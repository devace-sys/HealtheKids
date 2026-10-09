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


namespace Spedmon
{
  /***************************************************************************
   * UserAllServiceRecordsManage */
  /**
   * 
   ***************************************************************************/   

  public class UserAllServiceRecordsManage : WebUI
  {

    public UserAllServiceRecordsManage() : base( @"user_all_service_records_manage"
                                                , ServiceRecords.SEL_LABEL_MANAGE                                                                            
                                                , @"user_all_service_records_manage.css|user_all_patient_goal_progress_reporting.css"
                                                , @"user_all_service_records_manage.js|form-builder-patient-goal.js|user_all_patient_goal_progress_reporting.js"
                                                , Constants.ROLE_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC)
    {
    }

    public string match_rmts_id;
    public string attendanceSelectionsJSON          = @"[]";
    public bool   showSvcsForLeaBop                 = true;
    public bool   showSvcsForLeaBopNonSpEd          = true;
    public bool   showSvcsForCYBHI                  = true;
    public bool   showSvcsForRUHealth               = true;

    public string serviceNamesListDataSourcesJSON   = @"[]";
    public bool   isPrac                            = false;
    public string urlViewAllPatientGoalsProgress    = "";
    public bool   singleRecordMode                  = false;
    public bool   serviceCorrectionMode             = false;
    public string serviceReviewedByName             = @"";
    public string serviceReviewedByTitle            = @"";
    public string serviceReviewedOn                 = @"";
    public string serviceCorrectionReviewNotes      = @"";
    public string urlEditPatient                    = "";

    protected void Page_Load(object sender, EventArgs e)
    {
      /*###########################################################################
        # Get incoming parameter values 
        ###########################################################################*/
    
       var clientID             = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
       var patID                = MBA.HttpApplication.getParameter(Constants.PARM_PATIENT_ID);
       var dateRange            = MBA.HttpApplication.getParameter(Constants.PARM_DATE_RANGE);
       var recID                = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
       var svcRecToCorrectID    = MBA.HttpApplication.getParameter(Constants.PARM_SVCREC_TO_CORRECT_ID);

       match_rmts_id            = MBA.HttpApplication.getParameter("match_rmts_id");
       string matchrmtsdate     = MBA.HttpApplication.getParameter("matchrmtsdate");
    
       /*###########################################################################
         # Get control references 
         ###########################################################################*/
       
       var ctrlSelectClient     = findControlRecu (this.Page, @"selectClient")       as MBA.DataEntryRowSelectClient;
       var ctrlSelectPatient    = findControlRecu (this.Page, @"selectPatient")      as MBA.DataEntryRowSelectPatient;
       var ctrlDateRange        = findControlRecu (this.Page, @"daterange")          as DateBoxRange;
       var ctrlSvcTypeID        = findControlRecu (this.Page, @"svctypeid")          as MBA.SelectServiceType;
       var ctrlRecID            = findControlRecu (this.Page, Constants.PARM_REC_ID) as MBA.HiddenInput;

       /*###########################################################################
         # Get attendance selections JSON (will be used in rest view) 
         ###########################################################################*/
       
       attendanceSelectionsJSON = ServiceRecordAttendanceSelections.generateNvpValuesJSON(dbConnApp,log,uInfo);

      /*###########################################################################
        # Determine if we should be in single record mode and/or service correction
        # mode and validate the record id.
        ###########################################################################*/
      
      singleRecordMode      = false;
      serviceCorrectionMode = false;

      if (!String.IsNullOrWhiteSpace(svcRecToCorrectID))
      { 
        serviceCorrectionMode = true;
        var svcRecToCorrectIDVal = MBA.Validate.reqInteger(svcRecToCorrectID,Messages.INVALID_RECORD_ID);
        var svcRecToCorrect = ServiceRecordsApprovalSvcRecsToChangeDetails.load(dbConnApp, log, uInfo, svcRecToCorrectID);        
        serviceReviewedByName        = svcRecToCorrect.SvcReviewedByName;
        serviceReviewedByTitle       = svcRecToCorrect.SvcReviewedByTitle;
        serviceReviewedOn            = svcRecToCorrect.SvcReviewedOnStr;
        serviceCorrectionReviewNotes = svcRecToCorrect.SvcReviewNotes;
        recID                        = svcRecToCorrect.svcRecID.ToString();
      }

      if (!String.IsNullOrWhiteSpace(recID))
      { 
        var recIDVal = MBA.Validate.reqInteger(recID,Messages.INVALID_RECORD_ID);
        singleRecordMode = true;
        ctrlRecID.value = recIDVal.ToString();
      }

      /*###########################################################################
        # Determine if user is a practitioner
        ###########################################################################*/

      if (rd.wu.usr.pcalStaff == true)
      {
         isPrac = false;
      }

      if (rd.wu.usr.roleID == Constants.ROLE_LEA_COORDINATOR_ID)
      {
         isPrac = false;
      }
       
      if (rd.wu.usr.roleID == Constants.ROLE_LEA_INPUT_STAFF_ID)
      {
         isPrac = false;
      }

      if (rd.wu.usr.roleID == Constants.ROLE_LEA_PROVIDER_ID)
      {
         isPrac                   = true;
         showSvcsForLeaBop        = rd.wu.pr.participatesInLEABOP;
         showSvcsForLeaBopNonSpEd = rd.wu.pr.participatesInLEABOPNonSpEd;
         showSvcsForCYBHI         = rd.wu.pr.participatesInCYBHI;
         showSvcsForRUHealth      = rd.wu.pr.participatesInRUHealth;
      }

      /*###########################################################################
        # Set default values 
        # Note: For radio boxes we have to do this before adding selections
        ###########################################################################*/
     
      /*---- Client ----*/
      
      if (!String.IsNullOrWhiteSpace(clientID))
      {
        clientID = Spedmon.Validate.optClientID(uInfo,clientID).ToString();
        ctrlSelectClient.selectValue          = clientID;
        ctrlSelectClient.entryInitiallyHidden = true;
      }

      /*---- Patient ----*/
      
      if (!String.IsNullOrWhiteSpace(patID))
      {
         patID = Spedmon.Validate.reqPatID(uInfo,patID).ToString();
         ctrlSelectPatient.selectValue          = patID;
         ctrlSelectPatient.entryInitiallyHidden = true;
      }

      /*---- Date Range ----*/
      
      string dateRangeStr;
     
      /* The custom rmts date range was NOT passed in */

      if ( Util.IsNullOrEmpty(matchrmtsdate) ) { 
        
        /* The standard date range was passed in */

        if (!String.IsNullOrWhiteSpace(dateRange))
        {                    
          var svcDates = MBA.Validate.reqDateRange(dateRange,Messages.INVALID_DATE_RANGE);          
          dateRangeStr = Util.startAndEndDateToDateRangeStr(svcDates[0],svcDates[1]);
        }
        
        /* No date range passed in.  Use default */

        else
        { 
          dateRangeStr = Util.GenerateDateRange(Constants.SVC_REC_EDIT_DATE_RANGE_CONST);
        }
   
      }
      
      /* The custom rmts data range WAS passed in */

      else
      {   
        dateRangeStr = matchrmtsdate;
      }
      

      ctrlDateRange.value = dateRangeStr;
      
      /*---- Service Type ----*/

      ctrlSvcTypeID.value = @"";
      
      /*###########################################################################
        # Get service name list data sources user can pick from
        ###########################################################################*/

      serviceNamesListDataSourcesJSON = Services.viewJSONOfSvcNameListDataSources (            
            showSvcsForLeaBop
          , showSvcsForLeaBopNonSpEd
          , showSvcsForCYBHI
          , showSvcsForRUHealth );
            
      /*###########################################################################
        # Custom urls
        ###########################################################################*/ 

      urlViewAllPatientGoalsProgress = PatientGoalsProgressIndividualGoals.URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS_BASE();
      urlEditPatient                 = Patients.URL_USER_ALL_EDIT_EXISTING_BASE(true,"");

    }
  }
}