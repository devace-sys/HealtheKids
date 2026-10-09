using System;
using System.Collections;
using System.Collections.Generic;
using System.Dynamic;
using Newtonsoft.Json.Linq;
using MBA;

namespace Spedmon
{
    public class userAllSvcRecMultiPracPatSaveAll : WebUI
    {
        public userAllSvcRecMultiPracPatSaveAll() : base ( ServiceRecords.MENU_LINK_SVC_REC_SAVE_NEW_ALL
                                                          , ServiceRecords.SEL_LABEL_SVC_REC_SAVE_NEW_ALL
                                                          , "user_all_svcrec_save_batch_multi_prac_pat_dos_svc.css"
                                                          , "form-builder-patient-goal.js|user_all_patient_goal_progress_reporting.js"
                                                          , Constants.ROLE_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC)
        { }

        public bool   hasWipData                                    = false;        
        public bool   hasRecsToPreload                              = false;      
        public string wipDataLastSavedOnDateTimeStr                 = "";
        public string wipDataLastSavedOnRelDateStr                  = "";
        public string attendanceSelectionsJSON                      = @"[]";
        public string urlViewAllPatientGoalsProgress                = @"";        
        public string urlOrdersPrescriptionsManage                  = @"";
        public string dos                                           = "";
        public bool   isPrac                                        = false;
        public bool   isPcalStaff                                   = false;
        public bool   isLeaCoordAndAssist                           = false;
        public int    svcetrmdeInt                                  = 0;
        public string expectedSvcRecsJSON                           = "null";
        public string reloadUrl                                     = @"";        
        public bool   showSvcsForLeaBop                             = true;
        public bool   showSvcsForLeaBopNonSpEd                      = true;
        public bool   showSvcsForCYBHI                              = true;
        public bool   showSvcsForRUHealth                           = true;
        public string serviceNamesListDataSourcesJSON               = @"[]";
        public bool   isAssessmentsOnlyMode                         = false;
        public string urlEditPatient                                = "";
        public string caseloadGrpId                                 = "";
        public bool   autoLoadData                                  = false;

        protected void Page_Load(object sender, EventArgs e)
        {
            this.includeBackgroundLayer = false; /* TODO: Consider change to true when controls that do not have enough contrast are restyled*/

            List<ServiceRecordsExpectedEntryRow> expectedSvcRecs = new List<ServiceRecordsExpectedEntryRow>();

            /*###########################################################################
              # Turn on save points
              ###########################################################################*/

            this.useWorkInProgressSavePoints = true;
            
            /*###########################################################################
              # Get this request url.  We will use it for reloading the page if the
              # user opts to delete a save point.
              ###########################################################################*/
            
            this.reloadUrl = rd.requestURL;

            /*###########################################################################
              # Get control references
              ###########################################################################*/

            var ctrlDataEntryRowSelectClient          = findControlRecu(this.Page, "selectClient")                     as MBA.DataEntryRowSelectClient;
            var ctrlDataEntryRowSelectPrac            = findControlRecu(this.Page, "selectPractitioner")               as MBA.DataEntryRowSelectPractitioner;
            var ctrlDataEntryRowSelectPat             = findControlRecu(this.Page, "selectPatient")                    as MBA.DataEntryRowSelectPatient;
            var ctrlDataEntryRowOtherRecordAssmtLinks = findControlRecu(this.Page, "otherRecordAssmtLinks")            as MBA.DataEntryRow;
            var ctrlGroupID                           = findControlRecu(this.Page, "groupID")                          as MBA.HiddenInput;
            var ctrlGrpSvcClassNameID                 = findControlRecu(this.Page, "groupSvcClassNameID")              as MBA.HiddenInput;
            var ctrlDosHidden                         = findControlRecu(this.Page, "dosHidden")                        as MBA.HiddenInput;
            var ctrlDosSvcs                           = findControlRecu(this.Page, "dossvcs")                          as MBA.DateBox;
            var ctrlDataEntryRowSelectReferenceFile   = findControlRecu(this.Page, "dataEntryRowSelectReferenceFile")  as MBA.DataEntryRow;                
            var ctrlDataEntryRowSelectDate            = findControlRecu(this.Page, "DataEntryRowSelectDate")           as MBA.DataEntryRow;
            var ctrlDataEntryRowSelectCaseload        = findControlRecu(this.Page, "dataEntryRowSelectCaseload")       as MBA.DataEntryRow;
            var ctrlDataEntryRowSelectScheduledGroup  = findControlRecu(this.Page, "dataEntryRowSelectScheduledGroup") as MBA.DataEntryRow; 
            var ctrlSvcetrmde                         = findControlRecu(this.Page, "svcetrmde")                        as MBA.HiddenInput;
            var ctrlPracName                          = findControlRecu(this.Page, "pracName")                         as MBA.HiddenInput;
            var ctrlPatName                           = findControlRecu(this.Page, "patName")                          as MBA.HiddenInput;
            var ctrlDataEntryRowSaveOrEdit            = findControlRecu(this.Page, "saveOrEdit")                       as MBA.DataEntryRowSaveOrEdit;

            var ctrlLinkRecordUpcomingAssmtAllPats    = findControlRecu(this.Page, "gotorecordassmtsforupcomingiepsallpats")     as MBA.LinkInternal;
            var ctrlLinkRecordUpcomingAssmtMyCaseload = findControlRecu(this.Page, "gotorecordassmtsforupcomingiepsmycaseload")  as MBA.LinkInternal;

            /*###########################################################################
              # Change data entry row labels 
              ###########################################################################*/
            
            ctrlDataEntryRowSaveOrEdit.attestStatement                  = Messages.ATTEST_STATEMENT_SVC_RECS_SAVE;
            ctrlDataEntryRowSaveOrEdit.saveAndProceedButtonLabelForNew  = @"Finalize My Records";
            ctrlDataEntryRowSaveOrEdit.saveAndProceedDiagTitleForNew    = @"Finalize My Records";
            ctrlDataEntryRowSaveOrEdit.saveAndProceedButtonLabelForEdit = @"Finalize My Records";
            ctrlDataEntryRowSaveOrEdit.saveAndProceedDiagTitleForEdit   = @"Finalize My Records";

            /*###########################################################################
              # Get parameters 
              ###########################################################################*/
            
            var clientid            = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);            
            var pracid              = MBA.HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID);
            var patid               = MBA.HttpApplication.getParameter(Constants.PARM_PATIENT_ID);
            var svcetrmdeStr        = MBA.HttpApplication.getParameter(Constants.PARM_SVCETRMDE);
            var dosIn               = MBA.HttpApplication.getParameter(Constants.PARM_DOS);
            caseloadGrpId           = MBA.HttpApplication.getParameter("caseloadGrpID");
            autoLoadData            = (MBA.HttpApplication.getParameter("autoloaddata")) == "1";

           /*###########################################################################
             # Determine if this user + endpoint has saved work in progress
             ###########################################################################*/

            var sp = Spedmon.WorkInProgressSavePoints.load (  dbConnUser
                                                            , log
                                                            , uInfo
                                                            , ServiceRecords.URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC
                                                            , Constants.PARM_SAVE_FORM );
            hasWipData = sp.hasSavedData;
            

            if (hasWipData == true)
            {                                                                               
                wipDataLastSavedOnDateTimeStr = sp.loggedOn.ToLongDateAndTimeString();
                wipDataLastSavedOnRelDateStr = sp.loggedOn.ToRelativeDateString();

                clientid            = sp.savedDataObject[Constants.PARM_CLIENT_ID];
                pracid              = sp.savedDataObject[Constants.PARM_PRACTITIONER_ID];
                patid               = sp.savedDataObject[Constants.PARM_PATIENT_ID];
                svcetrmdeStr        = sp.savedDataObject[Constants.PARM_SVCETRMDE];  
                dosIn               = sp.savedDataObject["dosHidden"];                  
                expectedSvcRecs     = ServiceRecordsExpectedEntryRows.viewListFromWorkInProgressSavePoint(dbConnApp,log,uInfo,ref sp);
                hasRecsToPreload    = true;                
                expectedSvcRecsJSON = MBA.JSON.toJSONString(expectedSvcRecs, JsonLibrary.MSFT_WEB_SCRIPT_SERIALIZATION);             
            }
           
            /*###########################################################################
              # Enforce client and pracid values
              ###########################################################################*/

            var clientidval = Spedmon.Validate.optClientID (uInfo, clientid);
            var pracidval   = Spedmon.Validate.optPracID   (uInfo, pracid);
            var patidval    = Spedmon.Validate.optInteger  (patid, @"A patient ID value was passed but it is not valid");

            if (clientidval != null) clientid = clientidval.ToString();
            if (pracidval   != null) pracid   = pracidval.ToString();
            if (patidval    != null) patid    = patidval.ToString();

           /*###########################################################################
             # Get attendance selections JSON (will be used in data grid) 
             ###########################################################################*/
       
           attendanceSelectionsJSON = ServiceRecordAttendanceSelections.generateNvpValuesJSON(dbConnApp,log,uInfo);
            
                                 
           /*###########################################################################
             # Preload based on data passed
             ###########################################################################*/
            
            /*------------------------------------*/
            /* Client                             */
            /*------------------------------------*/

            if (!String.IsNullOrWhiteSpace(clientid))
            { 
              var clc = Clients.load(dbConnApp,log,uInfo,clientid);
              ctrlDataEntryRowSelectClient.selectValue = clc.id.ToString();
              ctrlDataEntryRowSelectClient.selectName =  clc.name;
            }

            /*------------------------------------*/
            /* Practioner & GroupID               */
            /*------------------------------------*/

            if (!String.IsNullOrWhiteSpace(pracid))
            {
              var prc = Practitioners.load(dbConnApp,log,uInfo,pracid);
              ctrlDataEntryRowSelectPrac.selectValue = prc.id.ToString();
              ctrlDataEntryRowSelectPrac.selectName  = prc.name;
              ctrlPracName.value                     = prc.name;
              ctrlGroupID.value                      = prc.groupID.ToString();
              ctrlGrpSvcClassNameID.value            = prc.stdSvcClassNameID.ToString();
            }
          
            /*------------------------------------*/
            /* Entry mode                         */
            /* Default is 1                       */
            /*------------------------------------*/

            if (String.IsNullOrEmpty(svcetrmdeStr)) svcetrmdeStr = Constants.SVCETRMDE_RECORD_SERVICES.ToString();
            if (!int.TryParse(svcetrmdeStr, out svcetrmdeInt)) svcetrmdeInt = Constants.SVCETRMDE_RECORD_SERVICES;                                         
            ctrlSvcetrmde.value = svcetrmdeInt.ToString();

            /*------------------------------------*/
            /* Date of service                    */
            /* Default is today                   */
            /*------------------------------------*/

            DateTime dosVal = DateTime.Now;
            if (!DateTime.TryParse(dosIn, out dosVal)) dosVal = DateTime.Now;
            dos = dosVal.ToString("yyyy-MM-dd"); /* HTML5 friendly format */
            ctrlDosHidden.value = dos;

            /*###########################################################################
              # Determine what classification of user is accessing screen
              ###########################################################################*/

            /*------------------------------------*/
            /* PCAL Staff                         */
            /*------------------------------------*/

            if (rd.wu.usr.pcalStaff == true)
            {
                isPrac               = false;
                isLeaCoordAndAssist  = false;
                isPcalStaff          = true;
            }

            /*------------------------------------*/
            /* Client User                        */
            /*------------------------------------*/

            else
            { 
              isPcalStaff = false;

              /* LEA Coordinator */
              
              if (rd.wu.usr.roleID == Constants.ROLE_LEA_COORDINATOR_ID)
              {
                isPrac              = false;
                isLeaCoordAndAssist = true;
              }
              
              /* LEA Input Staff */

              else if (rd.wu.usr.roleID == Constants.ROLE_LEA_INPUT_STAFF_ID)
              {
                isPrac              = false;
                isLeaCoordAndAssist = true;
              }

              /* Practitioner */

              else if (rd.wu.usr.roleID == Constants.ROLE_LEA_PROVIDER_ID)
              {
        
                showSvcsForLeaBop        = rd.wu.pr.participatesInLEABOP;
                showSvcsForLeaBopNonSpEd = rd.wu.pr.participatesInLEABOPNonSpEd;
                showSvcsForCYBHI         = rd.wu.pr.participatesInCYBHI;
                showSvcsForRUHealth      = rd.wu.pr.participatesInRUHealth;
                isPrac                   = true;
                isLeaCoordAndAssist      = false;
              }

              /* Unknown */

              else
              {
                isPrac              = false;
                isLeaCoordAndAssist = false;
              }        
            }
                        
            /*###########################################################################
              # Customize ui based on class of user
              ###########################################################################*/

            /*------------------------------------*/
            /* PCAL Staff                         */
            /*------------------------------------*/

            if (isPcalStaff == true)
            {
                ctrlDataEntryRowSelectReferenceFile.entryAllowed = true;
            }

            /*------------------------------------*/
            /* Client User                        */
            /*------------------------------------*/

            else
            {
               ctrlDataEntryRowSelectReferenceFile.entryAllowed = false;
            }
           
            /*###########################################################################
              # Customize ui based on entry mode
              ###########################################################################*/

            /* Set default row label for select dates row */

            ctrlDataEntryRowSelectDate.rowLabel = "(Optional): Multiple Date Selection";
                        
            /* Set default options for dos svcs */

            ctrlDosSvcs.showOK = false;

            /*------------------------------------*/
            /* Entry mode is record services      */
            /*------------------------------------*/

            if (svcetrmdeInt == Constants.SVCETRMDE_RECORD_SERVICES)
            {
                this.subTitle = WebUI.CreatePageSubTitle(ServiceRecords.SEL_LABEL_SVC_REC_SAVE_NEW_ALL);
                ctrlDataEntryRowSelectDate.entryAllowed            = true;  /* Show select dates */ 
                ctrlDataEntryRowSelectCaseload.entryAllowed        = true;  /* Show caseload and group */
                ctrlDataEntryRowSelectScheduledGroup.entryAllowed  = false; /* Hide scheduled group */
                ctrlDataEntryRowOtherRecordAssmtLinks.entryAllowed = false; /* Hide other record missing/upcoming assmt links*/
                isAssessmentsOnlyMode                              = false;
            }

            /*------------------------------------*/
            /* Entry mode is record scheduled     */
            /*------------------------------------*/

            else if (svcetrmdeInt == Constants.SVCETRMDE_RECORD_SCHEDULED_SERVICES)
            {
                this.subTitle = WebUI.CreatePageSubTitle(ServiceRecords.SEL_LABEL_SVC_REC_SAVE_FOR_DOS_ALL);
                ctrlDataEntryRowSelectDate.entryAllowed            = false; /* Hide select dates option */
                ctrlDataEntryRowSelectCaseload.entryAllowed        = false; /* Hide select caseload and group options */
                ctrlDataEntryRowSelectScheduledGroup.entryAllowed  = true;  /* Show scheduled group */
                ctrlDataEntryRowOtherRecordAssmtLinks.entryAllowed = false; /* Hide other record missing/upcoming assmt links*/
                isAssessmentsOnlyMode                              = false;
                if (hasWipData == false)
                { 
                  try
                  {
                      expectedSvcRecs = ServiceRecordsExpectedEntryRows.viewListFromExpectedTmtSvcsOnDos(dbConnApp,log,uInfo,clientid,pracid,"",dos,null);
                      if (expectedSvcRecs.Count != 0)
                      { 
                          hasRecsToPreload = true;                                                                    
                      }
                      expectedSvcRecsJSON = MBA.JSON.toJSONString(expectedSvcRecs, JsonLibrary.MSFT_WEB_SCRIPT_SERIALIZATION);
                  }
                  catch
                  {
                  }
                }
            }

            /*------------------------------------*/
            /* Entry mode is record missing       */
            /* assessments - All pats             */
            /*------------------------------------*/

            else if (svcetrmdeInt == Constants.SVCETRMDE_RECORD_MISSING_ASSMTS_ALL_PATS)
            {
                this.subTitle = WebUI.CreatePageSubTitle(ServiceRecords.SEL_LABEL_SVC_REC_REVIEW_ASSESSMENTS_ALL);
                ctrlDataEntryRowSelectDate.entryAllowed            = false;  /* Hide select dates */ 
                ctrlDataEntryRowSelectCaseload.entryAllowed        = false;  /* Hide caseload and group */
                ctrlDataEntryRowSelectScheduledGroup.entryAllowed  = false;  /* Hide scheduled group */
                ctrlDataEntryRowOtherRecordAssmtLinks.entryAllowed = true;   /* Show other record missing/upcoming assmt links*/
                ctrlLinkRecordUpcomingAssmtMyCaseload.hidden       = false;
                ctrlLinkRecordUpcomingAssmtAllPats.hidden          = true;
                isAssessmentsOnlyMode                              = true;
                if (hasWipData == false)
                { 
                  try
                  {
                     expectedSvcRecs = ServiceRecordsExpectedEntryRows.viewListFromExpectedAssmtSvcs(dbConnApp,log,uInfo,clientid,pracid,dos,false);
                      if (expectedSvcRecs.Count != 0)
                      { 
                        hasRecsToPreload = true;
                      }
                      expectedSvcRecsJSON = MBA.JSON.toJSONString(expectedSvcRecs, JsonLibrary.MSFT_WEB_SCRIPT_SERIALIZATION);
                  }
                  catch
                  {
                  }
                }
            }
            
            /*------------------------------------*/
            /* Entry mode is record missing       */
            /* assessments - caseload only        */
            /*------------------------------------*/

            else if (svcetrmdeInt == Constants.SVCETRMDE_RECORD_MISSING_ASSMTS_CASELOAD_ONLY)
            {
                this.subTitle = WebUI.CreatePageSubTitle(ServiceRecords.SEL_LABEL_SVC_REC_REVIEW_ASSESSMENTS_CASELOAD_ONLY);
                ctrlDataEntryRowSelectDate.entryAllowed            = false;  /* Hide select dates */ 
                ctrlDataEntryRowSelectCaseload.entryAllowed        = false;  /* Hide caseload and group */
                ctrlDataEntryRowSelectScheduledGroup.entryAllowed  = false;  /* Hide scheduled group */
                ctrlDataEntryRowOtherRecordAssmtLinks.entryAllowed = true;   /* Show other record missing/upcoming assmt links*/
                ctrlLinkRecordUpcomingAssmtMyCaseload.hidden       = true;
                ctrlLinkRecordUpcomingAssmtAllPats.hidden          = false;
                isAssessmentsOnlyMode                              = true;
                if (hasWipData == false)
                { 
                  try
                  {
                     expectedSvcRecs = ServiceRecordsExpectedEntryRows.viewListFromExpectedAssmtSvcs(dbConnApp,log,uInfo,clientid,pracid,dos,true);
                      if (expectedSvcRecs.Count != 0)
                      { 
                        hasRecsToPreload = true;
                      }
                      expectedSvcRecsJSON = MBA.JSON.toJSONString(expectedSvcRecs, JsonLibrary.MSFT_WEB_SCRIPT_SERIALIZATION);
                  }
                  catch
                  {
                  }
                }
            }

            /*------------------------------------*/
            /* Entry mode is record missing tmts  */
            /*------------------------------------*/

            else if (svcetrmdeInt == Constants.SVCETEMDE_RECORD_MISSING_TMT_FOR_PAT)
            {
                this.subTitle = WebUI.CreatePageSubTitle(ServiceRecords.SEL_LABEL_SVC_REC_MISSING_TMTS_FOR_PATIENT);
            
                ctrlDataEntryRowSelectDate.entryAllowed            = true;   /* Show select dates */ 
                ctrlDosSvcs.showOK                                 = true;   /* Turn on OK button */               
                ctrlDataEntryRowSelectDate.rowLabel                = "Select missing service date(s) then click OK";
                
                ctrlDataEntryRowSelectCaseload.entryAllowed        = false;  /* Hide caseload and group */
                ctrlDataEntryRowSelectScheduledGroup.entryAllowed  = false;  /* Hide scheduled group */
                ctrlDataEntryRowOtherRecordAssmtLinks.entryAllowed = false;  /* Hide other record missing/upcoming assmt links*/
                isAssessmentsOnlyMode                              = false;
                
                try
                {
                  /* Preselect patient.  User will select dates to add to grid */

                  var pat = Patients.load(dbConnApp,log,uInfo,patid);
                  ctrlDataEntryRowSelectPat.selectValue  = pat.id.ToString();
                  ctrlDataEntryRowSelectPat.selectName   = pat.name;             
                  ctrlPatName.value                      = pat.name;
                  ctrlDataEntryRowSelectPat.entryAllowed = false;
                  ctrlDosSvcs.onDateSelectMulti          = "addNewRowsFromSvcDateSelections();";
                  ctrlDataEntryRowSelectDate.rowLabel    = "Select missing service date(s) for " + pat.name + " then click OK";
                  this.subTitle = WebUI.CreatePageSubTitle(ServiceRecords.SEL_LABEL_SVC_REC_MISSING_TMTS_FOR,pat.name);

                 }
                 catch
                 {
                 }
                
            }

            /*------------------------------------*/
            /* Entry mode is passed but value     */
            /* is unknown, reset to 1             */
            /*------------------------------------*/

            else
            {
                svcetrmdeInt = Constants.SVCETRMDE_RECORD_SERVICES;
                this.subTitle = WebUI.CreatePageSubTitle(ServiceRecords.SEL_LABEL_SVC_REC_SAVE_NEW_ALL);
                ctrlDataEntryRowSelectDate.entryAllowed            = true;    /* Show select dates */ 
                ctrlDataEntryRowSelectCaseload.entryAllowed        = true;    /* Show caseload and group */
                ctrlDataEntryRowSelectScheduledGroup.entryAllowed  = false;   /* Hide scheduled group */
                ctrlDataEntryRowOtherRecordAssmtLinks.entryAllowed = false;   /* Hide other record missing/upcoming assmt links*/
                isAssessmentsOnlyMode                              = false;
            }
        
            /*###########################################################################
              # Get service name list data sources user can pick from
              ###########################################################################*/

            serviceNamesListDataSourcesJSON = Services.viewJSONOfSvcNameListDataSources (                
                showSvcsForLeaBop
              , showSvcsForLeaBopNonSpEd
              , showSvcsForCYBHI
              , showSvcsForRUHealth );
            
            /*###########################################################################
              # Setup any supporting urls
              ###########################################################################*/

            urlViewAllPatientGoalsProgress = PatientGoalsProgressIndividualGoals.URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS_BASE();

            urlOrdersPrescriptionsManage   = MBA.HttpApplication.createLink (  ORPDocuments.URL_USER_ALL_MANAGE
                                                                             , true
                                                                             , new NameValue(Constants.PARM_APP_MODE,Constants.AMD_UI_DBS_SUB_PAGE));

            ctrlLinkRecordUpcomingAssmtAllPats.url = ServiceRecords.URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC;
            ctrlLinkRecordUpcomingAssmtAllPats.addParameter(new NameValue(Constants.PARM_APP_MODE,Constants.AMD_UI_DBS_SUB_PAGE));
            ctrlLinkRecordUpcomingAssmtAllPats.addParameter(new NameValue(Constants.PARM_SVCETRMDE,Constants.SVCETRMDE_RECORD_MISSING_ASSMTS_ALL_PATS));

            ctrlLinkRecordUpcomingAssmtMyCaseload.url = ServiceRecords.URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC;
            ctrlLinkRecordUpcomingAssmtMyCaseload.addParameter(new NameValue(Constants.PARM_APP_MODE,Constants.AMD_UI_DBS_SUB_PAGE));
            ctrlLinkRecordUpcomingAssmtMyCaseload.addParameter(new NameValue(Constants.PARM_SVCETRMDE,Constants.SVCETRMDE_RECORD_MISSING_ASSMTS_CASELOAD_ONLY));
            
            urlEditPatient = Patients.URL_USER_ALL_EDIT_EXISTING_BASE(true,"");
            
         }
    }
}