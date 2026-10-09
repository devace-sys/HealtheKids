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
  /***************************************************************************
   * SubscriptionsView */
  /**
   * 
   ***************************************************************************/

  public class client_coorsubscriptionsview : WebUI
  {
    public client_coorsubscriptionsview() : base("subscriptions_view", WebUI.CreatePageSubTitle(Subscriptions.SEL_LABEL, Subscriptions.SEL_LABEL_VIEW), "", "", Constants.ROLE_LEA_CORDINATOR) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
