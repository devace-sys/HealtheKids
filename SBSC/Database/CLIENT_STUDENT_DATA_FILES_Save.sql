USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('CLIENT_STUDENT_DATA_FILES_Save') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENT_STUDENT_DATA_FILES_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[CLIENT_STUDENT_DATA_FILES_Save]    
 (@userID          bigint,
  @clientID        bigint,
  @fileTypeID      bigint,
  @companyID       varchar(100),  
  @frequency       char,  
  @autoReq         bit,
  @requestedBy     bigint,
  @editDelReason   varchar(7000),    
  @validateRec     bit,    
  @saveType        int,    
  @recID           int,    
  @MsgNotActive    varchar(1000),
  @MsgNoRec        varchar(1000),    
  @MsgNoEdit       varchar(1000),
  @MsgDupRec       varchar(1000),    
  @MsgDataError    varchar(1000),    
  @recordID        bigint output)  
AS    
BEGIN    
   
/***************************************************************************    
 * CLIENT_STUDENT_DATA_FILES_Save */    
/**    
 * Creates a new or edits existing entity record    
 * and manages any associated records.    
 *    
 * @param   userID          The userid of who performed the operation 
 * @param   clientID        Client ID
 * @param   fileTypeID      File type ID
 * @param   company         company requesting datafile
 * @param   frequency       how frequent the file is being requested for this client
 *                          m - Monthly
 *                          q - Quarterly
 * @autoReq autoReq         send automatic requests
                            1 = send automatic requests 
                            0 = manual requests
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
   

IF (@validateRec  IS NULL) RAISERROR ('Validate flag     is required', 11, 1)    
IF (@saveType     IS NULL) RAISERROR ('Save type         is required', 11, 1)    
IF (@clientID     IS NULL) RAISERROR ('Client ID         is required', 11, 1)
IF (@fileTypeID   IS NULL) RAISERROR ('File type ID      is required', 11, 1)  
IF (@frequency    IS NULL) RAISERROR ('Request frequency is required', 11, 1)  
IF (@companyID    IS NULL) RAISERROR ('Company           is required', 11, 1)  
IF (@autoReq      IS NULL) RAISERROR ('Auto request      is required', 11, 1)  
IF (@requestedBy  IS NULL) RAISERROR ('Requested By      is required', 11, 1)  

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
    @recordID           = ID  
  FROM dbo.CLIENT_STUDENT_DATA_FILES where id = @recID
    
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
     * Duplicate checking             
     *------------------------------*/    
       
    SELECT 
      @dupCount = COUNT(f.id) 
    FROM     
      CLIENT_STUDENT_DATA_FILES AS f
    WHERE 
      CLIENT_ID          = @clientID   AND
      FILE_TYPE_ID       = @fileTypeID AND
      ((@recID is null) or (ID != @recID))

--if the record already exists and is not active, activate the same record
    if (@saveType =  dbo.CONST_SAVE_TYPE_NEW() and @dupCount = 1)
    begin
        select @recID = ID, @saveType = dbo.CONST_SAVE_TYPE_EDIT()
          from dbo.CLIENT_STUDENT_DATA_FILES
         WHERE CLIENT_ID = @clientID AND FILE_TYPE_ID = @fileTypeID 
         
         set @editDelReason = 'Reactivating the existing record'
         set @recordID = @recID
    end  
    else        
    IF @dupCount > 0    
    RAISERROR ('Student Data File record already exists for this file type!', 11, 1)              
         
  END    
END 
   
/*-------------------------------    
 * Create or modify our record    
 *------------------------------*/    
   
BEGIN TRANSACTION    
   
  SET @TranOpen = 1                
           
   
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN    
    SET @updateState = dbo.CONST_REC_STATE_NEW()             
        INSERT INTO dbo.CLIENT_STUDENT_DATA_FILES
    (  
	CLIENT_ID,
	FILE_TYPE_ID,
	COMPANY_ID,
	FREQUENCY,
	AUTO_REQUEST,
	REQUESTED_BY,
	ACTIVE	
    )    
    VALUES    
    (  
     @clientID,
     @fileTypeID,
     @companyID,
     @frequency,     
     @autoReq,
     @requestedBy,
     1
     )  
    SET @recordID = SCOPE_IDENTITY()   
      
  END         
  
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN    
     
    /*-------------------------------    
     * Edit existing entity record    
     *------------------------------*/    
     
     SET @updateState = dbo.CONST_REC_STATE_MOD()                           
            
      UPDATE dbo.CLIENT_STUDENT_DATA_FILES
      SET [CLIENT_ID]          = @clientID,
	      [FILE_TYPE_ID]       = @fileTypeID,
	      [COMPANY_ID]         = @companyID,
	      [FREQUENCY]          = @frequency,
	      REQUESTED_BY         = @requestedBy,
	      [AUTO_REQUEST]       = @autoReq,
	      [ACTIVE]	           = 1  
     WHERE (id  = @recID)             
        
  END    
  ELSE    
    RAISERROR ('Unknown save type', 11, 1)    
   
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

GRANT EXECUTE ON  [dbo].[CLIENT_STUDENT_DATA_FILES_Save] TO [webuser]
GO
 
