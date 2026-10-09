USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENTS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENTS_VIEW] (
   @userID     INT    
 , @userGroup  INT    
 , @userRank   INT    
 , @source     INT
 , @clientID   INT
 , @pracID     INT
 , @siteID     INT
 , @siteRefID  NVARCHAR(50)    
 , @lname      NVARCHAR(50)    
 , @fname      NVARCHAR(50)
 , @dob        DATETIME    
 , @dos        DATETIME
 , @active     BIT    
 , @recID      INT
 , @canEdit    BIT 
) 
RETURNS TABLE    
 
 /***************************************************************************    
  * PATIENTS_VIEW */    
 /**    
  * Returns a table of patients that match the given parameters    
  *    
  * @param  userID          Callers user id    
  * @param  userGroup       Callers user group    
  * @param  userRank        Callers user rank    
  * @param  clientID        Required.  ID of client    
  * @param  lname           All or part of patients last name    
  * @param  fname           All or part of patients first name    
  * @param  dob             Patients dob    
  * @param  siteID          Patients site    
  * @param  dos             dos used for patient elibility calculation and caseload selection   
  * @param  active          If patient is active    
  * @param  recID           Patient ID    
  * @return                 Table of patient data    
  ***************************************************************************/     
  
AS RETURN (   
          
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/ 
 
with
cte_p1
as
(
  select 
    vc.*,   
	dbo.RPT_BIT_TO_YN(vc.ACTIVE)       as activeYN,
	dbo.RPT_DATE_FMT(vc.dob)           as dobStr,
	dbo.RPT_BIT_TO_YN(vc.submitClaims) as submitClaimsYN,
	dbo.RPT_DATE_FMT(vc.submitClaimsEffectiveDate) as submitClaimsEffectiveDateStr,
	dbo.RPT_PATIENT_MCAL_PARENTAL_CONSENT_STATUS (vc.clientBillMCALImpliedParentConsent, vc.parentConsentMCAL, vc.createdByPCAL) as medicalParentConsentYN,
	dbo.RPT_DATE_FMT(vc.parentConsentMCALEffectiveDate) as parentConsentMCALEffectiveDateStr,
	dbo.RPT_BIT_TO_YNU(vc.parentConsentOHCI) as parentConsentOHCIYN,
	dbo.RPT_DATE_FMT(vc.parentConsentOHCIEffectiveDate) as parentConsentOHCIEffectiveDateStr,
    [elgEst] = case when vc.ffpQualified = 1 
               then
			     case
			       when (peg.IS_ELIG = 1)    then dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()
                   when (peg.IS_ELIG = 0)    then dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()
                   when (peg.IS_ELIG = null) then dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_UNK()
                   else                           dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_UNK()
                   end
				else
				  case 
				    when vc.ffpQualified = 0 then dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO() 
					else dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_UNK() 
					end
			   end,
    isnull(pip.IEP_IFSP_NONE,'No IEP Record')                as iep,
    convert(bit, case when ((dbo.INT_HAS_VALUE(pip.PATIENT_ID) = 1) and (pip.IEP_IFSP_NONE in ('IFSP','IEP'))) then 1 else 0 end) as hasIEP,
    dbo.DATE_IS_PAST(dbo.DATE_END(GETDATE()), vc.patEndDate) as expired,
	patStartDate as startDate,
    patEndDate as endDate,
  [email]                  = ISNULL(pat_email.Email, N''),
  [phone]                  = ISNULL(pat_phone.Phone, N''),
  [ffpQualifiedStr]        = dbo.RPT_BIT_TO_YNU(vc.ffpQualified),
  spEdEnteredSpEdDateYMD   = dbo.RPT_DATE_FMT_YYYY_MM_DD(vc.spEdEnteredSpEdDate),
  spEdExitedSpEdDateYMD    = dbo.RPT_DATE_FMT_YYYY_MM_DD(vc.spEdExitedSpEdDate),
  spEdLastEvalDateYMD      = dbo.RPT_DATE_FMT_YYYY_MM_DD(vc.spEdLastEvalDate),
  spEdNextEvalDateYMD      = dbo.RPT_DATE_FMT_YYYY_MM_DD(vc.spEdNextEvalDate),
  spEdLastAnnualIEPDateYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(vc.spEdLastAnnualIEPDate),
  spEdNextAnnualIEPDateYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(vc.spEdNextAnnualIEPDate),
  spEdCurIEPDateYMD        = dbo.RPT_DATE_FMT_YYYY_MM_DD(vc.spEdCurIEPDate),

  [teacherOrCounselorOrCaseManagerName] = case 
    when (len(vc.teacherOrCounselorName) > 0) then vc.teacherOrCounselorName
    when (len(vc.spEdCaseManagerName)    > 0) then vc.spEdCaseManagerName
    else '' 
  end,

  
  submitClaimsEffectiveDateYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(vc.submitClaimsEffectiveDate),
  cybhiSubmitClaimsYN          = dbo.RPT_BIT_TO_YN(vc.cybhiSubmitClaims),
  parentConsentMCALYNU         = dbo.RPT_BIT_TO_YNU(vc.parentConsentMCAL),
  cybhiTpaApprovedYN           = dbo.RPT_BIT_TO_YN(vc.cybhiTpaApproved),
  cybhiTpaApprovedOnYMD        = dbo.RPT_DATE_FMT_YYYY_MM_DD(vc.cybhiTpaApprovedOn),
  parentConsentMCALEffectiveDateYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(vc.parentConsentMCALEffectiveDate),
  ferpaConsentYNU                   = dbo.RPT_BIT_TO_YNU(vc.ferpaConsent),
  ferpaConsentEffectiveDateYMD      = dbo.RPT_DATE_FMT_YYYY_MM_DD(vc.ferpaConsentEffectiveDate),
  speciallyAdaptedVehicleForTransportationYN = dbo.RPT_BIT_TO_YN(vc.speciallyAdaptedVehicleForTransportation),
  treatmentConsentYNU                        = dbo.RPT_BIT_TO_YNU(vc.treatmentConsent),
  treatmentConsentEffectiveDateYMD           =  dbo.RPT_DATE_FMT_YYYY_MM_DD(vc.treatmentConsentEffectiveDate),
  preferredContactMethodName = isnull(mc.[name], ''),
  minorConsentYN = dbo.RPT_BIT_TO_YN(vc.minorConsent),
  minorConsentEffectiveDateYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(vc.minorConsentEffectiveDate)

  from dbo.PATIENTS_VIEW_CORE (  @source
                               , @clientID 
                               , @pracID
                               , dbo.CREATE_NAME_PAT(@lname)
                               , dbo.CREATE_NAME_PAT(@fname)
                               , dbo.DATE_START_OR_NULL(@dob,1)
                               , dbo.BIT_TO_YN(@active)
                               , dbo.DATE_START(@dos,1)
							   , @siteID
                               , @siteRefID 
                               , @recID ) as vc
     
    left join dbo.CONTACT_METHODS					      as mc	  on  mc.code = vc.preferredContactMethodCode

	left join dbo.PATIENTS_IEP                            as pip  on  pip.PATIENT_ID = vc.id          

    left join dbo.PATIENTS_ELIGIBILITY_NORMALIZED         as peg  on  peg.PATIENT_ID = vc.id 
                                                                  and peg.MONTH_DATE = dbo.DATE_START(@dos,3)

	

    OUTER APPLY (
	  SELECT top 1 
	    pat_e.[Email] 
	  FROM dbo.[PATIENTS_Email] as pat_e 
	  WHERE pat_e.[PATIENT_ID] = vc.id AND pat_e.ACTIVE = 1
	) as pat_email

    OUTER APPLY (
	  SELECT top 1 
	    pat_ph.[Phone] 
	  FROM dbo.[PATIENTS_Phone] as pat_ph 
	  WHERE pat_ph.[PATIENT_ID] = vc.id AND pat_ph.ACTIVE = 1
	 ) as pat_phone
    
)

select top (dbo.CONST_MAX_ROWS()) 
    p1.*
  , hasIEPYN = dbo.RPT_BIT_TO_YN(p1.hasIEP)
   
  , patientHomePlaceID         = isnull(pp2.ID,0)
  , patientHomePlaceName       = isnull(pp2.[NAME],'')  
  , street1                    = isnull(pp2.ADDRESS_1,'')
  , street2                    = isnull(pp2.ADDRESS_2,'')
  , city                       = isnull(pp2.CITY,'')
  , [state]                    = isnull(pp2.[STATE],'')
  , zip5                       = isnull(pp2.ZIP_5,'')
  , zip4                       = isnull(pp2.ZIP_4,'')
  , pac2.patientUserIDInt

from cte_p1 as p1

/* Get patient home address */
/* Keep in synch with homeplace id get logic in C:\SBSC\Spedmon\Database\TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_SAVE_CORE.sql */

outer apply (
  select top 1 
      pp1.ID
	, pp1.NAME
	, pp1.ADDRESS_1
	, pp1.ADDRESS_2
	, pp1.CITY
	, pp1.STATE
	, pp1.ZIP_5
	, pp1.ZIP_4	
  from dbo.PATIENT_PLACES as pp1
  where (
        ((pp1.PATIENT_ID = p1.id) and (pp1.id is not null)) /* Index */
    and (pp1.PATIENT_PLACE_TYPE = 1)
    and (pp1.ACTIVE             = 1)
  )
  order by 
      pp1.id         desc
	, pp1.START_DATE desc
) as pp2


outer apply (
  select top 1 
    patientUserIDInt = pac1.userIDInt 
  from dbo.PATIENTS_USER_ACCOUNTS as pac1
  where 
    ((pac1.clientID = p1.clientID) and (pac1.patID = p1.id) and (pac1.active = 1))
) as pac2

order by 

  p1.clientName, 
  p1.lastName, 
  p1.firstName, 
  p1.dob
 
)   
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[PATIENTS_VIEW] TO [webuser]
GO
