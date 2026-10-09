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
   * ClientCoorrptPractitionersReview */
  /**
  * 
  ***************************************************************************/

  public class ClientCoorRptPractitionersReview : WebUI
  {
    public ClientCoorRptPractitionersReview() : base("rpt_prac_review", "Practitioners Review Report", "", "", Constants.ROLE_CLIENT_BO) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
