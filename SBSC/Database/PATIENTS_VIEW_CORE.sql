USE SPEDMON
GO



/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENTS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PATIENTS_VIEW_CORE] (
    @source         INT
  , @clientID       INT
  , @pracID         INT
  , @lnamePat       NVARCHAR(50)
  , @fnamePat       NVARCHAR(50)
  , @dob            DATETIME
  , @active         nvarchar(1)
  , @refDate        DATETIME
  , @siteID         INT
  , @siteRefID      NVARCHAR(50)
  , @recID          INT
)
RETURNS TABLE

 /***************************************************************************
  * PATIENTS_VIEW_CORE */
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

AS RETURN (

with
cte_p1
as
(
  select
      pdc.SOURCE
	, pdc.CLIENT_ID
	, pdc.PATIENT_CLIENT_ID
	, pdc.PATIENT_ID
	, pdc.START_DATE
	, pdc.END_DATE	
	, siteRefID = isnull(ps.STUDENT_ID,N'') 
    , siteRank  = isnull(ps.GRADE,'')   
    , siteID    = ps.SITE_ID        
    , siteName  = ps.SITE_NAME

  from dbo.PATIENTS_DATA_CORE ( isnull(@source,0)
                               , @clientID
							   , @pracID
							   , @refDate
							   , @recID) as pdc
                                    
  /* [LAST_FIRST_DOB_SEX_ID] */

  join dbo.PATIENTS_Patient as pap on (
           (1=1)
	 and  ((@lnamePat  is null) or (pap.LAST_NAME  like (@lnamePat)))
     and  ((@fnamePat  is null) or (pap.FIRST_NAME like (@fnamePat)) or (pap.preferredNickname like (@fnamePat)))
     and  ((@dob       is null) or (pap.DATE_OF_BIRTH = @dob))   
	 and  ((@active    is null) or (pap.ACTIVE        = @active))
     and  (pap.PATIENT_ID = pdc.PATIENT_ID)
  )
  
  
  join dbo.PATIENTS_SITES_VIEW_CURRENT (@clientID) as ps on ((ps.PATIENT_ID = pap.PATIENT_ID)
                                                         and ((@siteID is null) or (ps.SITE_ID = @siteID)))
  
  
  
  where (
        (1=1) 
    and ((@siteRefID is null) or ((ps.STUDENT_ID = @siteRefID) or (pap.CSIS = @siteRefID)))
  )
)
,
cte_p2
as
(
  select
      pc.SOURCE
    , pc.START_DATE
    , pc.END_DATE
    , pc.PATIENT_ID
	, pc.siteRefID
    , pc.siteRank
    , pc.siteID
    , pc.siteName

    , p.CONCAT_NAME
    , p.LAST_NAME
    , p.FIRST_NAME
	, p.MIDDLE_NAME
    , p.DATE_OF_BIRTH
    , p.CSIS
    , p.SSN
    , p.SEX
    , p.BIC
    , c.CLIENT_ID
    , c.CLIENT_NAME
    , ACTIVE = isnull(p.ACTIVE,'N')
    , p.LASTPOP
    , p.LAST_UPDATED
    , p.SUBMIT_CLAIMS
    , p.submitClaimsEffectiveDate
    , p.parentConsentMCAL
    , p.parentConsentMCALEffectiveDate
    , p.minorConsent
    , p.minorConsentEffectiveDate
    , p.parentConsentOHCI
    , p.parentConsentOHCIEffectiveDate
	, p.ferpaConsent
	, p.ferpaConsentEffectiveDate
	, p.treatmentConsent
	, p.treatmentConsentEffectiveDate

	, p.cybhiTpaApproved
    , p.cybhiTpaApprovedOn
    , cybhiTpaID = isnull(p.cybhiTpaID,'')
	, p.cybhiSubmitClaims

    , c.parentConsentAgreement as clientBillMCALImpliedParentConsent
    , p.createdByPCAL
    , isnull(pn.note,'')                                  as notes
	, p.speciallyAdaptedVehicleForTransportation          as speciallyAdaptedVehicleForTransportation
    , pn.id                                               as patNoteRecID

    , p.spEdSpecialTransportation
	, p.spEdLastEvalDate
	, p.spEdLastAnnualIEPDate
	, p.spEdNextAnnualIEPDate

	, p.spEdDisability1Code
	, spEdDisability1CodeAndName = iif ((psdc1.codeValue is not null)
	                                  , (convert(varchar(50),psdc1.codeValue) + ' ' + psdc1.[name])
									  , '')
	, p.spEdDisability2Code
	, spEdDisability2CodeAndName = iif (  (psdc2.codeValue is not null)
	                                  , (convert(varchar(50),psdc2.codeValue) + ' ' + psdc2.[name])
									  , '')
    , p.spEdCurIEPDate
	, p.spEdStudentStrengths
	, p.spEdParentConcerns
	, p.spEdProgressMonitoringData
	, p.spEdStudentPresentLevelsStatement
	, p.spEdStudentDisabilityAffectsPerformance
	, p.spEdCurEligibilityDate
	, p.spEdInitEligibilityDate
	, p.spEdIEPAttendeesIdentified
	, p.spEdEligibilityReasons
	, p.spEdInitRefDate
    , p.spEdReferringPartyCode
	, spEdReferringPartyCodeAndName = iif ((srp.codeValue is not null)
	                                  , (convert(varchar,srp.codeValue) + ' ' + srp.[name])
									  , '')
    , p.spEdReferringPartyOtherOption
    , p.spEdDistrictReceivedParentConsentDate
    , p.spEdMeetingPurposeDataJSON
    , p.spEdAdditionalMeetingPurposeDataJSON
    , p.spEdAmendmentReasonsDataJSON
    , p.spEdPlanTypeCode
	, spEdPlanTypeCodeAndName = iif ((spt.codeValue is not null)
	                                  , (convert(varchar,spt.codeValue) + ' ' + spt.[name])
									  , '')

     , spEdCaseManagerName = trim(isnull(p.spEdCaseManagerName,''))
	 , p.spEdCaseManagerUserID
	 , p.spEdCaseManagerUserName
 	 , p.spEdExitedSpEdDate
     , p.ffpQualified
	 , p.altFormat
     , p.spEdPlanTranslateToLanguageCodeID
	 , spEdPlanTranslateToLanguageCode = sptlng.codeValue
     , spEdPlanTranslateToLanguageCodeAndName = iif ((sptlng.id is not null), sptlng.codeValue + ' ' + sptlng.[name], '')
	 , p.spEdStudentLanguageCodeID
	 , spEdStudentLanguageCode                = sslng.codeValue
	 , spEdStudentLanguageCodeAndName         = iif ((sslng.id is not null), sslng.codeValue + ' ' + sslng.[name], '')
	 , p.spEdStudentRaceCode
	 , spEdStudentRaceCodeAndName             = iif ((ssrace.id is not null), convert(varchar,ssrace.codeValue) + ' ' + ssrace.[name], '')
	 , p.spEdNextEvalDate
	 , p.spEdEnteredSpEdDate
	 , p.spEdStudentLanguageEnglishLearner
	 , p.spEdStudentLanguageInfoReclassified
     , p.spEdStudentLanguageInterpreterNeeded
     , p.spEdStudentLanguageTranslationRequested
	 , p.spEdStudentLanguageEnglishLearnerUndesignatedPreschool
	 , p.spEdServicesDataJSON
	 , p.spEdTransitionGoalEducation
	 , p.spEdTransitionGoalTraining
	 , p.spEdTransitionGoalEmployment
	 , p.spEdTransitionGoalIndependentLiving
	 , p.spEdDevAcaFunSkillsReading
     , p.spEdDevAcaFunSkillsWriting
     , p.spEdDevAcaFunSkillsMath
     , p.spEdDevAcaFunSkillsCommunicationDev
     , p.spEdDevAcaFunSkillsGrossFineMotorDev
     , p.spEdDevAcaFunSkillsHealth
     , p.spEdDevAcaFunSkillsVocational
     , p.spEdDevAcaFunSkillsAdaptiveDailyLiving
     , p.spEdDevAcaFunSkillsAreasOfNeccessity
	 , p.spEdParticipantDetailsJSON
	 , p.spEdFacilitatorUserID
     , spEdFacilitatorUserName = trim(isnull(p.spEdFacilitatorUserName,''))
     , p.spEdMeetingDate
     , spEdMeetingDateYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(p.spEdMeetingDate)
     , p.spEdMeetingDurationInMins
     , spEdMeetingTime = isnull(p.spEdMeetingTime,'')
     , spEdMeetingTitle = isnull(p.spEdMeetingTitle,'')
     , spEdAmendmentReasonsOtherOption = isnull(p.spEdAmendmentReasonsOtherOption,'')
     , spEdMeetingPurposeOtherOption = isnull(p.spEdMeetingPurposeOtherOption,'')
     , p.spEdDevAcaFunSkillsSocialEmotionalBehavioral
     , p.spEdPresentLevelsDataJSON
     , p.spEdPresentLevelsPreparedBy
     , p.spEdPresentLevelsPreparedByName
     , p.spEdStudentStrengthsSource
     , p.spEdStudentStrengthsSourceJSON
     , p.spEdStudentStrengthsImpact
     , p.spEdParentConcernsSource
     , p.spEdParentConcernsSourceJSON
     , p.spEdReadingReviewedNA
     , p.spEdReadingSource
     , p.spEdReadingSourceJSON
     , p.spEdReadingBaselineValue
     , p.spEdReadingBaselineUnit
     , p.spEdReadingToolsUsed
     , p.spEdReadingToolsUsedJSON
     , p.spEdReadingBaselineDate
     , p.spEdReadingImpactSummary
     , p.spEdWritingReviewedNA
     , p.spEdWritingSource
     , p.spEdWritingSourceJSON
     , p.spEdWritingBaselineValue
     , p.spEdWritingBaselineUnit
     , p.spEdWritingToolsUsed
     , p.spEdWritingToolsUsedJSON
     , p.spEdWritingBaselineDate
     , p.spEdWritingImpactSummary
     , p.spEdMathReviewedNA
     , p.spEdMathSource
     , p.spEdMathSourceJSON
     , p.spEdMathBaselineValue
     , p.spEdMathBaselineUnit
     , p.spEdMathToolsUsed
     , p.spEdMathToolsUsedJSON
     , p.spEdMathBaselineDate
     , p.spEdMathImpactSummary
     , p.spEdCommunicationDevReviewedNA
     , p.spEdCommunicationDevSource
     , p.spEdCommunicationDevSourceJSON
     , p.spEdCommunicationDevBaselineValue
     , p.spEdCommunicationDevBaselineUnit
     , p.spEdCommunicationDevToolsUsed
     , p.spEdCommunicationDevToolsUsedJSON
     , p.spEdCommunicationDevBaselineDate
     , p.spEdCommunicationDevImpactSummary
     , p.spEdGrossFineMotorReviewedNA
     , p.spEdGrossFineMotorSource
     , p.spEdGrossFineMotorSourceJSON
     , p.spEdGrossFineMotorBaselineValue
     , p.spEdGrossFineMotorBaselineUnit
     , p.spEdGrossFineMotorToolsUsed
     , p.spEdGrossFineMotorToolsUsedJSON
     , p.spEdGrossFineMotorBaselineDate
     , p.spEdGrossFineMotorImpactSummary
     , p.spEdHealthReviewedNA
     , p.spEdHealthSource
     , p.spEdHealthSourceJSON
     , p.spEdHealthBaselineValue
     , p.spEdHealthBaselineUnit
     , p.spEdHealthToolsUsed
     , p.spEdHealthToolsUsedJSON
     , p.spEdHealthBaselineDate
     , p.spEdHealthImpactSummary
     , p.spEdVocationalReviewedNA
     , p.spEdVocationalSource
     , p.spEdVocationalSourceJSON
     , p.spEdVocationalBaselineValue
     , p.spEdVocationalBaselineUnit
     , p.spEdVocationalToolsUsed
     , p.spEdVocationalToolsUsedJSON
     , p.spEdVocationalBaselineDate
     , p.spEdVocationalImpactSummary
     , p.spEdAdaptiveDailyLivingReviewedNA
     , p.spEdAdaptiveDailyLivingSource
     , p.spEdAdaptiveDailyLivingSourceJSON
     , p.spEdAdaptiveDailyLivingBaselineValue
     , p.spEdAdaptiveDailyLivingBaselineUnit
     , p.spEdAdaptiveDailyLivingToolsUsed
     , p.spEdAdaptiveDailyLivingToolsUsedJSON
     , p.spEdAdaptiveDailyLivingBaselineDate
     , p.spEdAdaptiveDailyLivingImpactSummary
     , p.spEdSocialEmotionalBehavioralReviewedNA
     , p.spEdSocialEmotionalBehavioralSource
     , p.spEdSocialEmotionalBehavioralSourceJSON
     , p.spEdSocialEmotionalBehavioralBaselineValue
     , p.spEdSocialEmotionalBehavioralBaselineUnit
     , p.spEdSocialEmotionalBehavioralToolsUsed
     , p.spEdSocialEmotionalBehavioralToolsUsedJSON
     , p.spEdSocialEmotionalBehavioralBaselineDate
     , p.spEdSocialEmotionalBehavioralImpactSummary
     , p.spEdStudentStrengthsSourceNames
     , p.spEdParentConcernsSourceNames
     , p.spEdReadingSourceNames
     , p.spEdWritingSourceNames
     , p.spEdMathSourceNames
     , p.spEdCommunicationDevSourceNames
     , p.spEdGrossFineMotorSourceNames
     , p.spEdHealthSourceNames
     , p.spEdVocationalSourceNames
     , p.spEdAdaptiveDailyLivingSourceNames
     , p.spEdSocialEmotionalBehavioralSourceNames
     , p.spEdReadingBaselineUnitNames
     , p.spEdWritingBaselineUnitNames
     , p.spEdMathBaselineUnitNames
     , p.spEdCommunicationDevBaselineUnitNames
     , p.spEdGrossFineMotorBaselineUnitNames
     , p.spEdHealthBaselineUnitNames
     , p.spEdVocationalBaselineUnitNames
     , p.spEdAdaptiveDailyLivingBaselineUnitNames
     , p.spEdSocialEmotionalBehavioralBaselineUnitNames
     , p.spEdReadingToolsUsedNames
     , p.spEdWritingToolsUsedNames
     , p.spEdMathToolsUsedNames
     , p.spEdCommunicationDevToolsUsedNames
     , p.spEdGrossFineMotorToolsUsedNames
     , p.spEdHealthToolsUsedNames
     , p.spEdVocationalToolsUsedNames
     , p.spEdAdaptiveDailyLivingToolsUsedNames
     , p.spEdSocialEmotionalBehavioralToolsUsedNames
     , preferredNickname      = isnull(p.preferredNickname,N'')
     , teacherOrCounselorName = trim(isnull(p.teacherOrCounselorName,''))
    , inTransitionalHousingStatus
    , inTransitionalHousingStatusYN = [dbo].[RPT_BIT_TO_YN]( inTransitionalHousingStatus ) 
	, p.deceased
	, deceasedYN = dbo.RPT_BIT_TO_YN(p.deceased)
	, preferredContactMethodCode = p.preferredContactMethodCode

  from       cte_p1                                      as pc
  join       dbo.PATIENTS_Patient                        as p       on  p.PATIENT_ID     = pc.PATIENT_ID
  join       dbo.CLIENTS_Client                          as c       on  c.CLIENT_ID      = pc.CLIENT_ID
  
  left join  dbo.INPUT_NOTES_PAT (@clientID,@recID) as pn      on  pn.patID         = p.PATIENT_ID
  left join  dbo.SpEd_Disability_Codes              as psdc1   on  psdc1.codeValue  = p.[spEdDisability1Code]
  left join  dbo.SpEd_Disability_Codes              as psdc2   on  psdc2.codeValue  = p.[spEdDisability2Code]
  left join  dbo.SpEd_Referring_Party               as srp     on  srp.codeValue    = p.spEdReferringPartyCode
  left join  dbo.SpEd_Plan_Type                     as spt     on  spt.codeValue    = p.spEdPlanTypeCode
  left join  dbo.SpEd_Language                      as sptlng  on  sptlng.id        = p.spEdPlanTranslateToLanguageCodeID
  left join  dbo.SpEd_Language                      as sslng   on  sslng.id         = p.spEdStudentLanguageCodeID
  left join  dbo.SpEd_Race                          as ssrace  on  ssrace.codeValue = p.spEdStudentRaceCode

  
)

select 
  q1.PATIENT_ID                                     as id,
  q1.SOURCE                                         as source,
  [name] = iif((len(q1.preferredNickname) = 0)
               , q1.CONCAT_NAME
			   , q1.CONCAT_NAME + N' (' + q1.preferredNickName + N')'
			   ),
  q1.LAST_NAME                                      as lastName,
  q1.FIRST_NAME                                     as firstName,
  q1.MIDDLE_NAME     								as middleName,
  q1.DATE_OF_BIRTH                                  as dob,
  dbo.yn_to_bit(q1.ACTIVE)                          as active,
  isnull(q1.CSIS,N'')                               as CSIS,
  dbo.RPT_DATE_FMT(q1.DATE_OF_BIRTH)                as dob_str,
  dbo.RPT_DATE_FMT_YYYY_MM_DD(q1.DATE_OF_BIRTH)     as dobStrYMD,
  dbo.CALC_AGE_CURRENT(q1.DATE_OF_BIRTH)            as ageCurrent,
  isnull(q1.SSN,N'')                                as ssn,
  isnull(q1.SEX,N'')                                as gender,
  isnull(q1.BIC,N'')                                as bic,
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
  q1.minorConsent                                   as minorConsent,
  q1.minorConsentEffectiveDate                      as minorConsentEffectiveDate,
  q1.parentConsentOHCI                              as parentConsentOHCI,
  q1.parentConsentOHCIEffectiveDate                 as parentConsentOHCIEffectiveDate,

  q1.ferpaConsent                                   as ferpaConsent,
  q1.ferpaConsentEffectiveDate                      as ferpaConsentEffectiveDate,
  q1.treatmentConsent                               as treatmentConsent,
  q1.treatmentConsentEffectiveDate                  as treatmentConsentEffectiveDate,

  q1.cybhiTpaApproved                               as cybhiTpaApproved,
  q1.cybhiTpaApprovedOn                             as cybhiTpaApprovedOn,
  q1.cybhiTpaID                                     as cybhiTpaID,
  q1.cybhiSubmitClaims                              as cybhiSubmitClaims,

  q1.clientBillMCALImpliedParentConsent,
  q1.createdByPCAL,
  q1.notes,
  q1.patNoteRecID,
  isnull(q1.speciallyAdaptedVehicleForTransportation,0) as speciallyAdaptedVehicleForTransportation,

  q1.spEdSpecialTransportation,
  q1.spEdLastEvalDate,
  q1.spEdLastAnnualIEPDate,
  q1.spEdNextAnnualIEPDate,
  q1.spEdDisability1Code,
  q1.spEdDisability1CodeAndName,
  q1.spEdDisability2Code,
  q1.spEdDisability2CodeAndName,
  q1.spEdCaseManagerName,
  q1.spEdCaseManagerUserID,
  q1.spEdCaseManagerUserName,
  q1.spEdExitedSpEdDate,
  q1.ffpQualified,
  q1.altFormat,
  q1.spEdCurIEPDate,
  q1.spEdStudentStrengths,
  q1.spEdParentConcerns,
  q1.spEdProgressMonitoringData,
  q1.spEdStudentPresentLevelsStatement,
  q1.spEdStudentDisabilityAffectsPerformance,
  q1.spEdCurEligibilityDate,
  dbo.RPT_DATE_FMT_YYYY_MM_DD(q1.spEdCurEligibilityDate) as spEdCurEligibilityDateStrYMD,
  q1.spEdInitEligibilityDate,
  dbo.RPT_DATE_FMT_YYYY_MM_DD(q1.spEdInitEligibilityDate) as spEdInitEligibilityDateStrYMD,
  q1.spEdIEPAttendeesIdentified,
  q1.spEdEligibilityReasons,

  q1.spEdInitRefDate,
  dbo.RPT_DATE_FMT_YYYY_MM_DD(q1.spEdInitRefDate) as spEdInitRefDateStrYMD,
  q1.spEdReferringPartyCode,
  q1.spEdReferringPartyCodeAndName,
  q1.spEdReferringPartyOtherOption,
  q1.spEdDistrictReceivedParentConsentDate,
  dbo.RPT_DATE_FMT_YYYY_MM_DD(q1.spEdDistrictReceivedParentConsentDate) as spEdDistrictReceivedParentConsentDateStrYMD,
  q1.spEdMeetingPurposeDataJSON,
  q1.spEdAdditionalMeetingPurposeDataJSON,
  q1.spEdAmendmentReasonsDataJSON,
  q1.spEdPlanTypeCode,
  q1.spEdPlanTypeCodeAndName,
  q1.spEdPlanTranslateToLanguageCodeID,
  q1.spEdPlanTranslateToLanguageCode,
  q1.spEdPlanTranslateToLanguageCodeAndName,
  q1.spEdStudentLanguageCodeID,
  q1.spEdStudentLanguageCode,
  q1.spEdStudentLanguageCodeAndName,
  q1.spEdStudentRaceCode,
  q1.spEdStudentRaceCodeAndName,
  q1.spEdNextEvalDate,
  q1.spEdEnteredSpEdDate,
  q1.spEdStudentLanguageEnglishLearner,
  q1.spEdStudentLanguageInfoReclassified,
  q1.spEdStudentLanguageInterpreterNeeded,
  q1.spEdStudentLanguageTranslationRequested,
  q1.spEdStudentLanguageEnglishLearnerUndesignatedPreschool,
  q1.spEdServicesDataJSON ,
  q1.spEdTransitionGoalEducation,
  q1.spEdTransitionGoalTraining,
  q1.spEdTransitionGoalEmployment,
  q1.spEdTransitionGoalIndependentLiving,

  q1.spEdDevAcaFunSkillsReading,
  q1.spEdDevAcaFunSkillsWriting,
  q1.spEdDevAcaFunSkillsMath,
  q1.spEdDevAcaFunSkillsCommunicationDev,
  q1.spEdDevAcaFunSkillsGrossFineMotorDev,
  q1.spEdDevAcaFunSkillsHealth,
  q1.spEdDevAcaFunSkillsVocational,
  q1.spEdDevAcaFunSkillsAdaptiveDailyLiving,
  q1.spEdDevAcaFunSkillsAreasOfNeccessity,

  q1.spEdParticipantDetailsJSON,
  q1.spEdFacilitatorUserID,
  q1.spEdFacilitatorUserName,
  q1.spEdMeetingDate,
  q1.spEdMeetingDateYMD,
  q1.spEdMeetingDurationInMins,
  q1.spEdMeetingTime,
  q1.spEdMeetingTitle,
  q1.spEdAmendmentReasonsOtherOption,
  q1.spEdMeetingPurposeOtherOption,
  q1.spEdDevAcaFunSkillsSocialEmotionalBehavioral,
  q1.spEdPresentLevelsDataJSON,
  q1.spEdPresentLevelsPreparedBy,
  q1.spEdPresentLevelsPreparedByName,
  q1.spEdStudentStrengthsSource,
  q1.spEdStudentStrengthsSourceJSON,
  q1.spEdStudentStrengthsImpact,
  q1.spEdParentConcernsSource,
  q1.spEdParentConcernsSourceJSON,
  q1.spEdReadingReviewedNA,
  q1.spEdReadingSource,
  q1.spEdReadingSourceJSON,
  q1.spEdReadingBaselineValue,
  q1.spEdReadingBaselineUnit,
  q1.spEdReadingToolsUsed,
  q1.spEdReadingToolsUsedJSON,
  q1.spEdReadingBaselineDate,
  q1.spEdReadingImpactSummary,
  q1.spEdWritingReviewedNA,
  q1.spEdWritingSource,
  q1.spEdWritingSourceJSON,
  q1.spEdWritingBaselineValue,
  q1.spEdWritingBaselineUnit,
  q1.spEdWritingToolsUsed,
  q1.spEdWritingToolsUsedJSON,
  q1.spEdWritingBaselineDate,
  q1.spEdWritingImpactSummary,
  q1.spEdMathReviewedNA,
  q1.spEdMathSource,
  q1.spEdMathSourceJSON,
  q1.spEdMathBaselineValue,
  q1.spEdMathBaselineUnit,
  q1.spEdMathToolsUsed,
  q1.spEdMathToolsUsedJSON,
  q1.spEdMathBaselineDate,
  q1.spEdMathImpactSummary,
  q1.spEdCommunicationDevReviewedNA,
  q1.spEdCommunicationDevSource,
  q1.spEdCommunicationDevSourceJSON,
  q1.spEdCommunicationDevBaselineValue,
  q1.spEdCommunicationDevBaselineUnit,
  q1.spEdCommunicationDevToolsUsed,
  q1.spEdCommunicationDevToolsUsedJSON,
  q1.spEdCommunicationDevBaselineDate,
  q1.spEdCommunicationDevImpactSummary,
  q1.spEdGrossFineMotorReviewedNA,
  q1.spEdGrossFineMotorSource,
  q1.spEdGrossFineMotorSourceJSON,
  q1.spEdGrossFineMotorBaselineValue,
  q1.spEdGrossFineMotorBaselineUnit,
  q1.spEdGrossFineMotorToolsUsed,
  q1.spEdGrossFineMotorToolsUsedJSON,
  q1.spEdGrossFineMotorBaselineDate,
  q1.spEdGrossFineMotorImpactSummary,
  q1.spEdHealthReviewedNA,
  q1.spEdHealthSource,
  q1.spEdHealthSourceJSON,
  q1.spEdHealthBaselineValue,
  q1.spEdHealthBaselineUnit,
  q1.spEdHealthToolsUsed,
  q1.spEdHealthToolsUsedJSON,
  q1.spEdHealthBaselineDate,
  q1.spEdHealthImpactSummary,
  q1.spEdVocationalReviewedNA,
  q1.spEdVocationalSource,
  q1.spEdVocationalSourceJSON,
  q1.spEdVocationalBaselineValue,
  q1.spEdVocationalBaselineUnit,
  q1.spEdVocationalToolsUsed,
  q1.spEdVocationalToolsUsedJSON,
  q1.spEdVocationalBaselineDate,
  q1.spEdVocationalImpactSummary,
  q1.spEdAdaptiveDailyLivingReviewedNA,
  q1.spEdAdaptiveDailyLivingSource,
  q1.spEdAdaptiveDailyLivingSourceJSON,
  q1.spEdAdaptiveDailyLivingBaselineValue,
  q1.spEdAdaptiveDailyLivingBaselineUnit,
  q1.spEdAdaptiveDailyLivingToolsUsed,
  q1.spEdAdaptiveDailyLivingToolsUsedJSON,
  q1.spEdAdaptiveDailyLivingBaselineDate,
  q1.spEdAdaptiveDailyLivingImpactSummary,
  q1.spEdSocialEmotionalBehavioralReviewedNA,
  q1.spEdSocialEmotionalBehavioralSource,
  q1.spEdSocialEmotionalBehavioralSourceJSON,
  q1.spEdSocialEmotionalBehavioralBaselineValue,
  q1.spEdSocialEmotionalBehavioralBaselineUnit,
  q1.spEdSocialEmotionalBehavioralToolsUsed,
  q1.spEdSocialEmotionalBehavioralToolsUsedJSON,
  q1.spEdSocialEmotionalBehavioralBaselineDate,
  q1.spEdSocialEmotionalBehavioralImpactSummary,
  q1.spEdStudentStrengthsSourceNames,
  q1.spEdParentConcernsSourceNames,
  q1.spEdReadingSourceNames,
  q1.spEdWritingSourceNames,
  q1.spEdMathSourceNames,
  q1.spEdCommunicationDevSourceNames,
  q1.spEdGrossFineMotorSourceNames,
  q1.spEdHealthSourceNames,
  q1.spEdVocationalSourceNames,
  q1.spEdAdaptiveDailyLivingSourceNames,
  q1.spEdSocialEmotionalBehavioralSourceNames,
  q1.spEdReadingBaselineUnitNames,
  q1.spEdWritingBaselineUnitNames,
  q1.spEdMathBaselineUnitNames,
  q1.spEdCommunicationDevBaselineUnitNames,
  q1.spEdGrossFineMotorBaselineUnitNames,
  q1.spEdHealthBaselineUnitNames,
  q1.spEdVocationalBaselineUnitNames,
  q1.spEdAdaptiveDailyLivingBaselineUnitNames,
  q1.spEdSocialEmotionalBehavioralBaselineUnitNames,
  q1.spEdReadingToolsUsedNames,
  q1.spEdWritingToolsUsedNames,
  q1.spEdMathToolsUsedNames,
  q1.spEdCommunicationDevToolsUsedNames,
  q1.spEdGrossFineMotorToolsUsedNames,
  q1.spEdHealthToolsUsedNames,
  q1.spEdVocationalToolsUsedNames,
  q1.spEdAdaptiveDailyLivingToolsUsedNames,
  q1.spEdSocialEmotionalBehavioralToolsUsedNames,
  q1.inTransitionalHousingStatus    ,
  q1.inTransitionalHousingStatusYN  ,
  q1.deceased,
  q1.deceasedYN,
  q1.preferredNickname     ,
  q1.teacherOrCounselorName,
  q1.siteRefID ,
  q1.siteRank   ,  
  q1.siteID    ,
  q1.siteName,
  q1.preferredContactMethodCode

from cte_p2 as q1

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[PATIENTS_VIEW_CORE] TO [webuser]
GO