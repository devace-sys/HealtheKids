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
 * request_account */
/**
 * Public page for users to request an account
 ***************************************************************************/

namespace Spedmon
{
  public class request_account : WebUI
  {
    public request_account() : base("request_account","Request An Account","",""){}
    protected void Page_Load(object sender, EventArgs e)
    { 
    }
  }
}
