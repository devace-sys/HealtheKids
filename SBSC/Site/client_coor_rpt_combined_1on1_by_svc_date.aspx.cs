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
     * RptCombined1on1BySvcDate */
    /**
     * Combined1:1BySvcDate report
     ***************************************************************************/

    public class clientcoorrptcombined1on1bysvcdate : WebUI
    {
        public clientcoorrptcombined1on1bysvcdate() : base("rpt_combined_1on1_by_svc_date", "Report - By Patient for One Practitioner by Service Date", "", "", Constants.ROLE_LEA_CORDINATOR) { }
        protected void Page_Load(object sender, EventArgs e)
        {
        }
    }
}

