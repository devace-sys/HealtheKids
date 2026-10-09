using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

namespace Spedmon
{    
    public class client_lea_coord_rpt_missing_assessments_detail : WebUI
    {
        public client_lea_coord_rpt_missing_assessments_detail()

            : base("client_lea_coord_rpt_missing_assessments_detail"
                      , Claims.SEL_LABEL_RPT_MISSING_ASSESSMENTS_POT_REIMBURSEMENT_DETAILS
                      , ""
                      , ""
                      , Constants.ROLE_LEA_COORD_AND_ASSIST)
        {
        }



    }

}