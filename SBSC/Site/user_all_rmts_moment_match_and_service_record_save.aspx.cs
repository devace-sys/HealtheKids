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
   * UserAllRMTSMomentMatchAndServiceRecordSave */
  /**
   * Specialized form for creating a new sevice record to match to an RMTS
   * moment
   ***************************************************************************/   

  public class UserAllRMTSMomentMatchAndServiceRecordSave: WebUI
  {
    public UserAllRMTSMomentMatchAndServiceRecordSave() : base( @"user_all_rmts_moment_match_and_service_record_save"
	                                       , @"Enter New Sevice Record to Match RMTS Moment"
                                           , @"user_all_rmts_moment_match_and_service_record_save.css"
                                           , @"form-builder-patient-goal.js|user_all_patient_goal_progress_reporting.js"
										   , Constants.ROLE_LEA_PROVIDER){} 
   

    public bool       showNonPracMessage      = false;
    public bool       showRmtsMomentNotFound  = false;
    public bool       showRMTSMomentInfo      = false;
    public bool       showSvcJournalOptions   = false;
    public bool       showSvcRecDataEntry     = false;
        
    public RmtsMoment rmtsMoment                   = new RmtsMoment();
    public string     rmtsMomentMatchStatusState    = @"";
    public string     rmtsMomentMatchStatusText     = @"";
    public string     serviceNameFormDataRequestUrl = @"";

    protected void Page_Load(object sender, EventArgs e)
    {      	    

      showNonPracMessage      = false;
      showRmtsMomentNotFound  = false;
      showRMTSMomentInfo      = false;
      showSvcJournalOptions   = false;
      showSvcRecDataEntry     = false;

      /*###########################################################################
        # Screen is for practitioner use only.  If user is not a practitioner
        # exit and show appropriate messages
        ###########################################################################*/    
      
      if (uInfo.userRoleID != Constants.ROLE_LEA_PROVIDER_ID) {
        showNonPracMessage = true;
        return;
      }

      /*###########################################################################
        # RMTS moment ID is expected to be passed in as a parameter
        ###########################################################################*/    

      string rmtsMomentID = MBA.HttpApplication.getParameter(Constants.PARM_RMTS_MOMENT_ID);
      
      /*###########################################################################
        # If no moment ID provided, exit and set flags to show appropriate message
        ###########################################################################*/    

      if (String.IsNullOrWhiteSpace(rmtsMomentID))
      {
        showRmtsMomentNotFound = true;
        return;
      }
      
      /*###########################################################################
        # Load the RMTS moment data
        ###########################################################################*/    
      
      rmtsMoment = Spedmon.RmtsMoments.load(dbConnApp, log, uInfo, rmtsMomentID);
      
      /*###########################################################################
        # If the practitioner is in the health services group family and is a 
        # paraprofessional (HA or LVN) they cannot enter service records so show
        # then options for the journal
        ###########################################################################*/    
     
      if (uInfo.userPracStdSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES)
      {
        if (uInfo.userPracIsAParaProfessional) {
          showNonPracMessage      = false;      
          showRmtsMomentNotFound  = false;
          showRMTSMomentInfo      = true;
          showSvcJournalOptions   = true;
          showSvcRecDataEntry     = false;
          return;
        }
      }
      
      /*###########################################################################
        # Otherwise this is any practitioner other than a LVN or HA
        ###########################################################################*/
      
      showNonPracMessage      = false;
      showRmtsMomentNotFound  = false;
      showRMTSMomentInfo      = true;
      showSvcJournalOptions   = false;
      showSvcRecDataEntry     = true;

      /*###########################################################################
        # If the moment is matched hide action options and let user know
        ###########################################################################*/
       
      if (rmtsMoment.matched == true)
      {
        showSvcJournalOptions   = false;
        showSvcRecDataEntry     = false;   
        rmtsMomentMatchStatusState = @"rmts-moment-match-status-matched";
        rmtsMomentMatchStatusText  = @"This moment has been matched already";
      } 
      else
      {
        rmtsMomentMatchStatusState = @"rmts-moment-match-status-no-match";
        rmtsMomentMatchStatusText  = @"No match yet";
      }

      /*###########################################################################
        # Get control references
        ###########################################################################*/
      
      var ctrlDos            = findControlRecu(this.Page, "dos")          as MBA.DataEntryBoxDate;
      var ctrlStartTime      = findControlRecu(this.Page, "starttime")    as MBA.DataEntryBoxTime;
      var ctrlClientID       = findControlRecu(this.Page, "clientid")     as MBA.HiddenInput;
      var ctrlPracID         = findControlRecu(this.Page, "pracid")       as MBA.HiddenInput;
      var ctrlGroupID        = findControlRecu(this.Page, "groupid")      as MBA.HiddenInput;
      var ctrlRmtsMomentID   = findControlRecu(this.Page, "rmtsmomentid") as MBA.HiddenInput;
      var ctrlSaveOrEdit     = findControlRecu(this.Page, "saveOrEdit")   as MBA.DataEntryRowSaveOrEdit;
     
      var ctrlHasPatGoalTrack      = findControlRecu(this.Page, "hasPatientGoalTrackingData")                 as MBA.HiddenInput;
      var ctrlHasSessionRatTrack   = findControlRecu(this.Page, "hasSessionRatingTracking")                   as MBA.HiddenInput;
      var ctrlFBQuestions          = findControlRecu(this.Page, "svcNotesFormBuilderQuestionsJSON")           as MBA.HiddenTextArea;
      var ctrlFBAnswers            = findControlRecu(this.Page, "svcNotesFormBuilderAnswersJSON")             as MBA.HiddenTextArea;
      var ctrlGoalProgress         = findControlRecu(this.Page, "patientGoalProgressJSON")                    as MBA.HiddenTextArea;
      var ctrlSelectPlanType       = findControlRecu(this.Page, Constants.PARM_SVC_NAMES_LIST_DATA_SOURCE_ID) as MBA.DataEntryBoxSelect;      
      var ctrlGroupSvcClassNameID  = findControlRecu(this.Page, Constants.PARM_GRP_SVC_CLS_NME_ID)            as MBA.HiddenInput;
      
      /*###########################################################################
        # Load practitioner data
        ###########################################################################*/
            
      var prac = Spedmon.Practitioners.load(dbConnApp,log,uInfo,uInfo.userPracIDStr);
            
      /*###########################################################################
        # Get service name list data sources prac can pick from
        ###########################################################################*/

      var svcNameDataSources = Services.viewListOfSvcNameListDataSources(prac.participatesInLEABOP,prac.participatesInLEABOPNonSpEd,prac.participatesInCYBHI,prac.participatesInRUHealth);
       
      /*###########################################################################
        # Add options for plan type using the service name list data sources
        ###########################################################################*/
            
      ctrlSelectPlanType.addSelectOneSelection = false;
            
      foreach(var svcNameDataSource in svcNameDataSources) {             
        var newSelection      = svcNameDataSource;
        newSelection.typename = @"";
        ctrlSelectPlanType.addSelection(newSelection);              
      }

      /*###########################################################################
        # Populate Other Form Values
        ###########################################################################*/
     
      ctrlDos.value                 = rmtsMoment.momentDate;
      ctrlStartTime.value           = rmtsMoment.momentDatetime;
      ctrlClientID.value            = rmtsMoment.clientID.ToString();
      ctrlPracID.value              = rmtsMoment.PracID.ToString();
      ctrlRmtsMomentID.value        = rmtsMomentID;
      ctrlSaveOrEdit.saveType       = Constants.SAVE_TYPE_NEW;
      ctrlSaveOrEdit.recID          = "";            
      ctrlGroupID.value             = prac.groupID.ToString();
      ctrlHasPatGoalTrack.value     = @"false";
      ctrlHasPatGoalTrack.value     = @"false";
      ctrlFBQuestions.value         = @"{}";
      ctrlFBAnswers.value           = @"{}";
      ctrlGoalProgress.value        = @"{}";

      ctrlGroupSvcClassNameID.value = prac.stdSvcClassNameID.ToString();

      /*###########################################################################
        # Create various urls
        ###########################################################################*/

      serviceNameFormDataRequestUrl = MBA.HttpApplication.createLink(@"claim_service_name_xref_and_form_data_records.asmx/loadN",true);

    }
  }
}