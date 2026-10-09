USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_VIEW] (
    @userID              bigint
  , @userGroup           int  
  , @userRank            int 
  , @clientID			 bigint  
  , @reviewed            bit
  , @active              bit
)    
RETURNS 
TABLE
AS
RETURN
(

select top (dbo.CONST_MAX_ROWS())
	pir.id
  , pir.clientID
  , pir.patientFirstName                 
  , pir.patientLastName                  
  , pir.patientDOB
  , patientDOBStr = dbo.RPT_DATE_FMT(pir.patientDOB)
  , pir.patID                          
  , pir.studentID                         
  , pir.insuranceCarrierID               
  , pir.memberID                         
  
  , pir.noInsuranceOptionSelected        
  , noInsuranceOptionSelectedStr = dbo.RPT_BIT_TO_YN(pir.noInsuranceOptionSelected)

  , pir.otherInsuranceOptionSelected     
  , otherInsuranceOptionSelectedStr = dbo.RPT_BIT_TO_YN(pir.otherInsuranceOptionSelected)
  , pir.insuranceCarrierOtherName        

  , ferpaConsent    = pir.consentToReleaseOfChildHealthRecsAndOrBenefitInfo 
  , ferpaConsentStr = dbo.RPT_BIT_TO_YN(pir.consentToReleaseOfChildHealthRecsAndOrBenefitInfo)
  , responseReceivedOn    = pir.created
  , responseReceivedOnStr = dbo.RPT_DATE_FMT(pir.created)
  , pir.responderIsParentGuardian                         
  , pir.responderFirstName                                
  , pir.responderLastName                                 
  , pir.responderEmail                                    
  , pir.responderPhone                                    
  , hasResponderSignatureImgData = convert(bit,(iif((pir.responderSignatureImgData is null),0,1)))
  , pir.responderSignatureImgData
  
  , patName              = pp.CONCAT_NAME 
  , insuranceCarrierName = ic.[name]
  
from dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES as pir

left join dbo.PATIENTS_Patient   as pp on (pp.PATIENT_ID = pir.patID)
left join dbo.INSURANCE_CARRIERS as ic on (pir.insuranceCarrierID = ic.id)

where (      
      (pir.clientID = @clientID)
  and ((@reviewed is null) or (pir.reviewed = @reviewed))
  and (pir.active   = 1)  
)

)
GO

GRANT SELECT ON  [dbo].[PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_VIEW] TO [webuser]
GO
