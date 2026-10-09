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
   * RptClaimsView */
  /**
   * View claims
  ***************************************************************************/ 
  
  public class RptClaimsView : WebUI
  {
    public RptClaimsView() : base("rpt_claims_view","Report - Claims View","","",Constants.ROLE_SBS_MGMT_ANI){}
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
