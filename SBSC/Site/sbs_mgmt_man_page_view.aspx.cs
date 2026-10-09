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
   * SBSMgmtManPageView */
  /**
   * 
   ***************************************************************************/

  public class SBSMgmtManPageView : WebUI
  {
    public SBSMgmtManPageView() : base( "man_pages_view"
                                       , WebUI.CreatePageSubTitle ( ManPages.SEL_LABEL
												                                           , ManPages.SEL_LABEL_VIEW)
						                                                       , ""
												                                           , ""
												                                           , Constants.ROLE_ANNOUNCEMENT_ADMIN) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
