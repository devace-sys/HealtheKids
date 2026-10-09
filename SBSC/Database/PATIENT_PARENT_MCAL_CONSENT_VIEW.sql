USE [SPEDMON]
GO

DROP FUNCTION if exists [dbo].[PATIENT_PARENT_MCAL_CONSENT_VIEW]
GO

CREATE FUNCTION [dbo].[PATIENT_PARENT_MCAL_CONSENT_VIEW] (  
     @clientID            bigint
   , @patID               bigint
   , @parentConsent       bit
   , @hasUnknownConsent   bit
   , @hasHeldClaims       bit
)

 
RETURNS TABLE
AS RETURN (

with
cte_p1
as
(
select
    ID                                             = pap.PATIENT_ID
  , clc.CLIENT_ID
  , pap.PATIENT_ID
  , PATIENT_NAME                                   = pap.CONCAT_NAME
  , DATE_OF_BIRTH_VAL                              = pap.DATE_OF_BIRTH 
  , DATE_OF_BIRTH_STR                              = dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH)
  , PATIENT_SITE_NAME                              = ps.SITE_NAME
  , PATIENT_STUDENT_ID                             = ps.STUDENT_ID
  , PATIENT_CSIS                                   = pap.CSIS
  , CURRENT_CONSENT_STATUS_STR                     = dbo.RPT_BIT_TO_YNU(pap.parentConsentMCAL)
  , CURRENT_CONSENT_STATUS_VAL                     = pap.parentConsentMCAL
  , CURRENT_CONSENT_STATUS_EFF_DATE_STR            = dbo.RPT_DATE_FMT(pap.parentConsentMCALEffectiveDate)
  , CURRENT_CONSENT_STATUS_EFF_DATE_STR_YYYY_MM_DD = dbo.RPT_DATE_FMT_YYYY_MM_DD(pap.parentConsentMCALEffectiveDate)
  , CURRENT_CONSENT_STATUS_EFF_DATE_VAL            = pap.parentConsentMCALEffectiveDate
  , CURRENT_CONSENT_STATUS_NOTES                   = isnull(pap.parentConsentMCALNotes,'')
  , CASE_MANAGER                                   = pap.spEdCaseManagerName
  , HAS_UNKNOWN_CONSENT                            = convert(bit,(iif ((pap.parentConsentMCAL is null),1,0)))
  
from dbo.CLIENTS_Client   as clc
join dbo.PATIENTS_Client  as pac on  (pac.CLIENT_ID = clc.CLIENT_ID)
join dbo.PATIENTS_PATIENT as pap on  ((pap.PATIENT_ID = pac.PATIENT_ID) and (pap.ACTIVE in (N'y',N'Y')))
join dbo.PATIENTS_SITES_VIEW_CURRENT (@clientID)  as ps on ps.PATIENT_ID = pap.PATIENT_ID  
where (
        (clc.CLIENT_ID = @clientID)
	and (pac.CLIENT_ID = @clientID)
	and ((@parentConsent is null) or (pap.parentConsentMCAL = @parentConsent))
	and ((@patID is null)         or (pap.PATIENT_ID = @patID))
)
)
,
cte_p2
as
(

select 

	p1.*
  , HAS_HELD_CLAIMS                            = convert( bit,(iif ((cch2.PAT_ID is null),0,1)))
  , HELD_CLAIMS_TOTAL_EST_REIMBURSE_AMOUNT_VAL = isnull(cch2.TOT_EST_AMT,convert(money,0))

from cte_p1 as p1

outer apply (
  select  
	 cch1.PAT_ID
	,TOT_EST_AMT = sum(cch1.TOT_EST_AMT) 
  from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_ACTIONABLE_REPORT_DATA as cch1
  where (
             (cch1.CLIENT_ID = p1.CLIENT_ID)
         and (cch1.PAT_ID    = p1.PATIENT_ID)
         and (cch1.HOLD_CODE = 1000)
  )
  group by 
    cch1.PAT_ID
) as cch2

where ( 
      (1=1)
  and ((@hasUnknownConsent is null) or (p1.HAS_UNKNOWN_CONSENT = @hasUnknownConsent))
)

)
,
cte_p3
as
(
select
    p2.*
  , HELD_CLAIMS_TOTAL_EST_REIMBURSE_AMOUNT_STR = dbo.RPT_ROUND_FMT(p2.HELD_CLAIMS_TOTAL_EST_REIMBURSE_AMOUNT_VAL)
from cte_p2 as p2
where(  
      (1=1)
  and ((@hasHeldClaims is null) or (p2.HAS_HELD_CLAIMS = @hasHeldClaims))
)
)

select top (dbo.CONST_MAX_ROWS())
  p3.*
from cte_p3 as p3
order by 
    p3.PATIENT_NAME asc
) 
GO

GRANT SELECT ON [dbo].[PATIENT_PARENT_MCAL_CONSENT_VIEW] TO webuser
GO

