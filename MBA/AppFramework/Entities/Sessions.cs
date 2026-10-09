using MBA.Security;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;

namespace MBA
{
  
  /***************************************************************************
   * Sessions */
  /**
   * 
   ***************************************************************************/

  public class Sessions
  {
    
    public const string URL_ASMX                    = "sessions.asmx";
    public const string URL_ASMX_REQUEST_KEEP_ALIVE = URL_ASMX + "/requestkeepalive";
     
    /***************************************************************************
     * URL_WEB_SVC_REQUEST_KEEP_ALIVE */
    /**
     * 
     **************************************************************************/  
    public static string WEB_SVC_CDE_REQUEST_KEEP_ALIVE()
    {
      return MBA.HttpApplication.createLink(URL_ASMX_REQUEST_KEEP_ALIVE, true);
    }    
    public static ReturnValue requestKeepAlive ( string appName, ref RequestResponse rd, string msgName, string msgDataJSON )
     {
          ReturnValue so = new ReturnValue();
          try { 
            var tokenExpiresInSeconds = rd.wu.usr.sessionTokenExpires.Subtract(DateTime.Now).TotalSeconds;            
            so.value = Math.Round(tokenExpiresInSeconds).ToString();            
          } 
          catch {
            so.value = @"";
          }
          return so;
     }
  }
}
