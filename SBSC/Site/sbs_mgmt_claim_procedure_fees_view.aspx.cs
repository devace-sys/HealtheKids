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
    public class SBSMGMTClaimProcedureFeesView : WebUI
    {
        public SBSMGMTClaimProcedureFeesView() : base("claimproceduresfees_view", "Claim Procedure Fees - View", "", "", Constants.ROLE_SBS_MGMT) { }

        protected void Page_Load(object sender, EventArgs e)
        {
        }
    }
}