USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.REPORT_PUBLICATION_SUBSCRIPTION_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.REPORT_PUBLICATION_SUBSCRIPTION_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[REPORT_PUBLICATION_SUBSCRIPTION_Save]     
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @clientID      INT,
  @publicationID INT,
  @subscriberID  INT,
  @autoDistribute BIT,
  @reqFileType    SMALLINT,
  @distributionNotes       VARCHAR(8000),   
  @editDelReason           VARCHAR(7000),    
  @validateRec             BIT,    
  @saveType                INT,    
  @recID                   INT,    
  @MsgNoRec                VARCHAR(1000),    
  @MsgNoEdit               VARCHAR(1000), 
  @MsgDupRec               VARCHAR(1000),     
  @MsgNoClient             VARCHAR(1000),
  @MsgDataError            VARCHAR(1000),
  @MsgNotActive            VARCHAR(1000),     
  @spDetails               VARCHAR(8000) OUTPUT,    
  @recordID                BIGINT        OUTPUT)    
AS    

BEGIN     
    
/***************************************************************************    
 * REPORT_PUBLICATION_SUBSCRIPTION_Save */    
/**    
 * Creates a new or edits existing report publication subscription record 
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Patient's client id    
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
 * @param   recID           Record id of existing patient record to edit or    
 *                          delete.    
 * @param   MsgNoRec        Desired error message if a recID is not found    
 * @param   MsgNoEdit       Desired error message if a record cannot be edited    
 * @param   MsgDupRec       Desired error message for duplicate detection    
 * @param   MsgNoClient     Desired error message if a clientID is not found    
 * @param   MsgNoSite       Desired error message if a siteID is not found     
 * @param   MsgDataError    Desired error message for data errors    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted     
 ***************************************************************************/         

LINENO 74
     
SET NOCOUNT ON    
    
DECLARE @today        AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen     AS BIT            -- Is a transaction open    
DECLARE @dupCount     AS INT            -- Duplicate counter used for validation    
DECLARE @updateState  AS SMALLINT       -- Indicates what state the record is left in    
DECLARE @canEdit      AS BIT   
DECLARE @tempRecID    AS INT            -- Used for determining if a rec exists    
DECLARE @auditRecID   AS BIGINT     

BEGIN TRY    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @recordID   = 0    
SET @spDetails  = ''    
    
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
    
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@publicationID IS NULL) RAISERROR ('Publication ID is required', 11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1)    
    
IF ((@saveType = dbo.CONST_SAVE_TYPE_EDIT()) AND (@recID IS NULL))     
  RAISERROR ('updateRecID is required', 11, 1)    
                                  
/*-------------------------------    
 * Prep worker variables    
 *------------------------------*/    
     
SET @today = GETDATE()    
    
/*-------------------------------    
 * If this is an edit
 *------------------------------*/       
  
IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())     
BEGIN  
  
  /*-------------------------------    
   * Check to see if the record
   * exists and if it can be edited 
   *------------------------------*/       
  
  SET @recordID = null    
  SET @canEdit  = 0   
  
  SELECT 
    @recordID = ID, 
    @canEdit  = Active 
  from REPORT_PUBLICATION_SUBSCRIPTIONS        
  where ID = @recID
     
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
   * Verify client id exists    
   *-------------------------------*/    
    
  SET    @tempRecID = NULL    
  SELECT @tempRecID = CLIENT_ID FROM CLIENTS_CLIENT WHERE CLIENT_ID = @ClientID    
    
  IF (@tempRecID <> @clientID) RAISERROR (@MsgNoClient, 11, 1)            

  /*-------------------------------    
   * Verify publication id exists
   *-------------------------------*/    

  SET    @tempRecID = NULL    
  SELECT @tempRecID = ID FROM dbo.REPORT_PUBLICATIONS WHERE ID = @publicationID
    
  IF (@tempRecID <> @publicationID) RAISERROR ('Publication does not exist', 11, 1)    
        
    
  /*-------------------------------    
   * Look for duplicate records 
   * excluding the record specified
   * by recid    
   *------------------------------*/    

  SET @dupCount = 0   
    
  select 
    @dupCount = COUNT(id) 
  from 
    dbo.REPORT_PUBLICATION_SUBSCRIPTIONS 
  where
    (((@recID IS NULL) OR (id != @recID)) 
    and (Active = 1) 
    and (SubscriberID = @subscriberID) 
    and (PublicationID = @publicationID))
   
   /*-------------------------------    
    * If a duplicate record was 
    * found, get out!
    *------------------------------*/    
    
   if (@dupCount > 0) set @spDetails = dbo.UPDATE_DETAILS(@spDetails,@MsgDupRec,dbo.CONST_RET_WARN()) --RAISERROR (@MsgDupRec, 11, 1) 

  
  declare @possibleFileTypes as varchar(512)
  declare @suppportedFileTypes as varchar(512)

   /*-------------------------------    
    * Check file type requested
    *------------------------------*/    

  select top 1 
      @possibleFileTypes   = rpds.PossibleFileTypes
    , @suppportedFileTypes = rpds.SupportedFileTypes
  from dbo.REPORT_PUBLICATIONS             as rp
  join dbo.REPORT_PUBLICATION_DATA_SOURCES as rpds on rpds.DataSource = rp.DataSourceID
  where (rp.ID = @publicationID)

  /*-------------------------------    
   * If the file type is not
   * possible to generate, get out
   *------------------------------*/    

  if not exists (select top 1 t1.recid from dbo.MULTI_RECORD_ID_PARSE(@possibleFileTypes,',') as t1 where t1.recid = @reqFileType)
  begin
    RAISERROR ('The file type you requested is not available for this report', 11, 1)    
  end
    
  /*-------------------------------    
   * Advisement validation    
   *------------------------------*/    
    
  IF (@validateRec = 1)    
  BEGIN    
         
   if not exists (select top 1 t1.recid from dbo.MULTI_RECORD_ID_PARSE(@suppportedFileTypes,',') as t1 where t1.recid = @reqFileType)
   begin
     set @spDetails = dbo.UPDATE_DETAILS(@spDetails,'The file type you requested may not produce usable output because of the number of columns in this report.',dbo.CONST_RET_WARN())     
   end
     	
	/*-------------------------------    
     * If we are providing advisement    
     * validation exit now    
     *------------------------------*/    
              
    IF (@validateRec = 1) RETURN(0)    
       
  END  

END  
      
/*-------------------------------    
 * Create or modify our     
 * subscription record
 *------------------------------*/    
    
BEGIN TRANSACTION    
    
  SET @TranOpen = 1    
    
  /*-------------------------------    
   * New subscription record 
   *------------------------------*/    
    
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN    
    
    SET @updateState = dbo.CONST_REC_STATE_NEW()    
        
    INSERT INTO REPORT_PUBLICATION_SUBSCRIPTIONS 
      (ClientID,
       PublicationID,
       SubscriberID,
       Filetype_requested,
       AutoDistribute,
       DistributionNotes,
       Created,
       CreatedBy,
       Active)    
       
    VALUES     
    
      (@clientID,     
       @publicationID,     
       @subscriberID,
       @reqFileType,   
       @autoDistribute,    
       @distributionNotes, 
       @today,
       @userID,
       1)      
    
    SET @recordID = SCOPE_IDENTITY()       
            
  END  
  
  /*-------------------------------    
   * Edit existing subscription
   * record    
   *------------------------------*/     
  
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN               
      
     SET @updateState = dbo.CONST_REC_STATE_MOD()     
                      
     UPDATE REPORT_PUBLICATION_SUBSCRIPTIONS 
     
     SET
     
       ClientID           = @clientID,
       PublicationID      = @publicationID,
       SubscriberID       = @subscriberID,
       Filetype_requested = @reqFileType,
       AutoDistribute     = @autoDistribute,
       DistributionNotes  = @distributionNotes,
       LastUpdated        = @today,
       LastUpdatedBy      = @userID 
     
     WHERE 
     
       ID = @recordID
                
  END    
  ELSE     
  BEGIN    
    RAISERROR ('Unknown save type', 11, 1)    
  END    
    
  /*-------------------------------    
   * Create audit record    
   *------------------------------*/    
  
  EXEC REPORT_PUBLICATION_SUBSCRIPTIONS_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT        
       
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
 
GRANT EXECUTE ON  [dbo].[REPORT_PUBLICATION_SUBSCRIPTION_Save] TO [webuser]
GO
