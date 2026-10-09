using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using HtmlAgilityPack;
using Geo;
using Geo.USPS;
using Geo.Google;
using Geo.CDE;
using Geo.USAddressParser;

namespace MBA
{
  
  public class GeoUtil
  {
    
    /***************************************************************************
     * US_STATES */
    /**
     * 
     * 
     ***************************************************************************/  
    
    public static Dictionary<string, string> US_STATES = Geo.USAddressParser.AddressParser.US_STATES;
    
    /***************************************************************************
     * validateAddress */
    /**
     * 
     * 
     ***************************************************************************/  
    
    public static ReturnUspsAddress validateAddress (   string street1
                                                      , string street2
                                                      , string city
                                                      , string state
                                                      , string zip5
                                                      , string zip4
                                                      , bool  useCache )
    {            
      
        //return validateShippingAddress(street1, street2, city, state, zip5, zip4, useCache);
        return standardizeAddress(street1, street2, city, state, zip5, zip4, useCache);
     }

    /***************************************************************************
     * standardizeAddress */
    /**
     * 
     * 
     ***************************************************************************/  

        
    public static ReturnUspsAddress standardizeAddress ( string street1
                                                       , string street2
                                                       , string city
                                                       , string state
                                                       , string zip5
                                                       , string zip4
                                                       , bool  useCache )
    {
      
        ReturnUspsAddress so = new ReturnUspsAddress();
        
       /*----------------------------
        * Create input address
        *----------------------------*/

        Geo.USPS.Address addressIn = new Geo.USPS.Address(street1
                                                        , street2
                                                        , city
                                                        , state
                                                        , zip5
                                                        , zip4);

        /*----------------------------
          * Call the new v3 API
          *----------------------------*/

        bool retState = false;
        DateTime requestTimeStamp;
        DateTime responseTimeStamp;
        string errorMessage;
        Geo.USPS.Address addressOut;

        retState = AddressStandardization.RequestAddressValidation(
                                                    Constants.USPS_ADDRESS_STANDARDIZATION_OAUTH_URL,
                                                    Constants.USPS_ADDRESS_STANDARDIZATION_CLIENT_ID,
                                                    Constants.USPS_ADDRESS_STANDARDIZATION_CLIENT_SECRET,
                                                    Constants.USPS_ADDRESS_STANDARDIZATION_API_URL,
                                                    addressIn,
                                                    out requestTimeStamp,
                                                    out responseTimeStamp,
                                                    out errorMessage,
                                                    out addressOut);

        /*----------------------------
          * Handle errors
          *----------------------------*/

        if (!retState)
        {
            so = new ReturnUspsAddress(new Warning(errorMessage));
        }

        /*----------------------------
         * Populate return object
         *----------------------------*/

        so.addressIn = addressIn;
        so.addressOut = addressOut;

        return so;       
    }

        /***************************************************************************
         * validateShippingAddress */
        /**
         * NOTE: THIS USPS SERVICE IS GOING DARK AS OF 01/25/2026
         * IT HAS BEEN REPLACED WITH THE ADDRESS STANDARDIZATION API
         ***************************************************************************/

        public static ReturnUspsAddress validateShippingAddress(  string street1
                                                                 , string street2
                                                                 , string city
                                                                 , string state
                                                                 , string zip5
                                                                 , string zip4
                                                                 , bool useCache)
        {

            ReturnUspsAddress so = new ReturnUspsAddress();


            Geo.USPS.Address addressIn = new Geo.USPS.Address(street1
                                                               , street2
                                                               , city
                                                               , state
                                                               , zip5
                                                               , zip4);

            bool retState = false;
            DateTime requestTimeStamp;
            DateTime responseTimeStamp;
            string errorMessage;
            WebHeaderCollection requestHeaders;
            string requestData;
            WebHeaderCollection responseHeaders;
            string responseData;
            Geo.USPS.Address addressOut;

            retState = Geo.USPS.AddressValidation.RequestAddressValidation(Constants.USPS_SHIPPING_API_KEY
                                                                           , Constants.USPS_SHIPPING_API_URL
                                                                           , addressIn
                                                                           , useCache
                                                                           , out requestTimeStamp
                                                                           , out responseTimeStamp
                                                                           , out errorMessage
                                                                           , out requestHeaders
                                                                           , out requestData
                                                                           , out responseHeaders
                                                                           , out responseData
                                                                           , out addressOut);

            if (!retState) so = new ReturnUspsAddress(new Warning(errorMessage));

            so.addressIn = addressIn;
            so.addressOut = addressOut;

            return so;
        }


        /***************************************************************************
         * computeDistanceAndTravelTime */
        /**
         * 
         * 
         ***************************************************************************/


        public static ReturnGoogleDistanceMatrix computeDistanceAndTravelTime (  string originIn
                                                                           , string destinationIn
                                                                           , bool   useCache )
    {
      return computeDistanceAndTravelTime(originIn, destinationIn, useCache, false);      
    }
    
    public static ReturnGoogleDistanceMatrix computeDistanceAndTravelTime (  string originIn
                                                                           , string destinationIn
                                                                           , bool   useCache
                                                                           , bool   sanitize)
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
      string                 mapsURL;
      
      retState = Geo.Google.DistanceMatrix.RequestDistanceAndTravelTime (  Constants.GOOG_DIST_MATRIX_API_KEY
                                                                         , Constants.GOOG_DIST_MATRIX_API_URL
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
                                                                         , out distanceInMiles
                                                                         , out mapsURL );
      
      if (!retState) so = new ReturnGoogleDistanceMatrix (new Warning(errorMessage));
      
      so.originIn          = originIn;
      so.destinationIn     = destinationIn;
      so.originOut         = originOut;
      so.destinationOut    = destinationOut;
      so.durationInSeconds = durationInSeconds;
      so.durationInMinutes = durationInMinutes;
      so.distanceInMiles   = distanceInMiles;
      so.distanceInMeters  = distanceInMeters;
      so.mapsURL           = mapsURL;
      
      if (sanitize == false)
      {
        so.requestData   = requestData;
        so.responseData  = responseData;
      }
      else
      {
        so.requestData   = "";
        so.responseData  = "";
      }
      return so;
            
    }
    
    /***************************************************************************
     * retrieveSchoolDirectoryEntryForSite */
    /**
     * 
     ***************************************************************************/  
    
    public static ReturnCdeSchoolDirectoryEntry retrieveCdeSchoolDirectoryEntry (  string cdsCode
                                                                                  , bool   useCache )
    {

      ReturnCdeSchoolDirectoryEntry so = new ReturnCdeSchoolDirectoryEntry();
      
      string                 errorMessage;
      DateTime               requestTimeStamp;
      DateTime               responseTimeStamp;
      bool                   retState = false;
      WebHeaderCollection    requestHeaders;
      string                 requestContent;
      WebHeaderCollection    responseHeaders;
      string                 responseContent;
      HtmlDocument           responseDoc;      
      SchoolDirectoryEntry   directoryEntry;
      

      retState = Geo.CDE.SchoolDirectoryEntries.RequestDirectoryEntry (  Constants.CDE_SCHOOL_DIR_URL
                                                                        , cdsCode
                                                                        , useCache
                                                                        , out requestTimeStamp
                                                                        , out responseTimeStamp
                                                                        , out errorMessage
                                                                        , out requestHeaders
                                                                        , out requestContent
                                                                        , out responseHeaders
                                                                        , out responseContent
                                                                        , out responseDoc
                                                                        , out directoryEntry );
      
      
      if (!retState) so = new ReturnCdeSchoolDirectoryEntry (new Warning(errorMessage));
      
      so.directoryEntry = directoryEntry;      
      
      
      return so;
      
     }
   
    /***************************************************************************
     * requestIndividualProviderDataFromCMS */
    /**
     * 
     ***************************************************************************/  
    public static ReturnValue requestIndividualProviderDataFromCMS (  string term                                                      
                                                                    , string selectMode                                                              
                                                                    , bool   useCache )
    {

      ReturnValue so = new ReturnValue();      
      string                 errorMessage;
      bool                   retState = false;
      WebHeaderCollection    requestHeaders;
      string                 requestContent;
      WebHeaderCollection    responseHeaders;
      string                 responseContent;
       
      retState = Geo.CMS.NPI.RequestIndividualProviderDataFromCMS (  Constants.CMS_API_URL
                                                                   , Constants.CMS_API_VERSION
                                                                   , term
                                                                   , selectMode
                                                                   , useCache                                                                   
                                                                   , out errorMessage
                                                                   , out requestHeaders
                                                                   , out requestContent
                                                                   , out responseHeaders
                                                                   , out responseContent );
      
      
      if (!retState)
      { 
        so = new ReturnValue (new Warning(errorMessage));
        so.value = @"{}";
      }
      else
      {         
        so.status = Return.RET_SUCCESS;       
        so.value = responseContent;        
      }
      return so;
      
     }
              

  }
}
