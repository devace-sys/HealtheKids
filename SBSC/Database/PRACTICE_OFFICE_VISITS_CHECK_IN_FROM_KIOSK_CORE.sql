USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_KIOSK_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_KIOSK_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_KIOSK_CORE] (
    @userID                             bigint    
  , @userGroup                          int  
  , @userRank                           int 
  , @userIP                             varchar(500)                      
  , @userAgent                          varchar(8000)        
  , @clientID                           bigint
  , @groupSvcClassNameID                bigint
  , @siteID                             bigint
  , @kioskID                            bigint
  , @studentID                          nvarchar(50)
  , @practiceOfficeVisitReasonID        bigint
  , @practiceOfficeVisitReasonNotes     varchar(max)
  , @recordID                           bigint        OUTPUT
  , @spDetails                          varchar(8000) OUTPUT
  , @saveType                           int           OUTPUT)  
AS    
BEGIN    
   
/***************************************************************************    
 * Patients_Promised_Services_CDE_Audits_Current_Save */    
/**    
 * 
 ***************************************************************************/        

/*============================================================
 * Variables and init
 *============================================================*/  

declare @today                  as datetime    = getdate()
declare @tranOpen               as bit         = 0
declare @checkInDate            as date        = null
declare @checkInTime            as time(0)     = null
declare @patID                  as bigint      = null
declare @checkInComplete        as bit         = 0
declare @grade                  as varchar(20) = ''

set @today       = getdate()
set @saveType    = 0
set @recordID    = 0
set @spDetails   = ''

BEGIN TRY

/*============================================================
 * Defaults
 *============================================================*/  

set @studentID   = trim(isnull(@studentID,N''))
set @saveType    = dbo.CONST_SAVE_TYPE_NEW() /* Assume this is a new record */
set @checkInDate = convert(date,    @today) 
set @checkInTime = convert(time(0), @today)

/*============================================================
 * Check required parameters
 *============================================================*/  

IF (@userID      IS NULL)                 RAISERROR ('userID is required',          11, 1)      
IF (@userGroup   IS NULL)                 RAISERROR ('userGroup is required',       11, 1)    
IF (@userRank    IS NULL)                 RAISERROR ('userRank is required',        11, 1) 
IF (@clientID    is null)                 RAISERROR ('clientID is required',        11, 1) 
IF (@siteID      is null)                 RAISERROR ('siteID is required',          11, 1) 
IF (len(@studentID) = 0)                  RAISERROR ('Student ID is required',      11, 1) 
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
 * Attempt to find patID using student id
 *
 * Note: We do not allow blank student ids and we enforce
 * that earlier on in the procedure so we do not need to 
 * filter our blank student ids here. 
 *============================================================*/  

set @patID = null

select top 1 
    @patID = ps.PATIENT_ID
from dbo.PATIENTS_SCHOOL as ps
join dbo.PATIENTS_Client as pc on ((pc.CLIENT_ID = @clientID) and (pc.PATIENT_ID = ps.PATIENT_ID))
/* Uses [STUDENT_ID_PAT_ID_IDX] index */
where (
    (ps.STUDENT_ID = @studentID)
and (ps.PATIENT_ID        is not null)
and (ps.PATIENT_SCHOOL_ID is not null)
)

/*============================================================
 * If we found the patient
 *============================================================*/  

if (@patID is not null)
begin

  /*-------------------------------
   * Get patients current grade
   *------------------------------*/  

  select top 1 
    @grade = isnull(psvc.GRADE,'')
  from dbo.PATIENTS_SITES_VIEW_CURRENT(@clientID) as psvc
  where 
    (psvc.PATIENT_ID = @patID)

  /*-------------------------------
   * And we have a complete check
   * in
   *------------------------------*/  

  set @checkInComplete = 1

end

/*============================================================
 * If we did NOT find the patient 
 *============================================================*/  

else
begin

  /*-------------------------------
   * We have an incomplete check in
   *------------------------------*/  

  set @checkInComplete = 0

end

/*============================================================
 * Check student in with the data we have (either complete or
 * incomplete)
 *============================================================*/  

insert into dbo.PRACTICE_OFFICE_VISITS (
      clientID
	, groupSvcClassNameID
	, siteID
	, studentID
	, grade
	, patID
	, practiceOfficeVisitReasonID
	, practiceOfficeVisitReasonNotes
	, currentVisitStatusCodeValue
    , checkInDate
	, checkInTime
	, checkInDateTime
	, checkInComplete
	, waiting 
	, pracAssigned
	, visiting
	, completed
	, active
	, created 
    , createdBy
	, kioskID
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
	, -1 /* Unknown for now but will be updated further down */
	, @checkInDate
	, @checkInTime
	, @today
	, @checkInComplete
	, 1 /* Waiting */
    , 0 /* Prac assigned*/
    , 0 /* Visiting */
	, 0 /* Completed */
	, 1 /* Active */
	, @today
	, @userID
	, @kioskID
	, @userIP 
    , @userAgent
)

set @recordID = SCOPE_IDENTITY()

/*============================================================
 * Update the status log
 *============================================================*/  

/* Log if check in was complete or not */

if (@checkInComplete = 1)
begin
  exec dbo.PRACTICE_OFFICE_VISITS_UPDATE_STATUS_LOG_CORE @userID, @recordID, @today, 100
end
else
begin
  exec dbo.PRACTICE_OFFICE_VISITS_UPDATE_STATUS_LOG_CORE @userID, @recordID, @today, 200
end

/* Log waiting status */

exec dbo.PRACTICE_OFFICE_VISITS_UPDATE_STATUS_LOG_CORE @userID, @recordID, @today, 500

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

GRANT EXECUTE ON  [dbo].[PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_KIOSK_CORE] TO [webuser]
GO
