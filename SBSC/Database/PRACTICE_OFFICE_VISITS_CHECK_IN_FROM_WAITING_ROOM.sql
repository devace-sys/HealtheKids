USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_WAITING_ROOM') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_WAITING_ROOM
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_WAITING_ROOM] (
    @userID                             bigint    
  , @userGroup                          int  
  , @userRank                           int 
  , @userIP                             varchar(500)                    
  , @userAgent                          varchar(8000) 
  , @clientID                           bigint
  , @groupSvcClassNameID                bigint
  , @siteID                             bigint
  , @patID                              bigint
  , @practiceOfficeVisitReasonID        bigint
  , @practiceOfficeVisitReasonNotes     varchar(max)
  , @pracID                             bigint
  , @editDelReason                      VARCHAR(7000)
  , @validateRec                        BIT    
  , @recID                              BIGINT
  , @MsgNoRec                           VARCHAR(1000)   
  , @MsgDupRec                          VARCHAR(1000)
  , @MsgNoEdit                          VARCHAR(1000)
  , @MsgNotActive                       VARCHAR(1000)
  , @MsgDataError                       VARCHAR(1000)
  , @saveType                           int
  , @spDetails                          VARCHAR(8000) OUTPUT    
  , @recordID                           BIGINT        OUTPUT)  
AS    
BEGIN    
   
/***************************************************************************    
 * PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_WAITING_ROOM */    
/**    
 * 
 ***************************************************************************/        

/*============================================================
 * Variables and init
 *============================================================*/  

declare @today                           as datetime     = getdate()
declare @tranOpen                        as bit          = 0
declare @checkInDate                     as date         = null
declare @checkInTime                     as time(0)      = null
declare @studentID                       as nvarchar(50) = ''
declare @grade                           as varchar(20)  = ''
declare @checkInComplete                 as bit          = 0
declare @pracAssigned                    as bit          = 0
declare @prevPracID                      as bigint       = -1
declare @prevPatID                       as bigint       = -1
declare @prevCheckInComplete             as bit          = 0
declare @prevVisiting                    as bit          = 0
declare @prevPracAssigned                as bit          = 0
declare @prevCompleted                   as bit          = 0 
declare @logPracAssigned                 as bit          = 0
declare @logOfficeFixedCheckIn           as bit          = 0
declare @pracAssignedGroupSvcClassNameID as bigint = 0

set @today       = getdate()
set @recordID    = 0
set @spDetails   = ''
set @tranOpen    = 0

BEGIN TRY

/*============================================================
 * Defaults
 *============================================================*/  

set @checkInDate = convert(date,    @today) 
set @checkInTime = convert(time(0), @today)

/*============================================================
 * Make sure prac and patids that are set to 0 get reset to null
 *============================================================*/  

if (isnull(@patID,0)  = 0) set @patID  = null
if (isnull(@pracID,0) = 0) set @pracID = null

/*============================================================
 * Check required parameters
 *============================================================*/  

IF (@userID      IS NULL)                 RAISERROR ('userID is required',          11, 1)      
IF (@userGroup   IS NULL)                 RAISERROR ('userGroup is required',       11, 1)    
IF (@userRank    IS NULL)                 RAISERROR ('userRank is required',        11, 1) 
IF (@clientID    is null)                 RAISERROR ('clientID is required',        11, 1) 
IF (@patID       is null)                 RAISERROR ('patID is required',           11, 1)
IF (@siteID      is null)                 RAISERROR ('siteID is required',          11, 1) 
if (@saveType is null)                    RAISERROR ('Save type is required',       11, 1)
if (@practiceOfficeVisitReasonID is null) RAISERROR ('Reason is required',          11, 1)

/*============================================================
 * Verify practice family is supported
 *============================================================*/  

if (dbo.PRACTICE_OFFICE_VISITS_IS_PRACTICE_FAMILY_SUPPORTED (@groupSvcClassNameID) = 0)
begin
  RAISERROR ('This practice family is not supported', 11, 1) 
end

/*============================================================
 * Verify client and site exists
 *============================================================*/  

if not exists (
  select top 1 
    clc.CLIENT_ID
  from dbo.CLIENTS_Client as clc
  join dbo.SITES_Site     as ss on ss.SITE_CLIENT_ID = clc.CLIENT_ID
  where (
         (clc.CLIENT_ID = @clientID)
	 and (ss.SITE_ID    = @siteID)
  )
)
begin
  RAISERROR ('Client and site not found', 11, 1) 
end

/*============================================================
 * Verify patient ID exists
 *============================================================*/  

if not exists (
  select top 1 
     pap.PATIENT_ID
  from dbo.PATIENTS_Patient as pap
  join dbo.PATIENTS_Client  as pc on ((pc.CLIENT_ID = @clientID) and (pc.PATIENT_ID = pap.PATIENT_ID))
  where 
    (pap.PATIENT_ID = @patID)
)
begin
  RAISERROR ('Patient not found', 11, 1) 
end

/*============================================================
 * Verify reason exists
 *============================================================*/  

if not exists (
  select top 1 
    povr.id 
  from dbo.PRACTICE_OFFICE_VISIT_REASONS as povr
  where 
    (povr.id = @practiceOfficeVisitReasonID)	
)
begin
  RAISERROR ('Invalid reason id', 11, 1) 
end

/*============================================================
 * Verify pracID exists
 *============================================================*/  

if (@pracID is not null)
begin
 
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

end

/*============================================================
 * For new records 
 *============================================================*/  

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin

  /*============================================================
   * Find student id and grade
   *============================================================*/  

  select top 1 
      @studentID = isnull(psvc2.STUDENT_ID,N'')
	, @grade     = isnull(psvc2.GRADE,'')
  from dbo.PATIENTS_Patient as pap
  join dbo.PATIENTS_Client  as pc on ((pc.CLIENT_ID = @clientID) and (pc.PATIENT_ID = pap.PATIENT_ID))
  outer apply (
    select top 1 
        psvc1.STUDENT_ID 
	  , psvc1.GRADE	  
    from dbo.PATIENTS_SITES_VIEW_CURRENT(@clientID) as psvc1 
    where 
      (psvc1.PATIENT_ID = pap.PATIENT_ID)
   ) as psvc2
   where 
     (pap.PATIENT_ID = @patID)
     
  /*============================================================
   * Set status flags and logging options
   *============================================================*/  
  
  set @checkInComplete = 1
  set @pracAssigned    = 0
  set @logPracAssigned = 0

  /*============================================================
   * Determine what value we can set for pracAssigned
   *============================================================*/  

  if (@pracID is not null)
  begin
    set @pracAssigned    = 1
	set @logPracAssigned = 1
  end
  else
  begin
    set @pracAssigned    = 0
	set @logPracAssigned = 0
  end

end

/*============================================================
 * If we are editing the record
 *============================================================*/  

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  /*============================================================
   * Record id was not passed, get out
   *============================================================*/  

  IF (@recID IS NULL) RAISERROR ('Record id is required', 11, 1)    
  
  /*============================================================
   * Find record
   *============================================================*/  
  
  set @prevVisiting  = 0
  set @prevCompleted = 0

  select top 1 
      @recordID                 = pov.id
	, @prevPracID               = pov.pracID
    , @prevPatID                = pov.patID
	, @prevCheckInComplete      = pov.checkInComplete
	, @prevPracAssigned         = pov.pracAssigned   		
  from dbo.PRACTICE_OFFICE_VISITS as pov
  where (
        (1=1)    
    and (pov.id        = @recID)
	and (pov.clientID  = @clientID)
	and (pov.visiting  = 0)  /* Not allowed to modify if visit has started */
	and (pov.completed = 0)  /* Not allowed to modify if visit is complete */
  )
  
  /*============================================================
   * No record found, get out
   *============================================================*/  

  if (@recordID != @recID)
  begin
    RAISERROR ('This visit may have already started or is completed', 11, 1)
  end

  /*============================================================
   * Determine what we can set checkInComplete to
   * and if we can log a officeFixedCheckIn status
   *============================================================*/  

  set @checkInComplete               = 0
  set @logOfficeFixedCheckIn         = 0

  if ((@prevCheckInComplete = 0) and (@patID is null))  /* 0,0*/
  begin
    set @checkInComplete       = 0
	set @logOfficeFixedCheckIn = 0
  end
  
  else if ((@prevCheckInComplete = 0) and (@patID is not null)) /*0,1*/
  begin
    set @checkInComplete       = 1
    set @logOfficeFixedCheckIn = 1
  end
  
  else if ((@prevCheckInComplete = 1) and (@patID is null)) /*1,0*/
  begin
    set @checkInComplete       = 0
	set @logOfficeFixedCheckIn = 0
  end
  
  else if ((@prevCheckInComplete = 1) and (@patID is not null))
  begin
    set @checkInComplete       = 1
	set @logOfficeFixedCheckIn = 0
  end
  else 

  begin
    set @checkInComplete       = 0 
    set @logOfficeFixedCheckIn = 0
  end

  /*============================================================
   * Determine what value we can set for pracAssigned
   * and if we can log a prac assigned status
   *============================================================*/  

  set @pracAssigned    = 0
  set @logPracAssigned = 0

  if ((@prevPracAssigned = 0) and (@pracID is null))  /* 0,0*/
  begin
    set @pracAssigned    = 0
	set @logPracAssigned = 0
  end
  
  else if ((@prevPracAssigned = 0) and (@pracID is not null)) /*0,1*/
  begin
    set @pracAssigned    = 1
    set @logPracAssigned = 1
  end
  
  else if ((@prevPracAssigned = 1) and (@pracID is null)) /*1,0*/
  begin
    set @pracAssigned    = 0
	set @logPracAssigned = 0
  end
  
  else if ((@prevPracAssigned = 1) and (@pracID is not null))
  begin
    set @pracAssigned    = 1
	set @logPracAssigned = 0
  end
  else 
  begin
    set @checkInComplete = 0 
    set @logPracAssigned = 0
  end

end
else
begin
 RAISERROR ('Unknown or unsupported save type', 11, 1) 
end

/*============================================================
 * Validation
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  SET @recordID = 0 
  RETURN(0)    
END                          

/*============================================================
 * Check student in
 *============================================================*/  

begin transaction
set @tranOpen = 1

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin

  insert into dbo.PRACTICE_OFFICE_VISITS (
        clientID
	  , groupSvcClassNameID
	  , siteID
	  , studentID
	  , grade
	  , patID
	  , practiceOfficeVisitReasonID
	  , practiceOfficeVisitReasonNotes
      , checkInDate
	  , checkInTime
	  , checkInDateTime
	  , pracID
      , checkInComplete
      , waiting
      , pracAssigned	  
      , visiting
	  , currentVisitStatusCodeValue
      , created 
      , createdBy
	  , userIP
      , userAgent
  )
  values ( 
        @clientID
      , @groupSvcClassNameID
      , @siteID
	  , @studentID
      , @grade
	  , @patID
      , @practiceOfficeVisitReasonID
	  , @practiceOfficeVisitReasonNotes
	  , @checkInDate
	  , @checkInTime
	  , @today
	  , @pracID
	  , 1 /*checkInComplete*/
      , 1 /* Waiting */
	  , @pracAssigned
      , 0  /*visiting*/
	  , -1 /* Unknown for now but we will update below */
	  , @today
	  , @userID
	  , @userIP
	  , @userRank
  )

  set @recordID = SCOPE_IDENTITY()

  /*============================================================
   * Update status log
   *============================================================*/  

  /* Log complete check in from office */

  exec dbo.PRACTICE_OFFICE_VISITS_UPDATE_STATUS_LOG_CORE @userID, @recordID, @today, 400

  /* Log waiting */

  exec dbo.PRACTICE_OFFICE_VISITS_UPDATE_STATUS_LOG_CORE @userID, @recordID, @today, 500
  
  /* Practitioner assigned */

  if (@logPracAssigned = 1)  
  begin
    exec dbo.PRACTICE_OFFICE_VISITS_UPDATE_STATUS_LOG_CORE @userID, @recordID, @today, 600
  end

end

/*============================================================
 * Fix student check in and/or update visit data
 *============================================================*/  

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin
  
  set @recordID = @recID

  update dbo.PRACTICE_OFFICE_VISITS 
  set
	 -- studentID                      = @studentID
	  patID                          = @patID
	, pracID                         = @pracID
	, practiceOfficeVisitReasonID    = @practiceOfficeVisitReasonID
	, practiceOfficeVisitReasonNotes = @practiceOfficeVisitReasonNotes
	, checkInComplete                = @checkInComplete    
	, pracAssigned                   = @pracAssigned
	, lastModified                   = @today
    , lastModifiedBy                 = @userID
  where (id = @recID)

  /*============================================================
   * Update status log
   *============================================================*/  

  if (@logOfficeFixedCheckIn = 1)
  begin
    exec dbo.PRACTICE_OFFICE_VISITS_UPDATE_STATUS_LOG_CORE @userID, @recordID, @today, 300
  end
  
  if (@logPracAssigned = 1)
  begin
    exec dbo.PRACTICE_OFFICE_VISITS_UPDATE_STATUS_LOG_CORE @userID, @recordID, @today, 600
  end

end

else 
begin
 RAISERROR ('Unknown or unsupported save type', 11, 1) 
end

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

GRANT EXECUTE ON  [dbo].[PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_WAITING_ROOM] TO [webuser]
GO
