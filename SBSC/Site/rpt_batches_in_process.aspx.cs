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
   * RpsBatchesInProcess */
  /**
   * 
   ***************************************************************************/

  public class RptBatchesInProcess : WebUI
  {
    public RptBatchesInProcess () : base( "rpt_batches_in_process"
                                        , Clients.SEL_LABEL_RPT_BATCHES_IN_PROCESS                                                                              
						                , ""
                                        , ""
                                        , Constants.ROLE_SBS_MGMT_ANI) { }

    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
