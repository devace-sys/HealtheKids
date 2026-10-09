USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CIF_REQUESTS_UPDATE_RESOLUTIONS') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CIF_REQUESTS_UPDATE_RESOLUTIONS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CIF_REQUESTS_UPDATE_RESOLUTIONS]  
AS    

BEGIN     
    
/***************************************************************************    
 * CIF_REQUESTS_UPDATE_RESOLUTIONS */    
/**    
 * 
 ***************************************************************************/         

SET NOCOUNT ON        

BEGIN TRY

exec dbo.CIF_REQUESTS_UPDATE_RESOLUTIONS_STAND_ALONE_CLAIMS
exec dbo.CIF_REQUESTS_UPDATE_RESOLUTIONS_PROXY_CLAIMS
exec dbo.CIF_REQUESTS_UPDATE_RESOLUTIONS_RESUB_DENIALS

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
      
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CIF_REQUESTS_UPDATE_RESOLUTIONS] TO [webuser]
GO
