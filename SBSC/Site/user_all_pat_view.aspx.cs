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
  public class UserAllPatientsView : WebUI
  {
    public bool isSbsStaff;
    public UserAllPatientsView() : base("patients_view", "Patients - View", "", "", Constants.ROLE_ALL_PCAL_AND_CLIENT) { }
    protected void Page_Load(object sender, EventArgs e)
    {
        /*-------------------------------
         * Fetch parameters
         *------------------------------*/

        string clientID = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);

        /*-------------------------------
         * Locate data controls
         *------------------------------*/

        DataEntryRowSelectClient ctrlSelectClient = findControlRecu(this.Page, "selectClient") as DataEntryRowSelectClient;

        /*-------------------------------
         * Set up access variables
         *------------------------------*/
        isSbsStaff = uInfo.userGroup == Constants.USER_GROUP_SBSC;
        /*-------------------------------
         * Set control values
         *------------------------------*/
        if (!String.IsNullOrEmpty(clientID) && clientID != "0")
        {
            ctrlSelectClient.selectValue = clientID;
            ctrlSelectClient.entryInitiallyHidden = true;
            ctrlSelectClient.entryAllowed = false;
        }

    }
  }
}
