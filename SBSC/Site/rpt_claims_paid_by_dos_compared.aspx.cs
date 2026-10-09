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
    * RptClaimPaidCompared */
    /**
    * Claims paid report
    ***************************************************************************/

    public class RptClaimsPaidByDosCompared : WebUI
    {
        public RptClaimsPaidByDosCompared() : base("rpt_claims_paid_by_dos_compared", Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_2P, "", "", Constants.ROLE_SBS_ALL) { }
        protected void Page_Load(object sender, EventArgs e)
        {
        }
    }
}


