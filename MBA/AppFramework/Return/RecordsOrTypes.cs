using System;
using System.Collections.Generic;
using System.Text;

/***************************************************************************
 * RecordsOrTypes.cs */
/**
 * Contains all of our custom complex records/types. 
 ***************************************************************************/   

namespace MBA
{ 
  
  /***************************************************************************
   * AppStartEnd */
  /**
   * Our console app start/end object.  
   ***************************************************************************/   
  
  public class AppStartEnd
  {
    public DateTime startDateTime;
    public DateTime endDateTime;
    
    public string[] args;
    public int      status;
    public string   message;
  }
  
  /***************************************************************************
   * RequestResponse */
  /**
   * Our web resource request/response object.  This is available through the
   * entire request lifecyle and can be accessed in Context.Items 
   ***************************************************************************/   
    
  public class RequestResponse
  {    
    /*---------------------------------
	   * Request
	   *--------------------------------*/
    
    public DateTime requestDateTime; 	    // Date/time of request
    public string   userAgent;            // Users browser agent
    public string   userIP;				        // Users IP address
    public bool     browserSupported;     // Supported by our site?
    public bool     isBot;                // Is a bot?
    public bool     requestSecure;        // Request is over HTTPS?
    public string   requestURL;           // URL of request
    public string   requestMethod;        // get, post, head
    public string   requestResource;      // What page .asmx/.aspx is being requested
    public string   requestAction;        // What is the action against that page
    public bool     webApp;               // Web application
    public bool     webSvc;               // Web service
    public bool     webHdlr;              // Web handler
    public bool     webApiRest;           // Web API (Restful)
    public bool     privateResource;      // Private resource requested
    public string   appMode;              // Application mode
    public string   clientMessage;        // Message (msg) passed on query string
    public string   clientMessageText;
    public int      clientMessageCode;
    public string   contentOnly;    
    public string   language;
    public bool     languageSpecified;
    public bool     languageDefaultUsed;
    public System.Threading.CancellationToken cancellationToken;    
    public ReturnWebUser   wu;            // User data
    
    /*---------------------------------
	   * Response
	   *--------------------------------*/

    public int      credentialProvided;
    public bool     credentialOK;
    public bool     accessGranted;
    public bool     loggedIn;
    public bool     unsecureConnection;
    public bool     rrissue;
    public int      status;
    public string   message;
    public string   statmsg;
    public bool     appIsOffline             = false;
    public bool     userJustLoggedIn         = false;
    public bool     endPointIsChangePassword = false;
    public bool     endPointIsUnreadManPages = false;
    public bool     doNotShowUserToDoNotices = false; 
    public bool     earlyExit                = false;
    public int      earlyExitReason          = 0;
    public bool     subscriptionRequired     = false;
  }

  /***************************************************************************
   * Contact */
  /**
   * Application contact us data or general contact data
  ***************************************************************************/  
  
  public class Contact
  {
        
    public static string contactStringHTML (Contact c)
    {
      if (c == null) return "";
     
      string cs = @"<p>" + 
      @"<div class=""contact_org"">"   + c.name  + @"</div>" +
      @"<div class=""contact_email"">" + 
      @"<a href=""mailto:"             + c.email + 
      @""" title=""Email us!"">"       + c.email + @"</a></div>" + 
      @"<div class=""contact_mail"">"  + c.mail  + @"</div>" +
      @"</p>";
      
      return cs;
    }
    
    public static string contactStringHTMLEmail (Contact c)
    {
      if (c == null) return "";     
      string cs = @"<a href=""mailto:" + c.email + @""">" + c.email + @"</a>"; 
      return cs;
    }
    
    public string name;
    public string phone;
    public string fax;
    public string email;
    public string mail;
  }
}
