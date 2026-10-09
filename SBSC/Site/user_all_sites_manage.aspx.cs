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
   * UserAllSitesManage */
  /**
   * 
   ***************************************************************************/

  public class UserAllSitesManage : WebUI
  {
    
    public UserAllSitesManage() : base ( "user_all_sites_manage"
                                         , Sites.SEL_LABEL_MANAGE
                                         , @""
                                         , @""
                                         , Constants.ROLE_ALL_PCAL_AND_CLIENT) { }
    
    public bool showCybhiOptions = false;

    protected void Page_Load(object sender, EventArgs e)
    {
      if (uInfo.pcalStaff == true) {             
        showCybhiOptions = true;
      }            
    }
  }
}