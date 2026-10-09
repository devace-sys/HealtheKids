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
   * RptSpEdCareWeekly */
  /**
   * 
   ***************************************************************************/

  public class RptSpEdCareWeekly : WebUI
  {
    public RptSpEdCareWeekly () : base( "rpt_spedcare_weekly"
                                        , Clients.SEL_LABEL_RPT_SPEDCARE_WEEKLY_REPORT                                                                              
						                , ""
                                        , ""
                                        , Constants.ROLE_SBS_MGMT_ANI) { }

    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
