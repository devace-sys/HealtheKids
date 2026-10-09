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
   * SBSAllOneOnOneAideAssignmentsView */
  /**
   * 
   ***************************************************************************/

  public class SBSAllOneOnOneAideAssignmentsView : WebUI
  {
      public SBSAllOneOnOneAideAssignmentsView() : base("oneononeaideassignments_view", WebUI.CreatePageSubTitle(OneOnOneAideAssignments.SEL_LABEL, OneOnOneAideAssignments.SEL_LABEL_VIEW), "", "", Constants.ROLE_SBS_MGMT_ANI) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
