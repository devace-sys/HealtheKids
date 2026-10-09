USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('STUDENT_DATA_TRACKING_RECORD_Save') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.STUDENT_DATA_TRACKING_RECORD_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[STUDENT_DATA_TRACKING_RECORD_Save]    
 (@userID           bigint,
  @clientID         bigint,
  @fileTypeID       bigint,
  @quarter          int,
  @dateRequested    datetime,
  @dateFollowedUp   datetime,
  @dateNotified     datetime,
  @datereceived     datetime,
  @whoPrepTxtFile   varchar(2),
  @dateinFolders    datetime,
  @dateSentDHS      datetime,
  @datereceivedDHS  datetime,
  @dateMovClFolders datetime,
  @dhsFilename      varchar(500),
  @whoMovTxtMedFile varchar(2),
  @popFileID        bigint,
  @notes            varchar(max),
  @editDelReason    varchar(7000),    
  @validateRec      bit,    
  @saveType         int,    
  @recID            bigint,    
  @MsgNotActive     varchar(1000),
  @MsgNoRec         varchar(1000),    
  @MsgNoEdit        varchar(1000),
  @MsgDupRec        varchar(1000),    
  @MsgDataError     varchar(1000),    
  @recordID         bigint output)  
AS    
BEGIN    
   
/***************************************************************************    
 * STUDENT_DATA_TRACKING_RECORD_Save */    
/**    
 * Creates a new or edits existing entity record    
 * and manages any associated records.    
 *    
 * @param   userID              The userid of who performed the operation 
 * @param   clientID            Client ID
 * @param   fileTypeID          File type ID
 * @param   quarter              
 * @param   dateRequested   
 * @param   dateFollowedUp   
 * @param   dateNotified     
 * @param   datereceived     
 * @param   whoPrepTxtFile  
 * @param   dateinFolders   
 * @param   dateSentDHS      
 * @param   datereceivedDHS  
 * @param   dateMovClFolders 
 * @param   dhsFilename      
 * @param   whoMovTxtMedFile 
 * @param   popFileID       
 * @param   editDelReason       Reason for record edit or delete    
 * @param   validateRec         1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                              0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   saveType            Type of operation to perform    
 *                              1 = New, 2 = Edit, 3 = Delete    
 * @param   recID               Record id of existing client record to edit or    
 *                              delete.    
 * @param   MsgNoRec            Desired error message if a recID is not found    
 * @param   MsgNoEdit           Desired error message if a record cannot be edited    
 * @param   MsgNoFullEdit       Desired error message if a record can only be partially edited
 * @param   MsgDupRec           Desired error message for duplicate detection    
 * @param   MsgNoClient         Desired error message if a clientID is not found 
 * @param   MsgNoGroup          Desired error message if a groupID is not found    
 * @param   MsgDataError        Desired error message for data errors    
 * @returns spDetails           Validation or error details    
 * @returns recordID            New record id or record id of service record that    
 *                              was changed or deleted    
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
DECLARE @fiscalYear         as int            -- fiscal year


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
IF (@clientID     IS NULL) RAISERROR ('Client ID is required',    11, 1)
IF (@fileTypeID   IS NULL) RAISERROR ('File type ID is required', 11, 1)  
IF (@quarter      IS NULL) RAISERROR ('Quarter is required',      11, 1)  

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
 select @fiscalYear = ID from dbo.COMPANY_FISCAL_YEARS
    where @today between FY_START and FY_END     

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
  FROM dbo.STUDENT_DATA_TRACKING where id = @recID
    
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
     * Duplicate checking is disabled because a client can have more than one tracking record           
     *------------------------------*/    
       
    --SELECT 
    --  @dupCount = COUNT(ib.id) 
    --FROM     
    --  dbo.STUDENT_DATA_TRACKING AS ib
    --WHERE 
    --  CLIENT_ID    = @clientID   AND
    --  FILE_TYPE_ID = @fileTypeID and
    --  QUARTER      = @quarter    and
    --  FISCAL_YEAR  = @fiscalYear and
    --  ((@recID is null) or (ID != @recID)) and 
    --  ACTIVE       = 1
      
    --IF @dupCount > 0 RAISERROR ('Student data tracking record already exists!', 11, 1)             
                
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
        INSERT INTO dbo.STUDENT_DATA_TRACKING
		(  
		CLIENT_ID,
		FILE_TYPE_ID,
		QUARTER,
		FISCAL_YEAR,
		DATE_REQUESTED,
		DATE_FOLLOWED_UP,
		DATE_NOTIFIED_REP,
		DATE_RECEIVED,
		WHO_PREPARED_TXTfile,
		DATE_PUT_IN_FOLDERS,
		Nel2DHS_FILENAME,
		DATE_SENT_TO_DHS,
		DATE_RECEIVED_DHS,
		DATE_MOVED_CL_FOLDERS,
		WHO_MOVED_TXTnMED_FILES,
		POPULATION_FILE_ID,
		NOTES,
		ACTIVE
		)    
		VALUES    
		(  
		 @clientID,
		 @fileTypeID,
		 @quarter,
		 @fiscalYear,
		 @dateRequested,
		 @dateFollowedUp,
		 @dateNotified,
		 @datereceived,
		 @whoPrepTxtFile,
		 @dateinFolders,
		 @dhsFilename,
		 @dateSentDHS,
		 @datereceivedDHS,
		 @dateMovClFolders,
		 @whoMovTxtMedFile,
		 @popFileID,
		 @notes,
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
            
      UPDATE dbo.STUDENT_DATA_TRACKING
       SET  [CLIENT_ID] 		        = @clientID,
			[FILE_TYPE_ID] 		        = @fileTypeID,
			[QUARTER] 		            = @quarter,
			[DATE_REQUESTED] 		    = @dateRequested,
			[DATE_FOLLOWED_UP] 		    = @dateFollowedUp,
			[DATE_NOTIFIED_REP] 		= @dateNotified,
			[DATE_RECEIVED] 		    = @datereceived,
			[WHO_PREPARED_TXTfile] 	    = @whoPrepTxtFile,
			[DATE_PUT_IN_FOLDERS] 	    = @dateinFolders,
			[Nel2DHS_FILENAME] 		    = @dhsFilename,
			[DATE_SENT_TO_DHS] 		    = @dateSentDHS,
			[DATE_RECEIVED_DHS] 		= @datereceivedDHS,
			[DATE_MOVED_CL_FOLDERS] 	= @dateMovClFolders,
			[WHO_MOVED_TXTnMED_FILES]   = @whoMovTxtMedFile,
			[POPULATION_FILE_ID]		= @popFileID,
			[NOTES]                     = @notes

     WHERE (id  = @recID)             
        
  END    
  ELSE    
    RAISERROR ('Unknown save type', 11, 1)    
   
  /*-------------------------------    
   * Create audit record    
   *------------------------------*/    
   
 EXEC dbo.STUDENT_DATA_TRACKING_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT     
       
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

GRANT EXECUTE ON  [dbo].[STUDENT_DATA_TRACKING_RECORD_Save] TO [webuser]
GO
 
