using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.Services.Protocols;
using System.Web.Script.Serialization;
using System.ComponentModel;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

  [WebService(Namespace = "http://spedcare.com/")]
  [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
  [ScriptService]

  //public class SpedcareSessionsController : MBA.WebSvc
  public class SessionsSvc: MBA.WebSvc
  {
    
    /***************************************************************************
     * requestkeepalive */
    /**
     * Request session stay active
     ***************************************************************************/ 
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnValue requestkeepalive (string msgName, string msgDataJSON)
    {
      return (ReturnValue)
      callMethod(typeof(ReturnValue), 
      delegate()
      {
        return Spedmon.Sessions.requestKeepAlive(ref rd, msgName, msgDataJSON);        
      },
      Constants.ROLE_ALL); // Who can call this method    
    }

    
    //[WebMethod]
    //[ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    //public ReturnWebUser cmd (  string appname )
    //{
    //  return (ReturnWebUser)
    //  callMethod(typeof(ReturnWebUser),delegate ()
    //  {
    //    /* Note: This is a public method BUT it is only intended for internal server to server use.*/

    //    ReturnWebUser wu = new ReturnWebUser();
      
    //    /* See if actual request IP address for this web method is coming from a trusted list
    //     * If not then get out. */

    //    //if (!Util.isIpAddressIsInTrustedLocalIPs(rd.userIP)) {
    //    //  wu = new ReturnWebUser(new Exception(String.Format("{0} is not trusted",rd.userIP)));
    //    //  return wu;
    //    //}

    //    Credential.handleSessionLoginLogout (  appname
    //                                          , false
    //                                          , dbConnUser
    //                                          , dbConnApp
    //                                          , log
    //                                          , ref rd
    //                                          , ref wu );

    //    HttpContext.Current.Response.ContentType = @"application/json";
    //    return wu;
    //   });
    // }
  }
}
