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
   * UserAllPatientInfoRequestsPublicInsuranceFormResponsesManage */
  /**
   * 
   ***************************************************************************/

  public class UserAllPatientInfoRequestsPublicInsuranceFormResponsesManage : WebUI
  {

    public UserAllPatientInfoRequestsPublicInsuranceFormResponsesManage() : base (  Util.createUniqueID()
                                                           , PatientInfoRequestsPublicInsuranceFormResponses.SEL_LABEL_MANAGE
                                                           , @""
                                                           , @"qrcode.min.js"
                                                           , Constants.ROLE_ALL_PCAL_AND_CLIENT) { }
    
    public bool canAccessCombinedOptionsManageScreen = false;

    protected void Page_Load(object sender, EventArgs e)
    {
        var ctrlClientID = findControlRecu(this.Page, "selectClient") as MBA.DataEntryRowSelectClient;
        string clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
        /* preselect clientid if passed */

        if (!String.IsNullOrEmpty(clientIDStr))
        {
            ctrlClientID.selectValue = clientIDStr;
            ctrlClientID.entryInitiallyHidden = true;
            ctrlClientID.entryAllowed = false;
        }

        canAccessCombinedOptionsManageScreen = false;
        canAccessCombinedOptionsManageScreen = PatientInfoRequestOptionsCommon.userCanAccessCombinedManageScreen(this.rd);

    }
  }
}
