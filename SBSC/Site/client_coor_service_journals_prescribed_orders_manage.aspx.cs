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
   * ClientCoorServiceJournalsPrescribedOrdersManage */
  /**
   * 
   ***************************************************************************/

  public class ClientCoorServiceJournalsPrescribedOrdersManage : WebUI
  {
    
    public ClientCoorServiceJournalsPrescribedOrdersManage() : base ( "prescribed_orders_manage"
                                                                 , ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE
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
