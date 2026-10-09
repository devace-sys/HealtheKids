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
   * sbs_all_rpt_pot_lost_reimburse_orp_details */
  /**
   * 
   ***************************************************************************/

  public class sbs_all_rpt_pot_lost_reimburse_orp_details: WebUI
  {
    public sbs_all_rpt_pot_lost_reimburse_orp_details () : base( "sbs_all_rpt_pot_lost_reimburse_orp_details"
	                                             , WebUI.CreatePageSubTitle (   Claims.SEL_LABEL
	                                                                          , Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_ORP_DETAILS )
						                                   , ""
                                               , ""
										                           , Constants.ROLE_SBS_ALL) { }

    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
