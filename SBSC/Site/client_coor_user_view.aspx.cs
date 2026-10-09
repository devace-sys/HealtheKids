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
   * SBSAllUsersView */
  /**
   * 
   ***************************************************************************/

  public class clientcoorusersview : WebUI
  {
    
    public clientcoorusersview() : base("users_view", "Users - View", "", "", Constants.ROLE_CLIENT_BO) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
