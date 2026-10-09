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
   * SBSAllRptPotLostReimburse */
  /**
   * 
   ***************************************************************************/

  public class SBSAllRptPotLostReimburse : WebUI
  {
    public SBSAllRptPotLostReimburse () : base( "rpt_pot_lost_rev"
	                                             , WebUI.CreatePageSubTitle (   Claims.SEL_LABEL
	                                                                          , Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE )
						                                   , ""
                                               , ""
										                           , Constants.ROLE_SBS_ALL) { }

    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
