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
   * RptTattleTale */
  /**
   * TattleTale report
   ***************************************************************************/

  public class RptTattleTale : WebUI
  {
      public RptTattleTale() : base("rpt_svcrec_tattle", "Report - TattleTale Report", "", "", Constants.ROLE_SBS_ALL) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}