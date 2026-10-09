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
     * SBSAllRptPotLostReimburseDailyOverview */
    /**
     * 
     ***************************************************************************/

    public class sbs_all_rpt_pot_lost_reimburse_daily_overview : WebUI
    {
        public sbs_all_rpt_pot_lost_reimburse_daily_overview () : base("sbs_all_rpt_pot_lost_reimburse_daily_overview"
                                                     , WebUI.CreatePageSubTitle(Claims.SEL_LABEL
                                                                                  , Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_DAILY_OVERVIEW)
                                                               , ""
                                                   , ""
                                                                       , Constants.ROLE_SBS_ALL)
        { }

        protected void Page_Load(object sender, EventArgs e)
        {
        }
    }
}
