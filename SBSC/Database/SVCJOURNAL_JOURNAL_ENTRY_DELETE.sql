USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_ENTRY_DELETE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCJOURNAL_JOURNAL_ENTRY_DELETE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[SVCJOURNAL_JOURNAL_ENTRY_DELETE] (
    @userID        BIGINT
  , @userGroup     INT   
  , @userRank      INT
  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @journalID     BIGINT
  , @pracID        BIGINT  
  , @recID         BIGINT
  , @MsgNoRec      VARCHAR(1000)
  , @MsgNoEdit     VARCHAR(1000)
  , @spDetails     VARCHAR(8000) OUTPUT
  , @recordID      BIGINT        OUTPUT )    
AS    
BEGIN    
   
/***************************************************************************    
 * SVCJOURNAL_JOURNAL_ENTRY_DELETE */    
/**    
 * Delete record and manages any associated records.    
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
   
DECLARE @TranOpen     AS BIT    
DECLARE @today        AS DATETIME          -- Current date/time stamp    
DECLARE @auditRecID   AS BIGINT            -- Audit record id    
DECLARE @saveType     AS INT    
DECLARE @updateState  AS INT    
   
BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @saveType   = dbo.CONST_SAVE_TYPE_DELETE()    
SET @recordID   = 0    
SET @spDetails  = ''    
SET @today      = GETDATE()    
   
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
   
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@recID       IS NULL) RAISERROR ('updateRecID is required', 11, 1)    
   
/*-------------------------------    
 * If we are just validating    
 * get out now    
 *------------------------------*/    
     
IF (@validateRec = 1) RETURN(0)    
   
/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/    
   
BEGIN TRANSACTION    
   
  SET @TranOpen = 1    
   
  SET @updateState = dbo.CONST_SVC_REC_STATE_DEL()    
  set @recordID = @recID
  
  update dbo.SvcJournal_Event_Entries
  set 
      active          = 0
    , lastModified    = @today
    , lastModifiedBy  = @userID
    
  where (
        ([id]       = @recID)   
    and (journalID  = @journalID)
	and (pracID     = @pracID)
  )
  
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
   
  SET @ErrorMessage = @ErrorMessage
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SVCJOURNAL_JOURNAL_ENTRY_DELETE] TO [webuser]
GO
