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
   * ServiceRecordBatchEditDelete */
  /**
   * Batch edit/delete
   *
   * Note: Just delete right now
   *
   ***************************************************************************/   

  public class SBSAllServiceRecordsBatchEditDelete: WebUI
  {
    public SBSAllServiceRecordsBatchEditDelete() : base("service_records_batch_edit_delete",
                                                   "Service Records - Batch Delete",
                                                   "",
                                                   "",
                                                   Constants.ROLE_SBS_STAFF){}
    
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  
  }
}
