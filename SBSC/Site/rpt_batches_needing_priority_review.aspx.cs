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

    public class RptBatchesNeedingPriorityReview : WebUI
    {
        public RptBatchesNeedingPriorityReview()
            : base("rpt_batches_needing_priority_review"
                    , InputBatchesStatus.SEL_LABEL_RPT_BATCHES_NEEDING_PRIORITY_REVIEW
                    , ""
                    , ""
                    , Constants.ROLE_SBS_ALL) { }

        protected void Page_Load(object sender, EventArgs e) 
        {
        }
    }
}