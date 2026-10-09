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
{     /***************************************************************************
         * RptCountBatchesReadyToAssignByTypeOfWork */
      /**
     * 
     ***************************************************************************/
    public class RptCountBatchesReadyToAssignByTypeOfWork : WebUI
    {  
        public RptCountBatchesReadyToAssignByTypeOfWork() : base("rpt_count_batches_ready_to_assign_by_type_of_work"
            ,InputBatchesStatus.SEL_LABEL_RPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK
            , ""
            , ""
            , Constants.ROLE_SBS_ALL) { }
        protected void Page_Load(object sender, EventArgs e)
        {

        }
    }
}
