USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_INITIATE_CIF') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_INITIATE_CIF
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SERVICE_RECORD_INITIATE_CIF]     
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @editDelReason VARCHAR(7000),    
  @validateRec   BIT,
  @clientID      INT,
  @recID         INT,  
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * SERVICE_RECORD_INITIATE_CIF */    
/**    
 * Deletes (hides) an existing service record and manages any associated 
 * claim records.
 * 
 * NOTE: This is for single record deletes.
 *    
 * @param   userID          The userid of who saved the record    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   recID           Record id of existng service record to edit or    
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
    
DECLARE @TranOpen     AS BIT    
DECLARE @today        AS DATETIME       -- Current date/time stamp    
    
BEGIN TRY    

SET @today = GETDATE()    

/*-------------------------------    
 * If this is an actual save
 * or edit begin a transaction
 *------------------------------*/  

IF (@validateRec = 0)
BEGIN
  BEGIN TRANSACTION    
  SET @TranOpen  = 1 
END
ELSE
  SET @TranOpen = 0  

EXEC SERVICE_RECORD_Initiate_CIF_Core @userID, 
                                @userGroup, 
                                @userRank, 
                                @editDelReason, 
                                @validateRec, 
                                @clientID,
                                @recID,
                                @today,
                                @spDetails OUTPUT,
                                @recordID  OUTPUT

    
     
/*-------------------------------    
 * If this was an actual save
 * or edit commit the transaction
 *------------------------------*/  

IF (@TranOpen  = 1) 
  COMMIT TRANSACTION    

/*-------------------------------    
 * Reset our transaction flag
 *------------------------------*/  

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
    
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
    
  -- Reraise the error so it returns back to the server    
    
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_INITIATE_CIF] TO [webuser]
GO
