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
   * client_prov_service_record_save_batch */
  /**
   * Provides a screen for LEA providers to save their service records in
   * batches.
   * 
   * Please note:
   * 
   * The saving of new records is the only save type that is supported
   * at this time.
   ***************************************************************************/    

  public class client_prov_service_record_save_batch : WebUI
  {
    public int saveType = Constants.SAVE_TYPE_NEW;

    public client_prov_service_record_save_batch () : 
      base ("service_record_save", 
            "Service Records - Record Multiple New", 
            "", 
            "", 
            Constants.ROLE_LEA_PROVIDER){}
    
    protected void Page_Load(object sender, EventArgs e)
    { 
     
    }

  }
}
