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
     * PractitionersView */
    /**
     * 
     ***************************************************************************/

    public class UserAllPractitionersView : WebUI
    {
        public bool isSbsStaff;

        public UserAllPractitionersView() : base("pracs_view", "Practitioners - View", "", "", Constants.ROLE_SVC_SUP_PRAC) { }
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


            var ctrlActiveState   = findControlRecu(this.Page, "activeState") as MBA.RadioBox;
  
            ctrlActiveState.AddSelection(@"Active", "1");
            ctrlActiveState.AddSelection(@"Inactive", "2");
            if (this.uInfo.pcalStaff)
            {
                ctrlActiveState.AddSelection(@"Deactivated", "3");
                ctrlActiveState.AddSelection(@"Any Status", "4");
            }

        }
    }
}
