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
   * SBSAllTeleCommTeleHealthManage */
  /**
   * 
   ***************************************************************************/

  public class SBSAllTeleCommTeleHealthManage : WebUI
  {
    
    public SBSAllTeleCommTeleHealthManage() : base (  "telecomm_tele_health_manage"
                                                     , TeleHealthSessions.SEL_LABEL_MANAGE
                                                     , ""
                                                     , ""
                                                     , Constants.ROLE_SBS_ALL) { }
    
    protected void Page_Load(object sender, EventArgs e)
    {   
                 
    }
  }
}
