using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.Services.Protocols;
using System.Web.Script.Serialization;
using System.ComponentModel;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * TransportMgmtRouteSheetProcessingSvc */
  /*
   * Web services end points
   *
   * Unless indicated, each of these methods require that the caller is 
   * logged in.
   * 
   * Each end point method provides a wrapper for a coresponding framework
   * method that is not accessible from the outside.
   * 
   * These wrappers handle access control and parameter replacement.
   * 
   * The method is restricted to calls for given user groups
   * 
   * Parameter replacement is used to enforce additional access control within
   * the user group but this is limited.
   *
   * The final line of defense for access control are the database udfs or 
   * sprocs that return or save data
   ***************************************************************************/

  [WebService(Namespace = "http://spedcare.com/")]
  [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
  [ScriptService]
  
  public class TransportMgmtRouteSheetProcessingSvc : MBA.WebSvc
  {
               
    /***************************************************************************
     * loadProcessingData */
    /**
     * 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnTransportationMgmtProcessingData loadProcessingData (   string clientid )
    {               
      return (ReturnTransportationMgmtProcessingData) 
      callMethod(typeof(ReturnTransportationMgmtProcessingData),
      delegate()
      {
        return Spedmon.TransportationMgmtRouteSheetProcessing.loadProcessingData (  dbConnApp 
                                                                                   , log
                                                                                   , uInfo
                                                                                   , clientid );
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }


    /***************************************************************************
     * loadIncomingRouteSheetData */
    /**
     * 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnRouteSheetData loadIncomingRouteSheetData (   string clientid
                                                             , string sheetcode )
    {               
      return (ReturnRouteSheetData) 
      callMethod(typeof(ReturnRouteSheetData),
      delegate()
      {
        return Spedmon.TransportationMgmtRouteSheetProcessing.loadIncomingRouteSheetData (  dbConnApp 
                                                                                          , log
                                                                                          , uInfo
                                                                                          , clientid
                                                                                          , sheetcode );
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

    /***************************************************************************
     * saveIncomingRouteSheetTripDetails */
    /**
     * 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord saveIncomingRouteSheetTripDetails (   string clientid
                                                                , string reference 
                                                                , string pracid
                                                                , string sheetcode
                                                                , string details
                                                                , string validaterec )
    {               
      return (ReturnSaveRecord) 
      callMethod(typeof(ReturnSaveRecord),
      delegate()
      {
        return Spedmon.TransportationMgmtRouteSheetProcessing.saveIncomingRouteSheetTripDetails ( dbConnApp 
                                                                                                , log
                                                                                                , uInfo
                                                                                                , clientid
                                                                                                , reference
                                                                                                , pracid
                                                                                                , sheetcode
                                                                                                , details
                                                                                                , validaterec
                                                                                                );                                                                                          
                                             
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }
         

  }
}
