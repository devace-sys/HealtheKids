USE users
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_CREATE_LOG_ENTRY_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TELECOMM_SESSION_CREATE_LOG_ENTRY_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TELECOMM_SESSION_CREATE_LOG_ENTRY_CORE]
      @sessionID			bigint
	, @loggedOn				datetime
	, @participantID		bigint
	, @action				varchar(255)
	, @userIP				varchar(500)
	, @userAgent			varchar(8000)
	, @jsonData             varchar(max)
	, @logID	            bigint  output
   
/***************************************************************************    
 * TELECOMM_SESSION_CREATE_LOG_ENTRY_CORE */    
/**    
 *    
 ***************************************************************************/        
AS
BEGIN

set @logID = 0

BEGIN TRY    

insert into dbo.TELECOMM_SESSIONS_LOG (    
	  telecommSessionID
	, loggedOn
	, telecommSessionParticipantID
	, [action]
    , userIP
    , userAgent
	, jsonData)
values (
	  @sessionID	
	, @loggedOn		
	, @participantID
	, @action		
	, @userIP		
	, @userAgent
	, @jsonData	
)   

/*============================================================
 * Get record id of saved data
 *============================================================*/  

set @logID = SCOPE_IDENTITY()  

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

GRANT EXECUTE ON  [dbo].[TELECOMM_SESSION_CREATE_LOG_ENTRY_CORE] TO [webuser]
GO
