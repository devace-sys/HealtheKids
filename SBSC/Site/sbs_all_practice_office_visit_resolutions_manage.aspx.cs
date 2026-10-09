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
   * SbsAllPracticeOfficeResolutionsManage */
  /**
   * 
   ***************************************************************************/

  public class SbsAllPracticeOfficeResolutionsManage : WebUI
  {
    
    public SbsAllPracticeOfficeResolutionsManage() : base ( "sbs_all_practice_office_visit_resolutions_manage"
                                                        , "Visit Resolutions Manage"                                                           
                                                        , @""
                                                        , @""
                                                        , Constants.ROLE_SBS_ALL) { }

    protected void Page_Load(object sender, EventArgs e)
    {
      /***************************************************************************
       * Get control references
       ***************************************************************************/
      
      var ctrlActive                    = findControlRecu (this.Page, Constants.PARM_ACTIVE)             as MBA.HiddenInput;
      ctrlActive.value         = "1";
    
               
     }
  }
}
