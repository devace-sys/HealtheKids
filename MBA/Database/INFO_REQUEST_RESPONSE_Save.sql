USE USERS
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INFO_REQUEST_RESPONSE_Save') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.INFO_REQUEST_RESPONSE_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[INFO_REQUEST_RESPONSE_Save]    
 (@userID            BIGINT,    
  @token             VARCHAR(100),
  @emailTittle       VARCHAR(8000),    
  @emailMsg          VARCHAR(8000),    
  @emailTo           VARCHAR(1000),    
  @emailCc           VARCHAR(1000),    
  @clientID          BIGINT,
  @fromUserID        BIGINT,
  @toUserID          BIGINT,
  @toPracID          BIGINT,
  @toName            varchar(50),
  @parentID          BIGINT,
  @referenceID       BIGINT,
  @oldestDOS         datetime,
  @status            INT,
  @statusFlags       INT,
  @irrType           INT,
  @sentOn            DATETIME,
  @openedOn          DATETIME,
  @respondedOn       DATETIME,
  @expirationDate    DATETIME,
  @editDelReason     VARCHAR(7000),    
  @validateRec       BIT,    
  @saveType          INT,    
  @recID             INT,    
  @MsgNotActive      VARCHAR(1000),
  @MsgNoRec          VARCHAR(1000),    
  @MsgNoEdit         VARCHAR(1000),
  @MsgNoFullEdit     VARCHAR(1000),    
  @MsgDupRec         VARCHAR(1000),
  @MsgDataError      VARCHAR(1000),    
  @recordID          BIGINT        OUTPUT)  
AS    
BEGIN    
   
/***************************************************************************    
 * CLIENT_SAVE */    
/**    
 * Creates a new or edits existing entity record    
 * and manages any associated records.    
 *    
 * @param   userID          The userid of who saved the record    
 * @param   token                
 * @param   emailTittle              
 * @param   emailMsg                 
 * @param   emailTo                  
 * @param   emailCc                  
 * @param   clientID            
 * @param   fromUserID          
 * @param   toUserID            
 * @param   parentID            
 * @param   referenceID         
 * @param   stausFlags          
 * @param   irrType             
 * @param   sentOn              
 * @param   openedOn            
 * @param   responded           
 * @param   expirationDate 
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
   
   
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',                 11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',                  11, 1)    
IF (@token         IS NULL and @saveType = 1) 
                            RAISERROR ('token is required',                      11, 1)    
IF (@emailTittle   IS NULL) RAISERROR ('Email tittle is required',               11, 1)     
IF (@emailMsg      IS NULL) RAISERROR ('EmailMsg is required',                   11, 1)    
IF (@emailTo       IS NULL) RAISERROR ('Email To address is required',           11, 1)    
IF (@referenceID   IS NULL) RAISERROR ('Reference ID is required',               11, 1)    

IF ((@saveType = dbo.CONST_SAVE_TYPE_EDIT()) AND (@recID IS NULL))    
  RAISERROR ('updateRecID is required', 11, 1)                             

/*-------------------------------    
 * Prep worker variables    
 *------------------------------*/    
     
SET @today      = GETDATE()   

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
    @recordID           = ID,
    @expirationDate     = Expiration_Date
  FROM dbo.INFO_REQUEST_RESPONSE where id = @recID
    
  /*-------------------------------    
   * If the record does not exist
   * or it cannot be edited  
   * exit and let the user know   
   *------------------------------*/

  IF (@recordID IS NULL)         RAISERROR (@MsgNoRec,     11, 1)        
  IF (@expirationDate < @today)  RAISERROR (@MsgNotActive, 11, 1) 
  
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
       
    SELECT 
      @dupCount = COUNT(irr.id) 
    FROM dbo.INFO_REQUEST_RESPONSE irr
    WHERE Email_To    = @emailTo and
          Email_CC    = @emailCc and
          ReferenceID = @referenceID 
          
                  
    IF @dupCount > 0    
    BEGIN    
      SET @msgDupRec = dbo.STRING_CREATE(@msgDupRec, CONVERT(VARCHAR(10),@dupCount), NULL, NULL)    
      RAISERROR (@MsgDupRec, 11, 1)
    END    
     
    /*-------------------------------    
     * If we are editing and the
     * record we are editing is not    
     * active warn the user
     *------------------------------*/    

    IF ((@expirationDate < @today) AND (@saveType = dbo.CONST_SAVE_TYPE_EDIT())) 
       RAISERROR (@MsgNotActive, 11, 1)   
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
     * Client
     *------------------------------*/    
  
    INSERT INTO dbo.INFO_REQUEST_RESPONSE
    (  
     Token,
     Email_Tittle,
     Email_Msg,
     Email_To,
     Email_CC,
     ClientID,
     From_UserID,
     To_UserID,
     To_PracID,
     To_Name,
     ParentID,
     ReferenceID,
     OldestDOSOnQform,
     Status,
     Status_Flags,
     IRR_Type,
     CreatedOn,
     SentOn,
     OpenedOn,
     RespondedOn,
     Expiration_Date
    )    
    VALUES    
    (  
      @token,
      @emailTittle,
      @emailMsg,
      @emailTo,
      @emailCc,
      @clientID,
      @fromUserID,
      @toUserID,
      @toPracID,
      @toName,
      @parentID,
      @referenceID,
      @oldestDOS,
      @status,
      @statusFlags,
      @irrType,
      @today,
      @sentOn,
      @openedOn,
      @respondedOn,
      @expirationDate
    )      
    
    SET @recordID = SCOPE_IDENTITY()            
   
  END         
  
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN    
     
    /*-------------------------------    
     * Edit existing entity record but not token value   
     *------------------------------*/    
     
     SET @updateState = dbo.CONST_REC_STATE_MOD()                  
       
     UPDATE dbo.INFO_REQUEST_RESPONSE
     SET
         Email_Tittle     =  @emailTittle,
		 Email_Msg        =  @emailMsg,
		 Email_To         =  @emailTo,
		 Email_CC         =  @emailCc,
		 ClientID         =  @clientID,
		 From_UserID      =  @fromUserID,
		 To_UserID        =  @toUserID,
		 To_PracID        =  @toPracID,
		 To_Name          =  @toName,
		 ParentID         =  @parentID,
		 ReferenceID      =  @referenceID,
		 OldestDOSOnQform = @oldestDOS,
		 Status           =  @status,
		 Status_Flags     =  @statusFlags,
		 IRR_Type         =  @irrType,
		 SentOn           =  @sentOn,
		 OpenedOn         =  @openedOn,
		 RespondedOn      =  @respondedOn,
		 Expiration_Date  =  @expirationDate
     WHERE (ID  = @recID)    
     
     
  END    
  ELSE    
  BEGIN    
    RAISERROR ('Unknown save type', 11, 1)    
  END    
   
  /*-------------------------------    
   * Create audit record    
   *------------------------------*/    
   
   EXEC dbo.INFO_REQUEST_RESPONSE_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT    
      
       
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

GRANT EXECUTE ON  [dbo].[INFO_REQUEST_RESPONSE_Save] TO [webuser]
GO
 
