using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Text;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * UserAllServiceAuthorizationRequestResponsesManage */
  /**
   * Entry point for viewing, responding, and cancelling service authorization
   * requests.
   ***************************************************************************/   
               
  public class UserAllServiceAuthorizationRequestResponsesManage: WebUI
  {
      
    
  
    public string requestResponseBaseUrl      = @"";
    public string tkn                         = @"";

    public UserAllServiceAuthorizationRequestResponsesManage() : base(@"svc_auth_requests_responses_manage_save"
	                                                             , ServiceAuthorizationRequests.SEL_LABEL_RESPOND
                                                               , @"service_authorization_requests_responses_manage.css"
                                                               , @""
										                                           , Constants.ROLE_SVC_AUTH_RESPONDERS){} 

    protected void Page_Load(object sender, EventArgs e)

    {      
	    if (!this.rd.loggedIn) return;
      requestResponseBaseUrl = MBA.HttpApplication.createLink(  ServiceAuthorizationRequestResponses.URL_SAVE_RESPONSE
                                                                , true
                                                                , new NameValue(Constants.PARM_CONTENT_ONLY,"1")
                                                                , new NameValue(Constants.PARM_REC_ID,@""));            
             
    }

  }
}
