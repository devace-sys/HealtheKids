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
using System.Text;
using System.Collections.Generic;
using Geo.ARIES;

namespace Spedmon
{
  /***************************************************************************
   * UserAllAriesApiTest */
  /**
   * 
   ***************************************************************************/


  public class UserAllAriesApiTest : WebUI

  {

    public UserAllAriesApiTest() : base(  "user-all-aries-api-test"
                                         , "ARIES API Test"
                                         , @""
                                         , @""
										 , Constants.ROLE_BULK_PATIENT_IMPORT) { }
    
    public const string PARM_NAME_SERVER    = Spedmon.Constants.PARM_API_URL;
    public const string PARM_NAME_API_TOKEN = Spedmon.Constants.PARM_API_TOKEN;
    
    public string clientID                  = "";
    public string amd                       = "";
    public string tkn                       = "";
    public string server                    = "";
    public string apiToken                  = "";
    public bool   requestSuccesful          = false;
    
    public string codeSetLookupUrl                              = @"";
    public string studentLookupUrl                              = @"";    
    public string siteLookupUrl                                 = @"";

    public Geo.ARIES.AriesSystemInfo  systemInfo = null;    


    protected void Page_Load(object sender, EventArgs e)
    {

      systemInfo               = new Geo.ARIES.AriesSystemInfo();      
      systemInfo.hasData       = false;
      systemInfo.AeriesVersion = @"";
      
      tkn      = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_TOKEN);
      amd      = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_APP_MODE);
      clientID = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_CLIENT_ID);
      server   = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_API_URL);
      apiToken = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_API_TOKEN);

      if (String.IsNullOrWhiteSpace(tkn)) tkn = this.rd.wu.usr.token;

      codeSetLookupUrl = Spedmon.ARIES.URL_CODE_SET_LOOKUP(amd,clientID,server,apiToken);       
      studentLookupUrl = Spedmon.ARIES.URL_STUDENT_STUDENTS_AT_SCHOOL(amd,clientID,server,apiToken,"");
      siteLookupUrl    = Spedmon.ARIES.URL_SCHOOLS(amd,clientID,server,apiToken,"");

      /* No server - get out */
      
      if (String.IsNullOrWhiteSpace(server)) return;

      systemInfo = Geo.ARIES.Common.GetSystemInfo(server, out requestSuccesful);    
      
      /* Request is not successful for sys info - get out */

      if (!requestSuccesful) return;

      /* No token - get out */

      if (String.IsNullOrWhiteSpace(apiToken)) return;      
                  
     }
  }
}
