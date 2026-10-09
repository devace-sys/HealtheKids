USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTICE_OFFICE_VISITS_END_VISIT') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTICE_OFFICE_VISITS_END_VISIT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[PRACTICE_OFFICE_VISITS_END_VISIT] (
    @userID                                       bigint    
  , @userGroup                                    int  
  , @userRank                                     int 
  , @clientID                                     bigint
  , @pracID                                       bigint
  , @checkInDate								  date
  , @checkInTime								  time(0)
  , @visitStartDate								  date	
  , @visitStartTime								  time(0)	
  , @visitEndDate								  date
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
 * PRACTICE_OFFICE_VISITS_END_VISIT */    
/**    
 * 
 ***************************************************************************/        

/*============================================================
 * Variables and init
 *============================================================*/  

declare @today                  as datetime     = getdate()
declare @tranOpen               as bit          = 0
declare @prevPracID             as bigint       = -1
declare @prevPatID              as bigint       = -1
declare @prevCheckInComplete    as bit          = 0
declare @prevVisiting           as bit          = 0
declare @prevPracAssigned       as bit          = 0
declare @prevCompleted          as bit          = 0 
declare @currentStatusCodeValue as int          = -1
declare @prevCheckInDate		as date
declare @prevCheckInTime		as time(0)
declare @prevCheckInDateTime    as datetime
declare @prevVisitStartDate		as date	
declare @prevVisitStartTime		as time(0)	
declare @prevVisitStartDateTime as datetime
declare @checkInDateTime        as datetime     = null
declare @visitStartDateTime     as datetime     = null
declare @endDate                as date         = null
declare @endTime                as time(0)      = null
declare @visitEndDateTime       as datetime     = null
declare @logTimesChanged        as bit          = 0

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
 * Find record
 *============================================================*/  
  
select top 1 
      @recordID                 = pov.id
    , @prevCheckInComplete      = pov.checkInComplete
	, @prevPracAssigned         = pov.pracAssigned
	, @prevVisiting             = pov.visiting    
	, @prevCompleted            = pov.completed
	, @prevPracID               = pov.pracID
	, @prevCheckInDate          = pov.checkInDate
	, @prevCheckInTime          = dbo.TIME_HH_MM_ONLY(pov.checkInTime)
	, @prevVisitStartDate       = pov.visitStartDate
	, @prevVisitStartTime       = dbo.TIME_HH_MM_ONLY(pov.visitStartTime)

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
 * Not visiting yet
 *============================================================*/  

if (@prevVisiting = 0)
begin
  RAISERROR ('This visit has not started yet', 11, 1)
end

/*============================================================
 * Compare previous pracID to pracID passed
 *============================================================*/  

set @prevPracID = isnull(@prevPracID,0)
if (@prevPracID = 0) set @prevPracID = 0
if (@prevPracID != @pracID)
begin
  RAISERROR ('The practitioner who started the visit must be the one that completes the visit', 11, 1)
end

/*============================================================
 * Recalc prev check in datetime and start datetime
 * We stripped seconds out of the time components and need
 * to set these values so we can properly compare previos
 * to new values
 *============================================================*/  

set @prevCheckInDateTime    = dbo.DATE_TIME_COMBINE(@prevCheckInDate,   @prevCheckInTime)
set @prevVisitStartDateTime = dbo.DATE_TIME_COMBINE(@prevVisitStartDate,@prevVisitStartTime)

/*============================================================
 * Set check in datetime values to previously saved values
 * if values not provided and strip seconds out of
 * check in time
 *============================================================*/  

if (@checkInDate is null) set @checkInDate = @prevCheckInDate
if (@checkInTime is null) set @checkInTime = @prevCheckInTime

set @checkInTime     = dbo.TIME_HH_MM_ONLY(@checkInTime)
set @checkInDateTime = dbo.DATE_TIME_COMBINE(@checkInDate, @checkInTime)

/*============================================================
 * Set start datetime values to previously saved values
 * if values not provided and strip seconds out of visit
 * start time
 *============================================================*/  

if (@visitStartDate is null) set @visitStartDate = @prevVisitStartDate
if (@visitStartTime is null) set @visitStartTime = @prevVisitStartTime

set @visitStartTime     = dbo.TIME_HH_MM_ONLY(@visitStartTime)
set @visitStartDateTime =  dbo.DATE_TIME_COMBINE(@visitStartDate, @visitStartTime)

/*============================================================
 * Calculate end visit date/time that will be used if one is
 * not provided
 *============================================================*/  

set @endDate = convert(date,    @today) 
set @endTime = convert(time(0), @today) 

/*============================================================
 * Set end datetime values to calculated values
 * if values not provided
 *============================================================*/  

if (@visitEndDate is null) set @visitEndDate = @endDate
if (@visitEndTime is null) set @visitEndTime = @endTime

set @visitEndTime = dbo.TIME_HH_MM_ONLY(@visitEndTime)
set @visitEndDateTime =  dbo.DATE_TIME_COMBINE(@visitEndDate, @visitEndTime)

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
 * Detect if check in datetimes and/or visit start datetimes 
 * changed
 *============================================================*/  
 
set @logTimesChanged = 0

if (@prevCheckInDateTime    != @checkInDateTime)    set @logTimesChanged = 1
if (@prevVisitStartDateTime != @visitStartDateTime) set @logTimesChanged = 1


/*============================================================
 * Validation exit
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


/* If user changed times then it */

if (@logTimesChanged = 1) exec dbo.PRACTICE_OFFICE_VISITS_UPDATE_STATUS_LOG_CORE @userID, @recordID, @today, 750


update dbo.PRACTICE_OFFICE_VISITS 
  set	
    completed                                    = 1
  , checkInDate                                  = @checkInDate
  , checkInTime                                  = @checkInTime
  , checkInDateTime								 = @checkInDateTime
  , visitStartDate								 = @visitStartDate
  , visitStartTime                               = @visitStartTime
  , visitStartDateTime							 = @visitStartDateTime
  , visitEndDate                                 = @visitEndDate
  , visitEndTime                                 = @visitEndTime
  , visitEndDateTime                             = @visitEndDateTime
  , currentVisitStatusCodeValue                  = 800 /* Visit ended */
  , practiceOfficeVisitResolutionID              = @practiceOfficeVisitResolutionID
  , practiceOfficeVisitResolutionNotes           = @practiceOfficeVisitResolutionNotes
  , practiceOfficeVisitResolutionFBQuestionsJSON = @practiceOfficeVisitResolutionFBQuestionsJSON
  , practiceOfficeVisitResolutionFBAnswersJSON   = @practiceOfficeVisitResolutionFBAnswersJSON
  , lastModified                                 = @today
  , lastModifiedBy                               = @userID

where (id = @recID)


/* Log visit ended */

exec dbo.PRACTICE_OFFICE_VISITS_UPDATE_STATUS_LOG_CORE @userID, @recordID, @today, 800

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

GRANT EXECUTE ON  [dbo].[PRACTICE_OFFICE_VISITS_END_VISIT] TO [webuser]
GO
