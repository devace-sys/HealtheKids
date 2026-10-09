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
   * SBSAllClientPBSDocumentationEditDelete */
  /**
   * 
   ***************************************************************************/

  public class SBSAllClientPBSDocumentationEditDelete : WebUI
  {
    
    public SBSAllClientPBSDocumentationEditDelete() : base("client_pbs_documentation_edit_delete"
	                                          , WebUI.CreatePageSubTitle(
											                        ClientPBSDocumentation.SEL_LABEL
	                                          , ClientPBSDocumentation.SEL_LABEL_EDIT_DELETE )
											                      , ""
											                      , ""
											                      , Constants.ROLE_SBS_ALL) { }
    
    protected void Page_Load(object sender, EventArgs e)
    {  
    }
  
  }
}
