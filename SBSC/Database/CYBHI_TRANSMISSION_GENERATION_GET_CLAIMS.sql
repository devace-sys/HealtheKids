
use SPEDMON 
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS
GO

/*---------------------------------------------------------------------------------------------------------*/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (
    @transmissionID     bigint
  , @claimHeld          bit
)
RETURNS 
TABLE
AS
RETURN
(
  select 
      ctc.transmissionID
    , ctc.id
	, ctc.referenceID  
    , ctc.claimID
    , ctc.claimHeld
    , ctc.holdCode

	, clm.clientID
	, clm.patID
	, clm.dos
	, clm.procedureID
	, clm.numUnits
    , clm.claimLineNum
	, clm.renderingPracID
	, clm.supervisingPracID
	, clm.orpPracID
	, clm.txStatusCode
	, clm.amountClaimed
    , src.svcRecID
    , clm.claimingPracID
	, clm.claimWithWhatPracMode
	, ctc.siteID
	, ctc.useTpaIdAsInsuranceMemberID
	, ctc.patInsuranceCarrierID
	, ctc.patInsuranceMemberID
	, ctc.patInsuranceCarrierPcCode
	, clm.created

  from dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS as ctc
  join dbo.CYBHI_CLAIMS                    as clm on clm.id       = ctc.claimID
  join dbo.CYBHI_SERVICE_RECORD_CLAIMS     as src on src.claimID  = clm.id
  where (
        ((ctc.transmissionID = @transmissionID) and (ctc.id > 0))
    and ((@claimHeld is null) or (ctc.claimHeld = @claimHeld))  
  )

)
GO
