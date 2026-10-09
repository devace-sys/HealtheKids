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
   * SbsAllAllergiesManage */
  /**
   * 
   ***************************************************************************/

  public class SbsAllAllergiesManage : WebUI
  {
    
    public SbsAllAllergiesManage() : base ( "sbs_all_allergies_manage"
                                             , Allergies.SEL_LABEL_MANAGE                                                          
                                             , @""
                                             , @""
                                             , Constants.ROLE_SBS_ALL) { }
    
    protected void Page_Load(object sender, EventArgs e)
    {
      /***************************************************************************
       * Get control references and set values
       ***************************************************************************/
      
      var ctrlActive    = findControlRecu (this.Page, Constants.PARM_ACTIVE)             as MBA.HiddenInput;
      ctrlActive.value  = "1";
    
    }
  }
}
