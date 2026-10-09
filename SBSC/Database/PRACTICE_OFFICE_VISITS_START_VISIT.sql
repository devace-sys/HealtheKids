USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTICE_OFFICE_VISITS_START_VISIT') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTICE_OFFICE_VISITS_START_VISIT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[PRACTICE_OFFICE_VISITS_START_VISIT] (
    @userID                             bigint    
  , @userGroup                          int  
  , @userRank                           int 
  , @clientID                           bigint
  , @pracID                             bigint
  , @validateRec                        BIT    
  , @editDelReason                      VARCHAR(7000)
  , @recID                              BIGINT
  , @MsgNoRec                           VARCHAR(1000)   
  , @MsgNoEdit                          VARCHAR(1000)
  , @spDetails                          VARCHAR(8000) OUTPUT    
  , @recordID                           BIGINT        OUTPUT)  
AS    
BEGIN    
   
/***************************************************************************    
 * PRACTICE_OFFICE_VISITS_START_VISIT */    
/**    
 * 
 ***************************************************************************/        

/*============================================================
 * Variables and init
 *============================================================*/  

declare @today                           as datetime     = getdate()
declare @tranOpen                        as bit          = 0
declare @prevPracID                      as bigint       = -1
declare @prevPatID                       as bigint       = -1
declare @prevCheckInComplete             as bit          = 0
declare @prevVisiting                    as bit          = 0
declare @prevPracAssigned                as bit          = 0
declare @prevCompleted                   as bit          = 0 
declare @currentStatusCodeValue          as int          = -1
declare @logPracAssigned                 as bit          = 0
declare @pracAssigned                    as bit          = 0
declare @startDate                       as date         = null
declare @startTime                       as time(0)      = null
declare @groupSvcClassNameID             as bigint       = -1
declare @pracAssignedGroupSvcClassNameID as bigint       = 0
declare @visitReasonID                   as bigint       = -1

set @today       = getdate()
set @recordID    = 0
set @spDetails   = ''
set @tranOpen    = 0

BEGIN TRY

/*============================================================
 * Check required parameters
 *============================================================*/  

IF (@userID      IS NULL)                 RAISERROR ('userID is required',      11, 1)      
IF (@userGroup   IS NULL)                 RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL)                 RAISERROR ('userRank is required',    11, 1) 
IF (@clientID    is null)                 RAISERROR ('clientID is required',    11, 1) 
IF (@pracID      is null)                 RAISERROR ('pracID is required',      11, 1) 
IF (@recID       is null)                 RAISERROR ('Record id is required',   11, 1)    

/*============================================================
 * Find visit record
 *============================================================*/  
  
select top 1 
      @recordID                 = pov.id
    , @prevCheckInComplete      = pov.checkInComplete
	, @prevPracAssigned         = pov.pracAssigned
	, @prevVisiting             = pov.visiting    
	, @prevCompleted            = pov.completed
	, @prevPracID               = pov.pracID
    , @groupSvcClassNameID      = pov.groupSvcClassNameID
	, @visitReasonID            = pov.practiceOfficeVisitReasonID

from dbo.PRACTICE_OFFICE_VISITS as pov
where (
      (1=1)    
  and (pov.id        = @recID)
  and (pov.clientID  = @clientID)    
)
  
/*============================================================
 * No record found, get out
 *============================================================*/  

if (@recordID != @recID)
begin
  RAISERROR (@MsgNoRec, 11, 1)
end

/*============================================================
 * Verify pracID exists if passed
 *============================================================*/  

if not exists (
  select top 1 
    prp1.PRACTITIONER_ID 
  from dbo.PRACTITIONER_Practitioner as prp1 
  join dbo.PRACTITIONER_CLIENT       as prc1 on ((prc1.CLIENT_ID = @clientID) and (prc1.PRACTITIONER_ID = prp1.PRACTITIONER_ID))
  where 
	  (prp1.PRACTITIONER_ID = @pracID)
)
begin
  RAISERROR ('Practitioner not found', 11, 1) 
end

/*============================================================
 * Get this practitioners group family
 *============================================================*/  

select top 1 
  @pracAssignedGroupSvcClassNameID = png.GROUP_SERVICE_CLASS_NAME_ID 
from dbo.PRACTITIONER_GROUPS                               as pg
join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on (     (png.GROUP_SERVICE_CLASS_PARTITION_ID = 100)
                                                                       and (png.GROUP_ID = pg.GROUP_ID)
                                                                       and (png.GROUP_SERVICE_CLASS_NAME_ID is not null)) /* Uses index */
where (
       /* Uses index */
     ((pg.PRACTITIONER_ID = @pracID)
 and (pg.GROUP_TYPE in (1,2))
 and (pg.GROUP_ID is not null)
 and (pg.PRACTITIONER_GROUP is not null))
 and (pg.ACTIVE = 1)
)

/*============================================================
 * If the practitioners practice family does not match the 
 * office practice family then exit
 *============================================================*/  
  
if (@pracAssignedGroupSvcClassNameID != @groupSvcClassNameID)
begin
  RAISERROR ('Practitioner must be in the same practice family as the office', 11, 1) 
end

/*============================================================
 * If check in process is not finished get out
 *============================================================*/  

if (@prevCheckInComplete = 0)
begin
  RAISERROR ('Check in process for this visit has not been completed', 11, 1)
end

/*============================================================
 * If visit has ended get out
 *============================================================*/  

if (@prevCompleted = 1)
begin
  RAISERROR ('This visit has been completed', 11, 1)
end

/*============================================================
 * Already visiting
 *============================================================*/  

if (@prevVisiting = 1)
begin
  if (@pracID != @prevPracID)
  begin
    RAISERROR ('This patient has been assigned to another practitioner', 11, 1)
  end
  return(0)
end

/*============================================================
 * Compare previous pracID to pracID passed
 *============================================================*/  

set @prevPracID = isnull(@prevPracID,0)
if (@prevPracID = 0) set @prevPracID = 0
set @logPracAssigned = 0

if (@prevPracID = 0) 
begin
  set @logPracAssigned = 1
end
else
begin
  if (@prevPracID != @pracID)
  begin
    set @logPracAssigned = 1
  end
  else
  begin
    set @logPracAssigned = 0
  end
end

/*============================================================
 * Get start visit date/time
 *============================================================*/  

set @startDate = convert(date,    @today) 
set @startTime = convert(time(0), @today)

/*============================================================
 * Get default resolution (if any)
 *============================================================*/  
 
 declare @visitResolutionID as bigint

 select top 1 
   @visitResolutionID = povr.practiceOfficeVisitResolutionID
 from dbo.PRACTICE_OFFICE_VISIT_REASONS as povr
 where 
   (povr.id = @visitReasonID)

/*============================================================
 * Validation
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  RETURN(0)    
END                          

/*============================================================
 * Start visit
 *============================================================*/  

begin transaction
set @tranOpen = 1

  
set @recordID = @recID

/* If the practitioner is self assigning log it*/

if (@logPracAssigned = 1)
begin
  exec dbo.PRACTICE_OFFICE_VISITS_UPDATE_STATUS_LOG_CORE @userID, @recordID, @today, 600
end

update dbo.PRACTICE_OFFICE_VISITS 
set
	pracID                          = @pracID
  , pracAssigned                    = 1 /* Will always be true regardless */
  , visiting                        = 1
  , visitStartDate                  = @startDate
  , visitStartTime                  = @startTime
  , visitStartDateTime              = @today
  , practiceOfficeVisitResolutionID = @visitResolutionID
  , lastModified                    = @today
  , lastModifiedBy                  = @userID
where (id = @recID)

/* Log visit started */

exec dbo.PRACTICE_OFFICE_VISITS_UPDATE_STATUS_LOG_CORE @userID, @recordID, @today, 700

commit transaction
set @tranOpen = 0

/*============================================================
 * All done
 *============================================================*/  

RETURN(0)    
END TRY  

/*============================================================
 * Exception handling
 *============================================================*/      

BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Return any
   * error error messages to    
   * the caller    
   *------------------------------*/    
       
 if (@tranOpen = 1) 
 begin
   rollback transaction
   set @tranOpen = 0
 end
 
  -- Error or raise error with severity 11 to 19 will be caught here    
            
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  -- Only send really bad exceptions back with sp details

  if (@ErrorSeverity > 11)    
    SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PRACTICE_OFFICE_VISITS_START_VISIT] TO [webuser]
GO
