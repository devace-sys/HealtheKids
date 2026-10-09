using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web;
using System.Net.Security;
using System.Web.Script.Serialization;
using System.Collections.Specialized;


namespace Geo.Google
{

  /***************************************************************************
   * DistanceMatrix */
  /**
   * 
   * https://developers.google.com/maps/documentation/distance-matrix/start
   * 
   ***************************************************************************/  

	public class DistanceMatrix	
	{

	  public const string MAPS_URL_PTRN     = @"https://www.google.com/maps/dir/?api=1&travelmode=driving&origin={0}&destination={1}";
	  public const string VALUE_STATUS_OK   = @"OK";
		
		/***************************************************************************
     * StatusCodeToMessage */
    /**
     * Translate to friendly message.  
     * 
     ***************************************************************************/  
		
		private static string StatusCodeToMessage (string StatusCode)
		{
		  switch (StatusCode)
		  {
		    case VALUE_STATUS_OK   : return "OK";
		    case "NOT_FOUND"       : return "Origin or destination address not found";
		    case "ZERO_RESULTS"    : return "Could not determine route";
		    default                : return "Invalid request or Google API service error.  Please try again";
		  }
		}
		
		/***************************************************************************
     * ParseResponseData */
    /**
     * Parse data that comes back
     * 
     ***************************************************************************/  
		
		private static bool ParseResponseData (  string responseData
		                                       , out string                 errorMessage
		                                       , out DistanceMatrixResponse responseObj )
		{
			responseObj  = new DistanceMatrixResponse ();
			errorMessage = String.Empty;
			
			try
			{			
			  JavaScriptSerializer s = new JavaScriptSerializer ();
			  responseObj = (DistanceMatrixResponse) s.Deserialize <DistanceMatrixResponse> (responseData);
        
			  string sc = responseObj.status.Trim().ToUpper();
			  
			  if (sc != VALUE_STATUS_OK)
			  {
			    errorMessage = StatusCodeToMessage(sc);
			    return false;
			  }
			  
			  foreach (DistanceMatrixRows rows in responseObj.rows)
			  {
			    foreach (DistanceMatrixElement element in rows.elements)
			    {
			      sc = String.Empty;
			      sc = element.status.Trim().ToUpper();
			      if (sc != VALUE_STATUS_OK) 
			      {
			        errorMessage = StatusCodeToMessage(sc);
			        return false;
			      }
			    }
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
     * ParseResponseObject */
    /**
     * Further parse data
     * 
     ***************************************************************************/  

		private static bool ParseResponseObject (  DistanceMatrixResponse     responseObj
		                                         , out string                 errorMessage
		                                         , out string                 originOut
		                                         , out string                 destinationOut
		                                         , out string                 durationInSeconds
		                                         , out string                 durationInMinutes
		                                         , out string                 distanceInMeters
		                                         , out string                 distanceInMiles)
		{
			  errorMessage      = String.Empty;
			  originOut         = String.Empty;
			  destinationOut    = String.Empty;
			  durationInSeconds = String.Empty;
			  durationInMinutes = String.Empty;
			  distanceInMeters  = String.Empty;
			  distanceInMiles   = String.Empty;
			  
		  try
		  {
			  if (responseObj.status != VALUE_STATUS_OK)
			  {
			    errorMessage = StatusCodeToMessage(responseObj.status);
			    return false;
			  }
			  
			  foreach (string originAddress in responseObj.origin_addresses) {
			    originOut = originAddress;
			  }
			  
			  foreach (string destinationAddress in responseObj.destination_addresses) {
			    destinationOut = destinationAddress;
			  }
			  
			  foreach (DistanceMatrixRows rows in responseObj.rows) {			    
			    
			    foreach (DistanceMatrixElement element in rows.elements) {			      
			    
			      if (element.status != VALUE_STATUS_OK) {
			        errorMessage = StatusCodeToMessage(element.status);
			        return false;
			      }
			      
			      distanceInMeters = element.distance.value;			      
			      double distanceInMetersVal;
			      
			      if ( Double.TryParse( distanceInMeters, out distanceInMetersVal)) {
			        double distanceInMilesVal    = (distanceInMetersVal * 0.000621371d);
			        double distanceInMilesValRnd = Math.Round(distanceInMilesVal,1);
			        distanceInMiles              = distanceInMilesValRnd.ToString();
			      }
			      
			      durationInSeconds = element.duration.value;
			      double durationInSecondsVal;
			      
			      if ( Double.TryParse (durationInSeconds, out durationInSecondsVal)) {
			        double durationInMinutesVal = (durationInSecondsVal / 60);
			        double durationInMinutesRnd = Math.Round(durationInMinutesVal,0);
			        durationInMinutes           = durationInMinutesRnd.ToString();
			      }
			    
			    }
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
     * RequestDataFromGoogle */
    /**
     * Request data from USPS
     * 
     ***************************************************************************/  
		
		private static bool RequestDataFromGoogle (  string apiKey
		                                           , string apiUrl
		                                           , string originIn
		                                           , string destinationIn
		                                           , bool   useCache
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
        
			  nvc.Add (@"origins",        originIn);
			  nvc.Add (@"destinations",   destinationIn);
			  nvc.Add (@"language",       @"en");
			  nvc.Add (@"mode",           @"driving");
			  nvc.Add (@"units",          @"metric");
			  nvc.Add (@"key",            apiKey);
        
        /*----------------------------
         * Request data
         *----------------------------*/

        if (! Geo.Common.RequestData (  apiUrl
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
     * CheckForGoogleRequiredFields */
    /**
     * Verify that fields required by USPS API are provided
     * 
     ***************************************************************************/   

		private static bool CheckForGoogleRequiredFields (      String originIn
		                                                  ,     String destinationIn
		                                                  , out String originInClean
		                                                  , out String destinationInClean
		                                                  , out String errorMessage )
		{
	    errorMessage       = String.Empty;
	    originInClean      = originIn;
	    destinationInClean = destinationIn;

      /*----------------------------
       * Origin
       *----------------------------*/
	    
      if (! Common.ValididateAndCleanStringValueIn (originIn, out originInClean))
      {
        errorMessage = @"Origin is required";
	      return false;
	    }
	    
	    if (originInClean.Contains(@"|")) 
	    {
	      errorMessage = @"Origin cannot contain the pipe (|) symbol";
	      return false;
	    }

	    /*----------------------------
       * Destination
       *----------------------------*/

	    if (! Common.ValididateAndCleanStringValueIn (destinationIn, out destinationInClean))
      {
        errorMessage = @"Destination is required";
	      return false;
	    }
	    	    	    
	    if (destinationInClean.Contains(@"|")) 
	    {
	      errorMessage = @"Destination cannot contain the pipe (|) symbol";
	      return false;
	    }
	    
		  
		  return true;
		}
		
		/***************************************************************************
     * RequestDistanceAndTravelTime */
    /**
     * Request data from Google
     * 
     ***************************************************************************/  
		
		public static bool RequestDistanceAndTravelTime (      string                 apiKey
		                                                 ,     string                 apiUrl
		                                                 ,     string                 originIn
		                                                 ,     string                 destinationIn
		                                                 ,     bool                   useCache
		                                                 , out DateTime               requestTimeStamp
		                                                 , out DateTime               responseTimeStamp
		                                                 , out string                 errorMessage
		                                                 , out WebHeaderCollection    requestHeaders
		                                                 , out string                 requestContent
		                                                 , out WebHeaderCollection    responseHeaders
		                                                 , out string                 responseContent
		                                                 , out DistanceMatrixResponse responseContentObj
		                                                 , out string                 originOut
		                                                 , out string                 destinationOut
		                                                 , out string                 durationInSeconds
		                                                 , out string                 durationInMinutes
		                                                 , out string                 distanceInMeters
		                                                 , out string                 distanceInMiles
		                                                 , out string                 mapsURL
		                                                )
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
			responseContentObj = null;
			originOut          = String.Empty;
			destinationOut     = String.Empty;
			durationInSeconds  = String.Empty;
			durationInMinutes  = String.Empty;
      distanceInMeters   = String.Empty;
      distanceInMiles    = String.Empty;
      mapsURL            = String.Empty;
      
			try
			{ 
			
			  /*----------------------------
         * Validate standard parameters
         *----------------------------*/
			  
			  if (! Geo.Common.CheckForApiUrlAndKeys (  apiKey
			                                          , apiUrl
			                                          , out errorMessage )) 
			  return false;			  

			  /*----------------------------
         * Validate google parameters
         *----------------------------*/

			  if (! CheckForGoogleRequiredFields (  originIn
			                                      , destinationIn
			                                      , out originIn
			                                      , out destinationIn
			                                      , out errorMessage )) 
			  return false;
			  
			  /*----------------------------
         * Request data from Google
         *----------------------------*/

			  if (! RequestDataFromGoogle (  apiKey
			                               , apiUrl
			                               , originIn
			                               , destinationIn
			                               , useCache
			                               , out errorMessage
			                               , out requestHeaders
			                               , out requestContent
			                               , out responseHeaders
			                               , out responseContent )) 
			  return false;
				
				/*----------------------------
         * Parse response into obj
         *----------------------------*/

				if (! ParseResponseData (  responseContent
				                         , out errorMessage
				                         , out responseContentObj ))
				return false;				
        
        /*----------------------------
         * Parse response obj
         *----------------------------*/

        if (! ParseResponseObject (  responseContentObj
                                   , out errorMessage
                                   , out originOut
                                   , out destinationOut
                                   , out durationInSeconds
                                   , out durationInMinutes                                   
                                   , out distanceInMeters
                                   , out distanceInMiles )) 
                                
        return false;
                			
			  mapsURL = String.Format(MAPS_URL_PTRN,System.Web.HttpUtility.UrlEncode(originOut),System.Web.HttpUtility.UrlEncode(destinationOut));
			  			  
			
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

