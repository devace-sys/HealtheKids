using System;
using MBA;

namespace Spedmon
{
    public class userAllCRCSSalaryBenefitsManage : WebUI
    {
        public int ParmClientID     { get; set; }
        public int ParmFiscalYearID { get; set; }

        public bool isPcalStaff = false;
        public userAllCRCSSalaryBenefitsManage() : base(CrcsCommon.MENU_ID_MANAGE
                                            , CrcsCommon.SEL_LABEL_MANAGE
                                            , "crcs_rest_view_manage.css"
                                            , ""
                                            , Constants.ROLE_CRCS_ADMIN)
        { }
        protected void Page_Load(object sender, EventArgs e)
        {
            var ctrlQuarter  = findControlRecu(this.Page, "quarter")          as MBA.RadioBox;
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

            // set up radio box for quarter
            ctrlQuarter.value = "1"; /* Default */

            ctrlQuarter.AddSelection(@"Quarter 1", "1");
            ctrlQuarter.AddSelection(@"Quarter 2", "2");
            ctrlQuarter.AddSelection(@"Quarter 3", "3");
            ctrlQuarter.AddSelection(@"Quarter 4", "4");

            // reactivate archived records if they are now valid
            // we had to do this due to DHCS' rapid CRCS requirement changes
            CrcsPracSalaries.reactivateValidRecords(dbConnApp, log, uInfo, null, null, null);

            /*------------------------------------*/
            /* PCAL Staff                         */
            /*------------------------------------*/

            if (rd.wu.usr.pcalStaff == true)
            {
                isPcalStaff = true;
            }
        }
    }
}