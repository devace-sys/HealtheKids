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
using System.ComponentModel;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * UserAllPracticeOfficePatientVisitManage */
  /**
   * 
   ***************************************************************************/
  
  public class UserAllPracticeOfficePatientVisitManage : WebUI

  {

    public UserAllPracticeOfficePatientVisitManage() : base(  Util.createUniqueID()
                                                             , PracticeOfficeCommon.SEL_LABEL_PATIENT_VISIT_MANAGE_BASE
                                                             , @"user_all_patient_goal_progress_reporting.css|practice-office-visits.css|care_plans.css|orders-or-prescriptions-provide-hs-for-pat-on-dos.css|pre-care-notes.css|patient-profile.css|user_all_pat_save_2.css|user_all_practice_office_patient_visit_manage.css|jquery-mba-image-uploader-cropper.css"
                                                             , @"form-builder-patient-goal.js|user_all_patient_goal_progress_reporting.js|practice-office-visits.js|patient-allergies.js|patient-known-health-problems.js|patient-diagnoses.js|patient-care-notes.js|orders-or-prescriptions-provide-hs-for-pat-on-dos.js|service-journal-recent-procedure-entries.js|care-plans.js|patient-vital-signs.js|patient-vital-signs-measurement.js|patient-persons.js|patient-promised-services.js|patient-goals.js|patient-insurance.js|orders-or-prescriptions.js|patient-service-records.js|stored-files.js|patient-profile.js|jquery-mba-image-uploader-cropper.js"
                                                             , Constants.ROLE_ALL_PCAL_AND_CLIENT) { }
    
    public bool   pageInitOK                     = false;
    public bool   isPCalStaff                    = false;
    public bool   isPrac                         = false;
    public string isPcalStaffJSBoolStr           = "";
    public string errorMessage                   = "";
    public string userPrevSignature              = "";
    public string visitGrpSvcClassNameID         = "";
    public string urlViewAllPatientGoalsProgress = "";
        
    public PracticeOfficeVisit       pov;
    public Patient                   pat;
    public Practitioner              prac;
    public PracticeOfficeVisitReason povr;
    
    public string  PAT_DATA_SOURCE_VALUE_ALL_PATIENTS                 = "";
    public string  PRAC_DATA_SOURCE_VALUE_WITHIN_PRACTICE_FAMILY_ONLY = "";

    public bool   visitScreenIsWindow               = false;
    public bool   canRecordScheduledServices        = false;
    public string attendanceSelectionsJSON          = @"[]";
    public string serviceNamesListPlanTypesJSON     = @"[]";
    public string urlManageOrderAndPx               = @"";
    public string goBackURL                         = @"";  

    public string urlUserMessagesSave               = @"";
    public string urlRecipientSrc                   = @"";

    protected void Page_Load(object sender, EventArgs e)
    {            
            
      string pracIDAssignedStr = "";
            
      /***************************************************************************
       * Set content options
       ***************************************************************************/      

      this.renderOptionContentOnly = true; /* Render content only */

     /***************************************************************************
      * Get info about user
      ***************************************************************************/

      isPCalStaff = uInfo.pcalStaff;
      isPcalStaffJSBoolStr = Util.netBoolToJSBool(isPCalStaff);
      isPrac = false;
      if (uInfo.userRoleID == Constants.ROLE_LEA_PROVIDER_ID) isPrac = true;

      /***************************************************************************
       * Get the users cached signature image (base64 data)
       ***************************************************************************/      
      
      try { 
          userPrevSignature = UserSignatures.loadN(dbConnUser, log, uInfo, 0, rd.wu.usr.id.ToString(), null, null).signatureBase64;
      } catch (Exception err) { 
          userPrevSignature = "";
      }

      /***************************************************************************
       * Get parameters
       ***************************************************************************/      

      string clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);      
      string recIDStr    = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);      

      /***************************************************************************
       * Get control refs
       ***************************************************************************/      

      var ctrlClientID  = findControlRecu (this.Page, Constants.PARM_CLIENT_ID)       as MBA.HiddenInput;
      var ctrlPracID    = findControlRecu (this.Page, Constants.PARM_PRACTITIONER_ID) as MBA.HiddenInput;
      var ctrlGroupID   = findControlRecu (this.Page, Constants.PARM_GROUP_ID)        as MBA.HiddenInput;
      var ctrlPatID     = findControlRecu (this.Page, Constants.PARM_PATIENT_ID)      as MBA.HiddenInput;
      var ctrlRecID     = findControlRecu (this.Page, Constants.PARM_REC_ID)          as MBA.HiddenInput;
      var ctrlDOS       = findControlRecu (this.Page, Constants.PARM_DOS)             as MBA.HiddenInput;

      var ctrlGrpSvcClassNameID              = findControlRecu (this.Page, Constants.PARM_GRP_SVC_CLS_NME_ID)                   as MBA.HiddenInput;
      var ctrlPracticeOfficeVisitResolutions = findControlRecu (this.Page, Constants.PARM_PRACTICE_OFFICE_VISIT_RESOLUTION_ID)  as MBA.DataEntryBoxSelect;

      try { 

        PAT_DATA_SOURCE_VALUE_ALL_PATIENTS                 = MBA.PatientDataSource.ALL_PATIENTS.GetValueAsString();
        PRAC_DATA_SOURCE_VALUE_WITHIN_PRACTICE_FAMILY_ONLY = MBA.PractitionerDataSource.WITHIN_PRACTICE_FAMILY_ONLY.GetValueAsString();
        
        pov = Spedmon.PracticeOfficeVisits.load(dbConnApp,log,uInfo,clientIDStr,recIDStr);        
        pracIDAssignedStr = pov.pracID.ToString();

        urlUserMessagesSave = MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_SAVE, true);
        urlRecipientSrc = MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_VIEW_SEL_CONTACTS, true);
        
        /* Start visit */
        
        Spedmon.PracticeOfficeVisits.startVisit(dbConnApp,log,uInfo,clientIDStr,pracIDAssignedStr,recIDStr);

        /* Reload */

        pov  = Spedmon.PracticeOfficeVisits.load(dbConnApp,log,uInfo,clientIDStr,recIDStr);           

        /* Get practitioner data */

        prac = Spedmon.Practitioners.load(dbConnApp,log,uInfo,pov.pracID.ToString());
        
        /* Get patient data */

        pat = Spedmon.Patients.load(dbConnApp,log,uInfo,pov.patID.ToString());
        
        /* Get visit reason data (we need this for form builder note data) */

        povr = PracticeOfficeVisitReasons.load(dbConnApp,log,uInfo,pov.groupSvcClassNameID.ToString(),pov.practiceOfficeVisitReasonID.ToString());
        

        ctrlClientID.value          = pov.clientID.ToString();
        ctrlPracID.value            = pov.pracID.ToString();
        ctrlGroupID.value           = prac.groupID.ToString();
        ctrlPatID.value             = pov.patID.ToString();
        ctrlDOS.value               = pov.visitStartDateStr;
        ctrlRecID.value             = recIDStr;
        ctrlGrpSvcClassNameID.value = prac.stdSvcClassNameID.ToString();
        
       /* Visit group svc */

       visitGrpSvcClassNameID = pov.groupSvcClassNameID.ToString();

       /* Patient Goals Progress */

       urlViewAllPatientGoalsProgress = PatientGoalsProgressIndividualGoals.URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS_BASE(pov.clientID.ToString(), pov.patID.ToString());

        /* Get practice office visit resolutions */

        var practiceOfficeVisitResolutions = PracticeOfficeVisitResolutions.viewList(dbConnApp,log,uInfo,"Y");

        /* Add resolution selections */
        
        foreach (var practiceOfficeVisitResolution in practiceOfficeVisitResolutions) {
          ctrlPracticeOfficeVisitResolutions.addSelection(new NameValue(practiceOfficeVisitResolution.name, practiceOfficeVisitResolution.id.ToString(), @""));
        }

        /* If a default resolution has been set (in the start visit) then preselect it */

        if (pov.practiceOfficeVisitResolutionID > 0) {
          ctrlPracticeOfficeVisitResolutions.value = pov.practiceOfficeVisitResolutionID.ToString();
        }

        var pracPatCaseloadExpectedSvcID = MBA.HttpApplication.getParameter(Constants.PARM_PRAC_PAT_CASELOAD_EXPECTED_SVC_ID);
        var ctrlPracPatCaseloadExpectedSvcID = findControlRecu(this.Page, Constants.PARM_PRAC_PAT_CASELOAD_EXPECTED_SVC_ID) as MBA.HiddenInput;
        if (isPrac == true) {
              pracIDAssignedStr = uInfo.userPracIDStr;
                if (prac.stdSvcClassNameID.ToString() == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES.ToString())
                {
                    canRecordScheduledServices = true;
                }
                /* If they are a mental health practitioner */
                else if (prac.stdSvcClassNameID.ToString() == Constants.GROUP_SERVICE_CLASS_NAME_ID_MENTAL_HEALTH_SERVICES.ToString())
                {
                    canRecordScheduledServices = true;
                }
                /* Any other practitioner family */
                else
                {
                    canRecordScheduledServices = false;
                }
        } 

        /* TODO: EAW: I think this is unused.  Check and if so remove */
        if (canRecordScheduledServices == true)
        {
            attendanceSelectionsJSON = ServiceRecordAttendanceSelections.generateNvpValuesJSON(dbConnApp, log, uInfo);
            serviceNamesListPlanTypesJSON = Services.viewJSONOfSvcNameListDataSources(true, true, false, false);
            urlManageOrderAndPx = MBA.HttpApplication.createLink(ORPDocuments.URL_USER_ALL_MANAGE
                                                                            , true
                                                                            , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE));
            if (!String.IsNullOrEmpty(pracPatCaseloadExpectedSvcID))
            {
                ctrlPracPatCaseloadExpectedSvcID.value = pracPatCaseloadExpectedSvcID;
            }
        }
        
        /***************************************************************************
         * Determine if we close window or navigate back 
         ***************************************************************************/

         var povs = MBA.HttpApplication.getParameter(Constants.PARM_PRACTICE_OFFICE_VISIT_SOURCE);


         if (String.IsNullOrWhiteSpace(povs)) povs = PracticeOfficeCommon.PRACTICE_OFFICE_VISIT_SOURCE_WAITING_ROOM;

         bool navBackIsContentOnly = false;
         
         /* Waiting room */

         if (povs == PracticeOfficeCommon.PRACTICE_OFFICE_VISIT_SOURCE_WAITING_ROOM) {
            visitScreenIsWindow = true;
         } 
         
         /* Patient profile */

         else if (povs == PracticeOfficeCommon.PRACTICE_OFFICE_VISIT_SOURCE_PATIENT_PROFILE) {
            visitScreenIsWindow = false;
         }       

         /* Manage Patients - Patient profile iframe */

         else if (povs == PracticeOfficeCommon.PRACTICE_OFFICE_VISIT_SOURCE_PATIENT_PROFILE_MANAGE_PATIENTS) {
            visitScreenIsWindow  = false;
            navBackIsContentOnly = true;
         } 

        
         goBackURL = MBA.HttpApplication.createLink(Patients.URL_USER_ALL_SAVE
                                                   , true
                                                   , new NameValue(Constants.PARM_CONTENT_ONLY, (navBackIsContentOnly) ? "1": "0")
                                                   , new NameValue(Constants.PARM_APP_MODE, (this.isSubPage) ? Constants.AMD_UI_DBS_SUB_PAGE : @"")
                                                   , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)                                                   
                                                   , new NameValue(Constants.PARM_REC_ID, pat.id.ToString())
                                                   , new NameValue(Constants.PARM_TAB_TO_OPEN, "tab-medical-history"));
                
        
        pageInitOK = true;
      }
      catch (Exception err) {
         errorMessage = err.Message;
         pageInitOK = false;
      }
    }
  }

}
