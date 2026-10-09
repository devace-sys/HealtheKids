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
   * ClientCoorTransportMgmtProcessIncomingRouteSheet */
  /**
   * Manage transportation services
   ***************************************************************************/   

  public class ClientCoorTransportMgmtProcessIncomingRouteSheet : WebUI
  {          
    public ClientCoorTransportMgmtProcessIncomingRouteSheet() : base( "transport_mgmt"
	                                                               , WebUI.CreatePageSubTitle(  TransportationMgmtRecords.SEL_LABEL , TransportationMgmtRecords.SEL_LABEL_PROCESS_INCOMING_SHEET)										                                             
										                                             ,""
										                                             , "transport-mgmt-sheet-proc.js"
										                                             , Constants.ROLE_CLIENT_BO
										                                             ){}        
    public int saveType = 0;
    
    protected void Page_Load(object sender, EventArgs e)
    {      
      WebUIControlDataField ctrlClientID  = findControlRecu(this.Page, "clientid") as WebUIControlDataField;               
      ctrlClientID.value = Spedmon.Validate.reqClientID(uInfo,MBA.HttpApplication.getParameter(@"clientid")).ToString();       
      TransportationMgmtRecords.autoCreateOrUpdate (  dbConnApp, log, uInfo, ctrlClientID.value);
      saveType = Constants.SAVE_TYPE_NEW;
    }  
      
  }
}
