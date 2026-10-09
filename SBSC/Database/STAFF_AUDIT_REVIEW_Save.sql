USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STAFF_AUDIT_REVIEW_Save') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.STAFF_AUDIT_REVIEW_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[STAFF_AUDIT_REVIEW_Save]    
 (@userID          BIGINT,
  @staffID         BIGINT, 
  @worktypeID      INT,
  @rate            INT,
  @auditDate       DATETIME,   
  @note            NVARCHAR(MAX))  
AS    
BEGIN    
   
/***************************************************************************    
 * STAFF_AUDIT_REVIEW_Save */    
/**    
 * Creates a new or edits existing entity record    
 * and manages any associated records.    
 *    
 * @param   staffID         
 * @param   editDelReason   Reason for record edit or delete    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   saveType        Type of operation to perform    
 *                          1 = New, 2 = Edit, 3 = Delete    
 * @param   recID           Record id of existing client record to edit or    
 *                          delete.    
 * @param   MsgNoRec        Desired error message if a recID is not found    
 * @param   MsgNoEdit       Desired error message if a record cannot be edited    
 * @param   MsgNoFullEdit   Desired error message if a record can only be partially edited
 * @param   MsgDupRec       Desired error message for duplicate detection    
 * @param   MsgNoClient     Desired error message if a clientID is not found 
 * @param   MsgNoGroup      Desired error message if a groupID is not found    
 * @param   MsgDataError    Desired error message for data errors    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of STAFF_PROMISED_HOURS record that    
 *                          was changed or deleted    
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
DECLARE @today              AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen           AS BIT            -- Is a transaction open    

BEGIN TRY    
   

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
IF (@worktypeID  IS NULL) RAISERROR ('Work type is required',  11, 1)       
IF (@staffID     IS NULL) RAISERROR ('staffID is required',    11, 1) 
IF (@rate        IS NULL) RAISERROR ('Rating is required',     11, 1)
IF (@auditDate   IS NULL) RAISERROR ('Audit date is required', 11, 1)

/*-------------------------------    
 * Prep worker variables    
 *------------------------------*/    
     
SET @today      = GETDATE()   
 
/*-------------------------------    
 * Create record    
 *------------------------------*/    
   
BEGIN TRANSACTION    
   
  SET @TranOpen = 1        
 
    /*-------------------------------    
     * dbo.STAFF_PROMISED_HOURS
     *------------------------------*/    
  
    INSERT INTO dbo.EMP_AUDIT_REVIEW
    (  
      STAFF_ID,
      WORKTYPE_ID,
      AUDIT_DATE,
      REVIEW_RATE,
      NOTE,
      REVIEWED_BY,
      ENTRY_DATE
    )    
    VALUES    
    (  
     @staffID,
     @workTypeID,
     @auditDate,
     @rate,
     @note,
     @userID,
     @today
    )                             
   
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

GRANT EXECUTE ON  [dbo].[STAFF_AUDIT_REVIEW_Save] TO [webuser]
GO
 
