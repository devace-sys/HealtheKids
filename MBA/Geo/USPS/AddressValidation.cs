using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.Web.Configuration;
using System.Collections.Specialized;
using System.Xml.Linq;
using System.IO;

namespace Geo.USPS
{
	/***************************************************************************
   * AddressValidation */
  /**
   * https://www.usps.com/business/web-tools-apis/address-information-api.htm
   * 
   ***************************************************************************/   

	public class AddressValidation
	{
    
	  /***************************************************************************
     * CheckForUSPSRequiredFields */
    /**
     * Verify that fields required by USPS API are provided
     * 
     ***************************************************************************/   

		private static bool CheckForUSPSRequiredFields ( USPS.Address addressIn, out String errorMessage )
		{
	    errorMessage = String.Empty;
	    
	    if (String.IsNullOrEmpty(addressIn.Street1))
	    {
	      errorMessage = USPS.Common.MSG_STREET_ADDRESS_REQUIRED;
	      return false;
	    }
	    
	    if ((String.IsNullOrEmpty(addressIn.City)) && (String.IsNullOrEmpty(addressIn.State)) && (String.IsNullOrEmpty(addressIn.Zip5)))
	    {
	      errorMessage = USPS.Common.MSG_CITY_STATE_ZIP_REQUIRED;
	      return false;
	    }

	    if (!(String.IsNullOrEmpty(addressIn.City)) && (String.IsNullOrEmpty(addressIn.State)) && (String.IsNullOrEmpty(addressIn.Zip5)))
	    {
	      errorMessage = USPS.Common.MSG_CITY_STATE_ZIP_REQUIRED;
	      return false;
	    }
	    
	    if ((String.IsNullOrEmpty(addressIn.City)) && (!String.IsNullOrEmpty(addressIn.State)) && (String.IsNullOrEmpty(addressIn.Zip5)))
	    {
	      errorMessage = USPS.Common.MSG_CITY_STATE_ZIP_REQUIRED;
	      return false;
	    }
	    	    
		  return true;
		}
		
		/***************************************************************************
     * CreateRequestValue */
    /**
     * Create XML string that contains the details of the request
     * 
     ***************************************************************************/  
		
		private static bool CreateRequestString (   String apiKey
		                                          , USPS.Address addressIn 
		                                          , out String errorMessage
		                                          , out String requestDocString )	
		{
			errorMessage     = String.Empty;
			requestDocString = String.Empty;

			try 
			{

			  /*----------------------------
         * Request document
         *----------------------------*/

			  XElement xReqDoc   = new XElement(USPS.Common.ELEMENT_ADDRESS_VALIDATE_REQUEST);
			  xReqDoc.SetAttributeValue (USPS.Common.PARM_USERID, apiKey);
			  			  
			  /*----------------------------
         * Address element
         *----------------------------*/

			  XElement xAddress  = new XElement(USPS.Common.ELEMENT_ADDRESS);
			  xAddress.SetAttributeValue (USPS.Common.PARM_ID, @"0");                            /* We are only requesting 1,  so set to 0*/
			  xAddress.Add  (new XElement(USPS.Common.ELEMENT_FIRM_NAME, String.Empty));         /* Required by USPS spec */
			  xAddress.Add  (new XElement(USPS.Common.ELEMENT_STREET_1,  addressIn.Street2));    /* Note: Swapped */     
			  xAddress.Add  (new XElement(USPS.Common.ELEMENT_STREET_2,  addressIn.Street1));     
			  xAddress.Add  (new XElement(USPS.Common.ELEMENT_CITY,      addressIn.City));     
			  xAddress.Add  (new XElement(USPS.Common.ELEMENT_STATE,     addressIn.State));    
			  xAddress.Add  (new XElement(USPS.Common.ELEMENT_ZIP_5,     addressIn.Zip5));     
			  xAddress.Add  (new XElement(USPS.Common.ELEMENT_ZIP_4,     addressIn.Zip4));
			  xReqDoc.Add (xAddress);

			  requestDocString = xReqDoc.ToString ();
			}

			catch (Exception e)
			{
			  errorMessage = e.Message;
			  return false;
			}

			return true;

		}
    
    /***************************************************************************
     * RequestDataFromUSPS */
    /**
     * Request data from USPS
     * 
     ***************************************************************************/  
		
		private static bool RequestDataFromUSPS (   String apiUrl
		                                          , String requestString 
		                                          , bool useCache
		                                          , out String              errorMessage
		                                          , out WebHeaderCollection requestHeaders
		                                          , out String              requestData 
		                                          , out WebHeaderCollection responseHeaders
		                                          , out String              responseData )
		{

		  errorMessage    = String.Empty;
		  requestHeaders  = null;
      requestData     = String.Empty;
		  responseHeaders = null;
		  responseData    = String.Empty;
		  	  
		  try
		  {  
		  
		    /*----------------------------
         * Create request parameter 
         * name and value pairs
         *----------------------------*/
         
			  NameValueCollection nvc = new NameValueCollection();
			  
			  nvc.Add (USPS.Common.PARM_API, USPS.Common.VALUE_METHOD_VERIFY);
			  nvc.Add (USPS.Common.PARM_XML, requestString); 
			  
			  /*----------------------------
         * Request data
         *----------------------------*/

			  if (! Geo.Common.RequestData (   apiUrl
			                                 , nvc
			                                 , useCache
			                                 , out errorMessage
			                                 , out requestHeaders
			                                 , out requestData
			                                 , out responseHeaders
			                                 , out responseData )) 
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
     * ParseResponseData */
    /**
     * Parse data that comes back
     * 
     ***************************************************************************/  
		
		private static bool ParseResponseData (  String responseData 
		                                       , out String errorMessage
		                                       , out USPS.Address addressOut )
		{

			errorMessage   = String.Empty;
			addressOut     = new USPS.Address ();

			try
			{
			
			  /*----------------------------
         * Response document
         *----------------------------*/

			  XElement xRspDoc = XElement.Parse (responseData, LoadOptions.None);
			  
			  /*----------------------------
         * Search for errors
         *----------------------------*/

			  IEnumerable<XElement> uspsErrors = xRspDoc.Descendants(USPS.Common.ELEMENT_ERROR);
        			  
			  /*----------------------------
         * If no errors
         *----------------------------*/

			  if (uspsErrors.Count() <= 0)
			  {
			    /*----------------------------
           * Address element
           *----------------------------*/

			    XElement xAddRsp = xRspDoc.Element(USPS.Common.ELEMENT_ADDRESS);
				  if (xAddRsp != null)
			  	{
					  if (xAddRsp.Element(USPS.Common.ELEMENT_STREET_1) != null) addressOut.Street2 = Geo.Common.ToTitleCase(xAddRsp.Element(USPS.Common.ELEMENT_STREET_1).Value); /* Note swapped */         
					  if (xAddRsp.Element(USPS.Common.ELEMENT_STREET_2) != null) addressOut.Street1 = Geo.Common.ToTitleCase(xAddRsp.Element(USPS.Common.ELEMENT_STREET_2).Value);
					  if (xAddRsp.Element(USPS.Common.ELEMENT_CITY)     != null) addressOut.City    = Geo.Common.ToTitleCase(xAddRsp.Element(USPS.Common.ELEMENT_CITY).Value);
					  if (xAddRsp.Element(USPS.Common.ELEMENT_STATE)    != null) addressOut.State   = xAddRsp.Element(USPS.Common.ELEMENT_STATE).Value.ToUpper().Trim();
					  if (xAddRsp.Element(USPS.Common.ELEMENT_ZIP_5)    != null) addressOut.Zip5    = xAddRsp.Element(USPS.Common.ELEMENT_ZIP_5).Value.ToUpper().Trim();
					  if (xAddRsp.Element(USPS.Common.ELEMENT_ZIP_4)    != null) addressOut.Zip4    = xAddRsp.Element(USPS.Common.ELEMENT_ZIP_4).Value.ToUpper().Trim();     
				  }
				  else
				  {
				    errorMessage = "No address data available";
				    return false;
				  }
			  }
			  else
			  {
				  errorMessage = @"No address data available";
				  foreach (XElement error in uspsErrors)
				  {				  
				    if (error.Element(USPS.Common.ELEMENT_DESCRIPTION) != null) errorMessage = error.Element(USPS.Common.ELEMENT_DESCRIPTION).Value;				  
				  }							
				  return false;
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
     * RequestAddressValidation */
    /**
     * Request address validation from USPS
     * 
     ***************************************************************************/  
	
		public static bool RequestAddressValidation (  string   apiKey
		                                             , string   apiUrl
		                                             , Address  addressIn
		                                             , bool     useCache
		                                             , out DateTime            requestTimeStamp
		                                             , out DateTime            responseTimeStamp
		                                             , out String              errorMessage 
		                                             , out WebHeaderCollection requestHeaders
		                                             , out string              requestContent
		                                             , out WebHeaderCollection responseHeaders
		                                             , out String              responseContent
		                                             , out Address             addressOut )
		{

		  requestTimeStamp   = DateTime.Now;
			responseTimeStamp  = requestTimeStamp;
		  errorMessage       = String.Empty;
		  requestHeaders     = null;
		  requestContent     = null;
		  responseHeaders    = null;
		  responseContent    = String.Empty;
		  addressOut         = new Address();

		  try
		  {
		    String requestString;
			  
			  /*----------------------------
         * Check over required fields
         *----------------------------*/

			  if ( ! Geo.Common.CheckForApiUrlAndKeys (  apiKey
			                                           , apiUrl
			                                           , out errorMessage )) 
			  return false;
			  
			  /*----------------------------
         * Check over required fields
         *----------------------------*/

			  if ( ! CheckForUSPSRequiredFields ( addressIn
			                                     , out errorMessage ))                      
			  return false;
			  
			  /*----------------------------
         * Build request
         *----------------------------*/

			  if ( ! CreateRequestString ( apiKey
			                              , addressIn 
			                              , out errorMessage
			                              , out requestString ))
        return false;
			  
			  /*----------------------------
         * Request data from USPS
         *----------------------------*/
			  
			  if ( ! RequestDataFromUSPS ( apiUrl
			                             , requestString  
			                             , useCache
			                             , out errorMessage
			                             , out requestHeaders
			                             , out requestContent
			                             , out responseHeaders
			                             , out responseContent )) 
			  return false;			
			  
			  
			   /*----------------------------
          * Parse response XML document
          *----------------------------*/
			  
			  if ( ! ParseResponseData ( responseContent 
			                            , out errorMessage
			                            , out addressOut ))
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


