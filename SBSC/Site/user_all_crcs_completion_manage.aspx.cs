using System;
using MBA;

namespace Spedmon
{
    public class userAllCRCSCompletionManage : WebUI
    {
        public userAllCRCSCompletionManage() : base(CrcsCommon.MENU_ID_MANAGE
                                            , CrcsCommon.SEL_LABEL_MANAGE
                                            , "crcs_manage.css"
                                            , ""
                                            , Constants.ROLE_CRCS_ADMIN)
        { }
        protected void Page_Load(object sender, EventArgs e)
        {
            var ctrlCrcsTabID = findControlRecu(this.Page, "crcsTabID") as MBA.RadioBox;
            var ctrlQuarter   = findControlRecu(this.Page, "quarter")   as MBA.RadioBox;

            // set up radio box for management tab
            ctrlCrcsTabID.value = CrcsCommon.SALARY_BENEFITS_TAB_ID; /* Default */
            
            ctrlCrcsTabID.AddSelection(@"Salary & Benefits"             , CrcsCommon.SALARY_BENEFITS_TAB_ID);
            ctrlCrcsTabID.AddSelection(@"Other Costs"                   , CrcsCommon.OTHER_COSTS_TAB_ID);
            ctrlCrcsTabID.AddSelection(@"Contractor Costs"              , CrcsCommon.CONTRACTOR_COSTS_TAB_ID);
            ctrlCrcsTabID.AddSelection(@"Medical Equipment Depreciation", CrcsCommon.MED_EQUIPMENT_DEPRECIATION_COSTS_TAB_ID);
            ctrlCrcsTabID.AddSelection(@"Transportation"                , CrcsCommon.TRANSPORTATION_TAB_ID);
            ctrlCrcsTabID.AddSelection(@"Program Info"                  , CrcsCommon.PROGRAM_INFO_TAB_ID);
            if (rd.wu.usr.pcalStaff == true)
            {
                ctrlCrcsTabID.AddSelection(@"Completion Report", CrcsCommon.COMPLETION_REPORT_TAB_ID);
            }

            // prepopulate defaults
            CrcsCommon.populateDefaultsForFiscalYear(dbConnApp, log, uInfo, null);
        }
    }
}