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
using System.Collections.Generic;

namespace Spedmon
{
  /***************************************************************************
   * SbsAllPracticeOfficeReasonsManage */
  /**
   * 
   ***************************************************************************/

  public class SbsAllPracticeOfficeReasonsManage : WebUI
  {
    
    public SbsAllPracticeOfficeReasonsManage() : base ( "sbs_all_practice_office_visit_reasons_manage"
                                                        , "Visit Reasons Manage"                                                           
                                                        , @""
                                                        , @""
                                                        , Constants.ROLE_SBS_ALL) { }
    public bool   pageInitIsOK           = false;
    public long   groupSvcClassNameID    = -1;

    protected void Page_Load(object sender, EventArgs e)
    {
      /***************************************************************************
       * Get control references
       ***************************************************************************/
      
      var ctrlGroupSvcClassNameID            = findControlRecu (this.Page, Constants.PARM_GRP_SVC_CLS_NME_ID) as MBA.HiddenInput;
      var ctrlActive                         = findControlRecu (this.Page, Constants.PARM_ACTIVE)             as MBA.HiddenInput;
      
      ctrlActive.value         = "1";
    
      /***************************************************************************
       * Get parameters passed
       ***************************************************************************/

      /* Get practice family */

      string groupSvcClassNameIDStr = MBA.HttpApplication.getParameter(Constants.PARM_GRP_SVC_CLS_NME_ID);

        
      
      /* If practice family is passed set the page title and label*/

      if (long.TryParse(groupSvcClassNameIDStr,out groupSvcClassNameID)) { 
        pageInitIsOK = true;
        ctrlGroupSvcClassNameID.value = groupSvcClassNameIDStr;
        this.subTitle = PracticeOfficeCommon.SEL_LABEL_VISIT_REASONS_MANAGE(groupSvcClassNameID, true);
      }
      else {
        pageInitIsOK = false;
      }         
     }
  }
}
