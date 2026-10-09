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

namespace Geo
{
  public class Common
  {

    /***************************************************************************
     * SPACE_TRIMMER */
    /**
     * 
     ***************************************************************************/  

		public static readonly Regex SPACE_TRIMMER = new Regex(@"\s\s+",RegexOptions.Compiled);
		
		
	  /***************************************************************************
     * CleanStringValueOut */
    /**
     * 
     ***************************************************************************/ 
		
		public static string CleanStringValueOut (string valueIn)
		{
		  String valueOut = String.Empty;
		  if (String.IsNullOrEmpty(valueIn)) return String.Empty;
		  valueOut = valueIn.Trim();
		  if (String.IsNullOrEmpty(valueOut)) return String.Empty;
		  valueOut = SPACE_TRIMMER.Replace(valueOut,@" ");
		  return valueOut;		
		}
	  
	  /***************************************************************************
     * CleanStringNumericCodeValueOut */
    /**
     * Strips non numeric chars from values like 01-234-567 or 01 234 567
     * and returns 01234567
     ***************************************************************************/ 

		public static string CleanStringNumericCodeValueOut (string valueIn)
		{
		  String tempValue = String.Empty;
		  tempValue = CleanStringValueOut(valueIn);
		  tempValue = tempValue.Replace(@"-","");
		  tempValue = tempValue.Replace(@" ","");
		  return tempValue;
		}
	  
	  /***************************************************************************
     * SplitZip */
    /**
     * Splits zip code
     ***************************************************************************/ 
    
    public static bool SplitZip (string zip, out string zip5, out string zip4)
		{
			zip5 = String.Empty;
			zip4 = String.Empty;
			String tempValue = CleanStringValueOut(zip);
			if (String.IsNullOrEmpty(tempValue)) return false;

			String[] parts  = tempValue.Split(' ','-');

			if (parts.Length == 0) return false;
			if (parts.Length >= 1) zip5 = parts[0];
			if (parts.Length == 2) zip4 = parts[1];
			if (parts.Length >= 3) return false;

			if ((parts.Length == 1) && (tempValue.Length == 9))
			{
				zip5 = tempValue.Substring(0,5);
				zip4 = tempValue.Substring(5,4);
			}

			return true;
		}
		
		/***************************************************************************
     * ValidateAndCleanStringValueIn */
    /**
     * 
     ***************************************************************************/  

		public static bool ValididateAndCleanStringValueIn (string valueIn, out string valueOut)
		{
		  valueOut = String.Empty;
		  if (String.IsNullOrEmpty(valueIn)) return false;
		  valueOut = valueIn.Trim();
		  if (String.IsNullOrEmpty(valueOut)) return false;
		  valueOut = SPACE_TRIMMER.Replace(valueOut,@" ");		  
		  return true;
		}
		
		/***************************************************************************
     * CheckForApiUrlAndKeys*/
    /**
     * Verify key and url are provided
     * 
     ***************************************************************************/  

		public static bool CheckForApiUrlAndKeys (  string apiKey
		                                          , string apiUrl
		                                          , out string errorMessage )
		{
		  
		  errorMessage = String.Empty;
		  
		  if (String.IsNullOrEmpty(apiKey))
		  {
	      errorMessage = @"API key required";
	      return false;
	  	}
	  	
	  	if (String.IsNullOrEmpty(apiUrl))
		  {
	      errorMessage = @"API Url required";
	      return false;
	  	}
	  	
	  	return true;
		
		}
		
		/***************************************************************************
     * ToQueryString */
    /**
     * Creates URL friendly query string
     * 
     ***************************************************************************/  

    public static string ToQueryString (NameValueCollection nvc)
		{
			if (nvc == null) return "";
			
			var array = (from key   in nvc.AllKeys
			             from value in nvc.GetValues(key)
			             select string.Format("{0}={1}", HttpUtility.UrlEncode(key), HttpUtility.UrlEncode(value)))
				.ToArray();
						   
			return "?" + string.Join("&", array);
		}
			
		/***************************************************************************
     * ToTitleCase */
    /**
     * Converts textIn to Title Case
     * 
     ***************************************************************************/  
		
		public static String ToTitleCase (String textIn)
		{
		  if (String.IsNullOrEmpty(textIn)) return textIn;
		  TextInfo ti      = new CultureInfo("en-US",false).TextInfo;
		  String   textOut = ti.ToTitleCase(textIn.ToLower()).Trim();		  
		  return ti.ToTitleCase(textOut);
		}
			  
		/***************************************************************************
     * RequestData */
    /**
     * Requests data and returns response
     * 
     ***************************************************************************/  
		
		public static bool RequestData (      string              requestUrl
		                                ,     NameValueCollection nvc
		                                ,     bool                useCache
		                                , out string              errorMessage
		                                , out WebHeaderCollection requestHeaders
		                                , out string              requestContent
		                                , out WebHeaderCollection responseHeaders
		                                , out string              responseContent )
		{
		  errorMessage    = String.Empty;
		  requestHeaders  = null;
		  requestContent  = String.Empty;
		  responseHeaders = null;
		  responseContent = String.Empty;
		  		  
			try
			{
        			  
			  /*----------------------------
         * Build request URL
         *----------------------------*/

			  string url = requestUrl + ToQueryString(nvc);
			  
			  /*----------------------------
         * Exit if request URL exceeds
         * allowed length
         *----------------------------*/

			  if (url.Length > 8192) {
			    errorMessage = @"Request URL exceeds allowed length";
			    return false;
			  } 
			  
			  using (WebClient wc = new WebClient()) {			    
			    
			    /*----------------------------
           * Set text encoding
           * Dont use credentials 
           *----------------------------*/
          			    
			    wc.Encoding              = System.Text.Encoding.UTF8;			  
          wc.UseDefaultCredentials = false;

          /*----------------------------
           * Configure caching
           *----------------------------*/
          
          if (useCache) 
            wc.CachePolicy = new RequestCachePolicy( RequestCacheLevel.CacheIfAvailable);
          else
            wc.CachePolicy = new RequestCachePolicy( RequestCacheLevel.NoCacheNoStore);
          
			    /*----------------------------
           * Handler to manage https
           *----------------------------*/

			    ServicePointManager.ServerCertificateValidationCallback = new RemoteCertificateValidationCallback (delegate { return true; });
			    
			    /*----------------------------
           * Pass back request data
           * Send request
           * Pass back response data
           *----------------------------*/

			    requestHeaders  = wc.Headers;
			    requestContent  = url;
			    responseContent = wc.DownloadString (url);
			    responseHeaders = wc.ResponseHeaders;
			    
			  }
			  
		  }
		  catch (WebException e)
          {
		    errorMessage = "There was a problem accessing this third party service.  It is possible their servers are having issues.  Please try your request again later.";
				//e.Message;
			return false;
          }
	      catch (Exception e)
		  {
		    errorMessage = e.Message;
		    return false;
		  }
		  
		  return true;
		}
	  
	  /***************************************************************************
     * ParseHtml */
    /**
     * 
     ***************************************************************************/  
	  
	  public static HtmlDocument ParseHtml (string htmlIn)
		{
			HtmlDocument doc = new HtmlAgilityPack.HtmlDocument ();
			doc.LoadHtml(htmlIn);
			return doc;
		}
			
		/***************************************************************************
     * SelectNode */
    /**
     * 
     ***************************************************************************/  

		public static HtmlNode SelectNode (HtmlDocument doc, string path)
		{		  
		  return doc.DocumentNode.SelectSingleNode(path); 
		}		

	  /***************************************************************************
     * SelectNodeInnerText */
    /**
     * 
     ***************************************************************************/  

		public static string SelectNodeInnerText (HtmlDocument doc, string path)
		{
		  HtmlNode node = SelectNode(doc, path);
		  if (node == null) return String.Empty;
		  return CleanStringValueOut(node.InnerText);
		}
		
		/***************************************************************************
     * SelectNodeAttributeText */
    /**
     * 
     ***************************************************************************/  

		public static string SelectNodeAttributeText (HtmlDocument doc, string path, string attrName)
		{
		  HtmlNode node = SelectNode(doc, path);
		  if (node == null) return String.Empty;
		  if (!node.Attributes.Contains(attrName)) return String.Empty;		  
		  return CleanStringValueOut(node.Attributes[attrName].Value);		  
		}
				  
  }
}
