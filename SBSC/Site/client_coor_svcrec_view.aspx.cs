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
  * ClientCoorServiceRecordsView */
  /**
  * Permits a client to view any service record within the scope of their
  * clientID
  ***************************************************************************/   
  
  public class ClientCoorServiceRecordsView : WebUI
  {
    public ClientCoorServiceRecordsView() : base("service_records_view","Service Records - View","","",Constants.ROLE_CLIENT_BO){}
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
