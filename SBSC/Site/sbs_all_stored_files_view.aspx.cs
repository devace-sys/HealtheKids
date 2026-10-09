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
   * SBSAllStoredFilesView */
  /**
   * View files uploaded to SpEdCare
   ***************************************************************************/ 
  
  public class SBSAllStoredFilesView : WebUI
  {
    public SBSAllStoredFilesView() : base("stored_files_view","View Files Sent To Us","","",Constants.ROLE_SBS_ALL){}
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
