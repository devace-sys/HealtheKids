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
   * ClientProvServiceJournalsPrescribedOrdersView*/
  /**
   * 
   ***************************************************************************/

  public class ClientProvServiceJournalsPrescribedOrdersView : WebUI
  {
    
    public ClientProvServiceJournalsPrescribedOrdersView() : base("prescribed_orders_view", WebUI.CreatePageSubTitle(ServiceJournals.SEL_LABEL_MANAGE_ORDERS, ServiceJournals.SEL_LABEL_MANAGE_ORDERS_VIEW), "", "", Constants.ROLE_LEA_PROVIDER) { }
    protected void Page_Load(object sender, EventArgs e)
    {  
    }
  }
}
