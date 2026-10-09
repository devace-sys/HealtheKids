using System;
using MBA;

namespace Spedmon
{
    public class UserAllCdeComplianceManageForSelpa : WebUI
    {
        public UserAllCdeComplianceManageForSelpa() : base(
                                              CdeComplianceCommon.BODY_ID_FOR_SELPA_MANAGE
                                            , CdeComplianceCommon.SEL_LABEL_MANAGE
                                            , @"user_all_cde_compliance_manage.css"
                                            , @""
                                            , Constants.ROLE_CDE_COMPLIANCE_MANAGE_FOR_SELPA)
        { 
		}
        
        public string currentWindowStartDateStr            = @"";
        public string currentWindowEndDateStr              = @"";
        public string currentWindowStartAndEndDateRangeStr = @"";

		protected void Page_Load(object sender, EventArgs e)
        {
            var ctrlSelpaCode            = findControlRecu (this.Page, "selectSelpa")                                      as MBA.DataEntryRowSelectSELPA;            
            var ctrlDosRange             = findControlRecu (this.Page,  Constants.PARM_DATE_RANGE)                         as MBA.DateBoxRange;

            currentWindowStartDateStr            = Spedmon.CdeComplianceCommon.getCurrentWindowStartDateStr(dbConnUser,log,uInfo);
            currentWindowEndDateStr              = Spedmon.CdeComplianceCommon.getCurrentWindowEndDateStr  (dbConnUser,log,uInfo);
            currentWindowStartAndEndDateRangeStr = Util.startAndEndDateStrToDateRangeStr(currentWindowStartDateStr,currentWindowEndDateStr);
            ctrlDosRange.value                   = currentWindowStartAndEndDateRangeStr;

            /* preselect selpa code if passed */

            string selpaCodeStr = MBA.HttpApplication.getParameter(Constants.PARM_SELPA_CODE);

            if (!String.IsNullOrEmpty(selpaCodeStr))
            {
                ctrlSelpaCode.selectValue          = selpaCodeStr;
                ctrlSelpaCode.entryInitiallyHidden = true;
                ctrlSelpaCode.entryAllowed         = false;
            }
        }
    }
}