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
   * ClientProvServiceJournalsServiceDescriptionsManage */
  /**
   * 
   ***************************************************************************/

  public class ClientProvServiceJournalsServiceDescriptionsManage : WebUI
  {
    
    public ClientProvServiceJournalsServiceDescriptionsManage() : base ( "service_descriptions_manage"
                                                              , ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_MANAGE
                                                              , ""
                                                              , ""
                                                              , Constants.ROLE_LEA_PROVIDER) { }
    
    protected void Page_Load(object sender, EventArgs e)
    {                    
      long vClientID = Spedmon.Validate.reqClientID (uInfo, "");
      long vPracID   = Spedmon.Validate.reqPracID  (uInfo, "");
      
      MBA.HiddenInput ctrlClientID = findControlRecu(this.Page,  "clientid") as MBA.HiddenInput;
      MBA.HiddenInput ctrlPracID   = findControlRecu(this.Page,  "pracid") as MBA.HiddenInput;
      
      ctrlClientID.value = vClientID.ToString();
      ctrlPracID.value    = vPracID.ToString();

    }
    
  }
}
