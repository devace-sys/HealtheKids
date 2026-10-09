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
   * ClientCoorServiceRecordsSvcNotesView */
  /**
   * View service records and svc notes
   ***************************************************************************/   
  
  public class ClientCoorServiceRecordsSvcNotesView : WebUI
  {
    public ClientCoorServiceRecordsSvcNotesView() : base("service_records_view","Service Records and Service Notes - View","","",Constants.ROLE_CLIENT_BO){}
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
