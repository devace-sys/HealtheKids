USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.REPORT_PUBLICATION_DISTRIBUTION_HISTORY_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.REPORT_PUBLICATION_DISTRIBUTION_HISTORY_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[REPORT_PUBLICATION_DISTRIBUTION_HISTORY_Save]     
 (@userID           BIGINT,    
  @userGroup        INT,    
  @userRank         INT,    
  @clientID         INT,
  @publicationID    INT,
  @runDate             DATETIME,
  @procRunDate         DATETIME,
  @referenceDate       DATETIME,
  @OKToPublishUpToDate DATETIME,
  @actualDateRange1 VARCHAR(1000),
  @status           INT,
  @resultFlags      INT,
  @retryDate        DATETIME,
  @editDelReason           VARCHAR(7000),    
  @validateRec             BIT,    
  @saveType                INT,    
  @recID                   INT,    
  @MsgNoRec                VARCHAR(1000),    
  @MsgNoEdit               VARCHAR(1000), 
  @MsgDupRec               VARCHAR(1000),     
  @MsgDataError            VARCHAR(1000),
  @MsgNotActive            VARCHAR(1000),     
  @spDetails               VARCHAR(8000) OUTPUT,    
  @recordID                BIGINT        OUTPUT)    
AS    

BEGIN     
    
/***************************************************************************    
 * REPORT_PUBLICATION_DISTRIBUTION_HISTORY_Save */    
/**    
 * Creates a new history record
 *
 * Note: There is no edit or validate.  This is meant to be called by
 *       automation.
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Publication client id
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
     
SET NOCOUNT ON    
    
DECLARE @today          AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen       AS BIT            -- Is a transaction open    
DECLARE @updateState    AS SMALLINT       -- Indicates what state the record is left in    
DECLARE @prevID         AS BIGINT
DECLARE @isNew          AS BIT
DECLARE @isRetry        AS BIT
DECLARE @scheduleRetry  AS BIT
   
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
    
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',      11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',       11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',     11, 1)    
IF (@publicationID IS NULL) RAISERROR ('Publication ID is required', 11, 1) 
IF (@clientID      IS NULL) RAISERROR ('Client ID is required',      11, 1)    
IF (@referenceDate IS NULL) RAISERROR ('Reference date is required', 11, 1)    
IF (@status        IS NULL) RAISERROR ('Status is required',         11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',      11, 1)    
    
/*-------------------------------    
 * Setup worker vars
 *------------------------------*/    

SET @today  = GETDATE()
SET @prevID = null

/*-------------------------------    
 * Decode flags
 *
 * Note: Keep in synch with
 * MBA.DistributionResultFlag
 *------------------------------*/    

SET @isNew         = dbo.DECODE_FLAG (@resultFlags, 1)
SET @isRetry       = dbo.DECODE_FLAG (@resultFlags, 2)
SET @scheduleRetry = dbo.DECODE_FLAG (@resultFlags, 2048)

/*-------------------------------    
 * Get previous id if any
 *------------------------------*/    

if ((@scheduleRetry = 1) OR (@isRetry = 1))
BEGIN

  select
    
    /*-------------------------------    
     * Find the LATEST previous
     * record that...
     *------------------------------*/    
    
    @prevID = MAX(ID) 
  from REPORT_PUBLICATION_DISTRIBUTION_HISTORY
  
  where
  
    /*-------------------------------    
     * Has the same
     
     * - reference date
     * - client id
     * - publication id
     *------------------------------*/   
   
    ReferenceDate     = @referenceDate
    and ClientID      = @clientID
    and PublicationID = @publicationID
  
  group by 
    ReferenceDate, 
    ClientID, 
    PublicationID

END

/*-------------------------------    
 * Set retry date to null
 * if not needed
 *------------------------------*/    

IF (@scheduleRetry = 0) 
  SET @retryDate = null

/*-------------------------------    
 * Create history record
 *------------------------------*/    
    
BEGIN TRANSACTION    
    
  SET @TranOpen = 1        
          
  /*-------------------------------    
   * New history record
   *------------------------------*/    
    
  INSERT INTO REPORT_PUBLICATION_DISTRIBUTION_HISTORY
  
    (RecordDate,
     RunDate,
     ProcRunDate,
     ReferenceDate,
     ClientID,
     PublicationID,
     [Status],
     ResultFlags,
     RetryDate,
     PrevID,
     ActualDateRange1,
     OKToPublishUpToDate
     )    
       
  VALUES         
  
    (@today,
     @runDate,
     @procRunDate,
     @referenceDate,     
     @clientID,     
     @publicationID,     
     @status,
     @resultFlags,
     @RetryDate,
     @prevID,
     @actualDateRange1,
     @OKToPublishUpToDate)      
    
  SET @recordID = SCOPE_IDENTITY()       

  /*-------------------------------    
   * Set next id
   *------------------------------*/
 
  IF (@prevID is not null) 
    UPDATE REPORT_PUBLICATION_DISTRIBUTION_HISTORY SET NextID = @recordID WHERE ID = @prevID

            
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
 
GRANT EXECUTE ON  [dbo].[REPORT_PUBLICATION_DISTRIBUTION_HISTORY_Save] TO [webuser]
GO
