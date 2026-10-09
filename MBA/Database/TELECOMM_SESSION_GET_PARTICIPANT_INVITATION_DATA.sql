USE users
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_GET_PARTICIPANT_INVITATION_DATA') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TELECOMM_SESSION_GET_PARTICIPANT_INVITATION_DATA
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TELECOMM_SESSION_GET_PARTICIPANT_INVITATION_DATA] (
    @userID                           BIGINT    
  , @userGroup                        INT    
  , @userRank                         INT
  , @roomID                           varchar(256)
  , @email                            varchar(256)
  , @pin                              varchar(50)  
  , @editDelReason                    VARCHAR(7000)    
  , @validateRec               BIT    
  , @saveType                  INT    
  , @recID                     BIGINT    
  , @MsgNoRec                  VARCHAR(1000)    
  , @MsgNoEdit                 VARCHAR(1000) 
  , @MsgDupRec                 VARCHAR(1000)     
  , @MsgDataError              VARCHAR(1000)
  , @MsgNotActive              VARCHAR(1000)     
  , @recordID                  BIGINT        OUTPUT  
  , @jsonData                  varchar(max)  OUTPUT
  , @spDetails                 VARCHAR(8000) OUTPUT)    

AS    
BEGIN    
   
/***************************************************************************    
 * TELECOMM_SESSION_GET_PARTICIPANT_INVITATION_DATA */    
/**    
 *    
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
declare @today                       as  DATETIME         -- Current date/time stamp    
declare @sessionOK                   as  bit    = 0
declare @sessionID                   as  bigint = null
declare @participantClientID         as  bigint = null
declare @participantID               as  bigint = null
declare @serverSessionID             as  varchar(256)
declare @isSessionFacilitator        as  bit    = null
declare @meetingDateTime             as datetime
declare @title                       as varchar(512)
declare @meetingDate                 as date     
declare @meetingTime		         as time(0)
declare @meetingDurationInMins       as int 
declare @facilitatorTitle            as varchar(256)
declare @facilitatorEmail            as varchar(256)
declare @facilitatorName             as varchar(256)
declare @participantJsonData         as varchar(max)
declare @hasFacilitator              as bit  
declare @facilitatorIsParticipant    as bit
declare @purposeID                   as int
declare @roomBaseURL                 as varchar(256)
declare @inviteEmailBodyTemplateText as varchar(max)
declare @inviteEmailBodyTemplateHtml as varchar(max)
declare @tranOpen                    as bit       = 0

/*============================================================
 * Init
 *============================================================*/  

set @recordID  = 0
set @today     = GETDATE()    
set @spDetails = ''
set @tranOpen  = 0
set @jsonData  = ''

BEGIN TRY    

BEGIN TRANSACTION
set @tranOpen = 1

/* Keep in synch with TelecommSessionSignFormReturnData */

set @jsonData = '{"roomID":""'
              + ',"meetingDateTime":"'
              + ',"meetingTitle":""'
              + ',"meetingDate":""'
              + ',"meetingTime":""'
              + ',"meetingDurationInMins":0'
              + ',"hasFacilitator":false'
              + ',"facilitatorIsParticipant":false'
              + ',"facilitatorName":""'
              + ',"facilitatorTitle":""'
              + ',"facilitatorEmail":""'
              + ',"purposeID":0'
			  + ',"roomBaseURL":""'
			  + ',"inviteEmailBodyTemplateText":""'
			  + ',"inviteEmailBodyTemplateHtml":""'
			  + ',"serverSessionID":""'
              + ',"participants":[]}'

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
 * Lookup server session id (used for signal)
 *============================================================*/  

select top 1 
    @serverSessionID             = ts.serverSessionID
  , @roomID                      = ts.roomID
  , @meetingDateTime             = ts.startDate
  , @title                       = ts.title
  , @meetingDate                 = ts.meetingDate
  , @meetingTime                 = ts.meetingTime
  , @meetingDurationInMins       = ts.meetingDurationInMins
  , @hasFacilitator              = ts.hasFacilitator
  , @facilitatorIsParticipant    = ts.facilitatorIsParticipant
  ,	@facilitatorName		     = ts.facilitatorName
  ,	@facilitatorTitle		     = ts.facilitatorTitle
  ,	@facilitatorEmail		     = ts.facilitatorEmail
  , @purposeID                   = ts.purposeID
  , @roomBaseURL                 = tsp.roomBaseURL
  , @inviteEmailBodyTemplateText = tsp.inviteEmailBodyTemplateText	
  , @inviteEmailBodyTemplateHtml = tsp.inviteEmailBodyTemplateHtml
  , @participantJsonData = 
				( select 
					[idx]
				  , [name]
				  , title = isnull(title,'')
				  , [email]
				  , phone = isnull(phone,'')
				  , [pin]  
				  , userID = isnull(userID,-1)
				  , roleID = isnull(roleID,-1)
				  , entityID = isnull(entityID,-1)
				from dbo.TELECOMM_SESSIONS_PARTICIPANTS where telecommSessionID = @sessionID
				FOR JSON AUTO, INCLUDE_NULL_VALUES
				)
from dbo.TELECOMM_SESSIONS as ts 
join dbo.TELECOMM_SESSION_PURPOSE as tsp on tsp.id = ts.purposeID
where (ts.id = @sessionID)

/*============================================================
 * Generate json data to be returned
 *============================================================*/ 

set @jsonData = '{'
              + '"roomID":"'                        + STRING_ESCAPE (isnull(@roomID,''),'JSON') +'"'
			  + ',"meetingDateTime":"'              + STRING_ESCAPE (convert(varchar, @meetingDateTime, 22 ),'JSON') + '"' 
              + ',"meetingTitle":"'                 + STRING_ESCAPE (isnull(@title,''),'JSON') + '"'              
			  + ',"meetingDate":"'                  + STRING_ESCAPE (dbo.RPT_DATE_FMT(@meetingDate),'JSON') + '"' 
              + ',"meetingTime":"'                  + STRING_ESCAPE (dbo.RPT_TIME_FMT(@meetingTime,0),'JSON') + '"' 
              + ',"meetingDurationInMins":'         + convert(varchar(100),isnull(@meetingDurationInMins,0))  
              + ',"hasFacilitator":'                + iif((@hasFacilitator = 1),'true','false')
			  + ',"facilitatorIsParticipant":'      + iif((@facilitatorIsParticipant = 1),'true','false')  
              + ',"facilitatorName":"'              + STRING_ESCAPE (isnull(@facilitatorName,''), 'JSON') + '"'
              + ',"facilitatorTitle":"'             + STRING_ESCAPE (isnull(@facilitatorTitle,''),'JSON') + '"'
              + ',"facilitatorEmail":"'             + STRING_ESCAPE (isnull(@facilitatorEmail,''),'JSON') + '"'
              + ',"purposeID":'                     + convert(varchar(10),isnull(@purposeID,0))  
	  	      + ',"roomBaseURL":"'                  + STRING_ESCAPE (isnull(@roomBaseURL,''), 'JSON') +'"'
			  + ',"inviteEmailBodyTemplateText":"'  + STRING_ESCAPE (isnull(@inviteEmailBodyTemplateText,''), 'JSON') +'"'
			  + ',"inviteEmailBodyTemplateHtml":"'  + STRING_ESCAPE (isnull(@inviteEmailBodyTemplateHtml,''), 'JSON') +'"'
			  + ',"serverSessionID":"'              + STRING_ESCAPE (isnull(@serverSessionID,''), 'JSON') +'"'
              + ',"participants":'                  + @participantJsonData + '}'
    
/*============================================================
 * Get record id of saved data
 *============================================================*/  

set @tranOpen = 0

COMMIT TRANSACTION

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

if (@tranOpen  = 1) ROLLBACK TRANSACTION
       
  -- Error or raise error with severity 11 to 19 will be caught here    
         
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
     
   -- SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[TELECOMM_SESSION_GET_PARTICIPANT_INVITATION_DATA] TO [webuser]
GO
