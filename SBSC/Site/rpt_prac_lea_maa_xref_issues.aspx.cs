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
   * PractitionersLEAMAAXrefIssues */
  /**
   ***************************************************************************/

  public class PractitionersLEAMAAXrefIssues: WebUI
  {
    public PractitionersLEAMAAXrefIssues() : base("rpt_prac_lea_maa_xref_issues", "Miscoded MAA Participants", "", "", Constants.ROLE_SBS_MGMT_ANI) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
