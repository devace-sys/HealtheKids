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
   * UserAllPracticeOfficeKiosksManage */
  /**
   * 
   ***************************************************************************/

  public class UserAllPracticeOfficeKiosksManage : WebUI
  {
    
    public UserAllPracticeOfficeKiosksManage() : base ( "user_practice_office_kiosks_manage"
                                                        , "Kiosks Manage"                                                           
                                                        , @""
                                                        , @"qrcode.min.js"
                                                        , Constants.ROLE_ALL_PCAL_AND_CLIENT) { }
    public bool   pageInitIsOK           = false;
    public long   groupSvcClassNameID    = -1;

    protected void Page_Load(object sender, EventArgs e)
    {
      /***************************************************************************
       * Get control references
       ***************************************************************************/
      
      var ctrlGroupSvcClassNameID       = findControlRecu (this.Page, Constants.PARM_GRP_SVC_CLS_NME_ID) as MBA.HiddenInput;
      var ctrlActive                    = findControlRecu (this.Page, Constants.PARM_ACTIVE)             as MBA.HiddenInput;

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
        this.subTitle = PracticeOfficeCommon.SEL_LABEL_KIOSK_MANAGE(groupSvcClassNameID,true);
      }
      else {
        pageInitIsOK = false;
      }         
     }
  }
}
