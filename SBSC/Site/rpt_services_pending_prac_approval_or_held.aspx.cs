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
   * RptSvcsPendingPracApprovalOrHeld */
  /**
   * Service records waiting for practitioner sup approval or held by a sup
   ***************************************************************************/

  public class RptSvcsPendingPracApprovalOrHeld : WebUI
  {
    public RptSvcsPendingPracApprovalOrHeld() : base(    "rpt_svcs_pending_prac_approval_or_held"
		                                                  , ServiceRecordsApproval.SEL_LABEL_PRAC_SVC_REC_PENDING_APPROVAL_OR_HELD
									                                    , ""
											                                , ""
											                                , Constants.ROLE_SBS_MGMT_ANI) { }

    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}