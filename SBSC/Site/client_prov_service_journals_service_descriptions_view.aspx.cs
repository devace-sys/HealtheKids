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
   * ClientProvServiceJournalsServiceDescriptionsView */
  /**
   * 
   ***************************************************************************/

  public class ClientProvServiceJournalsServiceDescriptionsView : WebUI
  {
    
    public ClientProvServiceJournalsServiceDescriptionsView() : base("service_descriptions_view"
	                                                               , WebUI.CreatePageSubTitle(  ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION
	                                                                                          , ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_VIEW)
	                                                               , ""
	                                                               , ""
	                                                               , Constants.ROLE_LEA_PROVIDER) { }
    
	  protected void Page_Load(object sender, EventArgs e)
    {  
    
      
      /*###########################################################################
        # Exit if the prac is not allowed on this screen
        ###########################################################################*/    
           
      if (!ServiceJournals.isPracSomeoneWhoCanManageSvcDescr (ref rd)) throw new MBA.Critical(Messages.ACCESS_DENIED);
                  
    
    }
  }
}