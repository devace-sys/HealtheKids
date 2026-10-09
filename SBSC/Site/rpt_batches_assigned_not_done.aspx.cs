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
     * RptBatchesAssignedNotDone */
    /**
     * 
     ***************************************************************************/

    public class RptBatchesAssignedNotDone : WebUI
    {
        public RptBatchesAssignedNotDone()
            : base("rpt_batches_assigned_not_done"
                    , Clients.SEL_LABEL_RPT_BATCHES_ASSIGNED_NOT_DONE
                    , ""
                    , ""
                    , Constants.ROLE_SBS_MGMT_ANI) { }

        protected void Page_Load(object sender, EventArgs e)
        {
        }
    }
}
