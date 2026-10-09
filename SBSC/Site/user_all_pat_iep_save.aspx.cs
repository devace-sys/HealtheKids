using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MBA;
using System.Collections.Generic;

namespace Spedmon
{
    public class UserAllPatientIEPSave : WebUI
    {
        public UserAllPatientIEPSave() : base("patient_iep_save"
                                             , "Patient IEP Management"
                                             , "user_all_pat_save_2.css|user_all_patient_goal_progress_reporting.css|patient-profile.css|iep-accordion.css|iep_accommodation.css|jquery-mba-grid-iep-meeting-history.css|jquery-mba-sped-meeting-iep-grid.css"
                                             , "patient-goals.js|form-builder-patient-goal.js|user_all_patient_goal_progress_reporting.js|patient-profile.js|jquery-mba-image-uploader-cropper.js|iep-accordion.js|patient-promised-services.js|iep_accommodation.js|jquery-mba-grid-iep-meeting-history.js|jquery-mba-sped-meeting-iep-grid.js"
                                             , Constants.ROLE_ALL_PCAL_AND_CLIENT)
        { }

        public string  recID                         = "";
        public string  saveType                      = "";
        public int     saveTypeVal                   = Constants.SAVE_TYPE_EDIT;
        public string  tabToOpen                     = "";
        public string  showContentOnlyParm           = "0";
        public string  appModeParm                   = "";
        public bool    isPCalStaff                   = false;
        public string  isPcalStaffJSBoolStr          = "";
        public bool    isPrac                        = false;
        public string  clientID                      = "";
        public string  patID                         = "";
        public string  pracID                        = "";
        public string  groupID                       = "";
        public string  pracGrpSvcClassNameID         = "";
        public string  pracPatCaseloadExpectedSvcID  = "";
        public string  patientSaveURL                = "";
        public string  urlPracPatReferal             = "";
        public string  urlViewAllPatientGoalsProgress = "";
        public string  urlViewPatientGoalsProgress   = "";
        public string  urlGetPatientProfile          = "";
        public string  urlSavePatientProfile         = "";
        public bool    canStartNewVisit              = false;
        public bool    canReferPatient               = false;
        public string  spedDisability1Text           = "";
        public string  spedDisability2Text           = "";
        public string  meetingHistoryJSON            = "[]";
        public string editingUserName                = "";


        public string urlUserMessagesSave            = @"";
        public string urlRecipientSrc                = @"";




        private class HistoryParticipantData
        {
            public string name = "";
            public string title = "";
            public string email = "";
            public bool? inviteRsvpWillAttend;
            public string inviteRsvpNotes = "";
            public string phone = "";
        }

        private class HistorySessionData
        {
            public long id;
            public string meetingDateStr = "";
            public string meetingTimeStr = "";
            public string meetingCompletionStatus = "";
            public string meetingNotes = "";
            public string dateSent = "";
        }



        public Patient p = new Patient();

        protected void Page_Load(object sender, EventArgs e)
        {
            /*##########################################################################
              # Get parameters
              ###########################################################################*/

            recID                        = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
            tabToOpen                    = MBA.HttpApplication.getParameter(Constants.PARM_TAB_TO_OPEN);
            pracPatCaseloadExpectedSvcID = MBA.HttpApplication.getParameter(Constants.PARM_PRAC_PAT_CASELOAD_EXPECTED_SVC_ID);
            showContentOnlyParm          = MBA.HttpApplication.getParameter(Constants.PARM_CONTENT_ONLY);
            appModeParm                  = MBA.HttpApplication.getParameter(Constants.PARM_APP_MODE);
            clientID                     = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);


            saveType    = Constants.SAVE_TYPE_EDIT.ToString();
            saveTypeVal = Constants.SAVE_TYPE_EDIT;

            /*##########################################################################
              # Validate we have a record ID
              ###########################################################################*/

            if (String.IsNullOrEmpty(recID) || recID == "0")
            {
                throw new Exception("Patient ID is required for IEP management");
            }

            /*##########################################################################
              # Determine if user is pcal staff or prac
              ###########################################################################*/

            isPCalStaff         = uInfo.pcalStaff;
            isPcalStaffJSBoolStr = Util.netBoolToJSBool(isPCalStaff);
            isPrac              = (uInfo.userRole.ToLower() == Constants.ROLE_LEA_PROVIDER) ? true : false;
            editingUserName     = rd.wu.usr.firstName + " " + rd.wu.usr.lastName;
            /*##########################################################################
              # Get control references
              ###########################################################################*/

            DataEntryRowSaveOrEdit ctrlSaveOrEdit = findControlRecu(this.Page, "saveOrEdit") as DataEntryRowSaveOrEdit;

            var ctrlClientID             = findControlRecu(this.Page, Constants.PARM_CLIENT_ID)       as MBA.HiddenInput;
            var ctrlGroupID              = findControlRecu(this.Page, Constants.PARM_GROUP_ID)        as MBA.HiddenInput;
            var ctrlPracID               = findControlRecu(this.Page, Constants.PARM_PRACTITIONER_ID) as MBA.HiddenInput;
            var ctrlPracGroupSvcClassNameID = findControlRecu(this.Page, "groupserviceclassnameid")   as MBA.HiddenInput;
            var ctrlPatID                = findControlRecu(this.Page, Constants.PARM_PATIENT_ID)      as MBA.HiddenInput;
            var ctrlSiteID               = findControlRecu(this.Page, Constants.PARM_SITE_ID)         as MBA.HiddenInput;
            //var ctrlRecID              = findControlRecu(this.Page, Constants.PARM_REC_ID)          as MBA.HiddenInput;
            //var ctrlSaveType           = findControlRecu(this.Page, Constants.PARM_SAVE_TYPE)       as MBA.HiddenInput;

            // IEP-specific controls - DATES
            //var ctrlSpedCaseManagerName   = findControlRecu(this.Page, "spedcasemanagername")   as DataEntryBoxText;
            var ctrlSelectCaseManager       = findControlRecu(this.Page, "selectspedcasemanager")  as DataEntryRowSelectUser;
            var ctrlSpedCasemanagerUserName = findControlRecu(this.Page, "spedcasemanagerusername") as MBA.HiddenInput;
            var ctrlSpEdNextEvalDate        = findControlRecu(this.Page, "spednextevaldate")        as MBA.DataEntryBoxDate;
            var ctrlSpedLastAnnualIEPDate   = findControlRecu(this.Page, "spedlastannualiepdate")   as DataEntryBoxDate;
            var ctrlSpedCurIEPDate          = findControlRecu(this.Page, "spedcuriepdate")          as DataEntryBoxDate;
            var ctrlSpedNextAnnualIEPDate   = findControlRecu(this.Page, "spednextannualiepdate")   as DataEntryBoxDate;
            var ctrlSpEdEnteredSpEdDate     = findControlRecu(this.Page, "spedenteredspeddate")     as MBA.DataEntryBoxDate;
            var ctrlSpedExitedSpEdDate      = findControlRecu(this.Page, "spedexitedspeddate")      as DataEntryBoxDate;

            // Overview tab controls
            var ctrlSelectDisability1Code      = findControlRecu(this.Page, "SelectDisability1Code")              as DataEntryRowSelectSpEdDisabilityCode;
            var ctrlSelectDisability2Code      = findControlRecu(this.Page, "SelectDisability2Code")              as DataEntryRowSelectSpEdDisabilityCode;
            var ctrlSpedSpecialTransportation  = findControlRecu(this.Page, "spedspecialtransportation")          as SelectYesOrNo;
            var ctrlSpeciallyAdaptedVehicle    = findControlRecu(this.Page, "speciallyAdaptedVehicleForTransportation") as MBA.CheckBox;
            var ctrlSelectStudentLanguageCode  = findControlRecu(this.Page, "dataEntryRowSelectStudentLanguageCode") as DataEntryRowSelectSpEdLanguage;
            var ctrlSelectStudentRace          = findControlRecu(this.Page, "spedstudentracecode")                as MBA.ComboBox;
            var ctrlSpedServicesDataJSON       = findControlRecu(this.Page, "spedservicesdatajson")               as HiddenTextArea;

            // Language information controls
            var ctrlSpedStudentLanguageEnglishLearner                    = findControlRecu(this.Page, "spedstudentlanguageenglishlearner")                    as SelectYesOrNo;
            var ctrlSpedStudentLanguageInfoReclassified                  = findControlRecu(this.Page, "spedstudentlanguageinforeclassified")                  as MBA.CheckBox;
            var ctrlSpedStudentLanguageEnglishLearnerUndesignatedPreschool = findControlRecu(this.Page, "spedstudentlanguageenglishlearnerundesignatedpreschool") as SelectYesOrNo;
            var ctrlSpedStudentLanguageInterpreterNeeded                 = findControlRecu(this.Page, "spedstudentlanguageinterpreterneeded")                 as SelectYesOrNo;
            var ctrlSpedStudentLanguageTranslationRequested              = findControlRecu(this.Page, "spedstudentlanguagetranslationrequested")              as SelectYesOrNo;

            // Meeting purpose tab controls
            var ctrlSpedInitRefDate                        = findControlRecu(this.Page, "spedinitrefdate")                        as DataEntryBoxDate;
            var ctrlDataEntryRowSelectSpEdReferringParty   = findControlRecu(this.Page, "DataEntryRowSelectSpEdReferringParty")   as DataEntryRowSelectSpEdReferringParty;
            var ctrlSpedReferringPartyOtherOption          = findControlRecu(this.Page, "spedreferringpartyotheroption")          as DataEntryBoxText;
            var ctrlSpedDistrictReceivedParentConsentDate  = findControlRecu(this.Page, "speddistrictreceivedparentconsentdate")  as DataEntryBoxDate;
            var ctrlSpedMeetingPurposeDataJSON             = findControlRecu(this.Page, "spedmeetingpurposedatajson")             as HiddenTextArea;
            var ctrlDataEntryRowSelectSpEdPlanType         = findControlRecu(this.Page, "DataEntryRowSelectSpEdPlanType")         as DataEntryRowSelectSpEdPlanType;
            var ctrlSpedAdditionalMeetingPurposeDataJSON   = findControlRecu(this.Page, "spedadditionalmeetingpurposedatajson")   as HiddenTextArea;
            var ctrlSpedAmendmentReasonsDataJSON           = findControlRecu(this.Page, "spedamendmentreasonsdatajson")           as HiddenTextArea;

            // Present levels tab controls
            var ctrlSpedStudentStrengths                      = findControlRecu(this.Page, "spedstudentstrengths")                      as RichTextAreaBox;
            var ctrlSpedParentConcerns                        = findControlRecu(this.Page, "spedparentconcerns")                        as RichTextAreaBox;
            var ctrlSpedDevAcaFunSkillsReading                = findControlRecu(this.Page, "speddevacafunskillsreading")                as RichTextAreaBox;
            var ctrlSpedDevAcaFunSkillsWriting                = findControlRecu(this.Page, "speddevacafunskillswriting")                as RichTextAreaBox;
            var ctrlSpedDevAcaFunSkillsMath                   = findControlRecu(this.Page, "speddevacafunskillsmath")                   as RichTextAreaBox;
            var ctrlSpedDevAcaFunSkillsCommunicationDev       = findControlRecu(this.Page, "speddevacafunskillscommunicationdev")       as RichTextAreaBox;
            var ctrlSpedDevAcaFunSkillsGrossFineMotorDev      = findControlRecu(this.Page, "speddevacafunskillsgrossfinemotordev")      as RichTextAreaBox;
            var ctrlSpedDevAcaFunSkillsHealth                 = findControlRecu(this.Page, "speddevacafunskillshealth")                 as RichTextAreaBox;
            var ctrlSpedDevAcaFunSkillsVocational             = findControlRecu(this.Page, "speddevacafunskillsvocational")             as RichTextAreaBox;
            var ctrlSpedDevAcaFunSkillsAdaptiveDailyLiving    = findControlRecu(this.Page, "speddevacafunskillsadaptivedailyliving")    as RichTextAreaBox;
            var ctrlSpedDevAcaFunSkillsAreasOfNeccessity      = findControlRecu(this.Page, "speddevacafunskillsareasofneccessity")      as RichTextAreaBox;
            var ctrlSpedDevAcaFunSkillsSocialEmotionalBehavioral = findControlRecu(this.Page, "speddevacafunskillssocialemotionalbehavioral") as RichTextAreaBox;
            var ctrlSpedProgressMonitoringData                = findControlRecu(this.Page, "spedprogressmonitoringdata")                as RichTextAreaBox;
            var ctrlSpedStudentPresentLevelsStatement         = findControlRecu(this.Page, "spedstudentpresentlevelsstatement")         as RichTextAreaBox;

            // Eligibility information tab controls
            var ctrlSpedStudentDisabilityAffectsPerformance = findControlRecu(this.Page, "spedstudentdisabilityaffectsperformance") as SelectYesOrNo;
            var ctrlSpedCurEligibilityDate                  = findControlRecu(this.Page, "spedcureligibilitydate")                  as DataEntryBoxDate;
            var ctrlSpedInitEligibilityDate                 = findControlRecu(this.Page, "spediniteligibilitydate")                 as DataEntryBoxDate;
            var ctrlSpedIEPAttendeesIdentified              = findControlRecu(this.Page, "spediepattendeesidentified")              as SelectYesOrNo;
            var ctrlSpedEligibilityReasons                  = findControlRecu(this.Page, "spedeligibilityreasons")                  as RichTextAreaBox;
            var ctrlSelectSpEdLanguageToTranslatePlanTo     = findControlRecu(this.Page, "selectSpEdLangaugeToTranslatePlanTo")     as DataEntryRowSelectSpEdLanguage;

            // Goals tab controls
            var ctrlSpedTransitionGoalEducation       = findControlRecu(this.Page, "spedtransitiongoaleducation")       as MBA.CheckBox;
            var ctrlSpedTransitionGoalTraining        = findControlRecu(this.Page, "spedtransitiongoaltraining")        as MBA.CheckBox;
            var ctrlSpedTransitionGoalEmployment      = findControlRecu(this.Page, "spedtransitiongoalemployment")      as MBA.CheckBox;
            var ctrlSpedTransitionGoalIndependentLiving = findControlRecu(this.Page, "spedtransitiongoalindependentliving") as MBA.CheckBox;

            var ctrlSpedProceduralSafeguardsSentDate   = findControlRecu(this.Page, "spedproceduralsafeguardssentdate")   as DataEntryBoxDate;
            var ctrlSpedSpecialTransportationComments  = findControlRecu(this.Page, "spedspecialtransportationcomments")  as DataEntryBoxTextArea;
            var ctrlSpedVehicleAdaptationType          = findControlRecu(this.Page, "spedvehicleadaptationtype")          as MBA.ComboBox;
            var ctrlSpedCorrectionDetails              = findControlRecu(this.Page, "spedcorrectiondetails")              as DataEntryBoxTextArea;
            var ctrlSelectPreferredLanguage            = findControlRecu(this.Page, "dataEntryRowSelectPreferredLanguage") as DataEntryRowSelectSpEdLanguage;

            // Present Levels - Main/Hidden fields
            var ctrlSpedPresentLevelsDataJSON       = findControlRecu(this.Page, "spedpresentlevelsdatajson")       as HiddenTextArea;
            var ctrlSpedPresentLevelsPreparedBy     = findControlRecu(this.Page, "spedpresentlevelspreparedby")     as MBA.HiddenInput;
            var ctrlSpedPresentLevelsPreparedByName = findControlRecu(this.Page, "spedpresentlevelspreparedbyname") as MBA.HiddenInput;

            // Student Strengths
            var ctrlSpedStudentStrengthsSourceJSON = findControlRecu(this.Page, "spedstudentstrengthssourcejson") as HiddenTextArea;
            var ctrlSpedStudentStrengthsImpact     = findControlRecu(this.Page, "spedstudentstrengthsimpact")     as RichTextAreaBox;

            // Parent Concerns
            var ctrlSpedParentConcernsSourceJSON = findControlRecu(this.Page, "spedparentconcernssourcejson") as HiddenTextArea;

            // Reading Domain
            var ctrlSpedReadingReviewedNA    = findControlRecu(this.Page, "spedreadingreviewedna")    as MBA.CheckBox;
            var ctrlSpedReadingSourceJSON    = findControlRecu(this.Page, "spedreadingsourcejson")    as HiddenTextArea;
            var ctrlSpedReadingBaselineValue = findControlRecu(this.Page, "spedreadingbaselinevalue") as DataEntryBoxText;
            var ctrlSpedReadingBaselineUnit  = findControlRecu(this.Page, "spedreadingbaselineunit")  as MBA.ComboBoxMultiSelect;
            var ctrlSpedReadingToolsUsed     = findControlRecu(this.Page, "spedreadingtoolsused")     as MBA.ComboBoxMultiSelect;
            var ctrlSpedReadingToolsUsedJSON = findControlRecu(this.Page, "spedreadingtoolsusedjson") as HiddenTextArea;
            var ctrlSpedReadingBaselineDate  = findControlRecu(this.Page, "spedreadingbaselinedate")  as DataEntryBoxDate;
            var ctrlSpedReadingImpactSummary = findControlRecu(this.Page, "spedreadingimpactsummary") as RichTextAreaBox;

            // Writing Domain
            var ctrlSpedWritingReviewedNA    = findControlRecu(this.Page, "spedwritingreviewedna")    as MBA.CheckBox;
            var ctrlSpedWritingSourceJSON    = findControlRecu(this.Page, "spedwritingsourcejson")    as HiddenTextArea;
            var ctrlSpedWritingBaselineValue = findControlRecu(this.Page, "spedwritingbaselinevalue") as DataEntryBoxText;
            var ctrlSpedWritingBaselineUnit  = findControlRecu(this.Page, "spedwritingbaselineunit")  as MBA.ComboBoxMultiSelect;
            var ctrlSpedWritingToolsUsed     = findControlRecu(this.Page, "spedwritingtoolsused")     as MBA.ComboBoxMultiSelect;
            var ctrlSpedWritingToolsUsedJSON = findControlRecu(this.Page, "spedwritingtoolsusedjson") as HiddenTextArea;
            var ctrlSpedWritingBaselineDate  = findControlRecu(this.Page, "spedwritingbaselinedate")  as DataEntryBoxDate;
            var ctrlSpedWritingImpactSummary = findControlRecu(this.Page, "spedwritingimpactsummary") as RichTextAreaBox;

            // Math Domain
            var ctrlSpedMathReviewedNA    = findControlRecu(this.Page, "spedmathreviewedna")    as MBA.CheckBox;
            var ctrlSpedMathSourceJSON    = findControlRecu(this.Page, "spedmathsourcejson")    as HiddenTextArea;
            var ctrlSpedMathBaselineValue = findControlRecu(this.Page, "spedmathbaselinevalue") as DataEntryBoxText;
            var ctrlSpedMathBaselineUnit  = findControlRecu(this.Page, "spedmathbaselineunit")  as MBA.ComboBoxMultiSelect;
            var ctrlSpedMathToolsUsed     = findControlRecu(this.Page, "spedmathtoolsused")     as MBA.ComboBoxMultiSelect;
            var ctrlSpedMathToolsUsedJSON = findControlRecu(this.Page, "spedmathtoolsusedjson") as HiddenTextArea;
            var ctrlSpedMathBaselineDate  = findControlRecu(this.Page, "spedmathbaselinedate")  as DataEntryBoxDate;
            var ctrlSpedMathImpactSummary = findControlRecu(this.Page, "spedmathimpactsummary") as RichTextAreaBox;

            // Communication Development Domain
            var ctrlSpedCommunicationDevReviewedNA    = findControlRecu(this.Page, "spedcommunicationdevreviewedna")    as MBA.CheckBox;
            var ctrlSpedCommunicationDevSourceJSON    = findControlRecu(this.Page, "spedcommunicationdevsourcejson")    as HiddenTextArea;
            var ctrlSpedCommunicationDevBaselineValue = findControlRecu(this.Page, "spedcommunicationdevbaselinevalue") as DataEntryBoxText;
            var ctrlSpedCommunicationDevBaselineUnit  = findControlRecu(this.Page, "spedcommunicationdevbaselineunit")  as MBA.ComboBoxMultiSelect;
            var ctrlSpedCommunicationDevToolsUsed     = findControlRecu(this.Page, "spedcommunicationdevtoolsused")     as MBA.ComboBoxMultiSelect;
            var ctrlSpedCommunicationDevToolsUsedJSON = findControlRecu(this.Page, "spedcommunicationdevtoolsusedjson") as HiddenTextArea;
            var ctrlSpedCommunicationDevBaselineDate  = findControlRecu(this.Page, "spedcommunicationdevbaselinedate")  as DataEntryBoxDate;
            var ctrlSpedCommunicationDevImpactSummary = findControlRecu(this.Page, "spedcommunicationdevimpactsummary") as RichTextAreaBox;

            // Gross/Fine Motor Domain
            var ctrlSpedGrossFineMotorReviewedNA    = findControlRecu(this.Page, "spedgrossfinemotorreviewedna")    as MBA.CheckBox;
            var ctrlSpedGrossFineMotorSourceJSON    = findControlRecu(this.Page, "spedgrossfinemotorsourcejson")    as HiddenTextArea;
            var ctrlSpedGrossFineMotorBaselineValue = findControlRecu(this.Page, "spedgrossfinemotorbaselinevalue") as DataEntryBoxText;
            var ctrlSpedGrossFineMotorBaselineUnit  = findControlRecu(this.Page, "spedgrossfinemotorbaselineunit")  as MBA.ComboBoxMultiSelect;
            var ctrlSpedGrossFineMotorToolsUsed     = findControlRecu(this.Page, "spedgrossfinemotortoolsused")     as MBA.ComboBoxMultiSelect;
            var ctrlSpedGrossFineMotorToolsUsedJSON = findControlRecu(this.Page, "spedgrossfinemotortoolsusedjson") as HiddenTextArea;
            var ctrlSpedGrossFineMotorBaselineDate  = findControlRecu(this.Page, "spedgrossfinemotorbaselinedate")  as DataEntryBoxDate;
            var ctrlSpedGrossFineMotorImpactSummary = findControlRecu(this.Page, "spedgrossfinemotorimpactsummary") as RichTextAreaBox;

            // Health Domain
            var ctrlSpedHealthReviewedNA    = findControlRecu(this.Page, "spedhealthreviewedna")    as MBA.CheckBox;
            var ctrlSpedHealthSourceJSON    = findControlRecu(this.Page, "spedhealthsourcejson")    as HiddenTextArea;
            var ctrlSpedHealthBaselineValue = findControlRecu(this.Page, "spedhealthbaselinevalue") as DataEntryBoxText;
            var ctrlSpedHealthBaselineUnit  = findControlRecu(this.Page, "spedhealthbaselineunit")  as MBA.ComboBoxMultiSelect;
            var ctrlSpedHealthToolsUsed     = findControlRecu(this.Page, "spedhealthtoolsused")     as MBA.ComboBoxMultiSelect;
            var ctrlSpedHealthToolsUsedJSON = findControlRecu(this.Page, "spedhealthtoolsusedjson") as HiddenTextArea;
            var ctrlSpedHealthBaselineDate  = findControlRecu(this.Page, "spedhealthbaselinedate")  as DataEntryBoxDate;
            var ctrlSpedHealthImpactSummary = findControlRecu(this.Page, "spedhealthimpactsummary") as RichTextAreaBox;

            // Vocational Domain
            var ctrlSpedVocationalReviewedNA    = findControlRecu(this.Page, "spedvocationalreviewedna")    as MBA.CheckBox;
            var ctrlSpedVocationalSourceJSON    = findControlRecu(this.Page, "spedvocationalsourcejson")    as HiddenTextArea;
            var ctrlSpedVocationalBaselineValue = findControlRecu(this.Page, "spedvocationalbaselinevalue") as DataEntryBoxText;
            var ctrlSpedVocationalBaselineUnit  = findControlRecu(this.Page, "spedvocationalbaselineunit")  as MBA.ComboBoxMultiSelect;
            var ctrlSpedVocationalToolsUsed     = findControlRecu(this.Page, "spedvocationaltoolsused")     as MBA.ComboBoxMultiSelect;
            var ctrlSpedVocationalToolsUsedJSON = findControlRecu(this.Page, "spedvocationaltoolsusedjson") as HiddenTextArea;
            var ctrlSpedVocationalBaselineDate  = findControlRecu(this.Page, "spedvocationalbaselinedate")  as DataEntryBoxDate;
            var ctrlSpedVocationalImpactSummary = findControlRecu(this.Page, "spedvocationalimpactsummary") as RichTextAreaBox;

            // Adaptive/Daily Living Domain
            var ctrlSpedAdaptiveDailyLivingReviewedNA    = findControlRecu(this.Page, "spedadaptivedailylivingreviewedna")    as MBA.CheckBox;
            var ctrlSpedAdaptiveDailyLivingSourceJSON    = findControlRecu(this.Page, "spedadaptivedailylivingsourcejson")    as HiddenTextArea;
            var ctrlSpedAdaptiveDailyLivingBaselineValue = findControlRecu(this.Page, "spedadaptivedailylivingbaselinevalue") as DataEntryBoxText;
            var ctrlSpedAdaptiveDailyLivingBaselineUnit  = findControlRecu(this.Page, "spedadaptivedailylivingbaselineunit")  as MBA.ComboBoxMultiSelect;
            var ctrlSpedAdaptiveDailyLivingToolsUsed     = findControlRecu(this.Page, "spedadaptivedailylivingtoolsused")     as MBA.ComboBoxMultiSelect;
            var ctrlSpedAdaptiveDailyLivingToolsUsedJSON = findControlRecu(this.Page, "spedadaptivedailylivingtoolsusedjson") as HiddenTextArea;
            var ctrlSpedAdaptiveDailyLivingBaselineDate  = findControlRecu(this.Page, "spedadaptivedailylivingbaselinedate")  as DataEntryBoxDate;
            var ctrlSpedAdaptiveDailyLivingImpactSummary = findControlRecu(this.Page, "spedadaptivedailylivingimpactsummary") as RichTextAreaBox;

            // Social/Emotional/Behavioral Domain
            var ctrlSpedSocialEmotionalBehavioralReviewedNA    = findControlRecu(this.Page, "spedsocialemotionalbehavioralreviewedna")    as MBA.CheckBox;
            var ctrlSpedSocialEmotionalBehavioralSourceJSON    = findControlRecu(this.Page, "spedsocialemotionalbehavioralsourcejson")    as HiddenTextArea;
            var ctrlSpedSocialEmotionalBehavioralBaselineValue = findControlRecu(this.Page, "spedsocialemotionalbehavioralbaselinevalue") as DataEntryBoxText;
            var ctrlSpedSocialEmotionalBehavioralBaselineUnit  = findControlRecu(this.Page, "spedsocialemotionalbehavioralbaselineunit")  as MBA.ComboBoxMultiSelect;
            var ctrlSpedSocialEmotionalBehavioralToolsUsed     = findControlRecu(this.Page, "spedsocialemotionalbehavioraltoolsused")     as MBA.ComboBoxMultiSelect;
            var ctrlSpedSocialEmotionalBehavioralToolsUsedJSON = findControlRecu(this.Page, "spedsocialemotionalbehavioraltoolsusedjson") as HiddenTextArea;
            var ctrlSpedSocialEmotionalBehavioralBaselineDate  = findControlRecu(this.Page, "spedsocialemotionalbehavioralbaselinedate")  as DataEntryBoxDate;
            var ctrlSpedSocialEmotionalBehavioralImpactSummary = findControlRecu(this.Page, "spedsocialemotionalbehavioralimpactsummary") as RichTextAreaBox;
            var ctrlSpedSocialEmotionalBehavioralSource        = findControlRecu(this.Page, "spedsocialemotionalbehavioralsource")        as MBA.ComboBoxMultiSelect;

            var ctrlSpedHealthSource = findControlRecu(this.Page, "spedhealthsource") as MBA.ComboBoxMultiSelect;


            var ctrlSpedParentConcernsSource = findControlRecu(this.Page, "spedparentconcernssource") as MBA.ComboBoxMultiSelect;

            var ctrlSpedReadingSource          = findControlRecu(this.Page, "spedreadingsource")          as MBA.ComboBoxMultiSelect;
            var ctrlSpedWritingSource          = findControlRecu(this.Page, "spedwritingsource")          as MBA.ComboBoxMultiSelect;
            var ctrlSpedMathSource             = findControlRecu(this.Page, "spedmathsource")             as MBA.ComboBoxMultiSelect;
            var ctrlSpedCommunicationDevSource = findControlRecu(this.Page, "spedcommunicationdevsource") as MBA.ComboBoxMultiSelect;

            var ctrlSpedGrossFineMotorSource = findControlRecu(this.Page, "spedgrossfinemotorsource") as MBA.ComboBoxMultiSelect;

            var ctrlSpedVocationalSource          = findControlRecu(this.Page, "spedvocationalsource")          as MBA.ComboBoxMultiSelect;
            var ctrlSpedAdaptiveDailyLivingSource = findControlRecu(this.Page, "spedadaptivedailylivingsource") as MBA.ComboBoxMultiSelect;
            var ctrlSpedStudentStrengthsSource    = findControlRecu(this.Page, "spedstudentstrengthssource")    as MBA.ComboBoxMultiSelect;

            var ctrlSelectFacilitator           = findControlRecu(this.Page, "selectFacilitator")           as DataEntryRowSelectUser;
            var ctrlSpedFacilitatorUserName     = findControlRecu(this.Page, "spedfacilitatorusername")     as MBA.HiddenInput;
            var ctrlSpedParticipantDetailsJSON  = findControlRecu(this.Page, "spedparticipantdetailsjson")  as HiddenTextArea;
            var ctrlSpedGridlinesLayoutJSON     = findControlRecu(this.Page, "spedgridlineslayoutjson")     as HiddenTextArea;

            var ctrlSpedMeetingDate           = findControlRecu(this.Page, "spedmeetingdate")           as DataEntryBoxDate;
            var ctrlSpedMeetingTime           = findControlRecu(this.Page, "spedmeetingtime")           as DataEntryBoxTime;
            var ctrlSpedMeetingDurationInMins = findControlRecu(this.Page, "spedmeetingdurationinmins") as DataEntryBoxNumber;
            var ctrlSpedMeetingTitle          = findControlRecu(this.Page, "spedmeetingtitle")          as DataEntryBoxText;


            /*##########################################################################
              # Load patient record
              ###########################################################################*/

            var patIDVal = Spedmon.Validate.reqPatID(uInfo, recID);
            recID    = patIDVal.ToString();
            patID    = recID;

            p        = Patients.load(dbConnApp, log, uInfo, recID);
            clientID = p.clientID.ToString();
            patID    = p.id.ToString();

            /*##########################################################################
              # Set urls used for any save type
              ###########################################################################*/

            urlGetPatientProfile  = Patients.URL_SVC_GET_BASE();
            urlSavePatientProfile = Patients.URL_SVC_SAVE_PROFILE_BASE();
            patientSaveURL        = MBA.HttpApplication.createLink(Patients.URL_USER_ALL_SAVE, true);

            urlUserMessagesSave = MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_SAVE, true);
            urlRecipientSrc = MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_VIEW_SEL_CONTACTS, true);

            if (!String.IsNullOrEmpty(showContentOnlyParm))
            {
                patientSaveURL = Util.appendParmToLink(patientSaveURL, Constants.PARM_CONTENT_ONLY, showContentOnlyParm, true);
            }

            if (!String.IsNullOrEmpty(appModeParm))
            {
                patientSaveURL = Util.appendParmToLink(patientSaveURL, Constants.PARM_APP_MODE, appModeParm, true);
            }

            /*##########################################################################
              # CRITICAL: Configure saveOrEdit control
              ###########################################################################*/

            ctrlSaveOrEdit.saveType = saveTypeVal;
            ctrlSaveOrEdit.recID    = patID;

            /*##########################################################################
              # Set control values
              ###########################################################################*/

            //ctrlSaveType.value = saveType;
            ctrlClientID.value = clientID;
            ctrlPatID.value    = patID;
            ctrlSiteID.value   = p.siteID.ToString();
            //ctrlRecID.value  = recID;

            /*##########################################################################
              # Populate IEP-specific fields
              ###########################################################################*/

            // Case manager and dates header
            ctrlSelectCaseManager.selectValue = p.spEdCaseManagerUserID.ToString();
            ctrlSelectCaseManager.selectName  = p.spEdCaseManagerUserName;
            ctrlSpedCasemanagerUserName.value = p.spEdCaseManagerUserName;
            ctrlSpEdNextEvalDate.value      = p.spEdNextEvalDate;
            ctrlSpedLastAnnualIEPDate.setValue((p.spEdLastAnnualIEPDate == DateTime.MinValue) ? "" : p.spEdLastAnnualIEPDate.ToString("yyyy-MM-dd"));
            ctrlSpedCurIEPDate.setValue((p.spEdCurIEPDate == DateTime.MinValue) ? "" : p.spEdCurIEPDate.ToString("yyyy-MM-dd"));
            ctrlSpedNextAnnualIEPDate.setValue((p.spEdNextAnnualIEPDate == DateTime.MinValue) ? "" : p.spEdNextAnnualIEPDate.ToString("yyyy-MM-dd"));
            ctrlSpEdEnteredSpEdDate.value   = p.spEdEnteredSpEdDate;
            ctrlSpedExitedSpEdDate.value    = p.spEdExitedSpEdDate;

            // Overview tab
            ctrlSelectDisability1Code.selectValue = p.spEdDisability1Code.ToString();
            ctrlSelectDisability1Code.selectName  = p.spEdDisability1CodeAndName;
            ctrlSelectDisability2Code.selectValue = p.spEdDisability2Code.ToString();
            ctrlSelectDisability2Code.selectName  = p.spEdDisability2CodeAndName;
            spedDisability1Text                   = p.spEdDisability1CodeAndName;
            spedDisability2Text                   = p.spEdDisability2CodeAndName;

            ctrlSpedSpecialTransportation.value = Util.boolToYesNo(p.spEdSpecialTransportation);

            ctrlSelectStudentLanguageCode.selectValue = p.spEdStudentLanguageCodeID.ToString();
            ctrlSelectStudentLanguageCode.selectName  = p.spEdStudentLanguageCodeAndName;
            ctrlSelectStudentRace.value               = p.spEdStudentRaceCode.ToString();
            ctrlSelectStudentRace.selectName          = p.spEdStudentRaceCodeAndName;

            ctrlSpedServicesDataJSON.value = p.spEdServicesDataJSON;

            ctrlSpedProceduralSafeguardsSentDate.setValue((p.spEdProceduralSafeguardsSentDate == DateTime.MinValue) ? "" : p.spEdProceduralSafeguardsSentDate.ToString("yyyy-MM-dd"));
            ctrlSpedSpecialTransportationComments.value = p.spEdSpecialTransportationComments;
            ctrlSpedVehicleAdaptationType.value         = p.spEdVehicleAdaptationType.ToString();
            ctrlSpeciallyAdaptedVehicle.value           = p.speciallyAdaptedVehicleForTransportation;

            ctrlSpedCorrectionDetails.value         = p.spEdCorrectionDetails;
            ctrlSelectPreferredLanguage.selectValue = p.spEdPreferredLanguageCodeID.HasValue ? p.spEdPreferredLanguageCodeID.Value.ToString() : "";
            ctrlSelectPreferredLanguage.selectName  = p.spEdPreferredLanguageCodeAndName;

            // Language information
            ctrlSpedStudentLanguageEnglishLearner.value                      = Util.boolToYesNo(p.spEdStudentLanguageEnglishLearner);
            ctrlSpedStudentLanguageInfoReclassified.value                    = p.spEdStudentLanguageInfoReclassified;
            ctrlSpedStudentLanguageEnglishLearnerUndesignatedPreschool.value = Util.boolToYesNo(p.spEdStudentLanguageEnglishLearnerUndesignatedPreschool);
            ctrlSpedStudentLanguageInterpreterNeeded.value                   = Util.boolToYesNo(p.spEdStudentLanguageInterpreterNeeded);
            ctrlSpedStudentLanguageTranslationRequested.value                = Util.boolToYesNo(p.spEdStudentLanguageTranslationRequested);

            // Meeting purpose tab
            ctrlSpedInitRefDate.setValue((p.spEdInitRefDate == DateTime.MinValue) ? "" : p.spEdInitRefDate.ToString("yyyy-MM-dd"));
            ctrlDataEntryRowSelectSpEdReferringParty.selectValue = p.spEdReferringPartyCode.ToString();
            ctrlDataEntryRowSelectSpEdReferringParty.selectName  = p.spEdReferringPartyCodeAndName;
            ctrlSpedReferringPartyOtherOption.value              = p.spEdReferringPartyOtherOption;
            ctrlSpedDistrictReceivedParentConsentDate.setValue((p.spEdDistrictReceivedParentConsentDate == DateTime.MinValue) ? "" : p.spEdDistrictReceivedParentConsentDate.ToString("yyyy-MM-dd"));
            ctrlSpedMeetingPurposeDataJSON.value                 = p.spEdMeetingPurposeDataJSON;
            ctrlDataEntryRowSelectSpEdPlanType.selectValue       = p.spEdPlanTypeCode.ToString();
            ctrlDataEntryRowSelectSpEdPlanType.selectName        = p.spEdPlanTypeCodeAndName;
            ctrlSpedAdditionalMeetingPurposeDataJSON.value       = p.spEdAdditionalMeetingPurposeDataJSON;
            ctrlSpedAmendmentReasonsDataJSON.value               = p.spEdAmendmentReasonsDataJSON;

            // Present levels tab
            ctrlSpedStudentStrengths.value                         = p.spEdStudentStrengths;
            ctrlSpedParentConcerns.value                           = p.spEdParentConcerns;
            ctrlSpedDevAcaFunSkillsReading.value                   = p.spEdDevAcaFunSkillsReading;
            ctrlSpedDevAcaFunSkillsWriting.value                   = p.spEdDevAcaFunSkillsWriting;
            ctrlSpedDevAcaFunSkillsMath.value                      = p.spEdDevAcaFunSkillsMath;
            ctrlSpedDevAcaFunSkillsCommunicationDev.value          = p.spEdDevAcaFunSkillsCommunicationDev;
            ctrlSpedDevAcaFunSkillsGrossFineMotorDev.value         = p.spEdDevAcaFunSkillsGrossFineMotorDev;
            ctrlSpedDevAcaFunSkillsHealth.value                    = p.spEdDevAcaFunSkillsHealth;
            ctrlSpedDevAcaFunSkillsVocational.value                = p.spEdDevAcaFunSkillsVocational;
            ctrlSpedDevAcaFunSkillsAdaptiveDailyLiving.value       = p.spEdDevAcaFunSkillsAdaptiveDailyLiving;
            ctrlSpedDevAcaFunSkillsAreasOfNeccessity.value         = p.spEdDevAcaFunSkillsAreasOfNeccessity;
            ctrlSpedDevAcaFunSkillsSocialEmotionalBehavioral.value = p.spEdDevAcaFunSkillsSocialEmotionalBehavioral;
            ctrlSpedProgressMonitoringData.value                   = p.spEdProgressMonitoringData;
            ctrlSpedStudentPresentLevelsStatement.value            = p.spEdStudentPresentLevelsStatement;

            // Eligibility information tab
            ctrlSpedStudentDisabilityAffectsPerformance.value   = Util.boolToYesNo(p.spEdStudentDisabilityAffectsPerformance);
            ctrlSpedCurEligibilityDate.setValue((p.spEdCurEligibilityDate == DateTime.MinValue) ? "" : p.spEdCurEligibilityDate.ToString("yyyy-MM-dd"));
            ctrlSpedInitEligibilityDate.setValue((p.spEdInitEligibilityDate == DateTime.MinValue) ? "" : p.spEdInitEligibilityDate.ToString("yyyy-MM-dd"));
            ctrlSpedIEPAttendeesIdentified.value                = Util.boolToYesNo(p.spEdIEPAttendeesIdentified);
            ctrlSpedEligibilityReasons.value                    = p.spEdEligibilityReasons;
            ctrlSelectSpEdLanguageToTranslatePlanTo.selectValue = p.spEdPlanTranslateToLanguageCodeID.ToString();
            ctrlSelectSpEdLanguageToTranslatePlanTo.selectName  = p.spEdPlanTranslateToLanguageCodeAndName;

            // Goals tab
            ctrlSpedTransitionGoalEducation.value        = p.spEdTransitionGoalEducation;
            ctrlSpedTransitionGoalTraining.value         = p.spEdTransitionGoalTraining;
            ctrlSpedTransitionGoalEmployment.value       = p.spEdTransitionGoalEmployment;
            ctrlSpedTransitionGoalIndependentLiving.value = p.spEdTransitionGoalIndependentLiving;

            // Present Levels - Main/Hidden fields
            ctrlSpedPresentLevelsDataJSON.value       = p.spEdPresentLevelsDataJSON;
            ctrlSpedPresentLevelsPreparedBy.value     = p.spEdPresentLevelsPreparedBy.ToString();
            ctrlSpedPresentLevelsPreparedByName.value = p.spEdPresentLevelsPreparedByName;

            // Student Strengths
            ctrlSpedStudentStrengthsSourceJSON.value = p.spEdStudentStrengthsSourceJSON;
            ctrlSpedStudentStrengthsImpact.value     = p.spEdStudentStrengthsImpact;

            // Student Strengths Source
            ctrlSpedStudentStrengthsSource.multiSelectLoad          = true;
            ctrlSpedStudentStrengthsSource.multiSelectValues        = p.spEdStudentStrengthsSource;
            ctrlSpedStudentStrengthsSource.multiSelectNames         = p.spEdStudentStrengthsSourceNames;
            ctrlSpedStudentStrengthsSource.multiSelectContextLabels = "";

            // Parent Concerns
            ctrlSpedParentConcernsSourceJSON.value = p.spEdParentConcernsSourceJSON;

            // Parent Concerns Source
            ctrlSpedParentConcernsSource.multiSelectLoad          = true;
            ctrlSpedParentConcernsSource.multiSelectValues        = p.spEdParentConcernsSource;
            ctrlSpedParentConcernsSource.multiSelectNames         = p.spEdParentConcernsSourceNames;
            ctrlSpedParentConcernsSource.multiSelectContextLabels = "";

            // Reading Domain
            ctrlSpedReadingReviewedNA.value    = p.spEdReadingReviewedNA;
            ctrlSpedReadingSourceJSON.value    = p.spEdReadingSourceJSON;
            ctrlSpedReadingBaselineValue.value = p.spEdReadingBaselineValue;
            ctrlSpedReadingBaselineDate.setValue((p.spEdReadingBaselineDate == DateTime.MinValue) ? "" : p.spEdReadingBaselineDate.ToString("yyyy-MM-dd"));
            ctrlSpedReadingImpactSummary.value = p.spEdReadingImpactSummary;
            ctrlSpedReadingToolsUsedJSON.value = p.spEdReadingToolsUsedJSON;

            // Reading Source
            ctrlSpedReadingSource.multiSelectLoad          = true;
            ctrlSpedReadingSource.multiSelectValues        = p.spEdReadingSource;
            ctrlSpedReadingSource.multiSelectNames         = p.spEdReadingSourceNames;
            ctrlSpedReadingSource.multiSelectContextLabels = "";

            // Reading Baseline Unit
            ctrlSpedReadingBaselineUnit.multiSelectLoad          = true;
            ctrlSpedReadingBaselineUnit.multiSelectValues        = p.spEdReadingBaselineUnit;
            ctrlSpedReadingBaselineUnit.multiSelectNames         = p.spEdReadingBaselineUnitNames;
            ctrlSpedReadingBaselineUnit.multiSelectContextLabels = "";

            // Reading Tools Used
            ctrlSpedReadingToolsUsed.multiSelectLoad          = true;
            ctrlSpedReadingToolsUsed.multiSelectValues        = p.spEdReadingToolsUsed;
            ctrlSpedReadingToolsUsed.multiSelectNames         = p.spEdReadingToolsUsedNames;
            ctrlSpedReadingToolsUsed.multiSelectContextLabels = "";

            // Writing Domain
            ctrlSpedWritingReviewedNA.value    = p.spEdWritingReviewedNA;
            ctrlSpedWritingSourceJSON.value    = p.spEdWritingSourceJSON;
            ctrlSpedWritingBaselineValue.value = p.spEdWritingBaselineValue;
            ctrlSpedWritingBaselineDate.setValue((p.spEdWritingBaselineDate == DateTime.MinValue) ? "" : p.spEdWritingBaselineDate.ToString("yyyy-MM-dd"));
            ctrlSpedWritingImpactSummary.value = p.spEdWritingImpactSummary;
            ctrlSpedWritingToolsUsedJSON.value = p.spEdWritingToolsUsedJSON;

            // Writing Source
            ctrlSpedWritingSource.multiSelectLoad          = true;
            ctrlSpedWritingSource.multiSelectValues        = p.spEdWritingSource;
            ctrlSpedWritingSource.multiSelectNames         = p.spEdWritingSourceNames;
            ctrlSpedWritingSource.multiSelectContextLabels = "";

            // Writing Baseline Unit
            ctrlSpedWritingBaselineUnit.multiSelectLoad          = true;
            ctrlSpedWritingBaselineUnit.multiSelectValues        = p.spEdWritingBaselineUnit;
            ctrlSpedWritingBaselineUnit.multiSelectNames         = p.spEdWritingBaselineUnitNames;
            ctrlSpedWritingBaselineUnit.multiSelectContextLabels = "";

            // Writing Tools Used
            ctrlSpedWritingToolsUsed.multiSelectLoad          = true;
            ctrlSpedWritingToolsUsed.multiSelectValues        = p.spEdWritingToolsUsed;
            ctrlSpedWritingToolsUsed.multiSelectNames         = p.spEdWritingToolsUsedNames;
            ctrlSpedWritingToolsUsed.multiSelectContextLabels = "";

            // Math Domain
            ctrlSpedMathReviewedNA.value    = p.spEdMathReviewedNA;
            ctrlSpedMathSourceJSON.value    = p.spEdMathSourceJSON;
            ctrlSpedMathBaselineValue.value = p.spEdMathBaselineValue;
            ctrlSpedMathBaselineDate.setValue((p.spEdMathBaselineDate == DateTime.MinValue) ? "" : p.spEdMathBaselineDate.ToString("yyyy-MM-dd"));
            ctrlSpedMathImpactSummary.value = p.spEdMathImpactSummary;
            ctrlSpedMathToolsUsedJSON.value = p.spEdMathToolsUsedJSON;

            // Math Source
            ctrlSpedMathSource.multiSelectLoad          = true;
            ctrlSpedMathSource.multiSelectValues        = p.spEdMathSource;
            ctrlSpedMathSource.multiSelectNames         = p.spEdMathSourceNames;
            ctrlSpedMathSource.multiSelectContextLabels = "";

            // Math Baseline Unit
            ctrlSpedMathBaselineUnit.multiSelectLoad          = true;
            ctrlSpedMathBaselineUnit.multiSelectValues        = p.spEdMathBaselineUnit;
            ctrlSpedMathBaselineUnit.multiSelectNames         = p.spEdMathBaselineUnitNames;
            ctrlSpedMathBaselineUnit.multiSelectContextLabels = "";

            // Math Tools Used
            ctrlSpedMathToolsUsed.multiSelectLoad          = true;
            ctrlSpedMathToolsUsed.multiSelectValues        = p.spEdMathToolsUsed;
            ctrlSpedMathToolsUsed.multiSelectNames         = p.spEdMathToolsUsedNames;
            ctrlSpedMathToolsUsed.multiSelectContextLabels = "";

            // Communication Development Domain
            ctrlSpedCommunicationDevReviewedNA.value    = p.spEdCommunicationDevReviewedNA;
            ctrlSpedCommunicationDevSourceJSON.value    = p.spEdCommunicationDevSourceJSON;
            ctrlSpedCommunicationDevBaselineValue.value = p.spEdCommunicationDevBaselineValue;
            ctrlSpedCommunicationDevBaselineDate.setValue((p.spEdCommunicationDevBaselineDate == DateTime.MinValue) ? "" : p.spEdCommunicationDevBaselineDate.ToString("yyyy-MM-dd"));
            ctrlSpedCommunicationDevImpactSummary.value = p.spEdCommunicationDevImpactSummary;
            ctrlSpedCommunicationDevToolsUsedJSON.value = p.spEdCommunicationDevToolsUsedJSON;

            // Communication Dev Source
            ctrlSpedCommunicationDevSource.multiSelectLoad          = true;
            ctrlSpedCommunicationDevSource.multiSelectValues        = p.spEdCommunicationDevSource;
            ctrlSpedCommunicationDevSource.multiSelectNames         = p.spEdCommunicationDevSourceNames;
            ctrlSpedCommunicationDevSource.multiSelectContextLabels = "";

            // Communication Dev Baseline Unit
            ctrlSpedCommunicationDevBaselineUnit.multiSelectLoad          = true;
            ctrlSpedCommunicationDevBaselineUnit.multiSelectValues        = p.spEdCommunicationDevBaselineUnit;
            ctrlSpedCommunicationDevBaselineUnit.multiSelectNames         = p.spEdCommunicationDevBaselineUnitNames;
            ctrlSpedCommunicationDevBaselineUnit.multiSelectContextLabels = "";

            // Communication Dev Tools Used
            ctrlSpedCommunicationDevToolsUsed.multiSelectLoad          = true;
            ctrlSpedCommunicationDevToolsUsed.multiSelectValues        = p.spEdCommunicationDevToolsUsed;
            ctrlSpedCommunicationDevToolsUsed.multiSelectNames         = p.spEdCommunicationDevToolsUsedNames;
            ctrlSpedCommunicationDevToolsUsed.multiSelectContextLabels = "";

            // Gross/Fine Motor Domain
            ctrlSpedGrossFineMotorReviewedNA.value    = p.spEdGrossFineMotorReviewedNA;
            ctrlSpedGrossFineMotorSourceJSON.value    = p.spEdGrossFineMotorSourceJSON;
            ctrlSpedGrossFineMotorBaselineValue.value = p.spEdGrossFineMotorBaselineValue;
            ctrlSpedGrossFineMotorBaselineDate.setValue((p.spEdGrossFineMotorBaselineDate == DateTime.MinValue) ? "" : p.spEdGrossFineMotorBaselineDate.ToString("yyyy-MM-dd"));
            ctrlSpedGrossFineMotorImpactSummary.value = p.spEdGrossFineMotorImpactSummary;
            ctrlSpedGrossFineMotorToolsUsedJSON.value = p.spEdGrossFineMotorToolsUsedJSON;

            // Gross/Fine Motor Source
            ctrlSpedGrossFineMotorSource.multiSelectLoad          = true;
            ctrlSpedGrossFineMotorSource.multiSelectValues        = p.spEdGrossFineMotorSource;
            ctrlSpedGrossFineMotorSource.multiSelectNames         = p.spEdGrossFineMotorSourceNames;
            ctrlSpedGrossFineMotorSource.multiSelectContextLabels = "";

            // Gross/Fine Motor Baseline Unit
            ctrlSpedGrossFineMotorBaselineUnit.multiSelectLoad          = true;
            ctrlSpedGrossFineMotorBaselineUnit.multiSelectValues        = p.spEdGrossFineMotorBaselineUnit;
            ctrlSpedGrossFineMotorBaselineUnit.multiSelectNames         = p.spEdGrossFineMotorBaselineUnitNames;
            ctrlSpedGrossFineMotorBaselineUnit.multiSelectContextLabels = "";

            // Gross/Fine Motor Tools Used
            ctrlSpedGrossFineMotorToolsUsed.multiSelectLoad          = true;
            ctrlSpedGrossFineMotorToolsUsed.multiSelectValues        = p.spEdGrossFineMotorToolsUsed;
            ctrlSpedGrossFineMotorToolsUsed.multiSelectNames         = p.spEdGrossFineMotorToolsUsedNames;
            ctrlSpedGrossFineMotorToolsUsed.multiSelectContextLabels = "";

            // Health Domain
            ctrlSpedHealthReviewedNA.value    = p.spEdHealthReviewedNA;
            ctrlSpedHealthSourceJSON.value    = p.spEdHealthSourceJSON;
            ctrlSpedHealthBaselineValue.value = p.spEdHealthBaselineValue;
            ctrlSpedHealthBaselineDate.setValue((p.spEdHealthBaselineDate == DateTime.MinValue) ? "" : p.spEdHealthBaselineDate.ToString("yyyy-MM-dd"));
            ctrlSpedHealthImpactSummary.value = p.spEdHealthImpactSummary;
            ctrlSpedHealthToolsUsedJSON.value = p.spEdHealthToolsUsedJSON;

            // Health Source
            ctrlSpedHealthSource.multiSelectLoad          = true;
            ctrlSpedHealthSource.multiSelectValues        = p.spEdHealthSource;
            ctrlSpedHealthSource.multiSelectNames         = p.spEdHealthSourceNames;
            ctrlSpedHealthSource.multiSelectContextLabels = "";

            // Health Baseline Unit
            ctrlSpedHealthBaselineUnit.multiSelectLoad          = true;
            ctrlSpedHealthBaselineUnit.multiSelectValues        = p.spEdHealthBaselineUnit;
            ctrlSpedHealthBaselineUnit.multiSelectNames         = p.spEdHealthBaselineUnitNames;
            ctrlSpedHealthBaselineUnit.multiSelectContextLabels = "";

            // Health Tools Used
            ctrlSpedHealthToolsUsed.multiSelectLoad          = true;
            ctrlSpedHealthToolsUsed.multiSelectValues        = p.spEdHealthToolsUsed;
            ctrlSpedHealthToolsUsed.multiSelectNames         = p.spEdHealthToolsUsedNames;
            ctrlSpedHealthToolsUsed.multiSelectContextLabels = "";

            // Vocational Domain
            ctrlSpedVocationalReviewedNA.value    = p.spEdVocationalReviewedNA;
            ctrlSpedVocationalSourceJSON.value    = p.spEdVocationalSourceJSON;
            ctrlSpedVocationalBaselineValue.value = p.spEdVocationalBaselineValue;
            ctrlSpedVocationalBaselineDate.setValue((p.spEdVocationalBaselineDate == DateTime.MinValue) ? "" : p.spEdVocationalBaselineDate.ToString("yyyy-MM-dd"));
            ctrlSpedVocationalImpactSummary.value = p.spEdVocationalImpactSummary;
            ctrlSpedVocationalToolsUsedJSON.value = p.spEdVocationalToolsUsedJSON;

            // Vocational Source
            ctrlSpedVocationalSource.multiSelectLoad          = true;
            ctrlSpedVocationalSource.multiSelectValues        = p.spEdVocationalSource;
            ctrlSpedVocationalSource.multiSelectNames         = p.spEdVocationalSourceNames;
            ctrlSpedVocationalSource.multiSelectContextLabels = "";

            // Vocational Baseline Unit
            ctrlSpedVocationalBaselineUnit.multiSelectLoad          = true;
            ctrlSpedVocationalBaselineUnit.multiSelectValues        = p.spEdVocationalBaselineUnit;
            ctrlSpedVocationalBaselineUnit.multiSelectNames         = p.spEdVocationalBaselineUnitNames;
            ctrlSpedVocationalBaselineUnit.multiSelectContextLabels = "";

            // Vocational Tools Used
            ctrlSpedVocationalToolsUsed.multiSelectLoad          = true;
            ctrlSpedVocationalToolsUsed.multiSelectValues        = p.spEdVocationalToolsUsed;
            ctrlSpedVocationalToolsUsed.multiSelectNames         = p.spEdVocationalToolsUsedNames;
            ctrlSpedVocationalToolsUsed.multiSelectContextLabels = "";

            // Adaptive/Daily Living Domain
            ctrlSpedAdaptiveDailyLivingReviewedNA.value    = p.spEdAdaptiveDailyLivingReviewedNA;
            ctrlSpedAdaptiveDailyLivingSourceJSON.value    = p.spEdAdaptiveDailyLivingSourceJSON;
            ctrlSpedAdaptiveDailyLivingBaselineValue.value = p.spEdAdaptiveDailyLivingBaselineValue;
            ctrlSpedAdaptiveDailyLivingBaselineDate.setValue((p.spEdAdaptiveDailyLivingBaselineDate == DateTime.MinValue) ? "" : p.spEdAdaptiveDailyLivingBaselineDate.ToString("yyyy-MM-dd"));
            ctrlSpedAdaptiveDailyLivingImpactSummary.value = p.spEdAdaptiveDailyLivingImpactSummary;
            ctrlSpedAdaptiveDailyLivingToolsUsedJSON.value = p.spEdAdaptiveDailyLivingToolsUsedJSON;

            // Adaptive Daily Living Source
            ctrlSpedAdaptiveDailyLivingSource.multiSelectLoad          = true;
            ctrlSpedAdaptiveDailyLivingSource.multiSelectValues        = p.spEdAdaptiveDailyLivingSource;
            ctrlSpedAdaptiveDailyLivingSource.multiSelectNames         = p.spEdAdaptiveDailyLivingSourceNames;
            ctrlSpedAdaptiveDailyLivingSource.multiSelectContextLabels = "";

            // Adaptive Daily Living Baseline Unit
            ctrlSpedAdaptiveDailyLivingBaselineUnit.multiSelectLoad          = true;
            ctrlSpedAdaptiveDailyLivingBaselineUnit.multiSelectValues        = p.spEdAdaptiveDailyLivingBaselineUnit;
            ctrlSpedAdaptiveDailyLivingBaselineUnit.multiSelectNames         = p.spEdAdaptiveDailyLivingBaselineUnitNames;
            ctrlSpedAdaptiveDailyLivingBaselineUnit.multiSelectContextLabels = "";

            // Adaptive Daily Living Tools Used
            ctrlSpedAdaptiveDailyLivingToolsUsed.multiSelectLoad          = true;
            ctrlSpedAdaptiveDailyLivingToolsUsed.multiSelectValues        = p.spEdAdaptiveDailyLivingToolsUsed;
            ctrlSpedAdaptiveDailyLivingToolsUsed.multiSelectNames         = p.spEdAdaptiveDailyLivingToolsUsedNames;
            ctrlSpedAdaptiveDailyLivingToolsUsed.multiSelectContextLabels = "";

            // Social/Emotional/Behavioral Domain
            ctrlSpedSocialEmotionalBehavioralReviewedNA.value    = p.spEdSocialEmotionalBehavioralReviewedNA;
            ctrlSpedSocialEmotionalBehavioralSourceJSON.value    = p.spEdSocialEmotionalBehavioralSourceJSON;
            ctrlSpedSocialEmotionalBehavioralBaselineValue.value = p.spEdSocialEmotionalBehavioralBaselineValue;
            ctrlSpedSocialEmotionalBehavioralBaselineDate.setValue((p.spEdSocialEmotionalBehavioralBaselineDate == DateTime.MinValue) ? "" : p.spEdSocialEmotionalBehavioralBaselineDate.ToString("yyyy-MM-dd"));
            ctrlSpedSocialEmotionalBehavioralImpactSummary.value = p.spEdSocialEmotionalBehavioralImpactSummary;
            ctrlSpedSocialEmotionalBehavioralToolsUsedJSON.value = p.spEdSocialEmotionalBehavioralToolsUsedJSON;

            // Social/Emotional/Behavioral Source
            ctrlSpedSocialEmotionalBehavioralSource.multiSelectLoad          = true;
            ctrlSpedSocialEmotionalBehavioralSource.multiSelectValues        = p.spEdSocialEmotionalBehavioralSource;
            ctrlSpedSocialEmotionalBehavioralSource.multiSelectNames         = p.spEdSocialEmotionalBehavioralSourceNames;
            ctrlSpedSocialEmotionalBehavioralSource.multiSelectContextLabels = "";

            // Social/Emotional/Behavioral Baseline Unit
            ctrlSpedSocialEmotionalBehavioralBaselineUnit.multiSelectLoad          = true;
            ctrlSpedSocialEmotionalBehavioralBaselineUnit.multiSelectValues        = p.spEdSocialEmotionalBehavioralBaselineUnit;
            ctrlSpedSocialEmotionalBehavioralBaselineUnit.multiSelectNames         = p.spEdSocialEmotionalBehavioralBaselineUnitNames;
            ctrlSpedSocialEmotionalBehavioralBaselineUnit.multiSelectContextLabels = "";

            // Social/Emotional/Behavioral Tools Used
            ctrlSpedSocialEmotionalBehavioralToolsUsed.multiSelectLoad          = true;
            ctrlSpedSocialEmotionalBehavioralToolsUsed.multiSelectValues        = p.spEdSocialEmotionalBehavioralToolsUsed;
            ctrlSpedSocialEmotionalBehavioralToolsUsed.multiSelectNames         = p.spEdSocialEmotionalBehavioralToolsUsedNames;
            ctrlSpedSocialEmotionalBehavioralToolsUsed.multiSelectContextLabels = "";

            ctrlSpedMeetingDate.setValue(
                (p.spEdMeetingDate == DateTime.MinValue)
                    ? ""
                : p.spEdMeetingDate.ToString("yyyy-MM-dd"));

            if (!String.IsNullOrWhiteSpace(p.spEdMeetingTime))
            {
                try
                {
                    ctrlSpedMeetingTime.setValue(p.spEdMeetingTime);
                }
                catch { }
            }

            if (p.spEdMeetingDurationInMins > 0)
            {
                ctrlSpedMeetingDurationInMins.value = (double)p.spEdMeetingDurationInMins;
            }

            ctrlSpedMeetingTitle.value = p.spEdMeetingTitle;

            ctrlSelectFacilitator.selectValue       = p.spEdFacilitatorUserID.ToString();
            ctrlSelectFacilitator.selectName        = p.spEdFacilitatorUserName;
            ctrlSpedFacilitatorUserName.value       = p.spEdFacilitatorUserName;
            ctrlSpedParticipantDetailsJSON.value    = p.spEdParticipantDetailsJSON;
            ctrlSpedGridlinesLayoutJSON.value       = p.spEdParticipantDetailsJSON;
            /*##########################################################################
              # Set URL values used by all users
              ###########################################################################*/

            urlViewAllPatientGoalsProgress = PatientGoalsProgressIndividualGoals.URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS_BASE(clientID, patID);
            urlViewPatientGoalsProgress    = PatientGoalsProgressIndividualGoals.URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS_BASE();

            try
            {
                var historyList = TeleIEPSessions.viewList(dbConnApp
                                                          , log
                                                          , uInfo
                                                          , clientID
                                                          , patID
                                                          , "");

                if (historyList != null && historyList.Count > 0)
                {
                    var historyItems = new List<object>();

                    var sessionDataMap = new Dictionary<long, Dictionary<string, string>>();

                    try
                    {
                        var sessionIDs = new List<string>();
                        foreach (var s in historyList)
                        {
                            sessionIDs.Add(s.id.ToString());
                        }

                        if (sessionIDs.Count > 0)
                        {
                            string sessionIDsStr = String.Join(",", sessionIDs);
                            var sessionDataParms = new List<SqlParameter>();
                            sessionDataParms.Add(Database.SqlParm("@sessionIDsStr", SqlDbType.VarChar, sessionIDsStr, ParameterDirection.Input,-1));

                            string sessionDataSql = @"SELECT t1.id
                                                           , ISNULL(CONVERT(VARCHAR(10), t1.meetingDate, 101), '')          AS meetingDateStr
                                                           , ISNULL(FORMAT(CAST(t1.meetingTime AS DATETIME), 'h:mm tt'), '') AS meetingTimeStr
                                                           , ISNULL(t1.meetingCompletionStatus, '')                          AS meetingCompletionStatus
                                                           , ISNULL(t1.meetingNotes, '')                                     AS meetingNotes
                                                           , ISNULL(FORMAT(t1.created, 'MM/dd/yyyy h:mm tt'), '')            AS dateSent
                                                      FROM users.dbo.TELECOMM_SESSIONS as t1
                                                      WHERE t1.id IN (select id = t2.value from string_split(@sessionIDsStr,',') as t2)";

                            ReturnDB sessionDataRd = Database.execQuery(dbConnApp, log, sessionDataSql, false, sessionDataParms);

                            if (sessionDataRd.hasRecords)
                            {
                                List<Object> sessionDataObjects = Database.convertRecordsToList(ref sessionDataRd.records, typeof(HistorySessionData));

                                foreach (var obj in sessionDataObjects)
                                {
                                    var hs = (HistorySessionData)obj;

                                    var fieldMap = new Dictionary<string, string>();
                                    fieldMap["meetingDate"] = hs.meetingDateStr ?? "";
                                    fieldMap["meetingTime"] = hs.meetingTimeStr ?? "";
                                    fieldMap["meetingCompletionStatus"] = hs.meetingCompletionStatus ?? "";
                                    fieldMap["meetingNotes"] = hs.meetingNotes ?? "";
                                    fieldMap["dateSent"] = hs.dateSent ?? "";

                                    sessionDataMap[hs.id] = fieldMap;
                                }
                            }
                        }
                    }
                    catch { }

                    foreach (var session in historyList)
                    {
                        var participantsList = new List<object>();

                        try
                        {
                            var partParms = new List<SqlParameter>();
                            partParms.Add(Database.SqlParm("@sessionID", SqlDbType.BigInt, session.id, ParameterDirection.Input));

                            string partSql = @"SELECT name, title, email, phone, inviteRsvpWillAttend, inviteRsvpNotes
                                     FROM users.dbo.TELECOMM_SESSIONS_PARTICIPANTS
                                     WHERE telecommSessionID = @sessionID
                                     AND (ISNULL(name,'') != '')";

                            ReturnDB partRd = Database.execQuery(dbConnApp, log, partSql, false, partParms);

                            if (partRd.hasRecords)
                            {
                                List<Object> partObjects = Database.convertRecordsToList(ref partRd.records, typeof(HistoryParticipantData));

                                foreach (var obj in partObjects)
                                {
                                    var hp = (HistoryParticipantData)obj;

                                    string conf = "none";
                                    if (hp.inviteRsvpWillAttend == true) conf = "accepted";
                                    else if (hp.inviteRsvpWillAttend == false) conf = "declined";

                                    participantsList.Add(new
                                    {
                                        name = hp.name ?? "",
                                        title = hp.title ?? "",
                                        email = hp.email ?? "",
                                        confirmation = conf,
                                        phone = hp.phone ?? "",
                                        notes = hp.inviteRsvpNotes ?? ""

                                    });
                                }
                            }
                        }
                        catch { }

                        string hMeetingDate = "";
                        string hMeetingTime = "";
                        string hStatus = "";
                        string hNotes = "";
                        string hDateSent = "";

                        if (sessionDataMap.ContainsKey(session.id))
                        {
                            var map = sessionDataMap[session.id];
                            hMeetingDate = map["meetingDate"];
                            hMeetingTime = map["meetingTime"];
                            hStatus = map["meetingCompletionStatus"];
                            hNotes = map["meetingNotes"];
                            hDateSent = map["dateSent"];
                        }

                        historyItems.Add(new
                        {
                            id = session.id,
                            title = session.title ?? "",
                            meetingDate = hMeetingDate,
                            meetingTime = hMeetingTime,
                            durationInMins = session.meetingDurationInMins,
                            facilitatorName = session.facilitatorName ?? "",
                            active = session.active,
                            dateSent = hDateSent,
                            meetingCompletionStatus = hStatus,
                            meetingNotes = hNotes,
                            participants = participantsList
                        });
                    }

                    meetingHistoryJSON = Newtonsoft.Json.JsonConvert.SerializeObject(historyItems);
                }
            }
            catch
            {
                meetingHistoryJSON = "[]";
            }

            /*##########################################################################
              # Practitioner specific logic
              ###########################################################################*/

            if (isPrac == true)
            {
                pracGrpSvcClassNameID = uInfo.userPracStdSvcClassNameID.ToString();
                pracID                = uInfo.userPracIDStr;
                groupID               = uInfo.userPracDispGroupIDStr;

                ctrlPracGroupSvcClassNameID.value = string.IsNullOrEmpty(pracGrpSvcClassNameID) || pracGrpSvcClassNameID == "0" ? "" : pracGrpSvcClassNameID;
                ctrlPracID.value                  = string.IsNullOrEmpty(pracID) || pracID == "0" ? "" : pracID;
                ctrlGroupID.value                 = string.IsNullOrEmpty(groupID) || groupID == "0" ? "" : groupID;

                canReferPatient = PractitionerPatientReferrals.userCanAccessSaveScreen(rd, saveTypeVal);
                if (canReferPatient == true)
                {
                    urlPracPatReferal = PractitionerPatientReferrals.URL_MANAGE_REFERRALL(clientID, ctrlPatID.value);
                }

                // If they are a health services practitioner
                if (pracGrpSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES.ToString())
                {
                    canStartNewVisit = true;
                }
            }

            /*##########################################################################
              # Animate close icon if needed
              ###########################################################################*/

            if (!String.IsNullOrWhiteSpace(tabToOpen))
            {
                this.animateCloseIcon = true;
            }
        }
    }
}