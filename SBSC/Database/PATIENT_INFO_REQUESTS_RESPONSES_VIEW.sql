USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (
    SELECT * 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID('dbo.PATIENT_INFO_REQUESTS_RESPONSES_VIEW') 
      AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT')
)
DROP FUNCTION dbo.PATIENT_INFO_REQUESTS_RESPONSES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PATIENT_INFO_REQUESTS_RESPONSES_VIEW] (
      @userID              BIGINT
    , @userGroup           INT
    , @userRank            INT
    , @clientID            BIGINT
    , @active              BIT
    , @recID               BIGINT
) 
RETURNS TABLE
AS RETURN (

select top (dbo.CONST_MAX_ROWS())
    pirr.* 
  , consent    = pirr.consentToReleaseOfChildHealthRecsAndOrBenefitInfo
  , requestID  = pirr.id
  , patName    = pap.CONCAT_NAME   
  , dob        = pap.DATE_OF_BIRTH
  , dobStr     = dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH)  
  , siteName   = psvc.SITE_NAME
  , studentID  = psvc.STUDENT_ID 
  , grade      = psvc.GRADE
  , ssid       = isnull(pap.CSIS,N'')
  , clientName = clc.CLIENT_NAME
  , clientLogoFileData  = ''
  , requesterName       = ua2.[name]
  , requesterTitle      = ua2.pracDispGroupName
  , requesterEmail      = ua2.email
  , requesterPhone      = ua2.phone  
  , hasResponderSignatureImgData = convert(bit,(iif((pirr.responderSignatureImgData is null),0,1)))
  , insuranceCarrierName         = isnull(ic2.insuranceCarrierName,'')
  , consentStr                   = iif((pirr.consentToReleaseOfChildHealthRecsAndOrBenefitInfo is not null),dbo.RPT_BIT_TO_YN(pirr.consentToReleaseOfChildHealthRecsAndOrBenefitInfo),'')
  , responseReceivedOnStr        = dbo.RPT_DATE_FMT(pirr.responseReceivedOn)
 
from dbo.Patient_Info_Requests_Responses         as pirr
join dbo.PATIENTS_Patient                        as pap  on  pap.PATIENT_ID  = pirr.patID
join dbo.CLIENTS_Client                          as clc  on  clc.CLIENT_ID   = pirr.clientID
join dbo.PATIENTS_SITES_VIEW_CURRENT (@clientID) as psvc on  psvc.PATIENT_ID = pirr.patID

outer apply (
  select top 1 
    insuranceCarrierName = ic1.[name] 
  from dbo.INSURANCE_CARRIERS as ic1
  where 
    (ic1.id = pirr.insuranceCarrierID)
) as ic2

outer apply (
  select top 1
      ua1.[name]
	, ua1.pracDispGroupName
    , ua1.phone
    , ua1.email
  from users.dbo.USERS_ALL as ua1 
  where 
    (ua1.id = pirr.createdBy)
) as ua2

where (
        (1=1)
    and (pirr.clientID  = @clientID)
	--and (pirr.completed = 0)
    and (pirr.active    = 1)
    and ((@recID IS NULL) OR (pirr.id = @recID))
)

order by 
  pap.CONCAT_NAME

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[PATIENT_INFO_REQUESTS_RESPONSES_VIEW] TO [webuser]
GO
