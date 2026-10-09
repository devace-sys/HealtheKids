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
  * ClientSelect */
  /**
  * Selects a Client
  ***************************************************************************/

  public partial class SBSMGMTClientsEditDelete : WebUI
  {
      public SBSMGMTClientsEditDelete() : base("clients_edit_delete", "Clients - Review, Edit or Delete", "", "", Constants.ROLE_SBS_MGMT_ANI) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}