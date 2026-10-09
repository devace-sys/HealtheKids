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
   * UserAllTransportMgmtManagePatientsAndRoutes */
  /**
   * Manage transportation services
   ***************************************************************************/   

  public class UserAllTransportMgmtManagePatientsAndRoutes : WebUI
  {
  
    
    
    public UserAllTransportMgmtManagePatientsAndRoutes() : base( "transport_mgmt"
	                                     , WebUI.CreatePageSubTitle(  TransportationMgmtRecords.SEL_LABEL
	                                                                 , TransportationMgmtRecords.SEL_LABEL_MANAGE)
				                               , "transport-mgmt.css"
						                           , "transport-mgmt.js"
										                   , Constants.ROLE_ALL_PCAL_AND_CLIENT){}
										                   
    public string clientID         = "";
    public string tkn              = "";
    public string pracID           = "0";
    public string startDateDefault = "";
    public bool   showTopInfo      = true;
    
    public TransportationMgmtRecord tmr = new TransportationMgmtRecord();
    
    protected void Page_Load(object sender, EventArgs e)
    {      
	    if (this.rd.loggedIn)
	    {
	      clientID         = Spedmon.Validate.reqClientID(uInfo,MBA.HttpApplication.getParameter(@"clientid")).ToString();
          tkn              = this.rd.wu.usr.token;
          startDateDefault = Util.generateStartDateThisMondayOrNext(null).ToShortDateString();
        
          if (this.rd.wu.usr.userGroupID == Constants.USER_GROUP_CLIENT) showTopInfo = false;
        
        
          TransportationMgmtRecords.autoCreateOrUpdate(   dbConnApp
                                                         , log
                                                         , uInfo
                                                         , clientID);
        
          tmr = TransportationMgmtRecords.loadCurrent (   dbConnApp
                                                        , log
                                                        , uInfo
                                                        , clientID );                     

      }
    }
  }
}
