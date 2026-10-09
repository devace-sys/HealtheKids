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
   * RptClaimsPaidByEligPatDosCompared */
  /**
   * "Chuck Report"
   ***************************************************************************/

  public class RptClaimsPaidByEligPatDosCompared : WebUI
  {
    public RptClaimsPaidByEligPatDosCompared() : base("rpt_claims_paid_by_elig_pat_dos_compared", 
                                                      Reports.Fianancial.RPT_NAME_AMTS_BY_ELIG_PAT_SD_2P,
                                                      "", 
                                                      "", 
                                                      Constants.ROLE_SBS_ALL) {}
    
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
