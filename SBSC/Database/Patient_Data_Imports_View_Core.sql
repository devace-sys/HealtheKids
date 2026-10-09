USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_View_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patient_Data_Imports_View_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Patient_Data_Imports_View_Core] (
    @userID               BIGINT
  , @userGroup            INT
  , @userRank             INT
  , @clientID             BIGINT
  , @waitingForProcessing bit
  , @currentlyProcessing  bit
  , @processingComplete   bit
  , @recID                bigint
)

RETURNS TABLE

 /***************************************************************************
  * Patient_Data_Imports_View_Core */
 /**
  * Returns
  *
  * @return table
  ***************************************************************************/

AS RETURN

with
cte_p1
as
(
select top (dbo.CONST_MAX_ROWS())
    pdi.id
  , clientName = clc.CLIENT_NAME
  , pdi.clientID
  , sdi.fileProfileName
  , sdi.fileName
  , sdi.fileSize
  , sdi.fileClass
  , sdi.fileSubClass
  , sdi.fileMimeType
  , fileSizeStr = dbo.CALC_HUMAN_BYTE_SIZE (sdi.fileSize,1)
  , pdi.structuredDataImportID
  , pdi.numOfIncomingPatDataRecords
  , patientDataImportID = pdi.id
  , importedOn          = pdi.created
  , importedOnStr       = convert(varchar, pdi.created,9)
  , importedByUserID    = pdi.createdBy
  , importedByUserName  = u.UserName

  , pdi.fileAccepted
  , fileAcceptedStr = dbo.RPT_BIT_TO_YN(pdi.fileAccepted)
  , pdi.fileAcceptedOn
  , fileAcceptedOnStr = convert(varchar, pdi.fileAcceptedOn,9)
  , pdi.fileProcessingStarted
  , pdi.fileProcessingCompleted
  , pdi.fileProcessingStartDateTime
  , pdi.fileProcessingEndDateTime

  , pdi.hasPreImportRowExceptions
  , pdi.hasPreImportAdditionalBadRowExceptions
  , pdi.hasManageSitesData
  , pdi.hasImportRowExceptions
  , pdi.importRolledBack

  , pdi.preImportNumRowsSkipped
  , pdi.preImportNumColsSkipped
  , pdi.preImportNumAdditionalRowsSkipped

  , pdi.generateEligibilityMatchFile
  , pdi.eligibilityMatchFileGenerated
  , pdi.eligibilityMatchReturnFileReceived
  , pdi.eligibilityMatchfileGenerationUnscheduled

  , numRowsSuccessfullyImported = ISNULL(pdi.numOfNewPatRecsNeeded, 0) + ISNULL(pdi.numOfExistingPatRecsFound, 0)
                                  -- too bad I didn't have the presence of mind to make these NOT NULL default (0) when these columns were created
                                  -- on a second thought, I am making numRowsToBeSentInOutgoingElig a null-default column
                                  -- so that we can see when a column has been populated with 0 vs not-yet-populated
  , waitingForProcessing = convert(bit,(iif(((pdi.fileAccepted = 1) and (fileProcessingError = 0) and (pdi.fileProcessingStarted = 0) and (pdi.fileProcessingCompleted = 0))
  		                             ,1
		                             ,0)))
  , currentlyProcessing  = convert(bit,(iif(((pdi.fileAccepted = 1) and (fileProcessingError = 0) and (pdi.fileProcessingStarted = 1) and (pdi.fileProcessingCompleted = 0))
  		                             ,1
		                             ,0)))

  , processingCompleted  = convert(bit,(iif(((pdi.fileAccepted = 1) and (fileProcessingError = 0) and (pdi.fileProcessingStarted = 1) and (pdi.fileProcessingCompleted = 1))
  		                             ,1
		                             ,0)))
  , processingError      = convert(bit,(iif(((pdi.fileAccepted = 1) and (fileProcessingError = 1))
  		                           ,1
		                           ,0)))

  , pdi.numRowsToBeSentInOutgoingElig

  , pdi.okToCommitData

  , CASE WHEN pdi.okToCommitData = 1 THEN 'Live Mode' ELSE 'Test Mode' END isTestMode

  , pdi.numRowsCSISMissing

  , pdi.completedNormally

  , dbo.RPT_BIT_TO_YNB( pdi.completedNormally ) completedNormallyYN

  , pdi.earlyExit

  , dbo.RPT_BIT_TO_YNB( pdi.earlyExit ) earlyExitYN

  , pdi.rejectedValidateGradeDOBs 

  , dbo.RPT_BIT_TO_YNB( pdi.rejectedValidateGradeDOBs  ) rejectedValidateGradeDOBsYN

  , pdi.unknownProblem

  , dbo.RPT_BIT_TO_YNB(  pdi.unknownProblem ) unknownProblemYN

from dbo.Patient_Data_Imports    as pdi
join dbo.CLIENTS_Client          as clc on clc.CLIENT_ID = pdi.clientID
join dbo.Structured_Data_Imports as sdi on sdi.id        = pdi.structuredDataImportID
join users.dbo.Users             as u   on u.userrid     = pdi.createdBy

where (
      (1=1)
  and ((@recID is null)   or (pdi.id = @recID))
  and ((@clientID is null) or (pdi.clientID = @clientID))
)
)
,
cte_p2
as
(
select
    p1.*
  , currentStatusStr = case
    when (p1.waitingForProcessing = 1) then 'Waiting for Processing'
	when (p1.currentlyProcessing  = 1) then 'Currently Processing'
	when (p1.processingCompleted  = 1) then 'Processing Complete'
	when (p1.processingError      = 1) then 'Processing Error'
    else 'Unknown'
  end

 , importResultsStatusStr = case when p1.processingCompleted = 0 then '' else
	 case when p1.importRolledBack = 1 then 'All rows were skipped' else
	   case
	     when p1.hasPreImportRowExceptions               = 1 then 'Some rows and/or columns were skipped'
	     when p1.hasPreImportAdditionalBadRowExceptions  = 1 then 'Some rows and/or columns were skipped'
	     when p1.hasImportRowExceptions                  = 1 then 'Some rows and/or columns were skipped'
	                                                         else  'No rows were skipped'
	    end
      end
	end
 from cte_p1 as p1
 where (
      (1=1)
  and ((@waitingForProcessing is null) or (p1.waitingForProcessing = @waitingForProcessing))
  and ((@currentlyProcessing  is null) or (p1.currentlyProcessing  = @currentlyProcessing))
  and ((@processingComplete   is null) or (p1.processingCompleted  = @processingComplete))
)
)

select
  p2.*
from cte_p2 as p2

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[Patient_Data_Imports_View_Core] TO [webuser]
GO
