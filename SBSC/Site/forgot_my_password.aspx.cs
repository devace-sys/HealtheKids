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

/***************************************************************************
 * forgot_my_password */
/**
 * Public page for users to request a password reset.
 ***************************************************************************/

namespace Spedmon
{
  public class forgot_my_password : WebUI3
  {
    public forgot_my_password() : base("forgot_my_password","","",""){}
    protected void Page_Load(object sender, EventArgs e)
    { 
    }
  }
}
