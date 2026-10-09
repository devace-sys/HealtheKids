using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    /***************************************************************************
     * PatientSelection */
    /**
     * Patient record details (for batch entry)
     **************************************************************************/

    public class PatientSelection
    {
        public PatientSelection() { }

        [IsDataGridCol(1)]
        [DataGridColTitle("SpEdCare Patient ID")]
        [DataGridColIsInputLabel(true)]
        [DataGridColIsInputKey(true)]

        public int patID;

        [IsDataGridCol(2)]
        [DataGridColTitle("Patient Name")]
        [DataGridColIsInputLabel(true)]

        public string patName;

    }

    /***************************************************************************
     * Patient */
    /**
     ***************************************************************************/

    public class Patient : Person
    {
         public new const string DEFAULT_PAGING_ORDER = @"name, dob";
        public string gender;
        public DateTime dob;
        public string dobStr;
        public string dobStrYMD;
        public string ssn;
        public string siteRefID;
        public int siteID;
        public string siteName;
        public string siteRank;
        public bool hasIEP;
        public string bic;
        public string CSIS;

        public bool submitClaims;
        public DateTime submitClaimsEffectiveDate;
        public string submitClaimsEffectiveDateStr;
        public bool? parentConsentMCAL;
        public DateTime parentConsentMCALEffectiveDate;
        public string parentConsentMCALEffectiveDateStr;
        public bool? parentConsentOHCI;
        public DateTime parentConsentOHCIEffectiveDate;
        public string parentConsentOHCIEffectiveDateStr;

        public bool? ferpaConsent;
        public DateTime? ferpaConsentEffectiveDate;

        public bool? treatmentConsent;
        public DateTime? treatmentConsentEffectiveDate;

        public bool? cybhiTpaApproved;
        public DateTime? cybhiTpaApprovedOn;
        public string cybhiTpaID;
        public bool cybhiSubmitClaims;

        public int? ageCurrent;
        public string iep;
        public bool? expired;
        public bool speciallyAdaptedVehicleForTransportation;
        public string activeYN;
        public string submitClaimsYN;
        public string medicalParentConsentYN;
        public string parentConsentOHCIYN;
        public bool spEdSpecialTransportation;
        public DateTime spEdLastEvalDate;
        public DateTime spEdLastAnnualIEPDate;
        public DateTime spEdNextAnnualIEPDate;
        public DateTime spEdCurIEPDate;
        public int spEdDisability1Code;
        public string spEdDisability1CodeAndName;
        public int spEdDisability2Code;
        public string spEdDisability2CodeAndName;
        public string spEdCaseManagerName;
        public DateTime? spEdExitedSpEdDate;
        public bool ffpQualified;
        public string ffpQualifiedStr;
        public string altFormat;

        public string spEdStudentStrengths;
        public string spEdParentConcerns;
        public string spEdProgressMonitoringData;
        public string spEdStudentPresentLevelsStatement;
        public bool spEdStudentDisabilityAffectsPerformance;
        public DateTime spEdCurEligibilityDate;
        public string spEdCurEligibilityDateStrYMD;
        public DateTime spEdInitEligibilityDate;
        public string spEdInitEligibilityDateStrYMD;
        public bool spEdIEPAttendeesIdentified;
        public string spEdEligibilityReasons;
        public DateTime spEdInitRefDate;
        public string spEdInitRefDateStrYMD;
        public int spEdReferringPartyCode;
        public string spEdReferringPartyCodeAndName;
        public string spEdReferringPartyOtherOption;
        public DateTime spEdDistrictReceivedParentConsentDate;
        public string spEdDistrictReceivedParentConsentDateStrYMD;
        public string spEdMeetingPurposeDataJSON;
        public string spEdAdditionalMeetingPurposeDataJSON;
        public string spEdAmendmentReasonsDataJSON;
        public int spEdPlanTypeCode;
        public string spEdPlanTypeCodeAndName;
        public long spEdPlanTranslateToLanguageCodeID;       /* Codes are alphanumeric so we need an id */
        public string spEdPlanTranslateToLanguageCode;
        public string spEdPlanTranslateToLanguageCodeAndName;
        public long spEdStudentLanguageCodeID;               /* Codes are alphanumeric so we need an id */
        public string spEdStudentLanguageCode;
        public string spEdStudentLanguageCodeAndName;
        public int spEdStudentRaceCode;
        public string spEdStudentRaceCodeAndName;
        public DateTime? spEdNextEvalDate;
        public DateTime? spEdEnteredSpEdDate;

        public string spEdEnteredSpEdDateYMD;
        public string spEdExitedSpEdDateYMD;
        public string spEdLastEvalDateYMD;
        public string spEdNextEvalDateYMD;
        public string spEdLastAnnualIEPDateYMD;
        public string spEdNextAnnualIEPDateYMD;
        public string spEdCurIEPDateYMD;
        public bool spEdStudentLanguageEnglishLearner;
        public bool spEdStudentLanguageInfoReclassified;
        public bool spEdStudentLanguageEnglishLearnerUndesignatedPreschool;
        public bool spEdStudentLanguageInterpreterNeeded;
        public bool spEdStudentLanguageTranslationRequested;
        public string spEdServicesDataJSON;
        public bool spEdTransitionGoalEducation;
        public bool spEdTransitionGoalTraining;
        public bool spEdTransitionGoalEmployment;
        public bool spEdTransitionGoalIndependentLiving;

        public string spEdDevAcaFunSkillsReading;
        public string spEdDevAcaFunSkillsWriting;
        public string spEdDevAcaFunSkillsMath;
        public string spEdDevAcaFunSkillsCommunicationDev;
        public string spEdDevAcaFunSkillsGrossFineMotorDev;
        public string spEdDevAcaFunSkillsHealth;
        public string spEdDevAcaFunSkillsVocational;
        public string spEdDevAcaFunSkillsAdaptiveDailyLiving;
        public string spEdDevAcaFunSkillsAreasOfNeccessity;
        public string spEdDevAcaFunSkillsSocialEmotionalBehavioral;                                    

        public string   spEdParticipantDetailsJSON;

        public DateTime spEdProceduralSafeguardsSentDate;
        public string   spEdProceduralSafeguardsSentDateYMD;
        public string   spEdSpecialTransportationComments;
        public int?     spEdVehicleAdaptationType;
        public string   spEdCorrectionDetails;
        public long?    spEdPreferredLanguageCodeID;
        public string   spEdPreferredLanguageCode;
        public string   spEdPreferredLanguageCodeAndName;

        public string   spEdPresentLevelsDataJSON;
        public long     spEdPresentLevelsPreparedBy;
        public string   spEdPresentLevelsPreparedByName;

        public string   spEdStudentStrengthsSourceJSON;
        public string   spEdStudentStrengthsImpact;

        public string   spEdParentConcernsSourceJSON;

        public bool     spEdReadingReviewedNA;
        public string   spEdReadingSourceJSON;
        public string   spEdReadingBaselineValue;
        public string   spEdReadingBaselineUnit;
        public string   spEdReadingToolsUsed;
        public string   spEdReadingToolsUsedJSON;                                                      
        public DateTime spEdReadingBaselineDate;
        public string   spEdReadingImpactSummary;

        public bool     spEdWritingReviewedNA;
        public string   spEdWritingSourceJSON;
        public string   spEdWritingBaselineValue;
        public string   spEdWritingBaselineUnit;
        public string   spEdWritingToolsUsed;
        public string   spEdWritingToolsUsedJSON;                                                      
        public DateTime spEdWritingBaselineDate;
        public string   spEdWritingImpactSummary;

        public bool     spEdMathReviewedNA;
        public string   spEdMathSourceJSON;
        public string   spEdMathBaselineValue;
        public string   spEdMathBaselineUnit;
        public string   spEdMathToolsUsed;
        public string   spEdMathToolsUsedJSON;                                                         
        public DateTime spEdMathBaselineDate;
        public string   spEdMathImpactSummary;

        public bool     spEdCommunicationDevReviewedNA;
        public string   spEdCommunicationDevSourceJSON;
        public string   spEdCommunicationDevBaselineValue;
        public string   spEdCommunicationDevBaselineUnit;
        public string   spEdCommunicationDevToolsUsed;
        public string   spEdCommunicationDevToolsUsedJSON;                                             
        public DateTime spEdCommunicationDevBaselineDate;
        public string   spEdCommunicationDevImpactSummary;

        public bool     spEdGrossFineMotorReviewedNA;
        public string   spEdGrossFineMotorSourceJSON;
        public string   spEdGrossFineMotorBaselineValue;
        public string   spEdGrossFineMotorBaselineUnit;
        public string   spEdGrossFineMotorToolsUsed;
        public string   spEdGrossFineMotorToolsUsedJSON;                                               
        public DateTime spEdGrossFineMotorBaselineDate;
        public string   spEdGrossFineMotorImpactSummary;

        public bool     spEdHealthReviewedNA;
        public string   spEdHealthSourceJSON;
        public string   spEdHealthBaselineValue;
        public string   spEdHealthBaselineUnit;
        public string   spEdHealthToolsUsed;
        public string   spEdHealthToolsUsedJSON;                                                       
        public DateTime spEdHealthBaselineDate;
        public string   spEdHealthImpactSummary;

        public bool     spEdVocationalReviewedNA;
        public string   spEdVocationalSourceJSON;
        public string   spEdVocationalBaselineValue;
        public string   spEdVocationalBaselineUnit;
        public string   spEdVocationalToolsUsed;
        public string   spEdVocationalToolsUsedJSON;                                                   
        public DateTime spEdVocationalBaselineDate;
        public string   spEdVocationalImpactSummary;

        public bool     spEdAdaptiveDailyLivingReviewedNA;
        public string   spEdAdaptiveDailyLivingSourceJSON;
        public string   spEdAdaptiveDailyLivingBaselineValue;
        public string   spEdAdaptiveDailyLivingBaselineUnit;
        public string   spEdAdaptiveDailyLivingToolsUsed;
        public string   spEdAdaptiveDailyLivingToolsUsedJSON;                                          
        public DateTime spEdAdaptiveDailyLivingBaselineDate;
        public string   spEdAdaptiveDailyLivingImpactSummary;

        public bool     spEdSocialEmotionalBehavioralReviewedNA;                                       
        public string   spEdSocialEmotionalBehavioralSource;                                           
        public string   spEdSocialEmotionalBehavioralSourceJSON;                                       
        public string   spEdSocialEmotionalBehavioralBaselineValue;                                    
        public string   spEdSocialEmotionalBehavioralBaselineUnit;                                     
        public string   spEdSocialEmotionalBehavioralToolsUsed;                                        
        public string   spEdSocialEmotionalBehavioralToolsUsedJSON;                                    
        public DateTime spEdSocialEmotionalBehavioralBaselineDate;                                     
        public string   spEdSocialEmotionalBehavioralImpactSummary;                                    
        public string   spEdSocialEmotionalBehavioralSourceNames;                                      
        public string   spEdSocialEmotionalBehavioralBaselineUnitNames;         
        
        public string   spEdSocialEmotionalBehavioralToolsUsedNames;                                   

        public string   spEdStudentStrengthsSource;
        public string   spEdStudentStrengthsSourceNames;

        public string   spEdParentConcernsSource;
        public string   spEdParentConcernsSourceNames;

        public string   spEdReadingSource;
        public string   spEdReadingSourceNames;

        public string   spEdWritingSource;
        public string   spEdWritingSourceNames;

        public string   spEdMathSource;
        public string   spEdMathSourceNames;
        public string   spEdCommunicationDevSource;
        public string   spEdCommunicationDevSourceNames;
        public string   spEdGrossFineMotorSource;
        public string   spEdGrossFineMotorSourceNames;
        public string   spEdHealthSource;
        public string   spEdHealthSourceNames;
        public string   spEdVocationalSource;
        public string   spEdVocationalSourceNames;
        public string   spEdAdaptiveDailyLivingSource;
        public string   spEdAdaptiveDailyLivingSourceNames;

        public string   spEdReadingBaselineUnitNames;
        public string   spEdWritingBaselineUnitNames;
        public string   spEdMathBaselineUnitNames;
        public string   spEdCommunicationDevBaselineUnitNames;
        public string   spEdGrossFineMotorBaselineUnitNames;
        public string   spEdHealthBaselineUnitNames;
        public string   spEdVocationalBaselineUnitNames;
        public string   spEdAdaptiveDailyLivingBaselineUnitNames;
        public string   spEdReadingToolsUsedNames;
        public string   spEdWritingToolsUsedNames;
        public string   spEdMathToolsUsedNames;
        public string   spEdCommunicationDevToolsUsedNames;
        public string   spEdGrossFineMotorToolsUsedNames;
        public string   spEdHealthToolsUsedNames;
        public string   spEdVocationalToolsUsedNames;
        public string   spEdAdaptiveDailyLivingToolsUsedNames;

        public string   spEdAmendmentReasonsOtherOption;
        public string   spEdMeetingPurposeOtherOption;
        public long     spEdFacilitatorUserID;
        public string   spEdFacilitatorUserName;
        public long     spEdCaseManagerUserID;
        public string   spEdCaseManagerUserName;
        public DateTime spEdMeetingDate;
        public string   spEdMeetingDateYMD;
        public int      spEdMeetingDurationInMins;
        public string   spEdMeetingTime;
        public string   spEdMeetingTitle;

        public string  spEdVehicleAdaptationTypes;
        public string  spEdVehicleAdaptationTypeNames;

        public string   preferredNickname;

        public string   teacherOrCounselorName;

        public string   teacherOrCounselorOrCaseManagerName;


        public bool    inTransitionalHousingStatus;
        public string  inTransitionalHousingStatusYN;
        public string  submitClaimsEffectiveDateYMD;
        public string  cybhiSubmitClaimsYN;
        public string  parentConsentMCALYNU;
        public string  cybhiTpaApprovedYN;
        public string  cybhiTpaApprovedOnYMD;
        public string  parentConsentMCALEffectiveDateYMD;
        public string  ferpaConsentYNU;
        public string  ferpaConsentEffectiveDateYMD;
        public string  speciallyAdaptedVehicleForTransportationYN;
        public string  treatmentConsentYNU;
        public string  treatmentConsentEffectiveDateYMD;
        public string  hasIEPYN;
        public bool    deceased;
        public string  deceasedYN;
        
        public long    patientHomePlaceID;
        public string  patientHomePlaceName;
        public string  minorConsentYN;
        public bool?   minorConsent;
        public string  minorConsentEffectiveDateYMD;
        public DateTime? minorConsentEffectiveDate;
        public long?   patientUserIDInt;
    }

    /***************************************************************************
     * Patients */
    /**
     * Patients receive services from practitioners.  Patients are associated
     * with a client and a practitioner.
     ***************************************************************************/

    public class Patients : Entities
    {

        public const string SEL_LABEL_MANAGE                = @"Manage Patients";
        public const string SEL_LABEL_SAVE                  = @"Patients - Save";
        public const string MENU_ID_MANAGE                  = @"patientsmanage";
        public const string URL_USER_ALL_MANAGE             = @"user_all_pat_manage.aspx";
        //public const string URL_USER_ALL_SAVE             = @"user_all_pat_save.aspx";
        public const string URL_USER_ALL_SAVE               = @"user_all_pat_save_2.aspx";
        public const string URL_USER_ALL_VIEW               = @"user_all_pat_view.aspx";
        public const string URL_REST_VIEW                   = @"api/v1/patients";
        public const string URL_SVC_BASE                    = @"patients.asmx";
        public const string URL_WEB_REPORT                  = @"patients.ashx";
        public const string URL_SVC_DELETE_INLINE           = URL_SVC_BASE + @"/deleteinline";
        public const string URL_SVC_UNDELETE_INLINE         = URL_SVC_BASE + @"/undeleteinline";
        public const string URL_SVC_VIEW_SEL                = URL_SVC_BASE + "/viewSel";
        public const string URL_SVC_VIEW_SEL2               = URL_SVC_BASE + "/viewSel2";
        public const string URL_SVC_VIEW_SEL_TRANS          = URL_SVC_BASE + "/viewSelForTransMgmt";
        public const string URL_SVC_SAVE_PROFILE            = URL_SVC_BASE + "/saveprofile";
        public const string URL_SVC_GET                     = URL_SVC_BASE + "/get";
        public const string URL_SVC_CYBHI_PROCESS_FILE      = URL_SVC_BASE + "/cybhipatsprocessfile";
        public const string URL_USER_ALL_IEP_SAVE           = @"user_all_pat_iep_save.aspx";
        public const string URL_SVC_SEND_MEETING_INVITES    = URL_SVC_BASE + @"/sendmeetinginvites";
        public const string URL_SVC_RESEND_MEETING_INVITE   = URL_SVC_BASE + @"/resendmeetinginvite";
        public const string URL_SVC_SAVE_IEP                = URL_SVC_BASE + "/saveiep";
        public const string URL_SVC_SAVE_PATIENTS_INFO      = URL_SVC_BASE + "/updatepatientdata";
        public const string URL_INVITE_PORTAL               = URL_SVC_BASE + @"/invitePatientToPortal";
        public const string URL_SVC_UPDATE_MEETING_STATUS = URL_SVC_BASE + @"/updatemeetingstatus";

        /***************************************************************************
         * URL_REST_VIEW */
        /**
         * 
         **************************************************************************/
        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(Patients.URL_REST_VIEW, true);
        }

        /***************************************************************************
         * URL_SVC_DELETE_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SVC_DELETE_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(Patients.URL_SVC_DELETE_INLINE, true);
        }

        /***************************************************************************
         * URL_SVC_UNDELETE_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SVC_UNDELETE_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(Patients.URL_SVC_UNDELETE_INLINE, true);
        }

        /***************************************************************************
         * URL_SVC_SAVE_PROFILE_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SVC_SAVE_PROFILE_BASE()
        {
          return MBA.HttpApplication.createLink(Patients.URL_SVC_SAVE_PROFILE, true);
        }

        /***************************************************************************
         * URL_SVC_GET_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SVC_GET_BASE()
        {
            return MBA.HttpApplication.createLink(Patients.URL_SVC_GET, true);
        }

        /***************************************************************************
         * URL_WEB_REPORT_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_WEB_REPORT_BASE()
        {
            return MBA.HttpApplication.createLink(Patients.URL_WEB_REPORT, true);
        }

        public static string URL_SVC_VIEW_SEL_BASE()
        {
            return MBA.HttpApplication.createLink(URL_SVC_VIEW_SEL, true);
        }

        public static string URL_SVC_VIEW_SEL2_BASE()
        {
            return MBA.HttpApplication.createLink(URL_SVC_VIEW_SEL2, true);
        }

        public static string URL_SVC_VIEW_SEL_TRANS_BASE()
        {
            return MBA.HttpApplication.createLink(Patients.URL_SVC_VIEW_SEL_TRANS, true);
        }

        public static string URL_USER_ALL_SAVE_NEW_BASE(bool subPage = true)
        {
            var appModeValue = (subPage) ? Constants.AMD_UI_DBS_SUB_PAGE : @"";

            return MBA.HttpApplication.createLink(Patients.URL_USER_ALL_SAVE
                                                   , true
                                                   , new NameValue(Constants.PARM_APP_MODE, appModeValue)
                                                   , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW)
                                                  );
        }
        public static string URL_USER_ALL_EDIT_EXISTING_BASE(bool subPage = true, string recid = "")
        {
            var appModeValue = (subPage) ? Constants.AMD_UI_DBS_SUB_PAGE : @"";

            return MBA.HttpApplication.createLink(Patients.URL_USER_ALL_SAVE
                                                   , true
                                                   , new NameValue(Constants.PARM_APP_MODE, appModeValue)
                                                   , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)
                                                   , new NameValue(Constants.PARM_REC_ID, recid));
        }

        public static string URL_SVC_CYBHI_PROCESS_FILE_BASE()
        {
            return MBA.HttpApplication.createLink(Patients.URL_SVC_CYBHI_PROCESS_FILE
                                                   , true);            
        }

        public static string URL_CYBHI_PROCESS_FILE_BASE ()
        {
            return MBA.HttpApplication.createLink( "user_all_cybhi_patients_process_tpa_file.aspx"
                                                   , true);                        
        }


        public static string URL_USER_ALL_IEP_SAVE_BASE()
        {
            return MBA.HttpApplication.createLink(Patients.URL_USER_ALL_IEP_SAVE
                , true
                , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE));
        }  

        public static string URL_SVC_SAVE_PATIENTS_INFO_BASE()
        {
            return MBA.HttpApplication.createLink(URL_SVC_SAVE_PATIENTS_INFO, true);
        }

        public static string URL_SVC_UPDATE_MEETING_STATUS_BASE()
        {
            return MBA.HttpApplication.createLink(URL_SVC_UPDATE_MEETING_STATUS, true);
        }

        /***************************************************************************
         * URL_INVITE_PATIENT_TO_PORTAL_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_INVITE_PATIENT_TO_PORTAL_BASE()
        {
            return MBA.HttpApplication.createLink(Patients.URL_INVITE_PORTAL, true);
        }

        /***************************************************************************
         * updatepatientdata */
        /**
         * "Updates" a person data phone, email, address, city, state, zip5, zip4
         *          
         * @param  recID           Record id reference for edit and delete
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/
        public static ReturnSaveRecord updatepatientdata(SqlConnection connSpedmon
                                                                        , DetailsLog log
                                                                        , UserInfo uInfo
                                                                        , string clientID
                                                                        , string patID
                                                                        , string phone
                                                                        , string email
                                                                        , string street1
                                                                        , string street2
                                                                        , string city
                                                                        , string state
                                                                        , string zip5
                                                                        , string zip4
                                                                        , string patientHomePlaceID
                                                                        , string contactMethod)
        {
            ReturnSaveRecord so = new ReturnSaveRecord();

            var parms = new List<SqlParameter>();

            string opSproc = "PATIENT_DATA_SAVE";

            long vClientID              = Validate.reqClientID(     uInfo,                   clientID);
            var vEmail                  = Validate.optEmail(        email,                   Messages.INVALID_EMAIL);
            var vPhone                  = Validate.optPhoneNumber(  phone,                   Messages.INVALID_PHONE_NUMBER);
            var vPatientHomePlaceID     = Validate.optInteger(      patientHomePlaceID,      @"Invalid place id", true);
            string vContactMethod       = Validate.optString(       contactMethod,           @"Invalid Contact Method");

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt,   vClientID,  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@phone",    SqlDbType.NVarChar, vPhone,     ParameterDirection.Input));
            parms.Add(Database.SqlParm("@email",    SqlDbType.NVarChar, vEmail,     ParameterDirection.Input));            

            validateAndAddCommonAddressParameters(ref street1
                                                   , ref street2
                                                   , ref city
                                                   , ref state
                                                   , ref zip5
                                                   , ref zip4
                                                   , ref parms);

            parms.Add(Database.SqlParm("@patientHomePlaceID",   SqlDbType.BigInt,   vPatientHomePlaceID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@contactMethod",        SqlDbType.VarChar,  vContactMethod, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@MsgNoClient",          SqlDbType.VarChar, Messages.INVALID_CLIENT_ID, ParameterDirection.Input));

            return Entities.recordOp(connSpedmon
                                        , log
                                        , uInfo
                                        , ""
                                        , "N"
                                        , patID
                                        , opSproc
                                        , ref parms);
        }

        /***************************************************************************
          * URL_SVC_SEND_MEETING_INVITES_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SVC_SEND_MEETING_INVITES_BASE()
        {
            return MBA.HttpApplication.createLink(Patients.URL_SVC_SEND_MEETING_INVITES
                                                   , true
                                                 );
        }

        /***************************************************************************
         * URL_SVC_RESEND_MEETING_INVITE_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SVC_RESEND_MEETING_INVITE_BASE()
        {
            return MBA.HttpApplication.createLink(Patients.URL_SVC_RESEND_MEETING_INVITE
                                                   , true
                                                 );
        }


        /***************************************************************************
         * IEPTypeData */
        /*****************************************************************************/

        private class IEPTypeData
        {
            public long id = 0;
        }


        /***************************************************************************
         * SessionRoomData */
        /****************************************************************************/

        private class SessionRoomData
        {
            public string roomID = "";
        }
        private static string formatPhoneForTeleComm(string rawPhone)
        {
            if (String.IsNullOrWhiteSpace(rawPhone)) return "";
            string digits = System.Text.RegularExpressions.Regex.Replace(rawPhone, @"\D", "");
            if (digits.Length == 0) return "";
            return digits;
        }
        private class SessionParticipantLookup
       {
            public string email = "";
            public string pin = "";
            public string name = "";
            public string title = "";
       }
        private class ParticipantEmailData
        {
            public string email = "";
        }

        /***************************************************************************
         * convertGridJSONToTeleCommParticipantJSON */
        /*****************************************************************************/
        private static string convertGridJSONToTeleCommParticipantJSON(string gridJSON)
        {
            if (String.IsNullOrWhiteSpace(gridJSON)) return gridJSON;

            try
            {
        

                if (gridJSON.IndexOf("participantdetails", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    return gridJSON;
                }

            

                var gridObj = (Newtonsoft.Json.Linq.JObject)Newtonsoft.Json.JsonConvert.DeserializeObject(gridJSON);

                if (gridObj == null) return gridJSON;

                var participantsArray = gridObj["participants"] as Newtonsoft.Json.Linq.JArray;

                if (participantsArray == null || participantsArray.Count == 0) return gridJSON;

             

                var detailsObj = new MBA.TeleCommParticipantsDetails();
                detailsObj.participantdetails = new List<MBA.TeleCommParticipant>();

                foreach (var p in participantsArray)
                {
                    string title = (string)p["title"] ?? "";
                    long roleID = MBA.TeleCommParticipants.PARTICIPANT_ROLE_OTHER;

                    if (title.IndexOf("Parent", StringComparison.OrdinalIgnoreCase) >= 0
                     || title.IndexOf("Guardian", StringComparison.OrdinalIgnoreCase) >= 0
                     || title.IndexOf("Surrogate", StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        roleID = MBA.TeleCommParticipants.PARTICIPANT_ROLE_PARENT_GUARD;
                    }
                    else if (title.IndexOf("Student", StringComparison.OrdinalIgnoreCase) >= 0
                          || title.IndexOf("Adult", StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        roleID = MBA.TeleCommParticipants.PARTICIPANT_ROLE_PATIENT;
                    }
                    else if (title.IndexOf("LEA", StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        roleID = MBA.TeleCommParticipants.PARTICIPANT_ROLE_LEA_COOR;
                    }
                    else if (title.IndexOf("General Education", StringComparison.OrdinalIgnoreCase) >= 0
                          || title.IndexOf("Special Education", StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        roleID = MBA.TeleCommParticipants.PARTICIPANT_ROLE_PRACTITIONER;
                    }

                    var tp = new MBA.TeleCommParticipant(
                        (int)(p["id"] ?? 0),
                        title,
                        roleID
                    );

                    tp.name = (string)(p["name"] ?? "");
                    tp.email = (string)(p["email"] ?? "");
                    string rawPhone = ((string)(p["phone"] ?? "")).Trim();
                    string phoneDigits = System.Text.RegularExpressions.Regex.Replace(rawPhone, @"\D", "");
                    if (phoneDigits.Length == 10)
                    {
                        tp.phone = "(" + phoneDigits.Substring(0, 3) + ") " + phoneDigits.Substring(3, 3) + "-" + phoneDigits.Substring(6, 4);
                    }
                    else
                    {
                        tp.phone = "";
                    }
                    detailsObj.participantdetails.Add(tp);
                }

             

                var detailsStr = MBA.JSON.toJSONString(detailsObj, MBA.JsonLibrary.NEWTONSOFT);
                var detailsStrMod = Util.jsonStringReplaceAllNonStringValuesWithStringValues(detailsStr);

                return detailsStrMod;
            }
            catch
            {
                return gridJSON;
            }
        }

        /***************************************************************************
         * sendMeetingInvites */
        /**
         * If meeting date/time/duration match existing session and session
         * is still in the future: reuse session, add only new participants,
         * send invites only to new participants.
         * 
         * If anything changed or no session exists: create new session,
         * send invites to everyone.
         ***************************************************************************/
        public static ReturnSaveRecordWithJSONData sendMeetingInvites(SqlConnection connUsers
                                                                    , SqlConnection connSpedmon
                                                                    , DetailsLog log
                                                                    , UserInfo uInfo
                                                                    , string clientID
                                                                    , string patID
                                                                    , string filesToShareUploadIDs)
        {
            ReturnSaveRecordWithJSONData so = new ReturnSaveRecordWithJSONData();

            clientID = Validate.reqClientID(uInfo, clientID).ToString();
            patID = Validate.reqInteger(patID, Messages.INVALID_PAT_ID).ToString();

            Patient pat = Patients.load(connSpedmon, log, uInfo, patID);

            if (pat == null || pat.id == 0)
            {
                so.status = Return.RET_ERROR;
                so.message = @"Patient record not found.";
                return so;
            }

            if (pat.spEdFacilitatorUserID == 0)
            {
                so.status = Return.RET_ERROR;
                so.message = @"Please select an IEP Meeting Contact before sending invites.";
                return so;
            }

            if (String.IsNullOrWhiteSpace(pat.spEdMeetingDateYMD))
            {
                so.status = Return.RET_ERROR;
                so.message = @"Please enter a Meeting Date before sending invites.";
                return so;
            }

            if (String.IsNullOrWhiteSpace(pat.spEdMeetingTime))
            {
                so.status = Return.RET_ERROR;
                so.message = @"Please enter a Meeting Time before sending invites.";
                return so;
            }

            /*========================================================
             * Get IEP form type
             *========================================================*/

            string iepFormTypeID = "0";
            string iepTypeSql = @"select top 1 id from dbo.TELECOMM_IEP_TYPES where (active = 1)";
            ReturnDB iepTypeRd = Database.execQuery(connSpedmon, log, iepTypeSql, false, null);

            if (iepTypeRd.hasRecords)
            {
                var iepTypeData = (IEPTypeData)Database.convertRecord(iepTypeRd.records, typeof(IEPTypeData));
                iepFormTypeID = iepTypeData.id.ToString();
            }

            /*========================================================
             * Check for existing session
             *========================================================*/

            TeleIEPSession existingSession = null;

            try
            {
                existingSession = TeleIEPSessions.loadLastEnteredForClientPatient(
                    connSpedmon, log, uInfo, clientID, patID);
            }
            catch { existingSession = null; }

            if (existingSession != null && existingSession.id > 0)
            {
                /*========================================================
                 * Compare meeting date, time, and duration
                 * If all match: reuse session
                 * If anything changed: fall through to create new
                 *========================================================*/

                bool canReuseSession = false;

                try
                {
                    DateTime patMeetingDate = DateTime.Parse(pat.spEdMeetingDateYMD);
                    bool dateMatches = (existingSession.meetingDate.Date == patMeetingDate.Date);

                    bool timeMatches = false;
                    if (!String.IsNullOrWhiteSpace(pat.spEdMeetingTime)
                        && existingSession.meetingTime != TimeSpan.Zero)
                    {
                        try
                        {
                            TimeSpan patTime = TimeSpan.Parse(pat.spEdMeetingTime.Trim());
                            timeMatches = (existingSession.meetingTime == patTime);
                        }
                        catch { timeMatches = false; }
                    }

                    bool durationMatches = (existingSession.meetingDurationInMins == pat.spEdMeetingDurationInMins);

                    bool titleMatches = (existingSession.title ?? "").Trim()
                                            .Equals((pat.spEdMeetingTitle ?? "").Trim(),
                                                    StringComparison.OrdinalIgnoreCase);

                    canReuseSession = dateMatches && timeMatches && durationMatches && titleMatches;
                }
                catch { canReuseSession = false; }

                if (canReuseSession)
                {
                    try
                    {
                        /*========================================================
                         * Get room ID from Users DB
                         *========================================================*/

                        var sessionParms = new List<SqlParameter>();
                        sessionParms.Add(Database.SqlParm("@sessionID", SqlDbType.BigInt, existingSession.id, ParameterDirection.Input));

                        string sessionSql = @"select top 1 roomID from dbo.TELECOMM_SESSIONS where (id = @sessionID)";
                        ReturnDB sessionRd = Database.execQuery(connUsers, log, sessionSql, false, sessionParms);

                        if (!sessionRd.hasRecords)
                            goto CREATE_NEW_SESSION;

                        var roomData = (SessionRoomData)Database.convertRecord(sessionRd.records, typeof(SessionRoomData));

                        if (String.IsNullOrWhiteSpace(roomData.roomID))
                            goto CREATE_NEW_SESSION;

                        /*========================================================
                         * Get emails already in this session
                         *========================================================*/

                        var existingPartParms = new List<SqlParameter>();
                        existingPartParms.Add(Database.SqlParm("@sessionID", SqlDbType.BigInt, existingSession.id, ParameterDirection.Input));

                        string existingPartSql = @"select email from dbo.TELECOMM_SESSIONS_PARTICIPANTS where (telecommSessionID = @sessionID) and (email is not null) and (email != '')";
                        ReturnDB existingPartRd = Database.execQuery(connUsers, log, existingPartSql, false, existingPartParms);

                        var existingEmails = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                        if (existingPartRd.hasRecords)
                        {
                            List<Object> emailList = Database.convertRecordsToList(ref existingPartRd.records, typeof(ParticipantEmailData));
                            foreach (var obj in emailList)
                            {
                                var ped = (ParticipantEmailData)obj;
                                if (!String.IsNullOrWhiteSpace(ped.email))
                                    existingEmails.Add(ped.email.Trim());
                            }
                        }

                        /*========================================================
                         * Parse current participants from patient grid JSON
                         *========================================================*/

                        string gridJSON = pat.spEdParticipantDetailsJSON;
                        var gridObj = (Newtonsoft.Json.Linq.JObject)Newtonsoft.Json.JsonConvert.DeserializeObject(gridJSON);
                        var participantsArray = gridObj["participants"] as Newtonsoft.Json.Linq.JArray;
                        if (participantsArray == null)
                            participantsArray = gridObj["participantdetails"] as Newtonsoft.Json.Linq.JArray;

                        if (participantsArray == null || participantsArray.Count == 0)
                        {
                            so.status = Return.RET_SUCCESS;
                            so.message = @"No participants to invite.";
                            return so;
                        }

                        /*========================================================
                         * Add new participants to existing session
                         *========================================================*/

                        var newParticipantEmails = new List<string>();

                        foreach (var p in participantsArray)
                        {
                            string pEmail = ((string)p["email"] ?? "").Trim();
                            string pName = ((string)p["name"] ?? "").Trim();
                            string pTitle = ((string)p["title"] ?? "").Trim();

                            if (String.IsNullOrWhiteSpace(pEmail) || String.IsNullOrWhiteSpace(pName)) continue;

                            if (!existingEmails.Contains(pEmail))
                            {
                                var addParms = new List<SqlParameter>();
                                addParms.Add(Database.SqlParm("@sessionID", SqlDbType.BigInt, existingSession.id, ParameterDirection.Input));
                                addParms.Add(Database.SqlParm("@name", SqlDbType.VarChar, pName, ParameterDirection.Input, 256));
                                addParms.Add(Database.SqlParm("@title", SqlDbType.VarChar, pTitle, ParameterDirection.Input, 256));
                                addParms.Add(Database.SqlParm("@email", SqlDbType.VarChar, pEmail, ParameterDirection.Input, 256));
                                addParms.Add(Database.SqlParm("@recordID", SqlDbType.BigInt, 0, ParameterDirection.Output));

                                Database.execSproc(connUsers, log, "TELECOMM_SESSION_ADD_PARTICIPANT", addParms);
                                newParticipantEmails.Add(pEmail);
                            }
                        }

                        if (newParticipantEmails.Count == 0)
                        {
                            so.status = Return.RET_SUCCESS;
                            so.message = @"All participants have already been invited.";
                            return so;
                        }

                        /*========================================================
                         * Get invitation data using any existing participant
                         * Uses the RESEND sproc which skips date check
                         *========================================================*/

                        var anyPartParms = new List<SqlParameter>();
                        anyPartParms.Add(Database.SqlParm("@sessionID", SqlDbType.BigInt, existingSession.id, ParameterDirection.Input));
                        string anyPartSql = @"select top 1 email, pin, name, title from dbo.TELECOMM_SESSIONS_PARTICIPANTS where (telecommSessionID = @sessionID) and (email is not null) and (email != '')";
                        ReturnDB anyPartRd = Database.execQuery(connUsers, log, anyPartSql, false, anyPartParms);

                        if (!anyPartRd.hasRecords)
                        {
                            so.status = Return.RET_ERROR;
                            so.message = @"Unable to retrieve session invitation data.";
                            return so;
                        }

                        var lookupParticipant = (SessionParticipantLookup)Database.convertRecord(anyPartRd.records, typeof(SessionParticipantLookup));

                        var inviteParms = new List<SqlParameter>();
                        inviteParms.Add(Database.SqlParm("@roomID", SqlDbType.VarChar, roomData.roomID, ParameterDirection.Input, 256));
                        inviteParms.Add(Database.SqlParm("@email", SqlDbType.VarChar, lookupParticipant.email, ParameterDirection.Input, 256));
                        inviteParms.Add(Database.SqlParm("@pin", SqlDbType.VarChar, lookupParticipant.pin, ParameterDirection.Input, 50));

                        ReturnSaveRecordWithJSONData inviteData = Entities.saveAndReturnJSONData(connUsers
                            , log, uInfo, "1", "0", "", null
                            , "TELECOMM_SESSION_GET_PARTICIPANT_INVITATION_DATA_FOR_RESEND"
                            , @"Duplicate meeting", ref inviteParms, delegate () { });

                        if (inviteData.status != Return.RET_SUCCESS)
                        {
                            so.status = inviteData.status;
                            so.message = inviteData.message;
                            return so;
                        }

                        /*========================================================
                         * Filter to only new participants and send
                         *========================================================*/

                        MBA.TelecommSessionSaveReturnData srd = (MBA.TelecommSessionSaveReturnData)MBA.JSON.fromJSONString(
                            inviteData.jsonData, typeof(MBA.TelecommSessionSaveReturnData), MBA.JsonLibrary.NEWTONSOFT);

                        var newEmailSet = new HashSet<string>(newParticipantEmails, StringComparer.OrdinalIgnoreCase);
                        var filteredParticipants = new List<MBA.TeleCommParticipant>();

                        foreach (var p in srd.participants)
                        {
                            if (!Util.IsNullOrEmpty(p.email) && newEmailSet.Contains(p.email.Trim()))
                                filteredParticipants.Add(p);
                        }

                        srd.participants = filteredParticipants;
                        MBA.TeleCommSessions.sendSessionParticipantInvites(srd);

                        so.status = Return.RET_SUCCESS;
                        so.message = @"Invites sent to " + newParticipantEmails.Count + " new participant(s).";
                        return so;
                    }
                    catch (Exception exReuse)
                    {
                        so.status = Return.RET_ERROR;
                        so.message = @"Error adding participants to existing session: " + exReuse.Message;
                        return so;
                    }
                }
            }

        /*========================================================
         * CREATE NEW SESSION
         * Meeting details changed or no existing session
         * Create new session and send invites to everyone
         *========================================================*/

        CREATE_NEW_SESSION:

            string teleCommParticipantJSON = convertGridJSONToTeleCommParticipantJSON(pat.spEdParticipantDetailsJSON);

            try
            {
                so = TeleIEPSessions.save(connUsers
                                             , connSpedmon
                                             , log
                                             , uInfo
                                             , clientID
                                             , pat.spEdFacilitatorUserID.ToString()
                                             , patID
                                             , iepFormTypeID
                                             , pat.spEdMeetingDateYMD
                                             , pat.spEdMeetingTime
                                             , pat.spEdMeetingDurationInMins.ToString()
                                             , pat.spEdMeetingTitle
                                             , teleCommParticipantJSON
                                             , filesToShareUploadIDs
                                             , Constants.SAVE_TYPE_NEW.ToString()
                                             , "0"
                                             , ""
                                             , "");
            }
            catch (Exception exSave)
            {
                so.status = Return.RET_ERROR;
                so.message = @"Failed to create meeting session: " + exSave.Message;
            }

            return so;
        }


        /***************************************************************************
         * resendMeetingInvite */
        /**
         * Resends invite to a single participant.
         * If participant not found in session, adds them first
         * via TELECOMM_SESSION_ADD_PARTICIPANT, then sends.
         * Uses the RESEND sproc which skips the meeting date check.
         ***************************************************************************/
        public static ReturnSaveRecord resendMeetingInvite(SqlConnection connUsers
                                                              , SqlConnection connSpedmon
                                                              , DetailsLog log
                                                              , UserInfo uInfo
                                                              , string clientID
                                                              , string patID
                                                              , string participantEmail
                                                              , string participantName
                                                              , string participantRole)
        {
            ReturnSaveRecord so = new ReturnSaveRecord();

            clientID = Validate.reqClientID(uInfo, clientID).ToString();
            patID = Validate.reqInteger(patID, Messages.INVALID_PAT_ID).ToString();
            participantEmail = Validate.reqEmail(participantEmail, @"Participant email is required");

            /*========================================================
             * Load last existing session for this patient
             *========================================================*/

            TeleIEPSession lastSession = TeleIEPSessions.loadLastEnteredForClientPatient(
                connSpedmon, log, uInfo, clientID, patID);

            if (lastSession == null || lastSession.id == 0)
            {
                so.status = Return.RET_ERROR;
                so.message = @"No meeting session found. Please send meeting invites first.";
                return so;
            }

            /*========================================================
             * Get room ID
             *========================================================*/

            var sessionParms = new List<SqlParameter>();
            sessionParms.Add(Database.SqlParm("@sessionID", SqlDbType.BigInt, lastSession.id, ParameterDirection.Input));

            string sessionSql = @"select top 1 roomID from dbo.TELECOMM_SESSIONS where (id = @sessionID)";
            ReturnDB sessionRd = Database.execQuery(connUsers, log, sessionSql, false, sessionParms);

            if (!sessionRd.hasRecords)
            {
                so.status = Return.RET_ERROR;
                so.message = @"Meeting session room not found.";
                return so;
            }

            var roomData = (SessionRoomData)Database.convertRecord(sessionRd.records, typeof(SessionRoomData));

            if (String.IsNullOrWhiteSpace(roomData.roomID))
            {
                so.status = Return.RET_ERROR;
                so.message = @"Meeting session room not found.";
                return so;
            }

            try
            {
                /*========================================================
                 * Check if participant exists in session
                 *========================================================*/

                var findParms = new List<SqlParameter>();
                findParms.Add(Database.SqlParm("@sessionID", SqlDbType.BigInt, lastSession.id, ParameterDirection.Input));
                findParms.Add(Database.SqlParm("@email", SqlDbType.VarChar, participantEmail.Trim(), ParameterDirection.Input, 256));

                string findSql = @"select top 1 email, pin, name, title from dbo.TELECOMM_SESSIONS_PARTICIPANTS where (telecommSessionID = @sessionID) and (email = @email)";
                ReturnDB findRd = Database.execQuery(connUsers, log, findSql, false, findParms);

                SessionParticipantLookup foundParticipant = null;

                if (findRd.hasRecords)
                {
                    foundParticipant = (SessionParticipantLookup)Database.convertRecord(findRd.records, typeof(SessionParticipantLookup));
                }

                /*========================================================
                 * If not found, add them to the session first
                 *========================================================*/

                if (foundParticipant == null)
                {
                    var addParms = new List<SqlParameter>();
                    addParms.Add(Database.SqlParm("@sessionID", SqlDbType.BigInt, lastSession.id, ParameterDirection.Input));
                    addParms.Add(Database.SqlParm("@name", SqlDbType.VarChar, (participantName ?? "").Trim(), ParameterDirection.Input, 256));
                    addParms.Add(Database.SqlParm("@title", SqlDbType.VarChar, (participantRole ?? "").Trim(), ParameterDirection.Input, 256));
                    addParms.Add(Database.SqlParm("@email", SqlDbType.VarChar, participantEmail.Trim(), ParameterDirection.Input, 256));
                    addParms.Add(Database.SqlParm("@recordID", SqlDbType.BigInt, 0, ParameterDirection.Output));

                    Database.execSproc(connUsers, log, "TELECOMM_SESSION_ADD_PARTICIPANT", addParms);

                    // Re-lookup the participant we just inserted
                    var refindParms = new List<SqlParameter>();
                    refindParms.Add(Database.SqlParm("@sessionID", SqlDbType.BigInt, lastSession.id, ParameterDirection.Input));
                    refindParms.Add(Database.SqlParm("@email", SqlDbType.VarChar, participantEmail.Trim(), ParameterDirection.Input, 256));

                    string refindSql = @"select top 1 email, pin, name, title from dbo.TELECOMM_SESSIONS_PARTICIPANTS where (telecommSessionID = @sessionID) and (email = @email)";
                    ReturnDB refindRd = Database.execQuery(connUsers, log, refindSql, false, refindParms);

                    if (refindRd.hasRecords)
                        foundParticipant = (SessionParticipantLookup)Database.convertRecord(refindRd.records, typeof(SessionParticipantLookup));

                    if (foundParticipant == null)
                    {
                        so.status = Return.RET_ERROR;
                        so.message = @"Unable to add participant to the meeting session.";
                        return so;
                    }
                }

                /*========================================================
                 * Get invitation data using the RESEND sproc
                 * which skips the meeting date check
                 *========================================================*/

                var inviteParms = new List<SqlParameter>();
                inviteParms.Add(Database.SqlParm("@roomID", SqlDbType.VarChar, roomData.roomID, ParameterDirection.Input, 256));
                inviteParms.Add(Database.SqlParm("@email", SqlDbType.VarChar, foundParticipant.email, ParameterDirection.Input, 256));
                inviteParms.Add(Database.SqlParm("@pin", SqlDbType.VarChar, foundParticipant.pin, ParameterDirection.Input, 50));

                ReturnSaveRecordWithJSONData inviteData = Entities.saveAndReturnJSONData(connUsers
                    , log, uInfo, "1", "0", "", null
                    , "TELECOMM_SESSION_GET_PARTICIPANT_INVITATION_DATA_FOR_RESEND"
                    , @"Duplicate meeting", ref inviteParms, delegate () { });

                if (inviteData.status != Return.RET_SUCCESS)
                {
                    so.status = inviteData.status;
                    so.message = inviteData.message;
                    return so;
                }

                /*========================================================
                 * Filter to just this one participant and send
                 *========================================================*/

                MBA.TelecommSessionSaveReturnData srd = (MBA.TelecommSessionSaveReturnData)MBA.JSON.fromJSONString(
                    inviteData.jsonData, typeof(MBA.TelecommSessionSaveReturnData), MBA.JsonLibrary.NEWTONSOFT);

                var filteredParticipants = new List<MBA.TeleCommParticipant>();

                foreach (var p in srd.participants)
                {
                    if (!Util.IsNullOrEmpty(p.email)
                        && p.email.Trim().Equals(participantEmail.Trim(), StringComparison.OrdinalIgnoreCase))
                    {
                        filteredParticipants.Add(p);
                        break;
                    }
                }

                srd.participants = filteredParticipants;
                MBA.TeleCommSessions.sendSessionParticipantInvites(srd);

                so.status = Return.RET_SUCCESS;
                so.message = @"Invite sent to " + participantEmail;
            }
            catch (Exception e)
            {
                so.status = Return.RET_ERROR;
                so.message = @"Failed to resend invite: " + e.Message;
            }

            return so;
        }
        /***************************************************************************
         * delete */
        /**
         * "Deletes" a patients record
         * 
         * @param  editDelReason   Reason for edit/delete 
         * @param  validateRec     Perform validation for this record?
         * @param  recID           Record id reference for edit and delete
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/

        public static ReturnSaveRecord delete(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                               string editDelReason, string validateRec, string recID)
        {

            /*----------------------------
             * Check for required and 
             * optional parameters
             * and validate data integrity
             * of all supplied parameters
             *----------------------------*/

            Object vClientID = Validate.optClientID(uInfo, "");

            /*----------------------------
             * Collect all of the parameters
             * that are specific to this
             * delete method.
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

            /*----------------------------
             * Call base method 
             *----------------------------*/

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "PATIENTS_Delete", ref parms);
        }

        /***************************************************************************
         * unDelete */
        /**
         * "Deletes" a patients record
         * 
         * @param  editDelReason   Reason for edit/delete 
         * @param  validateRec     Perform validation for this record?
         * @param  recID           Record id reference for edit and delete
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/

        public static ReturnSaveRecord unDelete(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                               string editDelReason, string validateRec, string recID)
        {

            /*----------------------------
             * Check for required and 
             * optional parameters
             * and validate data integrity
             * of all supplied parameters
             *----------------------------*/

            Object vClientID = Validate.optClientID(uInfo, "");

            /*----------------------------
             * Collect all of the parameters
             * that are specific to this
             * delete method.
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

            /*----------------------------
             * Call base method 
             *----------------------------*/

            return Entities.unDelete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "PATIENTS_Undelete", ref parms);
        }

        /***************************************************************************
         * viewEntity */
        /**
         * Outputs data for a single patient
         * 
         * @param  connSpedmon     Spedmon database connection object
         * @param  log             Logging object
         * @param  clientID        Client ID
         * @param  patID           PatientID
         * @return                 ReturnEntity
         ***************************************************************************/

        public static ReturnEntity viewEntity(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                               string clientID,
                                               string patID)
        {

            // TODO: Legacy remove

            ReturnEntity so = new ReturnEntity();
            Patient p = load(connSpedmon, log, uInfo, patID);
            so.entity = (Entity)p;

            /*-------------------------------
             * Retrieve eligibility data
             * info and convert it to a 
             * note string
             *------------------------------*/

            ReturnInfoTable ei = viewCurrentEligInfo(connSpedmon, log, uInfo, clientID, patID);
            string einotes = ReturnInfoTable.ToNoteString(ei, 15);

            /*-------------------------------
             * Prepend eligibility data info
             * to patients notes or if there
             * is no data, append a notice
             * saying so
             *------------------------------*/

            if (!Util.IsNullOrEmpty(einotes)) einotes = "Eligibility Data\n\n" + einotes;
            else einotes = "No Eligibility Data\n\n";


            so.entity.notes = einotes + "<hr>" + so.entity.notes;

            return so;
        }

        /***************************************************************************
         * viewCurrentEligInfo */
        /**
         * Outputs eligibility info for the given clientID and patientID
         * 
         * @param  connSpedmon     Spedmon database connection object
         * @param  log             Logging object
         * @param  clientID        Client ID
         * @param  patID           PatientID
         * @return                 ReturnInfoTable
         ***************************************************************************/

        public static ReturnInfoTable viewCurrentEligInfo(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string clientID, string patID)
        {

            /*----------------------------
              * Validate parameters specific
              * to this entity.view
              * and populate their
              * coresponding database
              * parameters
              *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

            string viewUDF = "PATIENT_VIEW_ELIGIBILITY_INFO (@clientID, @patID)";

            int vClientID = Validate.reqClientID(uInfo, clientID);
            int vPatID = Validate.reqInteger(patID, Messages.INVALID_PAT_ID);

            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID", SqlDbType.Int, vPatID, ParameterDirection.Input));

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.viewInfoTbl(connSpedmon, log, uInfo, viewUDF, parms);

        }

        /***************************************************************************
         * load */
        /**
         * Outputs data for a single patient
         * 
         * Note: This calls the view method and the view method takes care of
         * enforcing the client id.
         * 
         * @param  connSpedmon     Spedmon database connection object
         * @param  log             Logging object
         * @param  clientID        Client ID
         * @param  patID           PatID
         * @return                 ReturnEntity
         ***************************************************************************/
        public static Patient load(
                    SqlConnection connSpedmon
                   , DetailsLog log
                   , UserInfo uInfo
                   , string recID)
        {
            return (Patient)Entities.load(connSpedmon, log, uInfo, recID, typeof(Patient),
            delegate { return Patients.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", "", "", "", "", "", "", "", "", "", null); });
        }

        /***************************************************************************
         * get */
        /**
         * Gets patient record
         *
         * Note: This calls the load method which calls the view method and the 
         * view method takes care of enforcing the client id.
         * 
         * @return            ReturnObject
         ***************************************************************************/

        public static ReturnObject get ( 
             SqlConnection connSpedmon
            , DetailsLog   log
            , UserInfo     uInfo            
            , string       recID )
        {

            var so      = new ReturnObject();
            var objType = typeof(Patient);

            so.hasRecord = false;
            so.objectFullName = objType.FullName;
            
            Patient pat = null;
            try { 
              pat = load(connSpedmon,log,uInfo,recID);
            } 
            catch
            {
                so.hasRecord = false;
                return so;
            }                
            so.hasRecord = true;                
            so.data = pat;;            
            return so;
        }
       
        /***************************************************************************
         * saveProfile */
        /**
        * Save only the profile data fields for a patient record
        *
        * @return                     ReturnSaveNewRecord
        ***************************************************************************/

        public static ReturnSaveRecord saveProfile (
              SqlConnection connSpedmon
            , DetailsLog log
            , UserInfo uInfo
            , string clientID
            , string siteID
            , string siteRefID
            , string siteRank
            , string lname
            , string fname
            , string mname
            , string preferred_nickname
            , string teacherorcounselorname
            , string dob
            , string sex
            , string parentConsentMCAL
            , string parentConsentMCALEffectiveDate
            , string ferpaConsent
            , string ferpaConsentEffectiveDate
            , string treatmentConsent
            , string treatmentConsentEffectiveDate
            , string cybhiTpaApproved
            , string cybhiTpaApprovedOn
            , string cybhiTpaID
            , string cybhiSubmitClaims
            , string hasplan
            , string ssn
            , string bic
            , string csis
            , string submitClaims
            , string submitClaimsEffectiveDate
            , string notes
            , string speciallyAdaptedVehicleForTransportation
            , string inTransitionalHousingStatus
            , string email
            , string phone
            , string deceased

            , string patientHomePlaceID         
            , string street1
            , string street2
            , string city
            , string state
            , string zip5
            , string zip4
         
            , string preferredContactMethodCode
			, string minorConsent
            , string minorConsentEffectiveDate							  

            , string editDelReason
            , string validateRec
            , string saveType
            , string recID)
        {

            /*----------------------------
             * Validate parameters specific
             * to this entity.save
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            var parms = new List<SqlParameter>();

            int vClientID     = Validate.reqClientID(uInfo, clientID);
            int vSiteID       = Validate.reqInteger(siteID, Messages.INVALID_SITE_ID);
            Object vSiteRefID = Validate.optString(siteRefID, Messages.INVALID_STUDENT_ID);
            Object vSiteRank  = Validate.optString(siteRank, Messages.INVALID_GRADE);
            Object vNickName  = Validate.optString(preferred_nickname, "Invalid preferred name or nickname entered");

            Object vCounselorOrTeacherName = Validate.optString(teacherorcounselorname, "Invalid counselor or teacher name");

            string vLname = Validate.reqString(lname, Messages.INVALID_LNAME);
            string vFname = Validate.reqString(fname, Messages.INVALID_FNAME);
            string vMname = Validate.optString(mname, Messages.INVALID_MNAME);
            DateTime vDob = Validate.reqDate(dob, Messages.INVALID_DOB, Constants.VAL_OPT_DATE_NO_FUTURE);
            string vSex   = Validate.reqSex(sex, Messages.INVALID_SEX);

            Object vParentConsentMCAL              = Validate.reqFlagOrUnknown(parentConsentMCAL, Messages.INVALID_PARENT_CONSENT_MCAL);
            object vParentConsentMCALEffectiveDate = Validate.optDate(parentConsentMCALEffectiveDate, Messages.INVALID_PARENT_CONSENT_MCAL_EFF_DATE);

            Object vFerpaConsent           = Validate.reqFlagOrUnknown(ferpaConsent, @"Invalid FERPA consent");
            var vFerpaConsentEffectiveDate = Validate.optDate(ferpaConsentEffectiveDate, @"Invalid FERPA consent effective date");

            Object vTreatmentConsent           = Validate.reqFlagOrUnknown(treatmentConsent, @"Invalid treatment consent");
            var vTreatmentConsentEffectiveDate = Validate.optDate(treatmentConsentEffectiveDate, @"Invalid treatment consent effective date");

            Object vCybhiTpaApproved = Validate.reqFlag(cybhiTpaApproved, @"Invalid CYBHI TPA Approved flag",true);
            var vCybhiTpaApprovedOn  = Validate.optDate(cybhiTpaApprovedOn, @"Invalid CYBHI TPA Approved On date");
            Object vCybhiTpaID       = Validate.optString(cybhiTpaID, @"Invalid CYBHI TPA ID");
            bool vCybhiSubmitClaims  = Validate.reqFlag(cybhiSubmitClaims, @"Invalid cybhiSubmitClaims flag", true);

            bool   vHasPlan = Validate.reqFlag(hasplan, Messages.IFSP_IEP_FLAG_BAD,true);
            Object vSSN     = Validate.optString(ssn, 9, Messages.INVALID_SSN);
            Object vBIC     = Validate.optString(bic, Messages.INVALID_BIC);
            Object vCSIS    = Validate.optCSISOrSSID(csis, Messages.INVALID_CSIS);

            bool vSubmitClaims                             = Validate.reqFlag(submitClaims, Messages.SUB_CLMS_FLAG_BAD, true);
            object vSubmitClaimsEffectiveDate              = Validate.optDate(submitClaimsEffectiveDate, Messages.INVALID_SUBMIT_CLAIMS_EFF_DATE);
            bool vSpeciallyAdaptedVehicleForTransportation = Validate.reqFlag(speciallyAdaptedVehicleForTransportation, @"Invalid specially adapted vehicle value", true);
            var vInTransitionalHousingStatus               = Validate.reqFlag(inTransitionalHousingStatus, @"transitional housing status?", true);

            var vEmail    = Validate.optEmail(email,Messages.INVALID_EMAIL);
            var vPhone    = Validate.optPhoneNumber(phone,Messages.INVALID_PHONE_NUMBER);
            var vDeceased = Validate.reqFlag(deceased,@"Invalid value for deceased",true);
                                             
            var vPatientHomePlaceID        = Validate.optInteger (patientHomePlaceID, @"Invalid place id", true);

            Object vNotes = Validate.optString(notes, Messages.INVALID_NOTES);

            var vPreferredContactMethodCode = Validate.optInteger(preferredContactMethodCode, @"Invalidad Preferred Contact Method Code");
			var         vMinorConsent                               = Validate.optFlag(minorConsent,                                @"Invalid Minor Consent Flag");
            var         vMinorConsentEffectiveDate                  = Validate.optDate(minorConsentEffectiveDate,                   @"Invalid Minor Consent effective date");

            validateAndAddCommonAddressParameters (  ref street1
                                                   , ref street2
                                                   , ref city
                                                   , ref state
                                                   , ref zip5
                                                   , ref zip4
                                                   , ref parms );

            
            parms.Add(Database.SqlParm("@patientHomePlaceID", SqlDbType.BigInt, vPatientHomePlaceID, ParameterDirection.Input));
            
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@siteID", SqlDbType.Int, vSiteID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@siteRefID", SqlDbType.NVarChar, vSiteRefID, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@siteRank", SqlDbType.NVarChar, vSiteRank, ParameterDirection.Input, 2));
            parms.Add(Database.SqlParm("@lname", SqlDbType.VarChar, vLname, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@fname", SqlDbType.VarChar, vFname, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@mname", SqlDbType.VarChar, vMname, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@dob", SqlDbType.DateTime, vDob, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@sex", SqlDbType.NVarChar, vSex, ParameterDirection.Input, 1));

            parms.Add(Database.SqlParm("@preferredContactMethodCode", SqlDbType.Int, vPreferredContactMethodCode, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@parentConsentMCAL", SqlDbType.Bit, vParentConsentMCAL, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@parentConsentMCALEffectiveDate", SqlDbType.DateTime, vParentConsentMCALEffectiveDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@parentConsentOHCI", SqlDbType.Bit, 0, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@parentConsentOHCIEffectiveDate", SqlDbType.DateTime, "2021-01-04", ParameterDirection.Input));


            parms.Add(Database.SqlParm("@ferpaConsent", SqlDbType.Bit, vFerpaConsent, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@ferpaConsentEffectiveDate", SqlDbType.DateTime, vFerpaConsentEffectiveDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@treatmentConsent", SqlDbType.Bit, vTreatmentConsent, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@treatmentConsentEffectiveDate", SqlDbType.DateTime, vTreatmentConsentEffectiveDate, ParameterDirection.Input));
           
			parms.Add(Database.SqlParm("@minorConsent",                                 SqlDbType.Bit, vMinorConsent, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@minorConsentEffectiveDate",                    SqlDbType.DateTime, vMinorConsentEffectiveDate, ParameterDirection.Input));																																		 
            parms.Add(Database.SqlParm("@cybhiTpaApproved", SqlDbType.Bit, vCybhiTpaApproved, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@cybhiTpaApprovedOn", SqlDbType.Date, vCybhiTpaApprovedOn, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@cybhiTpaID", SqlDbType.VarChar, vCybhiTpaID, ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@cybhiSubmitClaims", SqlDbType.Bit, vCybhiSubmitClaims, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@hasplan", SqlDbType.Bit, vHasPlan, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@ssn", SqlDbType.NVarChar, vSSN, ParameterDirection.Input, 9));
            parms.Add(Database.SqlParm("@bic", SqlDbType.NVarChar, vBIC, ParameterDirection.Input, 14));
            parms.Add(Database.SqlParm("@csis", SqlDbType.NVarChar, vCSIS, ParameterDirection.Input, 10));
            parms.Add(Database.SqlParm("@submitClaims", SqlDbType.Bit, vSubmitClaims, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@submitClaimsEffectiveDate", SqlDbType.DateTime, vSubmitClaimsEffectiveDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@notes", SqlDbType.VarChar, vNotes, ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@p_nickname", SqlDbType.NVarChar, vNickName, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@teacherOrCounselorName", SqlDbType.VarChar, vCounselorOrTeacherName, ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@speciallyAdaptedVehicleForTransportation", SqlDbType.Bit, vSpeciallyAdaptedVehicleForTransportation, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@inTransitionalHousingStatus", SqlDbType.Bit, vInTransitionalHousingStatus, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@email", SqlDbType.NVarChar, vEmail, ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@phone", SqlDbType.NVarChar, vPhone, ParameterDirection.Input, 14));
            parms.Add(Database.SqlParm("@deceased", SqlDbType.Bit, vDeceased, ParameterDirection.Input));
    
            parms.Add(Database.SqlParm("@MsgNoClient", SqlDbType.VarChar, Messages.INVALID_CLIENT_ID, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgNoSite", SqlDbType.VarChar, Messages.INVALID_SITE_ID, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgNoFullEdit", SqlDbType.VarChar, Messages.EDIT_REC_NO_EDIT_FULL, ParameterDirection.Input, 1000));


            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

         var so = Entities.saveAndReturnRecordData( connSpedmon
                , log
                , uInfo
                , saveType
                , validateRec
                , editDelReason
                , recID
                , "PATIENT_Save_Profile"
                , Messages.DUP_PAT_REC
                , ref parms,
        delegate ()
        {
            /*-------------------------------
             * Check date of birth.
             * Warn user if:
             * - Date is a future date
             * - Patients age is over 21
             *----------------------------*/

            DateTime dr = DateTime.Now;
            if (DateTime.Compare(vDob, dr) == 1) log.addDetail(Messages.VAL_PAT_NOT_BORN, Return.RET_WARNING);
            if (Util.calculateAge(vDob, dr) >= 22) log.addDetail(Messages.VAL_PAT_AGE_22, Return.RET_WARNING);

        });
        if (so.recData1 == "1") { 
            TransportationMgmtTripCalculations.refreshAllTripCalcsWithPlaceID (connSpedmon, log, uInfo, so.recData2);    
        }
        return so;

       }


        /***************************************************************************
         * save */
        /**
        * Save a patient record
        *
        * @param  userID              User id of who is recording service
        * @param  userGroup           1 = Client, 2 = SBSC (from users db)
        * @param  userRank            Users role ranking
        * @param  clientID            Patient's client id
        * @param  siteID              Patient's site id
        * @param  siteRefID           The unique id the client/site assigns to the patient (ie student id)
        * @param  siteRank            A ranking code or organization code the site assigns to the patient (ie grade)
        * @param  lname               Patient's last name
        * @param  fname               Patient's first name
        * @param  mname               Patient's middle name
        * @param  dob                 Patient's date of birth
        * @param  sex                 Patient's gender
        * @param  parentConsentMCAL   Parental consent for Medi-cal
        * @param  parentConsentOHCI   Parental consent for other health care insurance
        * @param  hasPlan             Patient has a IFSP/IEP.  Could also be used to indicate
        *                             patient has a health plan?
        * @param  ssn                 Patient's social security number
        * @param  bic                 Patient's Medi-cal Benefits Identification Card number
        * @param  csis                Patient's Statewide Student Identifier (SSID) 
                                      on file with CSIS (California School Information Services)
        * @param  submitClaims        Should claims be submitted for this patient
        * @param  editDelReason       Reason for record edit or delete
        * @param  validateRec         1 = Performs data integrity validation tasks
        *                                 Perform advisory validation tasks that can
        *                                 only be conducted by referencing data from the
        *                                 database and then exits WITHOUT saving the record
        *                             0 = Peform data integrity validation tasks and
        *                                 if these tasks succeed peforms the desired
        *                                 operation (saveType) on the record and exits
        * @param  saveType            Type of operation to perform
        *                             1 = New, 2 = Edit, 3 = Delete
        * @param  recID               Record id of existing patient record to edit or
        *                             delete.
        * @return                     ReturnSaveNewRecord
        ***************************************************************************/

        public static ReturnSaveRecord save(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo
                                             , string clientID
                                             , string siteID
                                             , string siteRefID
                                             , string siteRank
                                             , string lname
                                             , string fname
                                             , string mname
                                             , string preferred_nickname
                                             , string teacherorcounselorname 
                                             , string dob
                                             , string sex
                                             , string parentConsentMCAL
                                             , string parentConsentMCALEffectiveDate
                                             , string ferpaConsent
                                             , string ferpaConsentEffectiveDate
                                             , string treatmentConsent
                                             , string treatmentConsentEffectiveDate
                                             , string cybhiTpaApproved
                                             , string cybhiTpaApprovedOn
                                             , string cybhiTpaID
                                             , string cybhiSubmitClaims
                                             , string hasplan
                                             , string ssn
                                             , string bic
                                             , string csis
                                             , string submitClaims
                                             , string submitClaimsEffectiveDate
                                             , string notes
                                             , string speciallyAdaptedVehicleForTransportation
                                             , string spEdSpecialTransportation
                                             , string spEdLastEvalDate
                                             , string spEdLastAnnualIEPDate
                                             , string spEdNextAnnualIEPDate
                                             , string spEdCurIEPDate
                                             , string spEdDisability1Code
                                             , string spEdDisability2Code
                                             , string spEdCaseManagerName
                                             , string spEdExitedSpEdDate
                                             , string spEdStudentStrengths
                                             , string spEdParentConcerns
                                             , string spEdProgressMonitoringData
                                             , string spEdStudentPresentLevelsStatement
                                             , string spEdStudentDisabilityAffectsPerformance
                                             , string spEdCurEligibilityDate
                                             , string spEdInitEligibilityDate
                                             , string spEdIEPAttendeesIdentified
                                             , string spEdEligibilityReasons
                                             , string spEdPlanTranslateToLanguageCodeID
                                             , string spEdInitRefDate
                                             , string spEdReferringPartyCode
                                             , string spEdReferringPartyOtherOption
                                             , string spEdDistrictReceivedParentConsentDate
                                             , string spEdMeetingPurposeDataJSON
                                             , string spEdAdditionalMeetingPurposeDataJSON
                                             , string spEdAmendmentReasonsDataJSON
                                             , string spEdPlanTypeCode
                                             , string spEdStudentLanguageCodeID
                                             , string spEdStudentRaceCode
                                             , string spEdNextEvalDate
                                             , string spEdEnteredSpEdDate
                                             , string spEdStudentLanguageEnglishLearner
                                             , string spEdStudentLanguageInfoReclassified
                                             , string spEdStudentLanguageEnglishLearnerUndesignatedPreschool
                                             , string spEdStudentLanguageInterpreterNeeded
                                             , string spEdStudentLanguageTranslationRequested
                                             , string spEdServicesDataJSON
                                             , string spEdTransitionGoalEducation
                                             , string spEdTransitionGoalTraining
                                             , string spEdTransitionGoalEmployment
                                             , string spEdTransitionGoalIndependentLiving
                                             , string inTransitionalHousingStatus
                                             , string spEdDevAcaFunSkillsReading
                                             , string spEdDevAcaFunSkillsWriting
                                             , string spEdDevAcaFunSkillsMath
                                             , string spEdDevAcaFunSkillsCommunicationDev
                                             , string spEdDevAcaFunSkillsGrossFineMotorDev
                                             , string spEdDevAcaFunSkillsHealth
                                             , string spEdDevAcaFunSkillsVocational
                                             , string spEdDevAcaFunSkillsAdaptiveDailyLiving
                                             , string spEdDevAcaFunSkillsAreasOfNeccessity
                                             , string spEdParticipantDetailsJSON
                                             , string editDelReason
                                             , string validateRec
                                             , string saveType
                                             , string recID)
        {

            /*----------------------------
             * Validate parameters specific
             * to this entity.save
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> parms                        = new List<SqlParameter>();
            int vClientID                                   = Validate.reqClientID(uInfo, clientID);
            int vSiteID                                     = Validate.reqInteger(siteID, Messages.INVALID_SITE_ID);
            Object vSiteRefID                               = Validate.optString(siteRefID, Messages.INVALID_STUDENT_ID);
            Object vSiteRank                                = Validate.optString(siteRank, Messages.INVALID_GRADE);
            Object vNickName                                = Validate.optString(preferred_nickname, "Invalid preferred name or nickname entered");
            Object vCounselorOrTeacherName                  = Validate.optString(teacherorcounselorname, "Invalid counselor or teacher name");
            string vLname                                   = Validate.reqString(lname, Messages.INVALID_LNAME);
            string vFname                                   = Validate.reqString(fname, Messages.INVALID_FNAME);
            string vMname                                   = Validate.optString(mname, Messages.INVALID_MNAME);
            DateTime vDob                                   = Validate.reqDate(dob, Messages.INVALID_DOB, Constants.VAL_OPT_DATE_NO_FUTURE);
            string vSex                                     = Validate.reqSex(sex, Messages.INVALID_SEX);
            Object vParentConsentMCAL                       = Validate.reqFlagOrUnknown(parentConsentMCAL, Messages.INVALID_PARENT_CONSENT_MCAL);
            object vParentConsentMCALEffectiveDate          = Validate.optDate(parentConsentMCALEffectiveDate, Messages.INVALID_PARENT_CONSENT_MCAL_EFF_DATE);
            Object vFerpaConsent                            = Validate.reqFlagOrUnknown(ferpaConsent, @"Invalid FERPA consent");
            var vFerpaConsentEffectiveDate                  = Validate.optDate(ferpaConsentEffectiveDate, @"Invalid FERPA consent effective date");
            Object vTreatmentConsent                        = Validate.reqFlagOrUnknown(treatmentConsent, @"Invalid treatment consent");
            var vTreatmentConsentEffectiveDate              = Validate.optDate(treatmentConsentEffectiveDate, @"Invalid treatment consent effective date");
            Object vCybhiTpaApproved                        = Validate.reqFlag(cybhiTpaApproved, @"Invalid CYBHI TPA Approved flag",true);
            var vCybhiTpaApprovedOn                         = Validate.optDate(cybhiTpaApprovedOn, @"Invalid CYBHI TPA Approved On date");
            Object vCybhiTpaID                              = Validate.optString(cybhiTpaID, @"Invalid CYBHI TPA ID");
            bool vCybhiSubmitClaims                         = Validate.reqFlag(cybhiSubmitClaims, @"Invalid cybhiSubmitClaims flag", true);
            bool   vHasPlan                                 = Validate.reqFlag(hasplan, Messages.IFSP_IEP_FLAG_BAD,true);
            Object vSSN                                     = Validate.optString(ssn, 9, Messages.INVALID_SSN);
            Object vBIC                                     = Validate.optString(bic, Messages.INVALID_BIC);
            Object vCSIS                                    = Validate.optString(csis, Messages.INVALID_CSIS);
            bool vSubmitClaims                              = Validate.reqFlag(submitClaims, Messages.SUB_CLMS_FLAG_BAD);
            object vSubmitClaimsEffectiveDate               = Validate.optDate(submitClaimsEffectiveDate, Messages.INVALID_SUBMIT_CLAIMS_EFF_DATE);
            Object vNotes                                   = Validate.optString(notes, Messages.INVALID_NOTES); 
            bool vSpeciallyAdaptedVehicleForTransportation  = Validate.reqFlag(speciallyAdaptedVehicleForTransportation, @"Invalid specially adapted vehicle value", true);
            Object vSpEdSpecialTransportation               = Validate.optFlag(spEdSpecialTransportation, @"Invalid special transportation flag");
            Object vSpEdLastEvalDate                        = Validate.optDate(spEdLastEvalDate, @"Invalid last evaluation date");
            Object vSpEdLastAnnualIEPDate                   = Validate.optDate(spEdLastAnnualIEPDate, @"Invalid last annual IEP date");
            Object vSpEdNextAnnualIEPDate                   = Validate.optDate(spEdNextAnnualIEPDate, @"Invalid next annual IEP date");
            var vSpEdCurIEPDate                             = Validate.optDate(spEdCurIEPDate, @"Invalid current IEP date");
            Object vSpEdDisability1Code                     = Validate.optInteger(spEdDisability1Code, @"Invalid disability 1 code", true);
            Object vSpEdDisability2Code                     = Validate.optInteger(spEdDisability2Code, @"Invalid disability 2 code", true);
            string vSpEdCaseManagerName                     = Validate.optNoun(spEdCaseManagerName, @"Case manager name does not appear to be a noun");
            Object vSpEdExitedSpEdDate                      = Validate.optDate(spEdExitedSpEdDate, @"Invalid date value for exited SpEd");
            var vSpEdStudentStrengths                       = Validate.optString(spEdStudentStrengths, @"Invalid SpEd student strengths");
            var vSpEdParentConcerns                         = Validate.optString(spEdParentConcerns, @"Invalid SpEd parent concerns");
            var vSpEdProgressMonitoringData                 = Validate.optString(spEdProgressMonitoringData, @"Invalid SpEd progress monitoring data");
            var vSpEdStudentPresentLevelsStatement          = Validate.optString(spEdStudentPresentLevelsStatement, @"Invalid SpEd present levels statement");
            var vSpEdStudentDisabilityAffectsPerformance    = Validate.optFlag(spEdStudentDisabilityAffectsPerformance, @"Invalid SpEd disability flag");
            var vSpEdCurEligibilityDate                     = Validate.optDate(spEdCurEligibilityDate, @"Invalid SpEd current eligibility date");
            var vSpEdInitEligibilityDate                    = Validate.optDate(spEdInitEligibilityDate, @"Invalid SpEd initial eligibility date");
            var vSpEdIEPAttendeesIdentified                 = Validate.optFlag(spEdIEPAttendeesIdentified, @"Invalid SpEd attendees identified flag");
            var vSpEdEligibilityReasons                     = Validate.optString(spEdEligibilityReasons, @"Invalid SpEd eligibility reasons");
            var vSpEdPlanTranslateToLanguageCodeID          = Validate.optInteger(spEdPlanTranslateToLanguageCodeID, @"Invalid SpEd language selection", true);
            var vSpEdInitRefDate                            = Validate.optDate(spEdInitRefDate, Messages.INVALID_DATE);
            var vSpEdReferringPartyCode                     = Validate.optInteger(spEdReferringPartyCode, @"Invalid SpEd referring person", true);
            var vSpEdReferringPartyOtherOption              = Validate.optString(spEdReferringPartyOtherOption, Messages.INVALID_TEXT);
            var vSpEdDistrictReceivedParentConsentDate      = Validate.optDate(spEdDistrictReceivedParentConsentDate, Messages.INVALID_DATE);
            var vSpEdMeetingPurposeDataJSON                 = Validate.optString(spEdMeetingPurposeDataJSON, Messages.INVALID_TEXT);
            var vSpEdAdditionalMeetingPurposeDataJSON       = Validate.optString(spEdAdditionalMeetingPurposeDataJSON, Messages.INVALID_TEXT);
            var vSpEdAmendmentReasonsDataJSON               = Validate.optString(spEdAmendmentReasonsDataJSON, Messages.INVALID_TEXT);
            var vSpEdPlanTypeCode                           = Validate.optInteger(spEdPlanTypeCode, @"Invalid SpEd plan type", true);
            var vSpEdStudentLanguageCodeID                  = Validate.optInteger(spEdStudentLanguageCodeID, @"Invalid SpEd language selection", true);
            var vSpEdStudentRaceCode                        = Validate.optInteger(spEdStudentRaceCode, @"Invalid SpEd race selection", true);
            var vSpEdNextEvalDate                           = Validate.optDate(spEdNextEvalDate, Messages.INVALID_DATE);
            var vSpEdEnteredSpEdDate                        = Validate.optDate(spEdEnteredSpEdDate, Messages.INVALID_DATE);
            var vSpEdStudentLanguageEnglishLearner          = Validate.optFlag(spEdStudentLanguageEnglishLearner, @"Invalid language English learner value");
            var vSpEdStudentLanguageInfoReclassified        = Validate.reqFlag(spEdStudentLanguageInfoReclassified, @"Invalid language info reclassified value");
            var vSpEdStudentLanguageInterpreterNeeded       = Validate.optFlag(spEdStudentLanguageInterpreterNeeded, @"Invalid language interpreter needed value");
            var vSpEdStudentLanguageTranslationRequested    = Validate.optFlag(spEdStudentLanguageTranslationRequested, @"Invalid language translation requested value");
            var vSpEdStudentLanguageEnglishLearnerUndesignatedPreSchool = Validate.optFlag(spEdStudentLanguageEnglishLearnerUndesignatedPreschool.ToString(), @"Invalid undesignated preschool value");
            var vSpEdServicesDataJSON                       = Validate.optString(spEdServicesDataJSON, Messages.INVALID_TEXT);
            var vSpEdTransitionGoalEducation                = Validate.optFlag(spEdTransitionGoalEducation, @"Invalid box value");
            var vSpEdTransitionGoalTraining                 = Validate.optFlag(spEdTransitionGoalTraining, @"Invalid box value");
            var vSpEdTransitionGoalEmployment               = Validate.optFlag(spEdTransitionGoalEmployment, @"Invalid box value");
            var vSpEdTransitionGoalIndependentLiving        = Validate.optFlag(spEdTransitionGoalIndependentLiving, @"Invalid box value");
            var vInTransitionalHousingStatus                = Validate.reqFlag(inTransitionalHousingStatus, @"transitional housing status?", true);
            var vSpEdDevAcaFunSkillsReading                 = Validate.optString(spEdDevAcaFunSkillsReading, @"Invalid SpEd student strengths");
            var vSpEdDevAcaFunSkillsWriting                 = Validate.optString(spEdDevAcaFunSkillsWriting, @"Invalid SpEd student strengths");
            var vSpEdDevAcaFunSkillsMath                    = Validate.optString(spEdDevAcaFunSkillsMath, @"Invalid SpEd student strengths");
            var vSpEdDevAcaFunSkillsCommunicationDev        = Validate.optString(spEdDevAcaFunSkillsCommunicationDev, @"Invalid SpEd student strengths");
            var vSpEdDevAcaFunSkillsGrossFineMotorDev       = Validate.optString(spEdDevAcaFunSkillsGrossFineMotorDev, @"Invalid SpEd student strengths");
            var vSpEdDevAcaFunSkillsHealth                  = Validate.optString(spEdDevAcaFunSkillsHealth, @"Invalid SpEd student strengths");
            var vSpEdDevAcaFunSkillsVocational              = Validate.optString(spEdDevAcaFunSkillsVocational, @"Invalid SpEd student strengths");
            var vSpEdDevAcaFunSkillsAdaptiveDailyLiving     = Validate.optString(spEdDevAcaFunSkillsAdaptiveDailyLiving, @"Invalid SpEd student strengths");
            var vSpEdDevAcaFunSkillsAreasOfNeccessity       = Validate.optString(spEdDevAcaFunSkillsAreasOfNeccessity, @"Invalid SpEd student strengths");
            var vSpEdParticipantDetailsJSON                 = Validate.optString(spEdParticipantDetailsJSON, Messages.INVALID_TEXT);



            /*----------------------------
             * For reasons of consistancy
             * we are saving the patient
             * name in all caps
              *----------------------------*/

            vLname = vLname.ToUpper();
            vFname = vFname.ToUpper();
            if (vMname != null)
                vMname = vMname.ToUpper();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@siteID", SqlDbType.Int, vSiteID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@siteRefID", SqlDbType.NVarChar, vSiteRefID, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@siteRank", SqlDbType.NVarChar, vSiteRank, ParameterDirection.Input, 2));
            parms.Add(Database.SqlParm("@lname", SqlDbType.VarChar, vLname, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@fname", SqlDbType.VarChar, vFname, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@mname", SqlDbType.VarChar, vMname, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@dob", SqlDbType.DateTime, vDob, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@sex", SqlDbType.NVarChar, vSex, ParameterDirection.Input, 1));
            parms.Add(Database.SqlParm("@parentConsentMCAL", SqlDbType.Bit, vParentConsentMCAL, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@parentConsentMCALEffectiveDate", SqlDbType.DateTime, vParentConsentMCALEffectiveDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@parentConsentOHCI", SqlDbType.Bit, 0, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@parentConsentOHCIEffectiveDate", SqlDbType.DateTime, "2021-01-04", ParameterDirection.Input));


            parms.Add(Database.SqlParm("@ferpaConsent", SqlDbType.Bit, vFerpaConsent, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@ferpaConsentEffectiveDate", SqlDbType.DateTime, vFerpaConsentEffectiveDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@treatmentConsent", SqlDbType.Bit, vTreatmentConsent, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@treatmentConsentEffectiveDate", SqlDbType.DateTime, vTreatmentConsentEffectiveDate, ParameterDirection.Input));
           
            parms.Add(Database.SqlParm("@cybhiTpaApproved", SqlDbType.Bit, vCybhiTpaApproved, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@cybhiTpaApprovedOn", SqlDbType.Date, vCybhiTpaApprovedOn, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@cybhiTpaID", SqlDbType.VarChar, vCybhiTpaID, ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@cybhiSubmitClaims", SqlDbType.Bit, vCybhiSubmitClaims, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@hasplan", SqlDbType.Bit, vHasPlan, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@ssn", SqlDbType.NVarChar, vSSN, ParameterDirection.Input, 9));
            parms.Add(Database.SqlParm("@bic", SqlDbType.NVarChar, vBIC, ParameterDirection.Input, 14));
            parms.Add(Database.SqlParm("@csis", SqlDbType.NVarChar, vCSIS, ParameterDirection.Input, 10));
            parms.Add(Database.SqlParm("@submitClaims", SqlDbType.Bit, vSubmitClaims, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@submitClaimsEffectiveDate", SqlDbType.DateTime, vSubmitClaimsEffectiveDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@notes", SqlDbType.VarChar, vNotes, ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@p_nickname", SqlDbType.NVarChar, vNickName, ParameterDirection.Input, 50));

            parms.Add(Database.SqlParm("@teacherOrCounselorName", SqlDbType.VarChar, vCounselorOrTeacherName, ParameterDirection.Input, 256));

            parms.Add(Database.SqlParm("@speciallyAdaptedVehicleForTransportation", SqlDbType.Bit, vSpeciallyAdaptedVehicleForTransportation, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdSpecialTransportation", SqlDbType.Bit, vSpEdSpecialTransportation, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdLastEvalDate", SqlDbType.Date, vSpEdLastEvalDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdLastAnnualIEPDate", SqlDbType.Date, vSpEdLastAnnualIEPDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdNextAnnualIEPDate", SqlDbType.Date, vSpEdNextAnnualIEPDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdCurIEPDate", SqlDbType.Date, vSpEdCurIEPDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdDisability1Code", SqlDbType.Int, vSpEdDisability1Code, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdDisability2Code", SqlDbType.Int, vSpEdDisability2Code, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdCaseManagerName", SqlDbType.VarChar, vSpEdCaseManagerName, ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@spEdExitedSpEdDate", SqlDbType.Date, vSpEdExitedSpEdDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdStudentStrengths", SqlDbType.VarChar, vSpEdStudentStrengths, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdParentConcerns", SqlDbType.VarChar, vSpEdParentConcerns, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdProgressMonitoringData", SqlDbType.VarChar, vSpEdProgressMonitoringData, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdStudentPresentLevelsStatement", SqlDbType.VarChar, vSpEdStudentPresentLevelsStatement, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdStudentDisabilityAffectsPerformance", SqlDbType.Bit, vSpEdStudentDisabilityAffectsPerformance, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdCurEligibilityDate", SqlDbType.Date, vSpEdCurEligibilityDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdInitEligibilityDate", SqlDbType.Date, vSpEdInitEligibilityDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdIEPAttendeesIdentified", SqlDbType.Bit, vSpEdIEPAttendeesIdentified, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdEligibilityReasons", SqlDbType.VarChar, vSpEdEligibilityReasons, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdPlanTranslateToLanguageCodeID", SqlDbType.BigInt, vSpEdPlanTranslateToLanguageCodeID, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@spEdInitRefDate", SqlDbType.Date, vSpEdInitRefDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdReferringPartyCode", SqlDbType.Int, vSpEdReferringPartyCode, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdReferringPartyOtherOption", SqlDbType.VarChar, vSpEdReferringPartyOtherOption, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@spEdDistrictReceivedParentConsentDate", SqlDbType.Date, vSpEdDistrictReceivedParentConsentDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdMeetingPurposeDataJSON", SqlDbType.VarChar, vSpEdMeetingPurposeDataJSON, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdAdditionalMeetingPurposeDataJSON", SqlDbType.VarChar, vSpEdAdditionalMeetingPurposeDataJSON, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdAmendmentReasonsDataJSON", SqlDbType.VarChar, vSpEdAmendmentReasonsDataJSON, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdPlanTypeCode", SqlDbType.Int, vSpEdPlanTypeCode, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@spEdStudentLanguageCodeID", SqlDbType.BigInt, vSpEdStudentLanguageCodeID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdStudentRaceCode", SqlDbType.Int, vSpEdStudentRaceCode, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@spEdNextEvalDate", SqlDbType.DateTime, vSpEdNextEvalDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdEnteredSpEdDate", SqlDbType.DateTime, vSpEdEnteredSpEdDate, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@spEdStudentLanguageEnglishLearner", SqlDbType.Bit, vSpEdStudentLanguageEnglishLearner, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdStudentLanguageInfoReclassified", SqlDbType.Bit, vSpEdStudentLanguageInfoReclassified, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdStudentLanguageInterpreterNeeded", SqlDbType.Bit, vSpEdStudentLanguageInterpreterNeeded, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdStudentLanguageTranslationRequested", SqlDbType.Bit, vSpEdStudentLanguageTranslationRequested, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdStudentLanguageEnglishLearnerUndesignatedPreschool", SqlDbType.Bit, vSpEdStudentLanguageEnglishLearnerUndesignatedPreSchool, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@spEdServicesDataJSON", SqlDbType.VarChar, vSpEdServicesDataJSON, ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@MsgNoClient", SqlDbType.VarChar, Messages.INVALID_CLIENT_ID, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgNoSite", SqlDbType.VarChar, Messages.INVALID_SITE_ID, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgNoFullEdit", SqlDbType.VarChar, Messages.EDIT_REC_NO_EDIT_FULL, ParameterDirection.Input, 1000));

            parms.Add(Database.SqlParm("@spEdTransitionGoalEducation", SqlDbType.Bit, vSpEdTransitionGoalEducation, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdTransitionGoalTraining", SqlDbType.Bit, vSpEdTransitionGoalTraining, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdTransitionGoalEmployment", SqlDbType.Bit, vSpEdTransitionGoalEmployment, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdTransitionGoalIndependentLiving", SqlDbType.Bit, vSpEdTransitionGoalIndependentLiving, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@inTransitionalHousingStatus", SqlDbType.Bit, vInTransitionalHousingStatus, ParameterDirection.Input));


            parms.Add(Database.SqlParm("@spEdDevAcaFunSkillsReading", SqlDbType.VarChar, vSpEdDevAcaFunSkillsReading, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdDevAcaFunSkillsWriting", SqlDbType.VarChar, vSpEdDevAcaFunSkillsWriting, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdDevAcaFunSkillsMath", SqlDbType.VarChar, vSpEdDevAcaFunSkillsMath, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdDevAcaFunSkillsCommunicationDev", SqlDbType.VarChar, vSpEdDevAcaFunSkillsCommunicationDev, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdDevAcaFunSkillsGrossFineMotorDev", SqlDbType.VarChar, vSpEdDevAcaFunSkillsGrossFineMotorDev, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdDevAcaFunSkillsHealth", SqlDbType.VarChar, vSpEdDevAcaFunSkillsHealth, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdDevAcaFunSkillsVocational", SqlDbType.VarChar, vSpEdDevAcaFunSkillsVocational, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdDevAcaFunSkillsAdaptiveDailyLiving", SqlDbType.VarChar, vSpEdDevAcaFunSkillsAdaptiveDailyLiving, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdDevAcaFunSkillsAreasOfNeccessity", SqlDbType.VarChar, vSpEdDevAcaFunSkillsAreasOfNeccessity, ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@spEdParticipantDetailsJSON", SqlDbType.VarChar, vSpEdParticipantDetailsJSON, ParameterDirection.Input, -1));


            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "PATIENT_Save", Messages.DUP_PAT_REC, ref parms,
        delegate ()
        {
            /*-------------------------------
             * Check date of birth.
             * Warn user if:
             * - Date is a future date
             * - Patients age is over 21
             *----------------------------*/

            DateTime dr = DateTime.Now;
            if (DateTime.Compare(vDob, dr) == 1) log.addDetail(Messages.VAL_PAT_NOT_BORN, Return.RET_WARNING);
            if (Util.calculateAge(vDob, dr) >= 22) log.addDetail(Messages.VAL_PAT_AGE_22, Return.RET_WARNING);

            /*-------------------------------
             * Warn the user if the no submit
             * flag for this patient is set
             * to false
             *----------------------------*/

            if (!vSubmitClaims)
                log.addDetail(Messages.WARN_NO_SUB_CLAIMS_PAT, Return.RET_WARNING);

        });
        }

        /***************************************************************************
         * updateMeetingCompletionStatus */
        /**
         * Updates the meetingCompletionStatus and meetingNotes on an existing
         * telecomm session. Called from the IEP meeting history dropdown
         * and notes save for compliance tracking.
         *
         * @param connUsers     Users database connection
         * @param log           Details log
         * @param uInfo         User info
         * @param sessionID     Telecomm session ID
         * @param status        New status value (attended, did_not_occur, pending_review)
         * @param notes         User notes about the meeting outcome
         ***************************************************************************/

        public static ReturnSaveRecord updateMeetingCompletionStatus(SqlConnection connUsers
                                                                    , DetailsLog log
                                                                    , UserInfo uInfo
                                                                    , string sessionID
                                                                    , string status
                                                                    , string notes)
        {
            long vSessionID = Validate.reqInteger(sessionID, @"Session ID is required");
            string vStatus = Validate.optString(status, @"Invalid status value");
            string vNotes = Validate.optString(notes, @"Invalid notes value");

            var parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@sessionID", SqlDbType.BigInt, vSessionID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@status", SqlDbType.VarChar, vStatus, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@notes", SqlDbType.VarChar, vNotes, ParameterDirection.Input, -1));

            return Entities.save(connUsers
                                , log
                                , uInfo
                                , "2"
                                , "0"
                                , ""
                                , vSessionID.ToString()
                                , "TELECOMM_SESSION_UPDATE_COMPLETION_STATUS"
                                , "Duplicate"
                                , ref parms
                                , delegate () { });
        }

        /***************************************************************************
          * saveIEP */
        /**
         * Save patient IEP records only
         * 
         * @param connSpedmon   Database connection
         * @param log           Details log
         * @param uInfo         User info
         * @param clientID      Client ID
         * @param patID         Patient ID (for future use)
         * @param spEd...       All IEP-related fields
         * @param editDelReason Reason for edit
         * @param validateRec   Validate record flag
         * @param saveType      Save type (2 = Edit only for now)
         * @param recID         Record ID
         ***************************************************************************/

        public static ReturnSaveRecord saveIEP(SqlConnection connSpedmon, SqlConnection connUsers, DetailsLog log, UserInfo uInfo,
                                              string clientID
                                             , string patID
                                             , string spEdSpecialTransportation
                                             , string spEdLastEvalDate
                                             , string spEdLastAnnualIEPDate
                                             , string spEdNextAnnualIEPDate
                                             , string spEdCurIEPDate
                                             , string spEdDisability1Code
                                             , string spEdDisability2Code
                                             , string spEdExitedSpEdDate
                                             , string spEdStudentStrengths
                                             , string spEdParentConcerns
                                             , string spEdProgressMonitoringData
                                             , string spEdStudentPresentLevelsStatement
                                             , string spEdStudentDisabilityAffectsPerformance
                                             , string spEdCurEligibilityDate
                                             , string spEdInitEligibilityDate
                                             , string spEdIEPAttendeesIdentified
                                             , string spEdEligibilityReasons
                                             , string spEdPlanTranslateToLanguageCodeID
                                             , string spEdInitRefDate
                                             , string spEdReferringPartyCode
                                             , string spEdReferringPartyOtherOption
                                             , string spEdDistrictReceivedParentConsentDate
                                             , string spEdMeetingPurposeDataJSON
                                             , string spEdAdditionalMeetingPurposeDataJSON
                                             , string spEdAmendmentReasonsDataJSON
                                             , string spEdPlanTypeCode
                                             , string spEdStudentLanguageCodeID
                                             , string spEdStudentRaceCode
                                             , string spEdNextEvalDate
                                             , string spEdEnteredSpEdDate
                                             , string spEdStudentLanguageEnglishLearner
                                             , string spEdStudentLanguageInfoReclassified
                                             , string spEdStudentLanguageEnglishLearnerUndesignatedPreschool
                                             , string spEdStudentLanguageInterpreterNeeded
                                             , string spEdStudentLanguageTranslationRequested
                                             , string spEdServicesDataJSON
                                             , string spEdTransitionGoalEducation
                                             , string spEdTransitionGoalTraining
                                             , string spEdTransitionGoalEmployment
                                             , string spEdTransitionGoalIndependentLiving
                                             , string spEdDevAcaFunSkillsReading
                                             , string spEdDevAcaFunSkillsWriting
                                             , string spEdDevAcaFunSkillsMath
                                             , string spEdDevAcaFunSkillsCommunicationDev
                                             , string spEdDevAcaFunSkillsGrossFineMotorDev
                                             , string spEdDevAcaFunSkillsHealth
                                             , string spEdDevAcaFunSkillsVocational
                                             , string spEdDevAcaFunSkillsAdaptiveDailyLiving
                                             , string spEdDevAcaFunSkillsAreasOfNeccessity
                                             , string spEdDevAcaFunSkillsSocialEmotionalBehavioral                     
                                             , string spEdParticipantDetailsJSON
                                             , string spEdProceduralSafeguardsSentDate
                                             , string spEdSpecialTransportationComments
                                             , string spEdVehicleAdaptationType
                                             , string speciallyAdaptedVehicleForTransportation
                                             , string spEdCorrectionDetails
                                             , string spEdPreferredLanguageCodeID
                                             , string spEdPresentLevelsDataJSON
                                             , string spEdPresentLevelsPreparedBy
                                             , string spEdPresentLevelsPreparedByName
                                             , string spEdStudentStrengthsSourceJSON
                                             , string spEdStudentStrengthsImpact
                                             , string spEdParentConcernsSourceJSON
                                             , string spEdReadingReviewedNA
                                             , string spEdReadingSourceJSON
                                             , string spEdReadingBaselineValue
                                             , string spEdReadingBaselineUnit
                                             , string spEdReadingToolsUsed
                                             , string spEdReadingToolsUsedJSON                                         
                                             , string spEdReadingBaselineDate
                                             , string spEdReadingImpactSummary
                                             , string spEdWritingReviewedNA
                                             , string spEdWritingSourceJSON
                                             , string spEdWritingBaselineValue
                                             , string spEdWritingBaselineUnit
                                             , string spEdWritingToolsUsed
                                             , string spEdWritingToolsUsedJSON                                         
                                             , string spEdWritingBaselineDate
                                             , string spEdWritingImpactSummary
                                             , string spEdMathReviewedNA
                                             , string spEdMathSourceJSON
                                             , string spEdMathBaselineValue
                                             , string spEdMathBaselineUnit
                                             , string spEdMathToolsUsed
                                             , string spEdMathToolsUsedJSON                                            
                                             , string spEdMathBaselineDate
                                             , string spEdMathImpactSummary
                                             , string spEdCommunicationDevReviewedNA
                                             , string spEdCommunicationDevSourceJSON
                                             , string spEdCommunicationDevBaselineValue
                                             , string spEdCommunicationDevBaselineUnit
                                             , string spEdCommunicationDevToolsUsed
                                             , string spEdCommunicationDevToolsUsedJSON                                
                                             , string spEdCommunicationDevBaselineDate
                                             , string spEdCommunicationDevImpactSummary
                                             , string spEdGrossFineMotorReviewedNA
                                             , string spEdGrossFineMotorSourceJSON
                                             , string spEdGrossFineMotorBaselineValue
                                             , string spEdGrossFineMotorBaselineUnit
                                             , string spEdGrossFineMotorToolsUsed
                                             , string spEdGrossFineMotorToolsUsedJSON                                  
                                             , string spEdGrossFineMotorBaselineDate
                                             , string spEdGrossFineMotorImpactSummary
                                             , string spEdHealthReviewedNA
                                             , string spEdHealthSourceJSON
                                             , string spEdHealthBaselineValue
                                             , string spEdHealthBaselineUnit
                                             , string spEdHealthToolsUsed
                                             , string spEdHealthToolsUsedJSON                                          
                                             , string spEdHealthBaselineDate
                                             , string spEdHealthImpactSummary
                                             , string spEdVocationalReviewedNA
                                             , string spEdVocationalSourceJSON
                                             , string spEdVocationalBaselineValue
                                             , string spEdVocationalBaselineUnit
                                             , string spEdVocationalToolsUsed
                                             , string spEdVocationalToolsUsedJSON                                      
                                             , string spEdVocationalBaselineDate
                                             , string spEdVocationalImpactSummary
                                             , string spEdAdaptiveDailyLivingReviewedNA
                                             , string spEdAdaptiveDailyLivingSourceJSON
                                             , string spEdAdaptiveDailyLivingBaselineValue
                                             , string spEdAdaptiveDailyLivingBaselineUnit
                                             , string spEdAdaptiveDailyLivingToolsUsed
                                             , string spEdAdaptiveDailyLivingToolsUsedJSON                             
                                             , string spEdAdaptiveDailyLivingBaselineDate
                                             , string spEdAdaptiveDailyLivingImpactSummary
                                             , string spEdSocialEmotionalBehavioralReviewedNA                          
                                             , string spEdSocialEmotionalBehavioralSourceJSON                          
                                             , string spEdSocialEmotionalBehavioralBaselineValue                       
                                             , string spEdSocialEmotionalBehavioralBaselineUnit                        
                                             , string spEdSocialEmotionalBehavioralToolsUsed                           
                                             , string spEdSocialEmotionalBehavioralToolsUsedJSON                       
                                             , string spEdSocialEmotionalBehavioralBaselineDate                        
                                             , string spEdSocialEmotionalBehavioralImpactSummary                       
                                          
                                             , string spEdStudentStrengthsSource
                                             , string spEdStudentStrengthsSourceNames
                                             , string spEdParentConcernsSource
                                             , string spEdParentConcernsSourceNames
                                             , string spEdReadingSource
                                             , string spEdReadingSourceNames
                                             , string spEdWritingSource
                                             , string spEdWritingSourceNames
                                             , string spEdMathSource
                                             , string spEdMathSourceNames
                                             , string spEdCommunicationDevSource
                                             , string spEdCommunicationDevSourceNames
                                             , string spEdGrossFineMotorSource
                                             , string spEdGrossFineMotorSourceNames
                                             , string spEdHealthSource
                                             , string spEdHealthSourceNames
                                             , string spEdVocationalSource
                                             , string spEdVocationalSourceNames
                                             , string spEdAdaptiveDailyLivingSource
                                             , string spEdAdaptiveDailyLivingSourceNames
                                             , string spEdSocialEmotionalBehavioralSource                              
                                             , string spEdSocialEmotionalBehavioralSourceNames                         

                                             , string spEdReadingBaselineUnitNames
                                             , string spEdWritingBaselineUnitNames
                                             , string spEdMathBaselineUnitNames
                                             , string spEdCommunicationDevBaselineUnitNames
                                             , string spEdGrossFineMotorBaselineUnitNames
                                             , string spEdHealthBaselineUnitNames
                                             , string spEdVocationalBaselineUnitNames
                                             , string spEdAdaptiveDailyLivingBaselineUnitNames
                                             , string spEdSocialEmotionalBehavioralBaselineUnitNames
                                             , string sendMeetingInvitesFlag
                                             , string resendParticipantEmail
                                             , string resendParticipantName
                                             , string resendParticipantRole
                                             , string spEdReadingToolsUsedNames
                                             , string spEdWritingToolsUsedNames
                                             , string spEdMathToolsUsedNames
                                             , string spEdCommunicationDevToolsUsedNames
                                             , string spEdGrossFineMotorToolsUsedNames
                                             , string spEdHealthToolsUsedNames
                                             , string spEdVocationalToolsUsedNames
                                             , string spEdAdaptiveDailyLivingToolsUsedNames
                                             , string spEdAmendmentReasonsOtherOption
                                             , string spEdMeetingPurposeOtherOption
                                             , string spEdFacilitatorUserID
                                             , string spEdFacilitatorUserName
                                             , string spEdCaseManagerUserID
                                             , string spEdCaseManagerUserName
                                             , string spEdMeetingDate
                                             , string spEdMeetingDurationInMins
                                             , string spEdMeetingTime
                                             , string spEdMeetingTitle
                                             , string spEdSocialEmotionalBehavioralToolsUsedNames
                                             , string meetingStatusOverrides
                                             , string editDelReason
                                             , string validateRec
                                             , string saveType
                                             , string recID)
        {

            /*----------------------------
             * Validate parameters specific
             * to this entity.saveIEP
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/
            List<SqlParameter> parms = new List<SqlParameter>();
            int    vClientID                                          = Validate.reqClientID(uInfo, clientID);
            Object vPatID                                             = Validate.optInteger(patID, "Invalid patient ID", true);

            Object vSpEdSpecialTransportation                         = Validate.optFlag   (spEdSpecialTransportation,                        @"Invalid special transportation flag");
            Object vSpEdLastEvalDate                                  = Validate.optDate   (spEdLastEvalDate,                                 @"Invalid last evaluation date");
            Object vSpEdLastAnnualIEPDate                             = Validate.optDate   (spEdLastAnnualIEPDate,                            @"Invalid last annual IEP date");
            Object vSpEdNextAnnualIEPDate                             = Validate.optDate   (spEdNextAnnualIEPDate,                            @"Invalid next annual IEP date");
            var    vSpEdCurIEPDate                                    = Validate.optDate   (spEdCurIEPDate,                                   @"Invalid current IEP date");
            Object vSpEdDisability1Code                               = Validate.optInteger(spEdDisability1Code,                              @"Invalid disability 1 code", true);
            Object vSpEdDisability2Code                               = Validate.optInteger(spEdDisability2Code,                              @"Invalid disability 2 code", true);
            Object vSpEdExitedSpEdDate                                = Validate.optDate   (spEdExitedSpEdDate,                               @"Invalid date value for exited SpEd");
            var    vSpEdStudentStrengths                              = Validate.optString (spEdStudentStrengths,                             @"Invalid SpEd student strengths");
            var    vSpEdParentConcerns                                = Validate.optString (spEdParentConcerns,                               @"Invalid SpEd parent concerns");
            var    vSpEdProgressMonitoringData                        = Validate.optString (spEdProgressMonitoringData,                       @"Invalid SpEd progress monitoring data");
            var    vSpEdStudentPresentLevelsStatement                 = Validate.optString (spEdStudentPresentLevelsStatement,                @"Invalid SpEd present levels statement");
            var    vSpEdStudentDisabilityAffectsPerformance           = Validate.optFlag   (spEdStudentDisabilityAffectsPerformance,          @"Invalid SpEd disability flag");
            var    vSpEdCurEligibilityDate                            = Validate.optDate   (spEdCurEligibilityDate,                           @"Invalid SpEd current eligibility date");
            var    vSpEdInitEligibilityDate                           = Validate.optDate   (spEdInitEligibilityDate,                          @"Invalid SpEd initial eligibility date");
            var    vSpEdIEPAttendeesIdentified                        = Validate.optFlag   (spEdIEPAttendeesIdentified,                       @"Invalid SpEd attendees identified flag");
            var    vSpEdEligibilityReasons                            = Validate.optString (spEdEligibilityReasons,                           @"Invalid SpEd eligibility reasons");
            var    vSpEdPlanTranslateToLanguageCodeID                 = Validate.optInteger(spEdPlanTranslateToLanguageCodeID,                @"Invalid SpEd language selection", true);

            var    vSpEdInitRefDate                                   = Validate.optDate   (spEdInitRefDate,                                  Messages.INVALID_DATE);
            var    vSpEdReferringPartyCode                            = Validate.optInteger(spEdReferringPartyCode,                           @"Invalid SpEd referring person", true);
            var    vSpEdReferringPartyOtherOption                     = Validate.optString (spEdReferringPartyOtherOption,                    Messages.INVALID_TEXT);
            var    vSpEdDistrictReceivedParentConsentDate             = Validate.optDate   (spEdDistrictReceivedParentConsentDate,            Messages.INVALID_DATE);
            var    vSpEdMeetingPurposeDataJSON                        = Validate.optString (spEdMeetingPurposeDataJSON,                       Messages.INVALID_TEXT);
            var    vSpEdAdditionalMeetingPurposeDataJSON              = Validate.optString (spEdAdditionalMeetingPurposeDataJSON,             Messages.INVALID_TEXT);
            var    vSpEdAmendmentReasonsDataJSON                      = Validate.optString (spEdAmendmentReasonsDataJSON,                     Messages.INVALID_TEXT);
            var    vSpEdPlanTypeCode                                  = Validate.optInteger(spEdPlanTypeCode,                                 @"Invalid SpEd plan type", true);
            var    vSpEdStudentLanguageCodeID                         = Validate.optInteger(spEdStudentLanguageCodeID,                        @"Invalid SpEd language selection", true);
            var    vSpEdStudentRaceCode                               = Validate.optInteger(spEdStudentRaceCode,                              @"Invalid SpEd race selection", true);

            var    vSpEdNextEvalDate                                  = Validate.optDate   (spEdNextEvalDate,                                 Messages.INVALID_DATE);
            var    vSpEdEnteredSpEdDate                               = Validate.optDate   (spEdEnteredSpEdDate,                              Messages.INVALID_DATE);

            var    vSpEdStudentLanguageEnglishLearner                 = Validate.optFlag   (spEdStudentLanguageEnglishLearner,                @"Invalid language English learner value");
            var    vSpEdStudentLanguageInfoReclassified               = Validate.optFlag   (spEdStudentLanguageInfoReclassified,              @"Invalid language info reclassified value");
            var    vSpEdStudentLanguageInterpreterNeeded              = Validate.optFlag   (spEdStudentLanguageInterpreterNeeded,             @"Invalid language interpreter needed value");
            var    vSpEdStudentLanguageTranslationRequested           = Validate.optFlag   (spEdStudentLanguageTranslationRequested,          @"Invalid language translation requested value");

            var    vSpEdStudentLanguageEnglishLearnerUndesignatedPreSchool = Validate.optFlag(spEdStudentLanguageEnglishLearnerUndesignatedPreschool.ToString(), @"Invalid undesignated preschool value");

            var    vSpEdServicesDataJSON                              = Validate.optString (spEdServicesDataJSON,                             Messages.INVALID_TEXT);

            var    vSpEdTransitionGoalEducation                       = Validate.optFlag   (spEdTransitionGoalEducation,                      @"Invalid box value");
            var    vSpEdTransitionGoalTraining                        = Validate.optFlag   (spEdTransitionGoalTraining,                       @"Invalid box value");
            var    vSpEdTransitionGoalEmployment                      = Validate.optFlag   (spEdTransitionGoalEmployment,                     @"Invalid box value");
            var    vSpEdTransitionGoalIndependentLiving               = Validate.optFlag   (spEdTransitionGoalIndependentLiving,              @"Invalid box value");

            var    vSpEdDevAcaFunSkillsReading                        = Validate.optString (spEdDevAcaFunSkillsReading,                       @"Invalid SpEd student strengths");
            var    vSpEdDevAcaFunSkillsWriting                        = Validate.optString (spEdDevAcaFunSkillsWriting,                       @"Invalid SpEd student strengths");
            var    vSpEdDevAcaFunSkillsMath                           = Validate.optString (spEdDevAcaFunSkillsMath,                          @"Invalid SpEd student strengths");
            var    vSpEdDevAcaFunSkillsCommunicationDev               = Validate.optString (spEdDevAcaFunSkillsCommunicationDev,              @"Invalid SpEd student strengths");
            var    vSpEdDevAcaFunSkillsGrossFineMotorDev              = Validate.optString (spEdDevAcaFunSkillsGrossFineMotorDev,             @"Invalid SpEd student strengths");
            var    vSpEdDevAcaFunSkillsHealth                         = Validate.optString (spEdDevAcaFunSkillsHealth,                        @"Invalid SpEd student strengths");
            var    vSpEdDevAcaFunSkillsVocational                     = Validate.optString (spEdDevAcaFunSkillsVocational,                    @"Invalid SpEd student strengths");
            var    vSpEdDevAcaFunSkillsAdaptiveDailyLiving            = Validate.optString (spEdDevAcaFunSkillsAdaptiveDailyLiving,           @"Invalid SpEd student strengths");
            var    vSpEdDevAcaFunSkillsAreasOfNeccessity              = Validate.optString (spEdDevAcaFunSkillsAreasOfNeccessity,             @"Invalid SpEd student strengths");
            var    vSpEdDevAcaFunSkillsSocialEmotionalBehavioral      = Validate.optString (spEdDevAcaFunSkillsSocialEmotionalBehavioral,     @"Invalid SpEd student strengths"); 

            var    vSpEdParticipantDetailsJSON                        = Validate.optString (spEdParticipantDetailsJSON,                       Messages.INVALID_TEXT);
            var    vSpEdProceduralSafeguardsSentDate                  = Validate.optDate   (spEdProceduralSafeguardsSentDate,                 Messages.INVALID_DATE);
            var    vSpEdSpecialTransportationComments                 = Validate.optString (spEdSpecialTransportationComments,                Messages.INVALID_TEXT);
            var    vSpEdVehicleAdaptationType                         = Validate.optInteger(spEdVehicleAdaptationType,                        @"Invalid vehicle adaptation type", true);
            var    vSpeciallyAdaptedVehicleForTransportation          = Validate.optFlag   (speciallyAdaptedVehicleForTransportation,         @"Invalid specially adapted vehicle flag");
            var    vSpEdCorrectionDetails                             = Validate.optString (spEdCorrectionDetails,                            Messages.INVALID_TEXT);
            var    vSpEdPreferredLanguageCodeID                       = Validate.optInteger(spEdPreferredLanguageCodeID,                      @"Invalid preferred language selection", true);

            var    vSpEdPresentLevelsDataJSON                         = Validate.optString (spEdPresentLevelsDataJSON,                        Messages.INVALID_TEXT);
            var    vSpEdPresentLevelsPreparedBy                       = Validate.optInteger(spEdPresentLevelsPreparedBy,                      Messages.INVALID_TEXT, true);
            var    vSpEdPresentLevelsPreparedByName                   = Validate.optString (spEdPresentLevelsPreparedByName,                  Messages.INVALID_TEXT);

            var    vSpEdStudentStrengthsSourceJSON                    = Validate.optString (spEdStudentStrengthsSourceJSON,                   Messages.INVALID_TEXT);
            var    vSpEdStudentStrengthsImpact                        = Validate.optString (spEdStudentStrengthsImpact,                       Messages.INVALID_TEXT);

            var    vSpEdParentConcernsSourceJSON                      = Validate.optString (spEdParentConcernsSourceJSON,                     Messages.INVALID_TEXT);

            var    vSpEdReadingReviewedNA                             = Validate.optFlag   (spEdReadingReviewedNA,                            @"Invalid box value");
            var    vSpEdReadingSourceJSON                             = Validate.optString (spEdReadingSourceJSON,                            Messages.INVALID_TEXT);
            var    vSpEdReadingBaselineValue                          = Validate.optString (spEdReadingBaselineValue,                         Messages.INVALID_TEXT);
            var    vSpEdReadingBaselineUnit                           = Validate.optString (spEdReadingBaselineUnit,                          Messages.INVALID_TEXT);
            var    vSpEdReadingToolsUsed                              = Validate.optString (spEdReadingToolsUsed,                             Messages.INVALID_TEXT);
            var    vSpEdReadingToolsUsedJSON                          = Validate.optString (spEdReadingToolsUsedJSON,                         Messages.INVALID_TEXT);   
            var    vSpEdReadingBaselineDate                           = Validate.optDate   (spEdReadingBaselineDate,                          Messages.INVALID_DATE);
            var    vSpEdReadingImpactSummary                          = Validate.optString (spEdReadingImpactSummary,                         Messages.INVALID_TEXT);

            var    vSpEdWritingReviewedNA                             = Validate.optFlag   (spEdWritingReviewedNA,                            @"Invalid box value");
            var    vSpEdWritingSourceJSON                             = Validate.optString (spEdWritingSourceJSON,                            Messages.INVALID_TEXT);
            var    vSpEdWritingBaselineValue                          = Validate.optString (spEdWritingBaselineValue,                         Messages.INVALID_TEXT);
            var    vSpEdWritingBaselineUnit                           = Validate.optString (spEdWritingBaselineUnit,                          Messages.INVALID_TEXT);
            var    vSpEdWritingToolsUsed                              = Validate.optString (spEdWritingToolsUsed,                             Messages.INVALID_TEXT);
            var    vSpEdWritingToolsUsedJSON                          = Validate.optString (spEdWritingToolsUsedJSON,                         Messages.INVALID_TEXT);   
            var    vSpEdWritingBaselineDate                           = Validate.optDate   (spEdWritingBaselineDate,                          Messages.INVALID_DATE);
            var    vSpEdWritingImpactSummary                          = Validate.optString (spEdWritingImpactSummary,                         Messages.INVALID_TEXT);
             
            var    vSpEdMathReviewedNA                                = Validate.optFlag   (spEdMathReviewedNA,                               @"Invalid box value");
            var    vSpEdMathSourceJSON                                = Validate.optString (spEdMathSourceJSON,                               Messages.INVALID_TEXT);
            var    vSpEdMathBaselineValue                             = Validate.optString (spEdMathBaselineValue,                            Messages.INVALID_TEXT);
            var    vSpEdMathBaselineUnit                              = Validate.optString (spEdMathBaselineUnit,                             Messages.INVALID_TEXT);
            var    vSpEdMathToolsUsed                                 = Validate.optString (spEdMathToolsUsed,                                Messages.INVALID_TEXT);
            var    vSpEdMathToolsUsedJSON                             = Validate.optString (spEdMathToolsUsedJSON,                            Messages.INVALID_TEXT);      
            var    vSpEdMathBaselineDate                              = Validate.optDate   (spEdMathBaselineDate,                             Messages.INVALID_DATE);
            var    vSpEdMathImpactSummary                             = Validate.optString (spEdMathImpactSummary,                            Messages.INVALID_TEXT);
             
            var    vSpEdCommunicationDevReviewedNA                    = Validate.optFlag   (spEdCommunicationDevReviewedNA,                   @"Invalid box value");
            var    vSpEdCommunicationDevSourceJSON                    = Validate.optString (spEdCommunicationDevSourceJSON,                   Messages.INVALID_TEXT);
            var    vSpEdCommunicationDevBaselineValue                 = Validate.optString (spEdCommunicationDevBaselineValue,                Messages.INVALID_TEXT);
            var    vSpEdCommunicationDevBaselineUnit                  = Validate.optString (spEdCommunicationDevBaselineUnit,                 Messages.INVALID_TEXT);
            var    vSpEdCommunicationDevToolsUsed                     = Validate.optString (spEdCommunicationDevToolsUsed,                    Messages.INVALID_TEXT);
            var    vSpEdCommunicationDevToolsUsedJSON                 = Validate.optString (spEdCommunicationDevToolsUsedJSON,                Messages.INVALID_TEXT); 
            var    vSpEdCommunicationDevBaselineDate                  = Validate.optDate   (spEdCommunicationDevBaselineDate,                 Messages.INVALID_DATE);
            var    vSpEdCommunicationDevImpactSummary                 = Validate.optString (spEdCommunicationDevImpactSummary,                Messages.INVALID_TEXT);

            var    vSpEdGrossFineMotorReviewedNA                      = Validate.optFlag   (spEdGrossFineMotorReviewedNA,                     @"Invalid box value");
            var    vSpEdGrossFineMotorSourceJSON                      = Validate.optString (spEdGrossFineMotorSourceJSON,                     Messages.INVALID_TEXT);
            var    vSpEdGrossFineMotorBaselineValue                   = Validate.optString (spEdGrossFineMotorBaselineValue,                  Messages.INVALID_TEXT);
            var    vSpEdGrossFineMotorBaselineUnit                    = Validate.optString (spEdGrossFineMotorBaselineUnit,                   Messages.INVALID_TEXT);
            var    vSpEdGrossFineMotorToolsUsed                       = Validate.optString (spEdGrossFineMotorToolsUsed,                      Messages.INVALID_TEXT);
            var    vSpEdGrossFineMotorToolsUsedJSON                   = Validate.optString (spEdGrossFineMotorToolsUsedJSON,                  Messages.INVALID_TEXT); 
            var    vSpEdGrossFineMotorBaselineDate                    = Validate.optDate   (spEdGrossFineMotorBaselineDate,                   Messages.INVALID_DATE);
            var    vSpEdGrossFineMotorImpactSummary                   = Validate.optString (spEdGrossFineMotorImpactSummary,                  Messages.INVALID_TEXT);

            var    vSpEdHealthReviewedNA                              = Validate.optFlag   (spEdHealthReviewedNA,                             @"Invalid box value");
            var    vSpEdHealthSourceJSON                              = Validate.optString (spEdHealthSourceJSON,                             Messages.INVALID_TEXT);
            var    vSpEdHealthBaselineValue                           = Validate.optString (spEdHealthBaselineValue,                          Messages.INVALID_TEXT);
            var    vSpEdHealthBaselineUnit                            = Validate.optString (spEdHealthBaselineUnit,                           Messages.INVALID_TEXT);
            var    vSpEdHealthToolsUsed                               = Validate.optString (spEdHealthToolsUsed,                              Messages.INVALID_TEXT);
            var    vSpEdHealthToolsUsedJSON                           = Validate.optString (spEdHealthToolsUsedJSON,                          Messages.INVALID_TEXT);    
            var    vSpEdHealthBaselineDate                            = Validate.optDate   (spEdHealthBaselineDate,                           Messages.INVALID_DATE);
            var    vSpEdHealthImpactSummary                           = Validate.optString (spEdHealthImpactSummary,                          Messages.INVALID_TEXT);

            var    vSpEdVocationalReviewedNA                          = Validate.optFlag   (spEdVocationalReviewedNA,                         @"Invalid box value");
            var    vSpEdVocationalSourceJSON                          = Validate.optString (spEdVocationalSourceJSON,                         Messages.INVALID_TEXT);
            var    vSpEdVocationalBaselineValue                       = Validate.optString (spEdVocationalBaselineValue,                      Messages.INVALID_TEXT);
            var    vSpEdVocationalBaselineUnit                        = Validate.optString (spEdVocationalBaselineUnit,                       Messages.INVALID_TEXT);
            var    vSpEdVocationalToolsUsed                           = Validate.optString (spEdVocationalToolsUsed,                          Messages.INVALID_TEXT);
            var    vSpEdVocationalToolsUsedJSON                       = Validate.optString (spEdVocationalToolsUsedJSON,                      Messages.INVALID_TEXT); 
            var    vSpEdVocationalBaselineDate                        = Validate.optDate   (spEdVocationalBaselineDate,                       Messages.INVALID_DATE);
            var    vSpEdVocationalImpactSummary                       = Validate.optString (spEdVocationalImpactSummary,                      Messages.INVALID_TEXT);

            var    vSpEdAdaptiveDailyLivingReviewedNA                 = Validate.optFlag   (spEdAdaptiveDailyLivingReviewedNA,                @"Invalid box value");
            var    vSpEdAdaptiveDailyLivingSourceJSON                 = Validate.optString (spEdAdaptiveDailyLivingSourceJSON,                Messages.INVALID_TEXT);
            var    vSpEdAdaptiveDailyLivingBaselineValue              = Validate.optString (spEdAdaptiveDailyLivingBaselineValue,             Messages.INVALID_TEXT);
            var    vSpEdAdaptiveDailyLivingBaselineUnit               = Validate.optString (spEdAdaptiveDailyLivingBaselineUnit,              Messages.INVALID_TEXT);
            var    vSpEdAdaptiveDailyLivingToolsUsed                  = Validate.optString (spEdAdaptiveDailyLivingToolsUsed,                 Messages.INVALID_TEXT);
            var    vSpEdAdaptiveDailyLivingToolsUsedJSON              = Validate.optString (spEdAdaptiveDailyLivingToolsUsedJSON,             Messages.INVALID_TEXT); 
            var    vSpEdAdaptiveDailyLivingBaselineDate               = Validate.optDate   (spEdAdaptiveDailyLivingBaselineDate,              Messages.INVALID_DATE);
            var    vSpEdAdaptiveDailyLivingImpactSummary              = Validate.optString (spEdAdaptiveDailyLivingImpactSummary,             Messages.INVALID_TEXT);

            var    vSpEdSocialEmotionalBehavioralReviewedNA           = Validate.optFlag   (spEdSocialEmotionalBehavioralReviewedNA,          @"Invalid box value"); 
            var    vSpEdSocialEmotionalBehavioralSourceJSON           = Validate.optString (spEdSocialEmotionalBehavioralSourceJSON,          Messages.INVALID_TEXT); 
            var    vSpEdSocialEmotionalBehavioralBaselineValue        = Validate.optString (spEdSocialEmotionalBehavioralBaselineValue,       Messages.INVALID_TEXT); 
            var    vSpEdSocialEmotionalBehavioralBaselineUnit         = Validate.optString (spEdSocialEmotionalBehavioralBaselineUnit,        Messages.INVALID_TEXT); 
            var    vSpEdSocialEmotionalBehavioralToolsUsed            = Validate.optString (spEdSocialEmotionalBehavioralToolsUsed,           Messages.INVALID_TEXT); 
            var    vSpEdSocialEmotionalBehavioralToolsUsedJSON        = Validate.optString (spEdSocialEmotionalBehavioralToolsUsedJSON,       Messages.INVALID_TEXT); 
            var    vSpEdSocialEmotionalBehavioralBaselineDate         = Validate.optDate   (spEdSocialEmotionalBehavioralBaselineDate,        Messages.INVALID_DATE); 
            var    vSpEdSocialEmotionalBehavioralImpactSummary        = Validate.optString (spEdSocialEmotionalBehavioralImpactSummary,       Messages.INVALID_TEXT); 

            var    vSpEdStudentStrengthsSource                        = Validate.optString (spEdStudentStrengthsSource,                       Messages.INVALID_TEXT);
            var    vSpEdStudentStrengthsSourceNames                   = Validate.optString (spEdStudentStrengthsSourceNames,                  Messages.INVALID_TEXT);
            var    vSpEdParentConcernsSource                          = Validate.optString (spEdParentConcernsSource,                         Messages.INVALID_TEXT);
            var    vSpEdParentConcernsSourceNames                     = Validate.optString (spEdParentConcernsSourceNames,                    Messages.INVALID_TEXT);
            var    vSpEdReadingSource                                 = Validate.optString (spEdReadingSource,                                Messages.INVALID_TEXT);
            var    vSpEdReadingSourceNames                            = Validate.optString (spEdReadingSourceNames,                           Messages.INVALID_TEXT);
            var    vSpEdWritingSource                                 = Validate.optString (spEdWritingSource,                                Messages.INVALID_TEXT);
            var    vSpEdWritingSourceNames                            = Validate.optString (spEdWritingSourceNames,                           Messages.INVALID_TEXT);
            var    vSpEdMathSource                                    = Validate.optString (spEdMathSource,                                   Messages.INVALID_TEXT);
            var    vSpEdMathSourceNames                               = Validate.optString (spEdMathSourceNames,                              Messages.INVALID_TEXT);
            var    vSpEdCommunicationDevSource                        = Validate.optString (spEdCommunicationDevSource,                       Messages.INVALID_TEXT);
            var    vSpEdCommunicationDevSourceNames                   = Validate.optString (spEdCommunicationDevSourceNames,                  Messages.INVALID_TEXT);
            var    vSpEdGrossFineMotorSource                          = Validate.optString (spEdGrossFineMotorSource,                         Messages.INVALID_TEXT);
            var    vSpEdGrossFineMotorSourceNames                     = Validate.optString (spEdGrossFineMotorSourceNames,                    Messages.INVALID_TEXT);
            var    vSpEdHealthSource                                  = Validate.optString (spEdHealthSource,                                 Messages.INVALID_TEXT);
            var    vSpEdHealthSourceNames                             = Validate.optString (spEdHealthSourceNames,                            Messages.INVALID_TEXT);
            var    vSpEdVocationalSource                              = Validate.optString (spEdVocationalSource,                             Messages.INVALID_TEXT);
            var    vSpEdVocationalSourceNames                         = Validate.optString (spEdVocationalSourceNames,                        Messages.INVALID_TEXT);
            var    vSpEdAdaptiveDailyLivingSource                     = Validate.optString (spEdAdaptiveDailyLivingSource,                    Messages.INVALID_TEXT);
            var    vSpEdAdaptiveDailyLivingSourceNames                = Validate.optString (spEdAdaptiveDailyLivingSourceNames,               Messages.INVALID_TEXT);
            var    vSpEdSocialEmotionalBehavioralSource               = Validate.optString (spEdSocialEmotionalBehavioralSource,              Messages.INVALID_TEXT); 
            var    vSpEdSocialEmotionalBehavioralSourceNames          = Validate.optString (spEdSocialEmotionalBehavioralSourceNames,         Messages.INVALID_TEXT); 

            var    vSpEdReadingBaselineUnitNames                      = Validate.optString (spEdReadingBaselineUnitNames,                     Messages.INVALID_TEXT);
            var    vSpEdWritingBaselineUnitNames                      = Validate.optString (spEdWritingBaselineUnitNames,                     Messages.INVALID_TEXT);
            var    vSpEdMathBaselineUnitNames                         = Validate.optString (spEdMathBaselineUnitNames,                        Messages.INVALID_TEXT);
            var    vSpEdCommunicationDevBaselineUnitNames             = Validate.optString (spEdCommunicationDevBaselineUnitNames,            Messages.INVALID_TEXT);
            var    vSpEdGrossFineMotorBaselineUnitNames               = Validate.optString (spEdGrossFineMotorBaselineUnitNames,              Messages.INVALID_TEXT);
            var    vSpEdHealthBaselineUnitNames                       = Validate.optString (spEdHealthBaselineUnitNames,                      Messages.INVALID_TEXT);
            var    vSpEdVocationalBaselineUnitNames                   = Validate.optString (spEdVocationalBaselineUnitNames,                  Messages.INVALID_TEXT);
            var    vSpEdAdaptiveDailyLivingBaselineUnitNames          = Validate.optString (spEdAdaptiveDailyLivingBaselineUnitNames,         Messages.INVALID_TEXT);
            var    vSpEdSocialEmotionalBehavioralBaselineUnitNames    = Validate.optString (spEdSocialEmotionalBehavioralBaselineUnitNames,   Messages.INVALID_TEXT); 

            var    vSpEdReadingToolsUsedNames                         = Validate.optString (spEdReadingToolsUsedNames,                        Messages.INVALID_TEXT);
            var    vSpEdWritingToolsUsedNames                         = Validate.optString (spEdWritingToolsUsedNames,                        Messages.INVALID_TEXT);
            var    vSpEdMathToolsUsedNames                            = Validate.optString (spEdMathToolsUsedNames,                           Messages.INVALID_TEXT);
            var    vSpEdCommunicationDevToolsUsedNames                = Validate.optString (spEdCommunicationDevToolsUsedNames,               Messages.INVALID_TEXT);
            var    vSpEdGrossFineMotorToolsUsedNames                  = Validate.optString (spEdGrossFineMotorToolsUsedNames,                 Messages.INVALID_TEXT);
            var    vSpEdHealthToolsUsedNames                          = Validate.optString (spEdHealthToolsUsedNames,                         Messages.INVALID_TEXT);
            var    vSpEdVocationalToolsUsedNames                      = Validate.optString (spEdVocationalToolsUsedNames,                     Messages.INVALID_TEXT);
            var    vSpEdAdaptiveDailyLivingToolsUsedNames             = Validate.optString (spEdAdaptiveDailyLivingToolsUsedNames,            Messages.INVALID_TEXT);
            var    vSpEdSocialEmotionalBehavioralToolsUsedNames       = Validate.optString (spEdSocialEmotionalBehavioralToolsUsedNames,      Messages.INVALID_TEXT); 

            var    vSpEdAmendmentReasonsOtherOption                   = Validate.optString (spEdAmendmentReasonsOtherOption,                  Messages.INVALID_TEXT);
            var    vSpEdMeetingPurposeOtherOption                     = Validate.optString (spEdMeetingPurposeOtherOption,                    Messages.INVALID_TEXT);
            var    vSpEdFacilitatorUserID                             = Validate.optInteger(spEdFacilitatorUserID,                            Messages.INVALID_TEXT, true);
            var    vSpEdFacilitatorUserName                           = Validate.optString (spEdFacilitatorUserName,                          Messages.INVALID_TEXT);
            var    vSpEdCaseManagerUserID                             = Validate.optInteger(spEdCaseManagerUserID,                            Messages.INVALID_TEXT, true);
            var    vSpEdCaseManagerUserName                           = Validate.optString (spEdCaseManagerUserName,                          Messages.INVALID_TEXT);
            var    vSpEdMeetingDate                                   = Validate.optDate   (spEdMeetingDate,                                  Messages.INVALID_DATE);
            var    vSpEdMeetingDurationInMins                         = Validate.optInteger(spEdMeetingDurationInMins,                        Messages.INVALID_TEXT, true);
            var    vSpEdMeetingTime                                   = Validate.optString (spEdMeetingTime,                                  Messages.INVALID_TEXT);
            var    vSpEdMeetingTitle                                  = Validate.optString (spEdMeetingTitle,                                 Messages.INVALID_TEXT);
            



            parms.Add(Database.SqlParm("@clientID",                                             SqlDbType.Int,     vClientID,                                             ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID",                                                SqlDbType.Int,     vPatID,                                                ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdSpecialTransportation",                            SqlDbType.Bit,     vSpEdSpecialTransportation,                            ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdLastEvalDate",                                     SqlDbType.Date,    vSpEdLastEvalDate,                                     ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdLastAnnualIEPDate",                                SqlDbType.Date,    vSpEdLastAnnualIEPDate,                                ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdNextAnnualIEPDate",                                SqlDbType.Date,    vSpEdNextAnnualIEPDate,                                ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdCurIEPDate",                                       SqlDbType.Date,    vSpEdCurIEPDate,                                       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdDisability1Code",                                  SqlDbType.Int,     vSpEdDisability1Code,                                  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdDisability2Code",                                  SqlDbType.Int,     vSpEdDisability2Code,                                  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdExitedSpEdDate",                                   SqlDbType.Date,    vSpEdExitedSpEdDate,                                   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdStudentStrengths",                                 SqlDbType.VarChar, vSpEdStudentStrengths,                                 ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdParentConcerns",                                   SqlDbType.VarChar, vSpEdParentConcerns,                                   ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdProgressMonitoringData",                           SqlDbType.VarChar, vSpEdProgressMonitoringData,                           ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdStudentPresentLevelsStatement",                    SqlDbType.VarChar, vSpEdStudentPresentLevelsStatement,                    ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdStudentDisabilityAffectsPerformance",              SqlDbType.Bit,     vSpEdStudentDisabilityAffectsPerformance,              ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdCurEligibilityDate",                               SqlDbType.Date,    vSpEdCurEligibilityDate,                               ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdInitEligibilityDate",                              SqlDbType.Date,    vSpEdInitEligibilityDate,                              ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdIEPAttendeesIdentified",                           SqlDbType.Bit,     vSpEdIEPAttendeesIdentified,                           ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdEligibilityReasons",                               SqlDbType.VarChar, vSpEdEligibilityReasons,                               ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdPlanTranslateToLanguageCodeID",                    SqlDbType.BigInt,  vSpEdPlanTranslateToLanguageCodeID,                    ParameterDirection.Input));

            parms.Add(Database.SqlParm("@spEdInitRefDate",                                      SqlDbType.Date,    vSpEdInitRefDate,                                      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdReferringPartyCode",                               SqlDbType.Int,     vSpEdReferringPartyCode,                               ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdReferringPartyOtherOption",                        SqlDbType.VarChar, vSpEdReferringPartyOtherOption,                        ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@spEdDistrictReceivedParentConsentDate",                SqlDbType.Date,    vSpEdDistrictReceivedParentConsentDate,                ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdMeetingPurposeDataJSON",                           SqlDbType.VarChar, vSpEdMeetingPurposeDataJSON,                           ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdAdditionalMeetingPurposeDataJSON",                 SqlDbType.VarChar, vSpEdAdditionalMeetingPurposeDataJSON,                 ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdAmendmentReasonsDataJSON",                         SqlDbType.VarChar, vSpEdAmendmentReasonsDataJSON,                         ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdPlanTypeCode",                                     SqlDbType.Int,     vSpEdPlanTypeCode,                                     ParameterDirection.Input));

            parms.Add(Database.SqlParm("@spEdStudentLanguageCodeID",                            SqlDbType.BigInt,  vSpEdStudentLanguageCodeID,                            ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdStudentRaceCode",                                  SqlDbType.Int,     vSpEdStudentRaceCode,                                  ParameterDirection.Input));

            parms.Add(Database.SqlParm("@spEdNextEvalDate",                                     SqlDbType.DateTime, vSpEdNextEvalDate,                                    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdEnteredSpEdDate",                                  SqlDbType.DateTime, vSpEdEnteredSpEdDate,                                 ParameterDirection.Input));

            parms.Add(Database.SqlParm("@spEdStudentLanguageEnglishLearner",                    SqlDbType.Bit,     vSpEdStudentLanguageEnglishLearner,                    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdStudentLanguageInfoReclassified",                  SqlDbType.Bit,     vSpEdStudentLanguageInfoReclassified,                  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdStudentLanguageInterpreterNeeded",                 SqlDbType.Bit,     vSpEdStudentLanguageInterpreterNeeded,                 ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdStudentLanguageTranslationRequested",              SqlDbType.Bit,     vSpEdStudentLanguageTranslationRequested,              ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdStudentLanguageEnglishLearnerUndesignatedPreschool", SqlDbType.Bit,   vSpEdStudentLanguageEnglishLearnerUndesignatedPreSchool, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@spEdServicesDataJSON",                                 SqlDbType.VarChar, vSpEdServicesDataJSON,                                 ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@MsgNoClient",                                          SqlDbType.VarChar, Messages.INVALID_CLIENT_ID,                            ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgNoSite",                                            SqlDbType.VarChar, Messages.INVALID_SITE_ID,                              ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgNoFullEdit",                                        SqlDbType.VarChar, Messages.EDIT_REC_NO_EDIT_FULL,                        ParameterDirection.Input, 1000));

            parms.Add(Database.SqlParm("@spEdTransitionGoalEducation",                          SqlDbType.Bit,     vSpEdTransitionGoalEducation,                          ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdTransitionGoalTraining",                           SqlDbType.Bit,     vSpEdTransitionGoalTraining,                           ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdTransitionGoalEmployment",                         SqlDbType.Bit,     vSpEdTransitionGoalEmployment,                         ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdTransitionGoalIndependentLiving",                  SqlDbType.Bit,     vSpEdTransitionGoalIndependentLiving,                  ParameterDirection.Input));

            parms.Add(Database.SqlParm("@spEdDevAcaFunSkillsReading",                           SqlDbType.VarChar, vSpEdDevAcaFunSkillsReading,                           ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdDevAcaFunSkillsWriting",                           SqlDbType.VarChar, vSpEdDevAcaFunSkillsWriting,                           ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdDevAcaFunSkillsMath",                              SqlDbType.VarChar, vSpEdDevAcaFunSkillsMath,                              ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdDevAcaFunSkillsCommunicationDev",                  SqlDbType.VarChar, vSpEdDevAcaFunSkillsCommunicationDev,                  ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdDevAcaFunSkillsGrossFineMotorDev",                 SqlDbType.VarChar, vSpEdDevAcaFunSkillsGrossFineMotorDev,                 ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdDevAcaFunSkillsHealth",                            SqlDbType.VarChar, vSpEdDevAcaFunSkillsHealth,                            ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdDevAcaFunSkillsVocational",                        SqlDbType.VarChar, vSpEdDevAcaFunSkillsVocational,                        ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdDevAcaFunSkillsAdaptiveDailyLiving",               SqlDbType.VarChar, vSpEdDevAcaFunSkillsAdaptiveDailyLiving,               ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdDevAcaFunSkillsAreasOfNeccessity",                 SqlDbType.VarChar, vSpEdDevAcaFunSkillsAreasOfNeccessity,                 ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdDevAcaFunSkillsSocialEmotionalBehavioral",         SqlDbType.VarChar, vSpEdDevAcaFunSkillsSocialEmotionalBehavioral,         ParameterDirection.Input, -1)); 

            parms.Add(Database.SqlParm("@spEdParticipantDetailsJSON",                           SqlDbType.VarChar, vSpEdParticipantDetailsJSON,                           ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@spEdProceduralSafeguardsSentDate",                     SqlDbType.Date,    vSpEdProceduralSafeguardsSentDate,                     ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdSpecialTransportationComments",                    SqlDbType.VarChar, vSpEdSpecialTransportationComments,                    ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdVehicleAdaptationType",                            SqlDbType.Int,     vSpEdVehicleAdaptationType,                            ParameterDirection.Input));
            parms.Add(Database.SqlParm("@speciallyAdaptedVehicleForTransportation",             SqlDbType.Bit,     vSpeciallyAdaptedVehicleForTransportation,             ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdCorrectionDetails",                                SqlDbType.VarChar, vSpEdCorrectionDetails,                                ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdPreferredLanguageCodeID",                          SqlDbType.BigInt,  vSpEdPreferredLanguageCodeID,                          ParameterDirection.Input));

            parms.Add(Database.SqlParm("@spEdPresentLevelsDataJSON",                            SqlDbType.VarChar, vSpEdPresentLevelsDataJSON,                            ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdPresentLevelsPreparedBy",                          SqlDbType.BigInt,  vSpEdPresentLevelsPreparedBy,                          ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdPresentLevelsPreparedByName",                      SqlDbType.VarChar, vSpEdPresentLevelsPreparedByName,                      ParameterDirection.Input, 200));

            parms.Add(Database.SqlParm("@spEdStudentStrengthsSourceJSON",                       SqlDbType.VarChar, vSpEdStudentStrengthsSourceJSON,                       ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdStudentStrengthsImpact",                           SqlDbType.VarChar, vSpEdStudentStrengthsImpact,                           ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdParentConcernsSourceJSON",                         SqlDbType.VarChar, vSpEdParentConcernsSourceJSON,                         ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@spEdReadingReviewedNA",                                SqlDbType.Bit,     vSpEdReadingReviewedNA,                                ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdReadingSourceJSON",                                SqlDbType.VarChar, vSpEdReadingSourceJSON,                                ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdReadingBaselineValue",                             SqlDbType.VarChar, vSpEdReadingBaselineValue,                             ParameterDirection.Input, 100));
            parms.Add(Database.SqlParm("@spEdReadingBaselineUnit",                              SqlDbType.VarChar, vSpEdReadingBaselineUnit,                              ParameterDirection.Input, 100));
            parms.Add(Database.SqlParm("@spEdReadingToolsUsed",                                 SqlDbType.VarChar, vSpEdReadingToolsUsed,                                 ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@spEdReadingToolsUsedJSON",                             SqlDbType.VarChar, vSpEdReadingToolsUsedJSON,                             ParameterDirection.Input, -1)); 
            parms.Add(Database.SqlParm("@spEdReadingBaselineDate",                              SqlDbType.Date,    vSpEdReadingBaselineDate,                              ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdReadingImpactSummary",                             SqlDbType.VarChar, vSpEdReadingImpactSummary,                             ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@spEdWritingReviewedNA",                                SqlDbType.Bit,     vSpEdWritingReviewedNA,                                ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdWritingSourceJSON",                                SqlDbType.VarChar, vSpEdWritingSourceJSON,                                ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdWritingBaselineValue",                             SqlDbType.VarChar, vSpEdWritingBaselineValue,                             ParameterDirection.Input, 100));
            parms.Add(Database.SqlParm("@spEdWritingBaselineUnit",                              SqlDbType.VarChar, vSpEdWritingBaselineUnit,                              ParameterDirection.Input, 100));
            parms.Add(Database.SqlParm("@spEdWritingToolsUsed",                                 SqlDbType.VarChar, vSpEdWritingToolsUsed,                                 ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@spEdWritingToolsUsedJSON",                             SqlDbType.VarChar, vSpEdWritingToolsUsedJSON,                             ParameterDirection.Input, -1)); 
            parms.Add(Database.SqlParm("@spEdWritingBaselineDate",                              SqlDbType.Date,    vSpEdWritingBaselineDate,                              ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdWritingImpactSummary",                             SqlDbType.VarChar, vSpEdWritingImpactSummary,                             ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@spEdMathReviewedNA",                                   SqlDbType.Bit,     vSpEdMathReviewedNA,                                   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdMathSourceJSON",                                   SqlDbType.VarChar, vSpEdMathSourceJSON,                                   ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdMathBaselineValue",                                SqlDbType.VarChar, vSpEdMathBaselineValue,                                ParameterDirection.Input, 100));
            parms.Add(Database.SqlParm("@spEdMathBaselineUnit",                                 SqlDbType.VarChar, vSpEdMathBaselineUnit,                                 ParameterDirection.Input, 100));
            parms.Add(Database.SqlParm("@spEdMathToolsUsed",                                    SqlDbType.VarChar, vSpEdMathToolsUsed,                                    ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@spEdMathToolsUsedJSON",                                SqlDbType.VarChar, vSpEdMathToolsUsedJSON,                                ParameterDirection.Input, -1)); 
            parms.Add(Database.SqlParm("@spEdMathBaselineDate",                                 SqlDbType.Date,    vSpEdMathBaselineDate,                                 ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdMathImpactSummary",                                SqlDbType.VarChar, vSpEdMathImpactSummary,                                ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@spEdCommunicationDevReviewedNA",                       SqlDbType.Bit,     vSpEdCommunicationDevReviewedNA,                       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdCommunicationDevSourceJSON",                       SqlDbType.VarChar, vSpEdCommunicationDevSourceJSON,                       ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdCommunicationDevBaselineValue",                    SqlDbType.VarChar, vSpEdCommunicationDevBaselineValue,                    ParameterDirection.Input, 100));
            parms.Add(Database.SqlParm("@spEdCommunicationDevBaselineUnit",                     SqlDbType.VarChar, vSpEdCommunicationDevBaselineUnit,                     ParameterDirection.Input, 100));
            parms.Add(Database.SqlParm("@spEdCommunicationDevToolsUsed",                        SqlDbType.VarChar, vSpEdCommunicationDevToolsUsed,                        ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@spEdCommunicationDevToolsUsedJSON",                    SqlDbType.VarChar, vSpEdCommunicationDevToolsUsedJSON,                    ParameterDirection.Input, -1)); 
            parms.Add(Database.SqlParm("@spEdCommunicationDevBaselineDate",                     SqlDbType.Date,    vSpEdCommunicationDevBaselineDate,                     ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdCommunicationDevImpactSummary",                    SqlDbType.VarChar, vSpEdCommunicationDevImpactSummary,                    ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@spEdGrossFineMotorReviewedNA",                         SqlDbType.Bit,     vSpEdGrossFineMotorReviewedNA,                         ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdGrossFineMotorSourceJSON",                         SqlDbType.VarChar, vSpEdGrossFineMotorSourceJSON,                         ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdGrossFineMotorBaselineValue",                      SqlDbType.VarChar, vSpEdGrossFineMotorBaselineValue,                      ParameterDirection.Input, 100));
            parms.Add(Database.SqlParm("@spEdGrossFineMotorBaselineUnit",                       SqlDbType.VarChar, vSpEdGrossFineMotorBaselineUnit,                       ParameterDirection.Input, 100));
            parms.Add(Database.SqlParm("@spEdGrossFineMotorToolsUsed",                          SqlDbType.VarChar, vSpEdGrossFineMotorToolsUsed,                          ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@spEdGrossFineMotorToolsUsedJSON",                      SqlDbType.VarChar, vSpEdGrossFineMotorToolsUsedJSON,                      ParameterDirection.Input, -1)); 
            parms.Add(Database.SqlParm("@spEdGrossFineMotorBaselineDate",                       SqlDbType.Date,    vSpEdGrossFineMotorBaselineDate,                       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdGrossFineMotorImpactSummary",                      SqlDbType.VarChar, vSpEdGrossFineMotorImpactSummary,                      ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@spEdHealthReviewedNA",                                 SqlDbType.Bit,     vSpEdHealthReviewedNA,                                 ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdHealthSourceJSON",                                 SqlDbType.VarChar, vSpEdHealthSourceJSON,                                 ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdHealthBaselineValue",                              SqlDbType.VarChar, vSpEdHealthBaselineValue,                              ParameterDirection.Input, 100));
            parms.Add(Database.SqlParm("@spEdHealthBaselineUnit",                               SqlDbType.VarChar, vSpEdHealthBaselineUnit,                               ParameterDirection.Input, 100));
            parms.Add(Database.SqlParm("@spEdHealthToolsUsed",                                  SqlDbType.VarChar, vSpEdHealthToolsUsed,                                  ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@spEdHealthToolsUsedJSON",                              SqlDbType.VarChar, vSpEdHealthToolsUsedJSON,                              ParameterDirection.Input, -1)); 
            parms.Add(Database.SqlParm("@spEdHealthBaselineDate",                               SqlDbType.Date,    vSpEdHealthBaselineDate,                               ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdHealthImpactSummary",                              SqlDbType.VarChar, vSpEdHealthImpactSummary,                              ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@spEdVocationalReviewedNA",                             SqlDbType.Bit,     vSpEdVocationalReviewedNA,                             ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdVocationalSourceJSON",                             SqlDbType.VarChar, vSpEdVocationalSourceJSON,                             ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdVocationalBaselineValue",                          SqlDbType.VarChar, vSpEdVocationalBaselineValue,                          ParameterDirection.Input, 100));
            parms.Add(Database.SqlParm("@spEdVocationalBaselineUnit",                           SqlDbType.VarChar, vSpEdVocationalBaselineUnit,                           ParameterDirection.Input, 100));
            parms.Add(Database.SqlParm("@spEdVocationalToolsUsed",                              SqlDbType.VarChar, vSpEdVocationalToolsUsed,                              ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@spEdVocationalToolsUsedJSON",                          SqlDbType.VarChar, vSpEdVocationalToolsUsedJSON,                          ParameterDirection.Input, -1)); 
            parms.Add(Database.SqlParm("@spEdVocationalBaselineDate",                           SqlDbType.Date,    vSpEdVocationalBaselineDate,                           ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdVocationalImpactSummary",                          SqlDbType.VarChar, vSpEdVocationalImpactSummary,                          ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@spEdAdaptiveDailyLivingReviewedNA",                    SqlDbType.Bit,     vSpEdAdaptiveDailyLivingReviewedNA,                    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdAdaptiveDailyLivingSourceJSON",                    SqlDbType.VarChar, vSpEdAdaptiveDailyLivingSourceJSON,                    ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdAdaptiveDailyLivingBaselineValue",                 SqlDbType.VarChar, vSpEdAdaptiveDailyLivingBaselineValue,                 ParameterDirection.Input, 100));
            parms.Add(Database.SqlParm("@spEdAdaptiveDailyLivingBaselineUnit",                  SqlDbType.VarChar, vSpEdAdaptiveDailyLivingBaselineUnit,                  ParameterDirection.Input, 100));
            parms.Add(Database.SqlParm("@spEdAdaptiveDailyLivingToolsUsed",                     SqlDbType.VarChar, vSpEdAdaptiveDailyLivingToolsUsed,                     ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@spEdAdaptiveDailyLivingToolsUsedJSON",                 SqlDbType.VarChar, vSpEdAdaptiveDailyLivingToolsUsedJSON,                 ParameterDirection.Input, -1)); 
            parms.Add(Database.SqlParm("@spEdAdaptiveDailyLivingBaselineDate",                  SqlDbType.Date,    vSpEdAdaptiveDailyLivingBaselineDate,                  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdAdaptiveDailyLivingImpactSummary",                 SqlDbType.VarChar, vSpEdAdaptiveDailyLivingImpactSummary,                 ParameterDirection.Input, -1));
            
            parms.Add(Database.SqlParm("@spEdSocialEmotionalBehavioralReviewedNA",              SqlDbType.Bit,     vSpEdSocialEmotionalBehavioralReviewedNA,              ParameterDirection.Input)); 
            parms.Add(Database.SqlParm("@spEdSocialEmotionalBehavioralSourceJSON",              SqlDbType.VarChar, vSpEdSocialEmotionalBehavioralSourceJSON,              ParameterDirection.Input, -1)); 
            parms.Add(Database.SqlParm("@spEdSocialEmotionalBehavioralBaselineValue",           SqlDbType.VarChar, vSpEdSocialEmotionalBehavioralBaselineValue,           ParameterDirection.Input, 100)); 
            parms.Add(Database.SqlParm("@spEdSocialEmotionalBehavioralBaselineUnit",            SqlDbType.VarChar, vSpEdSocialEmotionalBehavioralBaselineUnit,            ParameterDirection.Input, 100)); 
            parms.Add(Database.SqlParm("@spEdSocialEmotionalBehavioralToolsUsed",               SqlDbType.VarChar, vSpEdSocialEmotionalBehavioralToolsUsed,               ParameterDirection.Input, 500)); 
            parms.Add(Database.SqlParm("@spEdSocialEmotionalBehavioralToolsUsedJSON",           SqlDbType.VarChar, vSpEdSocialEmotionalBehavioralToolsUsedJSON,           ParameterDirection.Input, -1)); 
            parms.Add(Database.SqlParm("@spEdSocialEmotionalBehavioralBaselineDate",            SqlDbType.Date,    vSpEdSocialEmotionalBehavioralBaselineDate,            ParameterDirection.Input)); 
            parms.Add(Database.SqlParm("@spEdSocialEmotionalBehavioralImpactSummary",           SqlDbType.VarChar, vSpEdSocialEmotionalBehavioralImpactSummary,           ParameterDirection.Input, -1)); 

            parms.Add(Database.SqlParm("@spEdStudentStrengthsSource",                           SqlDbType.VarChar, vSpEdStudentStrengthsSource,                           ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@spEdStudentStrengthsSourceNames",                      SqlDbType.VarChar, vSpEdStudentStrengthsSourceNames,                      ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdParentConcernsSource",                             SqlDbType.VarChar, vSpEdParentConcernsSource,                             ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@spEdParentConcernsSourceNames",                        SqlDbType.VarChar, vSpEdParentConcernsSourceNames,                        ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdReadingSource",                                    SqlDbType.VarChar, vSpEdReadingSource,                                    ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@spEdReadingSourceNames",                               SqlDbType.VarChar, vSpEdReadingSourceNames,                               ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdWritingSource",                                    SqlDbType.VarChar, vSpEdWritingSource,                                    ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@spEdWritingSourceNames",                               SqlDbType.VarChar, vSpEdWritingSourceNames,                               ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdMathSource",                                       SqlDbType.VarChar, vSpEdMathSource,                                       ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@spEdMathSourceNames",                                  SqlDbType.VarChar, vSpEdMathSourceNames,                                  ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdCommunicationDevSource",                           SqlDbType.VarChar, vSpEdCommunicationDevSource,                           ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@spEdCommunicationDevSourceNames",                      SqlDbType.VarChar, vSpEdCommunicationDevSourceNames,                      ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdGrossFineMotorSource",                             SqlDbType.VarChar, vSpEdGrossFineMotorSource,                             ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@spEdGrossFineMotorSourceNames",                        SqlDbType.VarChar, vSpEdGrossFineMotorSourceNames,                        ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdHealthSource",                                     SqlDbType.VarChar, vSpEdHealthSource,                                     ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@spEdHealthSourceNames",                                SqlDbType.VarChar, vSpEdHealthSourceNames,                                ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdVocationalSource",                                 SqlDbType.VarChar, vSpEdVocationalSource,                                 ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@spEdVocationalSourceNames",                            SqlDbType.VarChar, vSpEdVocationalSourceNames,                            ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdAdaptiveDailyLivingSource",                        SqlDbType.VarChar, vSpEdAdaptiveDailyLivingSource,                        ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@spEdAdaptiveDailyLivingSourceNames",                   SqlDbType.VarChar, vSpEdAdaptiveDailyLivingSourceNames,                   ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdSocialEmotionalBehavioralSource",                  SqlDbType.VarChar, vSpEdSocialEmotionalBehavioralSource,                  ParameterDirection.Input, 500)); 
            parms.Add(Database.SqlParm("@spEdSocialEmotionalBehavioralSourceNames",             SqlDbType.VarChar, vSpEdSocialEmotionalBehavioralSourceNames,             ParameterDirection.Input, -1)); 

            parms.Add(Database.SqlParm("@spEdReadingBaselineUnitNames",                         SqlDbType.VarChar, vSpEdReadingBaselineUnitNames,                         ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@spEdWritingBaselineUnitNames",                         SqlDbType.VarChar, vSpEdWritingBaselineUnitNames,                         ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@spEdMathBaselineUnitNames",                            SqlDbType.VarChar, vSpEdMathBaselineUnitNames,                            ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@spEdCommunicationDevBaselineUnitNames",                SqlDbType.VarChar, vSpEdCommunicationDevBaselineUnitNames,                ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@spEdGrossFineMotorBaselineUnitNames",                  SqlDbType.VarChar, vSpEdGrossFineMotorBaselineUnitNames,                  ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@spEdHealthBaselineUnitNames",                          SqlDbType.VarChar, vSpEdHealthBaselineUnitNames,                          ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@spEdVocationalBaselineUnitNames",                      SqlDbType.VarChar, vSpEdVocationalBaselineUnitNames,                      ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@spEdAdaptiveDailyLivingBaselineUnitNames",             SqlDbType.VarChar, vSpEdAdaptiveDailyLivingBaselineUnitNames,             ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@spEdSocialEmotionalBehavioralBaselineUnitNames",       SqlDbType.VarChar, vSpEdSocialEmotionalBehavioralBaselineUnitNames,       ParameterDirection.Input, 256)); 

            parms.Add(Database.SqlParm("@spEdReadingToolsUsedNames",                            SqlDbType.VarChar, vSpEdReadingToolsUsedNames,                            ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdWritingToolsUsedNames",                            SqlDbType.VarChar, vSpEdWritingToolsUsedNames,                            ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdMathToolsUsedNames",                               SqlDbType.VarChar, vSpEdMathToolsUsedNames,                               ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdCommunicationDevToolsUsedNames",                   SqlDbType.VarChar, vSpEdCommunicationDevToolsUsedNames,                   ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdGrossFineMotorToolsUsedNames",                     SqlDbType.VarChar, vSpEdGrossFineMotorToolsUsedNames,                     ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdHealthToolsUsedNames",                             SqlDbType.VarChar, vSpEdHealthToolsUsedNames,                             ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdVocationalToolsUsedNames",                         SqlDbType.VarChar, vSpEdVocationalToolsUsedNames,                         ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdAdaptiveDailyLivingToolsUsedNames",                SqlDbType.VarChar, vSpEdAdaptiveDailyLivingToolsUsedNames,                ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdSocialEmotionalBehavioralToolsUsedNames",          SqlDbType.VarChar, vSpEdSocialEmotionalBehavioralToolsUsedNames,          ParameterDirection.Input, -1)); 

            parms.Add(Database.SqlParm("@spEdAmendmentReasonsOtherOption",                      SqlDbType.VarChar, vSpEdAmendmentReasonsOtherOption,                      ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdMeetingPurposeOtherOption",                        SqlDbType.VarChar, vSpEdMeetingPurposeOtherOption,                        ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@spEdFacilitatorUserID",                                SqlDbType.BigInt,  vSpEdFacilitatorUserID,                                ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdFacilitatorUserName",                              SqlDbType.VarChar, vSpEdFacilitatorUserName,                              ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@spEdCaseManagerUserID",                                SqlDbType.BigInt,  vSpEdCaseManagerUserID,                                ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdCaseManagerUserName",                              SqlDbType.VarChar, vSpEdCaseManagerUserName,                              ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@spEdMeetingDate",                                      SqlDbType.Date,    vSpEdMeetingDate,                                      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdMeetingDurationInMins",                            SqlDbType.Int,     vSpEdMeetingDurationInMins,                            ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdMeetingTime",                                      SqlDbType.VarChar, vSpEdMeetingTime,                                      ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@spEdMeetingTitle",                                     SqlDbType.VarChar, vSpEdMeetingTitle,                                     ParameterDirection.Input, 256));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            var so = Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "PATIENT_IEP_Save", Messages.DUP_PAT_REC, ref parms,
            delegate ()
            {
            });

            if (so.status == Return.RET_SUCCESS && validateRec == "0")
            {
                string flagVal = (sendMeetingInvitesFlag ?? "").Trim();

                /*----------------------------------------------------
                 * If resending to one participant (flag=2),
                 * check if meeting details changed since last session.
                 * If they did, override to send all (flag=1).
                 *----------------------------------------------------*/

                if (flagVal == "2")
                {
                    try
                    {
                        TeleIEPSession lastSession = TeleIEPSessions.loadLastEnteredForClientPatient(
                            connSpedmon, log, uInfo, clientID, patID);

                        if (lastSession != null && lastSession.id > 0)
                        {
                            bool detailsChanged = false;

                            // Compare date
                            if (!String.IsNullOrWhiteSpace(spEdMeetingDate))
                            {
                                try
                                {
                                    DateTime newDate = DateTime.Parse(spEdMeetingDate);
                                    if (lastSession.meetingDate.Date != newDate.Date)
                                        detailsChanged = true;
                                }
                                catch { detailsChanged = true; }
                            }

                            // Compare time
                            if (!detailsChanged && !String.IsNullOrWhiteSpace(spEdMeetingTime))
                            {
                                try
                                {
                                    TimeSpan newTime = TimeSpan.Parse(spEdMeetingTime.Trim());
                                    if (lastSession.meetingTime != newTime)
                                        detailsChanged = true;
                                }
                                catch { detailsChanged = true; }
                            }

                            // Compare duration
                            if (!detailsChanged)
                            {
                                int newDuration = 0;
                                int.TryParse(spEdMeetingDurationInMins, out newDuration);
                                if (lastSession.meetingDurationInMins != newDuration)
                                    detailsChanged = true;
                            }

                            // Compare title
                            if (!detailsChanged)
                            {
                                string lastTitle = (lastSession.title ?? "").Trim();
                                string newTitle = (spEdMeetingTitle ?? "").Trim();
                                if (!lastTitle.Equals(newTitle, StringComparison.OrdinalIgnoreCase))
                                    detailsChanged = true;
                            }

                            if (detailsChanged)
                            {
                                // Meeting details changed - send to everyone
                                flagVal = "1";
                            }
                        }
                        else
                        {
                            // No existing session - send to everyone
                            flagVal = "1";
                        }
                    }
                    catch
                    {
                        // If we can't check, default to send all
                        flagVal = "1";
                    }
                }

                /*----------------------------------------------------
                 * Flag = '1' : Send all meeting invites
                 *----------------------------------------------------*/

                if (flagVal == "1")
                {
                    long facCheck = 0;
                    long.TryParse((spEdFacilitatorUserID ?? "").Trim(), out facCheck);

                    if (facCheck == 0)
                    {
                        so.status = Return.RET_ERROR;
                        so.message = @"Please select an IEP Meeting Contact before sending invites.";
                    }
                    else
                    {
                        ReturnSaveRecordWithJSONData sendResult = Patients.sendMeetingInvites(
                            connUsers, connSpedmon, log, uInfo, clientID, patID, "");

                        if (sendResult.status != Return.RET_SUCCESS)
                        {
                            so.status = sendResult.status;
                            so.message = sendResult.message;
                        }
                    }
                }
                /*----------------------------------------------------
                 * Flag = '2' : Resend invite to one participant
                 * (only reaches here if meeting details did NOT change)
                 *----------------------------------------------------*/
                else if (flagVal == "2")
                {
                    string vResendEmail = Validate.optString(resendParticipantEmail, Messages.INVALID_TEXT);
                    string vResendName = Validate.optString(resendParticipantName, Messages.INVALID_TEXT);
                    string vResendRole = Validate.optString(resendParticipantRole, Messages.INVALID_TEXT);

                    if (!String.IsNullOrWhiteSpace(vResendEmail))
                    {
                        ReturnSaveRecord resendResult = Patients.resendMeetingInvite(
                            connUsers, connSpedmon, log, uInfo,
                            clientID, patID, vResendEmail, vResendName, vResendRole);

                        if (resendResult.status != Return.RET_SUCCESS)
                        {
                            so.status = resendResult.status;
                            so.message = resendResult.message;
                        }
                    }
                    else
                    {
                        so.status = Return.RET_ERROR;
                        so.message = @"Participant email is required to resend an invite.";
                    }
           }
            }

            /*----------------------------------------------------
             * Process any meeting status/notes overrides
             * from the history dropdown and notes textarea
             *----------------------------------------------------*/

            if (so.status == Return.RET_SUCCESS)
            {
                try
                {
                    string overridesJSON = meetingStatusOverrides;
                    if (!String.IsNullOrWhiteSpace(overridesJSON) && overridesJSON != "{}")
                    {
                        var overrides = Newtonsoft.Json.JsonConvert.DeserializeObject<Dictionary<string, Dictionary<string, string>>>(overridesJSON);
                        if (overrides != null)
                        {
                            foreach (var kvp in overrides)
                            {
                                try
                                {
                                    string ovStatus = kvp.Value.ContainsKey("status") ? kvp.Value["status"] : "";
                                    string ovNotes  = kvp.Value.ContainsKey("notes")  ? kvp.Value["notes"]  : "";
                                    Patients.updateMeetingCompletionStatus(connUsers, log, uInfo, kvp.Key, ovStatus, ovNotes);
                                }
                                catch { }
                            }
                        }
                    }
                }
                catch { }
            }

            return so;
        }

        /***************************************************************************
         * mergeView */
        /**
         * 
         * 
         ***************************************************************************/
        public static ReturnDB mergeView(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                      int recViewType,
                                      bool pagedOrTop,
                                      string idx,
                                      string canEdit,
                                      string active,
                                      string source,
                                      string clientID,
                                      string pracID,
                                      string lname,
                                      string fname,
                                      string dob,
                                      string dos,
                                      string findCSIS,
                                      bool includeBlankCSIS,
                                      defineCols dc)
        {
            List<SqlParameter> parms = new List<SqlParameter>();

            string viewUDF = "PATIENTS_VIEW_MERGE (@clientID, @pracID, @lname, @fname, @dob, @active, null, @findCSIS, @inclUnknCSIS, @recID)";

            Object oCSIS = findCSIS; //Note: we're not validating the CSIS string because the whole point is to be able to find and fix records with invalid data.
            parms.Add(Database.SqlParm("@findCSIS", SqlDbType.Char, oCSIS, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@inclUnknCSIS", SqlDbType.Bit, includeBlankCSIS, ParameterDirection.Input));

            validateCommonViewParameters(uInfo, recViewType, clientID, pracID, lname, fname, dob, ref parms);
            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
        }

        /***************************************************************************
        * merge */
        /**
         * 
         * 
         ***************************************************************************/

        public static ReturnSaveRecord merge(SqlConnection connSpedmon
                                               , DetailsLog log
                                               , UserInfo uInfo
                                               , string clientID
                                               , string recIDToKeep
                                               , string patIDsToMerge
                                               , string validateRec)
        {
            ReturnSaveRecord so = new ReturnSaveRecord();

            List<SqlParameter> parms = new List<SqlParameter>();
            long vClientID = Validate.reqClientID(uInfo, clientID);
            Object vPatID = Spedmon.Validate.optInteger(recIDToKeep, Messages.INVALID_PAT_ID);

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));


            return Entities.merge(connSpedmon
                                   , log
                                   , uInfo
                                   , recIDToKeep
                                   , patIDsToMerge
                                   , validateRec
                                   , @"PATIENTS_MERGE"
                                   , ref parms);


        }

        /***************************************************************************
         * validateCommonViewParameters 
         *
         * 
         * 
         ***************************************************************************/

        private static void validateCommonViewParameters(UserInfo uInfo, int recViewType, string clientID, string pracID, string lname, string fname, string dob, ref List<SqlParameter> parms)
        {
            /*----------------------------
             * Client ID is required
             * for select views
             *----------------------------*/
            Object vClientID = null;

            if (recViewType != REC_VIEW_SEL) vClientID = Validate.optClientID(uInfo, clientID);
            else vClientID = Validate.reqClientID(uInfo, clientID);

            Object vPracID = Validate.optPracID(uInfo, pracID);
            Object vLname = Validate.optString(lname);
            Object vFname = Validate.optString(fname);
            Object vDob = Validate.optDate(dob, Messages.INVALID_DOB, Constants.VAL_OPT_DATE_NO_FUTURE);

            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID", SqlDbType.Int, vPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@lname", SqlDbType.NVarChar, vLname, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@fname", SqlDbType.NVarChar, vFname, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@dob", SqlDbType.DateTime, vDob, ParameterDirection.Input));

        }

        /***************************************************************************
         * view 
         *
         * Returns a list of patients for given criteria
         * 
         * TODO: Support for passing in siteID is only setup for viewSel
         * Add support for the viewTbl and viewObjects methods and the end points
         * that use those methods.
         ***************************************************************************/
        public static ReturnDB view (  SqlConnection connSpedmon
                                      , DetailsLog   log
                                      , UserInfo     uInfo
                                      , int          recViewType
                                      , bool         pagedOrTop
                                      , string       idx
                                      , string       canEdit
                                      , string       active
                                      , string       source
                                      , string       clientID
                                      , string       pracID
                                      , string       lname
                                      , string       fname
                                      , string       dob
                                      , string       dos
                                      , string       siteID
                                      , string       studentID                                      
                                      , defineCols   dc )
        {

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

            string viewUDF = "PATIENTS_VIEW (@userID, @userGroup, @userRank, @source, @clientID, @pracID, @siteID, @siteRefID, @lname, @fname, @dob, @dos, @active, @recID, @canEdit) ";

            Object vSource = Validate.optInteger(source, Messages.INVALID_DATA_SOURCE, true);

            /*----------------------------
             * Client ID is required
             * for select views
             *----------------------------*/

            //TODO: Consider using validateCommonViewParameters(); for a significantly shorter view() method

            Object vClientID = null;

            if (recViewType != REC_VIEW_SEL) vClientID = Validate.optClientID(uInfo, clientID);
            else vClientID = Validate.reqClientID(uInfo, clientID);

            Object vPracID    = Validate.optPracID (uInfo, pracID);
            Object vLname     = Validate.optString (lname);
            Object vFname     = Validate.optString (fname);
            Object vDob       = Validate.optDate   (dob, Messages.INVALID_DOB, Constants.VAL_OPT_DATE_NO_FUTURE);
            Object vDos       = Validate.optDate   (dos, Messages.SERVICE_DATE_BAD, Constants.VAL_OPT_DATE_NO_FUTURE);
            Object vSiteID    = Validate.optInteger(siteID,    Messages.INVALID_SITE_ID);
            Object vStudentID = Validate.optString (studentID, Messages.INVALID_STUDENT_ID);

            parms.Add(Database.SqlParm("@source",    SqlDbType.Int,       vSource,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@clientID",  SqlDbType.Int,       vClientID,  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID",    SqlDbType.Int,       vPracID,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@lname",     SqlDbType.NVarChar,  vLname,     ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@fname",     SqlDbType.NVarChar,  vFname,     ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@dob",       SqlDbType.DateTime,  vDob,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@dos",       SqlDbType.DateTime,  vDos,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@siteID",    SqlDbType.Int,       vSiteID,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@siteRefID", SqlDbType.NVarChar,  vStudentID, ParameterDirection.Input, 50));
            
            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        /***************************************************************************
         * viewObjects 
         *
         * Returns a list of patients objects
         * 
         ***************************************************************************/

        public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                  , DetailsLog log
                                                  , UserInfo uInfo
                                                  , bool pageObjectList
                                                  , string pageOrder
                                                  , string idx
                                                  , string active
                                                  , string clientID
                                                  , string lName
                                                  , string fName)

        {
            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = Patient.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                         , log
                                         , uInfo
                                         , typeof(Patient)
                                         , pageObjectList
                                         , pageOrder
                                         , delegate
                                         {
                                             return Patients.view ( connSpedmon
                                                                   , log
                                                                   , uInfo
                                                                   , Entities.REC_VIEW_OBJECTS
                                                                   , pageObjectList
                                                                   , idx
                                                                   , "" /* Can edit */
                                                                   , active
                                                                   , "0" /* Data source for all patients is 0 */
                                                                   , clientID
                                                                   , "" /* pracID */
                                                                   , lName
                                                                   , fName
                                                                   , "" /* DOB */
                                                                   , "" /* DOS */
                                                                   , "" /* siteID */
                                                                   , ""  /* studentID */
                                                                   , dc);
                                         });


        }

        /***************************************************************************
         * viewSel */
        /**
         * Returns a list of patients
         * 
         ***************************************************************************/

        public static ReturnSel viewSel (  SqlConnection connSpedmon
                                          , DetailsLog   log
                                          , UserInfo     uInfo
                                          , bool         top
                                          , string       topSize
                                          , string       source
                                          , string       clientID
                                          , string       pracID
                                          , string       term
                                          , string       dos
                                          , string       siteID )
        {

            /*----------------------------
             * Parse search term
             *----------------------------*/

            string vTerm = Validate.optString(term);
            
            string studentID = "";
            string lname     = "";
            string fname     = "";
            string dob       = "";
                     
            Parse.searchTermToIDOrLastFirstDate ( vTerm
                                                 , out studentID
                                                 , out lname
                                                 , out fname
                                                 , out dob);

            /*----------------------------
             * Define our context column
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {

                ss.addDisplayColumn("[email] as recData11");    /* Patient email */
                ss.addDisplayColumn("[phone] as recData12");    /* Patient phone */

                // Internal staff and clients see different context values 

                if (uInfo.userGroup == Constants.USER_GROUP_SBSC)
                {                    
                    ss.addDisplayColumn("dbo.BIT_TO_MSG(submitClaims,'','** DO NOT BILL ** | ') + elgEst + ' | ' + iep + ' | ' + dob_str   + ' | ' + convert(varchar(21),id) + ' | ' + siteName + ' | ' + siteRank + ' | ' + siteRefID + ' | ' + gender + ' | ' + CSIS + ' | ' + bic + ' | ' + ssn as [context1]");                
                }
                else
                {                    
                    ss.addDisplayColumn("dob_str + ' | ' + siteName + ' | ' + siteRank + ' | ' + siteRefID + ' | ' + CSIS  + ' | ' + teacherOrCounselorOrCaseManagerName as [context1]" );
                }
            };

            /* filter on active depending on datasource */
            string active = "1";
            if (source == ((int)PatientDataSource.INACTIVE_PATIENTS).ToString())
                active = "0";


            /*----------------------------
              * Call base method which
              * handles the rest and return
              * results
              *----------------------------*/

            return Entities.viewSel(connSpedmon, log, uInfo, top, topSize,
            delegate { return Patients.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, "", active, source, clientID, pracID, lname, fname, dob, dos, siteID, studentID,dc); });

        }


        /***************************************************************************
         * viewSelForTransMgmt */
        /**
         * Returns a list of patients
         * 
         ***************************************************************************/

        public static ReturnSel viewSelForTransMgmt(SqlConnection connSpedmon,
                                                      DetailsLog log,
                                                      UserInfo uInfo,
                                                      bool top,
                                                      string topSize,
                                                      string clientID,
                                                      string term)
        {


            string patDataSource = "0"; /* Changed from 5 to 0 since we no longer have SpEd only patients limit on transportation module f*/

            return Patients.viewSel(connSpedmon
                                     , log
                                     , uInfo
                                     , top
                                     , topSize
                                     , patDataSource
                                     , clientID
                                     , ""
                                     , term
                                     , ""
                                     , "");
        }

        /***************************************************************************
         * viewTbl */
        /**
         * Returns a data table of records for preview or record selection.
         * 
         * @return                 ReturnDataTable
         ***************************************************************************/

        /* TODO: 1 reference.  Used only to populate the merge screen.
         *       IDK why this is named as something "common" if it is only used one place
         */
        public static defineCols addCommonViewTblDisplayCols(UserInfo uInfo)
        {
            return delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("id");
                ss.addDisplayColumnIfParmValueIsNull("clientName as [Client Name]", "@clientID", true, ref parms);

                ss.addDisplayColumn("activeYN                              as [Is\nActive]");
                ss.addDisplayColumn("name                                  as [Patients\nLast, First]", true);
                ss.addDisplayColumn("dob                                   as [Date of Birth]");
                ss.addDisplayColumn("gender                                as [Gender]");

                /* Include additional identifying colums for our staff */

                if (uInfo.userGroup == Constants.USER_GROUP_SBSC)
                {
                    ss.addDisplayColumn("bic as [BIC]");
                    ss.addDisplayColumn("CSIS as [CSIS]");
                }

                ss.addDisplayColumn("siteName                              as [Site]");
                ss.addDisplayColumn("siteRank                              as [Grade]");

                if (uInfo.userGroup == Constants.USER_GROUP_SBSC)
                {
                    ss.addDisplayColumn("siteRefID as [Student ID]");
                }

                ss.addDisplayColumn("submitClaimsYN                        as [Submit\nClaims]");
                ss.addDisplayColumn("submitClaimsEffectiveDate             as [Submit\nClaims\nEffective\nDate]");
                ss.addDisplayColumn("medicalParentConsentYN                as [Medi-Cal\nParental Consent]");
                ss.addDisplayColumn("parentConsentMCALEffectiveDate        as [Medi-Cal\nParental Consent\nEffective Date]");
                ss.addDisplayColumn("parentConsentOHCIYN                   as [Other Health Insurance\nParental Consent]");
                ss.addDisplayColumn("parentConsentOHCIEffectiveDate        as [Other Health Insurance\nParental Consent\nEffective Date]");
                ss.addDisplayColumn("clientID");
                ss.addDisplayColumn("id                                    as [patientID]");

                ss.addPageOrderColumn("[Patients\nLast, First]");

                pageroworder = ss.pageRowOrder();
            };
        }

        /***************************************************************************
         * rptPossiblePatMergesNeeded */
        /**
         * Returns a data table of records for preview or record selection.
         * 
         * @return                 ReturnDataTable
         ***************************************************************************/

        public static ReturnDataTable rptPossiblePatMergesNeeded(SqlConnection connSpedmon,
                                                                            DetailsLog log,
                                                                            UserInfo uInfo,
                                                                            bool paged,
                                                                            string pageNumber,
                                                                            string clientID)
        {

            string viewTitle = "Possible Patient Merges Needed";
            string viewUDF = "dbo.RPT_POSSIBLE_PAT_MERGES_NEEDED(@clientID)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            Object vClientID = Validate.optClientID(uInfo, clientID);

            /*----------------------------
             * Populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> prms = new List<SqlParameter>();

            prms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

            /*----------------------------
             * Define our columns and
             * set the page order for 
             * paging
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addPageOrderColumn("[LAST_NAME] asc");
                pageroworder = ss.pageRowOrder();
            };

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.viewRpt(connSpedmon,
                                    log,
                                    uInfo,
                                    paged,
                                    pageNumber,
                                    "",
                                    viewUDF,
                                    prms,
                                    null,
                                    dc,
                                    viewTitle,
                                    Messages.CONFIDENTIAL);

        }

        /***************************************************************************
         * rptPossiblePatMergesNeeded */
        /**
         * Returns a data table of records for preview or record selection.
         * 
         * @return                 ReturnDataTable
         ***************************************************************************/

        public static ReturnDataTable rptFindRedundantPatientRecords(SqlConnection connSpedmon
                                                                       , DetailsLog log
                                                                       , UserInfo uInfo
                                                                       , bool paged
                                                                       , string pageNumber
                                                                       , string clientID)
        {

            string viewTitle = "Possible Redundant Patient Records";
            string viewUDF = "dbo.RPT_PATIENT_FIND_REDUNDANT_RECORDS(@clientID)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            Object vClientID = Validate.optClientID(uInfo, clientID);

            /*----------------------------
             * Populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> prms = new List<SqlParameter>();

            prms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

            /*----------------------------
             * Define our columns and
             * set the page order for 
             * paging
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addPageOrderColumn("[Client] asc");
                ss.addPageOrderColumn("[Record Set] asc");
                pageroworder = ss.pageRowOrder();
            };

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.viewRpt(connSpedmon,
                                    log,
                                    uInfo,
                                    paged,
                                    pageNumber,
                                    "",
                                    viewUDF,
                                    prms,
                                    null,
                                    dc,
                                    viewTitle,
                                    Messages.CONFIDENTIAL);

        }

        /***************************************************************************
         * viewTbl */
        /**
         * Returns a data table of records for preview or record selection.
         * 
         * @return                 ReturnDataTable
         ***************************************************************************/

        public static ReturnDataTable viewTbl(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                               bool paged,
                                               string pageNumber,
                                               string source,
                                               string clientID,
                                               string lname,
                                               string fname,
                                               string dob,
                                               string dos,
                                               string canEdit,
                                               string active)
        {

            /*----------------------------
             * Get clientID of 
             * user if user is a client 
             * We need this for the 
             * dataview title
             *----------------------------*/

            Object vClientID = Validate.optClientID(uInfo, clientID);
            if (vClientID != null) clientID = vClientID.ToString();

            /*----------------------------
             * Define our columns and
             * set the page order for 
             * paging
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("id");
                ss.addDisplayColumnIfParmValueIsNull("clientName as [Client Name]", "@clientID", true, ref parms);

                ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(active)             as [Is\nActive]");
                ss.addDisplayColumn("name                                  as [Patients\nLast, First]", true);
                ss.addDisplayColumn("dob                                   as [Date of Birth]");
                ss.addDisplayColumn("gender                                as [Gender]");

                ss.addDisplayColumn("CSIS as [SSID]");

                /* Include additional identifying colums for our staff */

                if (uInfo.userGroup == Constants.USER_GROUP_SBSC)
                {
                    ss.addDisplayColumn("bic as [BIC]");
                    
                }

                ss.addDisplayColumn("siteName                              as [Site]");
                ss.addDisplayColumn("siteRank                              as [Grade]");
                ss.addDisplayColumn("siteRefID as [Student ID]");
                
                ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(submitClaims)       as [Submit\nClaims]");
                ss.addDisplayColumn("submitClaimsEffectiveDate             as [Submit\nClaims\nEffective\nDate]");
                ss.addDisplayColumn("dbo.RPT_PATIENT_MCAL_PARENTAL_CONSENT_STATUS (clientBillMCALImpliedParentConsent, parentConsentMCAL, createdByPCAL) as [Medi-Cal\nParental Consent]");
                ss.addDisplayColumn("parentConsentMCALEffectiveDate        as [Medi-Cal\nParental Consent\nEffective Date]");
                ss.addDisplayColumn("dbo.RPT_BIT_TO_YNU(parentConsentOHCI) as [Other Health Insurance\nParental Consent]");
                ss.addDisplayColumn("parentConsentOHCIEffectiveDate        as [Other Health Insurance\nParental Consent\nEffective Date]");
                ss.addDisplayColumn("altFormat                             as [Alternative Formats]");

                if (uInfo.userGroup == Constants.USER_GROUP_SBSC)
                {
                    ss.addDisplayColumn("ffpQualifiedStr  as [FFP\nQualified]");
                    ss.addDisplayColumn("clientID");
                    ss.addDisplayColumn("id as [patientID]");
                }

                ss.addPageOrderColumn("[Patients\nLast, First]");

                pageroworder = ss.pageRowOrder();

            };  //TODO: consider using defineCols dc = Patients.addCommonViewTblDisplayCols(uInfo); for a significantly shorter implementation of the viewTbl() method


            string tableName = @"Patients - View";
            string tableFooter = Messages.CONFIDENTIAL;

            if (!Util.IsNullOrEmpty(clientID))
            {
                Client c = Clients.load(connSpedmon, log, uInfo, clientID);
                tableName = tableName + " - " + c.name;
            }

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
              delegate ()
              {
                  return Patients.view(connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, canEdit, active, source, clientID, "", lname, fname, dob, dos, "", "", dc);
              } //TODO: instead of putting a delegate here, consider assigning it to a variable.  viewCall vc = delegate () {...} for readability
              , tableName
              , tableFooter
              );
        }



        /***************************************************************************
         * viewMergeTbl */
        /**
         * Returns a preview data table of records for merge selection.
         * 
         * @return                 ReturnDataTable
         ***************************************************************************/
        public static ReturnDataTable viewMergeTbl(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                                    bool paged,
                                                    string pageNumber,
                                                    string source,
                                                    string clientID,
                                                    string lname,
                                                    string fname,
                                                    string dob,
                                                    string dos,
                                                    string canEdit,
                                                    string active,
                                                    string findCSIS)
        {
            try { Validate.optFlag(active, Messages.INVALID_BOOL); } catch { active = ""; } //silently ignore invalid values; "Unknown" active criterion will fail otherwise.  See comment added in MBA repo
            bool include_unknown_CSIS = !String.IsNullOrEmpty(dob) || !String.IsNullOrEmpty(lname) || !String.IsNullOrEmpty(fname);
            defineCols dc = Patients.addCommonViewTblDisplayCols(uInfo);
            viewCall vc = delegate ()
            {
                return Patients.mergeView(connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, canEdit, active, source, clientID, "" /* pracID */, lname, fname, dob, dos, findCSIS, include_unknown_CSIS, dc);
            };
            return Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber, vc, "", "");
        }
        
        /***************************************************************************
         * getCybhiTpaLayout */
        /**
         * Returns a list of fixed width field definitions that match fileClass
         ***************************************************************************/    
        public static List<FixedWidthFieldDefinition> getCybhiTpaLayout ( 
              SqlConnection connSpedmon
            , DetailsLog    log
            , UserInfo      uInfo            
            , int           fileClass )
        {
            List<FixedWidthFieldDefinition> so = new List<FixedWidthFieldDefinition>();
            var parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@fileClass", SqlDbType.TinyInt, fileClass, ParameterDirection.Input));
            var sql = "select * from dbo.CYBHI_TPA_CARELON_GET_PAT_REG_FILE_LAYOUT (@fileClass)";
            var rd = Database.execQuery(connSpedmon,log, sql, false, parms);
            var slo = Database.convertRecordsToList (ref rd.records, typeof(FixedWidthFieldDefinition));
            foreach (Object o in slo) {so.Add ((FixedWidthFieldDefinition) o);}
            return so;
       }

       /***************************************************************************
        * rptCybhiPatsExport */
       /**
        * Returns a list of CYBHI patients for submission to the third party admin 
        * (TPA).  The list is limited to patient rows that are OK for export.
        * OK for export = all criticial and required fields as defined by the TPA
        * are filled out.
        * 
        * 
        * @return ReturnDataTable
        ***************************************************************************/

        public static ReturnDataTable rptCybhiPatsExport (  SqlConnection connSpedmon
                                                          , DetailsLog    log
                                                          , UserInfo      uInfo
                                                          , bool          paged
                                                          , string        pageNumber
                                                          , string        clientID )
        {
            ReturnDataTable so = new ReturnDataTable();

            var vClientID = Validate.reqClientID(uInfo, clientID);
            var clc       = Clients.load(connSpedmon, log, uInfo, clientID);
            var parms     = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

            string udf = @"dbo.CYBHI_PAT_LIST_EXPORT_RPT(@clientID)";

            string viewTitle = clc.cybhiClientCode
                             + "toCarelon_Patient_"
                             + DateTime.Today.ToYYYYMMDDString();

            so = viewRpt(connSpedmon, log, uInfo, paged, pageNumber, "Y", udf, parms, null, null, viewTitle, Messages.DATA_VIEW_NO_FOOTER);

            return so;
        }
       
       /***************************************************************************
        * rptCybhiPatsExportFixed */
       /**
        * Returns a list of CYBHI patients for submission to the third party admin 
        * (TPA).  The list is limited to patient rows that are OK for export.
        * OK for export = all criticial and required fields as defined by the TPA
        * are filled out.
        * 
        * 
        * @return ReturnDataTable
        ***************************************************************************/

        public static ReturnDataTable rptCybhiPatsExportFixed (  SqlConnection connSpedmon
                                                                , DetailsLog    log
                                                                , UserInfo      uInfo
                                                                , bool          paged
                                                                , string        pageNumber
                                                                , string        clientID )
        {
            ReturnDataTable so = new ReturnDataTable();

            var vClientID = Validate.reqClientID(uInfo, clientID);          
            var clc       = Clients.load(connSpedmon, log, uInfo, clientID);
            var parms     = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

            string udf = @"dbo.CYBHI_PAT_LIST_EXPORT_RPT(@clientID)";

            string viewTitle = clc.cybhiClientCode
                             + "toCarelon_Patient_"
                             + DateTime.Today.ToYYYYMMDDString();

            so = viewRpt(connSpedmon, log, uInfo, paged, pageNumber, "Y", udf, parms, null, null, viewTitle, Messages.DATA_VIEW_NO_FOOTER);
            so.fixedWidthFieldDefinitions = getCybhiTpaLayout(connSpedmon,log,uInfo,0);
            //so.iTotalRecords.ToString();
            so.tableFooter = "TRAILER" + so.aaData.Length.ToString().PadLeft(7, '0');

            return so;
        }
       

        /***************************************************************************
          * rptCybhiPatsAudit */
        /**
         * Returns a list of CYBHI patients for submission to the third party admin
         * (TPA) but only returns the columns that the LEA is required to complete
         * and returns additional information on required or critical data that is 
         * missing.  This list is for internal use only and NOT to be submitted to
         * the TPA.  This list should be used to troubleshoot why patient rows are not
         * being included in the official export.
         *
         * @return ReturnDataTable
         ***************************************************************************/    

        public static ReturnDataTable rptCybhiPatsAudit(SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo uInfo
                                                , bool paged
                                                , string pageNumber
                                                , string clientID)
        {
            ReturnDataTable so = new ReturnDataTable();

            var vClientID = Validate.reqClientID(uInfo, clientID);
            var clc = Clients.load(connSpedmon, log, uInfo, clientID);
            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

            string udf = @"dbo.CYBHI_PAT_LIST_AUDIT_RPT(@clientID)";

            string viewTitle = clc.name
                             + " CYBHI Patients Audit "
                             + DateTime.Today.ToYYYYMMDDString();

            so = viewRpt(connSpedmon, log, uInfo, paged, pageNumber, "Y", udf, parms, null, null, viewTitle, Messages.DATA_VIEW_NO_FOOTER);

            return so;
        }

        /***************************************************************************
         * cybhiPatsProcessFile */
        /**
         * Processes file
         *
         * @return                     ReturnSaveNewRecordWithJSONData
         ***************************************************************************/

        public static ReturnSaveRecordWithJSONData cybhiPatsProcessFile(
             SqlConnection connSpedmon
           , DetailsLog log
           , UserInfo uInfo
           , string clientID
           , string fileClass
           , string fromExternalSource
           , string fileContents
           , string validateRec)
        {

            /*----------------------------
             * Validate parameters specific
             * to this entity.save
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/


            int vClientID = Validate.reqClientID(uInfo, clientID);
            int vFileClass = Validate.reqInteger(fileClass, "Invalid file class", true);
            bool vfromExternalSource = Validate.reqFlag(fromExternalSource, "Invalid external source");
            string vFileContents = Validate.reqString(fileContents, "Invalid file contents");

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fileClass", SqlDbType.TinyInt, vFileClass, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fromExternalSource", SqlDbType.Bit, vfromExternalSource, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fileContents", SqlDbType.VarChar, vFileContents, ParameterDirection.Input, -1));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            var so = Entities.saveAndReturnJSONData(connSpedmon
               , log
               , uInfo
               , "1" /*saveType*/
               , validateRec
               , "" /*editDelReason*/
               , "" /* recID*/
               , "CYBHI_TPA_RETURN_FILE_PROCESS_PAT_REG"
               , "Duplicate file"
               , ref parms
               , null);

            return so;

        }

        public static ReturnSaveRecordWithJSONData invitePatientToPortal(SqlConnection connSpedmon
                                                                                , DetailsLog log
                                                                                , UserInfo uInfo
                                                                                , string clientID
                                                                                , string editDelReason
                                                                                , string validateRec
                                                                                , string saveType
                                                                                , string recID)
        {
            string saveSproc = @"PATIENT_PORTAL_INVITE_SAVE";

            long vClientID      = Validate.reqClientID  (uInfo, clientID);
            bool vValidateRec   = Validate.reqFlag      (validateRec,   Messages.INVALID_VALIDATE_FLAG);
            int vSaveType       = Validate.reqInteger   (saveType,      Messages.INVALID_SAVE_TYPE);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID",     SqlDbType.BigInt,   vClientID,              ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pwdMinLen",    SqlDbType.Int,      Rules.PWD_MIN_LENGTH,   ParameterDirection.Input));

            var so = Entities.saveAndReturnJSONData(connSpedmon
                                                        , log
                                                        , uInfo
                                                        , saveType
                                                        , validateRec
                                                        , editDelReason
                                                        , recID
                                                        , saveSproc
                                                        , @"Active invite already exists"
                                                        , ref parms
                                                        , null);

            return PatientPortalCommon.ExtractAndProcessReturnData(ref so, vValidateRec);
        }
    }
}

