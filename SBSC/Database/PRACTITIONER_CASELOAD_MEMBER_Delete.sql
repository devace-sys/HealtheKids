/* TODO: Add code to manage expected service data */

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_CASELOAD_MEMBER_Delete') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_CASELOAD_MEMBER_Delete
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[PRACTITIONER_CASELOAD_MEMBER_Delete]    
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @editDelReason VARCHAR(7000),
  @clientID      BIGINT,
  @pracID        BIGINT,
  @patID         BIGINT,
  @validateRec   BIT,
  @recID         INT,    
  @MsgNoRec      VARCHAR(1000),    
  @MsgNoEdit     VARCHAR(1000),    
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)    
AS    
BEGIN    
   
/***************************************************************************    
 * PRACTITIONER_CASELOAD_MEMBER_Delete */    
/**    
 * Deletes (hides) an existing Patients record    
 * and manages any associated records.    
 *    
 * @param   userID          The userid of who saved the record   
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT deleting the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   recID           Record id of existng Patient to edit or    
 *                          delete.    
 * @param   MsgNoRec        Desired error message for edit/delete service record    
 *                          operations when record is not found    
 * @param   MsgNoEdit       Desired error message for edit/delete service record    
 *                          operations if the service record cannot be edited or    
 *                          deleted    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted    
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
DECLARE @TranOpen AS BIT = 0

/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @recordID     = 0    
SET @spDetails    = ''    

BEGIN TRY    
   
set @TranOpen = 0

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
   
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',       11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',        11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',      11, 1)

/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/    
   
BEGIN TRANSACTION    
SET @TranOpen = 1    
exec dbo.PRACTITIONER_CASELOAD_MEMBER_Delete_Core @clientID, @pracID, @patID, null, @recordID output      
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

GRANT EXECUTE ON  [dbo].[PRACTITIONER_CASELOAD_MEMBER_Delete] TO [webuser]
GO
