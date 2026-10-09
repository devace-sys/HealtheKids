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
   * ClientCoorServiceJournalsServiceDescriptionsManage */
  /**
   * 
   ***************************************************************************/

  public class ClientCoorServiceJournalsServiceDescriptionsManage : WebUI
  {
    
    public ClientCoorServiceJournalsServiceDescriptionsManage() : base ( "service_descriptions_manage"
                                                              , ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_MANAGE
                                                              , ""
                                                              , ""
                                                              , Constants.ROLE_CLIENT_BO) { }
    
    protected void Page_Load(object sender, EventArgs e)
    {                    
      long vClientID = Spedmon.Validate.reqClientID (uInfo, "");
      MBA.HiddenInput ctrlClientID = findControlRecu(this.Page,  "clientid") as MBA.HiddenInput;
      ctrlClientID.value = vClientID.ToString();
    }
    
  }
}
