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
   * UserAllTransportMgmtProcessIncomingRouteSheet */
  /**
   * Manage transportation services
   ***************************************************************************/   

  public class SBSAllTransportMgmtProcessIncomingRouteSheet : WebUI
  {          
    public SBSAllTransportMgmtProcessIncomingRouteSheet() : base( "transport_mgmt"
	                                                               , WebUI.CreatePageSubTitle(  TransportationMgmtRecords.SEL_LABEL , TransportationMgmtRecords.SEL_LABEL_PROCESS_INCOMING_SHEET)										                                             
										                                             ,""
										                                             ,"transport-mgmt-sheet-proc.js"
										                                             , Constants.ROLE_SBS_ALL
										                                             ){}        
    public string tkn      = "";
    public int    saveType = 0;
    
    protected void Page_Load(object sender, EventArgs e)
    {      
	    if (this.rd.loggedIn)
	    {
        tkn = this.rd.wu.usr.token;                    
      } 
           
      saveType = Constants.SAVE_TYPE_NEW;
        
    }
  }
}
