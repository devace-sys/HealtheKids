using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.Web;
using Microsoft.SqlServer.Server;
using Geo;
using Geo.Google;

namespace MBA.SQLServerAddOns
{
  
  public class ReturnGoogleDistanceMatrix
  {
        
    public string                 originIn;
	  public string                 destinationIn;
	  public string                 originOut;
	  public string                 destinationOut;
	  public string                 durationInSeconds;
	  public string                 durationInMinutes;
	  public string                 distanceInMiles;
    public string                 distanceInMeters; 
  }

  public class Google
  {
    
    /***************************************************************************
     * computeDistanceAndTravelTime */
    /**
     * 
     * 
     ***************************************************************************/  


    public static ReturnGoogleDistanceMatrix computeDistanceAndTravelTime (  string GOOG_DIST_MATRIX_API_KEY
                                                                           , string GOOG_DIST_MATRIX_API_URL 
                                                                           , string originIn
                                                                           , string destinationIn
                                                                           , bool   useCache)
    {
      
      ReturnGoogleDistanceMatrix so = new ReturnGoogleDistanceMatrix();
      
      string                 errorMessage;
      DateTime               requestTimeStamp;
      DateTime               responseTimeStamp;
      bool                   retState = false;
      WebHeaderCollection    requestHeaders;
      string                 requestData;
      WebHeaderCollection    responseHeaders;
      string                 responseData;
      DistanceMatrixResponse responseObj;
      string                 originOut;
      string                 destinationOut;
      string                 durationInSeconds;
      string                 durationInMinutes;
      string                 distanceInMeters;
      string                 distanceInMiles;
      
      retState = Geo.Google.DistanceMatrix.RequestDistanceAndTravelTime (  GOOG_DIST_MATRIX_API_KEY
                                                                         , GOOG_DIST_MATRIX_API_URL
                                                                         , originIn 
                                                                         , destinationIn
                                                                         , useCache        
                                                                         , out requestTimeStamp
                                                                         , out responseTimeStamp                                                                
                                                                         , out errorMessage                                                                         
                                                                         , out requestHeaders
                                                                         , out requestData
                                                                         , out responseHeaders
                                                                         , out responseData
                                                                         , out responseObj
                                                                         , out originOut
                                                                         , out destinationOut
                                                                         , out durationInSeconds
                                                                         , out durationInMinutes
                                                                         , out distanceInMeters
                                                                         , out distanceInMiles );
            
      so.originIn          = originIn;
      so.destinationIn     = destinationIn;
      so.originOut         = originOut;
      so.destinationOut    = destinationOut;
      so.durationInSeconds = durationInSeconds;
      so.durationInMinutes = durationInMinutes;
      so.distanceInMiles   = distanceInMiles;
      so.distanceInMeters  = distanceInMeters;
      
      return so;
            
    }
    
   
  }
}
