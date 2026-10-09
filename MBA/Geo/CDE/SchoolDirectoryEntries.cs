using System;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using System.Web;
using System.Net.Security;
using System.Web.Script.Serialization;
using System.Collections.Specialized;
using HtmlAgilityPack;

namespace Geo.CDE
{
  public class SchoolDirectoryEntries
  { 

		
		public static String XPATH_SITE_NAME_OR_NOT_FOUND = @"/html/body/div[2]/div[1]/div[1]/h2";
				
		public static String XPATH_SITE_COUNTY_NAME       = @"/html/body/div[2]/div/div[1]/table/tr[1]/td";
		public static String XPATH_SITE_DISTRICT_NAME     = @"/html/body/div[2]/div/div[1]/table/tr[2]/td/a";
		public static String XPATH_SITE_SCHOOL_NAME       = @"/html/body/div[2]/div/div[1]/table/tr[3]/td";
    public static String XPATH_SITE_CDS_CODE          = @"/html/body/div[2]/div/div[1]/table/tr[4]/td/div";
    public static String XPATH_SITE_STREET_ADDRESS    = @"/html/body/div[2]/div/div[1]/table/tr[9]/td/div";
    public static String XPATH_SITE_GOOGLE_MAPS_URL   = @"/html/body/div[2]/div/div[1]/table/tr[9]/td/a";
    public static String XPATH_SITE_MAILING_ADDRESS   = @"/html/body/div[2]/div/div[1]/table/tr[10]/td/div";
    public static String XPATH_SITE_CDE_PROFILE       = @"/html/body/div[2]/div/div[1]/table/tr[23]/td/a";

    public static String XPATH_DIST_COUNTY_NAME       = @"/html/body/div[2]/div[1]/div[1]/table/tr[1]/td";
		public static String XPATH_DIST_DISTRICT_NAME     = @"/html/body/div[2]/div[1]/div[1]/table/tr[2]/td/text()[1]";
		public static String XPATH_DIST_CDS_CODE          = @"/html/body/div[2]/div[1]/div[1]/table/tr[3]/td/div";
		public static String XPATH_DIST_STREET_ADDRESS    = @"/html/body/div[2]/div[1]/div[1]/table/tr[8]/td/div";
		public static String XPATH_DIST_GOOGLE_MAPS_URL   = @"/html/body/div[2]/div[1]/div[1]/table/tr[8]/td/a";
		public static String XPATH_DIST_MAILING_ADDRESS   = @"/html/body/div[2]/div[1]/div[1]/table/tr[9]/td/div";
    public static String XPATH_DIST_CDE_PROFILE       = @"/html/body/div[2]/div[1]/div[1]/table/tr[16]/td/a";
		
    /***************************************************************************
     * RequestDataFromCde */
    /**
     * 
     ***************************************************************************/  

    private static bool RequestDataFromCde (  string cdeUrl
		                                        , string cdsCode
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
            
      try
      {
        /*----------------------------
         * Create request parameter 
         * name and value pairs
         *----------------------------*/
        
        NameValueCollection nvc = new NameValueCollection();
        
			  nvc.Add (@"cdscode", cdsCode);
        
        /*----------------------------
         * Request data
         *----------------------------*/

        if (! Geo.Common.RequestData (  cdeUrl
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
    
    /***************************************************************************
     * ParseResponseContent */
    /**
     * 
     ***************************************************************************/  
    
    private static bool ParseResponseContent (  String responseContent
                                              , out String       errorMessage
                                              , out HtmlDocument responseDoc )
    {
      errorMessage = String.Empty;
      responseDoc  = null;
      
      try
      {
        responseDoc = Common.ParseHtml(responseContent);
      }
      catch (Exception e)
      {
        errorMessage = e.Message;        
        return false;
      }
      
      return true;
    }
    
    /***************************************************************************
     * ParseResponseDocument */
    /**
     * 
     ***************************************************************************/  

    public static bool ParseResponseDocument  (  HtmlDocument responseDoc
                                               , bool         distSearch
                                               , string       requestContent
                                               , out String   errorMessage
                                               , out SchoolDirectoryEntry directoryEntry)
    {
      
      errorMessage   = String.Empty;
      directoryEntry = new SchoolDirectoryEntry();
      
      directoryEntry.CdeDirectoryUrl = requestContent;
      
      try
      {
        string siteOrNotFound  = Common.SelectNodeInnerText (responseDoc, XPATH_SITE_NAME_OR_NOT_FOUND)
                                       .Trim()
                                       .ToLower();

        if (siteOrNotFound.Contains(@"unknown cds")) {
          errorMessage = @"Site or district not found";
          return false;
        }
        
        if (distSearch == true)
        {
          directoryEntry.CountyName         = Common.SelectNodeInnerText     (responseDoc, XPATH_DIST_COUNTY_NAME);
          directoryEntry.CdsCode            = Common.SelectNodeInnerText     (responseDoc, XPATH_DIST_CDS_CODE);
          directoryEntry.DistrictName       = Common.SelectNodeInnerText     (responseDoc, XPATH_DIST_DISTRICT_NAME);
          directoryEntry.GoogleMapsUrl      = Common.SelectNodeAttributeText (responseDoc, XPATH_DIST_GOOGLE_MAPS_URL, "href");
          directoryEntry.StreetAddressLine  = Common.SelectNodeInnerText     (responseDoc, XPATH_DIST_STREET_ADDRESS);
          directoryEntry.MailingAddressLine = Common.SelectNodeInnerText     (responseDoc, XPATH_DIST_MAILING_ADDRESS);
          directoryEntry.CdeProfileUrl      = Common.SelectNodeAttributeText (responseDoc, XPATH_DIST_CDE_PROFILE, "href");
        }
        else
        {
          directoryEntry.CountyName         = Common.SelectNodeInnerText     (responseDoc, XPATH_SITE_COUNTY_NAME);
          directoryEntry.CdsCode            = Common.SelectNodeInnerText     (responseDoc, XPATH_SITE_CDS_CODE);
          directoryEntry.DistrictName       = Common.SelectNodeInnerText     (responseDoc, XPATH_SITE_DISTRICT_NAME);
          directoryEntry.SchoolName         = Common.SelectNodeInnerText     (responseDoc, XPATH_SITE_SCHOOL_NAME);
          directoryEntry.GoogleMapsUrl      = Common.SelectNodeAttributeText (responseDoc, XPATH_SITE_GOOGLE_MAPS_URL, "href");
          directoryEntry.StreetAddressLine  = Common.SelectNodeInnerText     (responseDoc, XPATH_SITE_STREET_ADDRESS);
          directoryEntry.MailingAddressLine = Common.SelectNodeInnerText     (responseDoc, XPATH_SITE_MAILING_ADDRESS);
          directoryEntry.CdeProfileUrl      = Common.SelectNodeAttributeText (responseDoc, XPATH_SITE_CDE_PROFILE, "href");
        }
        
        directoryEntry.CdsCode         = Common.CleanStringNumericCodeValueOut(directoryEntry.CdsCode);
        directoryEntry.CdsCodeCounty   = directoryEntry.CdsCode.Substring(0,2);
        directoryEntry.CdsCodeDistrict = directoryEntry.CdsCode.Substring(2,5);
        directoryEntry.CdsCodeSite     = directoryEntry.CdsCode.Substring(7,7);
        directoryEntry.CdsCodeFirst7   = directoryEntry.CdsCode.Substring(0,7);
        directoryEntry.CdsCodeLast7    = directoryEntry.CdsCodeSite;
        
        String street1;
        String street2;
        String city;
        String state;
        String zip5;
        String zip4;
        
        Geo.USAddressParser.AddressParser      ap  = new Geo.USAddressParser.AddressParser();
        Geo.USAddressParser.AddressParseResult apr = ap.ParseAddress(directoryEntry.StreetAddressLine);
        
        if (apr != null)
        {
          street1 = Common.ToTitleCase(apr.StreetLine);
          street2 = String.Format(@"{0} {1}",apr.SecondaryUnit, apr.SecondaryNumber);
          city    = Common.ToTitleCase(apr.City);
          state   = apr.State.ToUpper();
          Geo.Common.SplitZip (apr.Zip, out zip5, out zip4);        
          directoryEntry.StreetAddress = new Geo.USPS.Address(street1,street2,city,state,zip5,zip4);
        }
        
        apr = ap.ParseAddress(directoryEntry.MailingAddressLine);
        
        if (apr != null)
        {
          street1 = Common.ToTitleCase(apr.StreetLine);
          street2 = String.Format(@"{0} {1}",apr.SecondaryUnit, apr.SecondaryNumber);
          city    = Common.ToTitleCase(apr.City);
          state   = apr.State.ToUpper();
          Geo.Common.SplitZip (apr.Zip, out zip5, out zip4);        
          directoryEntry.MailingAddress = new Geo.USPS.Address(street1,street2,city,state,zip5,zip4);
        }
        
      }
      catch (Exception e)
      {
        errorMessage = e.Message;        
        return false;
      }
      
      return true;
    }
    
    
    /***************************************************************************
     * CheckAndCleanRequiredFields */
    /**
     * 
     ***************************************************************************/  
     
    public static bool CheckAndCleanRequiredFields (   string cdeUrlIn
		                                                 , string cdsCodeIn 
		                                                 , out string errorMessage
		                                                 , out string cdeUrlOut
		                                                 , out string cdsCodeOut
		                                                 , out bool   distSearch )
		{
		  errorMessage = String.Empty;
		  cdeUrlOut    = String.Empty;
		  cdsCodeOut   = String.Empty;
		  distSearch   = false;
		  
		  cdeUrlOut  = Geo.Common.CleanStringValueOut            (cdeUrlIn);
		  cdsCodeOut = Geo.Common.CleanStringNumericCodeValueOut (cdsCodeIn);
		  
		  if (String.IsNullOrEmpty(cdeUrlOut)) {
		    errorMessage = @"CDE Url is required";
		    return false;
		  }
		  
		  if (String.IsNullOrEmpty(cdsCodeOut)){
		    errorMessage = @"CDS code is required";
		    return false;
		  }
		  
		  if (cdsCodeOut.Length != 14) {
		    errorMessage = @"CDS code must be 14 characters";
		    return false;
		  }
		  
		  if (cdsCodeOut.EndsWith("0000000")) distSearch = true;
		  
		  return true;
		}

    /***************************************************************************
     * RequestDirectoryEntryForSite */
    /**
     * 
     ***************************************************************************/  
     
    public static bool RequestDirectoryEntry (   string cdeUrl
		                                           , string cdsCode
		                                           , bool   useCache		                                          
		                                           , out DateTime               requestTimeStamp
		                                           , out DateTime               responseTimeStamp
		                                           , out string                 errorMessage
		                                           , out WebHeaderCollection    requestHeaders
		                                           , out string                 requestContent
		                                           , out WebHeaderCollection    responseHeaders
		                                           , out string                 responseContent
		                                           , out HtmlDocument           responseDoc
		                                           , out SchoolDirectoryEntry   directoryEntry )
   {
   
   	  /*----------------------------
       * Init output parms
       *----------------------------*/

			requestTimeStamp   = DateTime.Now;
			responseTimeStamp  = requestTimeStamp;
			errorMessage       = String.Empty;
			requestHeaders     = null;
			requestContent     = String.Empty;
			responseHeaders    = null;
			responseContent    = String.Empty;
			responseDoc        = null;
      directoryEntry     = null;
            
			try
			{ 			   
			  
			  string cdeUrlClean  = String.Empty;
			  string cdsCodeClean = String.Empty;
			  bool   distSearch   = false;
			    
			  if (! CheckAndCleanRequiredFields (  cdeUrl
			                                     , cdsCode
			                                     , out errorMessage
			                                     , out cdeUrlClean
			                                     , out cdsCodeClean
			                                     , out distSearch ))
			  return false;
			  
			  
			  if (! RequestDataFromCde (  cdeUrlClean
			                            , cdsCodeClean
			                            , useCache
			                            , out errorMessage
			                            , out requestHeaders
			                            , out requestContent
			                            , out responseHeaders
			                            , out responseContent))
			   return false;
			 
			 
			   if ( ! ParseResponseContent (  responseContent
			                                , out errorMessage
			                                , out responseDoc ))
			   return false;
			   
			   
			   if (! ParseResponseDocument (   responseDoc
			                                 , distSearch
			                                 , requestContent
			                                 , out errorMessage
			                                 , out directoryEntry ))
			   return false;
			   
			                   			
			}
			
			catch (Exception e) 
			{
				errorMessage = e.Message;
				return false;
			}
			finally
			{
			  responseTimeStamp  = DateTime.Now;
			}
			
			return true;
  
   }
    

  }
}
