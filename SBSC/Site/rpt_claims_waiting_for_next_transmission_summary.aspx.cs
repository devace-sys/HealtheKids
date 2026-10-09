
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
     * rpt_claims_waiting_for_next_transmission_summary*/
    /**
     * 
     ***************************************************************************/

    public class rpt_claims_waiting_for_next_transmission_summary : WebUI
    {
        public rpt_claims_waiting_for_next_transmission_summary() : base("rpt_claims_waiting_for_next_transmission_summary"
                                                   , Claims.SEL_LABEL_RPT_CLAIMS_WAITING_FOR_NEXT_TRANSMISSION_SUMMARY
                                                   , ""
                                                   , ""
                                                   , Constants.ROLE_SBS_ALL)
        { }
    
        protected void Page_Load(object sender, EventArgs e)
        {
          
        }
    }
}



