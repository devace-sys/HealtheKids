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
   * SBSAllServiceJournalsServiceDescriptionsManage */
  /**
   * 
   ***************************************************************************/

  public class SBSAllServiceJournalsServiceDescriptionsManage : WebUI
  {
    
    public SBSAllServiceJournalsServiceDescriptionsManage() : base ( "service_descriptions_manage"
                                                              , ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_MANAGE
                                                              , ""
                                                              , ""
                                                              , Constants.ROLE_SBS_ALL) { }
    
    protected void Page_Load(object sender, EventArgs e)
    {                    
    }
    
  }
}
