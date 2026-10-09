USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_BAN') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TELECOMM_SESSION_BAN
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TELECOMM_SESSION_BAN] (
    @roomID                  varchar(256)
  , @email                   varchar(256)
  , @pin                     varchar(50)  
  , @userIP                  varchar(500)
  , @userAgent               varchar(8000)
  , @participantEmailToBan   varchar(256) 
)
AS
BEGIN

/***************************************************************************
 * TELECOMM_SESSION_BAN */
/**
 * Ban a participant from a session
 *
 * @return                 
 ***************************************************************************/ 

SET NOCOUNT ON;  
  
declare @tranOpen                       as bit          = 0
declare @today                          as datetime     = getdate()  

declare @participantClientID            as bigint       = null                
declare @participantID                  as bigint       = null
declare @isSessionFacilitator           as bit          = null
declare @sessionOK                      as bit	        = 0          
declare @sessionID                      as bigint	    = -1        
declare @actingParticipantIsFacilitator as bit          = 0
declare @participantIDToBan             bigint          = null
declare @jsonData                       varchar(max)

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
  , @isSessionFacilitator     output

/*============================================================
 * If we get to this point verify that caller is a facilitator
 *============================================================*/  

if (@isSessionFacilitator = 0)
begin
  RAISERROR('Participant must be a moderator', 11, 1)
end

/*============================================================
 * If we get to this point, lookup participant to ban by email
 *============================================================*/  

select top 1 
  @participantIDToBan = tsp.id
from dbo.TELECOMM_SESSIONS              as ts
join dbo.TELECOMM_SESSIONS_PARTICIPANTS as tsp on tsp.telecommSessionID = ts.id
where ( 
      (ts.id = @sessionID)
  and (tsp.email = @participantEmailToBan)
)

/*============================================================
 * If participant not found or already banned exit
 *============================================================*/  

if (@participantIDToBan is null) return(0)

/*============================================================
 * Create json string to hold record of participant we are about
 * to ban
 *============================================================*/  

declare @bannedParticipantJSON as varchar(max) = ''
set @bannedParticipantJSON = convert(varchar(max),(select top 1 * from dbo.TELECOMM_SESSIONS_PARTICIPANTS where (id = @participantIDToBan) FOR JSON PATH , WITHOUT_ARRAY_WRAPPER))

/*============================================================
 * Delete participant record to ban participant
 *============================================================*/  

delete from dbo.TELECOMM_SESSIONS_PARTICIPANTS where (id = @participantIDToBan)

/*============================================================
 * Log
 *============================================================*/  

declare @logID as bigint = null
set @jsonData = '{"participantRecordBanned":' + @bannedParticipantJSON + ', "bannedByParticipantID":' + CONVERT(VARCHAR(30), @participantID) + '}'

exec dbo.TELECOMM_SESSION_CREATE_LOG_ENTRY_CORE
      @sessionID
	, @today
	, @participantID
	, 'Ban'
	, @userIP
	, @userAgent
	, @jsonData
	, @logID output

COMMIT TRANSACTION
set @tranOpen = 0

RETURN (0)
END TRY
BEGIN CATCH   
  
  if (@tranOpen = 1) ROLLBACK TRANSACTION
  
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

GRANT EXECUTE ON  [dbo].[TELECOMM_SESSION_BAN] TO [webuser]
GO
