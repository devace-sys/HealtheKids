USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRAINED_STAFF_Save') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.TRAINED_STAFF_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TRAINED_STAFF_Save]    
 (@staffID         int,
  @workTypeID      int,
  @rate            int,
  @trained         bit,
  @note            NVARCHAR(MAX),
  @editDelReason   VARCHAR(7000),    
  @validateRec     BIT,    
  @saveType        INT,    
  @recID           INT,    
  @MsgNotActive    VARCHAR(1000),
  @MsgNoRec        VARCHAR(1000),    
  @MsgNoEdit       VARCHAR(1000),
  @MsgDupRec       VARCHAR(1000),    
  @MsgDataError    VARCHAR(1000),    
  @recordID        BIGINT        OUTPUT)  
AS    
BEGIN    
   
/***************************************************************************    
 * Trained_Staff_SAVE */    
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
DECLARE @dupCount           AS INT            -- Duplicate counter used for validation    
DECLARE @updateState        AS SMALLINT       -- Indicates what state the record is left in    
DECLARE @canEdit            AS BIT            -- If the record is inactive it cannot be edited
DECLARE @isActive           AS BIT            -- Is this record active?
DECLARE @noFullEdit         AS BIT
DECLARE @tempRecID          AS INT            -- Used for determining if a rec exists  
DECLARE @auditRecID         AS BIGINT         -- Audit record id    


BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @recordID   = 0    
   
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
   

IF (@validateRec IS NULL) RAISERROR ('Validate flag required', 11, 1)    
IF (@saveType    IS NULL) RAISERROR ('Save type is required',  11, 1)    
IF (@staffID     IS NULL) RAISERROR ('staffID is required',    11, 1) 
IF (@workTypeID  IS NULL) RAISERROR ('workType is required',   11, 1) 
--IF (@rate        IS NULL) RAISERROR ('Rating is required',     11, 1) 

IF ((@saveType = dbo.CONST_SAVE_TYPE_EDIT()) AND (@recID IS NULL))    
  RAISERROR ('updateRecID is required', 11, 1)
  

/*-------------------------------    
 * Prep worker variables    
 *------------------------------*/    
     
SET @today      = GETDATE()   
SET @isActive   = 1  

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
    @recordID = ID   
  FROM dbo.TRAINED_STAFF where id = @recID
    
  /*-------------------------------    
   * If the record does not exist
   * or it cannot be edited  
   * exit and let the user know   
   *------------------------------*/

  IF (@recordID IS NULL) RAISERROR (@MsgNoRec,  11, 1)        
  IF (@canEdit = 0)      RAISERROR (@MsgNoEdit, 11, 1) 
  
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
     *------------------------------*/    
       
    SELECT 
      @dupCount = COUNT(ib.id) 
    FROM     
     dbo.TRAINED_STAFF  AS ib
    WHERE 
      STAFF_ID = @staffID and WORKTYPE_ID = @workTypeID
   
    IF @dupCount > 0    
    BEGIN    
      SET @saveType = dbo.CONST_SAVE_TYPE_EDIT() 
    select       @recID    = id
      FROM dbo.TRAINED_STAFF  AS ib
    WHERE 
      STAFF_ID = @staffID and WORKTYPE_ID = @workTypeID
   
    END    
     
    /*-------------------------------    
     * If we are editing and the
     * record we are editing is not    
     * active warn the user
     *------------------------------*/    

    IF ((@isActive = 0) AND (@saveType = dbo.CONST_SAVE_TYPE_EDIT())) 
   
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
     * dbo.STAFF_PROMISED_HOURS
     *------------------------------*/    
  
    INSERT INTO dbo.TRAINED_STAFF
    (  
      STAFF_ID,
      WORKTYPE_ID,
      TRAINED,
      RATING
    )    
    VALUES    
    (  
     @staffID,
     @workTypeID,
     @trained,
     @rate
    )      
    
    SET @recordID = SCOPE_IDENTITY()  
    
    /*-------------------------------    
    * dbo.STAFF_PROMISED_HOURS_AUDIT_LOG
    *------------------------------*/    
    
   --INSERT INTO dbo.TRAINED_STAFF_AUDIT_LOG
   --(
       
   --)  
   --VALUES
   --(  
    
   --)   
  
  END         
  
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN    
     
    /*-------------------------------    
     * Edit existing entity record    
     *------------------------------*/    
     
     SET @updateState = dbo.CONST_REC_STATE_MOD()   
     
    /*---------------------------------------------   
     * 
     *------------------------------------------*/
    
     UPDATE dbo.TRAINED_STAFF
     SET 
       STAFF_ID    = @staffID,
       WORKTYPE_ID = @workTypeID,
       TRAINED     = @trained,
       RATING      = @rate
     WHERE (id = @recID)
     
   /*-------------------------------    
    * dbo.STAFF_PROMISED_HOURS_AUDIT_LOG
    *------------------------------*/    
    
   --INSERT INTO dbo.TRAINED_STAFF_AUDIT_LOG
   --(
       
   --)  
   --VALUES
   --(  
    
   --)    
        
  END    
  ELSE    
  BEGIN    
    RAISERROR ('Unknown save type', 11, 1)    
  END    
   
  /*-------------------------------    
   * Create audit record    
   *------------------------------*/    
   
      
       
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

GRANT EXECUTE ON  [dbo].[TRAINED_STAFF_Save] TO [webuser]
GO
 
