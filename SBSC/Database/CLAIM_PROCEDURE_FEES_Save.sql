USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_PROCEDURE_FEES_Save') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIM_PROCEDURE_FEES_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[CLAIM_PROCEDURE_FEES_Save]    
 (@userID          BIGINT,    
  @userGroup       INT,    
  @userRank        INT,   
  @procID          bigint,
  @efctDate        datetime,
  @fees            numeric(18,2),  
  @editDelReason   VARCHAR(7000),    
  @validateRec     BIT,    
  @saveType        INT,    
  @recID           INT,    
  @MsgNotActive    VARCHAR(1000),
  @MsgNoRec        VARCHAR(1000),    
  @MsgNoEdit       VARCHAR(1000),
  @MsgNoFullEdit   VARCHAR(1000),    
  @MsgDupRec       VARCHAR(1000),    
  @MsgNoClient     VARCHAR(1000),
  @MsgNoGroup      VARCHAR(1000),   
  @MsgDataError    VARCHAR(1000),    
  @spDetails       VARCHAR(8000) OUTPUT,    
  @recordID        BIGINT        OUTPUT)  
AS    
BEGIN    
   
/***************************************************************************    
 * CLAIM_PROCEDURE_FEES_Save */    
/**    
 * Creates a new or edits existing entity record    
 * and manages any associated records.    
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   procID
 * @param   fees
 * @param   efctDate
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
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted    
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
DECLARE @tranOpen           AS BIT            -- Is a transaction open    
DECLARE @dupCount           AS INT            -- Duplicate counter used for validation    
DECLARE @updateState        AS SMALLINT       -- Indicates what state the record is left in    
DECLARE @canEdit            AS BIT            -- If the record is inactive it cannot be edited
DECLARE @isActive           AS BIT            -- Is this record active?
DECLARE @tempRecID          AS INT            -- Used for determining if a rec exists  
DECLARE @auditRecID         AS BIGINT         -- Audit record id    
DECLARE @today              AS DATETIME       -- Current date/time stamp
DECLARE @oldEfctDate        AS DATETIME       -- 


BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @recordID   = 0    
SET @spDetails  = ''
SET @today      = GETDATE()    
    
   
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
   
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',      11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',       11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',     11, 1)    
IF (@saveType    IS NULL) RAISERROR ('Save type is required',      11, 1)    
IF (@procID      IS NULL) RAISERROR ('procedureID  is required',   11, 1)  
IF (@fees        IS NULL) RAISERROR ('fees is required',           11, 1)    
IF (@efctDate    IS NULL) RAISERROR ('startdate is required',      11, 1)    
 

IF ((@saveType = dbo.CONST_SAVE_TYPE_EDIT()) AND (@recID IS NULL))    
  RAISERROR ('updateRecID is required', 11, 1)                             



/*-------------------------------    
 * Prep worker variables    
 *------------------------------*/    
     
SET @isActive        = 1  

/*-------------------------------    
 * Set default values
 *------------------------------*/  


/*-------------------------------    
 * If this is an edit
 * perform edit sanity checks
 *------------------------------*/ 

IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
BEGIN   
   
  SET @recordID   = NULL    
  SET @canEdit    = 1 /* Note: No current restrictions on edit */
  /*-------------------------------    
   * Does the record exist and if    
   * so can it be edited    
   *------------------------------*/
     
  SELECT    
    @recordID    = id,  
    @oldEfctDate = startDate
  FROM dbo.CLAIM_PROCEDURE_FEES_VIEW(@userID,@userGroup,@userRank,@recID,@procID,null,null,null,null) 
    
  /*-------------------------------    
   * If the record does not exist
   * or it cannot be edited  
   * exit and let the user know   
   *------------------------------*/

  IF (@recordID IS NULL)           RAISERROR (@MsgNoRec,  11, 1)        
  IF (@canEdit = 0)                RAISERROR (@MsgNoEdit, 11, 1)
  /*-------------------------------    
   * Check if the effective date 
   * overlaps with another fee range   
   *------------------------------*/  
  IF (@efctDate != @oldEfctDate)
  begin
      if (@efctDate <= (select max(Effective_Date) from PROCEDURE_FEES where Procedure_id = @procID and Effective_Date < @oldEfctDate and Active =1))   
                                                       or
         (@efctDate >= (select min(Effective_Date) from PROCEDURE_FEES where Procedure_id = @procID and Effective_Date > @oldEfctDate and Active =1))                                                                                               
       RAISERROR ('Effective date overlaps with another fee range for the selected claim procedure', 11, 1)
  
  end
 
  
END    
        
/*-------------------------------    
 * Validation    
 *------------------------------*/    
   
IF (((@saveType = dbo.CONST_SAVE_TYPE_NEW()) OR    
     (@saveType = dbo.CONST_SAVE_TYPE_EDIT())))    
BEGIN          
  
  /*-------------------------------    
   * Advisement validation   
   * Advisement does not prohibit
   * a record save. 
   *------------------------------*/    
   
  IF (@validateRec = 1)    
  BEGIN    
       
    /*-------------------------------    
     * Look for duplicate    
     * records excluding the record    
     * specified by recid    
     *------------------------------*/    
       
    SET @dupCount = 0    
     
    /*-------------------------------    
     * For duplicate checking    
     * We can rely on always having    
     * the  clientname and CDS        
     *------------------------------*/    
       
    SELECT 
      @dupCount = COUNT(pfv.id) 
    FROM dbo.CLAIM_PROCEDURE_FEES_VIEW(@userID,@userGroup,@userRank,null,@procID,null,@efctDate,null,null) 
      AS pfv
    WHERE 
      (@recID IS NULL) OR (pfv.id != @recID)           
   
    IF @dupCount > 0    
    BEGIN    
      SET @msgDupRec = dbo.STRING_CREATE(@msgDupRec, CONVERT(VARCHAR(10),@dupCount), NULL, NULL)    
      SET @spDetails = dbo.UPDATE_DETAILS(@spDetails,@msgDupRec,dbo.CONST_RET_DUP_RECORD())    
    END    
     
    /*-------------------------------    
     * If we are editing and the
     * record we are editing is not    
     * active warn the user
     *------------------------------*/    

    --IF ((@isActive = 0) AND (@saveType = dbo.CONST_SAVE_TYPE_EDIT())) 
    --  SET @spDetails = dbo.UPDATE_DETAILS(@spDetails,@MsgNotActive, dbo.CONST_RET_WARN())        
   
    /*-------------------------------    
     * If we are providing advisement    
     * validation exit now    
     *------------------------------*/    
         
    RETURN(0)         

  END    
END 
   
/*-------------------------------    
 * Create or modify our    
 * practitioner record    
 *------------------------------*/    
   
BEGIN TRANSACTION    
   
  SET @TranOpen = 1    
   
  /*-------------------------------    
   * New client record
   *------------------------------*/    
   
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN    
       
    SET @updateState = dbo.CONST_REC_STATE_NEW()
  /*-------------------------------    
   * Check if the effective date 
   * overlaps with another fee range   
   *------------------------------*/  
   
   if (@efctDate <= (select max(Effective_Date) from PROCEDURE_FEES where Procedure_id = @procID and Active =1))                                                                                                           
       RAISERROR ('Effective date overlaps with another fee range for the selected claim procedure', 11, 1) 
       
    /*-------------------------------    
     * PROCEDURE_FEES
     *------------------------------*/    
  
    INSERT INTO dbo.PROCEDURE_FEES
    (  
      Procedure_id,
      Effective_Date,
      Fee,
      active
    )    
    VALUES    
    (  
     @procID,
     @efctDate,
     @fees,
     1
    )      
    
    SET @recordID = SCOPE_IDENTITY()    
    
  END         
  
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN    

    /*-------------------------------    
     * Edit existing entity record 
     * for now edit only fee   
     *------------------------------*/    
     
     SET @updateState = dbo.CONST_REC_STATE_MOD()                  
       
     UPDATE dbo.PROCEDURE_FEES
     SET Effective_Date = @efctDate, 
         Fee            = @fees                 
     WHERE (ID  = @recID)    
    
  END    
  ELSE    
  BEGIN    
    RAISERROR ('Unknown save type', 11, 1)    
  END    
   
  /*-------------------------------    
   * Create audit record    
   *------------------------------*/    
   
   EXEC dbo.CLAIM_PROCEDURE_FEES_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT    
      
       
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

GRANT EXECUTE ON  [dbo].[CLAIM_PROCEDURE_FEES_Save] TO [webuser]
GO
 
