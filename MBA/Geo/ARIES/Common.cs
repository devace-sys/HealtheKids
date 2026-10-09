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
using Newtonsoft.Json;

namespace Geo.ARIES
{
  /***************************************************************************
   * AriesSystemInfo*/
  /**
   *
   ***************************************************************************/  

  public class AriesSystemInfo 
  {
    public string   AeriesVersion            { get; set; }
    public string   DatabaseYear             { get; set; }
    public string[] AvailableDatabaseYears   { get; set; }
    public string   LocalTimeZoneName        { get; set; }
    public DateTime CurrentDateTime          { get; set; }
    public bool     hasData                  { get; set; }
        
  }

  /***************************************************************************
   * AriesCode */
  /**
   * See
   * https://support.aeries.com/support/solutions/articles/14000113682-aeries-api-school-related-end-points#Code-Sets
   ***************************************************************************/  

  public class AriesCode
  {
        public string AeriesCode  { get; set; }
        public string Category    { get; set; }
        public string Code        { get; set; }
        public string Description { get; set; }
        public string Field       { get; set; }
        public string NumericValue { get; set; }
        public string SortOrder    { get; set; }
        public string Status       { get; set; }
        public string Table        { get; set; }
        
  }

  /***************************************************************************
   * Common */
  /**
   * Common methods for working with the ARIES API
   *
   * See : https://support.aeries.com/support/solutions/articles/14000077926-aeries-api-full-documentation
   * Also See : https://support.aeries.com/support/solutions/articles/14000070569-api-quick-reference-guide
   ***************************************************************************/  

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
     * AERIES-CERT : api token
     * See: https://support.aeries.com/support/solutions/articles/14000113681-aeries-api-building-a-request
     ***************************************************************************/  
  
    private static string CreateAuthorizationHeader ( string apiToken)
    {
       return @"AERIES-CERT" + @":" + apiToken;                   
    }

    /***************************************************************************
     * createRequestAddress */
    /**
     * Assumes v5 API
     * Method can be entity name, entityname/id/, etc
     ***************************************************************************/  
		
    public static string CreateRequestAddress (string server, string method) 
    {      
      return server + @"/api/v5/" + method;
    }
     
    /***************************************************************************
     * RequestDataGet */
    /**
     * Requests method and returns response using GET verb
     * See: https://support.aeries.com/support/solutions/articles/14000113681-aeries-api-building-a-request
     ***************************************************************************/  
     public static bool RequestDataGet (  string server
                                        , string apiToken
                                        , string method
		                                , out string response )
     {       
       return RequestDataGet(server,apiToken,method,null,null,out response);
     }
        
     public static bool RequestDataGet (  string server
                                        , string apiToken
                                        , string method
                                        , int? startingRecord
                                        , int? endingRecord
		                                , out string response )
     {
		  
      response          = @"";
      bool responseGood = false;
      string address    = @"";
      
	  try
	  {        			  			                 
        string qs = "";
        if ((startingRecord.HasValue) && (endingRecord.HasValue)) {
          qs = String.Format(@"?StartingRecord={0}&EndingRecord={1}",startingRecord.Value, endingRecord.Value);
        }
        address = CreateRequestAddress(server,method) + qs;
        string authorizationHeader = CreateAuthorizationHeader(apiToken);
      
		using (WebClient wc = new WebClient()) {  
          responseGood = false;
          wc.Headers.Add(authorizationHeader);
          wc.Headers.Add(CONTENT_TYPE_HEADER);
          wc.Encoding = System.Text.Encoding.UTF8;			  
          wc.UseDefaultCredentials = false;                      			    			    
          wc.CachePolicy = new RequestCachePolicy (RequestCacheLevel.NoCacheNoStore);
	      ServicePointManager.ServerCertificateValidationCallback = new RemoteCertificateValidationCallback (delegate { return true; });
          response = wc.DownloadString(address);  /* DownloadString uses GET verb */   
          
          /* If response is null or empty */
          if (String.IsNullOrWhiteSpace(response)) { 
            responseGood = false;
            response     = "Empty or no response";
          }

          /* If response is not empty */

          else { 

            response = response.Trim(); 
            
            /* If response does not appear to be valid JSON based on sentinal characters */
            
            if (!(( response.StartsWith("{") && response.EndsWith("}") ) || ( response.StartsWith("[") && response.EndsWith("]") ))) {
              responseGood = false;
              response     = "Invalid response data, expected JSON";
            } 
            
            /* Otherwise we can assume the response is valid JSON */
            
            else {
              responseGood = true;
            }          
          }
	    } /* Using */        
	  }		
      catch (Exception e)
      {
	    response     = e.Message;
	    responseGood = false;
	  }
	  return responseGood;
    }
     
     /***************************************************************************
      * GetSystemInfo */
     /**
      * Requests system info.  Does not require API token
      *     
      ***************************************************************************/      
    public static AriesSystemInfo GetSystemInfo (string server, out bool requestSuccessful)
    {
      requestSuccessful = false;
      var so            = new AriesSystemInfo();      
      so.hasData        = false;
      so.AeriesVersion  = @"";      
      string response   = @"";

      if (RequestDataGet(server,"","systeminfo",out response)) { 
         try { 
           so = (AriesSystemInfo) JsonConvert.DeserializeObject <AriesSystemInfo>(response);
           so.hasData        = true;                    
           requestSuccessful = true;
         }
         catch (Exception e) {
           so.hasData        = false;
           so.AeriesVersion  = e.Message;           
           requestSuccessful = false;
         }         
      }
      else {
        so.AeriesVersion  = response;
        so.hasData        = false;
        requestSuccessful = false;
      } 
	  return so;
	 }
        
    /***************************************************************************
      * GetCodeSetList */
     /**
      * Requests code set
      * /api/v5/codes/{Table}/{Field}
      ***************************************************************************/      
    public static List<AriesCode> GetCodeSetList (string server, string apiToken, string table, string field, out bool requestSuccessful, out bool hasData)
    {
      requestSuccessful = false;
      hasData           = false;

      var so = new List<AriesCode>();      
      
      string method       = String.Format(@"codes/{0}/{1}/",table,field);
      string responseJSON = "";

      if (RequestDataGet(server, apiToken, method, out responseJSON)) { 
         try { 
           so = (List<AriesCode>) JsonConvert.DeserializeObject <List<AriesCode>>(responseJSON);
           hasData        = true;                    
           requestSuccessful = true;
         }
         catch (Exception e) {
           hasData           = false;           
           requestSuccessful = false;
         }         
      }
      else {
        hasData           = false;
        requestSuccessful = false;
      } 
	  return so;
	 }    
  }
}
