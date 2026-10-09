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
  
  public class RptFileUploadsView : WebUI
  {
    public RptFileUploadsView() : base("rpt_file_uploads_view","Report - Files Uploaded to SpEdCare","","",Constants.ROLE_SBS_ALL){}
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
