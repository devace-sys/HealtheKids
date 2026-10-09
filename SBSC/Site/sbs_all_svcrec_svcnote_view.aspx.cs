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
   * SBSAllServiceRecordsSvcNotesView */
  /**
   * View service records and svc notes
   ***************************************************************************/   
  
  public class SBSAllServiceRecordsSvcNotesView : WebUI
  {
    public SBSAllServiceRecordsSvcNotesView() : base("service_records_view","Service Records and Service Notes - View","","",Constants.ROLE_SBS_ALL){}
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
