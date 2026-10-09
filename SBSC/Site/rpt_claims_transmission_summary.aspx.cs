
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
     * rpt_claims_transmission_summary */
    /**
     * 
     ***************************************************************************/

    public class rpt_claims_transmission_summary : WebUI
    {
        public rpt_claims_transmission_summary() : base("rpt_claims_transmission_summary"
                                                   , Claims.SEL_LABEL_RPT_CLAIM_TRANSMISSION_SUMMARY
                                                   , ""
                                                   , ""
                                                   , Constants.ROLE_SBS_ALL)
        { }
    
        protected void Page_Load(object sender, EventArgs e)
        {
          String dateRange = Claims.computeDefaultDateRangeForRptClaimsTransmissionSummary();
          DateBoxRange ctrlDateRange  = findControlRecu(this.Page, "daterange")    as DateBoxRange;
          ctrlDateRange.value = dateRange;
          ctrlDateRange.setParentStepLabel();        
        }
    }
}



