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
   * SBSAllOneOnOneAideAssignmentEditDelete */
  /**
   * 
   ***************************************************************************/

  public partial class SBSAllOneOnOneAideAssignmentEditDelete : WebUI
  {

      public SBSAllOneOnOneAideAssignmentEditDelete() : base("oneononeaidassignment_edit_delete", WebUI.CreatePageSubTitle(OneOnOneAideAssignments.SEL_LABEL, OneOnOneAideAssignments.SEL_LABEL_EDIT_DELETE), "", "", Constants.ROLE_SBS_MGMT_ANI) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
