using System;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using System.Web;
using System.Net.Security;
using System.Web.Script.Serialization;
using System.Collections.Specialized;
using HtmlAgilityPack;

namespace Geo.CMS
{
  public class NPI
  { 

  /***************************************************************************
   * RequestIndividualProviderDataFromCMS */
  /**
   * Note: Designed around API version 2.1
   * https://npiregistry.cms.hhs.gov/api/
   * 2.1
   ***************************************************************************/  
    public static bool RequestIndividualProviderDataFromCMS (   string cmsUrl        
		                                                      , string cmsApiVersion
                                                              , string term                                                      
                                                              , string selectMode                                                                                                            
		                                                      , bool   useCache
		                                                      , out String              errorMessage
		                                                      , out WebHeaderCollection requestHeaders
		                                                      , out String              requestContent 
		                                                      , out WebHeaderCollection responseHeaders
		                                                      , out String              responseContent )
    {
      errorMessage     = String.Empty;
      requestHeaders   = null;
      requestContent   = String.Empty;
      responseHeaders  = null;
      responseContent  = String.Empty;
            
      string  npiNumber;
      string  lastName;
      string  firstName;

      try
      {
        if (String.IsNullOrWhiteSpace(term))
        {
          errorMessage = @"You must provide a name or NPI number";
          return false;
        } 
        
        /*----------------------------
         * Create request parameter 
         * name and value pairs
         *----------------------------*/
        
        var nvc = new NameValueCollection();
                
        nvc.Add(@"version", cmsApiVersion);
        nvc.Add(@"enumeration_type",@"NPI-1");
               
	    if (selectMode == "npi") { 
          npiNumber = term;
          nvc.Add (@"number", npiNumber);
        }
        else if (selectMode == "name")
        {
          nvc.Add(@"name_purpose", @"Provider");

          if ( term.IndexOf(',') == (int) -1 ) {
            lastName  = term;
            firstName = "";
          }
          else
          { 
              var name  = term.Split(',');
              lastName  = name[0];
              firstName = name[1];
          }
          nvc.Add(@"last_name", lastName);
          nvc.Add(@"first_name", firstName);
          
        }
        else
        {
          errorMessage = @"Search must either be by name or by NPI number";
          return false;
        }

        /*----------------------------
         * Request data
         *----------------------------*/

        if (! Geo.Common.RequestData (  cmsUrl
                                      , nvc
                                      , useCache
                                      , out errorMessage
                                      , out requestHeaders
                                      , out requestContent
                                      , out responseHeaders
                                      , out responseContent )) 
        return false;
      
      }
      catch (Exception e)
      {
        errorMessage = e.Message;
        return false;        
      }
      
      return true;
    }  

  }
}
