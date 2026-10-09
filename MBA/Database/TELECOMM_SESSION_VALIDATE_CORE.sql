USE users
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_VALIDATE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TELECOMM_SESSION_VALIDATE_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TELECOMM_SESSION_VALIDATE_CORE] (
    @roomID                   varchar(256)
  , @email                    varchar(256)
  , @pin                      varchar(50)  
  , @today                    datetime

  , @skipMeetingHasNotStartedCheck bit

  , @sessionOK                bit     output
  , @sessionID                bigint  output
  , @participantClientID      bigint  output
  , @participantID            bigint  output
  , @isSessionFacilitator     bit     output
)    

AS    
BEGIN    
   
/***************************************************************************    
 * TELECOMM_SESSION_VALIDATE_CORE */    
/**    
 *    
 ***************************************************************************/        
     
SET NOCOUNT ON    

set @sessionOK            = 0
set @sessionID            = null
set @participantClientID  = null
set @participantID        = null
set @isSessionFacilitator = null

declare @meetingStartDateAdjusted as datetime
declare @meetingEndDateAdjusted   as datetime
declare @todayMinusMeetingStartAdjusted as int
declare @todayMinusMeetingEndAdjusted as int


BEGIN TRY    

set @sessionOK = 0

set @email  = trim(isnull(@email,''))
set @pin    = trim(isnull(@pin,''))
set @roomID = trim(isnull(@roomID,''))

/*============================================================
 * Exit if any of the credentials are empty
 *============================================================*/  

if (@email  = '')  RAISERROR ('Invalid room, email or pin', 11, 1) 
if (@pin    = '')  RAISERROR ('Invalid room, email or pin', 11, 1) 
if (@roomID = '')  RAISERROR ('Invalid room, email or pin', 11, 1) 

/*============================================================
 * Find session and participant
 *============================================================*/  

select top 1

   @sessionID                = ts.id
 , @participantClientID      = ts.clientID
 , @participantID            = tsp.id
 , @isSessionFacilitator     = tsp.sessionFacilitator
 , @meetingStartDateAdjusted = dateadd(minute,-15,ts.startDate)    /* 15 minute grace period */
 , @meetingEndDateAdjusted   = iif (  (tsp.sessionFacilitator = 1)
                                    , (dateadd(hour,3,ts.endDate)) /* Faciliator get 3 hours */
									, (dateadd(hour,2,ts.endDate))) /* Everyone else 2 hours*/

from dbo.TELECOMM_SESSIONS              as ts
join dbo.TELECOMM_SESSIONS_PARTICIPANTS as tsp on tsp.telecommSessionID = ts.id

where (
      (ts.roomID = @roomID)
  and (ts.active = 1)
  and (tsp.email = @email)
  and (tsp.pin   = @pin)  
)

/*============================================================
 * Exit if session not found
 *============================================================*/  

if (@sessionID is null) 
  RAISERROR ('Invalid participant or session is invalid or not active', 11, 1) 

/*============================================================
 * Exit if meeting has not begun or is over within
 * an adjusted period of time
 *============================================================*/  

set @todayMinusMeetingStartAdjusted = DATEDIFF(minute, @today, @meetingStartDateAdjusted) -- (now minus meeting start time)
set @todayMinusMeetingEndAdjusted   = DATEDIFF(minute, @today, @meetingEndDateAdjusted)   -- (now minus meeting end time)

if (@skipMeetingHasNotStartedCheck = 0)
begin
  --if @todayMinusMeetingStartAdjusted is within 2 days of meeting start
  if (@todayMinusMeetingStartAdjusted <= 2880 and @todayMinusMeetingStartAdjusted > 0)
  begin
	RAISERROR ('This meeting has not started yet. Please refer to your invitation email for start time', 11, 1)
  end

  --if @todayMinusMeetingStartAdjusted is over 2 days of meeting start
  if (@todayMinusMeetingStartAdjusted > 2880)
  begin
	RAISERROR ('Invalid participant or session is invalid or not active', 11, 1)
  end
end

--if @todayMinusMeetingEndAdjusted is within 2 days after the meeting
if (@todayMinusMeetingEndAdjusted >= -2880 and @todayMinusMeetingEndAdjusted < 0)
begin
	RAISERROR ('This meeting has ended', 11, 1)
end

--if @meetingStartAdjustedMinusToday is over 2 days after the meeting
if (@todayMinusMeetingEndAdjusted < -2880)
begin
	RAISERROR ('Invalid participant or session is invalid or not active', 11, 1)
end

--if (@today not between @meetingStartDateAdjusted and @meetingEndDateAdjusted) 
--begin
--  RAISERROR ('Invalid participant or session is invalid or not active ', 11, 1) 
--end    

/*============================================================
 * Done
 *============================================================*/  

set @sessionOK = 1

RETURN(0)    

END TRY    
BEGIN CATCH    
   
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
         
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
               
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[TELECOMM_SESSION_VALIDATE_CORE] TO [webuser]
GO
