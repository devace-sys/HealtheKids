USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_DELETE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SVCJOURNAL_JOURNAL_DELETE
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SVCJOURNAL_JOURNAL_DELETE]     
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @editDelReason VARCHAR(7000),    
  @validateRec   BIT,
  @clientID      INT,
  @pracID        INT,  
  @recID         INT,    
  @MsgNoRec      VARCHAR(1000),    
  @MsgNoEdit     VARCHAR(1000),    
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)  
AS    
BEGIN     
    
/***************************************************************************    
 * SVCJOURNAL_JOURNAL_DELETE */    
/**    
 * Delete entire journal
 *    
 ***************************************************************************/         
     
SET NOCOUNT ON    
   
DECLARE @TranOpen     AS BIT    
DECLARE @today        AS DATETIME          -- Current date/time stamp    
DECLARE @auditRecID   AS BIGINT            -- Audit record id    
DECLARE @saveType     AS INT    
DECLARE @updateState  AS INT    
DECLARE @completed    AS BIT = 0
   
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
SET @saveType   = dbo.CONST_SAVE_TYPE_DELETE()    

if (exists(select 1 from dbo.SvcJournals where ((clientID = @clientID) and (id = @recID) and (active = 1) and (completed = 0))))
begin

  /*============================================================
   * Check to see if we can still edit or delete this journal
   *===========================================================*/   

  declare @canStillEditOrDelJournal as bit = null
  
  set @canStillEditOrDelJournal = dbo.SvcJournal_Can_Edit (@userID,@userGroup,@userRank,@clientID,@recID)

  if ((@canStillEditOrDelJournal = 0) or (@canStillEditOrDelJournal is null)) 
  begin
    RAISERROR ('This journal cannot be deleted.', 11, 1)       
  end

 
  /*============================================================
   * Manage service records -- Delete
   *===========================================================*/   

  exec dbo.SVCJOURNAL_MANAGE_SERVICE_RECORDS
      @userID
    , @userGroup    
    , @userRank
    , @clientID
    , @recID
    , ''
    , @editDelReason
    , @validateRec
    , @saveType
    , @recID
    , @MsgNoRec
    , @MsgNoEdit
    , ''
    , ''
    , ''
    , ''
    , ''
    , ''
    , ''
    , ''
    , ''
    , ''
    , ''
    , @spDetails OUTPUT
    , @recordID  OUTPUT  

  /*============================================================
   * Delete all journal entries related to journal id
   *===========================================================*/   

  update dbo.SvcJournal_Event_Entries set active = 0, lastModified = @today, lastModifiedBy = @userID where ((journalID = @recID) and (active = 1))
  
  /*============================================================
   * Delete journal 
   *===========================================================*/   

  update dbo.SvcJournals set active = 0, lastModified = @today, lastModifiedBy = @userID where ((id = @recID) and (active = 1))
     

end  
 
 /*-------------------------------    
  * Create audit record
  *------------------------------*/    
   
 --EXEC REPORT_PUBLICATION_SUBSCRIPTIONS_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT     
         
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


GRANT EXECUTE ON  [dbo].[SVCJOURNAL_JOURNAL_DELETE] TO [webuser]
GO
