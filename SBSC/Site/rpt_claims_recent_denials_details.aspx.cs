
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
     * rpt_recent_denials_summary */
    /**
     * 
     ***************************************************************************/

    public class rpt_claims_recent_denials_details : WebUI
    {
        public string urlCompanionRpt = @"";
        public rpt_claims_recent_denials_details() : base( "rpt_claims_recent_denials_details"
                                                   , Claims.SEL_LABEL_RPT_RECENT_DENIALS_DETAILS
                                                   , ""
                                                   , ""
                                                   , Constants.ROLE_SBS_ALL)
        { }
    
        protected void Page_Load(object sender, EventArgs e)
        {
            urlCompanionRpt = MBA.HttpApplication.createLink(Claims.URL_RPT_RECENT_DENIALS_SUMMARY, true);
        }
    }
}



