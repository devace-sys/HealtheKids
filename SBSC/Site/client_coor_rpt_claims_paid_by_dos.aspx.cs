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
   * RptClaimPaid */
  /**
   * Claims paid report
   ***************************************************************************/

  public class ClientCoorRptClaimsPaidByDos : WebUI
  {
    public ClientCoorRptClaimsPaidByDos() : base("rpt_claims_paid_by_dos", Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_1P, "", "", Constants.ROLE_LEA_CORDINATOR) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
