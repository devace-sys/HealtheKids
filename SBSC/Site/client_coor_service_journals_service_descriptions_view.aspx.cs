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
   * ClientCoorServiceJournalsServiceDescriptionsView */
  /**
   * 
   ***************************************************************************/

  public class ClientCoorServiceJournalsServiceDescriptionsView : WebUI
  {
    
    public ClientCoorServiceJournalsServiceDescriptionsView() : base("service_descriptions_view"
	                                                               , WebUI.CreatePageSubTitle(  ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION
	                                                                                          , ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_VIEW)
	                                                               , ""
	                                                               , ""
	                                                               , Constants.ROLE_CLIENT_BO) { }
    
	  protected void Page_Load(object sender, EventArgs e)
    {  
    }
  }
}