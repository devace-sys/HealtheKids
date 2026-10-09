USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_RESUBMIT_DENIED') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIM_RESUBMIT_DENIED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CLAIM_RESUBMIT_DENIED] (    
    @claimID        bigint  
  , @ignoreClaimAge bit = 0
)
     
AS    

BEGIN     
    
/***************************************************************************    
 * CLAIM_RESUBMIT_DENIED */    
/**    
 * Reset a denied claim so it can be resubmitted
 * 
 * @param   claimID         Claim ID
 * @param   validate        0 = Save mode
 *                          1 = Validation mode
 ***************************************************************************/         
     
SET NOCOUNT ON    
    
declare @tranOpen as bit = 0
set @tranOpen = 0

BEGIN TRY    
  
  begin transaction   
  set @tranOpen = 1  
  exec dbo.CLAIM_RESUBMIT_DENIED_CORE  @claimID, @ignoreClaimAge  
  commit transaction
  set @tranOpen = 0

RETURN(0)    
END TRY    
BEGIN CATCH    
    
  if (@tranOpen = 1) rollback transaction

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
 
GRANT EXECUTE ON  [dbo].[CLAIM_RESUBMIT_DENIED] TO [webuser]
GO
