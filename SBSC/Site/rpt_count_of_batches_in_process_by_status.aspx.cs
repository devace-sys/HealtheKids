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
     * RptCountOfBatchesInProcessByStatus */
    /**
     * 
     ***************************************************************************/

    public class RptCountOfBatchesInProcessByStatus : WebUI
    {
      public RptCountOfBatchesInProcessByStatus() : base("rpt_count_of_batches_in_process_by_status"
            ,InputBatchesStatus.SEL_LABEL_RPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS
            , ""
            , ""
            , Constants.ROLE_SBS_ALL) { }

        protected void Page_Load(object sender, EventArgs e)
        {
        }
    }
}
