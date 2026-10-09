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
   * ClientAllPractitionerDirectSupervisionManage*/
  /**
   * 
   ***************************************************************************/

  public class ClientAllPractitionerDirectSupervisionManage : WebUI
  {
    
    public ClientAllPractitionerDirectSupervisionManage() : base (   "supervision_manage"
                                                     , PractitionerDirectSupervisors.SEL_LABEL_MANAGE
                                                     , ""
                                                     , ""
                                                     , Constants.ROLE_PRAC_DIR_SUP_ADMINS) { }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }
  }
}
