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
   * SBSAllSubscriptionsEditDelete */
  /**
   * 
   ***************************************************************************/

  public partial class SBSAllSubscriptionsEditDelete : WebUI
  {
    
    public SBSAllSubscriptionsEditDelete() : base("subscriptions_edit_delete", WebUI.CreatePageSubTitle(Subscriptions.SEL_LABEL, Subscriptions.SEL_LABEL_EDIT_DELETE), "", "", Constants.ROLE_SBS_ALL) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
