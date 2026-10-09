USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_IEP_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_IEP_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[PATIENT_IEP_Save] (
    @userID													BIGINT    
  , @userGroup												INT    
  , @userRank												INT
  , @clientID												INT
  , @patID													INT
  , @spEdSpecialTransportation								BIT
  , @spEdLastEvalDate										DATE
  , @spEdLastAnnualIEPDate									DATE
  , @spEdNextAnnualIEPDate									DATE
  , @spEdCurIEPDate											DATE
  , @spEdDisability1Code									INT
  , @spEdDisability2Code									INT
  , @spEdExitedSpEdDate									    date
  , @spEdStudentStrengths								    varchar(max)
  , @spEdParentConcerns										varchar(max)
  , @spEdProgressMonitoringData								varchar(max)
  , @spEdStudentPresentLevelsStatement						varchar(max)
  , @spEdStudentDisabilityAffectsPerformance				bit
  , @spEdCurEligibilityDate									date
  , @spEdInitEligibilityDate								date
  , @spEdIEPAttendeesIdentified								bit
  , @spEdEligibilityReasons									varchar(max)
  , @spEdPlanTranslateToLanguageCodeID						bigint
  , @spEdInitRefDate										date
  , @spEdReferringPartyCode									int
  , @spEdReferringPartyOtherOption							varchar(50)
  , @spEdDistrictReceivedParentConsentDate					date
  , @spEdMeetingPurposeDataJSON								varchar(max)
  , @spEdAdditionalMeetingPurposeDataJSON					varchar(max)
  , @spEdAmendmentReasonsDataJSON							varchar(max)
  , @spEdAmendmentReasonsOtherOption						varchar(max)
  , @spEdMeetingPurposeOtherOption							varchar(max)
  , @spEdFacilitatorUserID									bigint
  , @spEdFacilitatorUserName								varchar(256)
  , @spEdCaseManagerUserID									bigint
  , @spEdCaseManagerUserName								varchar(256)
  , @spEdMeetingDate										date
  , @spEdMeetingDurationInMins								int
  , @spEdMeetingTime										varchar(50)
  , @spEdMeetingTitle										varchar(256)
  , @spEdPlanTypeCode										int
  , @spEdStudentLanguageCodeID								bigint
  , @spEdStudentRaceCode									int 
  , @spEdNextEvalDate										datetime
  , @spEdEnteredSpEdDate                                    datetime
  , @spEdStudentLanguageEnglishLearner						bit
  , @spEdStudentLanguageInfoReclassified					bit
  , @spEdStudentLanguageInterpreterNeeded					bit
  , @spEdStudentLanguageTranslationRequested				bit
  , @spEdStudentLanguageEnglishLearnerUndesignatedPreschool bit
  , @spEdServicesDataJSON								    VARCHAR(max)
  , @spEdTransitionGoalEducation							bit
  , @spEdTransitionGoalTraining								bit
  , @spEdTransitionGoalEmployment							bit
  , @spEdTransitionGoalIndependentLiving					bit
  , @spEdDevAcaFunSkillsReading								varchar(max)
  , @spEdDevAcaFunSkillsWriting								varchar(max)
  , @spEdDevAcaFunSkillsMath								varchar(max)
  , @spEdDevAcaFunSkillsCommunicationDev					varchar(max)
  , @spEdDevAcaFunSkillsGrossFineMotorDev					varchar(max)
  , @spEdDevAcaFunSkillsHealth								varchar(max)
  , @spEdDevAcaFunSkillsVocational							varchar(max)
  , @spEdDevAcaFunSkillsAdaptiveDailyLiving					varchar(max)
  , @spEdDevAcaFunSkillsAreasOfNeccessity					varchar(max)
  , @spEdDevAcaFunSkillsSocialEmotionalBehavioral           varchar(max)    
  , @spEdParticipantDetailsJSON								VARCHAR(max)
  , @spEdProceduralSafeguardsSentDate						DATE
  , @spEdSpecialTransportationComments					    VARCHAR(MAX)
  , @spEdVehicleAdaptationType								INT
  , @speciallyAdaptedVehicleForTransportation				BIT
  , @spEdCorrectionDetails									VARCHAR(MAX)
  , @spEdPreferredLanguageCodeID							BIGINT
  
  , @spEdPresentLevelsDataJSON							    VARCHAR(MAX)
  , @spEdPresentLevelsPreparedBy						    BIGINT
  , @spEdPresentLevelsPreparedByName					    VARCHAR(200)
 
  , @spEdStudentStrengthsSource						        VARCHAR(100)
  , @spEdStudentStrengthsSourceJSON						    VARCHAR(MAX)
  , @spEdStudentStrengthsImpact							    VARCHAR(MAX)
  , @spEdParentConcernsSource							    VARCHAR(100)
  , @spEdParentConcernsSourceJSON						    VARCHAR(MAX)
  , @spEdReadingReviewedNA								    BIT
  , @spEdReadingSource									    VARCHAR(100)
  , @spEdReadingSourceJSON                                  VARCHAR(MAX)
  , @spEdReadingBaselineValue                               VARCHAR(100)
  , @spEdReadingBaselineUnit							    VARCHAR(100)
  , @spEdReadingToolsUsed						 		    VARCHAR(500)
  , @spEdReadingToolsUsedJSON                               VARCHAR(MAX)    
  , @spEdReadingBaselineDate						        DATE
  , @spEdReadingImpactSummary							    VARCHAR(MAX)
  , @spEdWritingReviewedNA								    BIT
  , @spEdWritingSource									    VARCHAR(100)
  , @spEdWritingSourceJSON								    VARCHAR(MAX)
  , @spEdWritingBaselineValue						        VARCHAR(100)
  , @spEdWritingBaselineUnit							    VARCHAR(100)
  , @spEdWritingToolsUsed							        VARCHAR(500)
  , @spEdWritingToolsUsedJSON                               VARCHAR(MAX)    
  , @spEdWritingBaselineDate							    DATE
  , @spEdWritingImpactSummary                               VARCHAR(MAX)
  , @spEdMathReviewedNA									    BIT
  , @spEdMathSource										    VARCHAR(100)
  , @spEdMathSourceJSON									    VARCHAR(MAX)
  , @spEdMathBaselineValue								    VARCHAR(100)
  , @spEdMathBaselineUnit								    VARCHAR(100)
  , @spEdMathToolsUsed									    VARCHAR(500)
  , @spEdMathToolsUsedJSON                                  VARCHAR(MAX)    
  , @spEdMathBaselineDate								    DATE
  , @spEdMathImpactSummary								    VARCHAR(MAX)
  , @spEdCommunicationDevReviewedNA						    BIT
  , @spEdCommunicationDevSource							    VARCHAR(100)
  , @spEdCommunicationDevSourceJSON						    VARCHAR(MAX)
  , @spEdCommunicationDevBaselineValue					    VARCHAR(100)
  , @spEdCommunicationDevBaselineUnit					    VARCHAR(100)
  , @spEdCommunicationDevToolsUsed						    VARCHAR(500)
  , @spEdCommunicationDevToolsUsedJSON                      VARCHAR(MAX)    
  , @spEdCommunicationDevBaselineDate					    DATE
  , @spEdCommunicationDevImpactSummary					    VARCHAR(MAX)

  , @spEdGrossFineMotorReviewedNA						    BIT
  , @spEdGrossFineMotorSource							    VARCHAR(100)
  , @spEdGrossFineMotorSourceJSON						    VARCHAR(MAX)
  , @spEdGrossFineMotorBaselineValue					    VARCHAR(100)
  , @spEdGrossFineMotorBaselineUnit					        VARCHAR(100)
  , @spEdGrossFineMotorToolsUsed						    VARCHAR(500)
  , @spEdGrossFineMotorToolsUsedJSON                        VARCHAR(MAX)    
  , @spEdGrossFineMotorBaselineDate						    DATE
  , @spEdGrossFineMotorImpactSummary					    VARCHAR(MAX)

  , @spEdHealthReviewedNA								    BIT
  , @spEdHealthSource									    VARCHAR(100)
  , @spEdHealthSourceJSON								    VARCHAR(MAX)
  , @spEdHealthBaselineValue							    VARCHAR(100)
  , @spEdHealthBaselineUnit								    VARCHAR(100)
  , @spEdHealthToolsUsed								    VARCHAR(500)
  , @spEdHealthToolsUsedJSON                                VARCHAR(MAX)    
  , @spEdHealthBaselineDate								    DATE
  , @spEdHealthImpactSummary						        VARCHAR(MAX)
	
  , @spEdVocationalReviewedNA							    BIT
  , @spEdVocationalSource								    VARCHAR(100)
  , @spEdVocationalSourceJSON					     	    VARCHAR(MAX)
  , @spEdVocationalBaselineValue						    VARCHAR(100)
  , @spEdVocationalBaselineUnit						        VARCHAR(100)
  , @spEdVocationalToolsUsed							    VARCHAR(500)
  , @spEdVocationalToolsUsedJSON                            VARCHAR(MAX)    
  , @spEdVocationalBaselineDate							    DATE
  , @spEdVocationalImpactSummary			   	  		    VARCHAR(MAX)

  , @spEdAdaptiveDailyLivingReviewedNA				        BIT
  , @spEdAdaptiveDailyLivingSource						    VARCHAR(100)
  , @spEdAdaptiveDailyLivingSourceJSON					    VARCHAR(MAX)
  , @spEdAdaptiveDailyLivingBaselineValue			        VARCHAR(100)
  , @spEdAdaptiveDailyLivingBaselineUnit				    VARCHAR(100)
  , @spEdAdaptiveDailyLivingToolsUsed					    VARCHAR(500)
  , @spEdAdaptiveDailyLivingToolsUsedJSON                   VARCHAR(MAX)    
  , @spEdAdaptiveDailyLivingBaselineDate				    DATE
  , @spEdAdaptiveDailyLivingImpactSummary					VARCHAR(MAX)

  , @spEdSocialEmotionalBehavioralReviewedNA                BIT
  , @spEdSocialEmotionalBehavioralSource                    VARCHAR(100)
  , @spEdSocialEmotionalBehavioralSourceJSON                VARCHAR(MAX)
  , @spEdSocialEmotionalBehavioralBaselineValue             VARCHAR(100)
  , @spEdSocialEmotionalBehavioralBaselineUnit              VARCHAR(100)
  , @spEdSocialEmotionalBehavioralToolsUsed                 VARCHAR(500)
  , @spEdSocialEmotionalBehavioralToolsUsedJSON             VARCHAR(MAX)
  , @spEdSocialEmotionalBehavioralBaselineDate              DATE
  , @spEdSocialEmotionalBehavioralImpactSummary             VARCHAR(MAX)

  , @spEdStudentStrengthsSourceNames					    VARCHAR(MAX)
  , @spEdParentConcernsSourceNames							VARCHAR(MAX)
  , @spEdReadingSourceNames								    VARCHAR(MAX)
  , @spEdWritingSourceNames								    VARCHAR(MAX)
  , @spEdMathSourceNames								    VARCHAR(MAX)
  , @spEdCommunicationDevSourceNames				        VARCHAR(MAX)
  , @spEdGrossFineMotorSourceNames						    VARCHAR(MAX)
  , @spEdHealthSourceNames								    VARCHAR(MAX)
  , @spEdVocationalSourceNames						        VARCHAR(MAX)
  , @spEdAdaptiveDailyLivingSourceNames			            VARCHAR(MAX)
  , @spEdSocialEmotionalBehavioralSourceNames               VARCHAR(MAX)    
  , @spEdReadingBaselineUnitNames					        VARCHAR(256)
  , @spEdWritingBaselineUnitNames						    VARCHAR(256)
  , @spEdMathBaselineUnitNames							    VARCHAR(256)
  , @spEdCommunicationDevBaselineUnitNames				    VARCHAR(256)
  , @spEdGrossFineMotorBaselineUnitNames				    VARCHAR(256)
  , @spEdHealthBaselineUnitNames							VARCHAR(256)
  , @spEdVocationalBaselineUnitNames					    VARCHAR(256)
  , @spEdAdaptiveDailyLivingBaselineUnitNames			    VARCHAR(256)
  , @spEdSocialEmotionalBehavioralBaselineUnitNames         VARCHAR(256)    
  , @spEdReadingToolsUsedNames                              VARCHAR(MAX)    
  , @spEdWritingToolsUsedNames                              VARCHAR(MAX)    
  , @spEdMathToolsUsedNames                                 VARCHAR(MAX)    
  , @spEdCommunicationDevToolsUsedNames                     VARCHAR(MAX)    
  , @spEdGrossFineMotorToolsUsedNames                       VARCHAR(MAX)    
  , @spEdHealthToolsUsedNames                               VARCHAR(MAX)    
  , @spEdVocationalToolsUsedNames                           VARCHAR(MAX)    
  , @spEdAdaptiveDailyLivingToolsUsedNames                  VARCHAR(MAX)    
  , @spEdSocialEmotionalBehavioralToolsUsedNames            VARCHAR(MAX)    
  
  , @editDelReason											VARCHAR(7000)
  , @validateRec											BIT   
  , @saveType												INT   
  , @recID													INT
  , @MsgNoRec												VARCHAR(1000)    
  , @MsgNoEdit												VARCHAR(1000)
  , @MsgNoFullEdit											VARCHAR(1000)       
  , @MsgDupRec												VARCHAR(1000)     
  , @MsgNoClient											VARCHAR(1000)    
  , @MsgNoSite												VARCHAR(1000)    
  , @MsgDataError											VARCHAR(1000)
  , @MsgNotActive											VARCHAR(1000)     
  , @spDetails												VARCHAR(8000) OUTPUT   
  , @recordID												BIGINT        OUTPUT )
AS     
BEGIN     
    
/***************************************************************************    
 * PATIENT_IEP_SAVE */    
/**    
 * Edits existing patient IEP fields
 *    
 * @param   userID                The userid of who saved the record    
 * @param   userGroup             Users group    
 * @param   userRank              User rank    
 * @param   clientID              Patient's client id    
 * @param   patID                 Patient ID (for future use)
 * @param   spEd...               All IEP related fields
 * @param   editDelReason         Reason for record edit or delete    
 * @param   validateRec           1 = Performs data integrity validation tasks    
 *                                0 = Peform data integrity validation tasks and save    
 * @param   saveType              Type of operation to perform (2 = Edit only for now)   
 * @param   recID                 Record id of existing patient record to edit
 * @param   MsgNoRec              Desired error message if a recID is not found    
 * @param   MsgNoEdit             Desired error message if a record cannot be edited    
 * @param   MsgDupRec             Desired error message for duplicate detection    
 * @param   MsgNoClient           Desired error message if a clientID is not found    
 * @param   MsgNoSite             Desired error message if a siteID is not found     
 * @param   MsgDataError          Desired error message for data errors    
 * @returns spDetails             Validation or error details    
 * @returns recordID              Record id of the patient record
 ***************************************************************************/    
    
SET NOCOUNT ON    
     
/*-------------------------------    
 * Declare local variables    
 *------------------------------*/    
     
DECLARE @auditRecID        AS BIGINT  = null    
DECLARE @today             AS DATETIME    
DECLARE @updateState       AS INT    
DECLARE @TranOpen          AS BIT = 0    
DECLARE @errorNum          AS INT    

/*-------------------------------    
 * Init    
 *------------------------------*/    
    
SET @TranOpen     = 0    
SET @spDetails    = ''    
SET @recordID     = @recID    
SET @today        = GETDATE()    

/*-------------------------------    
 * Error handling    
 *------------------------------*/    
    
BEGIN TRY    

/*-------------------------------    
 * Data Validation    
 *------------------------------*/    

-- Validate client exists

IF NOT EXISTS (SELECT top 1 CLIENT_ID FROM dbo.CLIENTS_Client WHERE CLIENT_ID = @clientID)
BEGIN
    RAISERROR (@MsgNoClient, 11, 1)
END

-- Validate patient record exists

IF @saveType = 2 AND NOT EXISTS (SELECT top 1 PATIENT_ID FROM dbo.PATIENTS_Patient WHERE PATIENT_ID = @recID)
BEGIN
    RAISERROR (@MsgNoRec, 11, 1)
END

-- For now, only allow Edit (saveType = 2)

IF @saveType <> 2
BEGIN
    RAISERROR ('PATIENT_IEP_Save only supports edit at this time', 11, 1)
END

/*-------------------------------    
 * If validateRec = 1 then exit    
 * without saving    
 *------------------------------*/    
     
IF @validateRec = 1    
BEGIN    
  SET @spDetails = ''    
  RETURN(0)    
END    

/*-------------------------------    
 * Edit Patient IEP Fields
 *------------------------------*/    

BEGIN TRANSACTION    
SET @TranOpen = 1    

IF @saveType = 2    
BEGIN    

    SET @updateState = 1    

     UPDATE PATIENTS_Patient
     SET
          spEdSpecialTransportation				  = @spEdSpecialTransportation
        , spEdLastEvalDate						  = @spEdLastEvalDate
        , spEdLastAnnualIEPDate					  = @spEdLastAnnualIEPDate
        , spEdNextAnnualIEPDate					  = @spEdNextAnnualIEPDate
        , spEdDisability1Code					  = @spEdDisability1Code
        , spEdDisability2Code					  = @spEdDisability2Code
        , spEdExitedSpEdDate					  = @spEdExitedSpEdDate
		, spEdCurIEPDate                          = @spEdCurIEPDate
		, spEdStudentStrengths                    = @spEdStudentStrengths                  
		, spEdParentConcerns                      = @spEdParentConcerns                   
		, spEdProgressMonitoringData              = @spEdProgressMonitoringData          
		, spEdStudentPresentLevelsStatement       = @spEdStudentPresentLevelsStatement      
		, spEdStudentDisabilityAffectsPerformance = @spEdStudentDisabilityAffectsPerformance
		, spEdCurEligibilityDate                  = @spEdCurEligibilityDate                
		, spEdInitEligibilityDate                 = @spEdInitEligibilityDate               
		, spEdIEPAttendeesIdentified              = @spEdIEPAttendeesIdentified            
		, spEdEligibilityReasons                  = @spEdEligibilityReasons                 
		, spEdPlanTranslateToLanguageCodeID       = @spEdPlanTranslateToLanguageCodeID                         
		, spEdInitRefDate                         = @spEdInitRefDate                        
		, spEdReferringPartyCode                  = @spEdReferringPartyCode                 
		, spEdReferringPartyOtherOption           = @spEdReferringPartyOtherOption          
		, spEdDistrictReceivedParentConsentDate   = @spEdDistrictReceivedParentConsentDate  
		, spEdMeetingPurposeDataJSON              = @spEdMeetingPurposeDataJSON             
		, spEdAdditionalMeetingPurposeDataJSON    = @spEdAdditionalMeetingPurposeDataJSON   
		, spEdAmendmentReasonsDataJSON            = @spEdAmendmentReasonsDataJSON          
		, spEdAmendmentReasonsOtherOption         = @spEdAmendmentReasonsOtherOption
		, spEdMeetingPurposeOtherOption           = @spEdMeetingPurposeOtherOption
		, spEdFacilitatorUserID                   = @spEdFacilitatorUserID
		, spEdFacilitatorUserName                 = @spEdFacilitatorUserName
		, spEdCaseManagerUserID                   = @spEdCaseManagerUserID
		, spEdCaseManagerUserName                 = @spEdCaseManagerUserName
		, spEdMeetingDate                         = @spEdMeetingDate
		, spEdMeetingDurationInMins               = @spEdMeetingDurationInMins
		, spEdMeetingTime                         = @spEdMeetingTime
		, spEdMeetingTitle                        = @spEdMeetingTitle
		, spEdPlanTypeCode                        = @spEdPlanTypeCode
		, spEdStudentLanguageCodeID               = @spEdStudentLanguageCodeID
        , spEdStudentRaceCode                     = @spEdStudentRaceCode   
        , spEdNextEvalDate                        = @spEdNextEvalDate
	    , spEdEnteredSpEdDate                     = @spEdEnteredSpEdDate
		, spEdStudentLanguageEnglishLearner       = @spEdStudentLanguageEnglishLearner
		, spEdStudentLanguageInfoReclassified     = @spEdStudentLanguageInfoReclassified
		, spEdStudentLanguageInterpreterNeeded    = @spEdStudentLanguageInterpreterNeeded
		, spEdStudentLanguageTranslationRequested = @spEdStudentLanguageTranslationRequested
		, spEdStudentLanguageEnglishLearnerUndesignatedPreschool = @spEdStudentLanguageEnglishLearnerUndesignatedPreschool
		, spEdTransitionGoalEducation			  = @spEdTransitionGoalEducation
		, spEdTransitionGoalTraining			  = @spEdTransitionGoalTraining
		, spEdTransitionGoalEmployment			  = @spEdTransitionGoalEmployment
		, spEdTransitionGoalIndependentLiving	  = @spEdTransitionGoalIndependentLiving
		, spEdDevAcaFunSkillsReading			  = @spEdDevAcaFunSkillsReading
		, spEdDevAcaFunSkillsWriting			  = @spEdDevAcaFunSkillsWriting
		, spEdDevAcaFunSkillsMath				  = @spEdDevAcaFunSkillsMath
		, spEdDevAcaFunSkillsCommunicationDev 	  = @spEdDevAcaFunSkillsCommunicationDev
		, spEdDevAcaFunSkillsGrossFineMotorDev	  = @spEdDevAcaFunSkillsGrossFineMotorDev
		, spEdDevAcaFunSkillsHealth				  = @spEdDevAcaFunSkillsHealth
		, spEdDevAcaFunSkillsVocational			  = @spEdDevAcaFunSkillsVocational
		, spEdDevAcaFunSkillsAdaptiveDailyLiving  = @spEdDevAcaFunSkillsAdaptiveDailyLiving
		, spEdDevAcaFunSkillsAreasOfNeccessity	  = @spEdDevAcaFunSkillsAreasOfNeccessity
		, spEdDevAcaFunSkillsSocialEmotionalBehavioral = @spEdDevAcaFunSkillsSocialEmotionalBehavioral 
		, spEdParticipantDetailsJSON			  = @spEdParticipantDetailsJSON
		, spEdServicesDataJSON                    = @spEdServicesDataJSON
		, spEdProceduralSafeguardsSentDate          = @spEdProceduralSafeguardsSentDate
		, spEdSpecialTransportationComments         = @spEdSpecialTransportationComments
		, spEdVehicleAdaptationType                 = @spEdVehicleAdaptationType
		, speciallyAdaptedVehicleForTransportation  = @speciallyAdaptedVehicleForTransportation
		, spEdCorrectionDetails                     = @spEdCorrectionDetails
		, spEdPreferredLanguageCodeID               = @spEdPreferredLanguageCodeID

        , spEdPresentLevelsDataJSON                 = @spEdPresentLevelsDataJSON
		, spEdPresentLevelsPreparedBy               = @spEdPresentLevelsPreparedBy
        , spEdPresentLevelsPreparedByName           = @spEdPresentLevelsPreparedByName
        , spEdStudentStrengthsSource                = @spEdStudentStrengthsSource
        , spEdStudentStrengthsSourceJSON            = @spEdStudentStrengthsSourceJSON
        , spEdStudentStrengthsImpact                = @spEdStudentStrengthsImpact
        , spEdParentConcernsSource                  = @spEdParentConcernsSource
        , spEdParentConcernsSourceJSON              = @spEdParentConcernsSourceJSON
        , spEdReadingReviewedNA                     = @spEdReadingReviewedNA
        , spEdReadingSource                         = @spEdReadingSource
        , spEdReadingSourceJSON                     = @spEdReadingSourceJSON
        , spEdReadingBaselineValue                  = @spEdReadingBaselineValue
        , spEdReadingBaselineUnit                   = @spEdReadingBaselineUnit
        , spEdReadingToolsUsed                      = @spEdReadingToolsUsed
        , spEdReadingToolsUsedJSON                  = @spEdReadingToolsUsedJSON             
        , spEdReadingBaselineDate                   = @spEdReadingBaselineDate
        , spEdReadingImpactSummary                  = @spEdReadingImpactSummary
        , spEdWritingReviewedNA                     = @spEdWritingReviewedNA
        , spEdWritingSource                         = @spEdWritingSource
        , spEdWritingSourceJSON                     = @spEdWritingSourceJSON
        , spEdWritingBaselineValue                  = @spEdWritingBaselineValue
        , spEdWritingBaselineUnit                   = @spEdWritingBaselineUnit
        , spEdWritingToolsUsed                      = @spEdWritingToolsUsed
        , spEdWritingToolsUsedJSON                  = @spEdWritingToolsUsedJSON             
        , spEdWritingBaselineDate                   = @spEdWritingBaselineDate
        , spEdWritingImpactSummary                  = @spEdWritingImpactSummary
        , spEdMathReviewedNA                        = @spEdMathReviewedNA
        , spEdMathSource                            = @spEdMathSource
        , spEdMathSourceJSON                        = @spEdMathSourceJSON
        , spEdMathBaselineValue                     = @spEdMathBaselineValue
        , spEdMathBaselineUnit                      = @spEdMathBaselineUnit
        , spEdMathToolsUsed                         = @spEdMathToolsUsed
        , spEdMathToolsUsedJSON                     = @spEdMathToolsUsedJSON                
        , spEdMathBaselineDate                      = @spEdMathBaselineDate
        , spEdMathImpactSummary                     = @spEdMathImpactSummary

        , spEdCommunicationDevReviewedNA            = @spEdCommunicationDevReviewedNA
        , spEdCommunicationDevSource                = @spEdCommunicationDevSource
        , spEdCommunicationDevSourceJSON            = @spEdCommunicationDevSourceJSON
        , spEdCommunicationDevBaselineValue         = @spEdCommunicationDevBaselineValue
        , spEdCommunicationDevBaselineUnit          = @spEdCommunicationDevBaselineUnit
        , spEdCommunicationDevToolsUsed             = @spEdCommunicationDevToolsUsed
        , spEdCommunicationDevToolsUsedJSON         = @spEdCommunicationDevToolsUsedJSON    
        , spEdCommunicationDevBaselineDate          = @spEdCommunicationDevBaselineDate
        , spEdCommunicationDevImpactSummary         = @spEdCommunicationDevImpactSummary
          
		, spEdGrossFineMotorReviewedNA              = @spEdGrossFineMotorReviewedNA
        , spEdGrossFineMotorSource                  = @spEdGrossFineMotorSource
        , spEdGrossFineMotorSourceJSON              = @spEdGrossFineMotorSourceJSON
        , spEdGrossFineMotorBaselineValue           = @spEdGrossFineMotorBaselineValue
        , spEdGrossFineMotorBaselineUnit            = @spEdGrossFineMotorBaselineUnit
        , spEdGrossFineMotorToolsUsed               = @spEdGrossFineMotorToolsUsed
        , spEdGrossFineMotorToolsUsedJSON           = @spEdGrossFineMotorToolsUsedJSON      
        , spEdGrossFineMotorBaselineDate            = @spEdGrossFineMotorBaselineDate
        , spEdGrossFineMotorImpactSummary           = @spEdGrossFineMotorImpactSummary

        , spEdHealthReviewedNA                      = @spEdHealthReviewedNA
        , spEdHealthSource                          = @spEdHealthSource
        , spEdHealthSourceJSON                      = @spEdHealthSourceJSON
        , spEdHealthBaselineValue                   = @spEdHealthBaselineValue
        , spEdHealthBaselineUnit                    = @spEdHealthBaselineUnit
        , spEdHealthToolsUsed                       = @spEdHealthToolsUsed
        , spEdHealthToolsUsedJSON                   = @spEdHealthToolsUsedJSON              
        , spEdHealthBaselineDate                    = @spEdHealthBaselineDate
        , spEdHealthImpactSummary                   = @spEdHealthImpactSummary

        , spEdVocationalReviewedNA                  = @spEdVocationalReviewedNA
        , spEdVocationalSource                      = @spEdVocationalSource
        , spEdVocationalSourceJSON                  = @spEdVocationalSourceJSON
        , spEdVocationalBaselineValue               = @spEdVocationalBaselineValue
        , spEdVocationalBaselineUnit                = @spEdVocationalBaselineUnit
        , spEdVocationalToolsUsed                   = @spEdVocationalToolsUsed
        , spEdVocationalToolsUsedJSON               = @spEdVocationalToolsUsedJSON          
        , spEdVocationalBaselineDate                = @spEdVocationalBaselineDate
        , spEdVocationalImpactSummary               = @spEdVocationalImpactSummary

        , spEdAdaptiveDailyLivingReviewedNA         = @spEdAdaptiveDailyLivingReviewedNA
        , spEdAdaptiveDailyLivingSource             = @spEdAdaptiveDailyLivingSource
        , spEdAdaptiveDailyLivingSourceJSON         = @spEdAdaptiveDailyLivingSourceJSON
        , spEdAdaptiveDailyLivingBaselineValue      = @spEdAdaptiveDailyLivingBaselineValue
        , spEdAdaptiveDailyLivingBaselineUnit       = @spEdAdaptiveDailyLivingBaselineUnit
        , spEdAdaptiveDailyLivingToolsUsed          = @spEdAdaptiveDailyLivingToolsUsed
        , spEdAdaptiveDailyLivingToolsUsedJSON      = @spEdAdaptiveDailyLivingToolsUsedJSON  
        , spEdAdaptiveDailyLivingBaselineDate       = @spEdAdaptiveDailyLivingBaselineDate
        , spEdAdaptiveDailyLivingImpactSummary      = @spEdAdaptiveDailyLivingImpactSummary

        , spEdSocialEmotionalBehavioralReviewedNA     = @spEdSocialEmotionalBehavioralReviewedNA
        , spEdSocialEmotionalBehavioralSource         = @spEdSocialEmotionalBehavioralSource
        , spEdSocialEmotionalBehavioralSourceJSON     = @spEdSocialEmotionalBehavioralSourceJSON
        , spEdSocialEmotionalBehavioralBaselineValue  = @spEdSocialEmotionalBehavioralBaselineValue
        , spEdSocialEmotionalBehavioralBaselineUnit   = @spEdSocialEmotionalBehavioralBaselineUnit
        , spEdSocialEmotionalBehavioralToolsUsed      = @spEdSocialEmotionalBehavioralToolsUsed
        , spEdSocialEmotionalBehavioralToolsUsedJSON  = @spEdSocialEmotionalBehavioralToolsUsedJSON
        , spEdSocialEmotionalBehavioralBaselineDate   = @spEdSocialEmotionalBehavioralBaselineDate
        , spEdSocialEmotionalBehavioralImpactSummary  = @spEdSocialEmotionalBehavioralImpactSummary
		
        , spEdStudentStrengthsSourceNames         = @spEdStudentStrengthsSourceNames
        , spEdParentConcernsSourceNames           = @spEdParentConcernsSourceNames
        , spEdReadingSourceNames                  = @spEdReadingSourceNames
        , spEdWritingSourceNames                  = @spEdWritingSourceNames
        , spEdMathSourceNames                     = @spEdMathSourceNames
        , spEdCommunicationDevSourceNames         = @spEdCommunicationDevSourceNames
        , spEdGrossFineMotorSourceNames           = @spEdGrossFineMotorSourceNames
        , spEdHealthSourceNames                   = @spEdHealthSourceNames
        , spEdVocationalSourceNames               = @spEdVocationalSourceNames
        , spEdAdaptiveDailyLivingSourceNames      = @spEdAdaptiveDailyLivingSourceNames
        , spEdSocialEmotionalBehavioralSourceNames = @spEdSocialEmotionalBehavioralSourceNames  
        , spEdReadingBaselineUnitNames             = @spEdReadingBaselineUnitNames
        , spEdWritingBaselineUnitNames             = @spEdWritingBaselineUnitNames
        , spEdMathBaselineUnitNames                = @spEdMathBaselineUnitNames
        , spEdCommunicationDevBaselineUnitNames    = @spEdCommunicationDevBaselineUnitNames
        , spEdGrossFineMotorBaselineUnitNames      = @spEdGrossFineMotorBaselineUnitNames
        , spEdHealthBaselineUnitNames              = @spEdHealthBaselineUnitNames
        , spEdVocationalBaselineUnitNames          = @spEdVocationalBaselineUnitNames
        , spEdAdaptiveDailyLivingBaselineUnitNames = @spEdAdaptiveDailyLivingBaselineUnitNames
        , spEdSocialEmotionalBehavioralBaselineUnitNames = @spEdSocialEmotionalBehavioralBaselineUnitNames 
        , spEdReadingToolsUsedNames               = @spEdReadingToolsUsedNames
        , spEdWritingToolsUsedNames               = @spEdWritingToolsUsedNames
        , spEdMathToolsUsedNames                  = @spEdMathToolsUsedNames
        , spEdCommunicationDevToolsUsedNames      = @spEdCommunicationDevToolsUsedNames
        , spEdGrossFineMotorToolsUsedNames        = @spEdGrossFineMotorToolsUsedNames
        , spEdHealthToolsUsedNames                = @spEdHealthToolsUsedNames
        , spEdVocationalToolsUsedNames            = @spEdVocationalToolsUsedNames
        , spEdAdaptiveDailyLivingToolsUsedNames   = @spEdAdaptiveDailyLivingToolsUsedNames
        , spEdSocialEmotionalBehavioralToolsUsedNames = @spEdSocialEmotionalBehavioralToolsUsedNames
		
                      
     WHERE 
        PATIENT_ID = @recordID        
                          
END    
       
/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
    
COMMIT TRANSACTION    
SET @TranOpen = 0    
RETURN(0)    
END TRY    
BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PATIENT_IEP_Save] TO [webuser]
GO