using System;
using System.Data;
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
    /***************************************************************************
     * PatientSave */
    /**
     * Saves a patient
     ***************************************************************************/

    public class UserAllPatientSave : WebUI
    {
        public int saveType = 0;
        public string patientSaveURL;
        public string restViewURL = "";
        public string urlViewAllPatientGoalsProgress = "";
        public string clientID  = "";
        public string patID     = "";
        public string pracID    = "";
        public string groupID   = "";
        public string tabToOpen = "";
        public bool isPCalStaff = false;
        public string isPcalStaffJSBoolStr = "";

        public bool canUsePreCareNotes                  = false;
        public bool canAdministerOrdersOrPx             = false;
        public bool canRecordScheduledServices          = false;
        public bool canViewVisitHistory                 = false;
        public bool canStartNewVisit                    = false;
        public bool canAdministerVitalSigns             = false;
        public bool canReferPatient                     = false;
        public string attendanceSelectionsJSON          = @"[]";
        public string serviceNamesListPlanTypesJSON     = @"[]";
        public string urlPracPatReferal                 = @"";

        public string urlManageOrderAndPx               = @"";
        public string urlViewPatientGoalsProgress       = @"";

        public List<TransportationMgmtAuthorizedRouteMember> transportationRecs = new List<TransportationMgmtAuthorizedRouteMember>();
        //public List<ServiceJournalsPrescribedOrder> serviceRecs = new List<ServiceJournalsPrescribedOrder>();
        //public List<StoredFile> fileRecs = new List<StoredFile>();
        public string showContentOnly;
        public string speciallyAdaptedVehicleForTransportationVal = "null";
        public string pracGrpSvcClassNameID         = "";
        
        public string spedDisability1Text           = @"";
        public string spedDisability2Text           = @"";
        public bool hasSpEdServiceData              = false;
        
        public UserAllPatientSave() : base("patient_save"
                                          , Patients.SEL_LABEL_SAVE
                                          , "user_all_pat_save.css|user_all_patient_goal_progress_reporting.css|pre-care-notes.css|pat_direct_service.css"
                                          , "scheduled-services-provided-by-prac-for-pat-on-dos.js|patient-allergies.js|patient-known-health-problems.js|patient-diagnoses.js|user_all_pat_save.js|patient-care-notes.js|practice-office-visits.js|orders-or-prescriptions-provide-hs-for-pat-on-dos.js|service-journal-recent-procedure-entries.js|patient-vital-signs.js|patient-vital-signs-measurement.js|care-plans.js|rec_pat_transportations.js|user_all_patient_goal_progress_reporting.js|tele-iep-sessions.js|patient-goals.js|patient-insurance.js|orders-or-prescriptions.js|patient-persons.js|patient-promised-services.js|practitioner-patient-scheduled-services-manage.js|patient-service-records.js|stored-files.js|form-builder-patient-goal.js"
                                          , Constants.ROLE_ALL_PCAL_AND_CLIENT)
        { }
        protected void Page_Load(object sender, EventArgs e)
        {
        
           /*-------------------------------
             * Determine what save type
             * this is 
             *------------------------------*/

            string recid = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
            string savetype = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);
            Object vSaveType = MBA.Validate.optInteger(savetype, Messages.INVALID_SAVE_TYPE);
            clientID = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
            
            if (vSaveType == null) vSaveType = Constants.SAVE_TYPE_NEW;
            saveType = (int)vSaveType;

            /***************************************************************************
             * Get info about user
             ***************************************************************************/

            isPCalStaff = uInfo.pcalStaff;
            isPcalStaffJSBoolStr = Util.netBoolToJSBool(isPCalStaff);
            
            /***************************************************************************
             * Determine if we can show the referr patient button
             ***************************************************************************/

            canReferPatient = false;
            canReferPatient = PractitionerPatientReferrals.userCanAccessSaveScreen(rd,saveType);

            /*-------------------------------
             * Locate data controls
             *------------------------------*/

            DataEntryRowSaveOrEdit ctrlSaveOrEdit = findControlRecu(this.Page, "saveOrEdit") as DataEntryRowSaveOrEdit;
            var ctrlpatid = findControlRecu(this.Page, Constants.PARM_PATIENT_ID) as MBA.HiddenInput;
            var ctrlDOS   = findControlRecu(this.Page, Constants.PARM_DOS)        as MBA.HiddenInput;
            var ctrlrecTransportationJSON = findControlRecu(this.Page, "recTransportationJSON") as MBA.HiddenTextArea;
            //var                    ctrlrecServiceJSON                   = findControlRecu(this.Page, "recServiceJSON")     as MBA.HiddenTextArea;
            //var                    ctrlrecFileJSON                      = findControlRecu(this.Page, "recFileJSON")        as MBA.HiddenTextArea;
            WebUIControlDataField ctrlLname = findControlRecu(this.Page, "lname") as WebUIControlDataField;
            WebUIControlDataField ctrlFname = findControlRecu(this.Page, "fname") as WebUIControlDataField;
            WebUIControlDataField ctrlMname = findControlRecu(this.Page, "mname") as WebUIControlDataField;


            WebUIControlDataField ctrlNickname = findControlRecu(this.Page, "p_nickname") as WebUIControlDataField;

            WebUIControlDataField ctrlTeacherName = findControlRecu(this.Page, "teacher_name") as WebUIControlDataField;


            DataEntryRowSelectClient ctrlSelectClient = findControlRecu(this.Page, "selectClient") as DataEntryRowSelectClient;

            ComboBox ctrlSiteID = findControlRecu(this.Page, "siteid") as ComboBox;
            WebUIControlDataField ctrlStudentID = findControlRecu(this.Page, "studentid") as WebUIControlDataField;
            WebUIControlDataField ctrlGrade = findControlRecu(this.Page, "grade") as WebUIControlDataField;
            WebUIControlDataField ctrlDOB = findControlRecu(this.Page, "dob") as WebUIControlDataField;
            SelectMaleOrFemale ctrlSex = findControlRecu(this.Page, "sex") as SelectMaleOrFemale;
            WebUIControlData ctrlparentConsentMCAL = findControlRecu(this.Page, "parentConsentMCAL") as WebUIControlData;
            WebUIControlDataField ctrlparentConsentMCALEffectiveDate = findControlRecu(this.Page, "parentConsentMCALEffectiveDate") as WebUIControlDataField;

            SelectYesOrNoOrUnknown ctrlFerpaConsent = findControlRecu(this.Page, "ferpaconsent") as SelectYesOrNoOrUnknown;
            DataEntryBoxDate ctrlFerpaConsentEffectiveDate = findControlRecu(this.Page, "ferpaconsenteffectivedate") as DataEntryBoxDate;
            SelectYesOrNoOrUnknown ctrlTreatmentConsent = findControlRecu(this.Page, "treatmentconsent") as SelectYesOrNoOrUnknown;
            DataEntryBoxDate ctrlTreatmentConsentEffectiveDate = findControlRecu(this.Page, "treatmentconsenteffectivedate") as DataEntryBoxDate;

            var ctrlCybhiTpaApprovedRow   = findControlRecu(this.Page, "cybhiTpaApprovedRow")     as DataEntryRow;
            var ctrlCybhiTpaApprovedOnRow = findControlRecu(this.Page, "cybhiTpaApprovedOnRow")   as DataEntryRow;
            var ctrlCybhiTpaIDRow         = findControlRecu(this.Page, "cybhiTpaIDRow")           as DataEntryRow;
            var ctrlCybhiTpaSubmitClaims  = findControlRecu(this.Page, "cybhiTpaSubmitClaimsRow") as DataEntryRow;

            SelectYesOrNo ctrlCybhiTpaApproved = findControlRecu(this.Page, "cybhitpaapproved") as SelectYesOrNo;
            DataEntryBoxDate ctrlCybhiTpaApprovedOn = findControlRecu(this.Page, "cybhitpaapprovedon") as DataEntryBoxDate;
            DataEntryBoxText ctrlCybhiTpaID = findControlRecu(this.Page, "cybhitpaid") as DataEntryBoxText;
            SelectYesOrNo ctrlCybhiSubmitClaims = findControlRecu(this.Page, "cybhisubmitclaims") as SelectYesOrNo;

            WebUIControlDataField ctrlCSIS = findControlRecu(this.Page, "csis") as WebUIControlDataField;
            SelectYesOrNo ctrlHasplan = findControlRecu(this.Page, "hasplan") as SelectYesOrNo;
            WebUIControlData ctrlSSN = findControlRecu(this.Page, "ssn") as WebUIControlData;
            WebUIControlData ctrlBIC = findControlRecu(this.Page, "bic") as WebUIControlData;
            WebUIControlData ctrlSubmitClaims = findControlRecu(this.Page, "submitclaims") as WebUIControlData;
            WebUIControlDataField ctrlSubmitClaimsEffectiveDate = findControlRecu(this.Page, "submitClaimsEffectiveDate") as WebUIControlDataField;
            MBA.TextAreaBox ctrlNotes = findControlRecu(this.Page, "notes") as MBA.TextAreaBox;

            ctrlNotes.cssClass += " w-100";

            WebUIControlDataField ctrlSpeciallyAdaptedVehicleForTransportation = findControlRecu(this.Page, "speciallyAdaptedVehicleForTransportation") as WebUIControlDataField;

            SelectYesOrNo ctrlSpedspecialtransportation = findControlRecu(this.Page, "spedspecialtransportation") as SelectYesOrNo;

            var ctrlInTransitionalHousingStatus = findControlRecu(this.Page, "inTransitionalHousingStatus") as MBA.SelectYesOrNo;

            var ctrlSpedlastevaldate = findControlRecu(this.Page, "spedlastevaldate") as DataEntryBoxDate;
            var ctrlSpedlastannualiepdate = findControlRecu(this.Page, "spedlastannualiepdate") as DataEntryBoxDate;
            var ctrlSpednextannualiepdate = findControlRecu(this.Page, "spednextannualiepdate") as DataEntryBoxDate;
            var ctrlSpedcuriepdate = findControlRecu(this.Page, "spedcuriepdate") as DataEntryBoxDate;
            var ctrlSelectDisability1Code = findControlRecu(this.Page, "SelectDisability1Code") as DataEntryRowSelectSpEdDisabilityCode;
            var ctrlSelectDisability2Code = findControlRecu(this.Page, "SelectDisability2Code") as DataEntryRowSelectSpEdDisabilityCode;
            DataEntryBoxText ctrlSpedCaseManagerName = findControlRecu(this.Page, "spedcasemanagername") as DataEntryBoxText;
            DataEntryBoxDate ctrlSpedExitedSpEdDate = findControlRecu(this.Page, "spedexitedspeddate") as DataEntryBoxDate;
            var ctrlSpedstudentstrengths = findControlRecu(this.Page, "spedstudentstrengths") as RichTextAreaBox;
            var ctrlSpedparentconcerns = findControlRecu(this.Page, "spedparentconcerns") as RichTextAreaBox;
            var ctrlSpedprogressmonitoringdata = findControlRecu(this.Page, "spedprogressmonitoringdata") as RichTextAreaBox;
            var ctrlSpedstudentpresentlevelsstatement = findControlRecu(this.Page, "spedstudentpresentlevelsstatement") as RichTextAreaBox;
            var ctrlSpedstudentdisabilityaffectsperformance = findControlRecu(this.Page, "spedstudentdisabilityaffectsperformance") as SelectYesOrNo;
            var ctrlSpedcureligibilitydate = findControlRecu(this.Page, "spedcureligibilitydate") as DataEntryBoxDate;
            var ctrlSpediniteligibilitydate = findControlRecu(this.Page, "spediniteligibilitydate") as DataEntryBoxDate;
            var ctrlSpediepattendeesidentified = findControlRecu(this.Page, "spediepattendeesidentified") as SelectYesOrNo;
            var ctrlSpedeligibilityreasons = findControlRecu(this.Page, "spedeligibilityreasons") as RichTextAreaBox;
            var ctrlSelectSpEdLangaugeToTranslatePlanTo = findControlRecu(this.Page, "selectSpEdLangaugeToTranslatePlanTo") as DataEntryRowSelectSpEdLanguage;
            var ctrlSpedmeetingpurposedatajson = findControlRecu(this.Page, "spedmeetingpurposedatajson") as HiddenTextArea;
            var ctrlSpedadditionalmeetingpurposedatajson = findControlRecu(this.Page, "spedadditionalmeetingpurposedatajson") as HiddenTextArea;
            var ctrlSpedamendmentreasonsdatajson = findControlRecu(this.Page, "spedamendmentreasonsdatajson") as HiddenTextArea;
            var ctrlSpedinitrefdate = findControlRecu(this.Page, "spedinitrefdate") as DataEntryBoxDate;
            var ctrlSpeddistrictreceivedparentconsentdate = findControlRecu(this.Page, "speddistrictreceivedparentconsentdate") as DataEntryBoxDate;
            var ctrlDataEntryRowSelectSpEdReferringParty = findControlRecu(this.Page, "DataEntryRowSelectSpEdReferringParty") as DataEntryRowSelectSpEdReferringParty;
            var ctrlDataEntryRowSelectSpEdPlanType = findControlRecu(this.Page, "DataEntryRowSelectSpEdPlanType") as DataEntryRowSelectSpEdPlanType;
            var ctrlSpEdReferringPartyOtherOption = findControlRecu(this.Page, "spedreferringpartyotheroption") as DataEntryBoxText;
            var ctrlSelectStudentSpEdLangauge = findControlRecu(this.Page, "dataEntryRowSelectStudentLanguageCode") as DataEntryRowSelectSpEdLanguage;
            var ctrlSelectStudentSpEdRace = findControlRecu(this.Page, "spedstudentracecode") as MBA.ComboBox;
            var ctrlSpEdNextEvalDate = findControlRecu(this.Page, "spednextevaldate") as MBA.DataEntryBoxDate;
            var ctrlSpEdEnteredSpEdDate = findControlRecu(this.Page, "spedenteredspeddate") as MBA.DataEntryBoxDate;
            var ctrlSpEdStudentLanguageEnglishLearner = findControlRecu(this.Page, "spedstudentlanguageenglishlearner") as MBA.SelectYesOrNo;
            var ctrlSpEdStudentLanguageInfoReclassified = findControlRecu(this.Page, "spedstudentlanguageinforeclassified") as MBA.CheckBox;
            var ctrlSpEdStudentLanguageInterpreterNeeded = findControlRecu(this.Page, "spedstudentlanguageinterpreterneeded") as MBA.SelectYesOrNo;
            var ctrlSpEdStudentLanguageTranslationRequested = findControlRecu(this.Page, "spedstudentlanguagetranslationrequested") as MBA.SelectYesOrNo;
            var ctrlSpedservicesdatajson = findControlRecu(this.Page, "spedservicesdatajson") as HiddenTextArea;

            var ctrlSpEdStudentLanguageEnglishLearnerUndesignatedPreschool = findControlRecu(this.Page, "spedstudentlanguageenglishlearnerundesignatedpreschool") as MBA.SelectYesOrNo;

            var ctrlSpEdTransitionGoalEducation = findControlRecu(this.Page, "spedtransitiongoaleducation") as MBA.CheckBox;
            var ctrlSpEdTransitionGoalTraining = findControlRecu(this.Page, "spedtransitiongoaltraining") as MBA.CheckBox;
            var ctrlSpEdTransitionGoalEmployment = findControlRecu(this.Page, "spedtransitiongoalemployment") as MBA.CheckBox;
            var ctrlSpEdTransitionGoalIndependentLiving = findControlRecu(this.Page, "spedtransitiongoalindependentliving") as MBA.CheckBox;


            var ctrlSpEdDevAcaFunSkillsReading = findControlRecu(this.Page, "speddevacafunskillsreading") as RichTextAreaBox;
            var ctrlSpEdDevAcaFunSkillsWriting = findControlRecu(this.Page, "speddevacafunskillswriting") as RichTextAreaBox;
            var ctrlSpEdDevAcaFunSkillsMath = findControlRecu(this.Page, "speddevacafunskillsmath") as RichTextAreaBox;
            var ctrlSpEdDevAcaFunSkillsCommunicationDev = findControlRecu(this.Page, "speddevacafunskillscommunicationdev") as RichTextAreaBox;
            var ctrlSpEdDevAcaFunSkillsGrossFineMotorDev = findControlRecu(this.Page, "speddevacafunskillsgrossfinemotordev") as RichTextAreaBox;
            var ctrlSpEdDevAcaFunSkillsHealth = findControlRecu(this.Page, "speddevacafunskillshealth") as RichTextAreaBox;
            var ctrlSpEdDevAcaFunSkillsVocational = findControlRecu(this.Page, "speddevacafunskillsvocational") as RichTextAreaBox;
            var ctrlSpEdDevAcaFunSkillsAdaptiveDailyLiving = findControlRecu(this.Page, "speddevacafunskillsadaptivedailyliving") as RichTextAreaBox;
            var ctrlSpEdDevAcaFunSkillsAreasOfNeccessity = findControlRecu(this.Page, "speddevacafunskillsareasofneccessity") as RichTextAreaBox;


            /*-------------------------------
             * Grab client specific fields
             *------------------------------*/

            DataEntryRow ctrlSubmitclaimsDataEntryRow = findControlRecu(this.Page, "submitclaimsDataEntryRow") as DataEntryRow;
            DataEntryRow ctrlBicDataEntryRow = findControlRecu(this.Page, "bicDataEntryRow") as DataEntryRow;
            DataEntryRow ctrlNotesDataEntryRow = findControlRecu(this.Page, "notesDataEntryRow") as DataEntryRow;

            pracGrpSvcClassNameID = uInfo.userPracStdSvcClassNameID.ToString();
            var ctrlPracGroupSvcClassNameID = findControlRecu(this.Page, "groupserviceclassnameid") as MBA.HiddenInput;
            ctrlPracGroupSvcClassNameID.value = string.IsNullOrEmpty(pracGrpSvcClassNameID) || pracGrpSvcClassNameID == "0" ? "" : pracGrpSvcClassNameID;
            
            pracID = uInfo.userPracIDStr;
            var ctrlPracID = findControlRecu(this.Page, Constants.PARM_PRACTITIONER_ID) as MBA.HiddenInput;
            ctrlPracID.value = string.IsNullOrEmpty(pracID) || pracID == "0" ? "" : pracID;

            groupID = uInfo.userPracDispGroupIDStr;
            var ctrlGroupID = findControlRecu(this.Page, Constants.PARM_GROUP_ID) as MBA.HiddenInput;
            ctrlGroupID.value = string.IsNullOrEmpty(groupID) || groupID == "0" ? "" : groupID;

            var pracPatCaseloadExpectedSvcID = MBA.HttpApplication.getParameter(Constants.PARM_PRAC_PAT_CASELOAD_EXPECTED_SVC_ID);
            var ctrlPracPatCaseloadExpectedSvcID = findControlRecu(this.Page, Constants.PARM_PRAC_PAT_CASELOAD_EXPECTED_SVC_ID) as MBA.HiddenInput;

            /* Checking if the user is a Practitioner */

            if (uInfo.userRole.ToLower() == Constants.ROLE_LEA_PROVIDER)
            {                

                /* If they are a health services practitioner */

                if (pracGrpSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES.ToString())
                {
                    canUsePreCareNotes = true;
                    canAdministerOrdersOrPx = true;
                    canRecordScheduledServices = false;
                    canAdministerVitalSigns = true;
                    canViewVisitHistory = true;
                    canStartNewVisit = true;
                 }

                /* If they are a mental health practitioner */

                else if (pracGrpSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_MENTAL_HEALTH_SERVICES.ToString())
                {
                    canUsePreCareNotes         = true;
                    canAdministerOrdersOrPx    = false; /* Record in journal */
                    canRecordScheduledServices = true;
                    canAdministerVitalSigns    = false;
                    canViewVisitHistory        = false; /* TODO: Set to true once visit code is filled in */
                    canStartNewVisit           = false; /* TODO: Set to true once visit code is filled in */
                }

                /* Any other practitioner family */

                else
                {
                    canUsePreCareNotes = false;
                    canAdministerOrdersOrPx = false;
                    canRecordScheduledServices = false;
                    canAdministerVitalSigns = false;
                    canViewVisitHistory = false;
                    canStartNewVisit = false;
                }
            }

            if (canRecordScheduledServices == true)
            {
                attendanceSelectionsJSON = ServiceRecordAttendanceSelections.generateNvpValuesJSON(dbConnApp, log, uInfo);

                var showSvcsForLeaBop        = rd.wu.pr.participatesInLEABOP;
                var showSvcsForLeaBopNonSpEd = rd.wu.pr.participatesInLEABOPNonSpEd;
                var showSvcsForCYBHI         = rd.wu.pr.participatesInCYBHI;
                var showSvcsForRUHealth      = rd.wu.pr.participatesInRUHealth;

                serviceNamesListPlanTypesJSON  = Services.viewJSONOfSvcNameListDataSources(showSvcsForLeaBop, showSvcsForLeaBopNonSpEd, showSvcsForCYBHI, showSvcsForRUHealth);

                urlManageOrderAndPx            = MBA.HttpApplication.createLink(ORPDocuments.URL_USER_ALL_MANAGE
                                                                             , true
                                                                             , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE));
                urlViewPatientGoalsProgress = PatientGoalsProgressIndividualGoals.URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS_BASE();
                if (!String.IsNullOrEmpty(pracPatCaseloadExpectedSvcID))
                {
                    ctrlPracPatCaseloadExpectedSvcID.value = pracPatCaseloadExpectedSvcID;
                }
            }

            /*-------------------------------
             * Hide client specific fields
             * if logged in as ROLE_CLIENT_ALL
             *------------------------------*/

            if (((IList)Constants.ROLE_CLIENT_ALL).Contains(uInfo.userRole.ToLower()))
            {
               
                ctrlCybhiTpaApprovedRow.entryAllowed                         = false;
                ctrlCybhiTpaApprovedRow.entryNotAllowedUseReplacementValue   = false;

                ctrlCybhiTpaApprovedOnRow.entryAllowed                       = false;
                ctrlCybhiTpaApprovedOnRow.entryNotAllowedUseReplacementValue = false;

                ctrlCybhiTpaIDRow.entryAllowed                               = false;
                ctrlCybhiTpaIDRow.entryNotAllowedUseReplacementValue         = false;

                ctrlCybhiTpaSubmitClaims.entryAllowed                        = false;

                ctrlSubmitclaimsDataEntryRow.rowLabel = "Does this patient attend our LEA? Select NO if the patient attends another LEA, but receives service from our LEA.";

                ctrlBicDataEntryRow.entryAllowed = false;
                ctrlBicDataEntryRow.entryNotAllowedUseReplacementValue = false;

                ctrlNotesDataEntryRow.entryAllowed = false;
                ctrlNotesDataEntryRow.entryNotAllowedUseReplacementValue = false;
            }

            /*-------------------------------
             * Hide fields for all
             * except sbs and coordinators
             *------------------------------*/

            if (!((IList)Constants.ROLE_SBS_ALL_LEA_COORD).Contains(uInfo.userRole.ToLower()))
            {
                ctrlSubmitclaimsDataEntryRow.entryAllowed = false;
                ctrlSubmitclaimsDataEntryRow.entryNotAllowedUseReplacementValue = false;
            }

            if (saveType == Constants.SAVE_TYPE_EDIT)
            {
                /*-------------------------------
                 * Get tab to open
                 * (only applies to edits)
                 *------------------------------*/

                tabToOpen = MBA.HttpApplication.getParameter(Constants.PARM_TAB_TO_OPEN);

                if (!String.IsNullOrWhiteSpace(tabToOpen))
                {
                    this.animateCloseIcon = true;
                }

                /*-------------------------------
                 * Get date of service to use for
                 * today
                 *------------------------------*/

                ctrlDOS.value = DateTime.Now.ToHTML5DateString();

                /*-------------------------------
                 * Load record and if its not
                 * found get out
                 *------------------------------*/

                Patient p = Patients.load(dbConnApp, log, uInfo, recid);

                /*-------------------------------
                 * Populate Data Values
                 *------------------------------*/

                ctrlSaveOrEdit.saveType = saveType;

                clientID = p.clientID.ToString();
                patID = p.id.ToString();

                ctrlSaveOrEdit.recID = patID;
                ctrlpatid.value = patID;
                ctrlSelectClient.selectValue = clientID;

                ctrlLname.value = p.lastName;
                ctrlFname.value = p.firstName;
                ctrlMname.value = p.middleName;

                ctrlNickname.value = p.preferredNickname;

                ctrlTeacherName.value = p.teacherOrCounselorName;

                ctrlSiteID.value = p.siteID.ToString();
                ctrlStudentID.value = p.siteRefID;
                ctrlDOB.value = (p.dob == DateTime.MinValue) ? "" : p.dob.ToString("yyyy-MM-dd");
                ctrlGrade.value = p.siteRank;
                ctrlSex.value = p.gender;
                ctrlparentConsentMCAL.value = Util.boolToYesNoUnknown(p.parentConsentMCAL, "");
                ctrlparentConsentMCALEffectiveDate.value = (p.parentConsentMCALEffectiveDate == DateTime.MinValue) ? "" : p.parentConsentMCALEffectiveDate.ToString("yyyy-MM-dd");

                ctrlFerpaConsent.value = Util.boolToYesNoUnknown(p.ferpaConsent);
                ctrlFerpaConsentEffectiveDate.value = p.ferpaConsentEffectiveDate;
                ctrlTreatmentConsent.value = Util.boolToYesNoUnknown(p.treatmentConsent);
                ctrlTreatmentConsentEffectiveDate.value = p.treatmentConsentEffectiveDate;

                ctrlCybhiTpaApproved.value = Util.boolToYesNoUnknown(p.cybhiTpaApproved);
                ctrlCybhiTpaApprovedOn.value = p.cybhiTpaApprovedOn;
                ctrlCybhiTpaID.value = p.cybhiTpaID;
                ctrlCybhiSubmitClaims.setValue(p.cybhiSubmitClaims);

                ctrlCSIS.value = p.CSIS;
                ctrlBIC.value = p.bic;
                ctrlHasplan.value = Util.boolToYesNo(p.hasIEP);
                ctrlSSN.value = p.ssn;
                ctrlSubmitClaims.value = Util.boolToYesNo(p.submitClaims);
                ctrlSubmitClaimsEffectiveDate.value = (p.submitClaimsEffectiveDate == DateTime.MinValue) ? "" : p.submitClaimsEffectiveDate.ToString("yyyy-MM-dd");
                ctrlNotes.value = p.notes;

                // NOTE: following value is also used in the javascript
                speciallyAdaptedVehicleForTransportationVal = Util.netBoolToJSBool(p.speciallyAdaptedVehicleForTransportation);
                ctrlSpeciallyAdaptedVehicleForTransportation.value = speciallyAdaptedVehicleForTransportationVal;

                ctrlSpedspecialtransportation.value = Util.boolToYesNo(p.spEdSpecialTransportation);



                ctrlSpedlastevaldate.setValue((p.spEdLastEvalDate == DateTime.MinValue) ?
                                                 "" : p.spEdLastEvalDate.ToString("yyyy-MM-dd"));

                ctrlSpedlastannualiepdate.setValue((p.spEdLastAnnualIEPDate == DateTime.MinValue) ?
                                                     "" : p.spEdLastAnnualIEPDate.ToString("yyyy-MM-dd"));

                ctrlSpednextannualiepdate.setValue((p.spEdNextAnnualIEPDate == DateTime.MinValue) ?
                                                       "" : p.spEdNextAnnualIEPDate.ToString("yyyy-MM-dd"));

                ctrlSpedcuriepdate.setValue((p.spEdCurIEPDate == DateTime.MinValue) ?
                                                       "" : p.spEdCurIEPDate.ToString("yyyy-MM-dd"));
                ctrlSelectDisability1Code.selectValue = p.spEdDisability1Code.ToString();
                ctrlSelectDisability1Code.selectName = p.spEdDisability1CodeAndName;
                ctrlSelectDisability2Code.selectValue = p.spEdDisability2Code.ToString();
                ctrlSelectDisability2Code.selectName = p.spEdDisability2CodeAndName;
                spedDisability1Text = p.spEdDisability1CodeAndName; // for display purposes
                spedDisability2Text = p.spEdDisability2CodeAndName; // for display purposes

                ctrlSpedCaseManagerName.value = p.spEdCaseManagerName;
                ctrlSpedExitedSpEdDate.value = p.spEdExitedSpEdDate;

                ctrlSpedstudentstrengths.value = p.spEdStudentStrengths;
                ctrlSpedparentconcerns.value = p.spEdParentConcerns;
                ctrlSpedprogressmonitoringdata.value = p.spEdProgressMonitoringData;
                ctrlSpedstudentpresentlevelsstatement.value = p.spEdStudentPresentLevelsStatement;
                ctrlSpedstudentdisabilityaffectsperformance.value = Util.boolToYesNo(p.spEdStudentDisabilityAffectsPerformance);
                ctrlSpedcureligibilitydate.setValue((p.spEdCurEligibilityDate == DateTime.MinValue) ?
                                                                   "" : p.spEdCurEligibilityDate.ToString("yyyy-MM-dd"));
                ctrlSpediniteligibilitydate.setValue((p.spEdInitEligibilityDate == DateTime.MinValue) ?
                                                                   "" : p.spEdInitEligibilityDate.ToString("yyyy-MM-dd"));
                ctrlSpediepattendeesidentified.value = Util.boolToYesNo(p.spEdIEPAttendeesIdentified);
                ctrlSpedeligibilityreasons.value = p.spEdEligibilityReasons;

                ctrlSelectSpEdLangaugeToTranslatePlanTo.selectValue = p.spEdPlanTranslateToLanguageCodeID.ToString();
                ctrlSelectSpEdLangaugeToTranslatePlanTo.selectName = p.spEdPlanTranslateToLanguageCodeAndName;

                ctrlSpedmeetingpurposedatajson.value = p.spEdMeetingPurposeDataJSON;
                ctrlSpedadditionalmeetingpurposedatajson.value = p.spEdAdditionalMeetingPurposeDataJSON;
                ctrlSpedamendmentreasonsdatajson.value = p.spEdAmendmentReasonsDataJSON;
                ctrlSpedinitrefdate.setValue((p.spEdInitRefDate == DateTime.MinValue) ?
                                                       "" : p.spEdInitRefDate.ToString("yyyy-MM-dd"));
                ctrlSpeddistrictreceivedparentconsentdate.setValue((p.spEdDistrictReceivedParentConsentDate == DateTime.MinValue) ?
                                                       "" : p.spEdDistrictReceivedParentConsentDate.ToString("yyyy-MM-dd"));
                ctrlDataEntryRowSelectSpEdReferringParty.selectValue = p.spEdReferringPartyCode.ToString();
                ctrlDataEntryRowSelectSpEdReferringParty.selectName = p.spEdReferringPartyCodeAndName;
                ctrlSpEdReferringPartyOtherOption.value = p.spEdReferringPartyOtherOption;
                ctrlDataEntryRowSelectSpEdPlanType.selectValue = p.spEdPlanTypeCode.ToString();
                ctrlDataEntryRowSelectSpEdPlanType.selectName = p.spEdPlanTypeCodeAndName;

                ctrlSelectStudentSpEdLangauge.selectValue = p.spEdStudentLanguageCodeID.ToString();
                ctrlSelectStudentSpEdLangauge.selectName = p.spEdStudentLanguageCodeAndName;

                ctrlSelectStudentSpEdRace.value = p.spEdStudentRaceCode.ToString();
                ctrlSelectStudentSpEdRace.selectName = p.spEdStudentRaceCodeAndName;

                ctrlSpEdEnteredSpEdDate.value = p.spEdEnteredSpEdDate;
                ctrlSpEdNextEvalDate.value = p.spEdNextEvalDate;

                ctrlSpEdStudentLanguageEnglishLearner.value = Util.boolToYesNo(p.spEdStudentLanguageEnglishLearner);
                ctrlSpEdStudentLanguageInfoReclassified.value = p.spEdStudentLanguageInfoReclassified;

                ctrlInTransitionalHousingStatus.setValue(p.inTransitionalHousingStatus);

                ctrlSpEdStudentLanguageEnglishLearnerUndesignatedPreschool.value = Util.boolToYesNo(p.spEdStudentLanguageEnglishLearnerUndesignatedPreschool);
                ctrlSpEdStudentLanguageInterpreterNeeded.value = Util.boolToYesNo(p.spEdStudentLanguageInterpreterNeeded);
                ctrlSpEdStudentLanguageTranslationRequested.value = Util.boolToYesNo(p.spEdStudentLanguageTranslationRequested);

                ctrlSpEdTransitionGoalEducation.value = p.spEdTransitionGoalEducation;
                ctrlSpEdTransitionGoalTraining.value = p.spEdTransitionGoalTraining;
                ctrlSpEdTransitionGoalEmployment.value = p.spEdTransitionGoalEmployment;
                ctrlSpEdTransitionGoalIndependentLiving.value = p.spEdTransitionGoalIndependentLiving;

                ctrlSpEdDevAcaFunSkillsReading.value = p.spEdDevAcaFunSkillsReading;
                ctrlSpEdDevAcaFunSkillsWriting.value = p.spEdDevAcaFunSkillsWriting;
                ctrlSpEdDevAcaFunSkillsMath.value = p.spEdDevAcaFunSkillsMath;
                ctrlSpEdDevAcaFunSkillsCommunicationDev.value = p.spEdDevAcaFunSkillsCommunicationDev;
                ctrlSpEdDevAcaFunSkillsGrossFineMotorDev.value = p.spEdDevAcaFunSkillsGrossFineMotorDev;
                ctrlSpEdDevAcaFunSkillsHealth.value = p.spEdDevAcaFunSkillsHealth;
                ctrlSpEdDevAcaFunSkillsVocational.value = p.spEdDevAcaFunSkillsVocational;
                ctrlSpEdDevAcaFunSkillsAdaptiveDailyLiving.value = p.spEdDevAcaFunSkillsAdaptiveDailyLiving;
                ctrlSpEdDevAcaFunSkillsAreasOfNeccessity.value = p.spEdDevAcaFunSkillsAreasOfNeccessity;

                ctrlSpedservicesdatajson.value = p.spEdServicesDataJSON;

                if (!String.IsNullOrEmpty(p.spEdServicesDataJSON))
                {
                    if (p.spEdServicesDataJSON == "{}") hasSpEdServiceData = false;
                    else if (p.spEdServicesDataJSON == "[]") hasSpEdServiceData = false;
                    else if (p.spEdServicesDataJSON == "[{}]") hasSpEdServiceData = false;
                    else hasSpEdServiceData = true;
                }
                else
                {
                    hasSpEdServiceData = false;
                }

                // populate the drop-down values with the saved selections

                ctrlSelectClient.selectName = p.clientName;
                ctrlSiteID.selectName = p.siteName;

                if (saveType == Constants.SAVE_TYPE_EDIT) this.subTitle = "Patients - Edit";
                if (saveType == Constants.SAVE_TYPE_DELETE) this.subTitle = "Patients - Delete";

                // load the transportation records to the table
                transportationRecs = TransportationMgmtAuthorizedRouteMembers.viewList(dbConnApp, log, uInfo, ctrlSelectClient.selectValue, ctrlSelectClient.selectValue, ctrlpatid.value, "1");
                ctrlrecTransportationJSON.value = MBA.JSON.toJSONString(transportationRecs, JsonLibrary.MSFT_WEB_SCRIPT_SERIALIZATION);

                // load the service records to the table
                //serviceRecs              = ORPDocuments.viewList (dbConnApp,log,uInfo, ctrlSelectClient.selectValue, ctrlpatid.value, "1");
                //ctrlrecServiceJSON.value = MBA.JSON.toJSONString(serviceRecs, JsonLibrary.MSFT_WEB_SCRIPT_SERIALIZATION);

                // load the service records to the table
                //fileRecs              = StoredFiles.viewList (dbConnApp,log,uInfo, ctrlSelectClient.selectValue, null, ctrlpatid.value, null, "1");
                //ctrlrecFileJSON.value = MBA.JSON.toJSONString(fileRecs, JsonLibrary.MSFT_WEB_SCRIPT_SERIALIZATION);

                restViewURL = MBA.HttpApplication.createLink(@"api/v1/servicerecords"
                                                            , true
                                                            , new NameValue(Constants.PARM_CLIENT_ID, ctrlSelectClient.selectValue)
                                                            , new NameValue(Constants.PARM_PATIENT_ID, ctrlpatid.value)
                                                           );

                urlViewAllPatientGoalsProgress = PatientGoalsProgressIndividualGoals.URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS_BASE(p.clientID.ToString(), recid);

                if (canReferPatient == true)
                {
                    urlPracPatReferal = PractitionerPatientReferrals.URL_MANAGE_REFERRALL(clientID, ctrlpatid.value);
                }

                // default selections for the SpEd tab
                if (String.IsNullOrWhiteSpace(ctrlDataEntryRowSelectSpEdPlanType.selectValue)
                            || ctrlDataEntryRowSelectSpEdPlanType.selectValue == "0")
                {
                    try
                    {
                        var pt = SpEdPlanTypes.load(dbConnApp, log, uInfo, "300");  // 300 - Pending

                        ctrlDataEntryRowSelectSpEdPlanType.selectValue = pt.id.ToString();
                        ctrlDataEntryRowSelectSpEdPlanType.selectName = pt.name;
                    }
                    catch (Exception planTypeDefaultLoadErr)
                    {

                    }
                }
            }
            else
            {
                /*-------------------------------
                 * Otherwise its a new record
                 *------------------------------*/
                this.subTitle = "Patients - New";

                /*-------------------------------
                 * Set client ID if passed in
                 *------------------------------*/

                if (!String.IsNullOrEmpty(clientID) && clientID != "0")
                {
                    ctrlSelectClient.selectValue = clientID;
                    ctrlSelectClient.entryInitiallyHidden = true;
                    ctrlSelectClient.entryAllowed = false;
                }

                /*-------------------------------
                 * submitclaims should
                 * default to YES
                 *------------------------------*/

                ctrlSubmitClaims.value = SelectYesOrNo.YES;


                

            } /* New Rec */

            // set showContentOnly flag for redirects

            showContentOnly = MBA.HttpApplication.getParameter(Constants.PARM_CONTENT_ONLY);
            if (String.IsNullOrEmpty(showContentOnly))
            {
                showContentOnly = "0";
            }            

            patientSaveURL = MBA.HttpApplication.createLink(Patients.URL_USER_ALL_SAVE
                                                          , true
                                                          , new NameValue(Constants.PARM_CONTENT_ONLY, showContentOnly));



        }
    }
}
