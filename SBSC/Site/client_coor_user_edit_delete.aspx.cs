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
  * UserSelect */
  /**
  * Selects a User
  ***************************************************************************/

  public partial class clientcooruserseditdelete : WebUI
  {   
    public clientcooruserseditdelete() : base("users_edit_delete", "Users - Review, Edit or Delete", "", "", Constants.ROLE_CLIENT_BO) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
