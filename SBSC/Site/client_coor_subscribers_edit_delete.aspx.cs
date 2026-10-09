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
   * SBSAllSubscriberssEditDelete */
  /**
   * 
   ***************************************************************************/

  public partial class clientcoorsubscribersseditdelete : WebUI
  {
    
    public clientcoorsubscribersseditdelete() : base("subscriptions_edit_delete", WebUI.CreatePageSubTitle(Subscribers.SEL_LABEL, Subscribers.SEL_LABEL_EDIT_DELETE), "", "", Constants.ROLE_LEA_CORDINATOR) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
