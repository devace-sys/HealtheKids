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

/***************************************************************************
 * Home */
/**
 * Private home page (first page user sees when they login)
 ***************************************************************************/

namespace Spedmon
{
  public class home : WebUI
  {
    public bool   showPatientSearch                  = false;
    public bool   showPatPersonSearch                = false;
    public bool   useGoogleCalendarWidget            = false;
    public bool   hideCdeComplianceSummary           = true;
    public bool   hideParentConsentActionItem        = true;
    public bool   hideMissingAssmtsActionItem        = true;
    public bool   hideMissingSpEdTmtsActionItem      = true;
    public bool   hideServiceAuthorizationActionItem = true;
    public bool   hideCalendarWidget                 = true;
    public bool   hidePerformanceWidget              = true;
    public bool   hideDeptHeadWidget                 = true;
    public bool   hideGoalsProgressWidget            = true;
    public bool   hideAnnouncementsAndTeachMe        = false;

    public string missingAssmtsURLBasedOnUserRole        = "";
    public string missingSpEdTmtsURLBasedOnUserRole      = "";
    public string ordersURLBasedOnUserRole               = "";
    public string calendarDateRedirectURLBasedOnUserRole = "";
    public string urlMissingSpEd                         = "";

    public string userRptGroupID                         = "";
    public string userClientID                           = "";
    public string userPracID                             = "";
    public string userGrpSvcClassStdNameID               = "";      
    public string patEditUrlBase                         = "";
    public home() : base("home","Home","home.css","form-builder-patient-goal.js|user_all_patient_goal_progress_reporting.js",Constants.ROLE_ALL){}
   
    protected void Page_Load(object sender, EventArgs e)
    {       
        this.includeBackgroundLayer = true;

       /*###########################################################################
         # Get control references
         ###########################################################################*/

        var ctrlClientID                      = findControlRecu (this.Page, Constants.PARM_CLIENT_ID)              as MBA.HiddenInput;
        var ctrlParentConsentActionItem       = findControlRecu (this.Page, "actionItemParentConsent")             as MBA.ActionItemTotalNumAmt;      
        var ctrlMissingAssessmentsActionItem  = findControlRecu (this.Page, "actionItemMissingAssmts")             as MBA.ActionItemTotalNumAmt;
        var ctrlMissingSpedTmtsActionItem     = findControlRecu (this.Page, "actionItemMissingSpEdTreatments")     as MBA.ActionItemTotalNumAmt;
        var ctrlSvcAuthActionItem             = findControlRecu (this.Page, "actionItemSvcAuth")                   as MBA.ActionItemTotalNumAmt; 

        MBA.AnnouncementsWidget   ctrlAnnouncementsWidget;
        MBA.PCalPerformanceWidget ctrlGoalsProgressWidget;

        var ctrlCalendarWidget                = findControlRecu (this.Page, "calendarWidget")                      as MBA.CalendarWidget;      
        var ctrlNotificationsAndMessages      = findControlRecu (this.Page, "spedmonUserNotificationsAndMessages") as MBA.NotificationsAndMessagesWidget;      
        var ctrlPcalPerformanceWidget         = findControlRecu (this.Page, "pcalPerformanceWidget")               as MBA.PCalPerformanceWidget;      
        var ctrlGotoDeptSvcsReview            = findControlRecu (this.Page, "gotoDeptSvcsReview")                  as MBA.LinkInternal;
        var ctrlGotoPracEfficiency            = findControlRecu (this.Page, "gotoPracEfficiency")                  as MBA.LinkInternal;

       /*###########################################################################
         # Set common entity values.  These will be used here and in the markup
         ###########################################################################*/

        userClientID             = String.IsNullOrEmpty(uInfo.userClientIDStr)              ? "" : uInfo.userClientIDStr;
        userPracID               = String.IsNullOrEmpty(uInfo.userPracIDStr)                ? "" : uInfo.userPracIDStr;
        userGrpSvcClassStdNameID = String.IsNullOrEmpty(uInfo.userPracStdSvcClassNameIDStr) ? "" : uInfo.userPracStdSvcClassNameIDStr;

        ctrlClientID.value       = userClientID;

        /* Set default title for performance widget */
        
        ctrlPcalPerformanceWidget.title = "Program Health";

       /*###########################################################################
         # Check what action items to display based on user's role
         ###########################################################################*/

       if (uInfo.userRoleID == Constants.ROLE_LEA_COORDINATOR_ID || uInfo.pcalStaff) 
       {
         useGoogleCalendarWidget = true;
       }

       if (uInfo.pcalStaff == true) 
       {
          showPatientSearch    = false;
          showPatPersonSearch  = true;
       } 
       else {
                if (uInfo.userRoleID == Constants.ROLE_LEA_PROVIDER_ID) {
                    showPatientSearch = true;
                }
                else {
                    showPatientSearch = false;
                }
       }

       if (((IList)Constants.ROLE_ADMIN_CONSULTANT_LEA_COORD).Contains(uInfo.userRole.ToLower())) { 
            hideParentConsentActionItem = false;
            hideMissingSpEdTmtsActionItem = false;
        }

       if (((IList)Constants.ROLE_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC).Contains(uInfo.userRole.ToLower())) { 
            hideMissingAssmtsActionItem = hideCalendarWidget = false;                
       }

       if (((IList)Constants.ROLE_LEA_COORD_AND_ASSIST).Contains(uInfo.userRole.ToLower())
                || uInfo.userRoleID == Constants.ROLE_LEA_PROVIDER_ID
                || ((IList)Constants.ROLE_SBS_ALL).Contains(uInfo.userRole.ToLower())) {
                
            hideServiceAuthorizationActionItem = false;
            
       }
       if (uInfo.userRoleID == Constants.ROLE_ADMIN_ID) { 
            hideParentConsentActionItem = hideMissingAssmtsActionItem = hideServiceAuthorizationActionItem = hideCalendarWidget = true;            
            hidePerformanceWidget = false;
            ctrlPcalPerformanceWidget.title = "Practi-Cal Health";
       }
       else if (uInfo.userRoleID == Constants.ROLE_CLIENT_CONSULTANT_ID) { 
            hideParentConsentActionItem = hideMissingAssmtsActionItem = hideServiceAuthorizationActionItem = true;
            hidePerformanceWidget = false;
            ctrlPcalPerformanceWidget.title = "Practi-Cal Health";
       }
       else if (uInfo.userRoleID == Constants.ROLE_WORK_LEADER_ID) { 
            hideParentConsentActionItem = hideMissingAssmtsActionItem = hideServiceAuthorizationActionItem = true;
            hidePerformanceWidget = false;
            ctrlPcalPerformanceWidget.title = "Practi-Cal Health";
       }
       else if (uInfo.userRoleID == Constants.ROLE_INPUT_STAFF_ID) { 
            hideMissingAssmtsActionItem = true;
            hideServiceAuthorizationActionItem = true;
       }
       else if (uInfo.userRoleID == Constants.ROLE_LEA_COORDINATOR_ID) { 
            hideParentConsentActionItem = hideMissingAssmtsActionItem = hideServiceAuthorizationActionItem = true;
             
            hidePerformanceWidget = false;
       }
       else if (uInfo.userRoleID == Constants.ROLE_CYBHI_CORDINATOR_ID) { 
            hideParentConsentActionItem = hideMissingAssmtsActionItem = hideServiceAuthorizationActionItem = true;
            hideCalendarWidget    = true;
            hidePerformanceWidget = true;                
       }
       else if (uInfo.userRoleID == Constants.ROLE_PARENT_GUARDIAN_ID ) {
            hideGoalsProgressWidget     = false;
            hideAnnouncementsAndTeachMe = true;
       }

       if (rd.wu.pr != null) {

            hideCdeComplianceSummary = false;

            if (rd.wu.pr.deptHead) { 
                hideDeptHeadWidget = false;
            }
            
            /* If this is a para rehide just about everything */

            if (uInfo.userPracIsAParaProfessional)
            {     
              hideCdeComplianceSummary = hideParentConsentActionItem = hideMissingAssmtsActionItem = hideServiceAuthorizationActionItem = hideCalendarWidget = true;
            }

            /* If this is a practitioner and its a teacher/or prog specialist rehide missing assmts, service authorization, parent consent */

            if (rd.wu.pr.stdSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_TEACHERS_PROG_SPECS)
            {
                    hideCalendarWidget       = false;            
                    hideMissingAssmtsActionItem = hideServiceAuthorizationActionItem = hideParentConsentActionItem = true;               
            }

       }

       /*###########################################################################
         # Setup various Urls
         ###########################################################################*/

       patEditUrlBase = Patients.URL_USER_ALL_EDIT_EXISTING_BASE(true,"");

       /*###########################################################################
         # Check what redirect URL to use based on user's role
         ###########################################################################*/

       if (uInfo.userRoleID == Constants.ROLE_LEA_PROVIDER_ID) {

            var upcomingTeleHealthSessions = Spedmon.TeleHealthSessions.getUpcomingTelecommSessionsForUserID(this.dbConnUser
                                                                                            , log
                                                                                            , uInfo
                                                                                            );

            foreach (var upcomingTeleHealthSession in upcomingTeleHealthSessions)
            {
              string _previewMsg = NotificationsAndMessagesWidget.generatePreviewMsg (                           
                          @"fa fa-video"
                        , @"Upcoming HyQueue TeleHealth Session"
                        , upcomingTeleHealthSession.tsp.meetingStartDate.ToShortDateAndTimeString()
                        , upcomingTeleHealthSession.tsp.roomTitle
                        , @"Click here for more details"
                        , upcomingTeleHealthSession.rsvpPageUrl
                        , true);

                
                        // TODO: we need to create an IF conditional that links to the RSVP page if the meeting
                        //       has not started; and links to the enter-chatroom page if the meeting has started

                ctrlNotificationsAndMessages.addMessage(
                                    _previewMsg
                                    , new UserMessage("Genera Message", _previewMsg, 0, Constants.APP_NAME)
                                    , NotificationMessagePriority.MESSAGE
                                    , false, false, false
                );
            }

            // also, hide amounts for prac users
            ctrlParentConsentActionItem.includeSum 
                    = ctrlMissingAssessmentsActionItem.includeSum
                    = ctrlSvcAuthActionItem.includeSum 
                    = ctrlMissingSpedTmtsActionItem.includeSum = false;


            missingAssmtsURLBasedOnUserRole = MBA.HttpApplication.createLink(ServiceRecords.URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC
                                                                                    , true
                                                              , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                              , new NameValue(Constants.PARM_SVCETRMDE, Constants.SVCETRMDE_RECORD_MISSING_ASSMTS_CASELOAD_ONLY)
                                                              , new NameValue(Constants.PARM_CLIENT_ID,       userClientID)
                                                              , new NameValue(Constants.PARM_PRACTITIONER_ID, userPracID));


            missingSpEdTmtsURLBasedOnUserRole = MBA.HttpApplication.createLink( MissingServicesTreatmentDetails.URL_MANAGE
                                                                                , true
                                                                                , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                                                , new NameValue (Constants.PARM_CLIENT_ID,          userClientID)
                                                                                , new NameValue (Constants.PARM_GRP_SVC_CLS_NME_ID, userGrpSvcClassStdNameID)
                                                                               );

       }
       else if (((IList)Constants.ROLE_LEA_COORD_AND_ASSIST).Contains(uInfo.userRole.ToLower())) { 
            
              missingAssmtsURLBasedOnUserRole   = MBA.HttpApplication.createLink(Claims.URL_CLIENT_LEA_COORD_RPT_MISSING_ASSESSMENTS_WITH_POT_REIMBURSEMENT_DETAILS
                                                                                    , true);
              missingSpEdTmtsURLBasedOnUserRole = MBA.HttpApplication.createLink( MissingServicesTreatmentsSummary.URL_MANAGE
                                                                                  , true
                                                                                  , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                                                  , new NameValue(Constants.PARM_CLIENT_ID, userClientID)
                                                                                 );

       }
       else { 
            
                missingAssmtsURLBasedOnUserRole = MBA.HttpApplication.createLink ( Claims.URL_SBS_ALL_RPT_MISSING_ASSESSMENTS_WITH_POT_REIMBURSEMENT_DETAILS
                                                                                  , true);

                missingSpEdTmtsURLBasedOnUserRole = MBA.HttpApplication.createLink ( MissingServicesTreatmentsSummary.URL_MANAGE
                                                                                    , true
                                                                                    , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)                                                                                   
                                                                                   );
       }

       calendarDateRedirectURLBasedOnUserRole = MBA.HttpApplication.createLink(ServiceRecords.URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC
                                                                              , true
                                                                              , new NameValue(Constants.PARM_SVCETRMDE, Constants.SVCETRMDE_RECORD_SCHEDULED_SERVICES));

       ordersURLBasedOnUserRole = ORPDocuments.URL_USER_ALL_MANAGE;

       /*###########################################################################
         # Set action item hidden properties
         ###########################################################################*/

        ctrlParentConsentActionItem.hidden      = hideParentConsentActionItem;
        ctrlMissingAssessmentsActionItem.hidden = hideMissingAssmtsActionItem;
        ctrlMissingSpedTmtsActionItem.hidden    = hideMissingSpEdTmtsActionItem;
        ctrlSvcAuthActionItem.hidden            = hideServiceAuthorizationActionItem;

       /*###########################################################################
         # For pcal staff only set missing treatment to details only 
         # TODO: This is temporary until we get the missing tmt details into the
         # nightly PLR
         ###########################################################################*/
  
        if (uInfo.pcalStaff == true)
        {
           ctrlMissingSpedTmtsActionItem.detailsLinkOnly = true;
        }
       
       /*###########################################################################
         # Set widget redirect URLs
         ###########################################################################*/

        ctrlParentConsentActionItem.urlDetails      = MBA.HttpApplication.createLink(PatientParentMcalConsents.URL_USER_ALL_MANAGE
                                                                                    , true);

        ctrlMissingAssessmentsActionItem.urlDetails = missingAssmtsURLBasedOnUserRole;

        ctrlMissingSpedTmtsActionItem.urlDetails    = missingSpEdTmtsURLBasedOnUserRole;

        ctrlSvcAuthActionItem.urlDetails            = MBA.HttpApplication.createLink(ordersURLBasedOnUserRole
                                                                                    , true);

        /* Set department head url */
        
        ctrlGotoPracEfficiency.urlPrivate = true;
        ctrlGotoPracEfficiency.url        = PractitionersEfficiency.URL_USER_ALL_RPT;
        ctrlGotoPracEfficiency.label      = PractitionersEfficiency.SEL_LABEL;

       /*###########################################################################
         # Set action item units
         ###########################################################################*/

       ctrlParentConsentActionItem.countUnits = "patients";

       ctrlMissingAssessmentsActionItem.countUnits = "assessments";
       ctrlMissingSpedTmtsActionItem.countUnits    = "minutes"; 
       ctrlSvcAuthActionItem.countUnits            = "claims held";
  
       /*###########################################################################
         # Set data URLs for widgets
         ###########################################################################*/

       if ( ! hideAnnouncementsAndTeachMe ) {

            ctrlAnnouncementsWidget = findControlRecu (this.Page, "announcements") as MBA.AnnouncementsWidget;

            ctrlAnnouncementsWidget.urlAnnouncementsLinksBase = MBA.HttpApplication.createLink(Constants.MAN_PAGES_PRIVATE
                                                                                            , true
                                                                                            , new NameValue(Constants.PARM_APP_MODE,Constants.AMD_UI_DBS_SUB_PAGE)
                                                                                            );

            ctrlAnnouncementsWidget.urlAnnouncementsAjax = MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_ASMX + "/viewSelDashboard"
                                                                                            , true
                                                                                            );

            ctrlAnnouncementsWidget.urlAnnouncementsAjaxData = "{\"term\": \"\"}";


       }

       if ( ! hideGoalsProgressWidget)
       {
            ctrlGoalsProgressWidget = findControlRecu (this.Page, "goalsProgressWidget") as MBA.PCalPerformanceWidget;

           foreach(var urlSet in PatientGoalsProgressIndividualGoals.generateParentPortalPatientGoalsProgressReviewUrlSetFromUInfo(uInfo))
           {  
             ctrlGoalsProgressWidget.iframeSrcUrl = urlSet.iframeSrcUrl;
             ctrlGoalsProgressWidget.popUpPageUrl = urlSet.popUpPageUrl;
             ctrlGoalsProgressWidget.title        = "Student Goal Progress";
             //ctrlPatientGoalProgressWidget.iframeSrcUrl = urlSet.iframeSrcUrl;
             //ctrlPatientGoalProgressWidget.popUpPageUrl = urlSet.popUpPageUrl;
             break; /* Break after first record.  TODO: Add support for multiple patients later */
           }

           /* Add notifications if parent has pending authorization requests */
 
          if (ServiceAuthorizationCommon.doesParentGuardianHaveServiceAuthorizationRequestsPending(ref rd))
          {
                                 
            string _previewMsg = NotificationsAndMessagesWidget.generatePreviewMsg (
                      @"fa fa-child"
                    , @"Parent/Guardian Authorization Requests"
                    , null
                    , @"There are pending authorization requests for your student that require your review."
                    , @"Click here to review the requests"
                    , MBA.HttpApplication.createLink(ServiceAuthorizationRequestResponses.URL_MANAGE_RESPONSES, true));
                    
             ctrlNotificationsAndMessages.addMessage(
                              _previewMsg
                            , new UserMessage("Genera Message", _previewMsg, 0, Constants.APP_NAME)
                            , NotificationMessagePriority.MESSAGE
                            , false, false, false
            );
          }

       }


       ctrlNotificationsAndMessages.sendMessageAjaxURL   = MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_SAVE
                                                                                    , true
                                                                                    );
       ctrlNotificationsAndMessages.deleteMessageAjaxURL = MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_DELETE
                                                                                    , true
                                                                                    );
       ctrlNotificationsAndMessages.recipientSrcURL      = MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_VIEW_SEL_CONTACTS
                                                                                    , true
                                                                                    );

       ctrlNotificationsAndMessages.messagesViewAjaxURL = MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_VIEWLIST
                                                                                    , true
                                                                                    );
       ctrlNotificationsAndMessages.deletedMessagesAjaxData = @"{"
                                                                   + "\"viewSentOnly\": false"
                                                                   + ",\"okToShow\"   : false"
                                                                   + ",\"hasRead\"    : null" 
                                                                   + ",\"active\"     : true" 
                                                            + @"}";

       ctrlNotificationsAndMessages.sentMessagesAjaxData    = @"{"
                                                                   + "\"viewSentOnly\": true"
                                                                   + ",\"okToShow\"   : null"
                                                                   + ",\"hasRead\"    : null" 
                                                                   + ",\"active\"     : true" 
                                                            + @"}";

        if (uInfo.userRole.ToLower() == Constants.ROLE_ADMIN)
        {
            ctrlPcalPerformanceWidget.iframeSrcUrl = @"https://app.smartsheet.com/b/publish?EQBCT=0cabe7d0a83549a0b12ae6600f81c937";
            ctrlPcalPerformanceWidget.popUpPageUrl = @"https://app.smartsheet.com/b/publish?EQBCT=0cabe7d0a83549a0b12ae6600f81c937";
        }
        else if (uInfo.userRole.ToLower() == Constants.ROLE_CLIENT_CONSULTANT)
        {
            ctrlPcalPerformanceWidget.iframeSrcUrl = @"https://app.smartsheet.com/b/publish?EQBCT=0cabe7d0a83549a0b12ae6600f81c937";
            ctrlPcalPerformanceWidget.popUpPageUrl = @"https://app.smartsheet.com/b/publish?EQBCT=0cabe7d0a83549a0b12ae6600f81c937";
        }
        else if (uInfo.userRole.ToLower() == Constants.ROLE_WORK_LEADER)
        {
            ctrlPcalPerformanceWidget.iframeSrcUrl = @"https://app.smartsheet.com/b/publish?EQBCT=0cabe7d0a83549a0b12ae6600f81c937";
            ctrlPcalPerformanceWidget.popUpPageUrl = @"https://app.smartsheet.com/b/publish?EQBCT=0cabe7d0a83549a0b12ae6600f81c937";
        }
        else if (uInfo.userRole.ToLower() == Constants.ROLE_LEA_CORDINATOR) {

            ctrlPcalPerformanceWidget.iframeSrcUrl = MBA.HttpApplication.createLink(LeaBopHealthCommon.URL_MANAGE
                                                    , true
                                                    , new NameValue(Constants.PARM_CLIENT_ID, uInfo.userClientIDStr)
                                                    , new NameValue(Constants.PARM_CONTENT_ONLY, 1)
                                                    , new NameValue(Constants.PARM_PREVIEW_ONLY ,true));

            ctrlPcalPerformanceWidget.popUpPageUrl = MBA.HttpApplication.createLink(LeaBopHealthCommon.URL_MANAGE
                                                    , true
                                                    , new NameValue(Constants.PARM_CLIENT_ID, uInfo.userClientIDStr)
                                                   );
             
            ctrlPcalPerformanceWidget.openPopUpOnSamePage = true;
         }

        /*###########################################################################
          # Get Service Authorization Requests
          ###########################################################################*/

        if (ServiceAuthorizationCommon.doesPracHaveServiceAuthorizationRequestsPending(ref rd))
        {
                        
            string _previewMsg = NotificationsAndMessagesWidget.generatePreviewMsg (
                      @"fa fa-user-md"
                    , @"Service Authorization Requests"
                    , null
                    , @"There are pending service authorization requests that require your review."
                    , @"Click here to review the requests"
                    , MBA.HttpApplication.createLink(ServiceAuthorizationRequestResponses.URL_MANAGE_RESPONSES, true));
                    
            ctrlNotificationsAndMessages.addMessage(
                              _previewMsg
                            , new UserMessage("Genera Message", _previewMsg, 0, Constants.APP_NAME)
                            , NotificationMessagePriority.MESSAGE
                            , false, false, false
            );

        }

        /*###########################################################################
          # Get service record review or change requests
          ###########################################################################*/

        if (ServiceRecordsApproval.isPracWithClientThatUsesApprovalSystem(ref rd))
        {

            // Supervised with held services

            if (ServiceRecordsApproval.isSupervisedPracWithHeldServices(ref rd))
            {
                List<ServiceRecordsApprovalSvcRecsToChangeDetail> svcRecsList = ServiceRecordsApprovalSvcRecsToChangeDetails.viewList(dbConnApp,log,uInfo, false, null, null, "1", uInfo.userClientIDStr,uInfo.userPracIDStr);
                foreach (var svcRec in svcRecsList) { 
                    string _previewMsg = @"";

                    if (rd.wu.pr.stdSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES) {
                       
                      _previewMsg = NotificationsAndMessagesWidget.generateNotificationPreviewMsg (                           
                          @"Service Journal Correction"
                        , svcRec.SvcReviewedOnStr
                        , svcRec.SvcReviewedByName + " (" + svcRec.SvcReviewedByTitle + ") " + "has returned some records for correction."
                        , @"Click here to correct the records"
                        , MBA.HttpApplication.createLink(ServiceJournals.URL_USER_ALL_GO_TO_JOURNAL, true, new NameValue(Constants.PARM_REC_ID, svcRec.journalID.ToString()), new NameValue(Constants.PARM_SVCREC_TO_CORRECT_ID, svcRec.ID.ToString()))
                       );

                      
                    }
                    else { 
                      
                       _previewMsg = NotificationsAndMessagesWidget.generateNotificationPreviewMsg (                           
                          @"Service Record Correction"
                         , svcRec.SvcReviewedOnStr
                         , svcRec.SvcReviewedByName + " (" + svcRec.SvcReviewedByTitle + ") " + "has returned a service record for correction."
                         , @"Click here to correct the service record"
                         , MBA.HttpApplication.createLink(ServiceRecords.URL_USER_ALL_SVC_RECS_MANAGE, true, new NameValue(Constants.PARM_SVCREC_TO_CORRECT_ID, svcRec.ID.ToString()))
                        );
                    }

                    ctrlNotificationsAndMessages.addMessage(
                                  _previewMsg
                                , new UserMessage("Genera Message", _previewMsg, 0, Constants.APP_NAME)
                                , NotificationMessagePriority.MESSAGE
                                , false, false, false
                    );
                }
            }

            // Supervisor with services to review

            if (ServiceRecordsApproval.isSupervisorPracWithServicesToReviewFromAssigned(ref rd))
            {
                bool _prefValueOkToShowSvcRecReviewNotifications = true;

                string _previewMsg = @"";

                if (rd.wu.pr.stdSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES) {
                   
                   /* HS does not get to opt out*/

                   _prefValueOkToShowSvcRecReviewNotifications = true;

                   _previewMsg = NotificationsAndMessagesWidget.generateNotificationPreviewMsg (                           
                          @"Service Journal Review"
                        , null
                        , @"You are qualified to review health service records entered by supervised practitioners. Please click here to review pending services."
                        , @"Click here to review pending services"
                        , MBA.HttpApplication.createLink(ServiceRecordsApproval.PAGE_USER_ALL_SVC_REC_APPROVAL_SUMMARY, true));
                }
                else { 
    
                    /* Check if prac has opted out */
                    
                    _prefValueOkToShowSvcRecReviewNotifications = PractitionerDirectSupervisedSupervisors.okToShowServiceRecordReviewNotificationsGetUserPref(ref rd);
                    
                    string _msg = @"You are qualified to review service records entered by supervised practitioners. Please click here to review pending services."
                                + ((_prefValueOkToShowSvcRecReviewNotifications) ? @" You can also opt out of receiving these notifications on the review screen." : @"");
                    
                    _previewMsg = NotificationsAndMessagesWidget.generateNotificationPreviewMsg (                           
                          @"Service Record Review"
                        , null
                        , _msg                         
                        , @"Click here to review pending services"
                        , MBA.HttpApplication.createLink(ServiceRecordsApproval.PAGE_USER_ALL_SVC_REC_APPROVAL, true));                    
                }

                /* If prac has indicated its ok to show */
                
                if (_prefValueOkToShowSvcRecReviewNotifications == true)
                { 
                  ctrlNotificationsAndMessages.addMessage(
                                _previewMsg                          
                              , new UserMessage("Genera Message", _previewMsg, 0, Constants.APP_NAME)
                                // general message?  generic message ??
                              , NotificationMessagePriority.MESSAGE
                              , false, false, false);
                }
            }
        }

            /*###########################################################################
              # Get CYBHI clinical supervisior ORP service record review requests
              ###########################################################################*/

        if (Spedmon.CybhiServiceRecordsOrpReviews.doesPracHaveServiceRecordsToReview(rd) == true)
        {
            string _reviewRequestMsgCybhiOrp = NotificationsAndMessagesWidget.generateNotificationPreviewMsg (
                             Spedmon.CybhiServiceRecordsOrpReviews.NOTIFICATION_LABEL_REVIEW
                            , null
                            , "There are 1 or more service records waiting for your review"
                            , @"Click here to review"
                            , Spedmon.CybhiServiceRecordsOrpReviews.URL_MANAGE());

            ctrlNotificationsAndMessages.addMessage(
                                    _reviewRequestMsgCybhiOrp
                                , new UserMessage("Genera Message", _reviewRequestMsgCybhiOrp, 0, Constants.APP_NAME)
                                , NotificationMessagePriority.MESSAGE
                                , false, false, false);
        }

            /*###########################################################################
              # Get internal service record review requests
              ###########################################################################*/

        if (Spedmon.ServiceRecordsInternalReviews.doesPracHaveServiceRecordsToReview(rd) == true) 
        {
               
          string _reviewRequestMsg = NotificationsAndMessagesWidget.generateNotificationPreviewMsg (                           
                          ServiceRecordsInternalReviews.NOTIFICATION_LABEL_REVIEW
                        , null
                        , "There are 1 or more service records waiting for your review"                         
                        , @"Click here to review"
                        , ServiceRecordsInternalReviews.URL_MANAGE());                    

          ctrlNotificationsAndMessages.addMessage(
                                _reviewRequestMsg                          
                              , new UserMessage("Genera Message", _reviewRequestMsg, 0, Constants.APP_NAME)                                
                              , NotificationMessagePriority.MESSAGE
                              , false, false, false);
        }

       /*###########################################################################
         # Get User's messages
         ###########################################################################*/

       UserMessages.viewList(dbConnUser, log, uInfo, "0", "1", null,"", "", "1").ForEach(delegate(MBA.UserMessage msg) {
               // if message is ok to show, then append to ctrlNotificationsAndMessages messages to show list
                if (msg.okToShow) {     
                    string  _previewMsg = NotificationsAndMessagesWidget.generateMessagePreviewMsg(msg.senderName,msg.createdStr,msg.subject, msg.senderEmail , msg.senderClientName, this.uInfo.pcalStaff );
                    ctrlNotificationsAndMessages.addMessage(
                                     _previewMsg
                                    , msg
                                    , NotificationMessagePriority.MESSAGE
                                    , true
                                    , true
                                    , true
                        );
                    
                }
         });
       
        /* Set department head url */

        ctrlGotoDeptSvcsReview.urlPrivate = true;
        ctrlGotoDeptSvcsReview.url        = PractitionerDepartmentServicesReview.URL_USER_ALL_RPT;
        ctrlGotoDeptSvcsReview.label      = PractitionerDepartmentServicesReview.SEL_LABEL;
    
        //ctrlGotoDeptSvcsReview.addParameter (new NameValue(Constants.PARM_CLIENT_ID, uInfo.userClientIDStr));
        //ctrlGotoDeptSvcsReview.addParameter (new NameValue(Constants.PARM_GRP_SVC_CLS_NME_ID, uInfo.userPracStdSvcClassNameID.ToString()));

        /*###########################################################################
          # Get User's Reporting Group
          ###########################################################################*/

        // if not PCal staff, preload prac group
        if (uInfo.pcalStaff == false && uInfo.userPracID != 0)
        {

            var pr = Practitioners.load(dbConnApp, log, uInfo, uInfo.userPracIDStr);

            userRptGroupID = pr.groupIDRept.ToString();
            userClientID   = pr.clientID.ToString();
        }


        var upcomingTeleIEPSessions = Spedmon.TeleIEPSessions.getUpcomingTelecommSessionsForUserID(this.dbConnUser
                                                                                            , log
                                                                                            , uInfo
                                                                                            );
        foreach (var upcomingTeleIEPSession in upcomingTeleIEPSessions)
        {
          string _previewMsg = NotificationsAndMessagesWidget.generatePreviewMsg (                           
                          @"fa fa-video"
                        , @"Upcoming HyQueue TeleIEP Session"
                        , upcomingTeleIEPSession.tsp.meetingStartDate.ToShortDateAndTimeString()
                        , upcomingTeleIEPSession.tsp.roomTitle
                        , @"Click here for more details"
                        , upcomingTeleIEPSession.rsvpPageUrl
                        , true);


                        // TODO: we need to create an IF conditional that links to the RSVP page if the meeting
                        //       has not started; and links to the enter-chatroom page if the meeting has started
         
          ctrlNotificationsAndMessages.addMessage(
                              _previewMsg
                            , new UserMessage("Genera Message", _previewMsg, 0, Constants.APP_NAME)
                            , NotificationMessagePriority.MESSAGE
                            , false, false, false
          );
        }

        if (ctrlCalendarWidget != null)
        {
            ctrlCalendarWidget.defaultViewMode = "calendar";
            ctrlCalendarWidget.hidden = hideCalendarWidget;
            ctrlCalendarWidget.urlDateOnClick = calendarDateRedirectURLBasedOnUserRole;
            ctrlCalendarWidget.urlAgendaGet = PractitionerCaseloadMembers.GEN_URL_ASMX_VIEW_LIST_SVC_DOS();
            ctrlCalendarWidget.sessionTimeOutUrl = MBA.Credential.generateSessionExpiredLink();
            ctrlCalendarWidget.title = "Today's Appointments";
            ctrlCalendarWidget.clientid = userClientID;
            ctrlCalendarWidget.pracid = userPracID;
            ctrlCalendarWidget.urlScheduledServiceEditBase = PractitionerPatientScheduledServices.URL_EDIT_BASE();
            ctrlCalendarWidget.urlScheduledServiceDeleteBase = PractitionerPatientScheduledServices.URL_SVC_DELETE_INLINE_BASE();
            ctrlCalendarWidget.urlPatientEditBase = patEditUrlBase;
            ctrlCalendarWidget.urlGroupViewEntity = PractitionerPatientGroups.GEN_URL_ASMX_VIEW_ENTITY();
            ctrlCalendarWidget.urlGroupOnEdit = calendarDateRedirectURLBasedOnUserRole;
            ctrlCalendarWidget.urlEditGrpSchSvc = PractitionerPatientScheduledServices.URL_MANAGE_BASE();
            ctrlCalendarWidget.urlScheduledServiceAddBase = PractitionerPatientScheduledServices.URL_ADD_NEW_BASE();
        }
    }
  }
}
