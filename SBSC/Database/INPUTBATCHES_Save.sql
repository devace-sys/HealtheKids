USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INPUTBATCHES_Save') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.INPUTBATCHES_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[INPUTBATCHES_Save]    
 (@filename        nvarchar(MAX),
  @fileLocation    nvarchar(MAX),
  @clientID        bigint,
  @dateSent        datetime,
  @dateRecieved    datetime,
  @partial         bit,
  @parentID        bigint,
  @typeofWork      smallint,
  @oldest_dos      datetime,
  @estmtedInpthrs  decimal(18,2),
  @userID1         bigint,
  @userID2         bigint,
  @priorityNum     smallint,
  @degreeofdifcult smallint,
  @statuscode      int,
  @note            nvarchar(MAX),
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
 * INPUTBATCHES_SAVE */    
/**    
 * Creates a new or edits existing entity record    
 * and manages any associated records.    
 *    
 * @param   filename        Name of input batch file sent by A&I 
 * @param   fileLocation    Location of the file.
 * @param   userID1         userID of the work leader who prescreened the file
 * @param   userID2         userID of the Assigned staff
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
DECLARE @fromStatus         AS SMALLINT       -- previous status of the input batch

DECLARE @precreened         AS bigint
DECLARE @isDate             AS INT

declare @fileName500Buffer as varchar(500) -- buffer for varchar max args still referenced in deprecated software

set @fileName500Buffer = @filename

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
   

IF (@validateRec  IS NULL) RAISERROR ('Validate flag required',   11, 1)    
IF (@saveType     IS NULL) RAISERROR ('Save type    is required', 11, 1)    
IF (@fileName500Buffer     IS NULL) RAISERROR ('Filename     is required', 11, 1)
IF (@fileLocation IS NULL) RAISERROR ('FileLocation is required', 11, 1)  
IF (@clientID     IS NULL) RAISERROR ('ClientID     is required', 11, 1)
IF (@dateSent     IS NULL) RAISERROR ('DateSent     is required', 11, 1)
IF (@typeofWork   IS NULL) RAISERROR ('TypeofWork   is required', 11, 1)  

IF ((@saveType = dbo.CONST_SAVE_TYPE_EDIT()) AND (@recID IS NULL))    
  RAISERROR ('updateRecID is required', 11, 1)
  
IF	(
		(@statuscode = 10) 
		AND (
				@userID2 IS not NULL 
				AND 
				/* Qform batches returning after being answered will be in status 10, but have user assigned to them */
				NOT EXISTS (select 1 from USERS.dbo.INFO_REQUEST_RESPONSE irr where irr.ReferenceID = @recID and irr.Status = 40)
			)
	)    
  RAISERROR ('File should be done prescreening before assigning! ', 11, 1)     
       
IF ((@statuscode = 60) AND (@userID2 IS NULL))    
  RAISERROR ('Work is not Assigned! ', 11, 1)                               

/*-------------------------------    
 * Prep worker variables    
 *------------------------------*/    
     
SET @today      = GETDATE() 
if (@dateRecieved is null) set @dateRecieved = @today
   
SET @isActive   = 1  
if (@partial is null) set @partial = 0
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
    @isActive           = case Current_status_Code when 200 then 0
                                                   when 300 then 0
                          else 1 end
  FROM dbo.INPUT_BATCHES where id = @recID
    
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
     * We can rely on always having    
     * the  clientname and CDS        
     *------------------------------*/    
       
    SELECT 
      @dupCount = COUNT(ib.id) 
    FROM     
      INPUT_BATCHES AS ib
    WHERE 
      FILE_NAME = @fileName500Buffer 
   
    IF @dupCount > 0    
    BEGIN    
      SET @msgDupRec = dbo.STRING_CREATE(@msgDupRec, CONVERT(VARCHAR(10),@dupCount), NULL, NULL)    
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
 * Create or modify our record    
 *------------------------------*/    
   
BEGIN TRANSACTION    
   
  SET @TranOpen = 1                
           
   
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN    
    if(@statuscode is null) select @statuscode = 10    
    SET @updateState = dbo.CONST_REC_STATE_NEW()             
    /*-------------------------------    
     * Input_Batches
     *------------------------------*/    
  
    INSERT INTO dbo.INPUT_BATCHES
    (  
      ClientID,
      Type_Of_Work,
      File_Name,
      File_Location,
      Partial_File,
      ParentBatchID,
      Date_Recieved,
      Date_Sent,
      Oldest_DOS,
      Current_status_Code,
      Current_Status_Date,
      Current_status_UserID1,
      Current_status_UserID2,
      Priority_number,
      Degree_Of_Difficulty,
      active,
      Notes
    )    
    VALUES    
    (  
     @clientID,
     @typeofWork,
     @fileName500Buffer,
     @fileLocation,
     @partial,
     @parentID,
     @dateRecieved,
     @dateSent,
     @oldest_dos,
     @statuscode,
     @today,
     @userID1,
     @userID2,
     @priorityNum,
     @degreeofdifcult,
     1,
     @note
    )      
    
    SET @recordID = SCOPE_IDENTITY()   
      
  END         
  
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN    
     
    /*-------------------------------    
     * Edit existing entity record    
     *------------------------------*/    
     
     SET @updateState = dbo.CONST_REC_STATE_MOD()   
     
    /*---------------------------------------------   
     * Update Current_status_UserID1 only if the 
     * StatusCode is related to Prescreen 
     *------------------------------------------*/
     select @precreened = Current_status_UserID1,@fromStatus = Current_status_Code from dbo.INPUT_BATCHES where id = @recID   
       
     if (@statuscode = 50) set @precreened = @userID1                  
            
     UPDATE dbo.INPUT_BATCHES
     SET File_Location          = @fileLocation,
         Partial_File           = @partial,  
         File_Name              = @fileName500Buffer,
         ClientID               = @clientID,
         Type_Of_Work           = @typeofWork,
         Oldest_DOS             = @oldest_dos,
         Estimated_Input_Hours  = @estmtedInpthrs,
         Date_Sent              = @dateSent,
         Current_status_Code    = @statuscode,
         Current_Status_Date    = @today,
         Current_status_UserID1 = @precreened,
         Current_status_UserID2 = @userID2,
         Priority_number        = @priorityNum,    
         Degree_Of_Difficulty   = @degreeofdifcult,
         Notes                  = @note,
         ParentBatchID          = @parentID
     WHERE (id  = @recID)       
        
  END    
  ELSE    
    RAISERROR ('Unknown save type', 11, 1)    
   
  /*-------------------------------    
   * Create audit record    
   *------------------------------*/    
   
  EXEC INPUT_BATCHES_Audit @recordID, @today, @fromStatus, @statuscode, @userID1, @userID2, @editDelReason, @auditRecID OUTPUT        
       
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

GRANT EXECUTE ON  [dbo].[INPUTBATCHES_Save] TO [webuser]
GO
 
