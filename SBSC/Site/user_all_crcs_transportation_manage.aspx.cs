using System;
using MBA;

namespace Spedmon
{
    public class userAllCRCSTransportationManage : WebUI
    {
        public int ParmClientID { get; set; }
        public int ParmFiscalYearID { get; set; }
        public userAllCRCSTransportationManage() : base(CrcsCommon.MENU_ID_MANAGE
                                            , CrcsCommon.SEL_LABEL_MANAGE
                                            , "crcs_manage.css"
                                            , ""
                                            , Constants.ROLE_CRCS_ADMIN)
        { }
        protected void Page_Load(object sender, EventArgs e)
        {
            var ctrlManageTabID = findControlRecu(this.Page, "crcsTransportationTabID") as MBA.RadioBox;
            var ctrlClientID  = findControlRecu(this.Page, "selectClient") as MBA.DataEntryRowSelectClient;
            var ctrlFYID      = findControlRecu(this.Page, "selectFiscalYear") as MBA.DataEntryRowSelectFiscalYear;
            var ctrlVehicleratetype = findControlRecu(this.Page, "vehicleratetype") as MBA.RadioBox;

            string clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID)
                 , fiscalYearIDStr = MBA.HttpApplication.getParameter(Constants.PARM_FISCAL_YEAR_ID);

            ParmClientID = int.Parse(clientIDStr);
            ParmFiscalYearID = int.Parse(fiscalYearIDStr);

            // if values provided, hide controls
            if (ParmClientID != 0)
            {
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

            // set up radio box for management tab
            ctrlManageTabID.value = CrcsCommon.TRANSPORTATION_PERSONNEL_COSTS_TAB_ID; /* Default */

            ctrlManageTabID.AddSelection(@"Personnel"             , CrcsCommon.TRANSPORTATION_PERSONNEL_COSTS_TAB_ID              );
            ctrlManageTabID.AddSelection(@"Other"                 , CrcsCommon.TRANSPORTATION_OTHER_COSTS_TAB_ID                  );
            ctrlManageTabID.AddSelection(@"Equipment Depreciation", CrcsCommon.TRANSPORTATION_EQUIPMENT_DEPRECIATION_COSTS_TAB_ID );
            ctrlManageTabID.AddSelection(@"Reimbursements"        , CrcsCommon.TRANSPORTATION_REIMBURSEMENTS_TAB_ID);

            // set up radio box for vehicle rates
            ctrlVehicleratetype.AddSelection(@"Itemized", @"1");
            ctrlVehicleratetype.AddSelection(@"Standardized", @"2");

        }
    }
}