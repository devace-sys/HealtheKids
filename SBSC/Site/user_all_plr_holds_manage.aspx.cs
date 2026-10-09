using System;
using MBA;

namespace Spedmon
{
    public class userAllPLRHoldsManage : WebUI
    {
        public string tabToOpen = "";
        public userAllPLRHoldsManage() : base(PotentialLostReimbursements.MENU_ID_MANAGE_HOLDS
                                            , PotentialLostReimbursements.SEL_MANAGE_HOLDS
                                            , "user_all_plr_holds_manage.css"
                                            , ""
                                            , Constants.ROLE_SBS_ALL_LEA_COORD)
        { }
        protected void Page_Load(object sender, EventArgs e)
        {
            var ctrlDeferFilter = findControlRecu(this.Page, "deferred")     as MBA.RadioBox;
            var ctrlPlrClass    = findControlRecu(this.Page, "plrClass")     as MBA.RadioBox;
            var ctrlClientID    = findControlRecu(this.Page, "selectClient") as MBA.DataEntryRowSelectClient;

            // set up radio box for plr class

            tabToOpen = MBA.HttpApplication.getParameter(Constants.PARM_TAB_TO_OPEN);

            if (!String.IsNullOrWhiteSpace(tabToOpen)) {
                ctrlPlrClass.value = tabToOpen;
            }
            else
            {
                ctrlPlrClass.value = "100"; /* Default */
            }

            ctrlPlrClass.AddSelection(@"Missing Orders"       , "100");
            ctrlPlrClass.AddSelection(@"NPI or ORP Validation", "200");
            ctrlPlrClass.AddSelection(@"Missing Supervision"  , "300");
            ctrlPlrClass.AddSelection(@"RMTS Participation"   , "400");
            ctrlPlrClass.AddSelection(@"Certification"        , "500");

            // set up radio box for defer filter
            ctrlDeferFilter.value = "false"; /* Default */

            ctrlDeferFilter.AddSelection(@"Review"  , "false");
            ctrlDeferFilter.AddSelection(@"Deferred", "true");

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