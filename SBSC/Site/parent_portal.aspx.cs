using System;
using MBA;
using System.Collections.Generic;
using System.Web.Script.Serialization;

/***************************************************************************
 * Parent Portal */
/**
 * Private home page for parent and patients
 ***************************************************************************/

namespace Spedmon
{
    public class parent_portal : WebUI
    {
        public parent_portal() : base(@"parent_portal",
                                      @"Parent Portal",
                                      @"portal_messages_widget.css|parent_portal.css|user_all_pat_save_2.css",
                                      @"patient-service-records.js|stored-files.js|patient-persons.js|user_personal_notes.js|tele-iep-sessions.js",
                                      Constants.ROLE_PARENT_GUARDIAN)
        { }

        public bool InitPageOK  = false;
        public bool isPG        = false;
        public bool isPCalStaff = false;

        public Dictionary<string, ParentPatientCommom> patData;
        public List<ParentPatientCommom> parentPatients;

        protected string PatientsJson = @"[]";

        public string clientIDStr   = "";
        public string clientName    = "";
        public string patIDStr      = "";

        public string isPcalStaffJSBoolStr  = "";
        public string isPatientJSBoolStr    = "";

        public string sendMessageUrl        = "";

        public string urlUserMessagesSave   = "";
        public string urlUserMessagesDelete = "";
        public string urlRecipientSrc       = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            var ctrlClientID = findControlRecu(this.Page, Constants.PARM_CLIENT_ID) as MBA.HiddenInput;
            var ctrlPracID = findControlRecu(this.Page, Constants.PARM_PRACTITIONER_ID) as MBA.HiddenInput;
            var ctrlPatID = findControlRecu(this.Page, Constants.PARM_PATIENT_ID) as MBA.HiddenInput;
            var ctrlPatPerID = findControlRecu(this.Page, Constants.PARM_PAT_PER_ID) as MBA.HiddenInput;
            var ctrlDos = findControlRecu(this.Page, Constants.PARM_DOS) as MBA.HiddenInput;
            var ctrlNoteNameSpace = findControlRecu(this.Page, Constants.PARM_NOTE_NAMESPACE) as MBA.HiddenInput;
            var ctrlNoteSource = findControlRecu(this.Page, Constants.PARM_NOTE_SOURCE) as MBA.HiddenInput;
            var ctrlNotificationsAndMessages = findControlRecu(this.Page, "spedmonUserNotificationsAndMessages") as MBA.ParentPortalMessagesWidget;
            var ctrlrefuserid = findControlRecu(this.Page, Constants.PARM_REFERRING_BY_USER_ID) as MBA.HiddenInput;

            isPCalStaff = uInfo.pcalStaff;
            isPG = (uInfo.userRoleID == Constants.ROLE_PARENT_GUARDIAN_ID);

            if (!isPG)
            {
                InitPageOK = false;
                return;
            }

            ctrlPracID.value = uInfo.userPracIDStr;

            isPcalStaffJSBoolStr = Util.netBoolToJSBool(isPCalStaff);
            isPatientJSBoolStr = "false";

            urlUserMessagesSave = MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_SAVE, true);
            urlUserMessagesDelete = MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_DELETE, true);
            urlRecipientSrc = MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_VIEW_SEL_CONTACTS, true);

            ctrlNotificationsAndMessages.sendMessageAjaxURL = urlUserMessagesSave;
            ctrlNotificationsAndMessages.deleteMessageAjaxURL = urlUserMessagesDelete;
            ctrlNotificationsAndMessages.recipientSrcURL = urlRecipientSrc;
            ctrlNotificationsAndMessages.messagesViewAjaxURL = MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_VIEWLIST, true);

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

            LoadUserMessages(ctrlNotificationsAndMessages);

            ctrlrefuserid.value = uInfo.useridStr;
            ctrlNoteNameSpace.value = @"user_personal_notes";
            ctrlNoteSource.value = @"home_screen";

            parentPatients = new List<ParentPatientCommom>();

            LoadParentGuardianActionItems(ctrlNotificationsAndMessages);
            LoadUpcomingTeleIEPSessions(ctrlNotificationsAndMessages);

            LoadParentGuardianPatients(ctrlClientID, ctrlPatID, ctrlPatPerID, ctrlDos, ctrlNotificationsAndMessages);
        }

        private void LoadUserMessages(MBA.ParentPortalMessagesWidget ctrlNotificationsAndMessages)
        {
            UserMessages.viewList(dbConnUser, log, uInfo, "0", "1", null, "", "", "1")
                .ForEach(delegate (MBA.UserMessage msg)
                {
                    if (msg.okToShow)
                    {
                        string _previewMsg = ParentPortalMessagesWidget.generateMessagePreviewMsg(
                            msg.senderName,
                            msg.createdStr,
                            msg.subject,
                            msg.senderEmail,
                            msg.senderClientName,
                            this.uInfo.pcalStaff
                        );

                        ctrlNotificationsAndMessages.addMessage(
                            _previewMsg,
                            msg,
                            NotificationMessagePriority.MESSAGE,
                            true,
                            true,
                            true
                        );
                    }
                });
        }

        private void LoadParentGuardianActionItems(MBA.ParentPortalMessagesWidget ctrlNotificationsAndMessages)
        {
            if (ServiceAuthorizationCommon.doesParentGuardianHaveServiceAuthorizationRequestsPending(ref rd))
            {
                string preview = ParentPortalMessagesWidget.generatePreviewMsg(
                    @"fa fa-child",
                    @"Parent/Guardian Authorization Requests",
                    null,
                    @"There are pending authorization requests for your student that require your review.",
                    @"Click here to review the requests",
                    MBA.HttpApplication.createLink(ServiceAuthorizationRequestResponses.URL_MANAGE_RESPONSES, true),
                    true
                );

                ctrlNotificationsAndMessages.addMessage(
                    preview,
                    new UserMessage("General Message", preview, 0, Constants.APP_NAME),
                    NotificationMessagePriority.MESSAGE,
                    false,
                    false,
                    false
                );
            }
        }

        private void LoadUpcomingTeleIEPSessions(MBA.ParentPortalMessagesWidget ctrlNotificationsAndMessages)
        {
            var upcomingTeleIEPSessions = Spedmon.TeleIEPSessions.getUpcomingTelecommSessionsForUserID(this.dbConnUser, log, uInfo);

            foreach (var upcomingTeleIEPSession in upcomingTeleIEPSessions)
            {
                string _previewMsg = NotificationsAndMessagesWidget.generatePreviewMsg(
                    @"fa fa-video",
                    @"Upcoming HyQueue TeleIEP Session",
                    upcomingTeleIEPSession.tsp.meetingStartDate.ToShortDateAndTimeString(),
                    upcomingTeleIEPSession.tsp.roomTitle,
                    @"Click here for more details",
                    upcomingTeleIEPSession.rsvpPageUrl,
                    true
                );

                ctrlNotificationsAndMessages.addMessage(
                    _previewMsg,
                    new UserMessage("General Message", _previewMsg, 0, Constants.APP_NAME),
                    NotificationMessagePriority.MESSAGE,
                    false,
                    false,
                    false
                );
            }
        }

        private void LoadParentGuardianPatients(MBA.HiddenInput ctrlClientID, MBA.HiddenInput ctrlPatID, MBA.HiddenInput ctrlPatPerID, MBA.HiddenInput ctrlDos, MBA.ParentPortalMessagesWidget ctrlNotificationsAndMessages)
        {
            if (uInfo.associatedPatientPersons == null || uInfo.associatedPatientPersons.Count == 0)
            {
                InitPageOK = false;
                return;
            }

            bool isFirstPatient = true;

            foreach (var p in uInfo.associatedPatientPersons)
            {
                string currClientID = p.clientID.ToString();
                string currClientName = p.clientName;
                string currPatID = p.patientID.ToString();
                string currPatPerID = p.personID.ToString();

                if (isFirstPatient)
                {
                    clientIDStr = currClientID;
                    clientName = currClientName;
                    patIDStr = currPatID;

                    ctrlClientID.value = currClientID;
                    ctrlPatID.value = currPatID;
                    ctrlDos.value = DateTime.Today.ToHTML5DateString();
                    ctrlPatPerID.value = currPatPerID;

                    isFirstPatient = false;
                }

                ReturnObject ro = Patients.get(dbConnApp, log, uInfo, currPatID);

                if (ro != null && ro.hasRecord && ro.data != null)
                {
                    Patient pat = ro.data as Patient;

                    if (pat != null)
                    {
                        AddPortalPatient(pat, currClientID, currClientName, currPatID);
                    }
                }
            }

            FinalizePortalPatients(ctrlNotificationsAndMessages);
        }

        private void AddPortalPatient(Patient pat, string clientID, string clientNameValue, string patientID)
        {
            if (pat == null)
            {
                return;
            }

            parentPatients.Add(new ParentPatientCommom
            {
                patID = patientID,
                pracID = string.IsNullOrEmpty(uInfo.userPracIDStr) ? "" : uInfo.userPracIDStr,

                patName = pat.name,
                patEmail = pat.email,
                patPhone = pat.phone,

                patStreet1 = pat.street1,
                patStreet2 = pat.street2,
                patCity = pat.city,
                patState = pat.state,
                patZip5 = pat.zip5,
                patZip4 = pat.zip4,

                patAge = pat.ageCurrent.ToString(),
                patGender = pat.gender,

                patConsentToRelease = pat.ferpaConsentYNU,
                patPreferredContactMethod = pat.preferredContactMethodCode,
                patplaceHomeID = pat.patientHomePlaceID.ToString(),

                insurance = new List<PatientInsuranceCarrier>(
                    PatientInsuranceCarriers.viewList(
                        dbConnApp,
                        log,
                        uInfo,
                        clientID,
                        patientID,
                        "Y"
                    )
                ),

                upcomingVisits = new List<TeleIEPSession>(
                    TeleIEPSessions.viewList(
                        dbConnApp,
                        log,
                        uInfo,
                        clientID,
                        patientID,
                        "Y"
                    )
                )
            });
        }

        private void FinalizePortalPatients(MBA.ParentPortalMessagesWidget ctrlNotificationsAndMessages)
        {
            if (parentPatients == null || parentPatients.Count == 0)
            {
                InitPageOK = false;
                return;
            }

            if (!string.IsNullOrEmpty(clientIDStr) && !string.IsNullOrEmpty(patIDStr))
            {
                var listPatPrac = Spedmon.PatientPractitioners.viewSel(
                    dbConnApp,
                    log,
                    uInfo,
                    false,
                    "",
                    clientIDStr,
                    patIDStr,
                    ""
                );

                if (listPatPrac.SelRecs != null)
                {
                    foreach (var pp in listPatPrac.SelRecs)
                    {
                        ctrlNotificationsAndMessages.addPractitioner(pp.id.ToString(), pp.label, pp.recData4, pp.recData5);
                    }
                }
            }

            var js = new JavaScriptSerializer();
            PatientsJson = js.Serialize(parentPatients);

            InitPageOK = true;
        }
    }


}