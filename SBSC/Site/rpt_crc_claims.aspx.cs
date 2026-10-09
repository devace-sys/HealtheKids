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
   * RptCRCSClaims */
  /**
   * CRCSClaims report
   ***************************************************************************/

    public class RptCRCsClaims : WebUI
  {
    public RptCRCsClaims() : base("rpt_crc_claims", CrcsCommon.SEL_LABEL_CLAIMS_REPORT, "", "", Constants.ROLE_SBS_MGMT_ANI) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}