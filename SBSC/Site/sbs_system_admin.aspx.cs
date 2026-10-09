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
* System Admin */
/**
* System Administration
***************************************************************************/

namespace Spedmon
{
  public class SystemAdmin : WebUI
  {
    public SystemAdmin() : base("systemadmin","System Admin - Test Third Party API","","",Constants.ROLE_ADMIN){}
    protected void Page_Load(object sender, EventArgs e)
    {           
    }
  }
}
