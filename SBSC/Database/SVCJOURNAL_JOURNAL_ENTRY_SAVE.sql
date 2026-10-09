USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_ENTRY_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SVCJOURNAL_JOURNAL_ENTRY_SAVE
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SVCJOURNAL_JOURNAL_ENTRY_SAVE]     
 (@userID            BIGINT,    
  @userGroup         INT,    
  @userRank          INT,
  @requestIP         varchar(1000),
  @requestUserAgent  varchar(1000),
  @clientID          bigint,
  @pracID            bigint,
  @patID             bigint,    
  @iep               bit,
  @journalID         bigint,
  @eventType         bigint, 
  @startTime         time(0),
  @endTime           time(0),
  @orpDocID          BIGINT,
  @notes             VARCHAR(8000),
  @noteCriteriaQuestionsJSON        varchar(max),
  @noteCriteriaAnswersJSON          varchar(max),
  @svcNotesFormBuilderQuestionsJSON varchar(max),
  @svcNotesFormBuilderAnswersJSON   varchar(max),
  @editDelReason     VARCHAR(7000),    
  @validateRec       BIT,    
  @saveType          INT,    
  @recID             BIGINT,    
  @MsgNoRec          VARCHAR(1000),    
  @MsgNoEdit         VARCHAR(1000), 
  @MsgDupRec         VARCHAR(1000),   
  @MsgDataError      VARCHAR(1000),
  @MsgNotActive      VARCHAR(1000),     
  @spDetails         VARCHAR(8000) OUTPUT,    
  @recordID          BIGINT        OUTPUT
  )    
AS    
BEGIN     
    
/***************************************************************************    
 * SVCJOURNAL_JOURNAL_ENTRY_SAVE */    
/**    
 * Creates or edits new service journal entry 
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
 * @param   pracID          Practitioner id
 * @param   patID           Patient id
 * @param   dos             Service date
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

DECLARE @tranOpen AS BIT = 0 -- Is a transaction open    

/*============================================================
 * Init output parameters
 *============================================================*/  
    
SET @recordID   = 0    
SET @spDetails  = ''   
set @tranOpen   = 0

/*###########################################################################
  # Save
  ###########################################################################*/

BEGIN TRY
  begin transaction
  set @tranOpen = 1
  
  exec dbo.SVCJOURNAL_JOURNAL_ENTRY_SAVE_CORE 
      @userID      
    , @userGroup   
    , @userRank   
    , @requestIP 
    , @requestUserAgent 
    , @clientID  
    , @pracID  
    , @patID 
    , @iep 
    , @journalID 
    , @eventType 
    , @startTime 
    , @endTime  
    , @orpDocID 
    , @notes 
    , @noteCriteriaQuestionsJSON 
    , @noteCriteriaAnswersJSON   
    , @svcNotesFormBuilderQuestionsJSON 
    , @svcNotesFormBuilderAnswersJSON   
    , @editDelReason  
    , @validateRec  
    , @saveType  
    , @recID  
    , @MsgNoRec  
    , @MsgNoEdit 
    , @MsgDupRec 
    , @MsgDataError 
    , @MsgNotActive 
    , @spDetails OUTPUT
    , @recordID  OUTPUT

/*============================================================
 * All done, commit changes and get out
 *============================================================*/  
    
COMMIT TRANSACTION    
SET @TranOpen = 0    
RETURN(0)    
END TRY  

/*============================================================
 * Exception handling
 *============================================================*/      

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
  
     
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/


GRANT EXECUTE ON  [dbo].[SVCJOURNAL_JOURNAL_ENTRY_SAVE] TO [webuser]
GO
