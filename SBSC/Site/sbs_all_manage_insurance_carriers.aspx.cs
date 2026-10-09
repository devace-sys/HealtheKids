using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Spedmon
{
    public class SBSAllManageInsuranceCarriers : WebUI
    {
        public SBSAllManageInsuranceCarriers() : base(@"sbs_all_manage_insurance_carriers"
                                                          , InsuranceCarriers.SEL_LABEL_MANAGE
                                                          , @""
                                                          , @""
                                                          , Constants.ROLE_SBS_ADMIN)
        {
        }
        protected void Page_Load(object sender, EventArgs e)
        {

        }
    }
}