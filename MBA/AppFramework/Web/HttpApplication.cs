using System;
using System.Collections;
using System.ComponentModel;
using System.Web;
using System.Web.Routing;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Text.RegularExpressions;
using System.Collections.Specialized;
using System.Collections.Generic;
using System.Reflection;
using System.Web.Script.Serialization;
using System.IO;
using System.Text;

namespace MBA
{  

  /***************************************************************************
   * MethodCallback*/
  /**
   * Delagate used by HttpApplication.callMethod()
   ***************************************************************************/

  public delegate Return MethodCallback(); 
  
  /***************************************************************************
   * GenericCallBack */
  /**
   * Generic call back delegate
   ***************************************************************************/

  public delegate void GenericCallBack();
  
  /***************************************************************************
   * ExceptionCallBack */
  /**
   * Generic call back delegate
   ***************************************************************************/

  public delegate void ExceptionCallBack(Exception e);
  
  /***************************************************************************
   * ReturnCallBack */
  /**
   * Generic call back delegate
   ***************************************************************************/
       
  public delegate void ReturnCallBack (ref Return rd);
    
  /***************************************************************************
   * JsonException */
  /**
   * Custom exception for handling JSON parsing exceptions
   ***************************************************************************/
  
  public class JsonException : MBA.Critical
  {
    private string _stackTrace;
    private string _message;

    public override string StackTrace
    {
      get { return _stackTrace; }
    }
      
    public override string Message
    {
      get { return _message; }
    }

    public JsonException(string json)
    {
      JavaScriptSerializer serialiser = new JavaScriptSerializer();
      Dictionary<string, string> data = serialiser.Deserialize<Dictionary<string, string>>(json);
      _message = data["Message"];
      _stackTrace = data["StackTrace"];
      Data.Add("OriginalExceptionType", data["ExceptionType"]);
     }
   }
      
  /***************************************************************************
   * HttpApplication */
  /**
   * Our base class for global.asax for both web services and web applications
   ***************************************************************************/

  public class HttpApplication : System.Web.HttpApplication
	{    
    public HttpApplication()
	{
      // Wire up our event handlers
      this.Error                     += new EventHandler(Application_Error);
      this.BeginRequest              += new EventHandler(Start_Request);
      this.PostRequestHandlerExecute += new EventHandler(Request_Execution_Complete);
      this.EndRequest                += new EventHandler(End_Request);
	}

    public static string REST_API_ROUTE_NAME_DICT_KEY = @"restapiroutename";
    
    /***************************************************************************
     * addRestApiRoute */
    /**
     * 
     ***************************************************************************/   

    public static void addRestApiRoute(  RouteCollection routes
                                       , bool   localNetworkAccessOnly
                                       , string version
                                       , string entityName 
                                       , Type   entityHandlerType)
    {
      
      // api/v1/patients
      // api/v1/patients

      string api       = "api";
      string routeName = api + "_"  + version + "_"   + entityName;
      string routeURL  = api + @"/" + version + @"/"  + entityName + @"/{id}";
      
      var handler = new EntitiesRestApiRouteHandler  (localNetworkAccessOnly, entityHandlerType);
      
      var route   = new Route (routeURL, handler);
      route.RouteExistingFiles = false;      
      route.Defaults           = new RouteValueDictionary {{"id",""}};
      route.DataTokens         = new RouteValueDictionary { { REST_API_ROUTE_NAME_DICT_KEY, routeName} };
      routes.Add(routeName,route);
    }

    /***************************************************************************
     * isCurrentRequestForRestApiRoute */
    /**
     * 
     ***************************************************************************/   
    
    public static bool isCurrentRequestForRestApiRoute ( RouteCollection routes, ref HttpContext context)
    {     
      var pathParts = context.Request.AppRelativeCurrentExecutionFilePath.Replace(@"~/",@"").Split('/');
      if (pathParts != null) return false;
      if (pathParts.Length > 2)
      {
        string resstapiroutenamevalue = String.Join(@"_",pathParts[0],pathParts[1],pathParts[2]);
        
        foreach(Route route in routes)
        {
          if (route.DataTokens.ContainsKey(REST_API_ROUTE_NAME_DICT_KEY))
          {
            if (route.DataTokens[REST_API_ROUTE_NAME_DICT_KEY].ToString() == resstapiroutenamevalue) 
            { 
              return true;
            }
          }
        }
      }
      return false;
    }

    /***************************************************************************
     * clientUID */
    /**
     * Returns contents of client user id from application parameters
     ***************************************************************************/   

    public static string clientUid() {return getParameter(Constants.PARM_UID);}
    
    /***************************************************************************
     * clientPWD */
    /**
     * Returns contents of client password from application parameters
     ***************************************************************************/   

    public static string clientPwd() {return getParameter(Constants.PARM_PWD);}
      
     
    /***************************************************************************
     * appTransferFlag */
    /**
     * Returns contents of app transfer flag parameter
     ***************************************************************************/       
    public static string appTransferFlag() {
      return getParameter(Constants.PARM_APP_TRANSFER);
    }

    /***************************************************************************
     * clientCmd */
    /**
     * Returns contents of cmd from application parameters
     ***************************************************************************/   

    public static string clientCmd() {return getParameter(Constants.PARM_CMD);}

    /***************************************************************************
     * clientConnected */
    /**
     * Returns true if client is connected
     ***************************************************************************/   
    
    public static bool clientConnected()
    {
      return HttpContext.Current.Response.IsClientConnected; 
    }
    
    /***************************************************************************
     * appMode */
    /**
     * Returns contents of appmode from application parameters
     ***************************************************************************/   

    public static string appMode() {return getParameter(Constants.PARM_APP_MODE);}

    /***************************************************************************
     * contentOnly */
    /**
     * Returns contents of contentOnly from application parameters
     ***************************************************************************/       
    public static string contentOnly() { var co = getParameter(Constants.PARM_CONTENT_ONLY); if (String.IsNullOrEmpty(co)) co = "0"; return co; }

    /***************************************************************************
     * contentOnly */
    /**
     * Returns language parameter
     *
     * en = English
     * es = Spanish     
     ***************************************************************************/       
        
    public static string language()
    {
      var _langIn = getParameter(Constants.PARM_LANGUAGE);

      /* If language passed in */

      if (!String.IsNullOrWhiteSpace(_langIn)) {         
        
        /* And its supported */

        if (    (_langIn == Constants.LANG_ENGLISH) 
             || (_langIn == Constants.LANG_SPANISH))
        { 
          return _langIn;    
        } 
        /* And its not supported */
        else {
          return String.Empty;
        }
      }   
      return String.Empty;            
    }

    /***************************************************************************
     * isAppOffline */
    /**
     * Returns status of app online config value.  If none exists returns a false
     * 
     ***************************************************************************/   

    public static bool isAppOffline (string action)
    {
      if (Util.IsNullOrEmpty(action)) action = @"";
      if (action == Constants.OFFLINE_PUBLIC) return false;
      bool? _appOffline = Constants.APP_OFFLINE;
      if (_appOffline.HasValue) return _appOffline.Value;
      return false;
    }

   /***************************************************************************
    * supportedBrowser */
   /**
    * Returns true if browser is supported
    ***************************************************************************/   

    public static bool supportedBrowser(string useragent)
    {
            
      /*-------------------------------
       * We detect the browser by looking
       * for key text in the user agent
       * string
       *------------------------------*/

      string ua = useragent.Trim().ToLower();
      
      if (ua.Contains("opera")) return false;
      if (ua.Contains(@"opr/")) return false;
      if (ua.Contains("trident")) return false;

      if (ua.Contains("firefox")) return true;
      if (ua.Contains("edge"))    return true;
      if (ua.Contains("chrome"))  return true;
      if (ua.Contains("safari"))  return true;
            
     /*-------------------------------
      * If we get to this point the
      * browser is unsupported
      *------------------------------*/

      return false;
    }

   /***************************************************************************
    * isBot */
   /**
    * Returns true if browser is supported
    ***************************************************************************/   
    
    public static bool isBot (string useragent)
    {
            
      /*-------------------------------
       * We detect the bot by looking
       * for key text in the user agent
       * string
       *------------------------------*/

      string tempUserAgent   = useragent.Trim().ToLower();
      string browser         = "";
                       
      /*-------------------------------
       * Googlebot
       *------------------------------*/

      browser = Regex.Match(tempUserAgent,@"googlebot").Value;
      if (!Util.IsNullOrEmpty(browser)) return true;
      
     /*-------------------------------
      * Yahoo! Slurp
      *------------------------------*/

      browser = Regex.Match(tempUserAgent,@"yahoo").Value;
      if (!Util.IsNullOrEmpty(browser)) return true;
     
     /*-------------------------------
      * Bing
      *------------------------------*/

      browser = Regex.Match(tempUserAgent,@"bingbot").Value;
      if (!Util.IsNullOrEmpty(browser)) return true;
      
      browser = Regex.Match(tempUserAgent,@"msnbot").Value;
      if (!Util.IsNullOrEmpty(browser)) return true;
      
      return false;

    }
    
    /***************************************************************************
     * identifyContentType */
    /**
     * Returns content type requested/delivered
     ***************************************************************************/   

    public static int identifyContentType(string hdrvalin)
    {
      if (Util.IsNullOrEmpty(hdrvalin)) hdrvalin = @"text/html";
      hdrvalin = hdrvalin.Trim().ToLower();
      if (hdrvalin.Contains("html"))  return 0;
      if (hdrvalin.Contains("json"))  return 1;
      if (hdrvalin.Contains("excel")) return 2;
      if (hdrvalin.Contains("pdf"))   return 3;
      if (hdrvalin.Contains("xml"))   return 4;
      return 0;
    }
    
    /***************************************************************************
     * clientToken */
    /**
     * Returns contents of security token from application parameters
     ***************************************************************************/   

    public static string clientToken() {return getParameter(Constants.PARM_TOKEN);}
    
    /***************************************************************************
     * clientMsg */
    /**
     * Returns raw contents of client msg application parameter.
     ***************************************************************************/   
    
    public static string clientMsg() {return getParameter(Constants.PARM_MSG);}

    /***************************************************************************
     * clientMsgText */
    /**
     * Returns text portion of client msg application parameter.
     ***************************************************************************/   
    
    public static string clientMsgTxt() {string msg = getParameter(Constants.PARM_MSG);
                                         if (String.IsNullOrEmpty(msg)) return "";
                                         string[] msgparts = msg.Split('|');
                                         if (msgparts.Length > 1) return msgparts[1];
                                         else return msgparts[0];}
    
    /***************************************************************************
     * clientMsgCde */
    /**
     * Returns code portion of client msg application parameter.
     ***************************************************************************/   
    
    public static int clientMsgCde() {string msg = getParameter(Constants.PARM_MSG);
                                      int cde = 0;
                                      if (String.IsNullOrEmpty(msg)) return cde;
                                      string[] msgparts = msg.Split('|');
                                      if (msgparts.Length < 2) return cde;
                                      try{cde = Convert.ToInt32(msgparts[0]);}catch{cde = 0;}
                                      return cde;}
    
    /***************************************************************************
     * clientUidPwdPassed */
    /**
     * Returns true if client is passing all of the required application parms
     * to login. 
     ***************************************************************************/   
    
    public static bool clientUidPwdPassed() {return ((!String.IsNullOrEmpty(clientUid())) &&
                                                     (!String.IsNullOrEmpty(clientPwd())) && 
                                                     (!String.IsNullOrEmpty(clientCmd())) &&
                                                     (clientCmd() == Constants.CMD_LOGIN));}
        
    /***************************************************************************
     * clientLogoutPassed */
    /**
     * Returns true if client is passing all of the required application parms
     * to logout. 
     ***************************************************************************/   

    public static bool clientLogoutPasssed() {return ((!String.IsNullOrEmpty(clientToken())) &&
                                                     (!String.IsNullOrEmpty(clientCmd())) &&
                                                     (clientCmd() == Constants.CMD_LOGOUT));}
    
    /***************************************************************************
     * clientLoginPassed */
    /**
     * Returns true if client is passing all of the required application parms
     * to login
     ****************************************************************************/   
    
    public static bool clientLoginPassed (ref RequestResponse rd) {return ((clientUidPwdPassed()) && (!rd.credentialOK));}

    /***************************************************************************
     * clientTokenPassed */
    /**
     * Returns true if client is passing all of the required application parms
     * for the security token.  This is used for maintaining a session. 
     ****************************************************************************/   

    public static bool clientTokenPassed() {return !String.IsNullOrEmpty(clientToken());}

    /***************************************************************************
     * clientAppTransferFlagPassed() */
    /**
     * Returns true if client is passing all of the required application parms
     * for transfering from one app to another without having to login to the
     * "another" app.
     ****************************************************************************/   
    
    public static bool clientAppTransferFlagPassed () { 
      return ((!String.IsNullOrWhiteSpace(appTransferFlag())) 
             && (!String.IsNullOrWhiteSpace(clientUid()))
             && (clientTokenPassed()));
    }
    
   /***************************************************************************
    * currentServer */
   /**
    * Returns the domain name of the current server.  For example on your dev.
    * machine this would probably return localhost or your machine name.  
    * On a production machine this would return whatever domain name was setup.
    ***************************************************************************/   

    public static string currentServer() 
    {
       if (HttpContext.Current == null) return String.Empty;
       return HttpContext.Current.Request.ServerVariables["SERVER_NAME"].ToString();
    }
    
    /***************************************************************************
     * getPhysicalPath */
    /**
     * Returns the physical path for the given virtual path
     ***************************************************************************/ 

    public static string getPhysicalPath (string virtualPath)
    {
      string ppath = HttpContext.Current.Server.MapPath(virtualPath);
      return ppath;
    }
    
    /***************************************************************************
     * getVirtualPath */
    /**
     * Returns the virtual path for the given physicalPath
     ***************************************************************************/ 
    
    public static string getVirtualPath (string physicalPath)
    {
    
      string vpath = physicalPath.Replace(HttpContext.Current.Request.ServerVariables["APPL_PHYSICAL_PATH"], String.Empty);
      return vpath.Replace(@"\", "/");;
    }
    
    /***************************************************************************
     * currentServerApp */
    /**
     * Returns the domain name of the current server and the app name as either
     * a secure or unsecure address.  For example if the domain name is localhost,
     * the app name is MBA, and the application is setup as secure this
     * method would return https://localhost/MBA/ 
     ***************************************************************************/ 
  
    public static string currentServerApp() {
      /* Get current server (assuming this is called from the context of an http server) */
      string currServer = currentServer();
      
      /*
       * If there is no value returned then 
       */
      
      if (String.IsNullOrWhiteSpace(currServer)) {
        /* See if we have a fallback value in app.config to use (this would be the case for batch apps, services, etc. */
        currServer = Constants.APP_HTTP_HOST; 
        /* If there is still no value then we need to set this to an empty string */
        if (String.IsNullOrWhiteSpace(currServer)) currServer = String.Empty;
      }
      
      return ((Rules.SECURE_CONNECTION_REQ) ? @"https://" : @"http://") 
             + currServer 
             + Constants.APP_VDIR;
    }
    
    /***************************************************************************
     * currentEndPointName */
    /**
     * Returns the filename of the end point being requested.  For example if
     * http://localhost/AppName/index.aspx is the requested end point then
     * index.aspx would be returned.
     ***************************************************************************/  
       
    public static string currentEndPointName() {return System.IO.Path.GetFileName(HttpContext.Current.Request.PhysicalPath);}
    
    /***************************************************************************
     * createFileDownloadCookie */
    /**
     * Create a cookie used by the filedownload plugin
     * 
     * @return                 Cookie
     ***************************************************************************/       

    public static HttpCookie createFileDownloadCookie()
    {
      return createFileDownloadCookie("true");
    }
    
    public static HttpCookie createFileDownloadCookie(string value)
    {
      HttpCookie c = new HttpCookie("fileDownload", value){Path="/"};
      c.Expires.AddHours(1);
      return c;
    }

    /***************************************************************************
     * createGeneratedFileDownloadReadyCookie */
    /**
     * Create a cookie used to let user know generated file download is being delivered
     * 
     * @return                 Cookie
     ***************************************************************************/      
    public static HttpCookie createGeneratedFileDownloadReadyCookie (string uidFromRequest, string returnData)
    {
      HttpCookie c = new HttpCookie(uidFromRequest,returnData) { Path = "/" };
      c.Expires.AddHours(1);
      return c;
    }

    /***************************************************************************
     * createLink */
    /**
     * Calls currentServerApp and appends url to the end of it generating a valid
     * link.  If parms are passed these are placed on the query string
     * 
     * @param  url             page or service name (ie index.aspx)
     * @parm   pvt             (optional) true = this is a private link so we append the token
     * @parm   parms           (optional) parameters 
     * @return                 Full link 
     ***************************************************************************/

    public static string createLink(string url)
    {
      return currentServerApp() + url;
    }
    
    public static string createLink(string url, bool pvt)
    {
      if (pvt){return createLink(url,new NameValue(Constants.PARM_TOKEN,clientToken()));}
      else{return createLink(url);}
    }
    
    public static string createLink(string url, params NameValue[] parms)
    {
       
      string p = @"";
      if (parms != null)
      {
        if (parms.Length > 0)
        {
          p = @"?" + parms[0].name + @"=" +   HttpUtility.UrlEncode(parms[0].value.ToString());
          for (int i=1;i<parms.Length;i++)
          {
            p = p + "&" + parms[i].name + @"=" +   HttpUtility.UrlEncode(parms[i].value.ToString());
          }
        }
      }
      return currentServerApp() + url + p;
    }

    public static string createLink (string url, bool pvt, params NameValue[] parms)
    {
      List <NameValue> pl = new List<NameValue>();
      string           p  = "";

      if (pvt) pl.Add(new NameValue(Constants.PARM_TOKEN,clientToken()));
      
      if (parms != null)
      {
        if (parms.Length > 0)
        {
          foreach (NameValue nvp in parms)
          {
            pl.Add(nvp);
          }
        }
      }

      if (pl.Count > 0)
      {
        p = @"?" + pl[0].name + @"=" +   HttpUtility.UrlEncode(pl[0].value.ToString());
          for (int i=1;i<pl.Count;i++)
          {
            p = p + "&" + pl[i].name + @"=" +   HttpUtility.UrlEncode(pl[i].value.ToString());
          }
      }
      
      return currentServerApp() + url + p;
    }
    
    /***************************************************************************
     * createLinkNonUrlEncoded */
    /**
     * Calls currentServerApp and appends url to the end of it generating a valid
     * link.  If parms are passed these are placed on the query string BUT they
     * are nor urlencoded.
     * 
     * @param  url             page or service name (ie index.aspx)
     * @parm   parms           (optional) parameters 
     * @return                 Full link 
     ***************************************************************************/       
    
    public static string createLinkNonUrlEncoded (string url, params NameValue[] parms)
    {
       
      string p = @"";
      if (parms != null)
      {
        if (parms.Length > 0)
        {
          p = @"?" + parms[0].name + @"=" +   parms[0].value.ToString();
          for (int i=1;i<parms.Length;i++)
          {
            p = p + "&" + parms[i].name + @"=" + parms[i].value.ToString();
          }
        }
      }
      return currentServerApp() + url + p;
    }

    /***************************************************************************
     * getParameter */
    /**
     * Retrieves a parameter from either the parameter collection or the http
     * header.
     * 
     * @param  parmname        Name of the parameter (ie tkn)
     * @parm   msg             (optional) error message if not found
     * @parm   errifnotfound   (optional) throw error if found
     * @parm   returnlower     (optional) return parameter as lowercase 
     * @return                 parameter as string
     ***************************************************************************/
       
    public static string getParameter (string parmname)            {return getParameter(parmname,"",false,false);}
    public static string getParameter (string parmname, string msg){return getParameter(parmname,msg,true,true);}
    public static string getParameter (string parmname, string msg, bool errifnotfound, bool returnlower)
    {
      string parm = HttpContext.Current.Request.Headers[parmname] != null ? HttpContext.Current.Request.Headers[parmname] : HttpContext.Current.Request.Params[parmname];
      if (String.IsNullOrEmpty(parm)) 
      {parm = "";if (errifnotfound) throw new Critical(msg);}
      parm = parm.Trim();
      if (returnlower) return parm.ToLower(); else return parm;
    }

    public static string getParameterForm (string parmname)
    {
      string parm = HttpContext.Current.Request.Headers[parmname] != null ? HttpContext.Current.Request.Headers[parmname] : HttpContext.Current.Request.Params[parmname];
      if (String.IsNullOrEmpty(parm)){ parm = HttpContext.Current.Request.Form[parmname]; }
      if (String.IsNullOrEmpty(parm)) 
      {parm = "";}
      parm = parm.Trim();
      return parm;
    }

    /***************************************************************************
     * isGzipSupported */
    /**
     * Determine if client supports gzip.  This is used for our response
     * compression.  This is a slightly modifed version of Rich Strahl's 
     * solution found on http://www.west-wind.com/Weblog/posts/10294.aspx
     * 
     * @return true if yes
     ***************************************************************************/   
    
    public static bool IsGZipSupported()
    {
      string AcceptEncoding = HttpContext.Current.Request.Headers["Accept-Encoding"];
      if (!String.IsNullOrEmpty(AcceptEncoding))
      {
        if  (AcceptEncoding.Contains("gzip") || AcceptEncoding.Contains("deflate"))
        {
          return true;
        }
      }
      return false;
    } 

    /***************************************************************************
     * GZipEncodeResponse */
    /**
     * If the client supports gzip compression and the COMPRESS_RESPONSES rule
     * is set to true, gzip compress our response.  This call needs
     * to be placed right before any response data is generated.
     * To accomplish this in our framework this has been placed in callMethod()
     *
     * Please note:
     * 
     * This only compresses DYNAMIC content from your application (ie anything
     * that goes through ASP.NET).  Static content such as HTML, images, CSS,
     * Javascript, SWF files, etc are not compressed by this.  These resources
     * COULD be compressed at the web server level though if the web server
     * supports compression or through the use of a custom handler (coupled with
     * modified src, href tags) to run all static content through ASP.NET. 
     * 
     * This is a slightly modifed version of Rich Strahl's solution found on
     * http://www.west-wind.com/Weblog/posts/10294.aspx
     ***************************************************************************/     
  
    public static void GZipEncodeResponse()
    {
      HttpResponse Response = HttpContext.Current.Response;
      if (IsGZipSupported() && (Rules.RESPONSE_COMPRESS))
      {
        string AcceptEncoding = HttpContext.Current.Request.Headers["Accept-Encoding"];
        if (AcceptEncoding.Contains("deflate"))
        {
            Response.Filter = new System.IO.Compression.DeflateStream(Response.Filter,
                                  System.IO.Compression.CompressionMode.Compress);
            Response.AppendHeader("Content-Encoding", "deflate");
        }
        else
        {
            Response.Filter = new System.IO.Compression.GZipStream(Response.Filter,
                                  System.IO.Compression.CompressionMode.Compress);
            Response.AppendHeader("Content-Encoding", "gzip");                    
        }
     }
     // Allow proxy servers to cache encoded and unencoded versions separately
     Response.AppendHeader("Vary", "Content-Encoding");
    }

    /***************************************************************************
     * retrieveRequestResponse */
    /**
     * @return RequestResponse object
     ***************************************************************************/       

    public static RequestResponse retrieveRequestResponse()
    {
      RequestResponse rd;
      try
      {
        /* Retrieve request/response data and throw exception if it is not present */
        if (!HttpContext.Current.Items.Contains("rd")) throw new Exception(Messages.MISSING_RD);        
        rd = (RequestResponse) HttpContext.Current.Items["rd"];
      }
      catch (Exception e)
      {
        throw new Exception(Messages.MISSING_RD);  
      }
      return rd;
    }
                
    /***************************************************************************
     * callMethod */
    /**
     * Our method wrapper for web applications and services.  This wrapper
     * provides database connection objects and access control.  All requests
     * need to be send through this wrapper.
     ***************************************************************************/     
     
    public static Object callMethod(ref SqlConnection dbConnUser, ref SqlConnection dbConnApp, ref DetailsLog log, ref RequestResponse rd, ref UserInfo uInfo, Type rt, MethodCallback cb, bool compressResponse = true){return callMethod(ref dbConnUser,ref dbConnApp,ref log,ref rd, ref uInfo, rt, cb, false, "");}
    public static Object callMethod(ref SqlConnection dbConnUser, ref SqlConnection dbConnApp, ref DetailsLog log, ref RequestResponse rd, ref UserInfo uInfo, Type rt, MethodCallback cb, bool privateMethod, params string[] permittedRoles)
    {
      rd = new RequestResponse();      
      
      bool earlyExit = false;
      
      try
      {    
        /*-------------------------------
         * Retrieve our request/response
         * object and immediately exit
         * if we cannot locate it
         *------------------------------*/      
        
        
        if (!HttpContext.Current.Items.Contains("rd")){throw new Exception(Messages.MISSING_RD);}
        rd = (RequestResponse) HttpContext.Current.Items["rd"];
        
        rd = retrieveRequestResponse();
        
        /*-------------------------------
         * Create details log          
         *------------------------------*/
         
         log = new DetailsLog();
        
        /*-------------------------------
         * Compress our response if we 
         * can.
         *------------------------------*/                       
        
        GZipEncodeResponse();
      
       /*-------------------------------
        * Open our database connections
        * If this fails we want to
        * immediatly exit with an
        * exception
        *------------------------------*/  
        
        try
        {
          dbConnUser    = MBA.Database.openConn(Constants.DB_CONN_USERS);
          dbConnApp     = MBA.Database.openConn(Constants.DB_CONN_APP); 
        }
        catch (Exception dbErr)
        {
          //throw new Fatal(Messages.FATAL_DB);
          throw new Fatal(dbErr.Message);
        }
        
        /*-------------------------------
         * If this is a private method
         * call perform authentication
         *------------------------------*/                       
        
        if ((privateMethod))
        {
          ReturnWebUser wu     = new ReturnWebUser();
          rd.privateResource   = true;
          rd.credentialOK      = false;
          rd.accessGranted     = false;
          rd.loggedIn          = false;
                
          /*-------------------------------
           * Login/logout commands from
           * web applications
           *------------------------------*/ 
      
          if (rd.webApp)
          { 

            if (rd.requestResource == Constants.CHANGE_MY_PASSWORD)    rd.endPointIsChangePassword = true;

            if (rd.requestResource == Constants.MAN_PAGES_PRIVATE_NEW) rd.endPointIsUnreadManPages = true;
          
            /* Handle login and logout commands.  Note: An EarlyExit may be thrown. */

            Credential.handleSessionLoginLogout (  Constants.APP_NAME
                                                 , true
                                                 , dbConnUser
                                                 , dbConnApp
                                                 , log
                                                 , ref rd 
                                                 , ref wu );
           
            /* User is already logged in or was redirected with a token from early exit*/

            if ((HttpApplication.clientTokenPassed()) && (!rd.credentialOK))
            {
               rd.credentialProvided = Constants.CREDENTIAL_TOKEN;

               wu = Credential.webSessionValidate(dbConnUser, dbConnApp, log, HttpApplication.clientToken(), rd, Constants.APP_NAME); 

               rd.wu           = wu;
               rd.loggedIn     = true;
               rd.credentialOK = true;                  
               
               /* If the users password must be changed and this is NOT the change password page indicate early exit to change password page */

               if ((rd.wu.usr.passwordMustBeChanged == true) && (rd.endPointIsChangePassword == false))
               {                
                 rd.earlyExitReason = Constants.EARLY_EXIT_CHANGE_PASSWORD;
                 throw new EarlyExit();
               }

               /* If the user requires a password change and this IS the change password screen requested
                * indicate that we do not want to show user notifications */

               if ((rd.wu.usr.passwordMustBeChanged == true) && (rd.endPointIsChangePassword == true))
               {
                 rd.doNotShowUserToDoNotices = true;
               }
               
               /* If this is the unread man pages and there are man pages to read indicate we dont want to show notices */

               if ((rd.wu.usr.numUnreadManPages > 0) && (rd.endPointIsUnreadManPages == true))
               {
                 rd.doNotShowUserToDoNotices = true;
               }
              
            }            
          }

          /*-------------------------------
           * Session check for all other
           * end point types
           *------------------------------*/ 
      
          if ((HttpApplication.clientTokenPassed()) && (!rd.credentialOK))
          {             
             rd.credentialProvided = Constants.CREDENTIAL_TOKEN;
             wu = Credential.webSessionValidate(dbConnUser, dbConnApp, log, HttpApplication.clientToken(), rd, Constants.APP_NAME); 
             rd.wu           = wu;
             rd.loggedIn     = true;
             rd.credentialOK = true;
          }
                    
          /*-------------------------------
           * If no credentials were passed
           * throw the request out
           *------------------------------*/ 
      
          if (!rd.credentialOK) throw new Critical(Messages.ACCESS_DENIED);
          
          // Now we need to determine if the user has access to this resource          
          
//          MBA.Validate.reqOption(rd.wu.usr.roleName,permittedRoles,Messages.ACCESS_DENIED);    
          MBA.UserAssignedRoles.userHasPermittedRole (ref permittedRoles, ref rd.wu.usr.allAssignedRolesData, Messages.ACCESS_DENIED);
  
          // If we reach this point access was granted
          
          rd.accessGranted = true;

          uInfo = new UserInfo();
          UserInfo.retrieveUserInfo(rd,ref uInfo); 

                                       
        }
        
        /*-------------------------------
         * Pass control to the code in
         * the delegate/callback and
         * get the return object
         *------------------------------*/ 

        Object ro = cb();
        
        return ro;
      }

      /*-------------------------------
       * Handle exceptions starting with
       * early exit
       *------------------------------*/
                   
      catch (EarlyExit e)
      {
        e.Data.Add("details",log.details);
        rd.earlyExit = true;
        earlyExit = true;
        Object[] v = new Object[] {e};
        return Activator.CreateInstance(rt,v);
      }

      /*-------------------------------
       * Session expiration
       *------------------------------*/

      catch (SessionExpired e)
      {
        // Update our request/response object (rd)
        log.addDetail(e.Message,Return.RET_WARNING);
        e.Data.Add("details",log.details);
        rd.status = Return.RET_SESSION_EXPIRE;
        rd.message = e.Message;
        rd.statmsg = rd.status + "|" + rd.message;
        Object[] v = new Object[] {e};
        earlyExit = true;
        return Activator.CreateInstance(rt,v);
      }

      /*-------------------------------
       * Subscription required
       *------------------------------*/

      catch (SubscriptionRequired e)
      {
        // Update our request/response object (rd)
        log.addDetail(e.Message,Return.RET_WARNING);
        e.Data.Add("details",log.details);
        rd.status = Return.RET_SUBSCRIPTION_REQUIRED;
        rd.message = e.Message;
        rd.statmsg = rd.status + "|" + rd.message;
        rd.subscriptionRequired = true;
        Object[] v = new Object[] {e};
        earlyExit = true;
        return Activator.CreateInstance(rt,v);
      }

      /*-------------------------------
       * Warnings
       *------------------------------*/

      catch(Warning e)
      {
        // Update our request/response object (rd)
        
        if (!e.excludeMsgFromDetails)
          log.addDetail(e.Message,Return.RET_WARNING);
        
        e.Data.Add("details",log.details);
        rd.status = Return.RET_WARNING;
        rd.message = e.Message;
        rd.statmsg = rd.status + "|" + rd.message;
        Object[] v = new Object[] {e};
        return Activator.CreateInstance(rt,v);
      }

      /*-------------------------------
       * Critical exceptions
       *------------------------------*/

      catch(Critical e)
      {
        // Update our request/response object (rd)
        
        if (!e.excludeMsgFromDetails)
          log.addDetail(e.Message,Return.RET_CRITICAL);

        e.Data.Add("details",log.details);
        rd.status = Return.RET_CRITICAL;
        rd.message = e.Message;
        rd.statmsg = rd.status + "|" + rd.message;
        Object[] v = new Object[] {e};
        return Activator.CreateInstance(rt,v);
      }

      /*-------------------------------
       * Fatal exceptions
       *------------------------------*/

      catch(Fatal e)
      {
        
        if (!e.excludeMsgFromDetails)
          log.addDetail(e.Message,Return.RET_FATAL);

        e.Data.Add("details",log.details);
        rd.status = Return.RET_FATAL;
        rd.message = e.Message;
        rd.statmsg = rd.status + "|" + rd.message;
        Object[] v = new Object[] {e};
        return Activator.CreateInstance(rt,v);
      }

      /*-------------------------------
       * Handle all other types of
       * exceptions
       *------------------------------*/
      
      catch(Exception e)
      {   
        // This catches all exceptions from either web svcs
        // or web apps
        // Update our request/response object (rd)
        
        log.addDetail(e.Message,Return.RET_ERROR);
        e.Data.Add("details",log.details);
        rd.status = Return.RET_ERROR;
        rd.message = e.Message;
        rd.statmsg = rd.status + "|" + rd.message;
        Object[] v = new Object[] {e};
        return Activator.CreateInstance(rt,v);
      }
      
      /*-------------------------------
       * Perform cleanup
       *------------------------------*/
      
      finally
      {                
        /*-------------------------------
         * Close database connections
         *------------------------------*/
        
        MBA.Database.closeConn(dbConnUser);
        MBA.Database.closeConn(dbConnApp);
        
       /*-------------------------------
        * Save request/response data
        *------------------------------*/
        
        HttpContext.Current.Items.Remove("rd");
        HttpContext.Current.Items.Add("rd",rd);
        
       /*-------------------------------
        * If the early exit flag is set
        * then we want to immediately
        * complete this request
        *------------------------------*/        
        
        if (earlyExit) 
          HttpContext.Current.ApplicationInstance.CompleteRequest();
      }
    }

    /**************************************************************************
     * addRequestHeader
    /**
     ***************************************************************************/
    
    public static void addRequestHeader(string name, string value)
    {
      // Hack to add request header
      // http://bigjimindc.blogspot.com/2007/07/ms-kb928365-aspnet-requestheadersadd.html?showComment=1256142896456#c3937244688277172426

      HttpRequest Request = HttpContext.Current.Request;
      NameValueCollection headers = Request.Headers;
      Type t = headers.GetType();
      System.Collections.ArrayList item = new System.Collections.ArrayList();
      t.InvokeMember("MakeReadWrite", BindingFlags.InvokeMethod | BindingFlags.NonPublic | BindingFlags.Instance,null,headers,null);
      t.InvokeMember("InvalidateCachedArrays",BindingFlags.InvokeMethod | BindingFlags.NonPublic | BindingFlags.Instance,null,headers,null);
      item.Add(value);
      t.InvokeMember("BaseAdd",BindingFlags.InvokeMethod | BindingFlags.NonPublic | BindingFlags.Instance,null,headers, new object[]{name,item});
      t.InvokeMember("MakeReadOnly",BindingFlags.InvokeMethod | BindingFlags.NonPublic | BindingFlags.Instance,null,headers,null);
      return;
    }

    /**************************************************************************
     * createMessageURL
    /**
     ***************************************************************************/
   
    public static string createMessageURL(string url,string msg, bool pvtPage)
    {
      string newURL = "";

      if (pvtPage)
      {
        newURL = createLink(url, new NameValue(Constants.PARM_MSG,msg),new NameValue(Constants.PARM_TOKEN,clientToken()));   
      }
      else
      {
        newURL = createLink(url, new NameValue(Constants.PARM_MSG,msg));
      }
      return newURL;      
    }

    /*-------------------------------
     * Event handlers
     *------------------------------*/ 
   
    /**************************************************************************
     * JsonErrorResponseFilter 
   /**
     * Custom stream for filtering out JSON errors
     ***************************************************************************/

   class JsonErrorResponseFilter : Stream
   {

     private Stream  _responseStream = null;

     public JsonErrorResponseFilter(Stream responseStream)
     {
       _responseStream = responseStream;
     }

     public override bool CanRead  { get { return true; } }
     public override bool CanSeek  { get { return true; } }
     public override bool CanWrite { get { return true; } }
     public override void Flush()  { _responseStream.Flush(); }
     public override long Length   { get { return _responseStream.Length; } }

     public override long Position
     { 
       get { return _responseStream.Position; } 
       set { _responseStream.Position = value; }
     }
 
     public override int Read(byte[] buffer, int offset, int count)
     {
       return _responseStream.Read(buffer, offset, count);
     }

     public override long Seek(long offset, SeekOrigin origin)
     {
       return _responseStream.Seek(offset, origin);
     }

     public override void SetLength(long value)
     {
       _responseStream.SetLength(value);
     }

     public override void Write(byte[] buffer, int offset, int count)
     {
       HttpContext _ctx = HttpContext.Current;         
      
       /*-------------------------------
        * If rd is missing immediately
        * throw an error to the web 
        * server
        *-----------------------------*/ 
      
      if (!_ctx.Items.Contains("rd"))
      {
        throw new Exception(Messages.MISSING_RD);
      }
      
      /*-------------------------------
       * Otherwiese grab it
       *-----------------------------*/ 

       RequestResponse rd = (RequestResponse) HttpContext.Current.Items["rd"];     
        

       string response = Encoding.UTF8.GetString(buffer, offset, count);       
       JsonException error = new JsonException(response);  
       
       rd.message = error.Message;
       rd.rrissue = true;
       
       // Save request response data
      
      HttpContext.Current.Items.Remove("rd");
      HttpContext.Current.Items.Add("rd",rd);
      
       _responseStream.Write(buffer, offset, count);
     }
   }
    
    protected void Request_Execution_Complete (Object sender, EventArgs e)
    {
      
      HttpContext _ctx = HttpContext.Current;  

      /*-------------------------------
       * Check for web service errors
       *-----------------------------*/ 
      
      if (_ctx.Request.FilePath.Contains(".asmx") && _ctx.Response.StatusCode == 500)
      {
        
        /*-------------------------------
         * JSON Errors
         *-----------------------------*/        
        
        if (_ctx.Response.ContentType == "application/json")
        {
          // Note: Setting rf to the contents of the response filter is a workaround for a bug in .NET 3.5
          // Courtesey of http://romsteady.blogspot.com/2008/12/workaround-aspnet-response-filter-is.html
            
          Stream rf  =_ctx.Response.Filter;
           _ctx.Response.Filter = new JsonErrorResponseFilter(_ctx.Response.OutputStream);

        }
      }
            
    }
    
    /***************************************************************************
     * Start_Request */
    /**
     * Our handler for new requests.  All new requests start here.
     ***************************************************************************/       
    
    protected void Start_Request(Object sender, EventArgs e)
	{            
       
      HttpContext _ctx = HttpContext.Current;      
      
      // Set request timeout
      
      _ctx.Server.ScriptTimeout = Rules.WEB_REQ_TIMEOUT;
     
      RequestResponse rd = new RequestResponse();      
      
      rd.cancellationToken   = _ctx.Response.ClientDisconnectedToken;
      rd.credentialProvided  = Constants.CREDENTIAL_NONE;
      rd.credentialOK        = false;
      rd.accessGranted       = false;
      rd.loggedIn            = false;
      rd.privateResource     = false;

      // Basic information about request

      rd.requestDateTime = DateTime.Now;
      rd.userAgent       = _ctx.Request.UserAgent;
      rd.userIP          = _ctx.Request.UserHostAddress;
      rd.appMode         = appMode();
      rd.contentOnly     = contentOnly(); 
      rd.requestURL      = _ctx.Request.Url.AbsoluteUri;
      rd.language        = language();
      
      /* Localization */

      if (String.IsNullOrWhiteSpace(rd.language)) {
        rd.languageSpecified   = false;
        rd.languageDefaultUsed = true;
        rd.language            = Constants.LANG_ENGLISH;
      }
      else {
        rd.languageSpecified   = true;
        rd.languageDefaultUsed = false;          
        System.Threading.Thread.CurrentThread.CurrentUICulture = new System.Globalization.CultureInfo(rd.language);
      }

      // Message (msg) passed on query string, if any

      rd.clientMessage     = HttpApplication.clientMsg();
      rd.clientMessageText = HttpApplication.clientMsgTxt();
      rd.clientMessageCode = HttpApplication.clientMsgCde();

      /*-------------------------------
       * Determine if browser is
       * supported
       *------------------------------*/ 
                
      rd.browserSupported = supportedBrowser(rd.userAgent); 
      rd.isBot            = isBot(rd.userAgent);
      
      /*-------------------------------
       * Determine what this request
       * is for and how it is being
       * requested
       *------------------------------*/ 

      rd.requestSecure        = _ctx.Request.IsSecureConnection;

      string   _resReq        = _ctx.Request.PhysicalPath;
      string[] _respRepParts  = _resReq.Split(new String[] { "\\" },StringSplitOptions.RemoveEmptyEntries);
      string   _rawUrl        = _ctx.Request.RawUrl;
      string   _resRef        = (_ctx.Request.UrlReferrer != null) ? _ctx.Request.UrlReferrer.AbsoluteUri : "";
      string   _method        = _ctx.Request.HttpMethod.ToLower();
      bool     _secCon        = _ctx.Request.IsSecureConnection;
      bool     _webApp        = _resReq.ToLower().Contains(".aspx");
      bool     _webSvc        = _resReq.ToLower().Contains(".asmx");
      bool     _webHdlr       = _resReq.ToLower().Contains(".ashx");
      
      bool     _webApiRest    = false;
      
      if ((!_webApp) && (!_webSvc) && (!_webHdlr)) 
        _webApiRest = isCurrentRequestForRestApiRoute (RouteTable.Routes,ref _ctx);
      
      bool     _webObj        = ((!_webApp) && (!_webSvc) && (!_webHdlr) && (!_webApiRest));
      bool     _wsdl          = _rawUrl.ToLower().EndsWith("?wsdl");
      bool     _test          = _rawUrl.ToLower().Contains("?op=");
      bool     _soap          = (!String.IsNullOrEmpty(_ctx.Request.Params["HTTP_SOAPACTION"]) ||
                                 !String.IsNullOrEmpty(_ctx.Request.Headers["SOAPAction"]));

      string   _conttype      = _ctx.Request.ContentType; 
      string   _datatype      = _ctx.Request.Headers[""];
       
      string   _action        = _soap ? _ctx.Request.Headers["SOAPAction"] : _ctx.Request.Path;        

      _action  = _action.Replace(@"https://","");
      _action  = _action.Replace(@"http://","");
      _action  = _action.Replace(@"practi-cal.com", ""); // Namespace not url
      _action  = _action.Replace("\"", "");

      string[] _actionParts = _action.Split(new char[] { '/' },StringSplitOptions.RemoveEmptyEntries);
     
      string  _resource = "";

      int len = _respRepParts.Length;
      if (len > 0) { _resource = _respRepParts[len - 1]; }
      
      len     = _actionParts.Length;
      _action = "";

      if (len > 0)
      {
        _action = _actionParts[len - 1];  // action is the last part
      }

      if ((_webSvc) && (!_wsdl) && (_method == "get") && (_resource == _action)) { _action = "info"; }
      if ((_webSvc) && (_wsdl)  && (_method == "get"))                           { _action = "wsdl"; }
      if ((_webSvc) && (!_wsdl) && (_method == "get") && (_test))                { _action = "test"; }

      rd.appIsOffline = isAppOffline(_action);

      _action = _action.Replace(".aspx", "");
      _action = _action.Replace(".asmx", "");
      _action = _action.Replace(".ashx", "");
      
      rd.requestMethod   = _method;
      rd.requestResource = _resource;
      rd.requestAction   = _action;
      rd.webApp          = _webApp;
      rd.webSvc          = _webSvc;
      rd.webHdlr         = _webHdlr;
      rd.webApiRest      = _webApiRest;
      
      /*-------------------------------
       * Analyse results and based on
       * our business rules, see if
       * there are any early issues
       * with the request
       *------------------------------*/ 

      bool _issueDetected = false;

            
      /*-------------------------------
       * Exit if secure connection
       * required and request is not
       * secure 
       *------------------------------*/ 

      if ((Rules.SECURE_CONNECTION_REQ) && (!rd.requestSecure)) {_issueDetected = true;rd.unsecureConnection = true;}


      /*-------------------------------
       * Exit if app is in offline mode
       *------------------------------*/ 
      
      if (rd.appIsOffline == true)
      {        
        _issueDetected = true;
      }
      
      /*-------------------------------
       * Save the results for later
       * logging and if there is an
       * early issue, exit
       *------------------------------*/ 

      HttpContext.Current.Items.Add("rd",rd);      
      if (_issueDetected) Context.ApplicationInstance.CompleteRequest();
    }

    /***************************************************************************
     * Application_Error */
    /**
     * Catches unhandled exceptions at this level
     ***************************************************************************/  
     
    protected void Application_Error(Object sender, EventArgs e)
		{	
      
      /*-------------------------------
       * If rd is missing immediately
       * get out
       *------------------------------*/       
      
      if (!HttpContext.Current.Items.Contains("rd"))
      {
        Context.ApplicationInstance.CompleteRequest();
      }

      /*-------------------------------
       * Otherwise store information
       * about the error then get out
       *------------------------------*/       

      RequestResponse rd = (RequestResponse) HttpContext.Current.Items["rd"];
      rd.rrissue = true;
      rd.status = Return.RET_ERROR;
      rd.message = Context.Error.Message;
      rd.statmsg = rd.status + "|" + rd.message;
      HttpContext.Current.Items.Remove("rd");
      HttpContext.Current.Items.Add("rd",rd);
      Context.ApplicationInstance.CompleteRequest();
    }
	
    /***************************************************************************
     * End_Request */
    /**
     * All requests end here.
     ***************************************************************************/       
    
    protected void End_Request(Object sender, EventArgs e)
		{     
      
      string _conttype = Response.ContentType;
      
      /*-------------------------------
       * If rd is missing immediately
       * throw an error to the web 
       * server
       *-----------------------------*/ 
      
      if (!HttpContext.Current.Items.Contains("rd"))
      {
        Response.Clear();
        throw new Exception(Messages.MISSING_RD);
      }
     
      /*-------------------------------
       * Otherwiese there should be
       * data available so log it
       * and parse it
       *-----------------------------*/ 

      RequestResponse rd = (RequestResponse) HttpContext.Current.Items["rd"];
            
      if (MBA.Rules.LOG_REQUEST_RESPONSE)
      {
        try
        {
          
          FileLogger fl = new FileLogger(Constants.LOG_FILE_PATH,Constants.LOG_FILE_NAME);
          fl.logLevel = "Summary";
          fl.logSummary("{0}|{1}|{2}|{3}|{4}|{5}|{6}|{7}",
                          rd.userAgent,
                          rd.userIP,
                          rd.requestDateTime,
                          rd.requestMethod,
                          rd.requestResource,
                          rd.requestAction,
                          rd.status,
                          rd.message);                              
        }
        catch
        {
          Response.Clear();
          throw new Exception (Messages.FATAL_RD);
        }
      }         
      
      /*-------------------------------
       * If a fatal error was detected
       * immediately throw an exception
       * to the web server
       *-----------------------------*/ 

      if (rd.status == Return.RET_FATAL)
      {
        Response.Clear();
        throw new Exception(rd.statmsg);
      }
      
      /*-------------------------------
       * Unsecure connection
       *-----------------------------*/ 

      if (rd.unsecureConnection)
      {
          /*-------------------------------
           * User is coming in over 
           * unsecure connection.
           * Immediately redirect to
           * the public home page
           * over a secure connection.
           *
           * TODO: If the original request
           * is for a non UI resource
           * results may be confusing for
           * user.  Refactor this to
           * provide better responses.
           *-----------------------------*/ 
          
          string url = "";
          url = createLink(Constants.HOME_PUBLIC);
          Response.Redirect(url);
      }
      
      /*-------------------------------
       * If app is offline redirect
       *-----------------------------*/       
      
      if (rd.appIsOffline == true)
      {
        string url = "";
        url = createLink(Constants.OFFLINE_PUBLIC);
        Response.Redirect(url);
      }

      /*-------------------------------
       * If subscription to app is
       * required redirect
       *-----------------------------*/       

      if (rd.subscriptionRequired == true)
      {
        string url = "";
        url = Constants.APP_MARKETING_PUBLIC;
        Response.Redirect(url);
      }

      /*-------------------------------
       * If the request was for a web
       * handler
       *-----------------------------*/ 
      
      if (rd.webHdlr)
      {
      }

      /*-------------------------------
       * If the request was for a web
       * service
       *-----------------------------*/ 
      
      if (rd.webSvc)
      {
             
       /*-------------------------------
        * And there was an issue
        * return an error message
        *-----------------------------*/ 
      
        if (rd.rrissue)
        {
          if (_conttype == "application/json")
          {
            
          }
          else
          {
            Response.ContentType = "text/xml";
            Response.ContentEncoding = System.Text.Encoding.UTF8;
            Response.Write("<return>");
            Response.Write("<status>" + rd.status + "</status>");
            Response.Write("<message>" + rd.message + "</message>");
            Response.Write("</return>");
            Context.ClearError();
          }
        }
      }
      
      /*-------------------------------
       * If the request was for a web
       * app
       *-----------------------------*/ 
      
      if (rd.webApp)
      {
      
        if ((rd.earlyExit) && (rd.credentialOK))
        { 
                      
          string endpoint  = rd.requestResource;
          string url       = "";
          
          /*-------------------------------
           * User JUST logged in
           * Setup our token passing
           *-----------------------------*/ 
          
          NameValue tnv = new NameValue (Constants.PARM_TOKEN,@"");  
          
          if (rd.userJustLoggedIn == true)
          {
            Response.AddHeader(Constants.PARM_TOKEN,rd.wu.usr.token);            
          }
         
          if (rd.earlyExitReason == Constants.EARLY_EXIT_LOGIN)
          {                                                  
            tnv = new NameValue (Constants.PARM_TOKEN,rd.wu.usr.token);            
            
            /* Get and validate optional goto page that overrides standard starting page if provided and its valid.
             * If its not valid then we catch the validation exception to prevent it propagating further and redirect
             * user to our error screen */

            string gotoPage = String.Empty;
            try 
            { 
              gotoPage = Validate.optGotoPage(HttpApplication.getParameter(Constants.PARM_GOTO_PAGE));
            }
            catch
            {
               Response.Redirect(@"error.aspx?msg=" + Messages.INVALID_GOTO_PAGE);
            }

            /* No goto page passed, use starting page set in user data */

            if (String.IsNullOrWhiteSpace(gotoPage))
              endpoint = rd.wu.usr.startingPage;  

            /* Goto page passed, use it as the starting page */
            else
              endpoint = gotoPage;

            url = createLink(endpoint,tnv);
            Response.Redirect(url);
          }
         
          else if (rd.earlyExitReason == Constants.EARLY_EXIT_CHANGE_PASSWORD)
          {
            tnv = new NameValue (Constants.PARM_TOKEN,rd.wu.usr.token);                                                              
            endpoint = Constants.CHANGE_MY_PASSWORD;            
            url = createLink(endpoint,tnv);                        
            Response.Redirect(url);
          }
                    
          else if (rd.earlyExitReason == Constants.EARLY_EXIT_LOGOUT)
          {
            string msg = Return.RET_INFO + "|You are logged out";
            Response.AddHeader(Constants.PARM_MSG,msg);
            url = createLink(Constants.HOME_PUBLIC,new NameValue(Constants.PARM_MSG,msg));
            Response.Redirect(url);          
          }                               
       }
                                    
       /*-------------------------------
        * User is not logged in and
        * attempted to access a private
        * resource
        *-----------------------------*/ 
        
        if ((rd.privateResource) && (!rd.credentialOK))
        {
          string msg = rd.statmsg;
          Response.AddHeader(Constants.PARM_MSG,msg);
          string url = createLink(Constants.HOME_PUBLIC, new NameValue(Constants.PARM_MSG,msg));
          Response.Redirect(url);      
        }
        
        /*-------------------------------
         * User is on an unsupported
         * browser or some other issue
         * that requires us to
         * completely replace our
         * response with simple
         * HTML that any browser should
         * recognize. 
         *-----------------------------*/ 
        
        if (rd.rrissue) 
        {
          string msg = "";
          Response.Clear();

          if (rd.rrissue)
          {
            if (Context.Error.InnerException != null)
              msg = Context.Error.InnerException.Message;
            else
              msg = Context.Error.Message;
          }
          else
          {
            msg = rd.message;
          }

         
          // All other errors get our generic error page

          Server.Transfer(@"error.aspx?msg=" + msg);

        }

        /*-------------------------------
         * Anything else that is an
         * issue return error message
         * as part of the URL
         * This should get picked 
         * up by our client side
         * scripts and it will form
         * an error message 
         *-----------------------------*/ 
        
        if ((rd.status != Return.RET_SUCCESS))
         {
           string url = "";
           if (rd.loggedIn)
           { 
             url = createLink(Constants.HOME_PRIVATE, new NameValue(Constants.PARM_MSG,rd.statmsg),new NameValue(Constants.PARM_TOKEN,clientToken()));
           }
           else
           { 
             url = createLink(Constants.HOME_PUBLIC, new NameValue(Constants.PARM_MSG,rd.statmsg));
           }
          Response.Redirect(url);
         }
      }
    }
	}
}
