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
   * ClientProvServiceRecordBatchSave */
  /**
   * Provides a screen for LEA providers to save their service records in
   * batches.
   * 
   * Please note:
   * 
   * The saving of new records is the only save type that is supported
   * at this time.
   ***************************************************************************/    

  public class ClientProvServiceRecordBatchSave : WebUI
  {
    public int saveType = Constants.SAVE_TYPE_NEW;
    
    public ClientProvServiceRecordBatchSave() : 
      base ("service_record_save", 
            "Service Records - Record Multiple New", 
            "", 
            "", 
            Constants.ROLE_LEA_PROVIDER){}
    
    protected void Page_Load(object sender, EventArgs e)
    { 
      
      /* If user is logged in get client and prac id */
      
      if (rd.loggedIn) 
      {
        WebUIControlDataField ctrlClientID = findControlRecu(this.Page, "clientid")      as WebUIControlDataField;
        WebUIControlDataField ctrlPracID   = findControlRecu(this.Page, "pracid")        as WebUIControlDataField;

        ctrlClientID.value = Spedmon.Validate.reqClientID (uInfo, "").ToString();
        ctrlPracID.value   = Spedmon.Validate.reqPracID   (uInfo, "").ToString();
      }

     
    }

  }
}
