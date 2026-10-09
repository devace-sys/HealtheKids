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

    public class RptBatchesAboutToAgeOut : WebUI
    {
        public RptBatchesAboutToAgeOut()
            : base("rpt_batches_about_to_ageout"
                    , InputBatchesStatus.SEL_LABEL_RPT_BATCHES_ABOUT_TO_AGE_OUT
                    , ""
                    , ""
                    , Constants.ROLE_SBS_ALL) { }

        protected void Page_Load(object sender, EventArgs e) // we are implementing this fairly useless method for convention's sake; if we investigate, this may be completely unnecessary going forward
        {
        }
    }
}