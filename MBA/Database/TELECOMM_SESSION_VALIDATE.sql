USE users
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_VALIDATE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TELECOMM_SESSION_VALIDATE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TELECOMM_SESSION_VALIDATE] (
    @roomID                   varchar(256)
  , @email                    varchar(256)
  , @pin                      varchar(50)  
  , @userIP                   varchar(500)
  , @userAgent                varchar(8000)
  , @action                   varchar(255)
  , @sessionOK                bit     output
  , @sessionID                bigint  output
  , @participantClientID      bigint  output
  , @participantID            bigint  output
  , @isSessionFacilitator     bit     output
)    

AS    
BEGIN    
   
/***************************************************************************    
 * TELECOMM_SESSION_VALIDATE */    
/**    
 *    
 ***************************************************************************/        
     
SET NOCOUNT ON    
declare @today as datetime
set @today = GETDATE()

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

declare @logID as bigint = null

exec dbo.TELECOMM_SESSION_CREATE_LOG_ENTRY_CORE
      @sessionID
	, @today
	, @participantID
	, @action
	, @userIP
	, @userAgent
	, ''
	, @logID output


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

GRANT EXECUTE ON  [dbo].[TELECOMM_SESSION_VALIDATE] TO [webuser]
GO
