USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_PRAC_SALARIES_REACTIVATE_VALID_RECORDS') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CRCS_PRAC_SALARIES_REACTIVATE_VALID_RECORDS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[CRCS_PRAC_SALARIES_REACTIVATE_VALID_RECORDS] (
    @userID          Bigint
  , @userGroup       Int
  , @userRank        Int 
  , @clientID		 BigInt
  , @fiscalYearID	 BigInt
  , @quarterNumber	 Int
)    
AS    
BEGIN            
 
SET NOCOUNT ON    
 
DECLARE @TranOpen            AS BIT  

BEGIN TRY          

BEGIN TRANSACTION    
 
	exec dbo.CRCS_PRAC_SALARIES_REACTIVATE_VALID_RECORDS_CORE @clientID, @fiscalYearID, @quarterNumber

/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
 
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
 
   if (@ErrorSeverity > 11)    
     SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
 
  -- Reraise the error so it returns back to the server    
 
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
 
END CATCH    
END    
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CRCS_PRAC_SALARIES_REACTIVATE_VALID_RECORDS] TO [webuser]
GO