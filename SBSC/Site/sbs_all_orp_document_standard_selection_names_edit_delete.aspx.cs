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
   * sbs_all_orp_document_standard_selection_names_edit_delete */
  /**
   * 
   ***************************************************************************/

  public class sbs_all_orp_document_standard_selection_names_edit_delete : WebUI
  {
    
    public sbs_all_orp_document_standard_selection_names_edit_delete() : base("sbs_all_orp_document_standard_selection_names_edit_delete"
	                                          , WebUI.CreatePageSubTitle(
											                        ORPDocumentsStandardSelectionNames.SEL_LABEL
	                                          , ORPDocumentsStandardSelectionNames.SEL_LABEL_EDIT_DELETE )
											                      , ""
											                      , ""
											                      , Constants.ROLE_SBS_ALL) { }
    
    protected void Page_Load(object sender, EventArgs e)
    {  
    }
  
  }
}
