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
   * SubscribersView */
  /**
   * 
   ***************************************************************************/

  public class clientcoorsubscribersview : WebUI
  {
    public clientcoorsubscribersview() : base("subscriptions_view", WebUI.CreatePageSubTitle(Subscribers.SEL_LABEL, Subscribers.SEL_LABEL_VIEW), "", "", Constants.ROLE_LEA_CORDINATOR) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
