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

  public partial class SBSAllUsersEditDelete : WebUI
  {   
    public SBSAllUsersEditDelete() : base("users_edit_delete", "Users - Review, Edit or Delete", "", "", Constants.ROLE_SBS_MGMT_ANI) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
