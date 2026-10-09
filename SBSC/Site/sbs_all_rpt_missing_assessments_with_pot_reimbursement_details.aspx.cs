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


namespace Spedmon
{
    public class sbs_all_rpt_missing_assessments_with_pot_reimbursement_details : WebUI
    {
        public sbs_all_rpt_missing_assessments_with_pot_reimbursement_details()

            : base(    "sbs_all_rpt_missing_assessments_with_pot_reimbursement_details"
                      , Claims.SEL_LABEL_RPT_MISSING_ASSESSMENTS_POT_REIMBURSEMENT_DETAILS
                      , ""
                      , ""
                      , Constants.ROLE_SBS_ALL )
        {
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }
}

}