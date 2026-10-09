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
   * UserAllTransportMgmtManageSvcRecs */
  /**
   * Manage transportation service records
   ***************************************************************************/   

  public class UserAllTransportMgmtManageSvcRecs : WebUI
  {
         
    public UserAllTransportMgmtManageSvcRecs() : base( "transport_mgmt"
	                                     , WebUI.CreatePageSubTitle (  TransportationMgmtRecords.SEL_LABEL
	                                                                 , TransportationMgmtRecords.SEL_LABEL_MANAGE_SERVICE_RECORDS)
				                               , ""
						                           , ""
										                   , Constants.ROLE_SVC_PRAC){}    
    
	  public string clientID         = "";
	  public string saveType         = "";
    public string tkn              = "";
        
    protected void Page_Load(object sender, EventArgs e)
    {      
	    if (this.rd.loggedIn)
	    {
	      clientID  = Spedmon.Validate.reqClientID(uInfo,MBA.HttpApplication.getParameter(@"clientid")).ToString();
	      saveType  = Constants.SAVE_TYPE_NEW.ToString();
        tkn       = this.rd.wu.usr.token;                      
      }
    }
  }
}
