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
   * SBSAllClientPBSDocumentationView */
  /**
   * 
   ***************************************************************************/

  public class SBSAllClientPBSDocumentationView : WebUI
  {
    
    public SBSAllClientPBSDocumentationView () : base("client_pbs_documentation_view"
	                                          , WebUI.CreatePageSubTitle(
											                        ClientPBSDocumentation.SEL_LABEL
	                                          , ClientPBSDocumentation.SEL_LABEL_VIEW )
											                      , ""
											                      , ""
											                      , Constants.ROLE_SBS_ALL) { }

    protected void Page_Load(object sender, EventArgs e)
    {  
    }

  }
}
