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
     * RptInputStaffTrainingInProcess */
    /**
     * 
     ***************************************************************************/

    public class RptInputStaffTrainingInProcess : WebUI
    {
        public RptInputStaffTrainingInProcess()
            : base("rpt_input_staff_training_in_process"
                    , InputBatchesStatus.SEL_LABEL_RPT_INPUT_STAFF_TRAINING_IN_PROCESS
                    , ""
                    , ""
                    , Constants.ROLE_SBS_MGMT)
        { }

        protected void Page_Load(object sender, EventArgs e)
        {
        }
    }
}
