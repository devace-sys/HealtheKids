USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_VIEW_MERGE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENTS_VIEW_MERGE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENTS_VIEW_MERGE]    
(
 @clientID       INT,
 @pracID         INT,
 @lnamePat       NVARCHAR(50),    
 @fnamePat       NVARCHAR(50),    
 @dob            DATETIME,  
 @active         bit,
 @refDate        DATETIME,
 @findCSIS       CHAR(10),
 @inclUnknCSIS   bit,     
 @recID          INT)    

RETURNS TABLE

 /***************************************************************************    
  * PATIENTS_VIEW_MERGE */    
 /**    
  * Returns a table of patients that match the given parameters    
  *    
  * @param  clientID        Required.  ID of client    
  * @param  pracID          Practitioner ID for caseload
  * @param  inPracCaseLoad   In pracID's caseload
  * @param  lname           All or part of patients last name    
  * @param  fname           All or part of patients first name    
  * @param  dob             Patients dob    
  * @param  active          If patient is active    
  * @param  recID           Patient ID    
  * @return                 Table of patient data    
  ***************************************************************************/     
  
AS RETURN(

select TOP (dbo.CONST_MAX_ROWS())
  q1.PATIENT_ID                                     as id,    
  q1.CONCAT_NAME                                    as name,    
  q1.LAST_NAME                                      as lastName,    
  q1.FIRST_NAME                                     as firstName,     
  q1.DATE_OF_BIRTH                                  as dob, 
  dbo.yn_to_bit(q1.ACTIVE)                          as active,
  q1.CSIS                                           as CSIS,
  siteName,
  siteRank,
  siteRefID,   
  convert(VARCHAR(10), q1.DATE_OF_BIRTH, 101)       as dob_str,
  dbo.CALC_AGE_CURRENT(q1.DATE_OF_BIRTH)            as ageCurrent,    
  isnull(q1.SSN,'')                                 as ssn,    
  isnull(q1.SEX,'')                                 as gender,    
  isnull(q1.BIC,'')                                 as bic,    
  q1.CLIENT_ID                                      as clientID,    
  q1.CLIENT_NAME                                    as clientName,        
  isnull(q1.LASTPOP,      dbo.CONST_MIN_DATETIME()) as lastPopulated,    
  isnull(q1.LAST_UPDATED, dbo.CONST_MIN_DATETIME()) as lastModifed,    
  isnull(q1.START_DATE,   dbo.CONST_MIN_DATETIME()) as patStartDate,    
  isnull(q1.END_DATE,     dbo.CONST_MIN_DATETIME()) as patEndDate,
  isnull(q1.SUBMIT_CLAIMS,1)                        as submitClaims,
  q1.submitClaimsEffectiveDate                      as submitClaimsEffectiveDate,
  q1.parentConsentMCAL                              as parentConsentMCAL,
  q1.parentConsentMCALEffectiveDate                 as parentConsentMCALEffectiveDate,
  q1.parentConsentOHCI                              as parentConsentOHCI,
  q1.parentConsentOHCIEffectiveDate                 as parentConsentOHCIEffectiveDate,
  q1.clientBillMCALImpliedParentConsent,
  q1.createdByPCAL,
  --[email],
  --[phone]
  /* The following columns are a temp fix until we can refactor this code to use the 
   * common patients view functionality
   */
  	q1.ACTIVE       as activeYN,
	--dbo.RPT_DATE_FMT(vc.dob)           as dobStr,
	dbo.RPT_BIT_TO_YN(q1.SUBMIT_CLAIMS) as submitClaimsYN,
	dbo.RPT_DATE_FMT(q1.submitClaimsEffectiveDate) as submitClaimsEffectiveDateStr,
	dbo.RPT_PATIENT_MCAL_PARENTAL_CONSENT_STATUS (q1.clientBillMCALImpliedParentConsent, q1.parentConsentMCAL, q1.createdByPCAL) as medicalParentConsentYN,
	dbo.RPT_DATE_FMT(q1.parentConsentMCALEffectiveDate ) as parentConsentMCALEffectiveDateStr,
	dbo.RPT_BIT_TO_YNU(q1.parentConsentOHCI) as parentConsentOHCIYN,
	dbo.RPT_DATE_FMT(q1.parentConsentOHCIEffectiveDate ) as parentConsentOHCIEffectiveDateStr
from
(  
  select
    pc.PATIENT_ID,    
    p.CONCAT_NAME,    
    p.LAST_NAME,    
    p.FIRST_NAME,     
    p.DATE_OF_BIRTH, 
    isnull(p.CSIS,'') CSIS,   
    p.SSN,
    p.SEX,
    p.BIC,
    c.CLIENT_ID,
    c.CLIENT_NAME,
    upper(isnull(p.ACTIVE,'N')) as ACTIVE,
    ISNULL(pss.siteName,'') siteName,
    ISNULL(pss.siteRank,'') siteRank,
    ISNULL(pss.siteRefID,'') siteRefID,
    p.LASTPOP,
    p.LAST_UPDATED,
    pc.START_DATE,
    pc.END_DATE,
    p.SUBMIT_CLAIMS,
    p.submitClaimsEffectiveDate,
    p.parentConsentMCAL,
    p.parentConsentMCALEffectiveDate,
    p.parentConsentOHCI,
    p.parentConsentOHCIEffectiveDate,
    c.parentConsentAgreement as clientBillMCALImpliedParentConsent,
    p.createdByPCAL--,
    --[email] = Email,
    --[phone] = Phone

from dbo.CLIENTS_Client   as c
join dbo.PATIENTS_Client  as pc on pc.CLIENT_ID  = c.CLIENT_ID
join dbo.PATIENTS_Patient as p on p.PATIENT_ID = pc.PATIENT_ID

outer apply  (  -- NOTE: it's much faster to cross apply on a highly-restricted result set,
                  -- than to have a JOIN that returns a big result set and restrict it wih WHERE and ON conditions
    SELECT top 1 PATIENT_ID, SITE_NAME siteName, GRADE siteRank, STUDENT_ID siteRefID FROM
        dbo.PATIENTS_SITES_VIEW_CURRENT (@clientID) AS ps WHERE ps.PATIENT_ID = p.PATIENT_ID
        --[dbo].[PATIENTS_SITES_VIEW_CUST] (@clientID, p.PATIENT_ID, 0, 0, 0)
        -- [PATIENTS_SITES_VIEW_CUST] is slower than [PATIENTS_SITES_VIEW_CURRENT], but it returns more accurate results.
        -- Don't believe me, just look at 
        -- SELECT * FROM PATIENTS_School ps WHERE PATIENT_ID = '2057762' ORDER BY PATIENT_SCHOOL_ID DESC
        -- that one patient is an example of multiple edge cases at once!  And we have to care about all known edge cases, because edge cases are the whole reason we have a merge process
           
  ) pss

  --LEFT JOIN VIEW_MOST_RECENT_PAT_EMAIL_AND_PHONE v_contact ON p.PATIENT_ID = v_contact.PATIENT_ID

  
  where (c.CLIENT_ID   = @clientID)
  and  (p.LAST_NAME  like (ISNULL(@lnamePat, N'') + N'%'))    
  and  (p.FIRST_NAME like (ISNULL(@fnamePat, N'') + N'%')) 
  and  ((@dob       is null) or (p.DATE_OF_BIRTH = @dob))
  and  ((@recID     is null) or (pc.PATIENT_ID  = @recID)) 
  and  ((@active    is null) or (dbo.yn_to_bit(p.ACTIVE)       = @active))               
 ) as q1
 WHERE (@findCSIS  is null) or (TRIM(@findCSIS) = '') or (q1.CSIS = @findCSIS)
         OR (
       (@inclUnknCSIS is null OR @inclUnknCSIS = 1) AND (q1.CSIS = '')
       )
 ORDER BY
 clientName,
 -- expected CSIS at the top of the list; put blank/null CSIS at the bottom of the list
 CASE WHEN (@findCSIS IS NOT NULL AND TRIM(@findCSIS) != '' AND (@inclUnknCSIS IS NULL OR @inclUnknCSIS = 1)) THEN q1.CSIS ELSE '1' END DESC,
 lastName,
 firstName,
 dob
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENTS_VIEW_MERGE] TO [webuser]
GO