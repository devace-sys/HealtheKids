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
   * UserAllApproveServiceRecordsDetails*/
  /**
   * Batch edit/delete
   *
   * Note: Just delete right now
   *
   ***************************************************************************/   

  public class UserAllApproveServiceRecordsDetails: WebUI
  {
    public string svcRecID;
    public string pracID;
    public string patID;
    public string entryMode;
    public string approveAllBaseURL;   // used as the URL for the save function for approving all records
    public string approveAllRecID;     // used as the recid parameter for the save function for approving all records
    public string entryModeLabel = "";
    
    public UserAllApproveServiceRecordsDetails() : base(  "service_records_batch_approve_details",
                                                   WebUI.CreatePageSubTitle(ServiceRecordsApproval.SEL_LABEL_PRAC_SUPERVISOR_REV_SVC,"Details"),
                                                   "client_prov_svcrec_batch_approve_details.css",
                                                   "",
                                                   Constants.ROLE_APPROVE_SVC_RECS){}
        
    protected void Page_Load(object sender, EventArgs e)
    {      
      /*************************************************
       * Get references to controls
       *************************************************/ 
     
      var ctrlClientid            = findControlRecu (this.Page, "selectClient")       as MBA.DataEntryRowSelectClient;
      var ctrlPracid              = findControlRecu (this.Page, "selectPractitioner") as MBA.DataEntryRowSelectPractitioner;
      var ctrlSiteID              = findControlRecu (this.Page, "selectSchoolSite")   as MBA.DataEntryRowSelectSchoolSite;

      /*************************************************
       * Set parameters used on the front end
       *************************************************/

      // entry mode
      entryMode = MBA.HttpApplication.getParameter(Constants.PARM_PRAC_SUP_DETAILS_ENTRY_MODE);
      if (String.IsNullOrEmpty(entryMode)) entryMode = Constants.PRAC_SUP_DETAILS_ENTRY_MODE_SVC_REC.ToString();

      // service record id (Note: We include pracID for now for performance reasons... TODO: Refactor back end so this lookup does not take forever)

      if (entryMode == Constants.PRAC_SUP_DETAILS_ENTRY_MODE_SVC_REC.ToString()) { 
        entryModeLabel = "By Service Record";        
        svcRecID = MBA.HttpApplication.getParameter(MBA.Constants.PARM_SVC_REC_ID);   
        pracID = MBA.HttpApplication.getParameter(MBA.Constants.PARM_PRACTITIONER_ID);
        Spedmon.Validate.reqInteger (svcRecID, @"Invalid service record id");
        Spedmon.Validate.reqInteger (pracID, Messages.INVALID_PRAC_ID);
        // set URL and recid for approving all entries in table
        approveAllBaseURL = MBA.HttpApplication.createLink(Spedmon.ServiceRecordsApproval.URL_ASMX_APPROVE_SVCREC, true);
      }

      
      // practitioner id

      if (entryMode == Constants.PRAC_SUP_DETAILS_ENTRY_MODE_PRAC.ToString()) { 
        entryModeLabel = "By Practitioner";
        pracID = MBA.HttpApplication.getParameter(MBA.Constants.PARM_PRACTITIONER_ID);
        Spedmon.Validate.reqInteger (pracID, Messages.INVALID_PRAC_ID);
        // set URL and recid for approving all entries in table
        approveAllBaseURL = MBA.HttpApplication.createLink(Spedmon.ServiceRecordsApproval.URL_ASMX_APPROVE_BY_PRAC_ID, true);
        approveAllRecID   = pracID;
      }
      
      // patient id

      if (entryMode == Constants.PRAC_SUP_DETAILS_ENTRY_MODE_PAT.ToString()) { 
         entryModeLabel = "By Patient";
         patID = MBA.HttpApplication.getParameter(MBA.Constants.PARM_PATIENT_ID);
         Spedmon.Validate.reqInteger (patID, Messages.INVALID_PAT_ID);

        // set URL and recid for approving all entries in table
        approveAllBaseURL = MBA.HttpApplication.createLink(Spedmon.ServiceRecordsApproval.URL_ASMX_APPROVE_BY_PAT_ID, true);
        approveAllRecID   = patID;
      }

      this.subTitle = WebUI.CreatePageSubTitle(ServiceRecordsApproval.SEL_LABEL, entryModeLabel);

      // for consultants and admins, set prac and client based on what is passed

      if (uInfo.userGroup == Constants.USER_GROUP_SBSC || uInfo.userClientID == 0) { 
        
        string approvingPracID = MBA.HttpApplication.getParameter(MBA.Constants.PARM_APPROVING_PRACTITIONER_ID);
        
        if (String.IsNullOrEmpty(approvingPracID) || approvingPracID == "0")
        {
            throw new Exception("practitioner was not provided");
        }

        string clientID = Practitioners.load(dbConnApp, log, uInfo, approvingPracID).clientID.ToString();
        
        if (String.IsNullOrEmpty(clientID) || clientID == "0")
        {
            throw new Exception("Invalid practitioner");
        }

        ctrlPracid.selectValue                        = approvingPracID;
        ctrlPracid.entryInitiallyHidden               = true;
        ctrlPracid.entryAllowed                       = false;
        ctrlPracid.entryNotAllowedUseReplacementValue = false;

        ctrlClientid.selectValue                        = clientID;
        ctrlClientid.entryInitiallyHidden               = true;
        ctrlClientid.entryAllowed                       = false;
        ctrlClientid.entryNotAllowedUseReplacementValue = false;

      }

      string siteIdStr = MBA.HttpApplication.getParameter(MBA.Constants.PARM_SITE_ID);
      if (!String.IsNullOrWhiteSpace(siteIdStr)) {
        var schoolSite = Sites.load(dbConnApp,log,uInfo,siteIdStr);
        ctrlSiteID.selectValue = schoolSite.id.ToString();
        ctrlSiteID.selectName = schoolSite.name;                
      }
    }
  
  }
}
