USE [users]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_MAN_PAGE_LOG_USER_RESPONSE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.APP_MAN_PAGE_LOG_USER_RESPONSE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[APP_MAN_PAGE_LOG_USER_RESPONSE]
 (@userID                BIGINT,    
  @userGroup             INT,    
  @userRank              INT, 
  @appName               varchar(50),    /* Application name (from web.config)*/
  @responseTypeID        int,
  @recID                 BIGINT,    
  @spDetails             VARCHAR(8000) OUTPUT,    
  @recordID              BIGINT        OUTPUT)  
AS    
BEGIN    
   
/***************************************************************************    
 * APP_ANNOUNCEMENT_LOG_USER_RESPONSE */    
/**    
 * @returns spDetails       Validation or error details    
 * @returns saveType        1 = New record created, 2 = Existing record edited
 * @returns recordID        New record id or record id of user record that    
 *                          was modified  
 ***************************************************************************/        
     
SET NOCOUNT ON    

DECLARE @tranOpen         AS BIT              -- Is a transaction open    

/*-------------------------------    
 * Init our output parameters   
 *------------------------------*/    

SET @spDetails  = ''    
set @recordID   = 0

BEGIN TRY    

BEGIN TRANSACTION    
SET @TranOpen = 1    

exec dbo.APP_MAN_PAGE_LOG_USER_RESPONSE_CORE   @userID   
                                             , @userGroup
                                             , @userRank
                                             , @appName
                                             , @responseTypeID
                                             , @recID    
                                             , @spDetails   OUTPUT    
                                             , @recordID    OUTPUT

COMMIT TRANSACTION    
SET @TranOpen = 0    
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
     
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
     
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

GRANT EXECUTE ON  [dbo].[APP_MAN_PAGE_LOG_USER_RESPONSE] TO [webuser]
GO

