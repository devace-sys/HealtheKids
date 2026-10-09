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
  * ClaimProcessingExceptionSelect */
  /**
  * Selects a ClaimProcessingException
  ***************************************************************************/

  public partial class SBSClaimProcessingExceptionEditDelete : WebUI
  {
    public SBSClaimProcessingExceptionEditDelete() : base("ClaimProcessingException_edit_delete", "Claims Processing Exceptions - Review, Edit or Delete", "", "", Constants.ROLE_SBS_MGMT) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}

