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
   * SBSAllServiceJournalsView */
  /**
   * View service journals with events and notes
   ***************************************************************************/   
  
  public class SBSAllServiceJournalsView : WebUI
  {
    public SBSAllServiceJournalsView() : base("service_journals_view","Service Journals - View","","",Constants.ROLE_SBS_ALL){}
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
