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
   * CaseloadView */
  /**
   * 
   ***************************************************************************/

  public class SBSAllCaseloadView : WebUI
  {
    public SBSAllCaseloadView() : base("caseload_view", WebUI.CreatePageSubTitle(CaseLoads.SEL_LABEL, CaseLoads.SEL_LABEL_VIEW), "", "", Constants.ROLE_SBS_ALL) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
