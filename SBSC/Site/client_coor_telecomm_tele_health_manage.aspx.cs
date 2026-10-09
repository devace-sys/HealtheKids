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
   * ClientCoorTeleCommTeleHealthManage */
  /**
   * 
   ***************************************************************************/

  public class ClientCoorTeleCommTeleHealthManage : WebUI
  {
    
    public ClientCoorTeleCommTeleHealthManage() : base ( "telecomm_tele_health_manage"
                                                         , TeleHealthSessions.SEL_LABEL_MANAGE
                                                         , ""
                                                         , ""
                                                         , Constants.ROLE_LEA_COORD_AND_ASSIST) { }
    
    protected void Page_Load(object sender, EventArgs e)
    {   
      TeleHealthSessions.validateClientAccessForPage(dbConnApp,log,uInfo,uInfo.userClientIDStr,this.Response,this.Context);
    }
  }
}
