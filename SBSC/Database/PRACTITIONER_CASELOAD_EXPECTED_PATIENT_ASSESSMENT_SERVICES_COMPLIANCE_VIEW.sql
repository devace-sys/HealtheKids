USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_CASELOAD_EXPECTED_PATIENT_ASSESSMENT_SERVICES_COMPLIANCE_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_CASELOAD_EXPECTED_PATIENT_ASSESSMENT_SERVICES_COMPLIANCE_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITIONER_CASELOAD_EXPECTED_PATIENT_ASSESSMENT_SERVICES_COMPLIANCE_VIEW] (
    @userID          bigint    
  , @userGroup       bigint    
  , @userRank        bigint
  , @clientID        bigint
  , @pracID          bigint
  , @patsInCaseload  bit = 1
)    

RETURNS 
TABLE 
AS
RETURN
(

with
cte_p1
as
(

select 
	upcoming.patID
  , upcoming.startDateStr
  , upcoming.endDateStr 
  , upcoming.clientID  
  , upcoming.pracID
  , upcoming.groupID
  , upcoming.expectedEntryContext
from dbo.PRACTITIONER_CASELOAD_UPCOMING_POSSIBLE_PATIENT_ASSESSMENT_VIEW_CORE (  
    @clientID 
  , @pracID
  , @patsInCaseload) as upcoming

union 

select 
	missing.patID
  , missing.startDateStr
  , missing.endDateStr 
  , missing.clientID  
  , missing.pracID
  , missing.groupID
  , missing.expectedEntryContext
from dbo.PRACTITIONER_CASELOAD_MISSING_POSSIBLE_PATIENT_ASSESSMENT_VIEW_CORE (  
    @clientID 
  , @pracID
  , @patsInCaseload
) as missing

)

select 
    id  = ROW_NUMBER() over (order by pap.CONCAT_NAME asc, pap.DATE_OF_BIRTH, pap.PATIENT_ID)
  , p1.patID
  , [patName]        = pap.CONCAT_NAME 
  , dobStr           = dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH)
  , p1.startDateStr  
  , p1.endDateStr    
  , p1.clientID  
  , p1.pracID
  , p1.groupID
  , p1.expectedEntryContext
from cte_p1 as p1
join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = p1.patID

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONER_CASELOAD_EXPECTED_PATIENT_ASSESSMENT_SERVICES_COMPLIANCE_VIEW] TO [webuser]
GO
