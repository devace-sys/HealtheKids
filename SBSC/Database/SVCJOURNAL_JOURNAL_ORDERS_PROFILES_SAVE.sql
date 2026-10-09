USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_ORDERS_PROFILES_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SVCJOURNAL_JOURNAL_ORDERS_PROFILES_SAVE
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SVCJOURNAL_JOURNAL_ORDERS_PROFILES_SAVE]     
 (@userID                   BIGINT,    
  @userGroup                INT,    
  @userRank                 INT,    
  @clientID                 BIGINT, 
  @patID                    BIGINT, 
  @orpDocType               BIGINT,
  @effectiveDate            DATE,
  @endDate                  DATE,
  @svcName                  VARCHAR(1000),
  @orpDocStdNameID          bigint,
  @svcDesc                  VARCHAR(8000),
  @noteCrit1                VARCHAR(2000),
  @noteCrit2                VARCHAR(2000),
  @noteCrit3                VARCHAR(2000),
  @noteCrit4                VARCHAR(2000),
  @noteCrit5                VARCHAR(2000),
  @noteCrit6                VARCHAR(2000),
  @noteCrit7                VARCHAR(2000),
  @noteCrit8                VARCHAR(2000),
  @noteCrit9                VARCHAR(2000),
  @noteCrit10               VARCHAR(2000),
  @expectedOutcomes         VARCHAR(8000),
  @allowMultipleOrders      BIT,
  @orderContextFieldName    VARCHAR(200),
  @formBuilderQuestionsJSON VARCHAR(max),
  @formBuilderAnswersJSON   VARCHAR(max),
  @noteObsvCmnt             VARCHAR(2000),  
  @iep                      bit,
  @frequency     			int,
  @projectedMinutes			int,
  @planStartDate			date,
  @planEndDate				date,
  @siteAide                 bit,
  @busAide                  bit,
  @dailyFreq                int,
  @pracIDsStr               varchar(8000),
  @detailsTrainingPracsJSON varchar(max),
  @detailsTrainingPracs ServiceJournalPractitionerTrainingDetails readonly,
  @orpPracID               BIGINT,
  @groupServiceClassNameID BIGINT,
  @orpAuthSvcDate          DATE,
  @orpAuthExpDate          DATE,
  @svcAuthStatusConfirmRespCode BIGINT,
  @diagnosis          VARCHAR(8000),
  @mdOrders           VARCHAR(8000),
  @editDelReason      VARCHAR(7000),    
  @validateRec        BIT,    
  @saveType           INT,    
  @recID              BIGINT,
  @MsgNoRec           VARCHAR(1000),    
  @MsgNoEdit          VARCHAR(1000), 
  @MsgDupRec          VARCHAR(1000),   
  @MsgDataError       VARCHAR(1000),
  @MsgNotActive       VARCHAR(1000),     
  @spDetails          VARCHAR(8000) OUTPUT,    
  @recordID           BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * SVCJOURNAL_JOURNAL_ORDERS_PROFILES_SAVE */    
/**    
 * Creates or edits prescribed order
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
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
 * @param   MsgDataError    Desired error message for data errors    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted     
 ***************************************************************************/         
     
SET NOCOUNT ON    


BEGIN TRY
    if (@orpDocType = 2)
	begin
		exec dbo.SVCJOURNAL_JOURNAL_PRESCRIBED_ORDER_SAVE     
		       @userID                  
			 , @userGroup               
			 , @userRank                
			 , @clientID                
			 , @patID                   
			 , @effectiveDate           
			 , @endDate                 
			 , @svcName                 
			 , @orpDocStdNameID         
			 , @svcDesc                 
			 , @noteCrit1               
			 , @noteCrit2               
			 , @noteCrit3               
			 , @noteCrit4
			 , @noteCrit5
			 , @noteCrit6
			 , @noteCrit7
			 , @noteCrit8 
			 , @noteCrit9 
			 , @noteCrit10                
			 , @allowMultipleOrders     
			 , @orderContextFieldName   
			 , @formBuilderQuestionsJSON
			 , @formBuilderAnswersJSON  
			 , @noteObsvCmnt            
			 , @iep 
			 , @frequency     	
			 , @projectedMinutes	
			 , @planStartDate	
			 , @planEndDate		                    
			 , @dailyFreq               
			 , @pracIDsStr              
			 , @detailsTrainingPracsJSON
			 , @detailsTrainingPracs
			 , @orpPracID              
			 , @groupServiceClassNameID
			 , @orpAuthSvcDate 
			 , @orpAuthExpDate
			 , @svcAuthStatusConfirmRespCode 
			 , @editDelReason     
			 , @validateRec       
			 , @saveType          
			 , @recID             
			 , @MsgNoRec          
			 , @MsgNoEdit         
			 , @MsgDupRec         
			 , @MsgDataError      
			 , @MsgNotActive      
			 , @spDetails       OUTPUT      
			 , @recordID		OUTPUT
	end

	else if (@orpDocType = 3)
	begin
		exec dbo.SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_SAVE
			  @userID             
			, @userGroup          
			, @userRank           
			, @clientID           
			, @patID              
			, @effectiveDate      
			, @diagnosis          
			, @mdOrders           
			, @svcDesc 
			, @expectedOutcomes   
			, @allowMultipleOrders      
			, @orderContextFieldName    
			, @formBuilderQuestionsJSON 
			, @formBuilderAnswersJSON   
			, @iep    
			, @frequency     	
			, @projectedMinutes	
			, @planStartDate	
			, @planEndDate		                  
			, @siteAide                 
			, @busAide                  
			, @pracIDsStr              
			, @detailsTrainingPracsJSON 
			, @detailsTrainingPracs 
			, @orpPracID      
			, @orpAuthSvcDate 
			, @orpAuthExpDate
			, @svcAuthStatusConfirmRespCode
			, @editDelReason     
			, @validateRec       
			, @saveType          
			, @recID             
			, @MsgNoRec          
			, @MsgNoEdit         
			, @MsgDupRec         
			, @MsgDataError      
			, @MsgNotActive      
			, @spDetails              OUTPUT
			, @recordID               OUTPUT
	end

	else
	begin
		RAISERROR('Invalid ORP Document Type', 11, 1)
	end

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
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  -- Only send really bad exceptions back with sp details

  if (@ErrorSeverity > 11)    
    SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/


GRANT EXECUTE ON  [dbo].[SVCJOURNAL_JOURNAL_ORDERS_PROFILES_SAVE] TO [webuser]
GO
