USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_JOIN') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TELECOMM_SESSION_JOIN
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TELECOMM_SESSION_JOIN]
    @appName          varchar(50)    /* Application name (from web.config)*/
  , @userIP           varchar(500)
  , @userAgent        varchar(8000) 
  , @roomID           varchar(256)
  , @email            varchar(256)
  , @pin              varchar(50)  

  , @sessionOK                bit            output  
  , @sessionID                bigint         output
  , @serverSessionID          varchar(256)   output
  , @roomTitle                varchar(512)   output
  , @roomContent              nvarchar(max)  output
  , @roomFormHTML             nvarchar(max)  output
  , @roomFormJSON             nvarchar(max)  output
  , @participantID            bigint         output
  , @participantName          varchar(256)   output
  , @participantTitle         varchar(256)   output
  , @participantUserID        bigint         output
  , @participantRoleID        bigint         output
  , @participantEntityID      bigint         output
  , @participantIsFacilitator bit            output
  , @facilitatorIsPresent     bit            output /* Any faciliator is logged in */
  , @today                    datetime       output
  , @meetingStartDate         datetime       output
  , @meetingEndDate           datetime       output
  , @meetingDurationInMins    int            output  
  , @clientID                 bigint         output
  , @clientName               varchar(1000)  output
  , @latestRoomFormDataJSONRecorded       varchar(max)   output

AS
BEGIN

/***************************************************************************
 * TELECOMM_SESSION_JOIN */
/**
 * Participant joins a session
 *
 * @return                 
 ***************************************************************************/ 

SET NOCOUNT ON;  
  
declare @tranOpen  as bit = 0
declare @participantClientID as bigint  = null
declare @logID as bigint

set @today                  = getdate()
set @sessionOK              = 0
set @sessionID              = -1
set @serverSessionID        = ''
set @roomTitle              = ''
set @roomContent            = N''
set @roomFormHTML           = N''
set @roomFormJSON           = N'{}'
set @participantID          = -1
set @participantName        = ''
set @participantTitle       = ''

set @participantUserID     = -1
set @participantRoleID     = -1
set @participantEntityID   = -1

set @participantIsFacilitator = 0
set @facilitatorIsPresent     = 0

set @meetingStartDate       = null
set @meetingEndDate         = null
set @meetingDurationInMins  = 0
set @clientID               = 0
set @clientName             = ''
set @latestRoomFormDataJSONRecorded = '{}'  

BEGIN TRY
  
BEGIN TRANSACTION   

set @tranOpen = 1


/*============================================================
 * Validate caller
 *============================================================*/  

exec dbo.TELECOMM_SESSION_VALIDATE_CORE 
    @roomID 
  , @email 
  , @pin     
  , @today

  , 0 --@skipMeetingHasNotStartedCheck

  , @sessionOK                output
  , @sessionID                output
  , @participantClientID      output
  , @participantID            output
  , @participantIsFacilitator output

/*============================================================
 * Update session to indicate session attendance has begun
 *============================================================*/  

update dbo.TELECOMM_SESSIONS
  set attended = 1
where (id = @sessionID)

/*============================================================
 * Update participant record to indicate participant attended
 *============================================================*/  

update dbo.TELECOMM_SESSIONS_PARTICIPANTS
  set attendedSession = 1
where (id = @participantID)

/*============================================================
 * Log
 *============================================================*/  

exec dbo.TELECOMM_SESSION_CREATE_LOG_ENTRY_CORE
      @sessionID
	, @today
	, @participantID
	, 'Joined'
	, @userIP
	, @userAgent
	, ''
	, @logID output

/*============================================================
 * Retrieve meeting and participant details
 *============================================================*/  

select top 1

   @serverSessionID          = ts.serverSessionID
 , @roomTitle                = ts.title
 , @roomContent              = ts.content
 , @roomFormHTML             = ts.formsHTML
 , @roomFormJSON             = ts.formsJSON
 , @participantName          = isnull(tsp.name,    '')
 , @participantTitle         = isnull(tsp.title,   '')
 , @participantEntityID      = isnull(tsp.entityID,-1)
 , @participantUserID        = isnull(tsp.userID,  -1)
 , @participantRoleID        = isnull(tsp.roleID,  -1)
 , @meetingStartDate         = ts.startDate
 , @meetingEndDate           = ts.endDate
 , @meetingDurationInMins    = ts.meetingDurationInMins

from dbo.TELECOMM_SESSIONS              as ts
join dbo.TELECOMM_SESSIONS_PARTICIPANTS as tsp on tsp.telecommSessionID = ts.id

where (
      (ts.id  = @sessionID)
  and (tsp.id = @participantID)
)

/*============================================================
 * Determine if any faciliators are present
 *============================================================*/  

select top 1
  @facilitatorIsPresent = tsp.sessionFacilitator 
from dbo.TELECOMM_SESSIONS              as ts
join dbo.TELECOMM_SESSIONS_PARTICIPANTS as tsp on tsp.telecommSessionID = ts.id
where  (
      (ts.id = @sessionID)
  and (tsp.sessionFacilitator = 1)
  and (tsp.attendedSession    = 1)
)

/*============================================================
 * Retrieve latest meeting form and signature data recorded 
 * (if any) Note: 1 meeting form per meeting
 *============================================================*/  
 
set @latestRoomFormDataJSONRecorded = 
  STRING_ESCAPE (
    isnull(
	  (
        select 
          fsd.formID
        , fsd.formDataJSON
      from dbo.TELECOMM_SESSION_FORM_AND_SIGNATURE_DATA_VIEW_LATEST_CORE(@sessionID) as fsd
      FOR JSON PATH, ROOT ('forms')
    ),'{}'),'JSON')

COMMIT TRANSACTION
set @tranOpen = 0

RETURN (0)
END TRY
BEGIN CATCH   
  
  if (@tranOpen = 1) ROLLBACK TRANSACTION
  set @sessionOK = 0
  
  -- Error or raise error with severity 11 to 19 will be caught here
  DECLARE @ErrorMessage NVARCHAR(4000)
  DECLARE @ErrorSeverity INT
  DECLARE @ErrorState INT
  SELECT  @ErrorMessage = ERROR_MESSAGE(),
          @ErrorSeverity = ERROR_SEVERITY(),
          @ErrorState = ERROR_STATE()
   -- Reraise the error so it returns back to the server
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)
  
  RETURN(1)

END CATCH
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[TELECOMM_SESSION_JOIN] TO [webuser]
GO
