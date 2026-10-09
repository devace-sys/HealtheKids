USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_STUDENT_DATA_FILES_Delete') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENT_STUDENT_DATA_FILES_Delete
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[CLIENT_STUDENT_DATA_FILES_Delete]    
 (@userID        BIGINT,         
  @validateRec   BIT,
  @recID         INT,    
  @editDelReason VARCHAR(7000),    
  @MsgNoRec      VARCHAR(1000),    
  @MsgNoEdit     VARCHAR(1000),    
  @recordID      BIGINT        OUTPUT)    
AS    
BEGIN    
   
/***************************************************************************    
 * CLIENT_STUDENT_DATA_FILES_Delete */    
/**    
 * Deletes (hides) an existing CLIENT_STUDENT_DATA_FILES record    
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
DECLARE @tempRecID    AS INT               -- Used for determining if a rec exists    
DECLARE @today        AS DATETIME          -- Current date/time stamp    
DECLARE @auditRecID   AS BIGINT            -- Audit record id    
DECLARE @recUserID    AS BIGINT            -- Associated user id   
DECLARE @canEdit      AS BIT    
DECLARE @hasAccount   AS BIT
DECLARE @saveType     AS INT    
DECLARE @updateState  AS INT    
   
BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @saveType   = dbo.CONST_SAVE_TYPE_DELETE()    
SET @recordID   = 0    
SET @today      = GETDATE()    
   
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
   
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@recID       IS NULL) RAISERROR ('updateRecID is required', 11, 1)    
   
/*-------------------------------    
 * See if the record can be    
 * deleted (by looking at canEdit)
 * and retrieve any associated
 * entity records at the same time    
 *------------------------------*/    
     
SET @recordID   = NULL    
SET @recUserID  = NULL
SET @canEdit    = 1   /* Currently there are no restrictions on edit */
SET @hasAccount = 0

SELECT 
  @recordID     = ID 
  FROM dbo.CLIENT_STUDENT_DATA_FILES where ID = @recID
 
     
/*-------------------------------    
 * If there are any problems    
 * let the user know    
 *------------------------------*/    
   
IF (@recordID IS NULL) RAISERROR (@MsgNoRec,  11, 1)   -- Record not found    
IF (@canEdit = 0)      RAISERROR (@MsgNoEdit, 11, 1)   -- Record can not be deleted    
   

/*-------------------------------    
 * If we are just validating    
 * get out now    
 *------------------------------*/    
     
--IF (@validateRec = 1) RETURN(0)    
   
/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/    
   
BEGIN TRANSACTION    
   
  SET @TranOpen = 1    
   
  /*-------------------------------    
   * "Delete" existing entity record    
   *------------------------------*/    
     
  SET @updateState = dbo.CONST_SVC_REC_STATE_DEL()    
  
  UPDATE dbo.CLIENT_STUDENT_DATA_FILES
         SET ACTIVE = 0
  WHERE (ID = @recID)    


 /*-------------------------------    
   * Create audit record    
   *------------------------------*/    
   
 EXEC dbo.CLIENT_STUDENT_DATA_FILES_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT 
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
   
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CLIENT_STUDENT_DATA_FILES_Delete] TO [webuser]
GO
