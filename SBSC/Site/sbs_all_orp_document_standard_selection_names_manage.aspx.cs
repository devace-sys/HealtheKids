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
   * SbsAllOrpDocumentStandardSelectionNamesManage */
  /**
   * 
   ***************************************************************************/

  public class SbsAllOrpDocumentStandardSelectionNamesManage : WebUI
  {
    
    public SbsAllOrpDocumentStandardSelectionNamesManage() : base ( "sbs_all_orp_document_standard_selection_names_manage"
                                                                    , WebUI.CreatePageSubTitle( ORPDocumentsStandardSelectionNames.SEL_LABEL
                                                                                               , ORPDocumentsStandardSelectionNames.SEL_LABEL_MANAGE)

                                                                    , @""
                                                                    , @""
                                                                    , Constants.ROLE_SBS_ALL) { }
    
    protected void Page_Load(object sender, EventArgs e)
    {

      var ctrlActive = findControlRecu(this.Page, @"active") as MBA.HiddenInput;
      ctrlActive.value         = "1"; 
           
   

     }
    }
}
