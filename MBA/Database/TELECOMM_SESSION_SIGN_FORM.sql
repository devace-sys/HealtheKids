USE users
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_SIGN_FORM') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TELECOMM_SESSION_SIGN_FORM
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TELECOMM_SESSION_SIGN_FORM] (
    @userID                           BIGINT    
  , @userGroup                        INT    
  , @userRank                         INT
  , @userIP							  varchar(500)
  , @userAgent						  varchar(8000) 
  , @roomID                           varchar(256)
  , @email                            varchar(256)
  , @pin                              varchar(50)  
  , @sigForFormID                     varchar(256)
  , @sigControlID                     varchar(256)
  , @sigClassName                     varchar(512)
  , @sigAdditionalData                varchar(max)
  , @ctrlAdditionalDataID             varchar(256)
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
 * TELECOMM_SESSION_SIGN_FORM */    
/**    
 *    
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
declare @today                as  DATETIME         -- Current date/time stamp    
declare @sessionOK            as  bit    = 0
declare @sessionID            as  bigint = null
declare @participantClientID  as  bigint = null
declare @participantID        as  bigint = null
declare @serverSessionID      as  varchar(256)
declare @isSessionFacilitator as  bit    = null
declare @tranOpen             as  bit       = 0
declare @logID				  as bigint

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

set @jsonData = '{'
			  + '"sigForFormID":""'		      	  
			  + ',"sigControlID":""'
			  + ',"sigClassName":""'
			  + ',"sigAdditionalData":""'
			  + ',"ctrlAdditionalDataID":""'
			  + ',"teleCommServerSessionID":""'
			  + '}'

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
  @serverSessionID = ts.serverSessionID
from dbo.TELECOMM_SESSIONS as ts 
where (ts.id = @sessionID)

/*============================================================
 * Log
 *============================================================*/  

exec dbo.TELECOMM_SESSION_CREATE_LOG_ENTRY_CORE
      @sessionID
	, @today
	, @participantID
	, 'Signature'
	, @userIP
	, @userAgent
	, ''
	, @logID output

/*============================================================
 * Save data
 *============================================================*/  
  
insert into dbo.TELECOMM_SESSIONS_SIGNATURES (  
    [telecommSessionID]   
  , [telecommSessionParticipantID]      
  , [sigForFormID]
  , [sigControlID]
  , [sigClassName]
  , [sigAdditionalData]
  , [ctrlAdditionalDataID]
  , [recordedOn]   
  , [logID]
 )
 values (
    @sessionID
  , @participantID
  , @sigForFormID
  , @sigControlID
  , @sigClassName
  , @sigAdditionalData
  , @ctrlAdditionalDataID
  , @today  
  , @logID
)
    
/*============================================================
 * Get record id of saved data
 *============================================================*/  

set @recordID = SCOPE_IDENTITY()  

/*============================================================
 * Generate JSON to return
 *============================================================*/  

set @jsonData = '{'
			  + '"sigForFormID":"'             + STRING_ESCAPE (isnull(@sigForFormID         ,'') ,'JSON') + '"'		      	  
			  + ',"sigControlID":"'            + STRING_ESCAPE (isnull(@sigControlID         ,'') ,'JSON') + '"'
			  + ',"sigClassName":"'            + STRING_ESCAPE (isnull(@sigClassName         ,'') ,'JSON') + '"'
			  + ',"sigAdditionalData":"'       + STRING_ESCAPE (isnull(@sigAdditionalData    ,'') ,'JSON') + '"'
			  + ',"ctrlAdditionalDataID":"'    + STRING_ESCAPE (isnull(@ctrlAdditionalDataID ,'') ,'JSON') + '"'
			  + ',"teleCommServerSessionID":"' + STRING_ESCAPE (isnull(@serverSessionID      ,'') ,'JSON') + '"'
			  + '}'
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

GRANT EXECUTE ON  [dbo].[TELECOMM_SESSION_SIGN_FORM] TO [webuser]
GO
