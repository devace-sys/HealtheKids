USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_PROCEDURES_Save') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIM_PROCEDURES_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[CLAIM_PROCEDURES_Save]    
 (@userID           BIGINT,    
  @userGroup        INT,    
  @userRank         INT,  
  @noPlanName       INT,
  @IEP_IFSP_NAME    INT,
  @procCode         nchar(10),
  @procMod1         nchar(10), 
  @procMod2         nchar(10),
  @procMod3         nchar(10),
  @procName         nvarchar(50),
  @dateEffective    datetime,
  @dateExpires      datetime,
  @IEPRequired      nchar(10),
  @serviceFee       numeric(18,2),
  @maxUnits         nchar(10),
  @maxServiceUnits  nchar(10),
  @tcmLowRate       nchar(10),
  @tcmMedRate       nchar(10),
  @tcmHighRate      nchar(10),
  @over17Fee        nchar(10),
  @under18Fee       nchar(10),
  @page             nchar(10),
  @diagnosisCode    nchar(10),
  @yearlyFlag       nchar(10),
  @putIn837         bit,
  @combineINTOProxy bit,
  @linkToService    bit, 
  @editDelReason    VARCHAR(7000),    
  @validateRec      BIT,    
  @saveType         INT,    
  @recID            INT,    
  @MsgNotActive     VARCHAR(1000),
  @MsgNoRec         VARCHAR(1000),    
  @MsgNoEdit        VARCHAR(1000),
  @MsgNoFullEdit    VARCHAR(1000),    
  @MsgDupRec        VARCHAR(1000),    
  @MsgNoClient      VARCHAR(1000),
  @MsgNoGroup       VARCHAR(1000),   
  @MsgDataError     VARCHAR(1000),    
  @spDetails        VARCHAR(8000) OUTPUT,    
  @recordID         BIGINT        OUTPUT)  
AS    
BEGIN    
   
/***************************************************************************    
 * CLAIM_PROCEDURES_Save */    
/**    
 * Creates a new or edits existing entity record    
 * and manages any associated records.    
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   noPlanName       
 * @param   IEP_IFSP_NAME 
 * @param   procCode    
 * @param   procMod1         
 * @param   procMod2        
 * @param   procMod3         
 * @param   procName         
 * @param   dateEffective    
 * @param   dateExpires      
 * @param   IEPRequired      
 * @param   serviceFee       
 * @param   maxUnits         
 * @param   maxServiceUnits  
 * @param   tcmLowRate      
 * @param   tcmMedRate       
 * @param   tcmHighRate      
 * @param   over17Fee        
 * @param   under18Fee       
 * @param   page             
 * @param   diagnosisCode    
 * @param   yearlyFlag       
 * @param   putIn837        
 * @param   combineINTOProxy 
 * @param   linkToService
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
   
IF (@userGroup          IS NULL) RAISERROR ('userGroup is required',         11, 1)    
IF (@userRank           IS NULL) RAISERROR ('userRank is required',          11, 1)    
IF (@validateRec        IS NULL) RAISERROR ('Validate flag required',        11, 1)    
IF (@saveType           IS NULL) RAISERROR ('Save type is required',         11, 1)    
IF (@procCode           IS NULL) RAISERROR ('Procedure code  is required',   11, 1) 
IF (@dateEffective      IS NULL) RAISERROR ('Date Effective is required',    11, 1)  
IF (@putIn837           IS NULL) RAISERROR ('put in 837',                    11, 1)      
IF (@combineINTOProxy   IS NULL) RAISERROR ('Combine into Proxy is required',11, 1)    
IF (@linkToService      IS NULL) RAISERROR ('Link To Service is required',   11, 1)   
 

IF ((@saveType = dbo.CONST_SAVE_TYPE_EDIT()) AND (@recID IS NULL))    
  RAISERROR ('updateRecID is required', 11, 1)
  
IF (@dateEffective > @dateExpires)    
  RAISERROR ('Date Effective is greater than Date Expires', 11, 1)                             

/*-------------------------------    
 * Prep worker variables    
 *------------------------------*/    
     
SET @isActive   = 1  
set @procMod1  = UPPER(@procMod1)
set @procMod2  = UPPER(@procMod2)
set @procMod3  = UPPER(@procMod3)

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
    @recordID  = ID,
    @isActive  = active
  FROM dbo.CLAIM_PROCEDURES_VIEW(@userID,@userGroup,@userRank,null,null,null,null,@recID,null,null) 
    
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
      @dupCount = COUNT(CP.ID) 
    FROM dbo.CLAIM_PROCEDURES_VIEW(@userID,@userGroup,@userRank,@procCode,@procMod1,@procMod2,@procMod3,null,null,null)
      AS CP
    WHERE      
      ((@recID IS NULL)    or (CP.ID != @recID))           
   
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

    IF ((@isActive = 0) AND (@saveType = dbo.CONST_SAVE_TYPE_EDIT())) 
      SET @spDetails = dbo.UPDATE_DETAILS(@spDetails,@MsgNotActive, dbo.CONST_RET_WARN())        
   
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
  
    INSERT INTO dbo.CLAIM_PROCEDURES
    (  
       [NO_PLAN_NAME]
      ,[IEP_IFSP_NAME]
      ,[PROCEDURE_CODE]
      ,[PROCEDURE_MODIFIER_1]
      ,[PROCEDURE_MODIFIER_2]
      ,[PROCEDURE_MODIFIER_3]
      ,[PROCEDURE_NAME]
      ,[DATE_ADDED]
      ,[DATE_EFFECTIVE]
      ,[DATE_EXPIRES]
      ,[IEP_REQUIRED]
      ,[SERVICE_FEE]
      ,[MAX_UNITS]
      ,[MAX_SERVICE_UNITS]
      ,[TCM_LOW_RATE]
      ,[TCM_MEDIUM_RATE]
      ,[TCM_HIGH_RATE]
      ,[OVER_17_FEE]
      ,[UNDER_18_FEE]
      ,[PAGE]
      ,[DIAGNOSIS_CODE]
      ,[YEARLY_FLAG]
      ,[PUT_IN_837]
      ,[COMBINE_INTO_PROXY]
      ,[LINK_TO_SERVICE] 
      ,[ACTIVE]
    )    
    VALUES    
    (  
       @noPlanName       
	  ,@IEP_IFSP_NAME 
	  ,@procCode    
	  ,@procMod1         
	  ,@procMod2        
	  ,@procMod3         
	  ,@procName     
      ,@today        
	  ,@dateEffective
	  ,@dateExpires      
	  ,@IEPRequired      
	  ,@serviceFee       
	  ,@maxUnits         
	  ,@maxServiceUnits  
	  ,@tcmLowRate      
	  ,@tcmMedRate       
	  ,@tcmHighRate      
	  ,@over17Fee        
	  ,@Under18Fee       
	  ,@page             
	  ,@diagnosisCode    
	  ,@yearlyFlag       
	  ,@PutIn837        
	  ,@combineINTOProxy 
	  ,@linkToService
      ,1  
    )      
    
    SET @recordID = SCOPE_IDENTITY()    
    
  END         
  
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN    
     
    /*-------------------------------    
     * Edit existing entity record    
     *------------------------------*/    
     
     SET @updateState = dbo.CONST_REC_STATE_MOD()                  
       
     UPDATE dbo.CLAIM_PROCEDURES
     SET  
       [NO_PLAN_NAME]         = @noPlanName
      ,[IEP_IFSP_NAME]        = @IEP_IFSP_NAME
      ,[PROCEDURE_CODE]       = @procCode
      ,[PROCEDURE_MODIFIER_1] = @procMod1
      ,[PROCEDURE_MODIFIER_2] = @procMod2
      ,[PROCEDURE_MODIFIER_3] = @procMod3
      ,[PROCEDURE_NAME]       = @procName
      ,[DATE_MODIFIED]        = @today
      ,[DATE_EFFECTIVE]       = @dateEffective
      ,[DATE_EXPIRES]         = @dateExpires 
      ,[IEP_REQUIRED]         = @IEPRequired 
      ,[SERVICE_FEE]          = @serviceFee
      ,[MAX_UNITS]            = @maxUnits 
      ,[MAX_SERVICE_UNITS]    = @maxServiceUnits
      ,[TCM_LOW_RATE]         = @tcmLowRate 
      ,[TCM_MEDIUM_RATE]      = @tcmMedRate
      ,[TCM_HIGH_RATE]        = @tcmHighRate
      ,[OVER_17_FEE]          = @over17Fee
      ,[UNDER_18_FEE]         = @under18Fee
      ,[PAGE]                 = @page
      ,[DIAGNOSIS_CODE]       = @diagnosisCode 
      ,[YEARLY_FLAG]          = @yearlyFlag
      ,[PUT_IN_837]           = @putIn837 
      ,[COMBINE_INTO_PROXY]   = @combineINTOProxy 
      ,[LINK_TO_SERVICE]      = @linkToService
     WHERE (PROCEDURE_ID      = @recID)    
    
  END    
  ELSE    
  BEGIN    
    RAISERROR ('Unknown save type', 11, 1)    
  END    
   
  /*-------------------------------    
   * Create audit record    
   *------------------------------*/    
   
   EXEC dbo.CLAIM_PROCEDURES_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT    
      
       
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

GRANT EXECUTE ON  [dbo].[CLAIM_PROCEDURES_Save] TO [webuser]
GO
 
