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
     * RptCombined1on1ByPmtDate */
    /**
     * Combined1:1ByPmtDate report
     ***************************************************************************/

    public class client_coor_rpt_combined_1on1_by_pmt_date : WebUI
    {
        public client_coor_rpt_combined_1on1_by_pmt_date() : base("rpt_combined_1on1_by_pmt_date", "Report - By Patient for One Practitioner by Payment Date", "", "", Constants.ROLE_LEA_CORDINATOR) { }
        protected void Page_Load(object sender, EventArgs e)
        {
        }
    }
}