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
   * ClientAllTeleCommTeleIEPManage */
  /**
   * 
   ***************************************************************************/

  public class ClientAllTeleCommTeleIEPManage : WebUI
  {
    
    public ClientAllTeleCommTeleIEPManage() : base (  "telecomm_tele_iep_manage"
                                                   , TeleIEPSessions.SEL_LABEL_MANAGE
                                                   , ""
                                                   , ""
                                                   , Constants.ROLE_CLIENT_BO_OR_PRAC) { }
    
    protected void Page_Load(object sender, EventArgs e)
    {   
      TeleIEPSessions.validateClientAccessForPage(dbConnApp,log,uInfo,uInfo.userClientIDStr,this.Response,this.Context);            
    }
  }
}
