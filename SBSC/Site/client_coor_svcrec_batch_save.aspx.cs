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
   * ClientCoorServiceRecordBatchSave */
  /**
   * Provides a screen for LEA coordinators to save services for their 
   * district in batches.
   * 
   * Please note:
   * 
   * The saving of new records is the only save type that is supported
   * at this time.
   ***************************************************************************/   

  public class ClientCoorServiceRecordBatchSave : WebUI
  {
    public int saveType = Constants.SAVE_TYPE_NEW;

    public ClientCoorServiceRecordBatchSave() 
      : base("service_record_save",
             "Service Records - Record Multiple New",
              "",
              "",
              Constants.ROLE_CLIENT_BO){}
    
    protected void Page_Load(object sender, EventArgs e)
    {
      /* If user is logged in get client id */
      
      if (rd.loggedIn) 
      {
        WebUIControlDataField ctrlClientID = findControlRecu(this.Page, "clientid")      as WebUIControlDataField;
        ctrlClientID.value = Spedmon.Validate.reqClientID (uInfo, "").ToString();
      }

    
    }

  }
}
