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
 * ani_all_pat_edit_delete */
/**
 ***************************************************************************/

namespace Spedmon
{
  public class ani_all_pat_edit_delete : WebUI
  {
    public ani_all_pat_edit_delete() : base("ani_all_pat_edit_delete","Update or Correct Patient Records","","",Constants.ROLE_CLIENT_CONSULTANT){}
    protected void Page_Load(object sender, EventArgs e)
    { 
    }
  }
}
