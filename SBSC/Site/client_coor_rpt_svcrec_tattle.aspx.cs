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
   * ClientCoorRptTattleTale */
  /**
   * TattleTale report
   ***************************************************************************/

  public class ClientCoorRptTattleTale : WebUI
  {
    public ClientCoorRptTattleTale() : base("rpt_svcrec_tattle", "Report - TattleTale Report", "", "", Constants.ROLE_CLIENT_BO) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}