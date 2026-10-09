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
   * ClientCoorServiceJournalsPrescribedOrdersEditDelete */
  /**
   * 
   ***************************************************************************/

  public class ClientCoorServiceJournalsPrescribedOrdersEditDelete : WebUI
  {
    
    public ClientCoorServiceJournalsPrescribedOrdersEditDelete() : base("prescribed_orders_edit_delete", WebUI.CreatePageSubTitle(ServiceJournals.SEL_LABEL_MANAGE_ORDERS, ServiceJournals.SEL_LABEL_MANAGE_ORDERS_EDIT_DELETE), "", "", Constants.ROLE_CLIENT_BO) { }
    protected void Page_Load(object sender, EventArgs e)
    {   
    }
  }
}
