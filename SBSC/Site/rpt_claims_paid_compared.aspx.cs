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

  public class RptClaimsPaidCompared : WebUI
  {
    public RptClaimsPaidCompared() : base("rpt_claims_paid_compared", Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_WD_2P, "", "", Constants.ROLE_SBS_ALL) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}