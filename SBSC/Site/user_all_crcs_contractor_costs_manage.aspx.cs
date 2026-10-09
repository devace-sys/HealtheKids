using System;
using MBA;

namespace Spedmon
{
    public class userAllCRCSContractorCostsManage : WebUI
    {
        public int ParmClientID     { get; set; }
        public int ParmFiscalYearID { get; set; }
        public userAllCRCSContractorCostsManage() : base(CrcsCommon.MENU_ID_MANAGE
                                            , CrcsCommon.SEL_LABEL_MANAGE
                                            , "crcs_rest_view_manage.css"
                                            , ""
                                            , Constants.ROLE_CRCS_ADMIN)
        { }
        protected void Page_Load(object sender, EventArgs e)
        {
            var ctrlClientID = findControlRecu(this.Page, "selectClient")     as MBA.DataEntryRowSelectClient;
            var ctrlFYID     = findControlRecu(this.Page, "selectFiscalYear") as MBA.DataEntryRowSelectFiscalYear;

            string clientIDStr     = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID)
                 , fiscalYearIDStr = MBA.HttpApplication.getParameter(Constants.PARM_FISCAL_YEAR_ID);

            ParmClientID     = int.Parse(clientIDStr);
            ParmFiscalYearID = int.Parse(fiscalYearIDStr);

            // if values provided, hide controls
            if (ParmClientID != 0) {
                ctrlClientID.selectValue = ParmClientID.ToString();
                ctrlClientID.entryInitiallyHidden = true;
                ctrlClientID.entryAllowed = false;
            }
            
            if (ParmFiscalYearID != 0)
            {
                ctrlFYID.selectValue = ParmFiscalYearID.ToString();
                ctrlFYID.entryInitiallyHidden = true;
                ctrlFYID.entryAllowed = false;
            }
        }
    }
}