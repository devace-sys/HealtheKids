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
     * ClientAllSitesEditDelete */
    /**
     * 
     ***************************************************************************/

  public partial class ClientAllSitesEditDelete : WebUI
  {

      public ClientAllSitesEditDelete() : base("sites_edit_delete", WebUI.CreatePageSubTitle("Sites - Review, Edit or Delete"), "", "", Constants.ROLE_ALL_PCAL_AND_CLIENT) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
