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
using System.Text;
using MBA;
using System.Collections.Generic;

namespace Spedmon
{
    /***************************************************************************
     * UserAllSvcRecSaveAll */
    /**
     * NOTE: This is depracated and no longer supported.  It was replaced with
     * user_all_svcrec_save_batch_multi_prac_pat_dos_svc.aspx
     ***************************************************************************/

    public class UserAllSvcRecSaveAll : WebUI
    {
      public string dos = "";
      public int    svcetrmde;
      public int    svcetrmdeInt; // for some reason the aspx thinks svcetrmde is a HiddenInput not the int declare above
      public string urlViewAllPatientGoalsProgress = "";
      public List<PractitionerCaseloadMemberExpectedSvcRecEntryData> expectedSvcRecs = new List<PractitionerCaseloadMemberExpectedSvcRecEntryData>();

      public UserAllSvcRecSaveAll() : base (     @"user_all_svcrec_save_batch_multi_pat_multi_svc"
                                               , ServiceRecords.SEL_LABEL_SVC_REC_SAVE_NEW_ALL
                                               , @"svcrec_save_all.css|user_all_patient_goal_progress_reporting.css"
                                               , @"svcrec_save_all.js|svcrec_save_batch_multi_pat_multi_svc.js|form-builder-patient-goal.js|user_all_patient_goal_progress_reporting.js"
                                               , Constants.ROLE_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC)
      {} 
   
    
                                        
    protected void Page_Load(object sender, EventArgs e)
    {      	    
       /*###########################################################################
        # Get control references
        ###########################################################################*/

      var ctrlSvcrecForDOSJSON    = findControlRecu (this.Page, "svcrecForDOSJSON"  ) as MBA.HiddenTextArea;
      var ctrlClientid            = findControlRecu (this.Page, "selectClient"      ) as MBA.DataEntryRowSelectClient;
      var ctrlPracid              = findControlRecu (this.Page, "selectPractitioner") as MBA.DataEntryRowSelectPractitioner;
      var ctrlDOS                 = findControlRecu (this.Page, "dos"               ) as MBA.HiddenInput;      
      var ctrlSvcetrmde           = findControlRecu (this.Page, "svcetrmde"         ) as MBA.HiddenInput;      
      var ctrlSaveOrEdit          = findControlRecu (this.Page, "saveOrEdit"        ) as MBA.DataEntryRowSaveOrEdit;
      var ctrlSelectGroup         = findControlRecu (this.Page, "selectGroup"       ) as MBA.DataEntryRow;
      var ctrlSelectDates         = findControlRecu (this.Page, "selectDates"       ) as MBA.DataEntryRow;
      var ctrlPracgroupid         = findControlRecu (this.Page, "pracgroupid"       ) as MBA.HiddenInput;

      /*###########################################################################
        # Get parameters passed on URL
        ###########################################################################*/

      /*------------------------------------*/
      /* Service date                       */
      /* Default is today                   */
      /*------------------------------------*/       
      
      DateTime dosVal = DateTime.Now;
      var dosIn = MBA.HttpApplication.getParameter(Constants.PARM_DOS);
      if (!DateTime.TryParse(dosIn,out dosVal)) dosVal = DateTime.Now;
      dos = dosVal.ToString("yyyy-MM-dd"); /* HTML5 friendly format */

      /*###########################################################################
       # Get client id and practitioner id from user data
       ###########################################################################*/
            
      var clientid = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);

      if (String.IsNullOrEmpty(clientid)) {
            clientid = uInfo.userClientID.ToString();
      } else {
            ctrlClientid.entryInitiallyHidden = true;
      }

      var pracid = MBA.HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID);

      if (!String.IsNullOrEmpty(pracid) && 
         (
            uInfo.userGroup == Constants.USER_GROUP_SBSC ||
            uInfo.userRoleID == Constants.ROLE_LEA_COORDINATOR_ID ||
            uInfo.userRoleID == Constants.ROLE_LEA_INPUT_STAFF_ID ||
            uInfo.userClientID == 0
         )
      ) { 

          // get client id from prac id
          Practitioner pr = Practitioners.load(dbConnApp, log, uInfo, pracid);
          
          string clientID = pr.clientID.ToString();
      
          if (String.IsNullOrEmpty(clientID) || clientID == "0")
          {
              throw new Exception("Invalid practitioner");
          }

          // set client id and label for practitioner
          clientid = clientID;
          ctrlPracid.selectName = pr.name;   
          ctrlPracgroupid.value = pr.groupID.ToString();
      
      } else { 
          pracid = uInfo.userPracID.ToString();
          if (rd.wu.pr != null) { 
            ctrlPracgroupid.value = rd.wu.pr.groupID.ToString();   
          }
      }

      /*------------------------------------*/
      /* Entry mode                         */
      /* Default is 1                       */
      /*------------------------------------*/

      /* Get value passed in (if any) default to 1 if none */

      var svcetrmdeStr = MBA.HttpApplication.getParameter(Constants.PARM_SVCETRMDE);
      if (String.IsNullOrEmpty(svcetrmdeStr)) svcetrmdeStr = Constants.SVCETRMDE_RECORD_SERVICES.ToString();
      
      /* Convert entry mode to int and if its not a number set to the default */
       
      if (!int.TryParse(svcetrmdeStr,out svcetrmde)){
        svcetrmdeStr = Constants.SVCETRMDE_RECORD_SERVICES.ToString();
        svcetrmde    = Constants.SVCETRMDE_RECORD_SERVICES;
      }
      
      /*###########################################################################
        # Load data into controls
        ###########################################################################*/

      ctrlClientid.selectValue          = clientid;

      if (clientid != null && clientid != "" && clientid != "0") { 
        ctrlClientid.selectName         = Clients.load(dbConnApp, log, uInfo, clientid).name;
      }

      ctrlPracid.selectValue            = pracid; 
            
      ctrlDOS.value                     = dos;    
      ctrlSvcetrmde.value               = svcetrmde.ToString();

      /*###########################################################################
        # Customize ui based on entry mode
        ###########################################################################*/

      /*------------------------------------*/
      /* Entry mode is record services      */
      /*------------------------------------*/

      if (svcetrmde == Constants.SVCETRMDE_RECORD_SERVICES) {
        this.subTitle = WebUI.CreatePageSubTitle (ServiceRecords.SEL_LABEL_SVC_REC_SAVE_NEW_ALL);
      }

      /*------------------------------------*/
      /* Entry mode is record scheduled     */
      /*------------------------------------*/

      else if (svcetrmde == Constants.SVCETRMDE_RECORD_SCHEDULED_SERVICES) { 
        this.subTitle = WebUI.CreatePageSubTitle (ServiceRecords.SEL_LABEL_SVC_REC_SAVE_FOR_DOS_ALL);
        ctrlSelectGroup.entryAllowed = false; /* Hide select caseload and group options */         
        ctrlSelectDates.entryAllowed = false; /* Hide select dates option */         
        try  {
            expectedSvcRecs              = PractitionerCaseloadMembers.viewListExpectedSvcsOnDos (dbConnApp,log,uInfo,clientid,pracid,"",dos,null);  
            ctrlSvcrecForDOSJSON.value   = MBA.JSON.toJSONString(expectedSvcRecs, JsonLibrary.MSFT_WEB_SCRIPT_SERIALIZATION);
        } catch(Exception err) {
                
        }

      }

      /*------------------------------------*/
      /* Entry mode is record missing       */
      /* assessments                        */
      /*------------------------------------*/

      else if (svcetrmde == Constants.SVCETRMDE_RECORD_MISSING_ASSMTS_ALL_PATS) {
        this.subTitle = WebUI.CreatePageSubTitle (ServiceRecords.SEL_LABEL_SVC_REC_REVIEW_ASSESSMENTS_ALL);
        ctrlSelectGroup.entryAllowed = false; /* Hide select caseload and group options */
        ctrlSelectDates.entryAllowed = false; /* Hide select dates option */         
        try {
            expectedSvcRecs              = PractitionerCaseloadMembers.viewListExpectedAssmtSvcs (dbConnApp,log,uInfo,clientid,pracid, dos,true,false);
            ctrlSvcrecForDOSJSON.value   = MBA.JSON.toJSONString(expectedSvcRecs, JsonLibrary.MSFT_WEB_SCRIPT_SERIALIZATION);

        } catch { 
        }
      }

      /*------------------------------------*/
      /* Entry mode is passed but value     */
      /* is unknown, reset to 1             */
      /*------------------------------------*/

      else {
        svcetrmdeStr = Constants.SVCETRMDE_RECORD_SERVICES.ToString();
        svcetrmde    = Constants.SVCETRMDE_RECORD_SERVICES;
        this.subTitle = WebUI.CreatePageSubTitle (ServiceRecords.SEL_LABEL_SVC_REC_SAVE_NEW_ALL);
      }

      svcetrmdeInt = svcetrmde; // for some reason the aspx thinks svcetrmde is a HiddenInput not the int declare above

      urlViewAllPatientGoalsProgress = PatientGoalsProgressIndividualGoals.URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS_BASE();
    }
  }
}