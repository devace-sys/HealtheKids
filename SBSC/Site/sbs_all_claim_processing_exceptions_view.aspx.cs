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
     * ClaimProcessingExceptionView */
    /**
     * 
     ***************************************************************************/

    public class SBSAllClaimProcessingExceptionView : WebUI
    {
        public SBSAllClaimProcessingExceptionView() : base("ClaimProcessingExceptions_view", "Claims Processing Exceptions - View", "", "", Constants.ROLE_SBS_MGMT) { }
        protected void Page_Load(object sender, EventArgs e)
        {

        }
    }
}
