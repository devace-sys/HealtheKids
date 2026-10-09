USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_DATA_IMPORT_FLAG_FOR_LIVE_IMPORT') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_DATA_IMPORT_FLAG_FOR_LIVE_IMPORT
GO

CREATE PROCEDURE [dbo].[PATIENT_DATA_IMPORT_FLAG_FOR_LIVE_IMPORT] (
    @userID        BIGINT    
  , @userGroup     INT    
  , @userRank      INT    

  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @saveType      INT

  , @recID         BIGINT -- pdiID

  , @msgDupRec          VARCHAR(1000)    

  , @MsgNoRec           VARCHAR(1000)     
  , @MsgNoEdit          VARCHAR(1000)     
  , @MsgDataError       VARCHAR(1000)    

  , @MsgNotActive       VARCHAR(1000)

  , @spDetails          VARCHAR(8000) OUTPUT
  , @recordID           BIGINT        OUTPUT)

AS    
BEGIN     
     
SET NOCOUNT ON    

declare @today             as datetime
set @today                     = getdate()
set @spDetails                 = ''
set @recordID                  = 0

declare @TranOpen bit = 0

BEGIN TRY

BEGIN TRANSACTION

-- validation
if (not exists (select id from dbo.[Patient_Data_Imports] where id = @recID)) RAISERROR(@MsgNoRec, 11, 1)

SET @TranOpen = 1;

  UPDATE [dbo].[Patient_Data_Imports]
  SET

    [fileProcessingStarted]   = 0,
    [fileProcessingCompleted] = 0,

    [fileProcessingError]     = 0,
     -- the Patient_Data_Imports_View_Core udf is looking for these to be 0, not null;
     -- otherwise the RestView status is "unknown"


    [fileProcessingStartDateTime] = NULL,
    [fileProcessingEndDateTime]   = NULL,

    [numOfNewPatRecsNeeded]     = NULL,
    [numOfExistingPatRecsFound] = NULL,
    [numPatPlacesMatched]       = NULL,

    [numPatPlaceMatchesNeededForExistingPatient] = NULL,

    [numNewPatPlaceNeededForNewPatient]             = NULL,
    [numPatContactsMatched]                         = NULL,
    [numPatContactMatchesNeededForExistingPatient]  = NULL,
    [numPatContactMatchesNeededForNewPatient]       = NULL,
    [numPatSiteMatched]                             = NULL,

    [numOfExistingPatSiteRecsNeededForExistingPatient] = NULL,

    [numNewPatAndNewPatSiteMatchesNeeded] = NULL,
    [importResultsJSON]                   = NULL,
    [errorMessages]                       = NULL,

    [lastModified]   = NULL,
    [lastModifiedBy] = NULL,

    [manageSitesJSONData]                    = NULL,

    [hasPreImportRowExceptions]              = 0,
    [hasPreImportAdditionalBadRowExceptions] = 0,
    [preImportNumRowsSkipped]                = 0,
    [preImportNumColsSkipped]                = 0,
    [preImportNumAdditionalRowsSkipped]      = 0,
    [hasManageSitesData]                     = 0,
    [hasImportRowExceptions]                 = 0,
    [importRolledBack]                       = 0,
    [generateEligibilityMatchFile]           = 0,
    [eligibilityMatchFileGenerated]          = 0,

    [eligibilityMatchFileGeneratedOn]     = NULL,
    [preImportAdditionalBadRowsJSONData]  = NULL,
    [hasAdditionalBadRowExceptions]       = 0,
    [numImportPopRowsSkipped]             = 0,
    [numImportSpedRowsSkipped]            = 0,
    [hasSpedSvcsImportResults]            = 0,
    [spedSvcsImportResultsJSON]           = NULL,
    [parsingSpEdSvcDataFailed]            = 0,

    [eligibilityMatchfileGenerationUnscheduled]   = 0,
    [eligibilityMatchReturnFileReceived]          = 0,
    [eligibilityMatchReturnFileReceivedOn]        = NULL,
    [numExistingPatSiteRecsToDeac]                = NULL,
    [numDistinctPatIDsWExistingPatSiteRecsToDeac] = NULL,
    [numNewPatientsMatchedToUnknownSite]          = NULL,
    [numExistingPatientsMatchedToUnknownSite]     = NULL,
    [numExistingPatsWSiteCodeUnknownAndUnchanged] = NULL,
    [numRowsToBeSentInOutgoingElig]               = NULL,

    numVeryOldPatRecsDeacd                        = NULL,
    numBlankCsisValsPopulatedForExisting          = NULL,

    [okToCommitData] = 1

  WHERE id = @recID
  AND [okToCommitData] = 0
  

IF (@TranOpen  = 1) COMMIT TRANSACTION    

/*-------------------------------    
 * And we are done
 *------------------------------*/  

SET @TranOpen = 0    
RETURN(0)    

END TRY    

/*-------------------------------    
 * If we end up here something    
 * went wrong
 *------------------------------*/    

BEGIN CATCH    
  
  -- Error or raise error with severity 11 to 19 will be caught here    
    
  /*-------------------------------    
   * Cancel any pending    
   * transactions  
   *------------------------------*/    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
  /*-------------------------------    
   * Identify error
   *------------------------------*/    
  
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage 
      
 /*-------------------------------    
   * Return the error message to
   * the caller. 
   *------------------------------*/    
 
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    

END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[PATIENT_DATA_IMPORT_FLAG_FOR_LIVE_IMPORT] TO [webuser]
GO