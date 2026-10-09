using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web;
using System.Net.Security;
using System.Net.Cache;
using System.Web.Script.Serialization;
using System.Collections.Specialized;
using System.Globalization;
using System.Text.RegularExpressions;
using HtmlAgilityPack;

namespace Geo.OpenVidu
{
 
  
  public class Common
  {
  	  
    /***************************************************************************
     * CONTENT_TYPE_HEADER */
    /**
     * "Content-Type": "application/json" 
     * 
     ***************************************************************************/  
 
    public const string CONTENT_TYPE_HEADER = @"Content-Type: application/json";

    /***************************************************************************
     * CreateAuthorizationHeader */
    /**
     * "Authorization": "Basic " + btoa("OPENVIDUAPP:" + OPENVIDU_SERVER_SECRET)
     *
     * 
     ***************************************************************************/  
  
    private static string CreateAuthorizationHeader ( string username , string password)
    {
       string authorizationString  = username + @":" + password;            
       var    authorizationBytes   = System.Text.Encoding.UTF8.GetBytes(authorizationString);
       var    authorizationBase64  = System.Convert.ToBase64String(authorizationBytes);
       string authorizationHeader  = @"Authorization: Basic " + authorizationBase64; 
       return authorizationHeader;
    }

    /***************************************************************************
     * createRequestAddress */
    /**
     * 
     * 
     ***************************************************************************/  
		
    public static string CreateRequestAddress (string server, string method) 
    {
      return server + @"/api/" + method;
    }
    
     
    /***************************************************************************
     * RequestDataGet */
    /**
     * Requests method and returns response using GET verb
     * 
     ***************************************************************************/  
		
		public static bool RequestDataGet  (  string server
                                        , string username 
                                        , string password
                                        , string method
		                                    , out string response )
		{
		  
      response = @"";

      string address = @"";
      
			try
			{
        			  			 
        address = CreateRequestAddress(server,method);        
        string authorizationHeader = CreateAuthorizationHeader(username,password);
      
			  using (WebClient wc = new WebClient()) {			    			    
          wc.Headers.Add(authorizationHeader);
          wc.Headers.Add(CONTENT_TYPE_HEADER);
          wc.Encoding              = System.Text.Encoding.UTF8;			  
          wc.UseDefaultCredentials = false;                      			    			    
          wc.CachePolicy = new RequestCachePolicy( RequestCacheLevel.NoCacheNoStore);          			    
			    ServicePointManager.ServerCertificateValidationCallback = new RemoteCertificateValidationCallback (delegate { return true; });			    			    
          response = wc.DownloadString(address);  /* DownloadString uses GET verb */         
			  }
			  
		  }		
      
      catch (WebException e)
      {        
        if (e.Message.Contains("(404)")) 
        { 
          response = address;
          return true;  
        }
        response = e.Message;
        return false;
      }

      catch (Exception e)
		  {
		    response = e.Message;
		    return false;
		  }
		  
		  return true;
		}
    
    /***************************************************************************
     * RequestDataPost */
    /**
     * Requests data be appplied using method and returns response using POST verb
     * 
     ***************************************************************************/  
		
		public static bool RequestDataPost (  string server
                                        , string username 
                                        , string password
                                        , string method
		                                    , string data                                        
		                                    , out string response )
		{
		  		  
      response = @"";
      string address = @"";
			try
			{
        			  
        address                     =  CreateRequestAddress(server,method);
        string authorizationHeader  =  CreateAuthorizationHeader(username,password);
        
			  using (WebClient wc = new WebClient()) {			    			    
          wc.Headers.Add(authorizationHeader);
          wc.Headers.Add(CONTENT_TYPE_HEADER);
          wc.Encoding              = System.Text.Encoding.UTF8;			  
          wc.UseDefaultCredentials = false;                      			    			    
          wc.CachePolicy = new RequestCachePolicy( RequestCacheLevel.NoCacheNoStore);          			    
			    ServicePointManager.ServerCertificateValidationCallback = new RemoteCertificateValidationCallback (delegate { return true; });			    
			    response = wc.UploadString(address, data);  /* Upload string uses POST verb */          
			  }
			  
		  }		
      
      catch (WebException e)
      {        
        if (e.Message.Contains("(409)")) 
        { 
          response = data;
          return true;  
        }
        response = e.Message;
        return false;
      }

      catch (Exception e)
		  {
		    response = e.Message;
		    return false;
		  }
		  
		  return true;
		}
	 
    /***************************************************************************
     * RequestDataDelete */
    /**
     * Requests method and returns response using DELETE verb
     * 
     ***************************************************************************/  
		
		public static bool RequestDataDelete (  string server
                                          , string username 
                                          , string password
                                          , string method
		                                      , out string response )
		{
		  		  
			string address = @"";
      try
			{
        			  
        response = @"";
	 
        address                     = CreateRequestAddress(server,method);
        string authorizationHeader  =  CreateAuthorizationHeader(username,password);
      
			  using (WebClient wc = new WebClient()) {			    
			    
          wc.Headers.Add(authorizationHeader);
          wc.Headers.Add(CONTENT_TYPE_HEADER);
          wc.Encoding              = System.Text.Encoding.UTF8;			  
          wc.UseDefaultCredentials = false;                      			    			    
          wc.CachePolicy = new RequestCachePolicy( RequestCacheLevel.NoCacheNoStore);          			    
			    ServicePointManager.ServerCertificateValidationCallback = new RemoteCertificateValidationCallback (delegate { return true; });			    
			    response = wc.UploadString(address, @"DELETE", @"");  /* Upload string can specify a different method, in this case DELETE */
			  }			  
		  }		
      
      catch (WebException e)
      {        
        if (e.Message.Contains("(404)")) 
        { 
          response = address;
          return true;  
        }
        response = e.Message;
        return false;
      }

      catch (Exception e)
		  {
		    response = e.Message;
		    return false;
		  }
		  
		  return true;
		}
  }
}
