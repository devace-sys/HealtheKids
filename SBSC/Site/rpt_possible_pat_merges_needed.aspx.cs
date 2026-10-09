
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

  public class RptPossibleMergesNeeded: WebUI
  {

    public RptPossibleMergesNeeded() : base("rpt_possible_pat_merges_needed", "Possible Patient Merges Needed", "", "", Constants.ROLE_SBS_ALL ) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }

  }

}

