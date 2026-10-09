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
     * UserAllPatientSave2 */
    /**
     * Saves a patient
     ***************************************************************************/

    public class UserAllPatientSave2 : WebUI
    {
        
        public UserAllPatientSave2() : base( "patient_save_2"
                                             ,  Patients.SEL_LABEL_SAVE
                                             , "user_all_patient_goal_progress_reporting.css|pre-care-notes.css|pat_direct_service.css|rec_pat_transportations.css|patient-visit.css|patient-profile.css|student-status-bar.css|user_all_pat_save_2.css|jquery-mba-image-uploader-cropper.css|portal_messages_widget.css"
                                             , "scheduled-services-provided-by-prac-for-pat-on-dos.js|patient-allergies.js|patient-known-health-problems.js|patient-diagnoses.js|patient-care-notes.js|practice-office-visits.js|orders-or-prescriptions-provide-hs-for-pat-on-dos.js|service-journal-recent-procedure-entries.js|patient-vital-signs.js|patient-vital-signs-measurement.js|care-plans.js|rec_pat_transportations.js|user_all_patient_goal_progress_reporting.js|patient-goals.js|patient-insurance.js|orders-or-prescriptions.js|patient-persons.js|patient-promised-services.js|practitioner-patient-scheduled-services-manage.js|patient-service-records.js|stored-files.js|form-builder-patient-goal.js|patient-profile.js|student-status-bar.js|jquery-mba-image-uploader-cropper.js"
                                             , Constants.ROLE_ALL_PCAL_AND_CLIENT)
        { }
        
        public string recID                          = "";
        public string saveType                       = "";
        public int    saveTypeVal                    = 0;
        public string tabToOpen                      = "";
        public string showContentOnlyParm            = "0";
        public string appModeParm                    = "";
        public bool   isPCalStaff                    = false;
        public string isPcalStaffJSBoolStr           = "";
        public bool   isPrac                         = false; 
        public string clientID                       = "";
        public string patID                          = "";
        public string pracID                         = "";
        public string groupID                        = "";
        public string pracGrpSvcClassNameID          = "";
        public string pracPatCaseloadExpectedSvcID   = "";
        public string patientSaveURL                 = "";
        public string urlPracPatReferal              = "";
        public string urlViewAllPatientGoalsProgress = "";
        public string urlViewPatientGoalsProgress    = "";
        public string urlGetPatientProfile           = "";
        public string urlSavePatientProfile          = "";
        public string urlManageOrderAndPx            = "";
        public string attendanceSelectionsJSON       = "[]";
        public string serviceNamesListPlanTypesJSON  = "[]";
        public bool   canUsePreCareNotes             = false;
        public bool   canAdministerOrdersOrPx        = false;
        public bool   canRecordScheduledServices     = false;
        public bool   canViewVisitHistory            = false;
        public bool   canStartNewVisit               = false;
        public bool   canAdministerVitalSigns        = false;
        public bool   canReferPatient                = false;

        public string urlUserMessagesSave            = @"";
        public string urlRecipientSrc                = @"";
        public string urlUserMessagesDelete          = @"";
        public string patientUserID                  = "";
        public int communicationsMessagesCount       = 0;


        public List<TransportationMgmtAuthorizedRouteMember> transportationRecs = new List<TransportationMgmtAuthorizedRouteMember>();

        public Patient p = new Patient();

        protected void Page_Load(object sender, EventArgs e)
        {                  
            /*##########################################################################
              # Get parameters
              ###########################################################################*/

            saveType                     = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);
            recID                        = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
            tabToOpen                    = MBA.HttpApplication.getParameter(Constants.PARM_TAB_TO_OPEN);            
            pracPatCaseloadExpectedSvcID = MBA.HttpApplication.getParameter(Constants.PARM_PRAC_PAT_CASELOAD_EXPECTED_SVC_ID);
            clientID                     = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
            showContentOnlyParm          = MBA.HttpApplication.getParameter(Constants.PARM_CONTENT_ONLY);
            appModeParm                  = MBA.HttpApplication.getParameter(Constants.PARM_APP_MODE);

            /*##########################################################################
              # Determine save type
              ###########################################################################*/

            Object vSaveType = MBA.Validate.optInteger(saveType, Messages.INVALID_SAVE_TYPE);
            if (vSaveType == null) saveType = Constants.SAVE_TYPE_NEW.ToString();            
            saveTypeVal = Convert.ToInt32(saveType);
           
            
            /*##########################################################################
              # Determine if user is pcal staff or prac
              ###########################################################################*/

            isPCalStaff           = uInfo.pcalStaff;
            isPcalStaffJSBoolStr  = Util.netBoolToJSBool(isPCalStaff);
            isPrac                = (uInfo.userRole.ToLower() == Constants.ROLE_LEA_PROVIDER) ? true: false;
                        
            /*##########################################################################
              # Get control references
              ###########################################################################*/

            var ctrlSelectClient                 = findControlRecu(this.Page, "selectClient")                 as DataEntryRowSelectClient;      
            var ctrlGroupID                      = findControlRecu(this.Page, Constants.PARM_GROUP_ID)        as MBA.HiddenInput;
            var ctrlPracID                       = findControlRecu(this.Page, Constants.PARM_PRACTITIONER_ID) as MBA.HiddenInput;
            var ctrlPracGroupSvcClassNameID      = findControlRecu(this.Page, "groupserviceclassnameid")      as MBA.HiddenInput;         
            var ctrlPatID                        = findControlRecu(this.Page, Constants.PARM_PATIENT_ID)      as MBA.HiddenInput;
            var ctrlDOS                          = findControlRecu(this.Page, Constants.PARM_DOS)             as MBA.HiddenInput;
            var ctrlRecTransportationJSON        = findControlRecu(this.Page, "recTransportationJSON")        as MBA.HiddenTextArea;
            var ctrlSiteID                       = findControlRecu(this.Page, Constants.PARM_SITE_ID)         as MBA.HiddenInput;         
            var ctrlRecID                        = findControlRecu(this.Page, Constants.PARM_REC_ID)          as MBA.HiddenInput;
            var ctrlSaveType                     = findControlRecu(this.Page, Constants.PARM_SAVE_TYPE)       as MBA.HiddenInput;
            var ctrlPracPatCaseloadExpectedSvcID = findControlRecu(this.Page, Constants.PARM_PRAC_PAT_CASELOAD_EXPECTED_SVC_ID) as MBA.HiddenInput;

            var ctrlNotificationsAndMessages = findControlRecu(this.Page, "spedmonPatientNotificationsAndMessages") as MBA.ParentPortalMessagesWidget;

            /*##########################################################################
              # Set urls used for any save type
              ###########################################################################*/

            urlGetPatientProfile    = Patients.URL_SVC_GET_BASE();
            urlSavePatientProfile   = Patients.URL_SVC_SAVE_PROFILE_BASE();
            patientSaveURL          = MBA.HttpApplication.createLink(Patients.URL_USER_ALL_SAVE, true);

            urlUserMessagesSave = MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_SAVE, true);
            urlUserMessagesDelete = MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_DELETE, true);
            urlRecipientSrc = MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_VIEW_SEL_CONTACTS, true);

            if (!String.IsNullOrEmpty(showContentOnlyParm)) {
              patientSaveURL = Util.appendParmToLink(patientSaveURL,Constants.PARM_CONTENT_ONLY,showContentOnlyParm,true);
            }            

            if (!String.IsNullOrEmpty(appModeParm))
            {
              patientSaveURL = Util.appendParmToLink(patientSaveURL,Constants.PARM_APP_MODE,appModeParm,true);
            }
            
            /*##########################################################################
              # Set control value used for any save type
              ###########################################################################*/

            ctrlSaveType.value = saveType;

            /*##########################################################################
              # New Patient
              ###########################################################################*/

            if (saveTypeVal == Constants.SAVE_TYPE_NEW)
            {

                if (!String.IsNullOrEmpty(clientID) && clientID != "0")
                {
                    var clientIDVal = Spedmon.Validate.reqClientID(uInfo, clientID);
                    ctrlSelectClient.selectValue = clientID;
                    ctrlSelectClient.entryInitiallyHidden = true;
                    ctrlSelectClient.entryAllowed = false;
                }
                ctrlPatID.value = "";

            }

            /*##########################################################################
              # Existing Patient
              ###########################################################################*/

            else if (saveTypeVal == Constants.SAVE_TYPE_EDIT)
            {

                var patIDVal = Spedmon.Validate.reqPatID(uInfo, recID);
                recID = patIDVal.ToString();

                p = Patients.load(dbConnApp, log, uInfo, recID);
                patientUserID = p.patientUserIDInt.ToString();
                ctrlSelectClient.selectValue = p.clientID.ToString();
                ctrlSelectClient.selectName = p.clientName;
                ctrlSelectClient.entryInitiallyHidden = true;
                ctrlSelectClient.entryAllowed = false;

                ctrlPatID.value = recID;
                ctrlSiteID.value = p.siteID.ToString();
                ctrlRecID.value = recID;
                clientID = p.clientID.ToString();
                transportationRecs = TransportationMgmtAuthorizedRouteMembers.viewList(dbConnApp, log, uInfo, ctrlSelectClient.selectValue, ctrlSelectClient.selectValue, ctrlPatID.value, "1");
                ctrlRecTransportationJSON.value = MBA.JSON.toJSONString(transportationRecs, JsonLibrary.MSFT_WEB_SCRIPT_SERIALIZATION);

                /*##########################################################################
                /*##########################################################################
                  # Set URL values used by all users
                  ###########################################################################*/

                urlManageOrderAndPx = MBA.HttpApplication.createLink(ORPDocuments.URL_USER_ALL_MANAGE, true, new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE));
                urlViewPatientGoalsProgress = PatientGoalsProgressIndividualGoals.URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS_BASE();

                /*##########################################################################
                  # Practitioner specific logic
                  ###########################################################################*/

                if (isPrac == true)
                {

                    ctrlDOS.value = DateTime.Now.ToHTML5DateString();

                    pracGrpSvcClassNameID = uInfo.userPracStdSvcClassNameID.ToString();
                    pracID = uInfo.userPracIDStr;
                    groupID = uInfo.userPracDispGroupIDStr;

                    ctrlPracGroupSvcClassNameID.value = string.IsNullOrEmpty(pracGrpSvcClassNameID) || pracGrpSvcClassNameID == "0" ? "" : pracGrpSvcClassNameID;
                    ctrlPracID.value = string.IsNullOrEmpty(pracID) || pracID == "0" ? "" : pracID;
                    ctrlGroupID.value = string.IsNullOrEmpty(groupID) || groupID == "0" ? "" : groupID;

                    canReferPatient = PractitionerPatientReferrals.userCanAccessSaveScreen(rd, saveTypeVal);
                    if (canReferPatient == true)
                    {
                        urlPracPatReferal = PractitionerPatientReferrals.URL_MANAGE_REFERRALL(clientID, ctrlPatID.value);
                    }

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
                        canUsePreCareNotes = true;
                        canAdministerOrdersOrPx = false; /* Record in journal */
                        canRecordScheduledServices = true;
                        canAdministerVitalSigns = false;
                        canViewVisitHistory = false; /* TODO: Set to true once visit code is filled in */
                        canStartNewVisit = false; /* TODO: Set to true once visit code is filled in */
                    }

                    /* Case managers, teachers */

                    else if (pracGrpSvcClassNameID == "1")
                    {
                        canUsePreCareNotes = true;
                        canAdministerOrdersOrPx = false;
                        canRecordScheduledServices = true;
                        canAdministerVitalSigns = false;
                        canViewVisitHistory = false;
                        canStartNewVisit = false;
                    }

                    /* OT */

                    else if (pracGrpSvcClassNameID == "4")
                    {
                        canUsePreCareNotes = true;
                        canAdministerOrdersOrPx = false;
                        canRecordScheduledServices = true;
                        canAdministerVitalSigns = false;
                        canViewVisitHistory = false;
                        canStartNewVisit = false;
                    }

                    /* PT */

                    else if (pracGrpSvcClassNameID == "6")
                    {
                        canUsePreCareNotes = true;
                        canAdministerOrdersOrPx = false;
                        canRecordScheduledServices = true;
                        canAdministerVitalSigns = false;
                        canViewVisitHistory = false;
                        canStartNewVisit = false;
                    }

                    /* Speech */

                    else if (pracGrpSvcClassNameID == "9")
                    {
                        canUsePreCareNotes = true;
                        canAdministerOrdersOrPx = false;
                        canRecordScheduledServices = true;
                        canAdministerVitalSigns = false;
                        canViewVisitHistory = false;
                        canStartNewVisit = false;
                    }

                    /* Orientration and Mobility */

                    else if (pracGrpSvcClassNameID == "11")
                    {
                        canUsePreCareNotes = true;
                        canAdministerOrdersOrPx = false;
                        canRecordScheduledServices = true;
                        canAdministerVitalSigns = false;
                        canViewVisitHistory = false;
                        canStartNewVisit = false;
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

                    if (canRecordScheduledServices == true)
                    {
                        attendanceSelectionsJSON = ServiceRecordAttendanceSelections.generateNvpValuesJSON(dbConnApp, log, uInfo);

                        var showSvcsForLeaBop = rd.wu.pr.participatesInLEABOP;
                        var showSvcsForLeaBopNonSpEd = rd.wu.pr.participatesInLEABOPNonSpEd;
                        var showSvcsForCYBHI = rd.wu.pr.participatesInCYBHI;
                        var showSvcsForRUHealth = rd.wu.pr.participatesInRUHealth;

                        serviceNamesListPlanTypesJSON = Services.viewJSONOfSvcNameListDataSources(showSvcsForLeaBop, showSvcsForLeaBopNonSpEd, showSvcsForCYBHI, showSvcsForRUHealth);

                        if (!String.IsNullOrEmpty(pracPatCaseloadExpectedSvcID))
                        {
                            ctrlPracPatCaseloadExpectedSvcID.value = pracPatCaseloadExpectedSvcID;
                        }
                    }
                } /* user is a prac*/

                /*Message Componnent*/
                ctrlNotificationsAndMessages.ID                     = "patientNotificationsMessagesWidget";
                ctrlNotificationsAndMessages.title                  = "Notifications";
                ctrlNotificationsAndMessages.showPractitioners      = false;
                ctrlNotificationsAndMessages.showHeaderActions      = false;
                ctrlNotificationsAndMessages.enableCompose          = false;
                ctrlNotificationsAndMessages.enableSentMessages     = false;
                ctrlNotificationsAndMessages.enableDeletedMessages  = false;
                ctrlNotificationsAndMessages.sendMessageAjaxURL     = urlUserMessagesSave;
                ctrlNotificationsAndMessages.deleteMessageAjaxURL   = urlUserMessagesDelete;
                ctrlNotificationsAndMessages.recipientSrcURL        = urlRecipientSrc;

                ctrlNotificationsAndMessages.messagesViewAjaxURL = MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_VIEWLIST
                                                                                             , true
                                                                                             );
                ctrlNotificationsAndMessages.deletedMessagesAjaxData = @"{"
                                                                            + "\"viewSentOnly\": false"
                                                                            + ",\"okToShow\"   : false"
                                                                            + ",\"hasRead\"    : null"
                                                                            + ",\"active\"     : true"
                                                                     + @"}";

                ctrlNotificationsAndMessages.sentMessagesAjaxData = @"{"
                                                                            + "\"viewSentOnly\": true"
                                                                            + ",\"okToShow\"   : null"
                                                                            + ",\"hasRead\"    : null"
                                                                            + ",\"active\"     : true"
                                                                     + @"}";

                /*########################################################################### 
                # Get User's messages
                ###########################################################################*/

                List<string> targetUserIDs = new List<string>();

                if (!string.IsNullOrEmpty(patientUserID))
                {
                    targetUserIDs.Add(patientUserID);
                }

                List<PatientPerson> patientPeople = PatientPersons.viewList(
                      dbConnApp
                    , log
                    , uInfo
                    , p.clientID.ToString()
                    , p.id.ToString()
                    , "1"
                );

                foreach (PatientPerson pp in patientPeople)
                {
                    if (pp.userIDInt > 0 && pp.classID2 == 1002)
                    {
                        string parentGuardianUserID = pp.userIDInt.ToString();

                        if (!targetUserIDs.Contains(parentGuardianUserID))
                            targetUserIDs.Add(parentGuardianUserID);
                    }
                }

                foreach (string targetUserID in targetUserIDs)
                {
                    UserMessages.viewListForUserID(dbConnUser, log, uInfo, targetUserID, "spedcare", "0", "1", null, "", "", "1").ForEach(delegate (MBA.UserMessage msg)
                    {

                        if (msg.okToShow)
                        {
                            string _previewMsg = ParentPortalMessagesWidget.generateMessagePreviewMsg(msg.senderName, msg.createdStr, msg.subject, msg.senderEmail, msg.senderClientName, this.uInfo.pcalStaff);
                            ctrlNotificationsAndMessages.addMessage(
                                             _previewMsg
                                            , msg
                                            , NotificationMessagePriority.MESSAGE
                                            , true
                                            , false
                                            , true
                                );
                            communicationsMessagesCount++;
                        }
                    });
                }

                /*##########################################################################
                  # Animate close icon if needed
                  ###########################################################################*/

                if (!String.IsNullOrWhiteSpace(tabToOpen))
                {
                    this.animateCloseIcon = true;
                }


            }
            else
            {
                return;
            }        
        }
    }
}
