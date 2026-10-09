USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTICE_OFFICE_VISITS_EDIT_COMPLETED_VISIT') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTICE_OFFICE_VISITS_EDIT_COMPLETED_VISIT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[PRACTICE_OFFICE_VISITS_EDIT_COMPLETED_VISIT] (
    @userID                                       bigint    
  , @userGroup                                    int  
  , @userRank                                     int 
  , @clientID                                     bigint
  , @pracID                                       bigint
  , @visitStartDate								  datetime
  , @visitStartTime								  time(0)
  , @visitEndDate								  datetime
  , @visitEndTime								  time(0)
  , @practiceOfficeVisitResolutionID              bigint
  , @practiceOfficeVisitResolutionNotes           varchar(max)
  , @practiceOfficeVisitResolutionFBQuestionsJSON varchar(max)
  , @practiceOfficeVisitResolutionFBAnswersJSON   varchar(max)
  , @validateRec                                  bit    
  , @editDelReason                                varchar(7000)
  , @recID                                        bigint
  , @MsgNoRec                                     varchar(1000)   
  , @MsgNoEdit                                    varchar(1000)
  , @spDetails                                    varchar(8000) output    
  , @recordID                                     bigint        output)  
AS    
BEGIN    
   
/***************************************************************************    
 * PRACTICE_OFFICE_VISITS_EDIT_COMPLETED_VISIT */    
/**    
 * 
 ***************************************************************************/        

/*============================================================
 * Variables and init
 *============================================================*/  

declare @today                  as datetime     = getdate()
declare @tranOpen               as bit          = 0
declare @prevPracID             as bigint       = -1
declare @checkInDate            as date         = null
declare @checkInTime            as time(0)      = null
declare @checkInDateTime        as datetime     = null
declare @visitStartDateTime     as datetime     = null
declare @visitEndDateTime       as datetime     = null
declare @hh                     as int          = 0
declare @mm                     as int          = 0
declare @ss                     as int          = 0

set @today       = getdate()
set @recordID    = 0
set @spDetails   = ''
set @tranOpen    = 0

BEGIN TRY

/*============================================================
 * Check required parameters
 *============================================================*/  

IF (@userID         IS NULL)    RAISERROR ('userID is required',            11, 1)      
IF (@userGroup      IS NULL)    RAISERROR ('userGroup is required',         11, 1)    
IF (@userRank       IS NULL)    RAISERROR ('userRank is required',          11, 1) 
IF (@recID          is null)    RAISERROR ('Record id is required',         11, 1)    
IF (@clientID       is null)    RAISERROR ('clientID is required',          11, 1) 
IF (@pracID         is null)    RAISERROR ('pracID is required',            11, 1) 
IF (@visitStartDate is null)    RAISERROR ('Visit start date is required',  11, 1) 
IF (@visitStartTime is null)    RAISERROR ('Visit start time is required',  11, 1) 
IF (@visitEndDate   is null)    RAISERROR ('Visit end date is required',    11, 1) 
if (@visitEndTime   is null)    RAISERROR ('Visit end time is required',    11, 1) 

if (@practiceOfficeVisitResolutionID is null) RAISERROR ('Resolution is required', 11, 1) 

/*============================================================
 * Verify pracID exists 
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
 * Verify resolution exists
 *============================================================*/  

if not exists(
  select top 1  
    povr.id 
  from dbo.PRACTICE_OFFICE_VISIT_RESOLUTIONS as povr
  where 
   (povr.id = @practiceOfficeVisitResolutionID)
)
begin
  RAISERROR ('Invalid visit resolution', 11, 1)
end

/*============================================================
 * Find completed record
 *============================================================*/  
  
select top 1     
    @recordID      = pov.id
  , @checkInDate   = pov.checkInDate
  , @checkInTime   = pov.checkInTime	
  , @prevPracID    = pov.pracID
from dbo.PRACTICE_OFFICE_VISITS as pov
where (
      (1=1)    
  and (pov.id        = @recID)
  and (pov.clientID  = @clientID)  
  and (pov.completed = 1)
  and (pov.active    = 1)    
)
  
/*============================================================
 * No record found, get out
 *============================================================*/  

if (@recordID != @recID)
begin
  RAISERROR (@MsgNoRec, 11, 1)
end

/*============================================================
 * Compare previous pracID to pracID passed
 *============================================================*/  

if (@prevPracID != @pracID)
begin
  RAISERROR ('The practitioner who completed the visit is the only one who can make changes', 11, 1)
end

/*============================================================
 * Calculate visit checkindatetime, startdatetime and 
 * enddatetime
 *
 * Note: Do not use saved value for checkindatetime as we need
 * to remove the seconds and mS portion
 *============================================================*/  

/* We recalc check in time removing the ms so its compatible with
 * the start and end times passed in
 */

set @hh  = datepart (hour,   @checkInTime)
set @mm  = datepart (minute, @checkInTime)
set @ss  = datepart (second, @checkInTime)
set @checkInTime = timefromparts(@hh,@mm,@ss,0,0)

/* The new visit start time is passed in without seconds.  
 * We generate a new start time using the hour and minute parts 
 * and we sub in the seconds from the check in time */

set @hh = datepart (hour,   @visitStartTime)
set @mm = datepart (minute, @visitStartTime)
set @visitStartTime = timefromparts(@hh,@mm,@ss,0,0)

/* The new visit end time is passed in without seconds.  
 * We generate a new end time using the hour and minute parts 
 * and we sub in the seconds from the check in time */

set @hh = datepart (hour,   @visitEndTime)
set @mm = datepart (minute, @visitEndTime)
set @visitEndTime = timefromparts(@hh,@mm,@ss,0,0)

set @checkInDateTime    = dbo.DATE_TIME_COMBINE (@checkInDate,    @checkInTime)
set @visitStartDateTime = dbo.DATE_TIME_COMBINE (@visitStartDate, @visitStartTime)
set @visitEndDateTime   = dbo.DATE_TIME_COMBINE (@visitEndDate,   @visitEndTime)

/*============================================================
 * Verify that visit date and times are valid
 *============================================================*/  

if (@visitStartDateTime > @visitEndDateTime)
begin
  RAISERROR ('The visit start date and time cannot be after the visit end date and time', 11, 1)
end

if (@checkInDateTime > @visitStartDateTime)
begin
  RAISERROR ('The visit start date and time cannot be before the check in date and time', 11, 1)
end

if (@checkInDateTime > @visitEndDateTime)
begin
  RAISERROR ('The visit end date and time cannot be before the check in date and time', 11, 1)
end

/*============================================================
 * Validation
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  RETURN(0)    
END                          

/*============================================================
 * End visit
 *============================================================*/  

begin transaction
set @tranOpen = 1
set @recordID = @recID

update dbo.PRACTICE_OFFICE_VISITS 
  set	
    currentVisitStatusCodeValue                  = 900 /* Post visit edit */
  , checkInDate                                  = @checkInDate
  , checkInTime                                  = @checkInTime
  , checkInDateTime                              = @checkInDateTime
  ,	visitStartDate								 = @visitStartDate  
  ,	visitStartTime								 = @visitStartTime 
  , visitStartDateTime                           = @visitStartDateTime  
  ,	visitEndDate								 = @visitEndDate 
  ,	visitEndTime								 = @visitEndTime   
  , visitEndDateTime                             = @visitEndDateTime
  , practiceOfficeVisitResolutionID              = @practiceOfficeVisitResolutionID
  , practiceOfficeVisitResolutionNotes           = @practiceOfficeVisitResolutionNotes
  , practiceOfficeVisitResolutionFBQuestionsJSON = @practiceOfficeVisitResolutionFBQuestionsJSON
  , practiceOfficeVisitResolutionFBAnswersJSON   = @practiceOfficeVisitResolutionFBAnswersJSON
  , lastModified                                 = @today
  , lastModifiedBy                               = @userID

where (id = @recID)

/* TODO: Create service record */


/* Log visit post completion edit  */

exec dbo.PRACTICE_OFFICE_VISITS_UPDATE_STATUS_LOG_CORE @userID, @recordID, @today, 900

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

GRANT EXECUTE ON  [dbo].[PRACTICE_OFFICE_VISITS_EDIT_COMPLETED_VISIT] TO [webuser]
GO
