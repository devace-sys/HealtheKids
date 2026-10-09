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

    public class UserAllManagePatientParentMcalConsent : WebUI
    {
        public string tabToOpen = "";
        public UserAllManagePatientParentMcalConsent() : base(@"user_all_manage_patient_parent_mcal_consent"
                                                         , PatientParentMcalConsents.SEL_LABEL_MANAGE
                                                         , @"user_all_manage_patient_parent_mcal_consent.css"
                                                         , @"user_all_manage_patient_parent_mcal_consent.js"
                                                         , Constants.ROLE_SBS_ALL_LEA_COORD)
        {
        }

        protected void Page_Load(object sender, EventArgs e)
        {
          
          var ctrlFilterOptions = findControlRecu (this.Page, "filterOptions") as MBA.RadioBox;
          var ctrlClientID      = findControlRecu(this.Page, "selectClient")   as MBA.DataEntryRowSelectClient;
          
          tabToOpen = MBA.HttpApplication.getParameter(Constants.PARM_TAB_TO_OPEN);

          if (!String.IsNullOrWhiteSpace(tabToOpen)) {
              ctrlFilterOptions.value = tabToOpen;
          }
          else { 
              ctrlFilterOptions.value = "2"; /* Default */
          }

          ctrlFilterOptions.AddSelection(@"No Filter",        "1");
          ctrlFilterOptions.AddSelection(@"Held Claims",      "2");
          ctrlFilterOptions.AddSelection(@"No Consent",       "3");
          ctrlFilterOptions.AddSelection(@"Unknown Consent",  "4");

          /* preselect clientid if passed */

          string clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);

          if (!String.IsNullOrEmpty(clientIDStr)) { 
              ctrlClientID.selectValue = clientIDStr;
              ctrlClientID.entryInitiallyHidden = true;
              ctrlClientID.entryAllowed = false;
          }

        }
    }
}