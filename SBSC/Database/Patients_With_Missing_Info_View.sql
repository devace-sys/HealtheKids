USE SPEDMON
GO

-- Drop if exists

IF EXISTS (
  SELECT * FROM sys.objects 
  WHERE object_id = OBJECT_ID('dbo.Patients_With_Missing_Info_View') 
    AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT')
)
DROP FUNCTION dbo.Patients_With_Missing_Info_View
GO

-- Create function

CREATE FUNCTION dbo.Patients_With_Missing_Info_View (
      @userID     bigint
    , @userGroup  int
    , @userRank   int
    , @clientID   bigint
    , @patID      bigint  /* Possible future use */
	, @source     tinyint = 1 /* 1= CYBHI */
    , @missingInsuranceInfo                     bit = null
    , @missingAddressInfo                       bit = null
    , @missingOrNoFerpaConsent                  bit = null
    , @missingPGEmails                          bit = null
	, @missingMcalParentConsent                 bit = null
    , @hasCurrentInfoRequest                    bit = null
    , @hasCurrentInfoRequestWaitingForReview    bit = null
    , @hasPreviousInfoRequestThatRequiredReview bit = null
	, @limitToPatsWithMissingInfo               bit = 1
)
RETURNS TABLE
AS
RETURN (

WITH 
cte_p1 
AS 
(
  select
    t1.*
  from dbo.Patients_With_Missing_Info_View_Core (
        @clientID
	  , @patID
      , @source
      , @missingInsuranceInfo
      , @missingAddressInfo
      , @missingOrNoFerpaConsent
      , @missingPGEmails
	  , @missingMcalParentConsent   
      , @hasCurrentInfoRequest
	  , @hasCurrentInfoRequestWaitingForReview
      , @hasPreviousInfoRequestThatRequiredReview
	  , @limitToPatsWithMissingInfo
  ) as t1
)
,
cte_p2 
as 
(
  select
        p1.*	  
      , patName   = pap.CONCAT_NAME 
      , dob       = pap.DATE_OF_BIRTH
	  , dobStr    = dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH)
      , ssid      = isnull(pap.CSIS, N'')
      , siteName  = psvc.SITE_NAME
      , studentID = psvc.STUDENT_ID 
      , grade     = psvc.GRADE
  from cte_p1                  as p1
  join dbo.PATIENTS_Patient    as pap  on pap.PATIENT_ID  = p1.patID
  join dbo.PATIENTS_SITES_VIEW_CURRENT(@clientID) as psvc on psvc.PATIENT_ID = p1.patID
)
,
cte_p3 
as 
(
  select
      p2.*,
	  	 
      /* Curr info request - If any */

	  pirrCurr.publicToken									as currentInfoRequestPublicToken,
      pirrCurr.requestSent									as currentInfoRequestRequestSent,
      pirrCurr.requestSentOn								as currentInfoRequestSentOn,
      dbo.RPT_DATE_FMT(pirrCurr.requestSentOn)				as currentInfoRequestSentOnStr,
      pirrCurr.requestSentToJSON							as currentInfoRequestSentToJSON,
      pirrCurr.responseReceived								as currentInfoRequestResponseReceived,
      pirrCurr.responseReceivedOn							as currentInfoRequestResponseReceivedOn,
      dbo.RPT_DATE_FMT(pirrCurr.responseReceivedOn)			as currentInfoRequestResponseReceivedOnStr,
      pirrCurr.responseReceivedByPatPerID					as currentInfoRequestResponseReceivedByPatPerID,
      pirrCurr.insuranceCarrierPolicyHolderFirstName		as currentInfoRequestResponsePolicyHolderFirstName,
      pirrCurr.insuranceCarrierPolicyHolderLastName			as currentInfoRequestResponsePolicyHolderLastName,
      pirrCurr.policyNumber									as currentInfoRequestResponsePolicyNumber,
      ISNULL(pirrCurr.insuranceGroupNumberID, '')			as currentInfoRequestResponseGroupNumber,
      ISNULL(pirrCurr.icName, '')							as currentInfoRequestResponseInsuranceCarrierName,
      ISNULL(pirrCurr.insuranceCarrierOtherName, '')		as currentInfoRequestResponseInsuranceCarrierOtherName,
      ISNULL(pirrCurr.responderFullName, '')				as currentInfoRequestResponseResponderName,
      pirrCurr.consentToReleaseOfChildHealthRecsAndOrBenefitInfo as currentInfoRequestResponseResponderConsent,
      IIF(
          pirrCurr.consentToReleaseOfChildHealthRecsAndOrBenefitInfo IS NOT NULL,
          dbo.RPT_BIT_TO_YN(pirrCurr.consentToReleaseOfChildHealthRecsAndOrBenefitInfo),
          ''
      ) as currentInfoRequestResponseResponderConsentStr,
      CONVERT(bit, IIF(pirrCurr.responderSignatureImgData IS NULL, 0, 1)) as currentInfoRequestResponseHasResponderSignatureImgData,
      pirrCurr.responderSignatureImgData					              as currentInfoRequestResponseResponderSignatureImgData,
      pirrCurr.noInsuranceOptionSelected					              as currentInfoRequestResponseNoInsuranceOptionSelected,
      pirrCurr.otherInsuranceOptionSelected					              as currentInfoRequestResponseOtherInsuranceOptionSelected,
   
      /* Prev info request - If any */

      pirrPrev.responseReceived								as prevInfoRequestResponseReceived,
      pirrPrev.responseReceivedOn							as prevInfoRequestResponseReceivedOn,
      dbo.RPT_DATE_FMT(pirrPrev.responseReceivedOn)			as prevInfoRequestResponseReceivedOnStr,
      pirrPrev.responseReceivedByPatPerID					as prevInfoRequestResponseReceivedByPatPerID,
      pirrPrev.insuranceCarrierPolicyHolderFirstName		as prevInfoRequestResponsePolicyHolderFirstName,
      pirrPrev.insuranceCarrierPolicyHolderLastName			as prevInfoRequestResponsePolicyHolderLastName,
      pirrPrev.policyNumber									as prevInfoRequestResponsePolicyNumber,
      ISNULL(pirrPrev.insuranceGroupNumberID, '')			as prevInfoRequestResponseGroupNumber,
      ISNULL(pirrPrev.icName, '')							as prevInfoRequestResponseInsuranceCarrierName,
      ISNULL(pirrPrev.insuranceCarrierOtherName, '')		as prevInfoRequestResponseInsuranceCarrierOtherName,
      ISNULL(pirrPrev.responderFullName, '')				as prevInfoRequestResponseResponderName,
      pirrPrev.consentToReleaseOfChildHealthRecsAndOrBenefitInfo as prevInfoRequestResponseResponderConsent,
      IIF(
          pirrPrev.consentToReleaseOfChildHealthRecsAndOrBenefitInfo IS NOT NULL,
          dbo.RPT_BIT_TO_YN(pirrPrev.consentToReleaseOfChildHealthRecsAndOrBenefitInfo),
          ''
      ) as prevInfoRequestResponseResponderConsentStr,
      CONVERT(bit, IIF(pirrPrev.responderSignatureImgData IS NULL, 0, 1)) as prevInfoRequestResponseHasResponderSignatureImgData,
      pirrPrev.responderSignatureImgData					              as prevInfoRequestResponseResponderSignatureImgData,
      pirrPrev.noInsuranceOptionSelected					              as prevInfoRequestResponseNoInsuranceOptionSelected,
      pirrPrev.otherInsuranceOptionSelected					              as prevInfoRequestResponseOtherInsuranceOptionSelected
  
  from cte_p2 as p2
  
  /* Current info request - If any */
  
  outer apply (
      SELECT top 1 
	      pirr.*
		, patper.responderFullName
		, icName = ic.name        		
	  FROM      dbo.PATIENT_INFO_REQUESTS_RESPONSES as pirr
      LEFT JOIN dbo.INSURANCE_CARRIERS              as ic on ic.id = pirr.insuranceCarrierID
      OUTER APPLY (
        SELECT TOP 1
          pep.FIRST_NAME + ' ' + pep.LAST_NAME AS responderFullName
        FROM dbo.PATIENTS_PERSON AS ppp
        JOIN dbo.PERSONS_PERSON  AS pep ON pep.ID = ppp.PERSON_ID
        WHERE 
	      (ppp.id = pirr.responseReceivedByPatPerID)
    ) AS patper
    WHERE (
	      (p2.hasCurrentInfoRequest = 1)
	  and (pirr.id = p2.currentInfoRequestID)
	)
  ) AS pirrCurr

  /* Prev info request - If any */
  
  outer apply (
      SELECT top 1 
	      pirr.*
		, patper.responderFullName
		, icName = ic.name
      FROM dbo.PATIENT_INFO_REQUESTS_RESPONSES AS pirr
      LEFT JOIN dbo.INSURANCE_CARRIERS AS ic ON ic.id = pirr.insuranceCarrierID
      OUTER APPLY (
        SELECT TOP 1
          pep.FIRST_NAME + ' ' + pep.LAST_NAME AS responderFullName
        FROM dbo.PATIENTS_PERSON AS ppp
        JOIN dbo.PERSONS_PERSON AS pep ON pep.ID = ppp.PERSON_ID
        WHERE 
	      (ppp.id = pirr.responseReceivedByPatPerID)
    ) AS patper
    where (
	      (p2.hasPreviousInfoRequestThatRequiredReview = 1)
	  and (pirr.id = p2.prevInfoRequestThatRequiredReviewID)
	)
  ) AS pirrPrev

)
select top (dbo.CONST_MAX_ROWS())
      p3.*
    , dbo.RPT_BIT_TO_YN(p3.missingInsuranceInfo)     as missingInsuranceInfoStr
    , dbo.RPT_BIT_TO_YN(p3.missingAddressInfo)       as missingAddressInfoStr
    , dbo.RPT_BIT_TO_YN(p3.missingFerpaConsent)      as missingFerpaConsentStr
	, dbo.RPT_BIT_TO_YN(p3.missingPGEmails)          as missingPGEmailsStr   
	, dbo.RPT_BIT_TO_YN(p3.missingMcalParentConsent) as missingMcalParentConsentStr
from cte_p3 as p3
order by 
    p3.hasCurrentInfoRequestWaitingForReview desc
  , p3.hasCurrentInfoRequest                 asc  
  , p3.patName                               asc

)
GO

-- Grant permission
GRANT SELECT ON dbo.Patients_With_Missing_Info_View TO [webuser]
GO
