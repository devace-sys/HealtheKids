USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_DELETE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_DELETE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_DELETE] (
    @userID        BIGINT
  , @userGroup     INT  
  , @userRank      INT    
  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @clientID      INT  
  , @recID         INT    
  , @MsgNoRec      VARCHAR(1000)
  , @MsgNoEdit     VARCHAR(1000)    
  , @spDetails     VARCHAR(8000) OUTPUT
  , @recordID      BIGINT        OUTPUT )    
AS    
BEGIN    
   
/***************************************************************************    
 * SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_DELETE */    
/**    
 * Deletes a service description
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
   
DECLARE @tranOpen as bit = 0
   
BEGIN TRY    
BEGIN TRANSACTION    
   
set @tranOpen = 1       
   
exec dbo.SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_DELETE_CORE
    @userID 
  , @userGroup
  , @userRank 
  , @editDelReason
  , @validateRec  
  , @clientID 
  , @recID 
  , @MsgNoRec 
  , @MsgNoEdit 
  , @spDetails output
  , @recordID  output
       
COMMIT TRANSACTION    
set @tranOpen = 0    
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
   
  SET @ErrorMessage = @ErrorMessage 
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_DELETE] TO [webuser]
GO
