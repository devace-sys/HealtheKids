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
   * ServiceRecordBatchSave */
  /**
   * Saves a service record
   ***************************************************************************/   

  public class SBSAllServiceRecordBatchSave : WebUI
  {
    public int saveType = Constants.SAVE_TYPE_NEW;
  
    public SBSAllServiceRecordBatchSave() : base("service_record_save","Service Records - Record Multiple New","","",Constants.ROLE_SBS_ALL){}
    
    protected void Page_Load(object sender, EventArgs e)
    {
    
    }
  }
}
