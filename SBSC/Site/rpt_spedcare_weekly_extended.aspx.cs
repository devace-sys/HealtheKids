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
   * RptSpEdCareWeeklyExtended */
  /**
   * 
   ***************************************************************************/

  public class RptSpEdCareWeeklyExtended : WebUI
  {
    public RptSpEdCareWeeklyExtended () : base( "rpt_spedcare_weekly_extended"
                                        , Clients.SEL_LABEL_RPT_SPEDCARE_WEEKLY_REPORT_EXTENDED                                                       
						                            , ""
                                        , ""
                                        , Constants.ROLE_SBS_MGMT_ANI) { }

    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
