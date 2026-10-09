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
   * ClientProvSvcRecBatchApproveSummary */
  /**
   * Batch edit/delete
   *
   * Note: Just delete right now
   *
   ***************************************************************************/   

  public class ClientProvSvcRecBatchApproveSummary: WebUI
  {
    public ClientProvSvcRecBatchApproveSummary() : base(  "service_records_batch_approve_summary",
                                                   WebUI.CreatePageSubTitle(ServiceRecordsApproval.SEL_LABEL_PRAC_SUPERVISOR_REV_SVC),
                                                   "",
                                                   "",
                                                   Constants.ROLE_LEA_PROVIDER){}
        
    protected void Page_Load(object sender, EventArgs e)
    {    
      
    }
  
  }
}
