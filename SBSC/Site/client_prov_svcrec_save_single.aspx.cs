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
   * ClientProvServiceRecordSaveSingle */
  /**
   * Saves a service record
   ***************************************************************************/   

  public class ClientProvServiceRecordSaveSingle : WebUI
  {
    
    public int saveType = Constants.SAVE_TYPE_NEW;
    
    public ClientProvServiceRecordSaveSingle() : base("service_record_save","Service Records - Save","","",Constants.ROLE_CLIENT_ALL){}
    
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
