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
   * ClientProvSvcRecBatchApproveDetails*/
  /**
   * Batch edit/delete
   *
   * Note: Just delete right now
   *
   ***************************************************************************/   

  public class ClientProvSvcRecBatchApproveDetails: WebUI
  {
    public ClientProvSvcRecBatchApproveDetails() : base(  "service_records_batch_approve_details",
                                                   WebUI.CreatePageSubTitle(ServiceRecordsApproval.SEL_LABEL_PRAC_SUPERVISOR_REV_SVC),
                                                   "client_prov_svcrec_batch_approve_details.css",
                                                   "",
                                                   Constants.ROLE_LEA_PROVIDER){}
        
    protected void Page_Load(object sender, EventArgs e)
    {      
      string pracid = MBA.HttpApplication.getParameter("pracid");  
      Spedmon.Validate.reqInteger (pracid, @"Invalid prac id");
      WebUIControlDataField ctrlPracID = findControlRecu(this.Page, "pracid") as WebUIControlDataField;
      ctrlPracID.value = pracid;      
    }
  
  }
}
