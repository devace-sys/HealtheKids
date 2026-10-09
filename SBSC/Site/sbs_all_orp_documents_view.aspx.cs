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
   * SBSAllOrpDocumentsView */
  /**
   * 
   ***************************************************************************/

  public class SBSAllOrpDocumentsView : WebUI
  {
    
    public SBSAllOrpDocumentsView() : base( "orp_documents_view"
	                                         , WebUI.CreatePageSubTitle(
										                           ORPDocuments.SEL_LABEL
											                       , ORPDocuments.SEL_LABEL_VIEW)
											                     , ""
											                     , ""
											                     , Constants.ROLE_SBS_ALL) { }
    
	protected void Page_Load(object sender, EventArgs e)
    {  
    }
  
  }
}
