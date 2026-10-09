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
   * SBSAllServiceJournalsPrescribedOrdersManage */
  /**
   * 
   ***************************************************************************/

  public class SBSAllServiceJournalsPrescribedOrdersManage : WebUI
  {
    
    public SBSAllServiceJournalsPrescribedOrdersManage() : base ( "prescribed_orders_manage"
                                                                 , ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE
                                                                 , ""
                                                                 , ""
                                                                 , Constants.ROLE_SBS_ALL) { }
    
    protected void Page_Load(object sender, EventArgs e)
    {   
                 
    }
  }
}
