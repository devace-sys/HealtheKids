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
   * RptClientWorkNotRecieved */
  /**
   * WorkNotRecieved Report
   ***************************************************************************/

    public class RptClientWorkNotRecieved : WebUI
  {
        public RptClientWorkNotRecieved() : base("rpt_client_work_not_received", "Report - Client Work Not Received", "", "", Constants.ROLE_SBS_MGMT_ANI) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
