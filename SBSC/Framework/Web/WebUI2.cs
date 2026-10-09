using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text.RegularExpressions;

using MBA;


namespace Spedmon
{

    /***************************************************************************
     * WebUI */
    /**
     * Base class for all web user interface (UI) pages.  This class generates a
     * standard framework of HTML markup, CSS includes, and Javascript includes
     * for every page that inherits from it.  It also renders any content that
     * the subclasses provide.  This provides a uniform "look and feel" for
     * all UI pages.
     *
     * @param bodyid         The id you wish to give to the body tag.  If none is
     * @param subtitle       The subtitle you wish to give to the page.  The page
     *                       title will be Application Name - Subtitle
     * @param css            Additional external css files
     * @param js             Additional external js files
     * @param permittedRoles User roles that are allowed to access the page
      *
     ****************************************************************************/

    public class WebUI2 : MBA.WebUI2
    {

        /*===============================
         * Delegates
         *===============================*/

        /*-------------------------------
          * App bar icons public
          *
          *------------------------------*/

        static handleAppSpecificResponse rAppBarIconsPublic = new handleAppSpecificResponse(delegate (HttpRequest req, HttpResponse rsp, ref RequestResponse rd, ref UserInfo uInfo, ref HtmlTextWriter writer) {

        });


        /*-------------------------------
         * App bar icons private
         *
         *------------------------------*/

        static handleAppSpecificResponse rAppBarIconsPrivate = new handleAppSpecificResponse(delegate (HttpRequest req, HttpResponse rsp, ref RequestResponse rd, ref UserInfo uInfo, ref HtmlTextWriter writer) {

            /*
            var comboBox = new MBA.ComboBox();
            comboBox.ID = "dropdownSelectPage"; comboBox.title = "Select Page"; comboBox.dataURL = "multimedia_outreach_campaigns.asmx/viewSel";
            comboBox.onSelect =
              "document.location =" +
              MBA.HttpApplication.createLink(
                "multimedia_page_private.aspx",
                true,
                new NameValue("amd", "uibssub")) +
              "&recid=event.dataitem.id;";

            comboBox.RenderComboBox(writer); 

            */

            /* Add client contacts for PCAL staff and LEA coordinators */

            if (UserAssignedRoles.userHasPermittedRole(Constants.ROLE_SBS_ALL_LEA_COORD, rd.wu.usr.roleName))
            {
                string clientCommunicationsLink = MBA.HttpApplication.createLink(ClientsNotes.URL_USER_ALL_MANAGE
                                                                                  , true
                                                                                  , new NameValue(Constants.PARM_APP_MODE
                                                                                                   , Constants.AMD_UI_DBS_SUB_PAGE));

                renderAppBarIcon(ref writer, ClientsNotes.SEL_LABEL_MANAGE, @"message", clientCommunicationsLink, null, true);
            }

        });


        /*-------------------------------
         * Public menu
         *------------------------------*/

        public static renderMenuPublic rmenuPublic = new renderMenuPublic(delegate (ref HtmlTextWriter writer) {
            renderMenuListItem(ref writer, null, @"About Us", Messages.ABOUT_US_LINK, false, false, true);
            renderMenuListItem(ref writer, null, @"Contact Us", Messages.CONTACT_US_LINK, false, false, true);
            renderMenuListItem(ref writer, null, @"Request Account", Constants.REQUEST_ACCOUNT, false, false, true);
            renderMenuListItem(ref writer, null, @"Request Password Reset", Constants.FORGOT_MY_PASSWORD, false, false, false);
            /*renderMenuListItem(ref writer, null, @"Send Us A File", Constants.REQUEST_FILE_UPLOAD_PUBLIC, false, false, true);*/

            return;
        });

        /*-------------------------------
         * Private menu
         *------------------------------*/

        public static renderMenuPrivate rmenuPrivate = new renderMenuPrivate(delegate (ref SqlConnection dbConnUser, ref SqlConnection dbConnApp, ref DetailsLog log, ref RequestResponse rd, ref UserInfo uInfo, ref HtmlTextWriter writer) {

            string roleNameLower = rd.wu.usr.roleName.ToLower();

            // If this is a time keeper user (in this case its just Practi-Cal staff)

            if (rd.wu.usr.pcalStaff == true)
            {

                /* If the time sheet user info has not already been prefetched (as it is on some time keeper pages) get the data */

                if (rd.wu.usr.timeSheetUserInfo == null)
                    rd.wu.usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(rd.wu.usr.userName);

                /* Set session data that is used on various time keeper pages */

                if (rd.wu.usr.timeSheetUserInfo != null)
                {
                    MBA.Web.TimeSheetSession.Current.EmployeeId = rd.wu.usr.timeSheetUserInfo.employeeid;
                    MBA.Web.TimeSheetSession.Current.RoleId = rd.wu.usr.timeSheetUserInfo.roleID;

                    /* If the time sheet user needs to enter time */

                    if (rd.wu.usr.timeSheetUserInfo.isDelinquentDTKUser == true)
                    {

                        /* And we are not on a time entry page */
                        /* TODO: Put these into a constant value that can be searched. */

                        if ((
                              (rd.requestResource == "WebFormTimeEntry.aspx")
                           || (rd.requestResource == "InsertOrUpdateTimeEntry.aspx")
                           || (rd.requestResource == "WebFormScheduleStopStart.aspx")
                           || (rd.requestResource == "WebFormTimeEntrySchedule.aspx")
                           || (rd.requestResource == "user_all_timekeeper_panel.aspx")
                           ) == false)
                        {

                            /* Redirect to a time entry page */

                            var enterTimeURL = MBA.HttpApplication.createLink(@"WebFormTimeEntry.aspx"
                                                                              , true);

                            /* Redirect logic uses static methods */

                            HttpContext.Current.Response.Redirect(enterTimeURL, false);
                            HttpContext.Current.ApplicationInstance.CompleteRequest();

                        } /* Not on a time entry page */
                    } /* Time entries required */
                } /* Timekeeper user */

            }

            switch (roleNameLower)
            {

                /*********************************************************************************************
                 *                          Third Party Person - SELPA
                 *********************************************************************************************/

                case Constants.ROLE_SELPA_USER:
                    {
                        renderMenuListItem(ref writer, CdeComplianceCommon.MENU_ID_FOR_SELPA_MANAGE, CdeComplianceCommon.SEL_LABEL_MANAGE, CdeComplianceCommon.URL_FOR_SELPA_MANAGE);
                        break;
                    }

                /*********************************************************************************************
                 *                          Third Party Person - Parent/Guardian
                 *********************************************************************************************/

                case Constants.ROLE_PARENT_GUARDIAN:
                    {
                        renderMenuListItem(ref writer, ServiceAuthorizationRequestResponses.MENU_ID_URL_RESPOND, ServiceAuthorizationRequestResponses.SEL_LABEL_RESPOND, ServiceAuthorizationRequestResponses.URL_MANAGE_RESPONSES);

                        renderTopMenuListStart(ref writer, @"Patient Goals");

                        foreach (var urlSet in PatientGoalsProgressIndividualGoals.generateParentPortalPatientGoalsProgressReviewUrlSetFromUInfo(uInfo))
                        {
                            renderMenuListItem(ref writer
                                                , urlSet.menuID
                                                , urlSet.label
                                                , urlSet.regularPageUrl
                                                , true
                                                , false
                                                , true);
                        }

                        renderTopMenuListEnd(ref writer);

                        break;
                    }


                /*********************************************************************************************
                 *                          Third Party Person - ORP Professional
                 *********************************************************************************************/

                case Constants.ROLE_ORP_PROFFESIONAL:
                    {
                        renderMenuListItem(ref writer, ServiceAuthorizationRequestResponses.MENU_ID_URL_RESPOND, ServiceAuthorizationRequestResponses.SEL_LABEL_RESPOND, ServiceAuthorizationRequestResponses.URL_MANAGE_RESPONSES);
                        break;
                    }


                /*********************************************************************************************
                 *                                   Client Role - Practitioner
                 *********************************************************************************************/

                case Constants.ROLE_LEA_PROVIDER:
                    {

                        if (ServiceJournals.isPracSomeoneWhoCanRecordServiceRecords(ref rd))

                        {

                            /*------------------------
                             * Care Plan
                             *------------------------*/

                            renderTopMenuListStart(ref writer, PlanWriterRecords.SEL_LABEL);
                            renderMenuListItem(ref writer, "planwritemanagecareplanslink", PlanWriterPlans.SEL_LABEL_MANAGE, PlanWriterPlans.URL_USER_ALL_MANAGE_PLANS);
                            renderTopMenuListEnd(ref writer);

                            /*------------------------
                             * Caseloads
                             *------------------------*/

                            renderMenuListItem(ref writer, PractitionerCaseloadMembers.MENU_ID, PractitionerCaseloadMembers.SEL_LABEL_PRAC, PractitionerCaseloadMembers.URL_USER_ALL);

                            /**** Manage Telehealth ****/

                            if (TeleHealthSessions.clientHasAccess(rd.wu))
                            {
                                renderMenuListItem(ref writer
                                                     , TeleHealthSessions.MENU_LINK_MANAGE
                                                     , TeleHealthSessions.SEL_LABEL_MANAGE
                                                     , TeleHealthSessions.URL_CLIENT_PROV_MANAGE);
                            }

                            /**** Manage TeleIEP ****/

                            if (TeleIEPSessions.clientHasAccess(rd.wu))
                            {

                                renderMenuListItem(ref writer
                                                    , TeleIEPSessions.MENU_LINK_MANAGE
                                                    , TeleIEPSessions.SEL_LABEL_MANAGE
                                                    , TeleIEPSessions.URL_CLIENT_MANAGE);
                            }


                        }

                        if (ServiceJournals.isPracSomeoneWhoCanManagePatientServices(ref rd))
                        {

                            /*------------------------
                             * Manage Patient Services
                             *------------------------*/

                            renderTopMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_PATIENT_SERVICES);

                            /*------------------------
                             * Respond to service
                             * authorization requests
                             *------------------------*/

                            if (ServiceAuthorizationCommon.canPracAccessServiceAuthorizationRequestsManageSystem(ref rd))
                            {
                                renderMenuListItem(ref writer, ServiceAuthorizationRequestResponses.MENU_ID_URL_RESPOND, ServiceAuthorizationRequestResponses.SEL_LABEL_RESPOND, ServiceAuthorizationRequestResponses.URL_MANAGE_RESPONSES);
                            }


                            /**** Patient Profiles ****/

                            if (ServiceJournals.isPracSomeoneWhoCanManageSvcDescr(ref rd))
                            {
                                //renderMenuListItem(ref writer, "managesvcdescrsmanagelink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_MANAGE, ServiceJournals.URL_PROV_MANAGE_SERVICE_DESCRIPTIONS_MANAGE);

                                /**** Old Patient Profiles Menu -- Render hidden to preserve compatability ****/

                                renderSubMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION, true);
                                renderMenuListItem(ref writer, @"managesvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_ADD_NEW_OR_EDIT, ServiceJournals.URL_PROV_SAVE_SERVICE_DESCRIPTION, true, true);
                                renderMenuListItem(ref writer, @"editdelsvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_EDIT_DELETE, ServiceJournals.URL_PROV_EDIT_DEL_SERVICE_DESCRIPTION, true, true);
                                renderMenuListItem(ref writer, @"viewsvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_VIEW, ServiceJournals.URL_PROV_SERVICE_DESCRIPTIONS_VIEW, true, true);
                                renderSubMenuListEnd(ref writer);
                            }


                            /**** Orders ****/

                            if (ServiceJournals.isPracSomeoneWhoCanManageOrders(ref rd))
                            {
                                //renderMenuListItem(ref writer, "manageordersmanagelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE, ServiceJournals.URL_PROV_MANAGE_ORDERS_NOTE_TEMPLATE_MANAGE);
                                renderMenuListItem(ref writer, "manageordersmanagelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE, ORPDocuments.URL_USER_ALL_MANAGE);

                                /**** Old Orders Menu -- Render hidden to preserve compatability ****/

                                renderSubMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_ORDERS, true);
                                renderMenuListItem(ref writer, @"manageordersnewlink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_NEW, ServiceJournals.URL_PROV_MANAGE_ORDERS_NOTE_TEMPATE_NEW, true, true);
                                renderMenuListItem(ref writer, @"manageordersviewlink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_VIEW, ServiceJournals.URL_PROV_MANAGE_ORDERS_NOTE_TEMPATE_VIEW, true, true);
                                renderMenuListItem(ref writer, @"manageorderseditdeletelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_EDIT_DELETE, ServiceJournals.URL_PROV_MANAGE_ORDERS_NOTE_TEMPATE_EDIT_DELETE, true, true);
                                renderSubMenuListEnd(ref writer);

                            }

                            /**** Request Name ****/

                            writer.Write(@"<li><a id=""{0}"" target=""_blank"" href=""{1}"">{2}</a></li>"
                                       , Constants.REQUEST_OPR_DOC_STD_NAME_MENU_ID
                                       , Constants.REQUEST_ORP_DOC_STD_NAME_URL
                                       , Constants.REQUEST_ORP_DOC_STD_NAME_LBL);

                            renderTopMenuListEnd(ref writer);

                        }

                        if (ServiceJournals.isPracSomeoneWhoCanRecordServiceRecords(ref rd))
                        {
                            /*------------------------
                             * Patients
                             *------------------------*/

                            renderTopMenuListStart(ref writer, @"Patients");
                            renderMenuListItem(ref writer, Patients.MENU_ID_MANAGE, Patients.SEL_LABEL_MANAGE, Patients.URL_USER_ALL_MANAGE);

                            /**** Patient Referrals ****/

                            if (PractitionerPatientReferrals.userCanAccessManageScreen(rd) == true)
                            {
                                renderMenuListItem(ref writer, PractitionerPatientReferrals.MENU_ID_MANAGE, PractitionerPatientReferrals.SEL_LABEL_MANAGE, PractitionerPatientReferrals.URL_USER_REF_ALL_MANAGE);
                            }

                            /**** Missing Treatments ****/

                            renderMenuListItem(ref writer
                                                 , MissingServicesTreatmentsSummary.MENU_ID_MANAGE
                                                 , MissingServicesTreatmentsCommon.SEL_LABEL
                                                 , MissingServicesTreatmentsSummary.URL_MANAGE);

                            renderTopMenuListEnd(ref writer);
                        }

                        if (ServiceJournals.isPracSomeoneWhoWouldUseJournal(ref rd))
                        {

                            /*------------------------
                             * Service Journals
                             *------------------------*/

                            renderTopMenuListStart(ref writer, ServiceJournals.SEL_LABEL);
                            writer.Write(@"<li><a id=""svcjournalrecordproclink""   href=""" + MBA.HttpApplication.createLink(ServiceJournals.URL_USER_ALL_OPEN_NEW, true, new NameValue(ServiceJournals.PARAM_EVENT_TYPE_ID, ServiceJournals.VAL_EVENT_TYPE_REC_PROC)) + @""">" + ServiceJournals.SEL_LABEL_RECORD_PROC + @"</a></li>");
                            renderTopMenuListEnd(ref writer);
                        }

                        if (ServiceJournals.isPracSomeoneWhoCanRecordServiceRecords(ref rd))
                        {
                            /*------------------------
                             * Service Records
                             * Complete Menu
                             *------------------------*/

                            renderTopMenuListStart(ref writer, @"Service Records");

                            /* Replaces ServiceRecords.MENU_LINK_SVC_REC_SAVE_NEW_ALL and ServiceRecords.URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC*/

                            renderMenuListItem(ref writer
                                               , ServiceRecords.MENU_LINK_SVC_REC_SAVE_NEW_ALL
                                               , ServiceRecords.SEL_LABEL_SVC_REC_SAVE_NEW_ALL
                                               , ServiceRecords.URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC);

                            renderMenuListItem(ref writer
                               , "viewsvcrecslink" /* Replacing view with manage*/
                               , ServiceRecords.SEL_LABEL_MANAGE
                               , ServiceRecords.URL_USER_ALL_SVC_RECS_MANAGE);

                            /* Preserve add new as a hidden menu item... Note: The generateURLProvEnter logic adds the token so we call the renderMenuListItem method with the private field set to false */
                            renderMenuListItem(ref writer, @"addnewsvcreclink", "Record New", Spedmon.ServiceRecordEntryExitRequest.GenerateUrlClientProvEnter(0), false, true);

                            //  writer.Write(@"<li><a id=""addnewsvcreclink""   href=""" + Spedmon.ServiceRecordEntryExitRequest.GenerateUrlClientProvEnter(0) + @""">Record New</a></li>");
                            //  writer.Write(@"<li><a id=""batchnewsvcreclink"" href=""" + Spedmon.ServiceRecordEntryExitRequest.GenerateUrlClientProvEnter(1) + @""">Record Multiple New</a></li>");
                            //  writer.Write(@"<li><a id=""caseloadandgroupsvcrec"" href=""" + MBA.HttpApplication.createLink("client_prov_svcrec_caseload_or_group_save.aspx", true) + @""">Record Services for My Caseload or Patient Groups</a></li>");

                            //writer.Write(@"<li><a id=""viewsvcrecslink""    href=""" + MBA.HttpApplication.createLink("client_prov_svcrec_view.aspx", true) + @""">View Service Records</a></li>");

                            //writer.Write(@"<li><a id=""editdelsvcrecslink"" href=""" + MBA.HttpApplication.createLink("client_prov_svcrec_edit_delete.aspx", true) + @""">" + ServiceRecords.SEL_LABEL_EDIT_SVCREC + @"</a></li>");
                            writer.Write(@"<li><a id=""viewsvcsrendcomponepat"" href=""" + MBA.HttpApplication.createLink(ServiceRecords.PAGE_CLIENT_ALL_SVC_COMP_REPT, true) + @""">" + ServiceRecords.SEL_LABEL_PLAN_SVC_COMP_REPT + @"</a></li>");

                            // writer.Write(@"<li><a id=""svcnotepreflink""    href=""" + Spedmon.ServiceNotesPreferenceRequest.GenerateUrlClientProv(ServiceNoteCommon.NoteRequestMode.LOAD) + @""">Where Do I Keep My Progress Notes</a></li>");
                            // writer.Write(@"<li><a id=""viewsvcrecssvcnoteslink""  href=""" + MBA.HttpApplication.createLink("client_prov_svcrec_svcnote_view.aspx", true) + @""">View My Progress Notes I Have Saved in SpEdCare</a></li>");

                            // TODO: Uncomment when we are read to support practitioner trans
                            //writer.Write(@"<li><a id=""processincomingroutesheetslink"" href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_CLIENT_PROV_PROCESS_INCOMING_SHEET,  true) + @""">" + TransportationMgmtRecords.SEL_LABEL_PROCESS_INCOMING_SHEET + @"</a></li>");

                            /* Vision and hearing screening */

                            renderMenuListItem(ref writer, ServiceRecords.MENU_LINK_VISION_HEARING_SCREEN, ServiceRecords.SEL_LABEL_VISION_HEARING_SCREEN, ServiceRecords.URL_USER_ALL_VISION_AND_HEARING_SCREEN);

                            renderTopMenuListEnd(ref writer);
                        }

                        else
                        {

                            /*------------------------
                              * Service Records
                              * HA & LVN
                              *------------------------*/

                            renderTopMenuListStart(ref writer, @"Service Records");

                            renderMenuListItem(ref writer
                                      , "viewsvcrecslink" /* Replacing view with manage*/
                                      , ServiceRecords.SEL_LABEL_MANAGE
                                      , ServiceRecords.URL_USER_ALL_SVC_RECS_MANAGE);

                            //writer.Write(@"<li><a id=""viewsvcrecslink""    href=""" + MBA.HttpApplication.createLink("client_prov_svcrec_view.aspx", true) + @""">View Service Records</a></li>");
                            //writer.Write(@"<li><a id=""viewsvcrecssvcnoteslink""  href=""" + MBA.HttpApplication.createLink("client_prov_svcrec_svcnote_view.aspx", true) + @""">View My Progress Notes I Have Saved in SpEdCare</a></li>");

                            /* Vision and hearing screening */

                            renderMenuListItem(ref writer, ServiceRecords.MENU_LINK_VISION_HEARING_SCREEN, ServiceRecords.SEL_LABEL_VISION_HEARING_SCREEN, ServiceRecords.URL_USER_ALL_VISION_AND_HEARING_SCREEN);

                            renderTopMenuListEnd(ref writer);

                        }

                        /**** Practice Office ****/

                        renderPracticeOfficeMenu(ref writer, rd);

                        /**** Supervision Tracking ****/

                        if (PractitionerDirectSupervisors.isPracSomeoneWhoCanManageDirectSupervisionTracking(ref rd))
                        {
                            renderManagePractitionerSupervisionMenu(ref writer, rd);
                        }

                        /* Review and approve service records */

                        renderServiceRecordReviewMenu(ref writer, rd, true);

                        /* Department head options */

                        if (Practitioners.isPracADepartmentHead(ref rd))
                        {

                            /**** Dept Svcs Review ****/

                            renderMenuListItem(ref writer, PractitionerDepartmentServicesReview.MENU_ID, PractitionerDepartmentServicesReview.SEL_LABEL, PractitionerDepartmentServicesReview.URL_USER_ALL_RPT);

                            /**** Efficiency ****/

                            renderMenuListItem(ref writer, PractitionersEfficiency.MENU_ID, PractitionersEfficiency.SEL_LABEL, PractitionersEfficiency.URL_USER_ALL_RPT);

                        }


                        break;

                    }

                /*********************************************************************************************
                 *                            Client Role - Transportation Manager
                 *********************************************************************************************/

                case Constants.ROLE_TRANSPORTATION_MANAGER:
                    {


                        /*------------------------
                         * Patients
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Patients");
                        renderMenuListItem(ref writer, Patients.MENU_ID_MANAGE, Patients.SEL_LABEL_MANAGE, Patients.URL_USER_ALL_MANAGE);
                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Sites 
                         *------------------------*/

                        renderManageSitesMenu(ref writer, rd);

                        /*------------------------
                         * Transportation
                         *------------------------*/

                        renderTopMenuListStart(ref writer, TransportationMgmtRecords.SEL_LABEL);
                        writer.Write(@"<li><a id=""managetranspatientsrouteslink""  href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_USER_ALL_MANAGE_PATIENTS_AND_ROUTES, true) + @""">" + TransportationMgmtRecords.SEL_LABEL_MANAGE + @"</a></li>");
                        writer.Write(@"<li><a id=""processincomingroutesheetslink"" href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_CLIENT_COOR_PROCESS_INCOMING_SHEET, true) + @""">" + TransportationMgmtRecords.SEL_LABEL_PROCESS_INCOMING_SHEET + @"</a></li>");
                        writer.Write(@"<li><a id=""manageheldtranslink""            href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_USER_ALL_MANAGE_SERVICE_RECORDS, true) + @""">" + TransportationMgmtRecords.SEL_LABEL_MANAGE_SERVICE_RECORDS + @"</a></li>");
                        renderTopMenuListEnd(ref writer);

                        break;


                    }

                /*********************************************************************************************
                 *                                  Client Role - File Manager
                 *        Note: This role can only upload and view files so that is why there are no items
                 *********************************************************************************************/

                case Constants.ROLE_LEA_FILE_MANAGER:
                    {
                        break;
                    }

                /*********************************************************************************************
                 *                                  Client Role - CRCS Staff          
                 *********************************************************************************************/

                case Constants.ROLE_LEA_CRCS_STAFF:
                    {
                        /*------------------------
                         * CRCS
                         *------------------------*/

                        renderMenuListItem(ref writer, CrcsCommon.MENU_ID_MANAGE, CrcsCommon.SEL_LABEL_MANAGE, CrcsCommon.URL_MANAGE);
                        break;
                    }

                /*********************************************************************************************
                 *                              Client Role - LEA Input Staff
                 *********************************************************************************************/

                case Constants.ROLE_LEA_INPUT_STAFF:  // done - no RMTS menu options changes for this role
                    {

                        /*------------------------
                         * Patients
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Patients");
                        renderMenuListItem(ref writer, Patients.MENU_ID_MANAGE, Patients.SEL_LABEL_MANAGE, Patients.URL_USER_ALL_MANAGE);

                        if (PractitionerPatientReferrals.userCanAccessManageScreen(rd) == true)
                        {
                            renderMenuListItem(ref writer, PractitionerPatientReferrals.MENU_ID_MANAGE, PractitionerPatientReferrals.SEL_LABEL_MANAGE, PractitionerPatientReferrals.URL_USER_REF_ALL_MANAGE);
                        }

                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Manage Patient Services
                         *------------------------*/

                        renderTopMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_PATIENT_SERVICES);

                        /**** Service Authorization Requests ****/

                        renderMenuListItem(ref writer, ServiceAuthorizationRequestResponses.MENU_ID_URL_RESPOND, ServiceAuthorizationRequestResponses.SEL_LABEL_RESPOND, ServiceAuthorizationRequestResponses.URL_MANAGE_RESPONSES);


                        /**** Manage Telehealth ****/

                        if (TeleHealthSessions.clientHasAccess(rd.wu))
                        {
                            renderMenuListItem(ref writer
                                                , TeleHealthSessions.MENU_LINK_MANAGE
                                                , TeleHealthSessions.SEL_LABEL_MANAGE
                                                , TeleHealthSessions.URL_CLIENT_COOR_MANAGE);
                        }

                        /**** Manage TeleIEP ****/

                        if (TeleIEPSessions.clientHasAccess(rd.wu))
                        {

                            renderMenuListItem(ref writer
                                                , TeleIEPSessions.MENU_LINK_MANAGE
                                                , TeleIEPSessions.SEL_LABEL_MANAGE
                                                , TeleIEPSessions.URL_CLIENT_MANAGE);

                        }

                        /**** Patient Profiles ****/

                        //renderMenuListItem(ref writer, "managesvcdescrsmanagelink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_MANAGE, ServiceJournals.URL_COOR_MANAGE_SERVICE_DESCRIPTIONS_MANAGE);

                        /**** Orders ****/

                        //renderMenuListItem(ref writer, "manageordersmanagelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE, ServiceJournals.URL_COOR_MANAGE_ORDERS_NOTE_TEMPLATE_MANAGE);
                        renderMenuListItem(ref writer, "manageordersmanagelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE, ORPDocuments.URL_USER_ALL_MANAGE);

                        /**** Request Name ****/

                        writer.Write(@"<li><a id=""{0}"" target=""_blank"" href=""{1}"">{2}</a></li>"
                                                 , Constants.REQUEST_OPR_DOC_STD_NAME_MENU_ID
                                                 , Constants.REQUEST_ORP_DOC_STD_NAME_URL
                                                 , Constants.REQUEST_ORP_DOC_STD_NAME_LBL);

                        /**** Old Patient Profiles Menu -- Render hidden to preserve compatability ****/

                        renderSubMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION, true);
                        renderMenuListItem(ref writer, @"managesvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_ADD_NEW_OR_EDIT, ServiceJournals.URL_COOR_SAVE_SERVICE_DESCRIPTION, true, true);
                        renderMenuListItem(ref writer, @"editdelsvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_EDIT_DELETE, ServiceJournals.URL_COOR_EDIT_DEL_SERVICE_DESCRIPTION, true, true);
                        renderMenuListItem(ref writer, @"viewsvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_VIEW, ServiceJournals.URL_COOR_SERVICE_DESCRIPTIONS_VIEW, true, true);
                        renderSubMenuListEnd(ref writer);

                        /**** Old Orders Menu -- Render hidden to preserve compatability ****/

                        renderSubMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_ORDERS, true);
                        renderMenuListItem(ref writer, @"manageordersnewlink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_NEW, ServiceJournals.URL_COOR_MANAGE_ORDERS_NOTE_TEMPATE_NEW, true, true);
                        renderMenuListItem(ref writer, @"manageordersviewlink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_VIEW, ServiceJournals.URL_COOR_MANAGE_ORDERS_NOTE_TEMPATE_VIEW, true, true);
                        renderMenuListItem(ref writer, @"manageorderseditdeletelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_EDIT_DELETE, ServiceJournals.URL_COOR_MANAGE_ORDERS_NOTE_TEMPATE_EDIT_DELETE, true, true);
                        renderSubMenuListEnd(ref writer);

                        renderTopMenuListEnd(ref writer);


                        /*------------------------
                         * Practitioners
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Practitioners");
                        renderMenuListItem(ref writer, Practitioners.MENU_ID_MANAGE, Practitioners.SEL_LABEL_MANAGE, Practitioners.URL_USER_ALL_MANAGE);

                        /*------------------------
                         * Caseloads
                         *------------------------*/

                        renderMenuListItem(ref writer, PractitionerCaseloadMembers.MENU_ID, PractitionerCaseloadMembers.SEL_LABEL_NON_PRAC, PractitionerCaseloadMembers.URL_USER_ALL);

                        /**** Supervision Tracking ****/
                        renderManagePractitionerSupervisionMenu(ref writer, rd);

                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Reports
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Reports");
                        writer.Write(@"<li><a id=""rptpracrevlink""         href=""" + MBA.HttpApplication.createLink("client_coor_rpt_prac_review.aspx", true) + @""">Practitioner Review</a></li>");
                        renderMenuListItem(ref writer, "rptmissingassessmentsdetailslnk", Claims.SEL_LABEL_RPT_MISSING_ASSESSMENTS_POT_REIMBURSEMENT_DETAILS, Claims.URL_CLIENT_LEA_COORD_RPT_MISSING_ASSESSMENTS_WITH_POT_REIMBURSEMENT_DETAILS);
                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Service Records
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Service Records");
                        writer.Write(@"<li><a id=""addnewsvcreclink""     href=""" + MBA.HttpApplication.createLink("client_coor_svcrec_save.aspx", true) + @""">Record New Service Records</a></li>");
                        writer.Write(@"<li><a id=""batchnewsvcreclink""   href=""" + MBA.HttpApplication.createLink("client_coor_svcrec_batch_save.aspx", true) + @""">Record Multiple New Service Records</a></li>");
                        /* Replaces renderMenuListItem(ref writer, ServiceRecords.MENU_LINK_SVC_REC_SAVE_NEW_ALL_NON_PRAC, ServiceRecords.SEL_LABEL_SVREC_NON_PRAC, ServiceRecords.URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC); */


                        renderMenuListItem(ref writer
                                            , ServiceRecords.MENU_LINK_SVC_REC_SAVE_NEW_ALL_NON_PRAC
                                            , ServiceRecords.SEL_LABEL_SVREC_NON_PRAC
                                            , ServiceRecords.URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC);

                        /* Vision and hearing screening */
                        renderMenuListItem(ref writer, ServiceRecords.MENU_LINK_VISION_HEARING_SCREEN, ServiceRecords.SEL_LABEL_VISION_HEARING_SCREEN, ServiceRecords.URL_USER_ALL_VISION_AND_HEARING_SCREEN);

                        //writer.Write(@"<li><a id=""caseloadandgroupsvcreclink""       href=""" + MBA.HttpApplication.createLink(ServiceRecords.URL_CLIENT_COOR_SVCREC_CSLD_OR_GRP_SEL_PRAC, true)   + @""">" + ServiceRecords.SEL_LABEL_SVREC_NON_PRAC + @"</a></li>");
                        //writer.Write(@"<li><a id=""viewsvcrecslink""      href=""" +  MBA.HttpApplication.createLink("client_coor_svcrec_view.aspx",        true) + @""">View Service Records</a></li>");
                        renderMenuListItem(ref writer
                                            , "viewsvcrecslink" /* Replacing view with manage*/
                                            , ServiceRecords.SEL_LABEL_MANAGE
                                            , ServiceRecords.URL_USER_ALL_SVC_RECS_MANAGE);

                        // writer.Write(@"<li><a id=""viewsvcrecssvcnoteslink""  href=""" + MBA.HttpApplication.createLink("client_coor_svcrec_svcnote_view.aspx", true) + @""">View Progress Notes Saved in SpEdCare</a></li>");
                        //writer.Write(@"<li><a id=""editdelsvcrecslink""   href=""" +  MBA.HttpApplication.createLink("client_coor_svcrec_edit_delete.aspx", true) + @""">" + ServiceRecords.SEL_LABEL_EDIT_SVCREC + @"</a></li>");

                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Sites 
                         *------------------------*/

                        renderManageSitesMenu(ref writer, rd);

                        /*------------------------
                         * Transportation
                         *------------------------*/

                        renderTopMenuListStart(ref writer, TransportationMgmtRecords.SEL_LABEL);
                        writer.Write(@"<li><a id=""managetranspatientsrouteslink""  href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_USER_ALL_MANAGE_PATIENTS_AND_ROUTES, true) + @""">" + TransportationMgmtRecords.SEL_LABEL_MANAGE + @"</a></li>");
                        writer.Write(@"<li><a id=""processincomingroutesheetslink"" href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_CLIENT_COOR_PROCESS_INCOMING_SHEET, true) + @""">" + TransportationMgmtRecords.SEL_LABEL_PROCESS_INCOMING_SHEET + @"</a></li>");
                        writer.Write(@"<li><a id=""manageheldtranslink""            href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_USER_ALL_MANAGE_SERVICE_RECORDS, true) + @""">" + TransportationMgmtRecords.SEL_LABEL_MANAGE_SERVICE_RECORDS + @"</a></li>");
                        renderTopMenuListEnd(ref writer);


                        /*------------------------
                         * Users
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Users");
                        writer.Write(@"<li><a id=""addnewuserlink""        href=""" + MBA.HttpApplication.createLink("client_coor_user_save.aspx", true) + @""">Record New User</a></li>");
                        writer.Write(@"<li><a id=""viewuserlink""          href=""" + MBA.HttpApplication.createLink("client_coor_user_view.aspx", true) + @""">View Users</a></li>");
                        writer.Write(@"<li><a id=""editdeluserslink""      href=""" + MBA.HttpApplication.createLink("client_coor_user_edit_delete.aspx", true) + @""">Edit or Delete Users</a></li>");
                        renderTopMenuListEnd(ref writer);


                        break;



                    }

                /*********************************************************************************************
                 *                                Client Role - LEA Coordinators
                 *********************************************************************************************/

                case Constants.ROLE_LEA_CORDINATOR:
                    // done - removed RmtsParticipationRosters.URL_MANAGE, RmtsMoments.URL_MANAGE, RmtsMoments.URL_REVIEW
                    // done - add new menu
                    {

                        /*------------------------
                         * My organization
                         *------------------------*/

                        renderSubMenuListStart(ref writer, @"My Organization");

                        renderMenuListItem(ref writer
                                            , Clients.MENU_ID_MY_ORGANIZATION
                                            , Clients.SEL_LABEL_MY_ORGANIZATION
                                            , Clients.URL_USER_ALL_MY_ORGANIZATION);

                        renderMenuListItem(ref writer
                                      , ClientInvoices.MENU_LNK
                                      , ClientInvoices.SEL_LABEL_MANAGE
                                      , ClientInvoices.URL_MANAGE);

                        /*------------------------
                         * Sites
                         *------------------------*/

                        renderManageSitesMenu(ref writer, rd);

                        renderSubMenuListEnd(ref writer);

                        /*---------------- --------
                         * Care Plans
                         *------------------------*/

                        renderTopMenuListStart(ref writer, PlanWriterRecords.SEL_LABEL);
                        renderMenuListItem(ref writer, "planwritemanagecareplanslink", PlanWriterPlans.SEL_LABEL_MANAGE, PlanWriterPlans.URL_USER_ALL_MANAGE_PLANS);
                        renderTopMenuListEnd(ref writer);


                        /*------------------------
                         * Patients
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Patients");
                        renderMenuListItem(ref writer, Patients.MENU_ID_MANAGE, Patients.SEL_LABEL_MANAGE, Patients.URL_USER_ALL_MANAGE);

                        renderMenuListItem(ref writer
                                            , PatientParentMcalConsents.MENU_LNK_USER_ALL_MANAGE
                                            , PatientParentMcalConsents.SEL_LABEL_MANAGE
                                            , PatientParentMcalConsents.URL_USER_ALL_MANAGE);

                        renderMenuListItem(ref writer
                                                , PatientsCurrentMcalBenefits.MENU_LNK_USER_ALL_MANAGE
                                                , PatientsCurrentMcalBenefits.SEL_LABEL_MANAGE
                                                , PatientsCurrentMcalBenefits.URL_MANAGE);

                        /**** Missing Treatments ****/

                        renderMenuListItem(ref writer
                                             , MissingServicesTreatmentsSummary.MENU_ID_MANAGE
                                             , MissingServicesTreatmentsCommon.SEL_LABEL
                                             , MissingServicesTreatmentsSummary.URL_MANAGE);

                        renderMenuListItem(ref writer
                                         , PotentialLostReimbursements.MENU_ID_MANAGE_HOLDS
                                         , PotentialLostReimbursements.SEL_MANAGE_HOLDS
                                         , PotentialLostReimbursements.URL_MANAGE_HOLDS);

                        /* CYBHI Holds */

                        renderMenuListItem(ref writer
                                           , Spedmon.CYBHIHoldsManageCommon.MENU_ID_MANAGE_HOLDS
                                           , Spedmon.CYBHIHoldsManageCommon.SEL_MANAGE_HOLDS
                                           , Spedmon.CYBHIHoldsManageCommon.URL_MANAGE_HOLDS);

                        /* Manage patients with missing info*/

                        renderMenuListItem(ref writer
                                           , Spedmon.PatientsWithMissingInfo.MENU_ID_MANAGE
                                           , Spedmon.PatientsWithMissingInfo.SEL_LABEL_MANAGE
                                           , Spedmon.PatientsWithMissingInfo.URL_MANAGE);

                        /* Patient Insurance Info Public Requests Responses Manage */

                        renderMenuListItem(ref writer
                                            , Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.MENU_ID_MANAGE
                                            , Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.SEL_LABEL_MANAGE
                                            , Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.URL_MANAGE);


                        /* Bulk manage patient insurance */

                        renderMenuListItem(ref writer
                                            , PatientInsuranceCarriers.MENU_LNK_USER_ALL_MANAGE
                                            , PatientInsuranceCarriers.PAGE_MANAGE_SEL_LABEL
                                            , PatientInsuranceCarriers.URL_PAGE_MANAGE);


                        if (PractitionerPatientReferrals.userCanAccessManageScreen(rd) == true)
                        {
                            renderMenuListItem(ref writer, PractitionerPatientReferrals.MENU_ID_MANAGE, PractitionerPatientReferrals.SEL_LABEL_MANAGE, PractitionerPatientReferrals.URL_USER_REF_ALL_MANAGE);
                        }                        

                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Manage Patient Services
                         *------------------------*/

                        renderTopMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_PATIENT_SERVICES);

                        /**** Service Authorization Requests ****/

                        renderMenuListItem(ref writer, ServiceAuthorizationRequestResponses.MENU_ID_URL_RESPOND, ServiceAuthorizationRequestResponses.SEL_LABEL_RESPOND, ServiceAuthorizationRequestResponses.URL_MANAGE_RESPONSES);


                        /**** Manage Telehealth ****/

                        if (TeleHealthSessions.clientHasAccess(rd.wu))
                        {
                            renderMenuListItem(ref writer
                                                , TeleHealthSessions.MENU_LINK_MANAGE
                                                , TeleHealthSessions.SEL_LABEL_MANAGE
                                                , TeleHealthSessions.URL_CLIENT_COOR_MANAGE);
                        }

                        /**** Manage TeleIEP ****/

                        if (TeleIEPSessions.clientHasAccess(rd.wu))
                        {

                            renderMenuListItem(ref writer
                                                , TeleIEPSessions.MENU_LINK_MANAGE
                                                , TeleIEPSessions.SEL_LABEL_MANAGE
                                                , TeleIEPSessions.URL_CLIENT_MANAGE);

                        }

                        /**** Patient Profiles ****/

                        //renderMenuListItem(ref writer, "managesvcdescrsmanagelink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_MANAGE, ServiceJournals.URL_COOR_MANAGE_SERVICE_DESCRIPTIONS_MANAGE);

                        /**** Orders ****/

                        //renderMenuListItem(ref writer, "manageordersmanagelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE, ServiceJournals.URL_COOR_MANAGE_ORDERS_NOTE_TEMPLATE_MANAGE);
                        renderMenuListItem(ref writer, "manageordersmanagelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE, ORPDocuments.URL_USER_ALL_MANAGE);

                        /**** Request Name ****/

                        writer.Write(@"<li><a id=""{0}"" target=""_blank"" href=""{1}"">{2}</a></li>"
                                              , Constants.REQUEST_OPR_DOC_STD_NAME_MENU_ID
                                              , Constants.REQUEST_ORP_DOC_STD_NAME_URL
                                              , Constants.REQUEST_ORP_DOC_STD_NAME_LBL);

                        /**** Old Patient Profiles Menu -- Render hidden to preserve compatability ****/

                        renderSubMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION, true);
                        renderMenuListItem(ref writer, @"managesvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_ADD_NEW_OR_EDIT, ServiceJournals.URL_COOR_SAVE_SERVICE_DESCRIPTION, true, true);
                        renderMenuListItem(ref writer, @"editdelsvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_EDIT_DELETE, ServiceJournals.URL_COOR_EDIT_DEL_SERVICE_DESCRIPTION, true, true);
                        renderMenuListItem(ref writer, @"viewsvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_VIEW, ServiceJournals.URL_COOR_SERVICE_DESCRIPTIONS_VIEW, true, true);
                        renderSubMenuListEnd(ref writer);

                        /**** Old Orders Menu -- Render hidden to preserve compatability ****/

                        renderSubMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_ORDERS, true);
                        renderMenuListItem(ref writer, @"manageordersnewlink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_NEW, ServiceJournals.URL_COOR_MANAGE_ORDERS_NOTE_TEMPATE_NEW, true, true);
                        renderMenuListItem(ref writer, @"manageordersviewlink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_VIEW, ServiceJournals.URL_COOR_MANAGE_ORDERS_NOTE_TEMPATE_VIEW, true, true);
                        renderMenuListItem(ref writer, @"manageorderseditdeletelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_EDIT_DELETE, ServiceJournals.URL_COOR_MANAGE_ORDERS_NOTE_TEMPATE_EDIT_DELETE, true, true);
                        renderSubMenuListEnd(ref writer);



                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Practitioners
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Practitioners");
                        renderMenuListItem(ref writer, Practitioners.MENU_ID_MANAGE, Practitioners.SEL_LABEL_MANAGE, Practitioners.URL_USER_ALL_MANAGE);

                        /**** Caseloads ****/
                        renderMenuListItem(ref writer, PractitionerCaseloadMembers.MENU_ID, PractitionerCaseloadMembers.SEL_LABEL_NON_PRAC, PractitionerCaseloadMembers.URL_USER_ALL);

                        /**** Supervision Tracking ****/
                        renderManagePractitionerSupervisionMenu(ref writer, rd);

                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Reports
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Reports");

                        renderSubMenuListStart(ref writer, @"Financial");
                        writer.Write(@"<li><a id=""rptclmpaidbycheckdate""  href=""" + MBA.HttpApplication.createLink("client_all_rpt_claims_paid.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_WD_1P + @"</a></li>");
                        writer.Write(@"<li><a id=""rptclmpaidbyservicedate""         href=""" + MBA.HttpApplication.createLink("client_coor_rpt_claims_paid_by_dos.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_1P + @"</a></li>");
                        writer.Write(@"<li><a id=""rptclmpaidbycheckdatecompared""   href=""" + MBA.HttpApplication.createLink("client_coor_rpt_claims_paid_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_WD_2P + @"</a></li>");
                        writer.Write(@"<li><a id=""rptclmpaidbyservicedatecompared"" href=""" + MBA.HttpApplication.createLink("client_coor_rpt_claims_paid_by_dos_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_2P + @"</a></li>");
                        writer.Write(@"<li><a id=""rptcombined1on1bysvcdate""        href=""" + MBA.HttpApplication.createLink("client_coor_rpt_combined_1on1_by_svc_date.aspx", true) + @""">By Patient for One Practitioner by Service Date</a></li>");
                        writer.Write(@"<li><a id=""rptcombined1on1bypmtdate""        href=""" + MBA.HttpApplication.createLink("client_coor_rpt_combined_1on1_by_pmt_date.aspx", true) + @""">By Patient for One Practitioner by Payment Date</a></li>");
                        writer.Write(@"<li><a id=""rptbyeligpatdos2p""               href=""" + MBA.HttpApplication.createLink("client_coor_rpt_claims_paid_by_elig_pat_dos_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_ELIG_PAT_SD_2P + @"</a></li>");
                        renderSubMenuListEnd(ref writer);

                        /* Program health */
                        renderMenuListItem(ref writer, LeaBopHealthCommon.MENU_ID_MANAGE, LeaBopHealthCommon.SEL_LABEL_MANAGE, LeaBopHealthCommon.URL_MANAGE);


                        /* CDE Compliance */
                        renderMenuListItem(ref writer, CdeComplianceCommon.MENU_ID_MANAGE, CdeComplianceCommon.SEL_LABEL_MANAGE, CdeComplianceCommon.URL_MANAGE);

                        /* CYBHI Program Health */
                        renderCybhiProgramHealthMenuOptions(ref writer, rd);

                        renderMenuListItem(ref writer, "rptmissingassessmentsdetailslnk", Claims.SEL_LABEL_RPT_MISSING_ASSESSMENTS_POT_REIMBURSEMENT_DETAILS, Claims.URL_CLIENT_LEA_COORD_RPT_MISSING_ASSESSMENTS_WITH_POT_REIMBURSEMENT_DETAILS);

                        renderMenuListItem(ref writer, Practitioners.MENU_ID_TATTLE_TALE_RPT, Practitioners.SEL_LABEL_RPT_TATTLETALE, Practitioners.URL_LEA_COORD_RPT_TATTLETALE);

                        /**** Dept Svcs Review ****/

                        renderMenuListItem(ref writer, PractitionerDepartmentServicesReview.MENU_ID, PractitionerDepartmentServicesReview.SEL_LABEL, PractitionerDepartmentServicesReview.URL_USER_ALL_RPT);

                        /**** Efficiency ****/

                        renderMenuListItem(ref writer, PractitionersEfficiency.MENU_ID, PractitionersEfficiency.SEL_LABEL, PractitionersEfficiency.URL_USER_ALL_RPT);


                        /*  writer.Write(@"<li><a id=""viewtattlelink""         href=""" + MBA.HttpApplication.createLink(Practitioners.URL_LEA_COORD_RPT_TATTLETALE, true) + @""">Practitioner Submissions Report</a></li>");*/
                        writer.Write(@"<li><a id=""rptpracrevlink""         href=""" + MBA.HttpApplication.createLink("client_coor_rpt_prac_review.aspx", true) + @""">Practitioner Review</a></li>");

                        //writer.Write(@"<li><a id=""rptfilesuploaded""       href=""" + MBA.HttpApplication.createLink("client_all_rpt_file_uploads_view.aspx", true)   + @""">Files Uploaded to SpEdCare</a></li>");
                        writer.Write(@"<li><a id=""viewsvcsrendcomponepat"" href=""" + MBA.HttpApplication.createLink(ServiceRecords.PAGE_CLIENT_ALL_SVC_COMP_REPT, true) + @""">" + ServiceRecords.SEL_LABEL_PLAN_SVC_COMP_REPT + @"</a></li>");

                        renderTopMenuListEnd(ref writer);


                        /*------------------------
                         * Report Distribution
                         *------------------------*/

                        renderTopMenuListStart(ref writer, Publications.SEL_LABEL);

                        /**** Subscribers ****/

                        renderSubMenuListStart(ref writer, Subscribers.SEL_LABEL);
                        writer.Write(@"<li><a id=""addnewsbrlink""        href=""" + MBA.HttpApplication.createLink("client_coor_subscriber_save.aspx", true) + @""">" + Subscribers.SEL_LABEL_ADD + @"</a></li>");
                        writer.Write(@"<li><a id=""viewsbrlink""          href=""" + MBA.HttpApplication.createLink("client_coor_subscribers_view.aspx", true) + @""">" + Subscribers.SEL_LABEL_VIEW + @"</a></li>");
                        writer.Write(@"<li><a id=""editdelsbrlink""       href=""" + MBA.HttpApplication.createLink("client_coor_subscribers_edit_delete.aspx", true) + @""">" + Subscribers.SEL_LABEL_EDIT_DELETE + @"</a></li>");
                        renderSubMenuListEnd(ref writer);

                        /**** Subscriptions *****/

                        renderSubMenuListStart(ref writer, Subscriptions.SEL_LABEL);
                        writer.Write(@"<li><a id=""addnewsublink""        href=""" + MBA.HttpApplication.createLink("client_coor_subscription_save.aspx", true) + @""">" + Subscriptions.SEL_LABEL_ADD + @"</a></li>");
                        writer.Write(@"<li><a id=""viewsublink""          href=""" + MBA.HttpApplication.createLink("client_coor_subscriptions_view.aspx", true) + @""">" + Subscriptions.SEL_LABEL_VIEW + @"</a></li>");
                        writer.Write(@"<li><a id=""editdelsublink""       href=""" + MBA.HttpApplication.createLink("client_coor_subscriptions_edit_delete.aspx", true) + @""">" + Subscriptions.SEL_LABEL_EDIT_DELETE + @"</a></li>");
                        renderSubMenuListEnd(ref writer);

                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Service Records
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Service Records");

                        writer.Write(@"<li><a id=""addnewsvcreclink""     href=""" + MBA.HttpApplication.createLink("client_coor_svcrec_save.aspx", true) + @""">Record New Service Records</a></li>");
                        writer.Write(@"<li><a id=""batchnewsvcreclink""   href=""" + MBA.HttpApplication.createLink("client_coor_svcrec_batch_save.aspx", true) + @""">Record Multiple New Service Records</a></li>");

                        /* Replaces renderMenuListItem(ref writer, ServiceRecords.MENU_LINK_SVC_REC_SAVE_NEW_ALL_NON_PRAC, ServiceRecords.SEL_LABEL_SVREC_NON_PRAC, ServiceRecords.URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC); */


                        renderMenuListItem(ref writer
                                            , ServiceRecords.MENU_LINK_SVC_REC_SAVE_NEW_ALL_NON_PRAC
                                            , ServiceRecords.SEL_LABEL_SVREC_NON_PRAC
                                            , ServiceRecords.URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC);

                        /* Vision and hearing screening */

                        renderMenuListItem(ref writer, ServiceRecords.MENU_LINK_VISION_HEARING_SCREEN, ServiceRecords.SEL_LABEL_VISION_HEARING_SCREEN, ServiceRecords.URL_USER_ALL_VISION_AND_HEARING_SCREEN);


                        // writer.Write(@"<li><a id=""caseloadandgroupsvcreclink""       href=""" + MBA.HttpApplication.createLink(ServiceRecords.URL_CLIENT_COOR_SVCREC_CSLD_OR_GRP_SEL_PRAC, true)   + @""">" + ServiceRecords.SEL_LABEL_SVREC_NON_PRAC + @"</a></li>");
                        //writer.Write(@"<li><a id=""viewsvcrecslink""      href=""" +  MBA.HttpApplication.createLink("client_coor_svcrec_view.aspx",        true) + @""">View Service Records</a></li>");

                        renderMenuListItem(ref writer
                                          , "viewsvcrecslink" /* Replacing view with manage*/
                                          , ServiceRecords.SEL_LABEL_MANAGE
                                          , ServiceRecords.URL_USER_ALL_SVC_RECS_MANAGE);

                        renderMenuListItem(ref writer
                                          , ServiceRecordsDataIncomplete.MENU_LNK_USER_ALL_MANAGE
                                          , ServiceRecordsDataIncomplete.SEL_LABEL_MANAGE
                                          , ServiceRecordsDataIncomplete.URL_MANAGE);

                        //renderMenuListItem(ref writer, ClaimsRetroactiveForSpa.MENU_ID_AUTHORIZATION, ClaimsRetroactiveForSpa.SEL_LABEL_AUTHORIZATION, ClaimsRetroactiveForSpa.URL_USER_ALL_AUTHORIZATION);

                        // writer.Write(@"<li><a id=""viewsvcrecssvcnoteslink""  href=""" + MBA.HttpApplication.createLink("client_coor_svcrec_svcnote_view.aspx", true) + @""">View Progress Notes Saved in SpEdCare</a></li>");
                        //writer.Write(@"<li><a id=""editdelsvcrecslink""   href=""" +  MBA.HttpApplication.createLink("client_coor_svcrec_edit_delete.aspx", true) + @""">" + ServiceRecords.SEL_LABEL_EDIT_SVCREC  + @"</a></li>");


                        /* SPA 2015 Claim Authorization*/
                        // TODO: Uncomment when ready for release
                        //renderMenuListItem(ref writer, ClaimsRetroactiveForSpa.MENU_ID_AUTHORIZATION, ClaimsRetroactiveForSpa.SEL_LABEL_AUTHORIZATION , ClaimsRetroactiveForSpa.URL_CLIENT_MGMT_AUTHORIZATION);

                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * RMTS
                         *------------------------*/

                        // Constants.ROLE_LEA_CORDINATOR 
                        renderRmtsMenu(ref writer, rd);


                        /*------------------------
                         * Transportation
                         *------------------------*/

                        renderTopMenuListStart(ref writer, TransportationMgmtRecords.SEL_LABEL);
                        writer.Write(@"<li><a id=""managetranspatientsrouteslink""  href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_USER_ALL_MANAGE_PATIENTS_AND_ROUTES, true) + @""">" + TransportationMgmtRecords.SEL_LABEL_MANAGE + @"</a></li>");
                        writer.Write(@"<li><a id=""processincomingroutesheetslink"" href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_CLIENT_COOR_PROCESS_INCOMING_SHEET, true) + @""">" + TransportationMgmtRecords.SEL_LABEL_PROCESS_INCOMING_SHEET + @"</a></li>");
                        writer.Write(@"<li><a id=""manageheldtranslink""            href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_USER_ALL_MANAGE_SERVICE_RECORDS, true) + @""">" + TransportationMgmtRecords.SEL_LABEL_MANAGE_SERVICE_RECORDS + @"</a></li>");
                        renderTopMenuListEnd(ref writer);


                        /*------------------------
                         * CRCS
                         *------------------------*/

                        renderTopMenuListStart(ref writer, CrcsCommon.SEL_LABEL);
                        renderMenuListItem(ref writer, CrcsCommon.MENU_ID_MANAGE, CrcsCommon.SEL_LABEL_MANAGE, CrcsCommon.URL_MANAGE);
                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                          * Practice Office
                          *------------------------*/

                        renderPracticeOfficeMenu(ref writer, rd);

                        /*------------------------
                         * Users
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Users");
                        writer.Write(@"<li><a id=""addnewuserlink""        href=""" + MBA.HttpApplication.createLink("client_coor_user_save.aspx", true) + @""">Record New User</a></li>");
                        writer.Write(@"<li><a id=""viewuserlink""          href=""" + MBA.HttpApplication.createLink("client_coor_user_view.aspx", true) + @""">View Users</a></li>");
                        writer.Write(@"<li><a id=""editdeluserslink""      href=""" + MBA.HttpApplication.createLink("client_coor_user_edit_delete.aspx", true) + @""">Edit or Delete Users</a></li>");
                        renderTopMenuListEnd(ref writer);




                        break;
                    }

                /*********************************************************************************************
                 *                                Client Role - CYBHI Coordinators
                 *********************************************************************************************/

                case Constants.ROLE_CYBHI_CORDINATOR:
                    {

                        /* CYBHI Program Health */
                        renderCybhiProgramHealthMenuOptions(ref writer, rd);

                        /* Manage Patients */
                        renderMenuListItem(ref writer, Patients.MENU_ID_MANAGE, Patients.SEL_LABEL_MANAGE, Patients.URL_USER_ALL_MANAGE);

                        /* Manage patients with missing info*/

                        renderMenuListItem(ref writer, Spedmon.PatientsWithMissingInfo.MENU_ID_MANAGE, Spedmon.PatientsWithMissingInfo.SEL_LABEL_MANAGE, Spedmon.PatientsWithMissingInfo.URL_MANAGE);

                        /* Patient Insurance Info Public Requests Responses Manage */

                        renderMenuListItem(ref writer, Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.MENU_ID_MANAGE, Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.SEL_LABEL_MANAGE, Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.URL_MANAGE);

                        /* Bulk manage patient insurance */

                        renderMenuListItem(ref writer
                                            , PatientInsuranceCarriers.MENU_LNK_USER_ALL_MANAGE
                                            , PatientInsuranceCarriers.PAGE_MANAGE_SEL_LABEL
                                            , PatientInsuranceCarriers.URL_PAGE_MANAGE);

                        break;
                    }

                /*********************************************************************************************
                 *                                Practi-Cal Role - Input Staff
                 *********************************************************************************************/

                case Constants.ROLE_INPUT_STAFF:  //  //
                                                  // done: removed StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.URL_PAGE_MANAGE_USER_ALL
                                                  // done: put new RMTS menu here
                    {
                        renderTimeKeeperMenu(writer, rd);

                        /*------------------------
                        * Care Plan
                        *------------------------*/

                        renderTopMenuListStart(ref writer, PlanWriterRecords.SEL_LABEL);
                        renderMenuListItem(ref writer, "planwritemanagediagnoseslink", PlanWriterDiagnoses.SEL_LABEL_MANAGE, PlanWriterDiagnoses.URL_USER_ALL_MANAGE_DIAGNOSES);
                        renderMenuListItem(ref writer, "planwritemanagecareplanslink", PlanWriterPlans.SEL_LABEL_MANAGE, PlanWriterPlans.URL_USER_ALL_MANAGE_PLANS);
                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Clients
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Clients");

                        /* Program health */
                        renderMenuListItem(ref writer, LeaBopHealthCommon.MENU_ID_MANAGE, LeaBopHealthCommon.SEL_LABEL_MANAGE, LeaBopHealthCommon.URL_MANAGE);

                        /* CDE Compliance */
                        renderMenuListItem(ref writer, CdeComplianceCommon.MENU_ID_MANAGE, CdeComplianceCommon.SEL_LABEL_MANAGE, CdeComplianceCommon.URL_MANAGE);

                        renderMenuListItem(ref writer, Clients.MENU_ID_MANAGE, Clients.SEL_LABEL_MANAGE, Clients.URL_USER_ALL_MANAGE);
                        renderMenuListItem(ref writer, ClientComplianceCommon.MENU_ID_MANAGE, ClientComplianceCommon.SEL_LABEL_MANAGE, ClientComplianceCommon.URL_MANAGE);

                        renderTopMenuListEnd(ref writer);


                        /*------------------------
                         * Patients
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Patients");

                        renderMenuListItem(ref writer, Patients.MENU_ID_MANAGE, Patients.SEL_LABEL_MANAGE, Patients.URL_USER_ALL_MANAGE);

                        renderMenuListItem(ref writer
                          , PotentialLostReimbursements.MENU_ID_MANAGE_HOLDS
                          , PotentialLostReimbursements.SEL_MANAGE_HOLDS
                          , PotentialLostReimbursements.URL_MANAGE_HOLDS);

                        renderMenuListItem(ref writer
                          , PatientParentMcalConsents.MENU_LNK_USER_ALL_MANAGE
                          , PatientParentMcalConsents.SEL_LABEL_MANAGE
                          , PatientParentMcalConsents.URL_USER_ALL_MANAGE);

                        /* Bulk import - Patient data */

                        renderMenuListItem(ref writer
                                            , StructuredDataImportFilesPatientData.LNK_PAGE_IMPORT_USER_ALL
                                            , StructuredDataImportFilesPatientData.SEL_LABEL_IMPORT
                                            , StructuredDataImportFilesPatientData.URL_PAGE_IMPORT_USER_ALL);

                        renderMenuListItem(ref writer
                                            , StructuredDataImportFilesPatientData.LNK_PAGE_MANAGE_USER_ALL
                                            , StructuredDataImportFilesPatientData.SEL_LABEL_MANAGE
                                            , StructuredDataImportFilesPatientData.URL_PAGE_MANAGE_USER_ALL);

                        writer.Write(@"<li><a id=""mergepatrecslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_patients_merge.aspx", true) + @""">Merge Patients</a></li>");

                        renderMenuListItem(ref writer
                                              , PatientsCurrentMcalBenefits.MENU_LNK_USER_ALL_MANAGE
                                              , PatientsCurrentMcalBenefits.SEL_LABEL_MANAGE
                                              , PatientsCurrentMcalBenefits.URL_MANAGE);

                        /* Bulk manage patient insurance */

                        renderMenuListItem(ref writer
                                        , PatientInsuranceCarriers.MENU_LNK_USER_ALL_MANAGE
                                        , PatientInsuranceCarriers.PAGE_MANAGE_SEL_LABEL
                                        , PatientInsuranceCarriers.URL_PAGE_MANAGE);
                       
                        renderTopMenuListEnd(ref writer);


                        /*------------------------
                         * Manage Patient Services
                         *------------------------*/

                        renderTopMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_PATIENT_SERVICES);

                        /**** Transportation ****/

                        renderSubMenuListStart(ref writer, TransportationMgmtRecords.SEL_LABEL);
                        writer.Write(@"<li><a id=""managetranspatientsrouteslink""  href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_USER_ALL_MANAGE, true, new NameValue(TransportationMgmtRecords.PARM_NAME_TMGMT_SCREEN, TransportationMgmtRecords.PARM_VALUE_TMGMT_SCREEN_1)) + @""">" + TransportationMgmtRecords.SEL_LABEL_MANAGE + @"</a></li>");
                        writer.Write(@"<li><a id=""processincomingroutesheetslink"" href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_SBS_ALL_PROCESS_INCOMING_SHEET, true) + @""">" + TransportationMgmtRecords.SEL_LABEL_PROCESS_INCOMING_SHEET + @"</a></li>");
                        renderSubMenuListEnd(ref writer);

                        /**** Patient Profiles ****/

                        //renderMenuListItem(ref writer, "managesvcdescrsmanagelink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_MANAGE, ServiceJournals.URL_SBS_MANAGE_SERVICE_DESCRIPTIONS_MANAGE);

                        /**** Orders ****/

                        //renderMenuListItem(ref writer, "manageordersmanagelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPLATE_MANAGE);
                        renderMenuListItem(ref writer, "manageordersmanagelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE, ORPDocuments.URL_USER_ALL_MANAGE);

                        /**** Recurring Services ****/

                        renderSubMenuListStart(ref writer, RecurringServices.SEL_LABEL);
                        writer.Write(@"<li><a id=""addnewrcrsvcloadlink""    href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_save.aspx", true) + @""">" + RecurringServices.SEL_LABEL_ADD + @"</a></li>");
                        writer.Write(@"<li><a id=""viewrcrsvcloadlink""      href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_view.aspx", true) + @""">" + RecurringServices.SEL_LABEL_VIEW + @"</a></li>");
                        writer.Write(@"<li><a id=""editdelrcrsvcrecslink""   href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_edit_delete.aspx", true) + @""">" + RecurringServices.SEL_LABEL_OPS + @"</a></li>");
                        renderSubMenuListEnd(ref writer);

                        /**** ORP Document Standard Selection Names ****/

                        renderSubMenuListStart(ref writer, ORPDocumentsStandardSelectionNames.SEL_LABEL);
                        renderMenuListItem(ref writer, ORPDocumentsStandardSelectionNames.MENU_ID_MANAGE, ORPDocumentsStandardSelectionNames.SEL_LABEL_MANAGE, ORPDocumentsStandardSelectionNames.URL_SBS_MANAGE);
                        //renderMenuListItem(ref writer, ORPDocumentsStandardSelectionNames.MENU_ID_ADD_NEW,     ORPDocumentsStandardSelectionNames.SEL_LABEL_NEW,         ORPDocumentsStandardSelectionNames.URL_SBS_SAVE);
                        //renderMenuListItem(ref writer, ORPDocumentsStandardSelectionNames.MENU_ID_EDIT_DELETE, ORPDocumentsStandardSelectionNames.SEL_LABEL_EDIT_DELETE, ORPDocumentsStandardSelectionNames.URL_SBS_EDIT_DELETE);
                        //renderMenuListItem(ref writer, ORPDocumentsStandardSelectionNames.MENU_ID_VIEW ,       ORPDocumentsStandardSelectionNames.SEL_LABEL_VIEW,        ORPDocumentsStandardSelectionNames.URL_SBS_VIEW);
                        /**** Request Name ****/

                        writer.Write(@"<li><a id=""{0}"" target=""_blank"" href=""{1}"">{2}</a></li>"
                                      , Constants.REQUEST_OPR_DOC_STD_NAME_MENU_ID
                                      , Constants.REQUEST_ORP_DOC_STD_NAME_URL
                                      , Constants.REQUEST_ORP_DOC_STD_NAME_LBL);

                        renderSubMenuListEnd(ref writer);


                        /**** Old Patient Profiles Menu -- Render hidden to preserve compatability ****/

                        renderSubMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION, true);
                        renderMenuListItem(ref writer, @"managesvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_ADD_NEW_OR_EDIT, ServiceJournals.URL_SBS_SAVE_SERVICE_DESCRIPTION, true, true);
                        renderMenuListItem(ref writer, @"editdelsvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_EDIT_DELETE, ServiceJournals.URL_SBS_EDIT_DEL_SERVICE_DESCRIPTION, true, true);
                        renderMenuListItem(ref writer, @"viewsvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_VIEW, ServiceJournals.URL_SBS_SERVICE_DESCRIPTIONS_VIEW, true, true);
                        renderSubMenuListEnd(ref writer);

                        /* Old Orders Menu -- Render hidden to preserve compatability*/

                        renderSubMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_ORDERS, true);
                        renderMenuListItem(ref writer, @"manageordersnewlink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_NEW, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_NEW, true, true);
                        renderMenuListItem(ref writer, @"manageorderseditdeletelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_EDIT_DELETE, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_EDIT_DELETE, true, true);
                        renderMenuListItem(ref writer, @"manageordersviewlink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_VIEW, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_VIEW, true, true);
                        renderSubMenuListEnd(ref writer);

                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Service Records
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Service Records");

                        renderMenuListItem(ref writer
                                     , ServiceRecords.MENU_ID_MANAGE
                                     , ServiceRecords.SEL_LABEL_MANAGE
                                     , ServiceRecords.URL_USER_ALL_SVC_RECS_MANAGE);

                        writer.Write(@"<li><a id=""addnewsvcreclink""    href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_save.aspx", true) + @""">Record New Service Records</a></li>");
                        writer.Write(@"<li><a id=""batchnewsvcreclink""                    href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_save.aspx", true) + @""">Record Multiple New Service Records</a></li>");
                        // writer.Write(@"<li><a id=""batchnewsvcreconeononelink""          href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_one_on_one_save.aspx",true) + @""">Record Multiple New 1:1</a></li>");
                        writer.Write(@"<li><a id=""batchnewsvcrecmultiencountlink""        href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_save_multi_encounter.aspx", true) + @""">Record Multiple New - Multiple Encounters for Service Records</a></li>");
                        // renderMenuListItem(ref writer, ServiceRecords.MENU_LINK_SVC_REC_SAVE_NEW_ALL_NON_PRAC, ServiceRecords.SEL_LABEL_SVREC_NON_PRAC, ServiceRecords.URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC);
                        writer.Write(@"<li><a id=""viewsvcrecslink""                       href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_view.aspx", true) + @""">View Service Records</a></li>");
                        writer.Write(@"<li><a id=""editdelsvcrecslink""                    href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_edit_delete.aspx", true) + @""">" + ServiceRecords.SEL_LABEL_EDIT_SVCREC + @"</a></li>");
                        writer.Write(@"<li><a id=""batcheditdelsvcrecslink""               href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_edit_delete.aspx", true) + @""">Service Records Batch Delete</a></li>");
                        // writer.Write(@"<li><a id=""viewsvcrecssvcnoteslink""               href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_svcnote_view.aspx", true) + @""">View Progress Notes Saved in SpEdCare</a></li>");
                        writer.Write(@"<li><a id=""processincomingroutesheetslink""        href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_SBS_ALL_PROCESS_INCOMING_SHEET, true) + @""">" + TransportationMgmtRecords.SEL_LABEL_PROCESS_INCOMING_SHEET + @"</a></li>");

                        /* Vision and hearing screening */
                        renderMenuListItem(ref writer, ServiceRecords.MENU_LINK_VISION_HEARING_SCREEN, ServiceRecords.SEL_LABEL_VISION_HEARING_SCREEN, ServiceRecords.URL_USER_ALL_VISION_AND_HEARING_SCREEN);

                        renderMenuListItem(ref writer, @"svcrecorpdocasclink", @"Associate ORP Documents", @"sbs_all_orp_doc_svc_rec_asc.aspx");
                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Practitioners
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Practitioners");
                        renderMenuListItem(ref writer, Practitioners.MENU_ID_MANAGE, Practitioners.SEL_LABEL_MANAGE, Practitioners.URL_USER_ALL_MANAGE);

                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * RMTS
                         *------------------------*/

                        // Constants.ROLE_INPUT_STAFF  
                        renderRmtsMenu(ref writer, rd);


                        /*------------------------
                         * Reports
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Reports");

                        renderSubMenuListStart(ref writer, @"Potential Lost Reimbursement");
                        renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM_DAILY_OVERVIEW, Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_DAILY_OVERVIEW, Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_DAILY_OVERVIEW);
                        renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM_DAILY_DETAILS, Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_DAILY_DETAILS, Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_DAILY_DETAILS);
                        //renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM_OVERVIEW,          Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_OVERVIEW,                   Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_OVERVIEW);
                        //renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM,                   Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE,                            Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE);
                        //renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM_ORP_DETAILS,       Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_ORP_DETAILS,                Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_ORP_DETAILS);
                        renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM_MIS_ASSMT_DETAILS, Claims.SEL_LABEL_RPT_MISSING_ASSESSMENTS_POT_REIMBURSEMENT_DETAILS, Claims.URL_SBS_ALL_RPT_MISSING_ASSESSMENTS_WITH_POT_REIMBURSEMENT_DETAILS);
                        renderSubMenuListEnd(ref writer);

                        renderSubMenuListStart(ref writer, @"Financial");
                        writer.Write(@"<li><a id=""rptclmpaidbycheckdate""                    href=""" + MBA.HttpApplication.createLink("rpt_claims_paid.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_WD_1P + @"</a></li>");
                        writer.Write(@"<li><a id=""rptclmpaidbycheckdatecompared""            href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_WD_2P + @"</a></li>");
                        writer.Write(@"<li><a id=""rptclmpaidbyservicedate""                  href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_dos.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_1P + @"</a></li>");
                        writer.Write(@"<li><a id=""rptclmpaidbyservicedatecompared""          href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_dos_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_2P + @"</a></li>");
                        writer.Write(@"<li><a id=""rptcombined1on1bysvcdate""                 href=""" + MBA.HttpApplication.createLink("rpt_combined_1on1_by_svc_date.aspx", true) + @""">By Patient for One Practitioner by Service Date</a></li>");
                        renderSubMenuListEnd(ref writer);

                        renderSubMenuListStart(ref writer, @"Production Reports");
                        writer.Write(@"<li><a id=""rptcountofbatchesinprocessbystatus""       href=""" + MBA.HttpApplication.createLink(InputBatchesStatus.URL_RPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS, true) + @""">" + InputBatchesStatus.SEL_LABEL_RPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS + @"</a></li>");
                        writer.Write(@"<li><a id=""rptcountbatchesreadytoassignbytypeofwork"" href=""" + MBA.HttpApplication.createLink(InputBatchesStatus.URL_RPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK, true) + @""">" + InputBatchesStatus.SEL_LABEL_RPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK + @"</a></li>");
                        writer.Write(@"<li><a id=""rptbatchesneedingpriorityreview""          href=""" + MBA.HttpApplication.createLink(InputBatchesStatus.URL_RPT_BATCHES_NEEDING_PRIORITY_REVIEW, true) + @""">" + InputBatchesStatus.SEL_LABEL_RPT_BATCHES_NEEDING_PRIORITY_REVIEW + @"</a></li>");
                        writer.Write(@"<li><a id=""rptbatchesabt2ageout""                     href=""" + MBA.HttpApplication.createLink(InputBatchesStatus.URL_RPT_BATCHES_ABOUT_TO_AGE_OUT, true) + @""">" + InputBatchesStatus.SEL_LABEL_RPT_BATCHES_ABOUT_TO_AGE_OUT + @"</a></li>");
                        renderSubMenuListEnd(ref writer);

                        /* Recent denials */

                        renderSubMenuListStart(ref writer, Claims.SEL_LABEL_RECENT_DENIALS);

                        renderMenuListItem(ref writer, Claims.MENU_ID_RPT_DENIALS_SUMMARY
                                                     , Claims.SEL_LABEL_RPT_RECENT_DENIALS_SUMMARY
                                                     , Claims.URL_RPT_RECENT_DENIALS_SUMMARY);

                        renderMenuListItem(ref writer, Claims.MENU_ID_RPT_DENIALS_DETAILS
                                                     , Claims.SEL_LABEL_RPT_RECENT_DENIALS_DETAILS
                                                     , Claims.URL_RPT_RECENT_DENIALS_DETAILS);

                        renderSubMenuListEnd(ref writer);


                        //writer.Write(@"<li><a id=""viewtattlelink""                         href=""" + MBA.HttpApplication.createLink("rpt_svcrec_tattle.aspx",true)                                                  + @""">Tattle Tale</a></li>");
                        writer.Write(@"<li><a id=""rptpracrevlink""                           href=""" + MBA.HttpApplication.createLink("rpt_prac_review.aspx", true) + @""">Practitioner Review</a></li>");
                        //writer.Write(@"<li><a id=""rptrecentanifiles""                      href=""" + MBA.HttpApplication.createLink("rpt_recent_ani_files.aspx", true)                                              + @""">" + Workflow.RPT_NAME_RECENT_ANI + @"</a></li>");
                        writer.Write(@"<li><a id=""rptfilesuploaded""                         href=""" + MBA.HttpApplication.createLink("rpt_file_uploads_view.aspx", true) + @""">Files Uploaded to SpEdCare</a></li>");

                        writer.Write(@"<li><a id=""rpt_possible_pat_merges_needed""                         href=""" + MBA.HttpApplication.createLink("rpt_possible_pat_merges_needed.aspx", true) + @""">Possible Patient Merges Needed</a></li>");


                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * X12 Tools
                         *------------------------*/

                        renderX12ToolsMenu(ref writer);


                        /*------------------------
                         * Utility & Misc
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Utility");

                        /* Production */

                        renderInputBatchesMenu(writer, rd, false);

                        renderTopMenuListEnd(ref writer);

                        break;
                    }

                /*********************************************************************************************
                 *                                Practi-Cal Role - Work Leaders
                 *********************************************************************************************/

                case Constants.ROLE_WORK_LEADER:   //  //
                                                   // done: removed RmtsParticipationRosters.URL_MANAGE, StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.URL_PAGE_MANAGE_USER_ALL
                                                   // done: add new menu
                    {
                        renderTimeKeeperMenu(writer, rd);

                        /*------------------------
                        * Care Plan
                        *------------------------*/

                        renderTopMenuListStart(ref writer, PlanWriterRecords.SEL_LABEL);
                        renderMenuListItem(ref writer, "planwritemanagediagnoseslink", PlanWriterDiagnoses.SEL_LABEL_MANAGE, PlanWriterDiagnoses.URL_USER_ALL_MANAGE_DIAGNOSES);
                        renderMenuListItem(ref writer, "planwritemanagecareplanslink", PlanWriterPlans.SEL_LABEL_MANAGE, PlanWriterPlans.URL_USER_ALL_MANAGE_PLANS);
                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * SELPAS
                         *------------------------*/

                        renderSelpaMenu(writer, rd);

                        /*------------------------
                         * Clients
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Clients");

                        /* Program health */
                        renderMenuListItem(ref writer, LeaBopHealthCommon.MENU_ID_MANAGE, LeaBopHealthCommon.SEL_LABEL_MANAGE, LeaBopHealthCommon.URL_MANAGE);

                        /* CDE Compliance */
                        renderMenuListItem(ref writer, CdeComplianceCommon.MENU_ID_MANAGE, CdeComplianceCommon.SEL_LABEL_MANAGE, CdeComplianceCommon.URL_MANAGE);

                        /* Manage */
                        renderMenuListItem(ref writer, Clients.MENU_ID_MANAGE, Clients.SEL_LABEL_MANAGE, Clients.URL_USER_ALL_MANAGE);

                        renderMenuListItem(ref writer
                                            , ClientInvoices.MENU_LNK
                                            , ClientInvoices.SEL_LABEL_MANAGE
                                            , ClientInvoices.URL_MANAGE);

                        renderMenuListItem(ref writer, ClientComplianceCommon.MENU_ID_MANAGE, ClientComplianceCommon.SEL_LABEL_MANAGE, ClientComplianceCommon.URL_MANAGE);

                        /* Manage sites */
                        renderMenuListItem(ref writer, Sites.MENU_ID_MANAGE, Sites.SEL_LABEL_MANAGE, Sites.URL_MANAGE);

                        /* Old menu options.  Hidden for backwards compatibility and redirecting to new manage screen */

                        renderTopMenuListStart(ref writer, Sites.SEL_LABEL, true);
                        renderMenuListItem(ref writer, Sites.MENU_ID_SAVE, Sites.SEL_LABEL_SAVE, Sites.URL_SAVE);
                        renderMenuListItem(ref writer, Sites.MENU_ID_VIEW, Sites.SEL_LABEL_VIEW, Sites.URL_MANAGE);
                        renderMenuListItem(ref writer, Sites.MENU_ID_EDIT_DEL, Sites.SEL_LABEL_EDIT_DELETE, Sites.URL_MANAGE);
                        renderTopMenuListEnd(ref writer);

                        renderTopMenuListEnd(ref writer);

                        /*----------------------
                         * Manage Help Library
                         *---------------------*/

                        renderTopMenuListStart(ref writer, ManPages.SEL_LABEL);
                        renderMenuListItem(ref writer, ManPages.MENU_LNK_MAN_PAGE_MANAGE, ManPages.SEL_LABEL_MANAGE, ManPages.URL_MAN_PAGE_MANAGE);
                        writer.Write(@"<li><a id=""adminrptreviewuserresplink""    href=""" + MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_RPT_USER_RESP_REVIEW, true) + @""">" + ManPages.SEL_LABEL_RPT_USER_RESP_REVIEW + @"</a></li>");
                        writer.Write(@"<li><a target=""_blank"" id=""adminreviewmanpagecontentlink"" href=""" + MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_REVIEW_CONTENT, true) + @""">" + ManPages.SEL_LABEL_REVIEW_CONTENT + @"</a></li>");
                        /* Manage newsletters */
                        renderMenuListItem(ref writer, NewsletterPages.MENU_LNK_ID_MANAGE, NewsletterPages.SEL_LABEL_MANAGE, NewsletterPages.URL_MANAGE);
                        renderTopMenuListEnd(ref writer);



                        /*------------------------
                         * Patients
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Patients");
                        renderMenuListItem(ref writer, Patients.MENU_ID_MANAGE, Patients.SEL_LABEL_MANAGE, Patients.URL_USER_ALL_MANAGE);

                        renderMenuListItem(ref writer
                        , PotentialLostReimbursements.MENU_ID_MANAGE_HOLDS
                        , PotentialLostReimbursements.SEL_MANAGE_HOLDS
                        , PotentialLostReimbursements.URL_MANAGE_HOLDS);

                        renderMenuListItem(ref writer
                        , PatientParentMcalConsents.MENU_LNK_USER_ALL_MANAGE
                        , PatientParentMcalConsents.SEL_LABEL_MANAGE
                        , PatientParentMcalConsents.URL_USER_ALL_MANAGE);

                        /* Bulk import - Patient data */

                        renderMenuListItem(ref writer
                                            , StructuredDataImportFilesPatientData.LNK_PAGE_IMPORT_USER_ALL
                                            , StructuredDataImportFilesPatientData.SEL_LABEL_IMPORT
                                            , StructuredDataImportFilesPatientData.URL_PAGE_IMPORT_USER_ALL);

                        renderMenuListItem(ref writer
                                            , StructuredDataImportFilesPatientData.LNK_PAGE_MANAGE_USER_ALL
                                            , StructuredDataImportFilesPatientData.SEL_LABEL_MANAGE
                                            , StructuredDataImportFilesPatientData.URL_PAGE_MANAGE_USER_ALL);

                        writer.Write(@"<li><a id=""mergepatrecslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_patients_merge.aspx", true) + @""">Merge Patients</a></li>");

                        renderMenuListItem(ref writer
                                            , PatientsCurrentMcalBenefits.MENU_LNK_USER_ALL_MANAGE
                                            , PatientsCurrentMcalBenefits.SEL_LABEL_MANAGE
                                            , PatientsCurrentMcalBenefits.URL_MANAGE);

                        /* Bulk manage patient insurance */

                        renderMenuListItem(ref writer
                                        , PatientInsuranceCarriers.MENU_LNK_USER_ALL_MANAGE
                                        , PatientInsuranceCarriers.PAGE_MANAGE_SEL_LABEL
                                        , PatientInsuranceCarriers.URL_PAGE_MANAGE);

                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Manage Patient Services
                         *------------------------*/

                        renderTopMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_PATIENT_SERVICES);


                        /**** Transportation ****/

                        renderSubMenuListStart(ref writer, TransportationMgmtRecords.SEL_LABEL);
                        writer.Write(@"<li><a id=""managetranspatientsrouteslink""  href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_USER_ALL_MANAGE, true, new NameValue(TransportationMgmtRecords.PARM_NAME_TMGMT_SCREEN, TransportationMgmtRecords.PARM_VALUE_TMGMT_SCREEN_1)) + @""">" + TransportationMgmtRecords.SEL_LABEL_MANAGE + @"</a></li>");
                        writer.Write(@"<li><a id=""processincomingroutesheetslink"" href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_SBS_ALL_PROCESS_INCOMING_SHEET, true) + @""">" + TransportationMgmtRecords.SEL_LABEL_PROCESS_INCOMING_SHEET + @"</a></li>");
                        renderSubMenuListEnd(ref writer);

                        /**** Patient Profiles ****/

                        //renderMenuListItem(ref writer, "managesvcdescrsmanagelink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_MANAGE, ServiceJournals.URL_SBS_MANAGE_SERVICE_DESCRIPTIONS_MANAGE);

                        /**** Orders ****/

                        //renderMenuListItem(ref writer, "manageordersmanagelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPLATE_MANAGE);

                        renderMenuListItem(ref writer, "manageordersmanagelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE, ORPDocuments.URL_USER_ALL_MANAGE);

                        /**** Recurring Services ****/

                        renderSubMenuListStart(ref writer, RecurringServices.SEL_LABEL);
                        writer.Write(@"<li><a id=""addnewrcrsvcloadlink""    href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_save.aspx", true) + @""">" + RecurringServices.SEL_LABEL_ADD + @"</a></li>");
                        writer.Write(@"<li><a id=""viewrcrsvcloadlink""      href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_view.aspx", true) + @""">" + RecurringServices.SEL_LABEL_VIEW + @"</a></li>");
                        writer.Write(@"<li><a id=""editdelrcrsvcrecslink""   href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_edit_delete.aspx", true) + @""">" + RecurringServices.SEL_LABEL_OPS + @"</a></li>");
                        renderSubMenuListEnd(ref writer);

                        /**** ORP Document Standard Selection Names ****/

                        renderSubMenuListStart(ref writer, ORPDocumentsStandardSelectionNames.SEL_LABEL);
                        renderMenuListItem(ref writer, ORPDocumentsStandardSelectionNames.MENU_ID_MANAGE, ORPDocumentsStandardSelectionNames.SEL_LABEL_MANAGE, ORPDocumentsStandardSelectionNames.URL_SBS_MANAGE);

                        renderSubMenuListEnd(ref writer);

                        /**** Request Name ****/

                        writer.Write(@"<li><a id=""{0}"" target=""_blank"" href=""{1}"">{2}</a></li>"
                                      , Constants.REQUEST_OPR_DOC_STD_NAME_MENU_ID
                                      , Constants.REQUEST_ORP_DOC_STD_NAME_URL
                                      , Constants.REQUEST_ORP_DOC_STD_NAME_LBL);


                        /* Service name and form data */

                        renderMenuListItem(ref writer
                            , ClaimServiceNameXrefAndFormDataRecords.MENU_LNK_MANAGE
                            , ClaimServiceNameXrefAndFormDataRecords.SEL_LABEL_MANAGE
                            , ClaimServiceNameXrefAndFormDataRecords.URL_SBS_ALL_MANAGE);


                        /**** Old Patient Profiles Menu -- Render hidden to preserve compatability ****/

                        renderSubMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION, true);
                        renderMenuListItem(ref writer, @"managesvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_ADD_NEW_OR_EDIT, ServiceJournals.URL_SBS_SAVE_SERVICE_DESCRIPTION, true, true);
                        renderMenuListItem(ref writer, @"editdelsvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_EDIT_DELETE, ServiceJournals.URL_SBS_EDIT_DEL_SERVICE_DESCRIPTION, true, true);
                        renderMenuListItem(ref writer, @"viewsvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_VIEW, ServiceJournals.URL_SBS_SERVICE_DESCRIPTIONS_VIEW, true, true);
                        renderSubMenuListEnd(ref writer);

                        /* Old Orders Menu -- Render hidden to preserve compatability*/

                        renderSubMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_ORDERS, true);
                        renderMenuListItem(ref writer, @"manageordersnewlink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_NEW, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_NEW, true, true);
                        renderMenuListItem(ref writer, @"manageorderseditdeletelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_EDIT_DELETE, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_EDIT_DELETE, true, true);
                        renderMenuListItem(ref writer, @"manageordersviewlink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_VIEW, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_VIEW, true, true);
                        renderSubMenuListEnd(ref writer);

                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Service Records
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Service Records");

                        renderMenuListItem(ref writer
                                     , ServiceRecords.MENU_ID_MANAGE
                                     , ServiceRecords.SEL_LABEL_MANAGE
                                     , ServiceRecords.URL_USER_ALL_SVC_RECS_MANAGE);

                        writer.Write(@"<li><a id=""addnewsvcreclink""    href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_save.aspx", true) + @""">Record New Service Records</a></li>");
                        writer.Write(@"<li><a id=""batchnewsvcreclink""  href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_save.aspx", true) + @""">Record Multiple New Service Records</a></li>");
                        //writer.Write(@"<li><a id=""batchnewsvcreconeononelink""  href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_one_on_one_save.aspx",true) + @""">Record Multiple New 1:1</a></li>");
                        writer.Write(@"<li><a id=""batchnewsvcrecmultiencountlink"" href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_save_multi_encounter.aspx", true) + @""">Record Multiple New - Multiple Encounters for Service Records</a></li>");
                        //renderMenuListItem(ref writer, ServiceRecords.MENU_LINK_SVC_REC_SAVE_NEW_ALL, ServiceRecords.SEL_LABEL_SVREC_NON_PRAC, ServiceRecords.URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC);
                        writer.Write(@"<li><a id=""viewsvcrecslink""     href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_view.aspx", true) + @""">View Service Records</a></li>");
                        writer.Write(@"<li><a id=""editdelsvcrecslink""  href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_edit_delete.aspx", true) + @""">" + ServiceRecords.SEL_LABEL_EDIT_SVCREC + @"</a></li>");
                        writer.Write(@"<li><a id=""batcheditdelsvcrecslink""  href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_edit_delete.aspx", true) + @""">Service Records Batch Delete</a></li>");
                        // writer.Write(@"<li><a id=""viewsvcrecssvcnoteslink""  href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_svcnote_view.aspx", true) + @""">View Progress Notes Saved in SpEdCare</a></li>");
                        writer.Write(@"<li><a id=""processincomingroutesheetslink"" href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_SBS_ALL_PROCESS_INCOMING_SHEET, true) + @""">" + TransportationMgmtRecords.SEL_LABEL_PROCESS_INCOMING_SHEET + @"</a></li>");

                        /* Vision and hearing screening */
                        renderMenuListItem(ref writer, ServiceRecords.MENU_LINK_VISION_HEARING_SCREEN, ServiceRecords.SEL_LABEL_VISION_HEARING_SCREEN, ServiceRecords.URL_USER_ALL_VISION_AND_HEARING_SCREEN);
                        renderMenuListItem(ref writer, ClaimDenialResubmissions.MENU_ID_MANGE_DENIED_CLAIMS, ClaimDenialResubmissions.SEL_LABEL_MANAGE_DENIED_CLAIMS, ClaimDenialResubmissions.URL_SBS_ALL_MANAGE_DENIED_CLAIMS);
                        renderMenuListItem(ref writer, @"svcrecorpdocasclink", @"Associate ORP Documents", @"sbs_all_orp_doc_svc_rec_asc.aspx");

                        /* Import service records*/

                        renderMenuListItem(ref writer
                                            , ServiceRecordsDataImports.MENU_ID_IMPORT
                                            , ServiceRecordsDataImports.SEL_LABEL_IMPORT
                                            , ServiceRecordsDataImports.URL_PAGE_IMPORT);


                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * RMTS
                         *------------------------*/

                        // Constants.ROLE_WORK_LEADER  
                        renderRmtsMenu(ref writer, rd);

                        /*------------------------
                         * Practitioners
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Practitioners");
                        renderMenuListItem(ref writer, Practitioners.MENU_ID_MANAGE, Practitioners.SEL_LABEL_MANAGE, Practitioners.URL_USER_ALL_MANAGE);

                        /* Caseloads */
                        renderMenuListItem(ref writer, PractitionerCaseloadMembers.MENU_ID, PractitionerCaseloadMembers.SEL_LABEL_NON_PRAC, PractitionerCaseloadMembers.URL_USER_ALL);

                        /**** Supervision Tracking ****/
                        renderManagePractitionerSupervisionMenu(ref writer, rd);


                        renderTopMenuListEnd(ref writer);



                        /*------------------------
                         * Reports
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Reports");

                        renderSubMenuListStart(ref writer, @"Potential Lost Reimbursement");
                        renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM_DAILY_OVERVIEW, Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_DAILY_OVERVIEW, Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_DAILY_OVERVIEW);
                        renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM_DAILY_DETAILS, Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_DAILY_DETAILS, Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_DAILY_DETAILS);
                        //renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM_OVERVIEW,          Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_OVERVIEW,                   Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_OVERVIEW);
                        //renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM,                   Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE,                            Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE);
                        //renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM_ORP_DETAILS,       Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_ORP_DETAILS,                Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_ORP_DETAILS);
                        renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM_MIS_ASSMT_DETAILS, Claims.SEL_LABEL_RPT_MISSING_ASSESSMENTS_POT_REIMBURSEMENT_DETAILS, Claims.URL_SBS_ALL_RPT_MISSING_ASSESSMENTS_WITH_POT_REIMBURSEMENT_DETAILS);
                        renderSubMenuListEnd(ref writer);

                        renderSubMenuListStart(ref writer, @"Financial");
                        writer.Write(@"<li><a id=""rptclmpaidbycheckdate""                    href=""" + MBA.HttpApplication.createLink("rpt_claims_paid.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_WD_1P + @"</a></li>");
                        writer.Write(@"<li><a id=""rptclmpaidbycheckdatecompared""            href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_WD_2P + @"</a></li>");
                        writer.Write(@"<li><a id=""rptclmpaidbyservicedate""                  href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_dos.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_1P + @"</a></li>");
                        writer.Write(@"<li><a id=""rptclmpaidbyservicedatecompared""          href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_dos_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_2P + @"</a></li>");
                        renderSubMenuListEnd(ref writer);


                        renderSubMenuListStart(ref writer, @"Production Reports");
                        writer.Write(@"<li><a id=""rptcountofbatchesinprocessbystatus""       href=""" + MBA.HttpApplication.createLink(InputBatchesStatus.URL_RPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS, true) + @""">" + InputBatchesStatus.SEL_LABEL_RPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS + @"</a></li>");
                        writer.Write(@"<li><a id=""rptcountbatchesreadytoassignbytypeofwork"" href=""" + MBA.HttpApplication.createLink(InputBatchesStatus.URL_RPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK, true) + @""">" + InputBatchesStatus.SEL_LABEL_RPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK + @"</a></li>");
                        renderMenuListItem(ref writer, "rptbatchesassignednotdonelink", Clients.SEL_LABEL_RPT_BATCHES_ASSIGNED_NOT_DONE, Clients.URL_SBS_ALL_RPT_BATCHES_ASSIGNED_NOT_DONE);
                        writer.Write(@"<li><a id=""rptbatchesabt2ageout""                     href=""" + MBA.HttpApplication.createLink(InputBatchesStatus.URL_RPT_BATCHES_ABOUT_TO_AGE_OUT, true) + @""">" + InputBatchesStatus.SEL_LABEL_RPT_BATCHES_ABOUT_TO_AGE_OUT + @"</a></li>");
                        writer.Write(@"<li><a id=""rptbatchesneedingpriorityreview""          href=""" + MBA.HttpApplication.createLink(InputBatchesStatus.URL_RPT_BATCHES_NEEDING_PRIORITY_REVIEW, true) + @""">" + InputBatchesStatus.SEL_LABEL_RPT_BATCHES_NEEDING_PRIORITY_REVIEW + @"</a></li>");
                        renderMenuListItem(ref writer, "rptbatchesinprocess", Clients.SEL_LABEL_RPT_BATCHES_IN_PROCESS, Clients.URL_SBS_ALL_RPT_BATCHES_IN_PROCESS);
                        writer.Write(@"<li><a id=""rptinputstafftraininginprocesslink""           href=""" + MBA.HttpApplication.createLink(InputBatchesStatus.URL_RPT_INPUT_STAFF_TRAINING_IN_PROCESS, true) + @""">" + InputBatchesStatus.SEL_LABEL_RPT_INPUT_STAFF_TRAINING_IN_PROCESS + @"</a></li>");
                        renderSubMenuListEnd(ref writer);

                        renderSubMenuListStart(ref writer, @"Potential Lost Reimbursement");
                        writer.Write(@"<li><a id=""rptpotlostreimburse""                             href=""" + MBA.HttpApplication.createLink(Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE, true) + @""">" + Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE + @"</a></li>");
                        renderSubMenuListEnd(ref writer);

                        /* Recent denials */

                        renderSubMenuListStart(ref writer, Claims.SEL_LABEL_RECENT_DENIALS);

                        renderMenuListItem(ref writer, Claims.MENU_ID_RPT_DENIALS_SUMMARY
                                                     , Claims.SEL_LABEL_RPT_RECENT_DENIALS_SUMMARY
                                                     , Claims.URL_RPT_RECENT_DENIALS_SUMMARY);

                        renderMenuListItem(ref writer, Claims.MENU_ID_RPT_DENIALS_DETAILS
                                                     , Claims.SEL_LABEL_RPT_RECENT_DENIALS_DETAILS
                                                     , Claims.URL_RPT_RECENT_DENIALS_DETAILS);

                        renderSubMenuListEnd(ref writer);


                        renderMenuListItem(ref writer, "rptorpdocslink", ORPDocuments.SEL_LABEL_RPT, ORPDocuments.URL_SBS_VIEW);
                        writer.Write(@"<li><a id=""viewclmslink""                             href=""" + MBA.HttpApplication.createLink("rpt_claims_view.aspx", true) + @""">Claims View</a></li>");
                        renderMenuListItem(ref writer, ServicesByPracRpt.MENU_ID, ServicesByPracRpt.SEL_LABEL, ServicesByPracRpt.URL_USER_ALL_RPT);

                        writer.Write(@"<li><a id=""rptpracrevlink""                           href=""" + MBA.HttpApplication.createLink("rpt_prac_review.aspx", true) + @""">Practitioner Review</a></li>");
                        writer.Write(@"<li><a id=""viewworknotreceivedlink""                  href=""" + MBA.HttpApplication.createLink("rpt_client_work_not_received.aspx", true) + @""">Client Work Not Received</a></li>");
                        writer.Write(@"<li><a id=""rptpracleamaaxrefsetupissues""             href=""" + MBA.HttpApplication.createLink("rpt_prac_lea_maa_xref_issues.aspx", true) + @""">Miscoded MAA Participants</a></li>");
                        writer.Write(@"<li><a id=""rptbyeligpatdos2p""                        href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_elig_pat_dos_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_ELIG_PAT_SD_2P + @"</a></li>");
                        writer.Write(@"<li><a id=""rptcombined1on1bypmtdate""                 href=""" + MBA.HttpApplication.createLink("rpt_combined_1on1_by_pmt_date.aspx", true) + @""">By Patient for One Practitioner by Payment Date</a></li>");
                        writer.Write(@"<li><a id=""rptcombined1on1bysvcdate""                 href=""" + MBA.HttpApplication.createLink("rpt_combined_1on1_by_svc_date.aspx", true) + @""">By Patient for One Practitioner by Service Date</a></li>");
                        writer.Write(@"<li><a id=""rptfilesuploaded""                         href=""" + MBA.HttpApplication.createLink("rpt_file_uploads_view.aspx", true) + @""">Files Uploaded to SpEdCare</a></li>");

                        writer.Write(@"<li><a id=""rpt_possible_pat_merges_needed""                         href=""" + MBA.HttpApplication.createLink("rpt_possible_pat_merges_needed.aspx", true) + @""">Possible Patient Merges Needed</a></li>");


                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Report Distribution
                         *------------------------*/

                        renderTopMenuListStart(ref writer, Publications.SEL_LABEL);

                        /**** Subscribers *****/

                        renderSubMenuListStart(ref writer, Subscribers.SEL_LABEL);
                        writer.Write(@"<li><a id=""addnewsbrlink""        href=""" + MBA.HttpApplication.createLink("sbs_all_subscriber_save.aspx", true) + @""">" + Subscribers.SEL_LABEL_ADD + @"</a></li>");
                        writer.Write(@"<li><a id=""viewsbrlink""          href=""" + MBA.HttpApplication.createLink("sbs_all_subscribers_view.aspx", true) + @""">" + Subscribers.SEL_LABEL_VIEW + @"</a></li>");
                        writer.Write(@"<li><a id=""editdelsbrlink""       href=""" + MBA.HttpApplication.createLink("sbs_all_subscribers_edit_delete.aspx", true) + @""">" + Subscribers.SEL_LABEL_EDIT_DELETE + @"</a></li>");
                        renderSubMenuListEnd(ref writer);

                        /**** Subscriptions ****/

                        renderSubMenuListStart(ref writer, Subscriptions.SEL_LABEL);
                        writer.Write(@"<li><a id=""addnewsublink""        href=""" + MBA.HttpApplication.createLink("sbs_all_subscription_save.aspx", true) + @""">" + Subscriptions.SEL_LABEL_ADD + @"</a></li>");
                        writer.Write(@"<li><a id=""viewsublink""          href=""" + MBA.HttpApplication.createLink("sbs_all_subscriptions_view.aspx", true) + @""">" + Subscriptions.SEL_LABEL_VIEW + @"</a></li>");
                        writer.Write(@"<li><a id=""editdelsublink""       href=""" + MBA.HttpApplication.createLink("sbs_all_subscriptions_edit_delete.aspx", true) + @""">" + Subscriptions.SEL_LABEL_EDIT_DELETE + @"</a></li>");
                        renderSubMenuListEnd(ref writer);

                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                        * CRCS
                        *------------------------*/

                        renderTopMenuListStart(ref writer, CrcsCommon.SEL_LABEL);
                        renderMenuListItem(ref writer, CrcsCommon.MENU_ID_MANAGE, CrcsCommon.SEL_LABEL_MANAGE, CrcsCommon.URL_MANAGE);
                        renderMenuListItem(ref writer, CrcsCommon.MENU_ID_CLAIMS_REPORT, CrcsCommon.SEL_LABEL_CLAIMS_REPORT, CrcsCommon.URL_CLAIMS_REPORT);
                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Users
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Users");
                        writer.Write(@"<li><a id=""addnewuserlink""        href=""" + MBA.HttpApplication.createLink("sbs_all_user_save.aspx", true) + @""">Record New User</a></li>");
                        writer.Write(@"<li><a id=""viewuserlink""          href=""" + MBA.HttpApplication.createLink("sbs_all_user_view.aspx", true) + @""">View Users</a></li>");
                        writer.Write(@"<li><a id=""editdeluserslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_user_edit_delete.aspx", true) + @""">Edit or Delete Users</a></li>");
                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * X12 Tools
                         *------------------------*/

                        renderX12ToolsMenu(ref writer);

                        /*------------------------
                         * Utility & Misc
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Utility");

                        /* Claim procedure service fee updates */

                        renderMenuListItem(ref writer
                                            , ClaimProcedureFees.MENU_ID_SERVICE_FEES_UPDATE
                                            , ClaimProcedureFees.SEL_LABEL_SERVICE_FEES_UPDATE
                                            , ClaimProcedureFees.URL_SERVICE_FEES_UPDATE);



                        /* Production */

                        renderInputBatchesMenu(writer, rd, false);

                        renderTopMenuListEnd(ref writer);

                        break;

                    }

                /*********************************************************************************************
                 *                              Practi-Cal Role - Client Consultants
                 *********************************************************************************************/

                case Constants.ROLE_CLIENT_CONSULTANT:   //  //
                                                         // done: removed
                                                         //   RmtsParticipationRosters.URL_MANAGE,
                                                         //   StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.URL_PAGE_MANAGE_USER_ALL,
                                                         //   RmtsMoments.URL_MANAGE
                                                         //   RmtsMoments.URL_REVIEW
                                                         // done: put rmts menu here
                    {

                        renderTimeKeeperMenu(writer, rd);

                        /*------------------------
                        * Care Plan
                        *------------------------*/

                        renderTopMenuListStart(ref writer, PlanWriterRecords.SEL_LABEL);
                        renderMenuListItem(ref writer, "planwritemanagediagnoseslink", PlanWriterDiagnoses.SEL_LABEL_MANAGE, PlanWriterDiagnoses.URL_USER_ALL_MANAGE_DIAGNOSES);
                        renderMenuListItem(ref writer, "planwritemanagecareplanslink", PlanWriterPlans.SEL_LABEL_MANAGE, PlanWriterPlans.URL_USER_ALL_MANAGE_PLANS);
                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * SELPAS
                         *------------------------*/

                        renderSelpaMenu(writer, rd);

                        /*------------------------
                         * Clients
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Clients");

                        /* Program health */
                        renderMenuListItem(ref writer, LeaBopHealthCommon.MENU_ID_MANAGE, LeaBopHealthCommon.SEL_LABEL_MANAGE, LeaBopHealthCommon.URL_MANAGE);

                        /* CDE Compliance */
                        renderMenuListItem(ref writer, CdeComplianceCommon.MENU_ID_MANAGE, CdeComplianceCommon.SEL_LABEL_MANAGE, CdeComplianceCommon.URL_MANAGE);

                        /* CYBHI Program Health */
                        renderCybhiProgramHealthMenuOptions(ref writer, rd);

                        /* Manage */
                        renderMenuListItem(ref writer, Clients.MENU_ID_MANAGE, Clients.SEL_LABEL_MANAGE, Clients.URL_USER_ALL_MANAGE);
                        renderMenuListItem(ref writer, ClientComplianceCommon.MENU_ID_MANAGE, ClientComplianceCommon.SEL_LABEL_MANAGE, ClientComplianceCommon.URL_MANAGE);

                        /* My organization */

                        renderSubMenuListStart(ref writer, @"My Organization");

                        renderMenuListItem(ref writer
                                            , Clients.MENU_ID_MY_ORGANIZATION
                                            , Clients.SEL_LABEL_MY_ORGANIZATION
                                            , Clients.URL_USER_ALL_MY_ORGANIZATION);

                        renderMenuListItem(ref writer
                                      , ClientInvoices.MENU_LNK
                                      , ClientInvoices.SEL_LABEL_MANAGE
                                      , ClientInvoices.URL_MANAGE);

                        renderSubMenuListEnd(ref writer);

                        /* Manage sites */
                        renderManageSitesMenu(ref writer, rd);

                        renderTopMenuListEnd(ref writer);

                        /*----------------------
                         * Manage Help Library
                         *---------------------*/

                        renderTopMenuListStart(ref writer, ManPages.SEL_LABEL);
                        renderMenuListItem(ref writer, ManPages.MENU_LNK_MAN_PAGE_MANAGE, ManPages.SEL_LABEL_MANAGE, ManPages.URL_MAN_PAGE_MANAGE);
                        writer.Write(@"<li><a id=""adminrptreviewuserresplink""    href=""" + MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_RPT_USER_RESP_REVIEW, true) + @""">" + ManPages.SEL_LABEL_RPT_USER_RESP_REVIEW + @"</a></li>");
                        writer.Write(@"<li><a target=""_blank"" id=""adminreviewmanpagecontentlink"" href=""" + MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_REVIEW_CONTENT, true) + @""">" + ManPages.SEL_LABEL_REVIEW_CONTENT + @"</a></li>");
                        renderMenuListItem(ref writer, NewsletterPages.MENU_LNK_ID_MANAGE, NewsletterPages.SEL_LABEL_MANAGE, NewsletterPages.URL_MANAGE);
                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Patients
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Patients");
                        renderMenuListItem(ref writer, Patients.MENU_ID_MANAGE, Patients.SEL_LABEL_MANAGE, Patients.URL_USER_ALL_MANAGE);

                        renderMenuListItem(ref writer
                                                 , PatientParentMcalConsents.MENU_LNK_USER_ALL_MANAGE
                                                 , PatientParentMcalConsents.SEL_LABEL_MANAGE
                                                 , PatientParentMcalConsents.URL_USER_ALL_MANAGE);

                        renderMenuListItem(ref writer
                                              , PatientsCurrentMcalBenefits.MENU_LNK_USER_ALL_MANAGE
                                              , PatientsCurrentMcalBenefits.SEL_LABEL_MANAGE
                                              , PatientsCurrentMcalBenefits.URL_MANAGE);



                        /**** Missing Treatments ****/

                        renderMenuListItem(ref writer
                                              , MissingServicesTreatmentsSummary.MENU_ID_MANAGE
                                              , MissingServicesTreatmentsCommon.SEL_LABEL
                                              , MissingServicesTreatmentsSummary.URL_MANAGE);

                        renderMenuListItem(ref writer
                                         , PotentialLostReimbursements.MENU_ID_MANAGE_HOLDS
                                         , PotentialLostReimbursements.SEL_MANAGE_HOLDS
                                         , PotentialLostReimbursements.URL_MANAGE_HOLDS);

                        /* CYBHI Holds */

                        renderMenuListItem(ref writer
                                            , Spedmon.CYBHIHoldsManageCommon.MENU_ID_MANAGE_HOLDS
                                            , Spedmon.CYBHIHoldsManageCommon.SEL_MANAGE_HOLDS
                                            , Spedmon.CYBHIHoldsManageCommon.URL_MANAGE_HOLDS);

                        /* Manage patients with missing info*/

                        renderMenuListItem(ref writer
                                           , Spedmon.PatientsWithMissingInfo.MENU_ID_MANAGE
                                           , Spedmon.PatientsWithMissingInfo.SEL_LABEL_MANAGE
                                           , Spedmon.PatientsWithMissingInfo.URL_MANAGE);

                        /* Patient Insurance Info Public Requests Responses Manage */

                        renderMenuListItem(ref writer
                                            , Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.MENU_ID_MANAGE
                                            , Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.SEL_LABEL_MANAGE
                                            , Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.URL_MANAGE);

                        /* Bulk import - Patient data */

                        renderMenuListItem(ref writer
                                            , StructuredDataImportFilesPatientData.LNK_PAGE_IMPORT_USER_ALL
                                            , StructuredDataImportFilesPatientData.SEL_LABEL_IMPORT
                                            , StructuredDataImportFilesPatientData.URL_PAGE_IMPORT_USER_ALL);

                        renderMenuListItem(ref writer
                                            , StructuredDataImportFilesPatientData.LNK_PAGE_MANAGE_USER_ALL
                                            , StructuredDataImportFilesPatientData.SEL_LABEL_MANAGE
                                            , StructuredDataImportFilesPatientData.URL_PAGE_MANAGE_USER_ALL);

                        writer.Write(@"<li><a id=""mergepatrecslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_patients_merge.aspx", true) + @""">Merge Patients</a></li>");

                        /* Bulk manage patient insurance */

                        renderMenuListItem(ref writer
                                            , PatientInsuranceCarriers.MENU_LNK_USER_ALL_MANAGE
                                            , PatientInsuranceCarriers.PAGE_MANAGE_SEL_LABEL
                                            , PatientInsuranceCarriers.URL_PAGE_MANAGE);

                        renderTopMenuListEnd(ref writer);


                        /*------------------------
                         * Manage Patient Services
                         *------------------------*/

                        renderTopMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_PATIENT_SERVICES);

                        /**** Service Authorization Requests ****/

                        renderMenuListItem(ref writer, ServiceAuthorizationRequestResponses.MENU_ID_URL_RESPOND, ServiceAuthorizationRequestResponses.SEL_LABEL_RESPOND, ServiceAuthorizationRequestResponses.URL_MANAGE_RESPONSES);
                        renderMenuListItem(ref writer, ServiceAuthorizationRequestResponses.MENU_ID_URL_VIEW, ServiceAuthorizationRequestResponses.SEL_LABEL_REQUESTS_VIEW, ServiceAuthorizationRequestResponses.URL_SBSC_ALL_VIEW);



                        /**** Patient Profiles ****/

                        //renderMenuListItem(ref writer, "managesvcdescrsmanagelink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_MANAGE, ServiceJournals.URL_SBS_MANAGE_SERVICE_DESCRIPTIONS_MANAGE);

                        /**** Orders ****/

                        //renderMenuListItem(ref writer, "manageordersmanagelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPLATE_MANAGE);
                        renderMenuListItem(ref writer, "manageordersmanagelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE, ORPDocuments.URL_USER_ALL_MANAGE);

                        /**** Special Authorization ****/

                        renderSubMenuListStart(ref writer, ClientPBSDocumentation.SEL_LABEL);
                        writer.Write(@"<li><a id=""newclientpbslink""     href=""" + MBA.HttpApplication.createLink(ClientPBSDocumentation.URL_SBS_SAVE, true) + @""">" + ClientPBSDocumentation.SEL_LABEL_NEW + @"</a></li>");
                        writer.Write(@"<li><a id=""editdelclientpbslink"" href=""" + MBA.HttpApplication.createLink(ClientPBSDocumentation.URL_SBS_EDIT_DELETE, true) + @""">" + ClientPBSDocumentation.SEL_LABEL_EDIT_DELETE + @"</a></li>");
                        writer.Write(@"<li><a id=""viewclientpbslink""    href=""" + MBA.HttpApplication.createLink(ClientPBSDocumentation.URL_SBS_VIEW, true) + @""">" + ClientPBSDocumentation.SEL_LABEL_VIEW + @"</a></li>");
                        renderSubMenuListEnd(ref writer);

                        /**** Manage Telehealth ****/

                        renderMenuListItem(ref writer
                                            , TeleHealthSessions.MENU_LINK_MANAGE
                                            , TeleHealthSessions.SEL_LABEL_MANAGE
                                            , TeleHealthSessions.URL_SBS_MANAGE);

                        /**** Manage TeleIEP ****/

                        renderMenuListItem(ref writer
                                            , TeleIEPSessions.MENU_LINK_MANAGE
                                            , TeleIEPSessions.SEL_LABEL_MANAGE
                                            , TeleIEPSessions.URL_SBS_MANAGE);

                        /**** Recurring Services ****/

                        renderSubMenuListStart(ref writer, RecurringServices.SEL_LABEL);
                        writer.Write(@"<li><a id=""addnewrcrsvcloadlink""    href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_save.aspx", true) + @""">" + RecurringServices.SEL_LABEL_ADD + @"</a></li>");
                        writer.Write(@"<li><a id=""viewrcrsvcloadlink""      href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_view.aspx", true) + @""">" + RecurringServices.SEL_LABEL_VIEW + @"</a></li>");
                        writer.Write(@"<li><a id=""editdelrcrsvcrecslink""   href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_edit_delete.aspx", true) + @""">" + RecurringServices.SEL_LABEL_OPS + @"</a></li>");
                        renderSubMenuListEnd(ref writer);

                        /**** Transportation Services ****/

                        renderSubMenuListStart(ref writer, TransportationMgmtRecords.SEL_LABEL);
                        writer.Write(@"<li><a id=""managetranspatientsrouteslink""  href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_USER_ALL_MANAGE, true, new NameValue(TransportationMgmtRecords.PARM_NAME_TMGMT_SCREEN, TransportationMgmtRecords.PARM_VALUE_TMGMT_SCREEN_1)) + @""">" + TransportationMgmtRecords.SEL_LABEL_MANAGE + @"</a></li>");
                        writer.Write(@"<li><a id=""processincomingroutesheetslink"" href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_SBS_ALL_PROCESS_INCOMING_SHEET, true) + @""">" + TransportationMgmtRecords.SEL_LABEL_PROCESS_INCOMING_SHEET + @"</a></li>");
                        renderSubMenuListEnd(ref writer);

                        /**** ORP Document Standard Selection Names ****/

                        renderSubMenuListStart(ref writer, ORPDocumentsStandardSelectionNames.SEL_LABEL);

                        renderMenuListItem(ref writer, ORPDocumentsStandardSelectionNames.MENU_ID_MANAGE, ORPDocumentsStandardSelectionNames.SEL_LABEL_MANAGE, ORPDocumentsStandardSelectionNames.URL_SBS_MANAGE);

                        /**** Request Name ****/

                        writer.Write(@"<li><a id=""{0}"" target=""_blank"" href=""{1}"">{2}</a></li>"
                                    , Constants.REQUEST_OPR_DOC_STD_NAME_MENU_ID
                                    , Constants.REQUEST_ORP_DOC_STD_NAME_URL
                                    , Constants.REQUEST_ORP_DOC_STD_NAME_LBL);
                        renderSubMenuListEnd(ref writer);

                        /**** Request Name ****/

                        writer.Write(@"<li><a id=""{0}"" target=""_blank"" href=""{1}"">{2}</a></li>"
                                      , Constants.REQUEST_OPR_DOC_STD_NAME_MENU_ID
                                      , Constants.REQUEST_ORP_DOC_STD_NAME_URL
                                      , Constants.REQUEST_ORP_DOC_STD_NAME_LBL);

                        /**** Old Patient Profiles Menu -- Render hidden to preserve compatability ****/

                        renderSubMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION, true);
                        renderMenuListItem(ref writer, @"managesvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_ADD_NEW_OR_EDIT, ServiceJournals.URL_SBS_SAVE_SERVICE_DESCRIPTION, true, true);
                        renderMenuListItem(ref writer, @"editdelsvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_EDIT_DELETE, ServiceJournals.URL_SBS_EDIT_DEL_SERVICE_DESCRIPTION, true, true);
                        renderMenuListItem(ref writer, @"viewsvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_VIEW, ServiceJournals.URL_SBS_SERVICE_DESCRIPTIONS_VIEW, true, true);
                        renderSubMenuListEnd(ref writer);

                        /* Old Orders Menu -- Render hidden to preserve compatability*/

                        renderSubMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_ORDERS, true);
                        renderMenuListItem(ref writer, @"manageordersnewlink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_NEW, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_NEW, true, true);
                        renderMenuListItem(ref writer, @"manageorderseditdeletelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_EDIT_DELETE, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_EDIT_DELETE, true, true);
                        renderMenuListItem(ref writer, @"manageordersviewlink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_VIEW, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_VIEW, true, true);
                        renderSubMenuListEnd(ref writer);

                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * RMTS
                         *------------------------*/

                        // Constants.ROLE_CLIENT_CONSULTANT  
                        renderRmtsMenu(ref writer, rd);

                        /*------------------------
                         * Practitioners
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Practitioners");

                        renderMenuListItem(ref writer, Practitioners.MENU_ID_MANAGE, Practitioners.SEL_LABEL_MANAGE, Practitioners.URL_USER_ALL_MANAGE);

                        /* Caseloads */
                        renderMenuListItem(ref writer, PractitionerCaseloadMembers.MENU_ID, PractitionerCaseloadMembers.SEL_LABEL_NON_PRAC, PractitionerCaseloadMembers.URL_USER_ALL);

                        /**** RMTS ****/
                        //renderMenuListItem(ref writer, RmtsParticipationRosters.MENU_LINK_MANAGE, RmtsParticipationRosters.SEL_LABEL_MANAGE, RmtsParticipationRosters.URL_MANAGE);

                        /**** Supervision Tracking ****/
                        renderManagePractitionerSupervisionMenu(ref writer, rd);


                        /**** Service record review ****/
                        renderServiceRecordReviewMenu(ref writer, rd, false);

                        // renderMenuListItem(ref writer
                        //                     , StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.MENU_ID_MANAGE
                        //                     , StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.SEL_LABEL_MANAGE
                        //                     , StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.URL_PAGE_MANAGE_USER_ALL);

                        renderTopMenuListEnd(ref writer);


                        /*------------------------
                         * Reports
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Reports");

                        renderSubMenuListStart(ref writer, @"Potential Lost Reimbursement");
                        renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM_DAILY_OVERVIEW, Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_DAILY_OVERVIEW, Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_DAILY_OVERVIEW);
                        renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM_DAILY_DETAILS, Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_DAILY_DETAILS, Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_DAILY_DETAILS);
                        //renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM_OVERVIEW,          Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_OVERVIEW,                   Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_OVERVIEW);
                        //renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM,                   Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE,                            Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE);
                        //renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM_ORP_DETAILS,       Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_ORP_DETAILS,                Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_ORP_DETAILS);
                        renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM_MIS_ASSMT_DETAILS, Claims.SEL_LABEL_RPT_MISSING_ASSESSMENTS_POT_REIMBURSEMENT_DETAILS, Claims.URL_SBS_ALL_RPT_MISSING_ASSESSMENTS_WITH_POT_REIMBURSEMENT_DETAILS);
                        renderSubMenuListEnd(ref writer);

                        renderSubMenuListStart(ref writer, @"Financial");
                        writer.Write(@"<li><a id=""rptclmpaidbycheckdate""           href=""" + MBA.HttpApplication.createLink("rpt_claims_paid.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_WD_1P + @"</a></li>");
                        writer.Write(@"<li><a id=""rptclmpaidbycheckdatecompared""   href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_WD_2P + @"</a></li>");
                        writer.Write(@"<li><a id=""rptclmpaidbyservicedate""         href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_dos.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_1P + @"</a></li>");
                        writer.Write(@"<li><a id=""rptclmpaidbyservicedatecompared"" href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_dos_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_2P + @"</a></li>");
                        renderSubMenuListEnd(ref writer);

                        renderSubMenuListStart(ref writer, @"Production Reports");
                        renderMenuListItem(ref writer, "rptcountofbatchesinprocessbystatus", InputBatchesStatus.SEL_LABEL_RPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS, InputBatchesStatus.URL_RPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS);
                        renderMenuListItem(ref writer, "rptcountbatchesreadytoassignbytypeofwork", InputBatchesStatus.SEL_LABEL_RPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK, InputBatchesStatus.URL_RPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK);
                        renderMenuListItem(ref writer, "rptbatchesinprocess", Clients.SEL_LABEL_RPT_BATCHES_IN_PROCESS, Clients.URL_SBS_ALL_RPT_BATCHES_IN_PROCESS);
                        renderMenuListItem(ref writer, "rptbatchesassignednotdonelink", Clients.SEL_LABEL_RPT_BATCHES_ASSIGNED_NOT_DONE, Clients.URL_SBS_ALL_RPT_BATCHES_ASSIGNED_NOT_DONE);
                        renderSubMenuListEnd(ref writer);

                        /* Recent denials */

                        renderSubMenuListStart(ref writer, Claims.SEL_LABEL_RECENT_DENIALS);

                        renderMenuListItem(ref writer, Claims.MENU_ID_RPT_DENIALS_SUMMARY
                                                     , Claims.SEL_LABEL_RPT_RECENT_DENIALS_SUMMARY
                                                     , Claims.URL_RPT_RECENT_DENIALS_SUMMARY);

                        renderMenuListItem(ref writer, Claims.MENU_ID_RPT_DENIALS_DETAILS
                                                     , Claims.SEL_LABEL_RPT_RECENT_DENIALS_DETAILS
                                                     , Claims.URL_RPT_RECENT_DENIALS_DETAILS);

                        renderSubMenuListEnd(ref writer);



                        renderMenuListItem(ref writer, "rptorpdocslink", ORPDocuments.SEL_LABEL_RPT, ORPDocuments.URL_SBS_VIEW);

                        /**** Submission Reports ****/

                        renderMenuListItem(ref writer, ServicesByPracRpt.MENU_ID, ServicesByPracRpt.SEL_LABEL, ServicesByPracRpt.URL_USER_ALL_RPT);

                        /**** Dept Svcs Review ****/

                        renderMenuListItem(ref writer, PractitionerDepartmentServicesReview.MENU_ID, PractitionerDepartmentServicesReview.SEL_LABEL, PractitionerDepartmentServicesReview.URL_USER_ALL_RPT);

                        /**** Efficiency ****/

                        renderMenuListItem(ref writer, PractitionersEfficiency.MENU_ID, PractitionersEfficiency.SEL_LABEL, PractitionersEfficiency.URL_USER_ALL_RPT);

                        writer.Write(@"<li><a id=""rptpracrevlink""                  href=""" + MBA.HttpApplication.createLink("rpt_prac_review.aspx", true) + @""">Practitioner Review</a></li>");
                        writer.Write(@"<li><a id=""viewworknotreceivedlink""         href=""" + MBA.HttpApplication.createLink("rpt_client_work_not_received.aspx", true) + @""">Client Work Not Received</a></li>");
                        //writer.Write(@"<li><a id=""viewcrcclaimslink""               href=""" + MBA.HttpApplication.createLink("rpt_crc_claims.aspx", true) + @""">CRCS Claims</a></li>");

                        writer.Write(@"<li><a id=""viewclmslink""                    href=""" + MBA.HttpApplication.createLink("rpt_claims_view.aspx", true) + @""">Claims View</a></li>");
                        writer.Write(@"<li><a id=""rptcombined1on1bypmtdate""        href=""" + MBA.HttpApplication.createLink("rpt_combined_1on1_by_pmt_date.aspx", true) + @""">By Patient for One Practitioner by Payment Date</a></li>");
                        writer.Write(@"<li><a id=""rptcombined1on1bysvcdate""        href=""" + MBA.HttpApplication.createLink("rpt_combined_1on1_by_svc_date.aspx", true) + @""">By Patient for One Practitioner by Service Date</a></li>");
                        writer.Write(@"<li><a id=""rptpracleamaaxrefsetupissues""    href=""" + MBA.HttpApplication.createLink("rpt_prac_lea_maa_xref_issues.aspx", true) + @""">Miscoded MAA Participants</a></li>");
                        writer.Write(@"<li><a id=""rptbyeligpatdos2p""               href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_elig_pat_dos_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_ELIG_PAT_SD_2P + @"</a></li>");
                        // writer.Write(@"<li><a id=""rptrecentanifiles""            href=""" + MBA.HttpApplication.createLink("rpt_recent_ani_files.aspx", true) + @""">" + Workflow.RPT_NAME_RECENT_ANI + @"</a></li>");
                        writer.Write(@"<li><a id=""rptpracsupsvcsstillheld""         href=""" + MBA.HttpApplication.createLink(ServiceRecordsApproval.PAGE_RPT_SVC_REC_PENDING_APPROVAL_OR_HELD, true) + @""">" + ServiceRecordsApproval.SEL_LABEL_PRAC_SVC_REC_PENDING_APPROVAL_OR_HELD + @"</a></li>");
                        writer.Write(@"<li><a id=""rptfilesuploaded""                href=""" + MBA.HttpApplication.createLink("rpt_file_uploads_view.aspx", true) + @""">Files Uploaded to SpEdCare</a></li>");
                        writer.Write(@"<li><a id=""viewsvcsrendcomponepat""          href=""" + MBA.HttpApplication.createLink(ServiceRecords.PAGE_SBSC_ALL_SVC_COMP_REPT, true) + @""">" + ServiceRecords.SEL_LABEL_PLAN_SVC_COMP_REPT + @"</a></li>");

                        writer.Write(@"<li><a id=""rpt_possible_pat_merges_needed""                         href=""" + MBA.HttpApplication.createLink("rpt_possible_pat_merges_needed.aspx", true) + @""">Possible Patient Merges Needed</a></li>");


                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Report Distribution
                         *------------------------*/

                        renderTopMenuListStart(ref writer, Publications.SEL_LABEL);

                        /**** Subscribers *****/

                        renderSubMenuListStart(ref writer, Subscribers.SEL_LABEL);
                        writer.Write(@"<li><a id=""addnewsbrlink""        href=""" + MBA.HttpApplication.createLink("sbs_all_subscriber_save.aspx", true) + @""">" + Subscribers.SEL_LABEL_ADD + @"</a></li>");
                        writer.Write(@"<li><a id=""viewsbrlink""          href=""" + MBA.HttpApplication.createLink("sbs_all_subscribers_view.aspx", true) + @""">" + Subscribers.SEL_LABEL_VIEW + @"</a></li>");
                        writer.Write(@"<li><a id=""editdelsbrlink""       href=""" + MBA.HttpApplication.createLink("sbs_all_subscribers_edit_delete.aspx", true) + @""">" + Subscribers.SEL_LABEL_EDIT_DELETE + @"</a></li>");
                        renderSubMenuListEnd(ref writer);

                        /**** Subscriptions ****/

                        renderSubMenuListStart(ref writer, Subscriptions.SEL_LABEL);
                        writer.Write(@"<li><a id=""addnewsublink""        href=""" + MBA.HttpApplication.createLink("sbs_all_subscription_save.aspx", true) + @""">" + Subscriptions.SEL_LABEL_ADD + @"</a></li>");
                        writer.Write(@"<li><a id=""viewsublink""          href=""" + MBA.HttpApplication.createLink("sbs_all_subscriptions_view.aspx", true) + @""">" + Subscriptions.SEL_LABEL_VIEW + @"</a></li>");
                        writer.Write(@"<li><a id=""editdelsublink""       href=""" + MBA.HttpApplication.createLink("sbs_all_subscriptions_edit_delete.aspx", true) + @""">" + Subscriptions.SEL_LABEL_EDIT_DELETE + @"</a></li>");
                        renderSubMenuListEnd(ref writer);

                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Service Journals
                         *------------------------*/

                        renderTopMenuListStart(ref writer, ServiceJournals.SEL_LABEL);
                        writer.Write(@"<li><a id=""svcjournalrecordproclink""   href=""" + MBA.HttpApplication.createLink(ServiceJournals.URL_USER_ALL_OPEN_NEW, true, new NameValue(ServiceJournals.PARAM_EVENT_TYPE_ID, ServiceJournals.VAL_EVENT_TYPE_REC_PROC)) + @""">" + ServiceJournals.SEL_LABEL_RECORD_PROC + @"</a></li>");
                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Service Records
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Service Records");

                        renderMenuListItem(ref writer
                                           , ServiceRecords.MENU_ID_MANAGE
                                           , ServiceRecords.SEL_LABEL_MANAGE
                                           , ServiceRecords.URL_USER_ALL_SVC_RECS_MANAGE);

                        writer.Write(@"<li><a id=""viewsvcrecslink""     href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_view.aspx", true) + @""">View Service Records</a></li>");

                        /* Replaces : renderMenuListItem(ref writer, ServiceRecords.MENU_LINK_SVC_REC_SAVE_NEW_ALL_NON_PRAC, ServiceRecords.SEL_LABEL_SVC_REC_SAVE_NEW_ALL, ServiceRecords.URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC); */

                        renderMenuListItem(ref writer
                                         , ServiceRecords.MENU_LINK_SVC_REC_SAVE_NEW_ALL_NON_PRAC
                                         , ServiceRecords.SEL_LABEL_SVREC_NON_PRAC
                                         , ServiceRecords.URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC);

                        renderMenuListItem(ref writer, ClaimDenialResubmissions.MENU_ID_MANGE_DENIED_CLAIMS, ClaimDenialResubmissions.SEL_LABEL_MANAGE_DENIED_CLAIMS, ClaimDenialResubmissions.URL_SBS_ALL_MANAGE_DENIED_CLAIMS);
                        // writer.Write(@"<li><a id=""viewsvcrecssvcnoteslink""  href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_svcnote_view.aspx", true) + @""">View Progress Notes Saved in SpEdCare</a></li>");
                        renderMenuListItem(ref writer, ClaimsRetroactiveForSpa.MENU_ID_AUTHORIZATION, ClaimsRetroactiveForSpa.SEL_LABEL_AUTHORIZATION, ClaimsRetroactiveForSpa.URL_USER_ALL_AUTHORIZATION);

                        /* Import service records*/

                        renderMenuListItem(ref writer
                                            , ServiceRecordsDataImports.MENU_ID_IMPORT
                                            , ServiceRecordsDataImports.SEL_LABEL_IMPORT
                                            , ServiceRecordsDataImports.URL_PAGE_IMPORT);

                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Practice Office
                         *------------------------*/

                        renderPracticeOfficeMenu(ref writer, rd);

                        /*------------------------
                         * CRCS
                         *------------------------*/

                        renderTopMenuListStart(ref writer, CrcsCommon.SEL_LABEL);
                        renderMenuListItem(ref writer, CrcsCommon.MENU_ID_MANAGE, CrcsCommon.SEL_LABEL_MANAGE, CrcsCommon.URL_MANAGE);
                        renderMenuListItem(ref writer, CrcsCommon.MENU_ID_CLAIMS_REPORT, CrcsCommon.SEL_LABEL_CLAIMS_REPORT, CrcsCommon.URL_CLAIMS_REPORT);
                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Users
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Users");
                        writer.Write(@"<li><a id=""addnewuserlink""        href=""" + MBA.HttpApplication.createLink("sbs_all_user_save.aspx", true) + @""">Record New User</a></li>");
                        writer.Write(@"<li><a id=""viewuserlink""          href=""" + MBA.HttpApplication.createLink("sbs_all_user_view.aspx", true) + @""">View Users</a></li>");
                        writer.Write(@"<li><a id=""editdeluserslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_user_edit_delete.aspx", true) + @""">Edit or Delete Users</a></li>");
                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * X12 Tools
                         *------------------------*/

                        renderX12ToolsMenu(ref writer);

                        /*------------------------
                         * Utility & Misc
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Utility");

                        /* Claim procedure service fee updates */

                        renderMenuListItem(ref writer
                                           , ClaimProcedureFees.MENU_ID_SERVICE_FEES_UPDATE
                                           , ClaimProcedureFees.SEL_LABEL_SERVICE_FEES_UPDATE
                                           , ClaimProcedureFees.URL_SERVICE_FEES_UPDATE);


                        /* Production */

                        renderInputBatchesMenu(writer, rd, false);

                        renderTopMenuListEnd(ref writer);


                        break;
                    }

                /*********************************************************************************************
                 *                              Practi-Cal Role - Administrators
                 *********************************************************************************************/

                case Constants.ROLE_ADMIN:   //  //
                                             // done: removed
                                             //  RmtsParticipationRosters.URL_MANAGE
                                             //  StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.URL_PAGE_MANAGE_USER_ALL
                                             //  RmtsMoments.URL_MANAGE
                                             //  RmtsMoments.URL_REVIEW
                                             // done: add new menu
                    {

                        renderTimeKeeperMenu(writer, rd);

                        /*------------------------
                         * SELPAS
                         *------------------------*/

                        renderSelpaMenu(writer, rd);

                        /*------------------------
                         * Clients
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Clients");

                        /* Program health */
                        renderMenuListItem(ref writer, LeaBopHealthCommon.MENU_ID_MANAGE, LeaBopHealthCommon.SEL_LABEL_MANAGE, LeaBopHealthCommon.URL_MANAGE);

                        /* CDE Compliance */

                        renderMenuListItem(ref writer, CdeComplianceCommon.MENU_ID_MANAGE, CdeComplianceCommon.SEL_LABEL_MANAGE, CdeComplianceCommon.URL_MANAGE);

                        /* CYBHI Program Health */
                        renderCybhiProgramHealthMenuOptions(ref writer, rd);

                        /* CDE Compliance for Audit Period */

                        /*renderMenuListItem(ref writer, CdeComplianceCommon.MENU_ID_FOR_CLIENT_MANAGE_CURRENT_AUDIT, CdeComplianceCommon.SEL_LABEL_MANGE_FOR_CLIENT_CURRENT_AUDIT, CdeComplianceCommon.URL_MANAGE_CURRENT_AUDIT);*/

                        /**** Manage ****/

                        renderMenuListItem(ref writer, Clients.MENU_ID_MANAGE, Clients.SEL_LABEL_MANAGE, Clients.URL_USER_ALL_MANAGE);

                        /* My organization */

                        renderSubMenuListStart(ref writer, @"My Organization");

                        renderMenuListItem(ref writer
                                            , Clients.MENU_ID_MY_ORGANIZATION
                                            , Clients.SEL_LABEL_MY_ORGANIZATION
                                            , Clients.URL_USER_ALL_MY_ORGANIZATION);

                        renderMenuListItem(ref writer
                                      , ClientInvoices.MENU_LNK
                                      , ClientInvoices.SEL_LABEL_MANAGE
                                      , ClientInvoices.URL_MANAGE);


                        renderMenuListItem(ref writer
                                  , ClientInvoices.MENU_LNK_PARTNER
                                  , ClientInvoices.SEL_LABEL_MANAGE_DISTR
                                  , ClientInvoices.URL_MANAGE_PARTNER_DISTRIBUTIONS
                                      );

                        renderMenuListItem(ref writer
                                      , ClientInvoices.MENU_LNK_PARTNER_CYBHI
                                      , ClientInvoices.SEL_LABEL_MANAGE_PARTN1_2
                                      , ClientInvoices.URL_MANAGE_PARTNER_CYBHI_DISTRIBUTIONS
                                      );

                        renderMenuListItem(ref writer
                                      , ClientInvoices.MENU_LNK_PARTNER_RETNTN
                                      , ClientInvoices.SEL_LABEL_MANAGE_RETNTN_DISTR
                                      , ClientInvoices.URL_MANAGE_PARTNER_RETNTN_DISTRIBUTIONS
                                      );
                        
                        renderSubMenuListEnd(ref writer);

                        renderMenuListItem(ref writer, ClientComplianceCommon.MENU_ID_MANAGE, ClientComplianceCommon.SEL_LABEL_MANAGE, ClientComplianceCommon.URL_MANAGE);

                        /* Manage sites */
                        renderManageSitesMenu(ref writer, rd);


                        renderTopMenuListEnd(ref writer);


                        /*----------------------
                         * Manage Help Library
                         *---------------------*/

                        renderTopMenuListStart(ref writer, ManPages.SEL_LABEL);
                        renderMenuListItem(ref writer, ManPages.MENU_LNK_MAN_PAGE_MANAGE, ManPages.SEL_LABEL_MANAGE, ManPages.URL_MAN_PAGE_MANAGE);
                        writer.Write(@"<li><a id=""adminrptreviewuserresplink""    href=""" + MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_RPT_USER_RESP_REVIEW, true) + @""">" + ManPages.SEL_LABEL_RPT_USER_RESP_REVIEW + @"</a></li>");

                        writer.Write(@"<li><a target=""_blank"" id=""adminreviewmanpagecontentlink"" href=""" + MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_REVIEW_CONTENT, true) + @""">" + ManPages.SEL_LABEL_REVIEW_CONTENT + @"</a></li>");

                        renderMenuListItem(ref writer, NewsletterPages.MENU_LNK_ID_MANAGE, NewsletterPages.SEL_LABEL_MANAGE, NewsletterPages.URL_MANAGE);

                        renderTopMenuListEnd(ref writer);


                        /*------------------------
                         * Patients
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Patients");
                        renderMenuListItem(ref writer, Patients.MENU_ID_MANAGE, Patients.SEL_LABEL_MANAGE, Patients.URL_USER_ALL_MANAGE);

                        renderMenuListItem(ref writer
                                             , PatientParentMcalConsents.MENU_LNK_USER_ALL_MANAGE
                                             , PatientParentMcalConsents.SEL_LABEL_MANAGE
                                             , PatientParentMcalConsents.URL_USER_ALL_MANAGE);

                        renderMenuListItem(ref writer
                                             , PatientsCurrentMcalBenefits.MENU_LNK_USER_ALL_MANAGE
                                             , PatientsCurrentMcalBenefits.SEL_LABEL_MANAGE
                                             , PatientsCurrentMcalBenefits.URL_MANAGE);


                        /**** Missing Treatments ****/

                        renderMenuListItem(ref writer
                                             , MissingServicesTreatmentsSummary.MENU_ID_MANAGE
                                             , MissingServicesTreatmentsCommon.SEL_LABEL
                                             , MissingServicesTreatmentsSummary.URL_MANAGE);

                        renderMenuListItem(ref writer
                                         , PotentialLostReimbursements.MENU_ID_MANAGE_HOLDS
                                         , PotentialLostReimbursements.SEL_MANAGE_HOLDS
                                         , PotentialLostReimbursements.URL_MANAGE_HOLDS);

                        /* CYBHI Holds */

                        renderMenuListItem(ref writer
                                            , Spedmon.CYBHIHoldsManageCommon.MENU_ID_MANAGE_HOLDS
                                            , Spedmon.CYBHIHoldsManageCommon.SEL_MANAGE_HOLDS
                                            , Spedmon.CYBHIHoldsManageCommon.URL_MANAGE_HOLDS);

                        /* Manage patients with missing info*/

                        renderMenuListItem(ref writer
                                          , Spedmon.PatientsWithMissingInfo.MENU_ID_MANAGE
                                          , Spedmon.PatientsWithMissingInfo.SEL_LABEL_MANAGE
                                          , Spedmon.PatientsWithMissingInfo.URL_MANAGE);

                        /* Patient Insurance Info Public Requests Responses Manage */

                        renderMenuListItem(ref writer
                                          , Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.MENU_ID_MANAGE
                                          , Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.SEL_LABEL_MANAGE
                                          , Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.URL_MANAGE);

                        /* Bulk import - Patient data */

                        renderMenuListItem(ref writer
                                            , StructuredDataImportFilesPatientData.LNK_PAGE_IMPORT_USER_ALL
                                            , StructuredDataImportFilesPatientData.SEL_LABEL_IMPORT
                                            , StructuredDataImportFilesPatientData.URL_PAGE_IMPORT_USER_ALL);

                        renderMenuListItem(ref writer
                                            , StructuredDataImportFilesPatientData.LNK_PAGE_MANAGE_USER_ALL
                                            , StructuredDataImportFilesPatientData.SEL_LABEL_MANAGE
                                            , StructuredDataImportFilesPatientData.URL_PAGE_MANAGE_USER_ALL);

                        writer.Write(@"<li><a id=""mergepatrecslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_patients_merge.aspx", true) + @""">Merge Patients</a></li>");

                        /* Bulk manage patient insurance */

                        renderMenuListItem(ref writer
                                        , PatientInsuranceCarriers.MENU_LNK_USER_ALL_MANAGE
                                        , PatientInsuranceCarriers.PAGE_MANAGE_SEL_LABEL
                                        , PatientInsuranceCarriers.URL_PAGE_MANAGE);

                        /* Import Patient Goals */
                        renderMenuListItem(ref writer
                                            , ImportFromPatientGoalRecords.MENU_ID_IMPORT
                                            , ImportFromPatientGoalRecords.SEL_LABEL_IMPORT
                                            , ImportFromPatientGoalRecords.URL_PAGE_IMPORT);

                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Manage Patient Services
                         *------------------------*/

                        renderTopMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_PATIENT_SERVICES);

                        /**** Service Authorization Requests ****/

                        renderMenuListItem(ref writer, ServiceAuthorizationRequestResponses.MENU_ID_URL_RESPOND, ServiceAuthorizationRequestResponses.SEL_LABEL_RESPOND, ServiceAuthorizationRequestResponses.URL_MANAGE_RESPONSES);
                        renderMenuListItem(ref writer, ServiceAuthorizationRequestResponses.MENU_ID_URL_VIEW, ServiceAuthorizationRequestResponses.SEL_LABEL_REQUESTS_VIEW, ServiceAuthorizationRequestResponses.URL_SBSC_ALL_VIEW);


                        /**** Patient Profiles ****/

                        //renderMenuListItem(ref writer, "managesvcdescrsmanagelink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_MANAGE, ServiceJournals.URL_SBS_MANAGE_SERVICE_DESCRIPTIONS_MANAGE);

                        /**** Orders ****/

                        // renderMenuListItem(ref writer, "manageordersmanagelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPLATE_MANAGE);
                        renderMenuListItem(ref writer, "manageordersmanagelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE, ORPDocuments.URL_USER_ALL_MANAGE);

                        /**** Special Authorization ****/

                        renderSubMenuListStart(ref writer, ClientPBSDocumentation.SEL_LABEL);
                        writer.Write(@"<li><a id=""newclientpbslink""     href=""" + MBA.HttpApplication.createLink(ClientPBSDocumentation.URL_SBS_SAVE, true) + @""">" + ClientPBSDocumentation.SEL_LABEL_NEW + @"</a></li>");
                        writer.Write(@"<li><a id=""editdelclientpbslink"" href=""" + MBA.HttpApplication.createLink(ClientPBSDocumentation.URL_SBS_EDIT_DELETE, true) + @""">" + ClientPBSDocumentation.SEL_LABEL_EDIT_DELETE + @"</a></li>");
                        writer.Write(@"<li><a id=""viewclientpbslink""    href=""" + MBA.HttpApplication.createLink(ClientPBSDocumentation.URL_SBS_VIEW, true) + @""">" + ClientPBSDocumentation.SEL_LABEL_VIEW + @"</a></li>");
                        renderSubMenuListEnd(ref writer);


                        /**** Manage Telehealth ****/

                        renderMenuListItem(ref writer
                                            , TeleHealthSessions.MENU_LINK_MANAGE
                                            , TeleHealthSessions.SEL_LABEL_MANAGE
                                            , TeleHealthSessions.URL_SBS_MANAGE);

                        /**** Manage TeleIEP ****/

                        renderMenuListItem(ref writer
                                            , TeleIEPSessions.MENU_LINK_MANAGE
                                            , TeleIEPSessions.SEL_LABEL_MANAGE
                                            , TeleIEPSessions.URL_SBS_MANAGE);

                        /**** Manage IEP Form Signature Page Types ****/

                        renderMenuListItem(ref writer
                                            , TeleCommIEPTypes.MENU_LINK_MANAGE
                                            , TeleCommIEPTypes.SEL_LABEL_MANAGE
                                            , TeleCommIEPTypes.URL_SBS_ALL_MANAGE);

                        /**** Recurring Services ****/

                        renderSubMenuListStart(ref writer, RecurringServices.SEL_LABEL);
                        writer.Write(@"<li><a id=""addnewrcrsvcloadlink""    href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_save.aspx", true) + @""">" + RecurringServices.SEL_LABEL_ADD + @"</a></li>");
                        writer.Write(@"<li><a id=""viewrcrsvcloadlink""      href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_view.aspx", true) + @""">" + RecurringServices.SEL_LABEL_VIEW + @"</a></li>");
                        writer.Write(@"<li><a id=""editdelrcrsvcrecslink""   href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_edit_delete.aspx", true) + @""">" + RecurringServices.SEL_LABEL_OPS + @"</a></li>");
                        renderSubMenuListEnd(ref writer);


                        /**** Transportation ****/

                        renderSubMenuListStart(ref writer, TransportationMgmtRecords.SEL_LABEL);
                        writer.Write(@"<li><a id=""managetranspatientsrouteslink""  href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_USER_ALL_MANAGE, true, new NameValue(TransportationMgmtRecords.PARM_NAME_TMGMT_SCREEN, TransportationMgmtRecords.PARM_VALUE_TMGMT_SCREEN_1)) + @""">" + TransportationMgmtRecords.SEL_LABEL_MANAGE + @"</a></li>");
                        writer.Write(@"<li><a id=""processincomingroutesheetslink"" href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_SBS_ALL_PROCESS_INCOMING_SHEET, true) + @""">" + TransportationMgmtRecords.SEL_LABEL_PROCESS_INCOMING_SHEET + @"</a></li>");
                        renderSubMenuListEnd(ref writer);

                        /**** Plan Writer ****/

                        renderSubMenuListStart(ref writer, PlanWriterRecords.SEL_LABEL);
                        renderMenuListItem(ref writer, "planwritemanagediagnoseslink", PlanWriterDiagnoses.SEL_LABEL_MANAGE, PlanWriterDiagnoses.URL_USER_ALL_MANAGE_DIAGNOSES);
                        renderMenuListItem(ref writer, "planwritemanagecareplanslink", PlanWriterPlans.SEL_LABEL_MANAGE, PlanWriterPlans.URL_USER_ALL_MANAGE_PLANS);
                        renderSubMenuListEnd(ref writer);

                        /**** ORP Document Standard Selection Names ****/

                        renderSubMenuListStart(ref writer, ORPDocumentsStandardSelectionNames.SEL_LABEL);
                        renderMenuListItem(ref writer, ORPDocumentsStandardSelectionNames.MENU_ID_MANAGE, ORPDocumentsStandardSelectionNames.SEL_LABEL_MANAGE, ORPDocumentsStandardSelectionNames.URL_SBS_MANAGE);

                        /**** Request Name ****/

                        writer.Write(@"<li><a id=""{0}"" target=""_blank"" href=""{1}"">{2}</a></li>"
                                      , Constants.REQUEST_OPR_DOC_STD_NAME_MENU_ID
                                      , Constants.REQUEST_ORP_DOC_STD_NAME_URL
                                      , Constants.REQUEST_ORP_DOC_STD_NAME_LBL);

                        renderSubMenuListEnd(ref writer);


                        /* Service name and form data */

                        renderMenuListItem(ref writer
                            , ClaimServiceNameXrefAndFormDataRecords.MENU_LNK_MANAGE
                            , ClaimServiceNameXrefAndFormDataRecords.SEL_LABEL_MANAGE
                            , ClaimServiceNameXrefAndFormDataRecords.URL_SBS_ALL_MANAGE);

                        /* SpEd Document Templates */

                        renderMenuListItem(ref writer
                            , SpEdDocumentTemplates.MENU_LNK_MANAGE
                            , SpEdDocumentTemplates.SEL_LABEL_MANAGE
                            , SpEdDocumentTemplates.URL_SBS_ALL_MANAGE);

                        /* Known Health Problem Selections */

                        renderManageKnownHealthProblemSelections(ref writer, rd);

                        /* Allergies Selections */

                        renderManageAllergiesSelections(ref writer, rd);

                        /* Insurance Carriers - Manage*/
                        renderMenuListItem(ref writer, InsuranceCarriers.MENU_ID_MANAGE, InsuranceCarriers.SEL_LABEL_MANAGE, InsuranceCarriers.URL_MANAGE);

                        /* Fillable PDFs */

                        renderSBSAllFillablePDFMenu(ref writer, rd);

                        /**** Old Patient Profiles Menu -- Render hidden to preserve compatability ****/

                        renderSubMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION, true);
                        renderMenuListItem(ref writer, @"managesvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_ADD_NEW_OR_EDIT, ServiceJournals.URL_SBS_SAVE_SERVICE_DESCRIPTION, true, true);
                        renderMenuListItem(ref writer, @"editdelsvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_EDIT_DELETE, ServiceJournals.URL_SBS_EDIT_DEL_SERVICE_DESCRIPTION, true, true);
                        renderMenuListItem(ref writer, @"viewsvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_VIEW, ServiceJournals.URL_SBS_SERVICE_DESCRIPTIONS_VIEW, true, true);
                        renderSubMenuListEnd(ref writer);

                        /* Old Orders Menu -- Render hidden to preserve compatability*/

                        renderSubMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_ORDERS, true);
                        renderMenuListItem(ref writer, @"manageordersnewlink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_NEW, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_NEW, true, true);
                        renderMenuListItem(ref writer, @"manageorderseditdeletelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_EDIT_DELETE, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_EDIT_DELETE, true, true);
                        renderMenuListItem(ref writer, @"manageordersviewlink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_VIEW, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_VIEW, true, true);
                        renderSubMenuListEnd(ref writer);

                        renderTopMenuListEnd(ref writer);


                        /*------------------------
                         * Practitioners
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Practitioners");

                        /**** Management ****/

                        renderMenuListItem(ref writer, Practitioners.MENU_ID_MANAGE, Practitioners.SEL_LABEL_MANAGE, Practitioners.URL_USER_ALL_MANAGE);


                        /**** Caseloads ****/

                        renderMenuListItem(ref writer, PractitionerCaseloadMembers.MENU_ID, PractitionerCaseloadMembers.SEL_LABEL_NON_PRAC, PractitionerCaseloadMembers.URL_USER_ALL);

                        /**** Supervision Tracking ****/
                        renderManagePractitionerSupervisionMenu(ref writer, rd);

                        /**** Service record review ****/
                        renderServiceRecordReviewMenu(ref writer, rd, false);

                        renderTopMenuListEnd(ref writer);


                        /*------------------------
                         * Reports
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Reports");

                        renderSubMenuListStart(ref writer, @"Financial");
                        writer.Write(@"<li><a id=""rptclmpaidbycheckdate""           href=""" + MBA.HttpApplication.createLink("rpt_claims_paid.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_WD_1P + @"</a></li>");
                        writer.Write(@"<li><a id=""rptclmpaidbycheckdatecompared""   href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_WD_2P + @"</a></li>");
                        writer.Write(@"<li><a id=""rptclmpaidbyservicedate""         href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_dos.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_1P + @"</a></li>");
                        writer.Write(@"<li><a id=""rptclmpaidbyservicedatecompared"" href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_dos_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_2P + @"</a></li>");
                        writer.Write(@"<li><a id=""rptcombined1on1bypmtdate""        href=""" + MBA.HttpApplication.createLink("rpt_combined_1on1_by_pmt_date.aspx", true) + @""">By Patient for One Practitioner by Payment Date</a></li>");
                        writer.Write(@"<li><a id=""rptcombined1on1bysvcdate""        href=""" + MBA.HttpApplication.createLink("rpt_combined_1on1_by_svc_date.aspx", true) + @""">By Patient for One Practitioner by Service Date</a></li>");
                        writer.Write(@"<li><a id=""rptbyeligpatdos2p""               href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_elig_pat_dos_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_ELIG_PAT_SD_2P + @"</a></li>");
                        renderSubMenuListEnd(ref writer);


                        renderSubMenuListStart(ref writer, @"Production Reports");
                        renderMenuListItem(ref writer, "rptcountofbatchesinprocessbystatus", InputBatchesStatus.SEL_LABEL_RPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS, InputBatchesStatus.URL_RPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS);
                        renderMenuListItem(ref writer, "rptcountbatchesreadytoassignbytypeofwork", InputBatchesStatus.SEL_LABEL_RPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK, InputBatchesStatus.URL_RPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK);
                        renderMenuListItem(ref writer, "rptbatchesinprocess", Clients.SEL_LABEL_RPT_BATCHES_IN_PROCESS, Clients.URL_SBS_ALL_RPT_BATCHES_IN_PROCESS);
                        renderMenuListItem(ref writer, "rptbatchesassignednotdonelink", Clients.SEL_LABEL_RPT_BATCHES_ASSIGNED_NOT_DONE, Clients.URL_SBS_ALL_RPT_BATCHES_ASSIGNED_NOT_DONE);
                        renderMenuListItem(ref writer, "rptbatchesneedingpriorityreview", InputBatchesStatus.SEL_LABEL_RPT_BATCHES_NEEDING_PRIORITY_REVIEW, InputBatchesStatus.URL_RPT_BATCHES_NEEDING_PRIORITY_REVIEW);
                        renderMenuListItem(ref writer, "rptbatchesabt2ageout", InputBatchesStatus.SEL_LABEL_RPT_BATCHES_ABOUT_TO_AGE_OUT, InputBatchesStatus.URL_RPT_BATCHES_ABOUT_TO_AGE_OUT);
                        renderMenuListItem(ref writer, "rptinputstafftraininginprocesslink", InputBatchesStatus.SEL_LABEL_RPT_INPUT_STAFF_TRAINING_IN_PROCESS, InputBatchesStatus.URL_RPT_INPUT_STAFF_TRAINING_IN_PROCESS);
                        renderSubMenuListEnd(ref writer);

                        renderSubMenuListStart(ref writer, @"Potential Lost Reimbursement");
                        renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM_DAILY_OVERVIEW, Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_DAILY_OVERVIEW, Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_DAILY_OVERVIEW);
                        renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM_DAILY_DETAILS, Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_DAILY_DETAILS, Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_DAILY_DETAILS);
                        //renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM_OVERVIEW,          Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_OVERVIEW,                   Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_OVERVIEW);
                        //renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM,                   Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE,                            Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE);
                        //renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM_ORP_DETAILS,       Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_ORP_DETAILS,                Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_ORP_DETAILS);
                        renderMenuListItem(ref writer, Claims.MENU_ID_RPT_POT_LOST_REIM_MIS_ASSMT_DETAILS, Claims.SEL_LABEL_RPT_MISSING_ASSESSMENTS_POT_REIMBURSEMENT_DETAILS, Claims.URL_SBS_ALL_RPT_MISSING_ASSESSMENTS_WITH_POT_REIMBURSEMENT_DETAILS);
                        renderSubMenuListEnd(ref writer);

                        /* renderSubMenuListStart(ref writer, @"SpEdCare Weekly");

                           renderMenuListItem(ref writer, "rptspedcareweekly",         Clients.SEL_LABEL_RPT_SPEDCARE_WEEKLY_REPORT, Clients.URL_SBS_ALL_RPT_SPEDCARE_WEEKLY_REPORT);*/
                        renderMenuListItem(ref writer, "rptspedcareweeklyextended", Clients.SEL_LABEL_RPT_SPEDCARE_WEEKLY_REPORT_EXTENDED, Clients.URL_SBS_ALL_RPT_SPEDCARE_WEEKLY_REPORT_EXTENDED);

                        /*renderSubMenuListEnd(ref writer);*/

                        /* Recent denials */

                        renderSubMenuListStart(ref writer, Claims.SEL_LABEL_RECENT_DENIALS);

                        renderMenuListItem(ref writer, Claims.MENU_ID_RPT_DENIALS_SUMMARY
                                                     , Claims.SEL_LABEL_RPT_RECENT_DENIALS_SUMMARY
                                                     , Claims.URL_RPT_RECENT_DENIALS_SUMMARY);

                        renderMenuListItem(ref writer, Claims.MENU_ID_RPT_DENIALS_DETAILS
                                                     , Claims.SEL_LABEL_RPT_RECENT_DENIALS_DETAILS
                                                     , Claims.URL_RPT_RECENT_DENIALS_DETAILS);

                        renderSubMenuListEnd(ref writer);

                        renderSubMenuListStart(ref writer, @"Claims Transmissions");

                        renderMenuListItem(ref writer, "clmswaitingfortxsummaryrptlink", Claims.SEL_LABEL_RPT_CLAIMS_WAITING_FOR_NEXT_TRANSMISSION_SUMMARY, Claims.URL_CLAIMS_WAITING_FOR_NEXT_TRANSMISSION_SUMMARY_REPORT);
                        renderMenuListItem(ref writer, "clmstxsummaryrptlink", Claims.SEL_LABEL_RPT_CLAIM_TRANSMISSION_SUMMARY, Claims.URL_CLAIM_TRANSMISSION_SUMMARY_REPORT);

                        renderSubMenuListEnd(ref writer);

                        writer.Write(@"<li><a id=""viewsvcsrendcomponepat""          href=""" + MBA.HttpApplication.createLink(ServiceRecords.PAGE_SBSC_ALL_SVC_COMP_REPT, true) + @""">" + ServiceRecords.SEL_LABEL_PLAN_SVC_COMP_REPT + @"</a></li>");
                        renderMenuListItem(ref writer, "rptorpdocslink", ORPDocuments.SEL_LABEL_RPT, ORPDocuments.URL_SBS_VIEW);
                        writer.Write(@"<li><a id=""viewclmslink""                    href=""" + MBA.HttpApplication.createLink("rpt_claims_view.aspx", true) + @""">Claims View</a></li>");

                        /**** Submission Reports ****/

                        renderMenuListItem(ref writer, ServicesByPracRpt.MENU_ID, ServicesByPracRpt.SEL_LABEL, ServicesByPracRpt.URL_USER_ALL_RPT);

                        /**** Dept Svcs Review ****/

                        renderMenuListItem(ref writer, PractitionerDepartmentServicesReview.MENU_ID, PractitionerDepartmentServicesReview.SEL_LABEL, PractitionerDepartmentServicesReview.URL_USER_ALL_RPT);

                        /**** Efficiency ****/

                        renderMenuListItem(ref writer, PractitionersEfficiency.MENU_ID, PractitionersEfficiency.SEL_LABEL, PractitionersEfficiency.URL_USER_ALL_RPT);

                        writer.Write(@"<li><a id=""rptpracrevlink""            href=""" + MBA.HttpApplication.createLink("rpt_prac_review.aspx", true) + @""">Practitioner Review</a></li>");
                        writer.Write(@"<li><a id=""viewworknotreceivedlink""         href=""" + MBA.HttpApplication.createLink("rpt_client_work_not_received.aspx", true) + @""">Client Work Not Received</a></li>");
                        //writer.Write(@"<li><a id=""viewcrcsclaimslink""              href=""" + MBA.HttpApplication.createLink("rpt_crc_claims.aspx", true) + @""">CRCS Claims</a></li>");
                        writer.Write(@"<li><a id=""rptpracleamaaxrefsetupissues""    href=""" + MBA.HttpApplication.createLink("rpt_prac_lea_maa_xref_issues.aspx", true) + @""">Miscoded MAA Participants</a></li>");
                        writer.Write(@"<li><a id=""rptpracsupsvcsstillheld""         href=""" + MBA.HttpApplication.createLink(ServiceRecordsApproval.PAGE_RPT_SVC_REC_PENDING_APPROVAL_OR_HELD, true) + @""">" + ServiceRecordsApproval.SEL_LABEL_PRAC_SVC_REC_PENDING_APPROVAL_OR_HELD + @"</a></li>");
                        writer.Write(@"<li><a id=""rptfilesuploaded""                href=""" + MBA.HttpApplication.createLink("rpt_file_uploads_view.aspx", true) + @""">Files Uploaded to SpEdCare</a></li>");

                        writer.Write(@"<li><a id=""rpt_possible_pat_merges_needed""                         href=""" + MBA.HttpApplication.createLink("rpt_possible_pat_merges_needed.aspx", true) + @""">Possible Patient Merges Needed</a></li>");


                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Report Distribution
                         *------------------------*/

                        renderTopMenuListStart(ref writer, Publications.SEL_LABEL);

                        /**** Subscribers *****/

                        renderSubMenuListStart(ref writer, Subscribers.SEL_LABEL);
                        writer.Write(@"<li><a id=""addnewsbrlink""        href=""" + MBA.HttpApplication.createLink("sbs_all_subscriber_save.aspx", true) + @""">" + Subscribers.SEL_LABEL_ADD + @"</a></li>");
                        writer.Write(@"<li><a id=""viewsbrlink""          href=""" + MBA.HttpApplication.createLink("sbs_all_subscribers_view.aspx", true) + @""">" + Subscribers.SEL_LABEL_VIEW + @"</a></li>");
                        writer.Write(@"<li><a id=""editdelsbrlink""       href=""" + MBA.HttpApplication.createLink("sbs_all_subscribers_edit_delete.aspx", true) + @""">" + Subscribers.SEL_LABEL_EDIT_DELETE + @"</a></li>");
                        renderSubMenuListEnd(ref writer);

                        /**** Subscriptions ****/

                        renderSubMenuListStart(ref writer, Subscriptions.SEL_LABEL);
                        writer.Write(@"<li><a id=""addnewsublink""        href=""" + MBA.HttpApplication.createLink("sbs_all_subscription_save.aspx", true) + @""">" + Subscriptions.SEL_LABEL_ADD + @"</a></li>");
                        writer.Write(@"<li><a id=""viewsublink""          href=""" + MBA.HttpApplication.createLink("sbs_all_subscriptions_view.aspx", true) + @""">" + Subscriptions.SEL_LABEL_VIEW + @"</a></li>");
                        writer.Write(@"<li><a id=""editdelsublink""       href=""" + MBA.HttpApplication.createLink("sbs_all_subscriptions_edit_delete.aspx", true) + @""">" + Subscriptions.SEL_LABEL_EDIT_DELETE + @"</a></li>");
                        renderSubMenuListEnd(ref writer);

                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Service Journals
                         *------------------------*/

                        renderTopMenuListStart(ref writer, ServiceJournals.SEL_LABEL);
                        writer.Write(@"<li><a id=""svcjournalrecordproclink""   href=""" + MBA.HttpApplication.createLink(ServiceJournals.URL_USER_ALL_OPEN_NEW, true, new NameValue(ServiceJournals.PARAM_EVENT_TYPE_ID, ServiceJournals.VAL_EVENT_TYPE_REC_PROC)) + @""">" + ServiceJournals.SEL_LABEL_RECORD_PROC + @"</a></li>");
                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Service Records
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Service Records");

                        renderMenuListItem(ref writer
                                             , ServiceRecords.MENU_ID_MANAGE
                                             , ServiceRecords.SEL_LABEL_MANAGE
                                             , ServiceRecords.URL_USER_ALL_SVC_RECS_MANAGE);

                        writer.Write(@"<li><a id=""addnewsvcreclink""            href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_save.aspx", true) + @""">Record New Service Records</a></li>");
                        writer.Write(@"<li><a id=""batchnewsvcreclink""          href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_save.aspx", true) + @""">Record Multiple New Service Records</a></li>");
                        writer.Write(@"<li><a id=""batchnewsvcrecmultiencountlink"" href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_save_multi_encounter.aspx", true) + @""">Record Multiple New - Multiple Encounters for Service Records</a></li>");
                        // renderMenuListItem(ref writer, ServiceRecords.MENU_LINK_SVC_REC_SAVE_NEW_ALL_NON_PRAC, ServiceRecords.SEL_LABEL_SVC_REC_SAVE_NEW_ALL, ServiceRecords.URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC);
                        writer.Write(@"<li><a id=""viewsvcrecslink""     href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_view.aspx", true) + @""">View Service Records</a></li>");
                        writer.Write(@"<li><a id=""editdelsvcrecslink""  href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_edit_delete.aspx", true) + @""">" + ServiceRecords.SEL_LABEL_EDIT_SVCREC + @"</a></li>");
                        writer.Write(@"<li><a id=""batcheditdelsvcrecslink""  href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_edit_delete.aspx", true) + @""">Service Records Batch Delete</a></li>");
                        // writer.Write(@"<li><a id=""viewsvcrecssvcnoteslink""  href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_svcnote_view.aspx", true) + @""">View Progress Notes Saved in SpEdCare</a></li>");

                        /* Vision and hearing screening */

                        renderMenuListItem(ref writer, ServiceRecords.MENU_LINK_VISION_HEARING_SCREEN, ServiceRecords.SEL_LABEL_VISION_HEARING_SCREEN, ServiceRecords.URL_USER_ALL_VISION_AND_HEARING_SCREEN);

                        renderMenuListItem(ref writer, ClaimDenialResubmissions.MENU_ID_MANGE_DENIED_CLAIMS, ClaimDenialResubmissions.SEL_LABEL_MANAGE_DENIED_CLAIMS, ClaimDenialResubmissions.URL_SBS_ALL_MANAGE_DENIED_CLAIMS);
                        renderMenuListItem(ref writer, @"svcrecorpdocasclink", @"Associate ORP Documents", @"sbs_all_orp_doc_svc_rec_asc.aspx");
                        renderMenuListItem(ref writer, ClaimsRetroactiveForSpa.MENU_ID_AUTHORIZATION, ClaimsRetroactiveForSpa.SEL_LABEL_AUTHORIZATION, ClaimsRetroactiveForSpa.URL_USER_ALL_AUTHORIZATION);

                        /* Import service records*/

                        renderMenuListItem(ref writer
                                            , ServiceRecordsDataImports.MENU_ID_IMPORT
                                            , ServiceRecordsDataImports.SEL_LABEL_IMPORT
                                            , ServiceRecordsDataImports.URL_PAGE_IMPORT);

                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * Practice Office
                         *------------------------*/

                        renderPracticeOfficeMenu(ref writer, rd);

                        /*------------------------
                         * RMTS
                         *------------------------*/

                        // Constants.ROLE_ADMIN  
                        renderRmtsMenu(ref writer, rd);

                        /*------------------------
                         * CRCS
                         *------------------------*/

                        renderTopMenuListStart(ref writer, CrcsCommon.SEL_LABEL);
                        renderMenuListItem(ref writer, CrcsCommon.MENU_ID_MANAGE, CrcsCommon.SEL_LABEL_MANAGE, CrcsCommon.URL_MANAGE);
                        renderMenuListItem(ref writer, CrcsCommon.MENU_ID_CLAIMS_REPORT, CrcsCommon.SEL_LABEL_CLAIMS_REPORT, CrcsCommon.URL_CLAIMS_REPORT);
                        renderTopMenuListEnd(ref writer);


                        /*------------------------
                         * Users
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Users");
                        writer.Write(@"<li><a id=""addnewuserlink""        href=""" + MBA.HttpApplication.createLink("sbs_all_user_save.aspx", true) + @""">Record New User</a></li>");
                        writer.Write(@"<li><a id=""viewuserlink""          href=""" + MBA.HttpApplication.createLink("sbs_all_user_view.aspx", true) + @""">View Users</a></li>");
                        writer.Write(@"<li><a id=""editdeluserslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_user_edit_delete.aspx", true) + @""">Edit or Delete Users</a></li>");
                        renderMenuListItem(ref writer, Users.MENU_ID_USER_ALL_SAVE, Users.SEL_LABEL_SAVE, Users.URL_USER_ALL_SAVE);
                        renderTopMenuListEnd(ref writer);

                        /*------------------------
                         * X12 Tools
                         *------------------------*/

                        renderX12ToolsMenu(ref writer);

                        /*------------------------
                         * Utility & Misc
                         *------------------------*/

                        renderTopMenuListStart(ref writer, @"Utility");


                        /* Claim procedure service fee updates */
                        renderMenuListItem(ref writer
                                           , ClaimProcedureFees.MENU_ID_SERVICE_FEES_UPDATE
                                           , ClaimProcedureFees.SEL_LABEL_SERVICE_FEES_UPDATE
                                           , ClaimProcedureFees.URL_SERVICE_FEES_UPDATE);

                        //renderMenuListItem(ref writer, @"svcrecsviewalltestlink", @"Service Records View (Test)", @"user_all_service_records_view.aspx");
                        // StructuredDataImportFilesPatientData.URL_PAGE_USER_ALL
                        /* Claim Management */

                        renderSubMenuListStart(ref writer, @"Claim Management");
                        //              writer.Write(@"<li><a id=""addnewclaimprocedurelink""        href=""" + MBA.HttpApplication.createLink("sbs_mgmt_claim_procedures_save.aspx", true) + @""">Record New Procedure Code</a></li>");
                        //              writer.Write(@"<li><a id=""viewclaimprocedureslink""         href=""" + MBA.HttpApplication.createLink("sbs_all_claim_procedures_view.aspx", true) + @""">View Procedure Codes</a></li>");
                        //              writer.Write(@"<li><a id=""editdelclaimprocedureslink""      href=""" + MBA.HttpApplication.createLink("sbs_mgmt_claim_procedures_edit_delete.aspx", true) + @""">Edit or Delete Procedure Code</a></li>");
                        //              writer.Write(@"<li><a id=""addnewprocedurefeelink""          href=""" + MBA.HttpApplication.createLink("sbs_mgmt_claim_procedure_fees_save.aspx", true) + @""">Record New Procedure Fee</a></li>");
                        //              writer.Write(@"<li><a id=""viewclaimprocedurefeeslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_claim_procedure_fees_view.aspx", true) + @""">View Procedure Fees</a></li>");
                        //              writer.Write(@"<li><a id=""editdelclaimprocedurefeeslink""   href=""" + MBA.HttpApplication.createLink("sbs_mgmt_claim_procedure_fees_edit_delete.aspx", true) + @""">Edit or Delete Procedure Fee</a></li>");
                        writer.Write(@"<li><a id=""addnewclaimexceptionslink""       href=""" + MBA.HttpApplication.createLink("sbs_all_claim_processing_exception_save.aspx", true) + @""">Record New Claim Exception</a></li>");
                        writer.Write(@"<li><a id=""viewclaimexceptionslink""         href=""" + MBA.HttpApplication.createLink("sbs_all_claim_processing_exceptions_view.aspx", true) + @""">View Claim Exceptions</a></li>");
                        writer.Write(@"<li><a id=""editdelclaimexceptionslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_claim_processing_exception_edit_delete.aspx", true) + @""">Edit or Delete Claim Exception</a></li>");
                        renderSubMenuListEnd(ref writer);

                        /* Production */

                        renderInputBatchesMenu(writer, rd, false);

                        /**** System Admin ****/

                        renderSubMenuListStart(ref writer, @"System Admin Tools");

                        renderMenuListItem(ref writer, @"sysadminviewloginslink", @"View Current Logins", @"sbs_system_admin_view_current_logins.aspx");
                        renderMenuListItem(ref writer, @"sysadminlink", @"Test Third Party API", @"sbs_system_admin.aspx");
                        renderMenuListItem(ref writer, @"sysadmintelecomm", @"Telecomm Server Admin", @"sbs_system_admin_telecomm_server.aspx");
                        renderMenuListItem(ref writer, @"sysadmincomponenttestlnk", @"Component Testing", @"user_all_component_test.aspx");
                        renderMenuListItem(ref writer, @"ariesapitestlnk", @"Aries API Test", @"user_all_aries_api_test.aspx");
                        renderMenuListItem(ref writer, @"ariesapicodesetlookuplnk", @"Aries API Code Set Lookup", @"user_all_aries_api_code_set_lookup.aspx");
                        renderSubMenuListEnd(ref writer);
                        renderTopMenuListEnd(ref writer);

                        break;
                    }

                default:
                    {
                        // No default menu
                        break;
                    }
            }

        });


        /*-------------------------------
         * Header public
         *------------------------------*/

        static renderHeaderPublic rheaderPublic = new renderHeaderPublic(delegate (string homelink, ref HtmlTextWriter writer)
        {

        });

        /*-------------------------------
         * Header private
         *------------------------------*/

        static renderHeaderPrivate rheaderPrivate = new renderHeaderPrivate(delegate (string homelink, string helplink, ref SqlConnection dbConnUser, ref SqlConnection dbConnApp, ref DetailsLog log, ref RequestResponse rd, ref UserInfo uInfo, ref HtmlTextWriter writer) {


        });

        /*-------------------------------
         * Public footer
         *------------------------------*/

        static renderFooterPublic rfooterPublic = new renderFooterPublic(delegate (ref HtmlTextWriter writer)
        {
        });


        /*-------------------------------
         * Private footer
         *------------------------------*/

        static renderFooterPrivate rfooterPrivate = new renderFooterPrivate(delegate (ref HtmlTextWriter writer, string roleNameLower) {
        });


        /*-------------------------------
         * To Do Messages for User
         *------------------------------*/

        static handleAppSpecificResponse rAppUserToDoMsgs = new handleAppSpecificResponse(delegate (HttpRequest req, HttpResponse rsp, ref RequestResponse rd, ref UserInfo uInfo, ref HtmlTextWriter writer) {

        });

        /* Not used but included for refactoring purposes */

        static handleAppendingUserSpecificNotifications aUserSpecificNotifications =
        new handleAppendingUserSpecificNotifications(delegate (ref RequestResponse rd, ref UserInfo uInfo, ref MBA.WebUI3Controls.Notifications notificationsControl) {
        });
        public static void renderInputBatchesMenu(HtmlTextWriter writer, RequestResponse rd, bool topMenu)
        {
            if (topMenu)
                renderTopMenuListStart(ref writer, @"Production");
            else
                renderSubMenuListStart(ref writer, @"Production");

            renderMenuListItem(ref writer
                                , InputBatchesCommon.MENU_ID_MANAGE
                                , InputBatchesCommon.SEL_LABEL_MANAGE
                                , InputBatchesCommon.URL_MANAGE);

            renderMenuListItem(ref writer
                                 , ServiceRecords.MENU_ID_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC
                                 , ServiceRecords.SEL_LABEL_SVC_REC_SAVE_NEW_ALL
                                 , ServiceRecords.URL_SBS_ALL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC);

            renderMenuListItem(ref writer
                                , ServiceRecordsDataIncomplete.MENU_LNK_USER_ALL_MANAGE
                                , ServiceRecordsDataIncomplete.SEL_LABEL_MANAGE
                                , ServiceRecordsDataIncomplete.URL_MANAGE);

            /*writer.Write(@"<li><a id=""traininglink"" href=""" + MBA.HttpApplication.createLink("sbs_all_training.aspx", true) + @""" target=""_blank"">Production Documents</a></li>");*/

            if (topMenu)
                renderTopMenuListEnd(ref writer);
            else
                renderSubMenuListEnd(ref writer);

        }

        public static void renderX12ToolsMenu(ref HtmlTextWriter writer)
        {

            renderTopMenuListStart(ref writer, @"X12 Tools");

            /*renderMenuListItem ( ref writer
                                , "cybhiposting835lnk"
                                , "CYBHI 835 Posting"
                                , "sbs_mgmt_cybhi_835_posting.aspx");      
            */
            renderMenuListItem(ref writer
                                , "x12tool5010277fileviewerlnk"
                                , "X12 5010 277 File Viewer"
                                , "user_all_x12_5010_277_file_viewer.aspx");

            renderMenuListItem(ref writer
                                , "x12tool5010835fileviewerlnk"
                                , "X12 5010 835 File Viewer"
                                , "user_all_x12_5010_835_file_viewer.aspx");

            /* EDI X12 file viewer */

            renderMenuListItem(ref writer
                                , "x12toolsedifileviewerlnk"
                                , "X12 EDI File Viewer"
                                , "user_all_x12_edi_file_viewer.aspx");

            renderSubMenuListEnd(ref writer);
        }

        public static void renderSelpaMenu(HtmlTextWriter writer, RequestResponse rd)
        {
            renderTopMenuListStart(ref writer, @"SELPAS");
            renderMenuListItem(ref writer, CdeComplianceCommon.MENU_ID_FOR_SELPA_MANAGE, CdeComplianceCommon.SEL_LABEL_MANAGE, CdeComplianceCommon.URL_FOR_SELPA_MANAGE);
            renderTopMenuListEnd(ref writer);
        }

        public static void renderTimeKeeperMenu(HtmlTextWriter writer, RequestResponse rd)
        {
            /*----------------------
            * Time Keeper 
            * ---------------------*/
            if (rd.wu.usr.timeSheetUserInfo != null)
            {
                renderTopMenuListStart(ref writer, ManPages.SEL_TIMEKEEPER);
                writer.Write(@"<li><a id=""timekeeperentertimeweekly"" href=""" + MBA.HttpApplication.createLink("WebFormTimeEntry.aspx", true) + @""">Weekly Time Entries</a></li>");
                writer.Write(@"<li><a id=""timekeeperentertimedaily"" href=""" + MBA.HttpApplication.createLink("InsertOrUpdateTimeEntry.aspx", true) + @""">Daily Time Entries</a></li>");
                writer.Write(@"<li><a id=""timekeeperschedule"" href=""" + MBA.HttpApplication.createLink("WebFormTimeEntrySchedule.aspx", true) + @""">Enter or Modify Schedule</a></li>");
                writer.Write(@"<li><a id=""timekeeperviewerschedule"" href=""" + MBA.HttpApplication.createLink("TimeKeeperEmployeeScheduleViewer.aspx", true) + @""">Employees Schedule Viewer</a></li>");
                writer.Write(@"<li><a id=""timekeepermodifyfavorites"" href=""" + MBA.HttpApplication.createLink("SetUpFavorites.aspx", true) + @""">Modify Favorites<br/>(Clients & Tasks)</a></li>");
                writer.Write(@"<li><a id=""timekeeperscheduleadmin"" href=""" + MBA.HttpApplication.createLink("TimeEntryScheduleAdmin.aspx", true) + @""">Task and Schedule Template Manager</a></li>");

                writer.Write(@"<li><a id=""useralltimekepperpanel"" href=""" +
                        MBA.HttpApplication.createLink("user_all_timekeeper_panel.aspx", true) +
                        @""">Timekeeper User Panel</a></li>");

                renderSubMenuListStart(ref writer, @"Reports");

                writer.Write(@"<li><a id=""timekeepereportsemployeetimeentryandschedulereport"" " +
                    @"href=""" + MBA.HttpApplication.createLink("EmployeeTimeEntryAndScheduleReport.aspx", true) +
                    @""">Time Entry and Schedule Report</a></li>");

                //Removed per Vic's request
                // writer.Write(@"<li><a id=""timekeepereportsemployeetimeperiodreviewreport"" href=""" +
                //    MBA.HttpApplication.createLink("TimeEntryReport.aspx", true) +
                //    @""">Employee Time Period Review Report</a></li>");

                writer.Write(@"<li><a id=""timekeepereportsschedulereport"" href=""" +
                    MBA.HttpApplication.createLink("ScheduleReport.aspx", true) +
                    @""">Schedule Report</a></li>");



                // Manager's and admin report
                //
                if ((rd.wu.usr.timeSheetUserInfo.roleID == 1) || (rd.wu.usr.timeSheetUserInfo.roleID == 3))
                {
                    writer.Write(@"<li><a id=""timekeeperpayrollreport"" href=""" +
                        MBA.HttpApplication.createLink("PayrollReport1.aspx", true) +
                        @""">Payroll Report</a></li>");

                    renderMenuListItem(ref writer, TimekeeperAccountabilityRpt.PER_MIN_RPT_VIEWPAGE_MENU_ID, TimekeeperAccountabilityRpt.SEL_LABEL_PER_MIN_RPT, TimekeeperAccountabilityRpt.PER_MIN_RPT_VIEWPAGE_BASE);


                    writer.Write(@"<li><a id=""timekeepereportstimeperiodreviewreport"" href=""" +
                        MBA.HttpApplication.createLink("ManagerTimeEntryAndScheduleReport.aspx", true) +
                        @""">Manager's Time Period Review Report</a></li>");


                    /*== SBC TBD
                    writer.Write(@"<li><a id=""timekeepereportscaccountingeport"" href=""" +
                        MBA.HttpApplication.createLink("TimeEntryReport.aspx", true) +
                        @""">Accounting Report</a></li>");
                    writer.Write(@"<li><a id=""timekeepereportscclientreport"" href=""" +
                        MBA.HttpApplication.createLink("TimeEntryReport.aspx", true) +
                        @""">Client Report</a></li>");
                    writer.Write(@"<li><a id=""timekeepereportscaccountingeport"" href=""" +
                        MBA.HttpApplication.createLink("TimeEntryReport.aspx", true) +
                        @""">Accounting Report</a></li>");
                    */
                }
                renderSubMenuListEnd(ref writer);

                renderSubMenuListStart(ref writer, @"Management");
                writer.Write(@"<li><a id=""timekeeperautoscheduler"" href=""" +
                    MBA.HttpApplication.createLink("TimeEntryScheduleAdmin.aspx", true) +
                    @""">Task and Schedule Template Manager</a></li>");
                // Manager and admin only
                //
                if ((rd.wu.usr.timeSheetUserInfo.roleID == 1) || (rd.wu.usr.timeSheetUserInfo.roleID == 3))
                {

                    writer.Write(@"<li><a id=""timekeepermanageusers"" href=""" +
                        MBA.HttpApplication.createLink("ManageEmployees.aspx", true) +
                        @""">Manage Users</a></li>");
                    writer.Write(@"<li><a id=""timekeepermanagetasks"" href=""" +
                        MBA.HttpApplication.createLink("TimeEntryTaskManagement.aspx", true) +
                        @""">Manage Tasks</a></li>");
                    writer.Write(@"<li><a id=""timekeepermanageemployeefavorites"" href=""" +
                        MBA.HttpApplication.createLink("timekeeper_admin_manage_favorites_for_employees.aspx", true) +
                        @""">Manage Favorites For Employees</a></li>");
                    writer.Write(@"<li><a id=""timekeeperorganizationmanagement"" href=""" +
                        MBA.HttpApplication.createLink("OranizationManagement.aspx", true) +
                        @""">Organization Management</a></li>");
                    writer.Write(@"<li><a id=""timekeeperclientnmanagement"" href=""" +
                        MBA.HttpApplication.createLink("ClientOranizationManagement.aspx", true) +
                        @""">Client Management</a></li>");
                    writer.Write(@"<li><a id=""timekeeperholidaymanagement"" href=""" +
                        MBA.HttpApplication.createLink("TimeEntryHolidayAdmin.aspx", true) +
                        @""">Holiday Management</a></li>");
                    writer.Write(@"<li><a id=""timeverificationadmin"" href=""" +
                        MBA.HttpApplication.createLink("TimeVerificationAdmin.aspx", true) +
                        @""">Employee Verification Management</a></li>");


                }

                //
                if ((rd.wu.usr.timeSheetUserInfo.roleID != 1) && (rd.wu.usr.timeSheetUserInfo.roleID != 3) && (
                    /* Check SpEdCare role */
                    ((rd.wu.usr.roleID == Constants.ROLE_ADMIN_ID) || (rd.wu.usr.roleID == Constants.ROLE_INPUT_STAFF_ID))
                    ))

                    writer.Write(@"<li><a id=""timekeepermanageemployeefavorites"" href=""" +
        MBA.HttpApplication.createLink("timekeeper_admin_manage_favorites_for_employees.aspx", true) +
        @""">Manage Favorites For Employees</a></li>");

                renderSubMenuListEnd(ref writer);

                renderTopMenuListEnd(ref writer);
            }
        }

        public static void renderManageSitesMenu(ref HtmlTextWriter writer, RequestResponse rd)
        {
            /* Manage sites */
            renderMenuListItem(ref writer, Sites.MENU_ID_MANAGE, Sites.SEL_LABEL_MANAGE, Sites.URL_MANAGE);

            /* Old menu options.  Hidden for backwards compatibility and redirecting to new manage screen */

            renderTopMenuListStart(ref writer, Sites.SEL_LABEL, true);
            renderMenuListItem(ref writer, Sites.MENU_ID_SAVE, Sites.SEL_LABEL_SAVE, Sites.URL_SAVE);
            renderMenuListItem(ref writer, Sites.MENU_ID_VIEW, Sites.SEL_LABEL_VIEW, Sites.URL_MANAGE);
            renderMenuListItem(ref writer, Sites.MENU_ID_EDIT_DEL, Sites.SEL_LABEL_EDIT_DELETE, Sites.URL_MANAGE);
            renderTopMenuListEnd(ref writer);

        }

        public static void renderRmtsMenu(ref HtmlTextWriter writer, RequestResponse rd)
        {

            var user_role_lowered = rd.wu.usr.roleName.ToLower();

            renderTopMenuListStart(ref writer, @"RMTS");

            // Constants.ROLE_SBS_ALL_LEA_COORD
            if (Constants.ROLE_SBS_ALL_LEA_COORD.Contains(user_role_lowered))
                renderMenuListItem(ref writer, RmtsParticipationRosters.MENU_LINK_MANAGE, RmtsParticipationRosters.SEL_LABEL_MANAGE, RmtsParticipationRosters.URL_MANAGE);
            // "user_all_rmts_participation_roster_manage.aspx"                                                                                                                   // "user_all_rmts_participation_roster_manage.aspx""user_all_rmts_participation_roster_manage.aspx"

            //Constants.ROLE_SBS_ALL
            if (Constants.ROLE_SBS_ALL.Contains(user_role_lowered))
            {
                renderMenuListItem(ref writer
                                     , StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.MENU_ID_MANAGE
                                     , StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.SEL_LABEL_MANAGE
                                     , StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.URL_PAGE_MANAGE_USER_ALL);

                renderMenuListItem(ref writer
                                     , RMTSActivityCodeChangeReasons.MENU_ID_MANAGE
                                     , RMTSActivityCodeChangeReasons.SEL_LABEL_MANAGE
                                     , RMTSActivityCodeChangeReasons.URL_PAGE_MANAGE_USER_ALL);
            }
            // "user_all_rmts_participants_not_in_spedcare_manage.aspx"

            // Constants.ROLE_RMTS_ADMINS
            if (Constants.ROLE_RMTS_ADMINS.Contains(user_role_lowered))
            {
                renderMenuListItem(ref writer, RmtsMoments.MENU_LINK_RPT_RMTS_MOMENT_SERVICE_RECORDS, RmtsMoments.SEL_LABEL_MANAGE, RmtsMoments.URL_MANAGE);
                // "user_all_rmts_moment_service_records_manage.aspx"
                // Constants.ROLE_ADMIN_CONSULTANT_LEA_COORD
                renderMenuListItem(ref writer, RmtsMoments.MENU_LINK_RMTS_REVIEW, RmtsMoments.SEL_LABEL_REVIEW, RmtsMoments.URL_REVIEW);
            }
            // "user_all_rmts_moment_pcal_review.aspx"
            renderTopMenuListEnd(ref writer);

        }

        public static void renderManageKnownHealthProblemSelections(ref HtmlTextWriter writer, RequestResponse rd)
        {
            renderMenuListItem(ref writer
                                 , KnownHealthProblems.MENU_LNK_SBS_ALL_MANAGE
                                 , KnownHealthProblems.SEL_LABEL_MANAGE
                                 , KnownHealthProblems.URL_SBS_ALL_MANAGE
                                 , true
                                 , false);

        }

        public static void renderManageAllergiesSelections(ref HtmlTextWriter writer, RequestResponse rd)
        {
            renderMenuListItem(ref writer
                                 , Allergies.MENU_LNK_SBS_ALL_MANAGE
                                 , Allergies.SEL_LABEL_MANAGE
                                 , Allergies.URL_SBS_ALL_MANAGE
                                 , true
                                 , false);

        }

        public static void renderSBSAllFillablePDFMenu(ref HtmlTextWriter writer, RequestResponse rd)
        {

            /*renderMenuListItem ( ref writer
                                 , FillablePdfs.MENU_LNK_SBS_ALL_MANAGE
                                 , FillablePdfs.SEL_LABEL_MANAGE
                                 , FillablePdfs.URL_SBS_ALL_MANAGE
                                 , true
                                 , false);*/
        }

        public static void renderPracticeOfficeMenu(ref HtmlTextWriter writer, RequestResponse rd)
        {
            /* If user does not have access to anything in this menu, exit */

            if (!PracticeOfficeCommon.userHasAccessToPracticeOffices(rd)) return;

            /* Practice office */
            renderTopMenuListStart(ref writer, PracticeOfficeCommon.SEL_LABEL);

            /* Health services */

            if (Spedmon.PracticeOfficeCommon.userHasAccessToHealthServicesPracticeOffice(rd))
            {
                /* If not a prac then render this as a sub menu */

                if (rd.wu.usr.roleID != Constants.ROLE_LEA_PROVIDER_ID)
                {
                    renderSubMenuListStart(ref writer, PracticeOfficeCommon.SEL_LABEL_HEALTH_SERVICES_BASE);
                }

                /* Render health service menu options */

                if (Spedmon.PracticeOfficeCommon.userHasAccessToManageHealthServicesPracticeOfficeVisitReasons(rd))
                {
                    renderMenuListItem(ref writer
                                        , PracticeOfficeCommon.MENU_LNK_VISIT_REASONS_MANAGE(Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES)
                                        , PracticeOfficeCommon.SEL_LABEL_VISIT_REASONS_MANAGE(Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES, false)
                                        , PracticeOfficeCommon.URL_VISIT_REASONS_MANAGE(Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES)
                                        , false
                                        , false
                                        , true);
                }

                if (Spedmon.PracticeOfficeCommon.userHasAccessToManageHealthServicesPracticeOfficeKiosks(rd))
                {
                    renderMenuListItem(ref writer
                                        , PracticeOfficeCommon.MENU_LNK_KIOSK_MANAGE(Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES)
                                        , PracticeOfficeCommon.SEL_LABEL_KIOSK_MANAGE(Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES, false)
                                        , PracticeOfficeCommon.URL_KIOSK_MANAGE(Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES)
                                        , false
                                        , false
                                        , true);
                }

                renderMenuListItem(ref writer
                                   , PracticeOfficeCommon.MENU_LNK_WAITING_ROOM(Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES)
                                   , PracticeOfficeCommon.SEL_LABEL_WAITING_ROOM(Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES, false)
                                   , PracticeOfficeCommon.URL_WAITING_ROOM_MANAGE(Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES)
                                   , false
                                   , false
                                   , true);

                renderMenuListItem(ref writer
                                   , PracticeOfficeCommon.MENU_LNK_COMPLETED_VISITS(Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES)
                                   , PracticeOfficeCommon.SEL_LABEL_COMPLETED_VISITS(Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES, false)
                                   , PracticeOfficeCommon.URL_COMPLETED_VISITS_MANAGE(Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES)
                                   , false
                                   , false
                                   , true);

                if (rd.wu.usr.roleID != Constants.ROLE_LEA_PROVIDER_ID)
                {
                    renderSubMenuListEnd(ref writer);
                }


            } /* Health Services */

            /* Visit resolutions (these are not practice family specific) */

            if (Spedmon.PracticeOfficeCommon.userHasAccessToManagePracticeOfficeVisitResolutions(rd))
            {
                renderMenuListItem(ref writer
                                    , PracticeOfficeCommon.MENU_LNK_VISIT_RESOLUTIONS_MANAGE()
                                    , PracticeOfficeCommon.SEL_LABEL_VISIT_RESOLUTIONS_MANAGE(false)
                                    , PracticeOfficeCommon.URL_VISIT_RESOLUTIONS_MANAGE()
                                    , false
                                    , false
                                    , true);
            }

            renderTopMenuListEnd(ref writer); /*  Practice office */

        }

        public static void renderManagePractitionerSupervisionMenu(ref HtmlTextWriter writer, RequestResponse rd)
        {
            if (PractitionerDirectSupervisors.userHasAccess(ref rd))
            {
                renderMenuListItem(ref writer, PractitionerDirectSupervisors.MENU_LINK_MANAGE, PractitionerDirectSupervisors.SEL_LABEL_MANAGE, PractitionerDirectSupervisedSupervisors.URL_USER_ALL_MANAGE);
            }
        }
        public static void renderServiceRecordReviewMenu(ref HtmlTextWriter writer, RequestResponse rd, bool topMenu)
        {
            bool _userHasAccessToType10 = ServiceRecordsApproval.userHasAccess(rd);
            bool _userHasAccessToType20 = CybhiServiceRecordsOrpReviews.userHasAccess(rd);
            bool _userHasAccessToType30 = ServiceRecordsInternalReviews.userHasAccess(rd);

            if ((_userHasAccessToType10 == true) || (_userHasAccessToType20 == true) || (_userHasAccessToType30 == true))
            {

                if (topMenu == true)
                {
                    renderTopMenuListStart(ref writer, ServiceRecordsApproval.SEL_LABEL);
                }
                else
                {
                    renderSubMenuListStart(ref writer, ServiceRecordsApproval.SEL_LABEL);
                }

                /* Program compliance */

                if (_userHasAccessToType10 == true)
                {

                    /* Pcal Staff */

                    if (rd.wu.usr.pcalStaff == true)
                    {
                        renderMenuListItem(ref writer, ServiceRecordsApproval.MENU_ID_APPROVE_SUMMARY_HS, ServiceRecordsApproval.SEL_LABEL_PRAC_SUPERVISOR_REV_SVC_HEALTH, ServiceRecordsApproval.PAGE_USER_ALL_SVC_REC_APPROVAL_SUMMARY);
                        renderMenuListItem(ref writer, ServiceRecordsApproval.MENU_ID_APPROVE_SUMMARY, ServiceRecordsApproval.SEL_LABEL_PRAC_SUPERVISOR_REV_SVC_NON_HEALTH, ServiceRecordsApproval.PAGE_USER_ALL_SVC_REC_APPROVAL);
                    }

                    /* Practitioner */

                    else
                    {
                        if (rd.wu.pr.stdSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES)
                            renderMenuListItem(ref writer, ServiceRecordsApproval.MENU_ID_APPROVE_SUMMARY, ServiceRecordsApproval.SEL_LABEL_PRAC_SUPERVISOR_REV_SVC, ServiceRecordsApproval.PAGE_USER_ALL_SVC_REC_APPROVAL_SUMMARY);
                        else
                            renderMenuListItem(ref writer, ServiceRecordsApproval.MENU_ID_APPROVE_SUMMARY, ServiceRecordsApproval.SEL_LABEL_PRAC_SUPERVISOR_REV_SVC, ServiceRecordsApproval.PAGE_USER_ALL_SVC_REC_APPROVAL);

                        /* Old view/review menu option */

                        if (PractitionerDirectSupervisors.shouldPracSeeServiceRecReviewForNonHS(ref rd))
                        {
                            renderMenuListItem(ref writer, "directsupsvcrevlink", ServiceRecordsApproval.SEL_LABEL_RPT_SVC_REC_REVIEW_FOR_DIRECT_SUP, ServiceRecordsApproval.PAGE_RPT_CLIENT_PROV_SVC_REC_REVIEW_FOR_DIRECT_SUP);
                        }

                    }
                }

                /* CYBHI Clinical Sup/ORP */

                if (_userHasAccessToType20 == true)
                {
                    renderMenuListItem(ref writer
                                        , CybhiServiceRecordsOrpReviews.MENU_ID_MANAGE
                                        , CybhiServiceRecordsOrpReviews.SEL_LABEL_MANAGE
                                        , CybhiServiceRecordsOrpReviews.URL_MANAGE_BASE);
                }

                /* Internal Review */

                if (_userHasAccessToType30 == true)
                {
                    renderMenuListItem(ref writer
                                       , ServiceRecordsInternalReviews.MENU_ID_MANAGE
                                       , ServiceRecordsInternalReviews.SEL_LABEL_MANAGE
                                       , ServiceRecordsInternalReviews.URL_MANAGE_BASE);
                }
                if (topMenu == true)
                {
                    renderTopMenuListEnd(ref writer);
                }
                else
                {
                    renderSubMenuListEnd(ref writer);
                }
            }
        }
        public static void renderCybhiProgramHealthMenuOptions(ref HtmlTextWriter writer, RequestResponse rd)
        {
            if (CYBHIProgramHealthStats.userHasAccess(rd) == true) renderMenuListItem(ref writer, CYBHIProgramHealthStats.MENU_ID_MANAGE, CYBHIProgramHealthStats.SEL_LABEL_MANAGE, CYBHIProgramHealthStats.URL_MANAGE);
            if (CYBHIConsortiumMembers.userHasAccess(rd) == true) renderMenuListItem(ref writer, CYBHIConsortiumMembers.MENU_ID_MANAGE, CYBHIConsortiumMembers.SEL_LABEL_MANAGE, CYBHIConsortiumMembers.URL_MANAGE);
        }

        /*===============================
         * Constructors
         *===============================*/

        public WebUI2(
            string bodyid
          , string subtitle
          , params string[] permittedroles) : this(bodyid, subtitle, null, null, permittedroles) { }
        public WebUI2(
            string bodyid
          , string subtitle
          , string css
          , string js
          , params string[] permittedroles) : base(
                bodyid
              , subtitle
              , rAppBarIconsPublic
              , rAppBarIconsPrivate
              , rheaderPublic
              , rheaderPrivate
              , rmenuPublic
              , rmenuPrivate
              , rfooterPublic
              , rfooterPrivate
              , rAppUserToDoMsgs
              , aUserSpecificNotifications
              , css
              , js
              , permittedroles)
        {
            this.appName = Constants.APP_NAME;
            this.appTitle = Constants.APP_TITLE;
            this.applicationName = Constants.APPLICATION_NAME;
            this.appVersion = Constants.APP_VERSION;
            this.appDescription = Constants.APP_DESCRIPTION;
            this.appKeywords = Constants.APP_KEYWORDS;
            this.appLogoMarkup = Messages.APP_LOGO_MKUP;
        }
    }
}
