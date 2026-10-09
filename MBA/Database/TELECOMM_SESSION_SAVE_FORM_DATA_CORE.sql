USE users
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_SAVE_FORM_DATA_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TELECOMM_SESSION_SAVE_FORM_DATA_CORE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TELECOMM_SESSION_SAVE_FORM_DATA_CORE] (
    @userID                           BIGINT    
  , @userGroup                        INT    
  , @userRank                         INT
  , @userIP                           varchar(500)
  , @userAgent						  varchar(8000)
  , @roomID                           varchar(256)
  , @email                            varchar(256)
  , @pin                              varchar(50)  
  , @formID                           varchar(256)
  , @formData                         varchar(max)
  , @dataFinalized                    BIT
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
  , @spDetails                 VARCHAR(8000) OUTPUT)    

AS    
BEGIN    
   
/***************************************************************************    
 * TELECOMM_SESSION_SAVE_FORM_DATA_CORE */    
/**    
 *    
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
declare @today                as  DATETIME         -- Current date/time stamp    
declare @sessionOK            as  bit    = 0
declare @sessionID            as  bigint = null
declare @participantClientID  as  bigint = null
declare @participantID        as  bigint = null
declare @isSessionFacilitator as  bit    = null
declare @logID                as bigint

/*============================================================
 * Init
 *============================================================*/  

set @recordID  = 0
set @today     = GETDATE()    
set @spDetails = ''

BEGIN TRY    

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
 * Log 
 *============================================================*/  

exec dbo.TELECOMM_SESSION_CREATE_LOG_ENTRY_CORE
      @sessionID
	, @today
	, @participantID
	, 'Data Entry'
	, @userIP
	, @userAgent
	, ''
	, @logID output

/*============================================================
 * Save data
 *============================================================*/  

insert into dbo.TELECOMM_SESSIONS_FORM_DATA (  
    [telecommSessionID]   
  , [telecommSessionParticipantID]      
  , [formID]
  , [formData]
  , [recordedOn]   
  , [dataFinalized]
  , [validateRec]
  , [logID]
 )
 values (
    @sessionID
  , @participantID
  , @formID
  , @formData
  , @today  
  , @dataFinalized
  , @validateRec
  , @logID
)
    
/*============================================================
 * Get record id of saved data
 *============================================================*/  

set @recordID = SCOPE_IDENTITY()  


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
     
   -- SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[TELECOMM_SESSION_SAVE_FORM_DATA_CORE] TO [webuser]
GO
