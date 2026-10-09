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
   * View */
  /**
   * 
   ***************************************************************************/
  public class ClientAllSitesView : WebUI
  {
    public ClientAllSitesView() : base("SITES_VIEW", WebUI.CreatePageSubTitle("Sites - View"), "", "", Constants.ROLE_CLIENT_ALL) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}