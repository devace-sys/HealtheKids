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
  public class SBSMgmtNewsletterPagesManage : WebUI
  {
    
    public SBSMgmtNewsletterPagesManage() : base (  "newsletter_page_edit_delete"
	                                                          , NewsletterPages.SEL_LABEL_MANAGE												
						                                      , ""
												              , ""
												               , Constants.ROLE_ANNOUNCEMENT_ADMIN) { }

    protected void Page_Load(object sender, EventArgs e)
    {
    }

  }
}
