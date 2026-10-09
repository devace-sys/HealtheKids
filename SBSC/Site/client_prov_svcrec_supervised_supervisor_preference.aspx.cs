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

  public class ClientProvSvcRecSupervisedSupervisorPreference: WebUI
  {
    public ClientProvSvcRecSupervisedSupervisorPreference() : base(  "supervisor_supervised_pref",
                                                   WebUI.CreatePageSubTitle(ServiceRecordsApproval.SEL_LABEL, ServiceRecordsApproval.SEL_LABEL_PRAC_SUPERVISED_SEL_SUP),
                                                   "",
                                                   "",
                                                   Constants.ROLE_LEA_PROVIDER){}
        
    protected void Page_Load(object sender, EventArgs e)
    {          
    
    }
  
  }
}
