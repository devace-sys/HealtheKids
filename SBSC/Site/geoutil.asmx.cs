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
using System.IO;

namespace Spedmon
{
  /***************************************************************************
   * GeoUtilSvc */
  /*
   * Web services end point 
   *
   * Unless indicated, each of these methdos are for all users
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

  public class GeoUtilSvc : MBA.WebSvc
  {
    public GeoUtilSvc() : base() { }

    /***************************************************************************
     * validateAddress */
    /**
     *
     ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnUspsAddress validateAddress (   string street1
                                               , string street2
                                               , string city
                                               , string state
                                               , string zip5
                                               , string zip4 )
    {
      return (ReturnUspsAddress)
      callMethod(typeof(ReturnUspsAddress), 
      delegate()
      {        		    
		    return MBA.GeoUtil.validateAddress (street1,street2,city,state,zip5,zip4,true);		   
      },Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method    
    }

    /***************************************************************************
     * computeDistanceAndTravelTime */
    /**
     *
     ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnGoogleDistanceMatrix computeDistanceAndTravelTime (  string origin
                                                                    , string destination )
    {
      return (ReturnGoogleDistanceMatrix)
      callMethod(typeof(ReturnGoogleDistanceMatrix), 
      delegate()
      {        		    
		     return MBA.GeoUtil.computeDistanceAndTravelTime (origin, destination, true, true);		     
      }, Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method    
    }


    /***************************************************************************
     * retrieveCaSchoolDirectoryEntry */
    /**
     *
     ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnCdeSchoolDirectoryEntry retrieveCdeSchoolDirectoryEntry ( string cdsCode )
    {
      return (ReturnCdeSchoolDirectoryEntry)
      callMethod(typeof(ReturnCdeSchoolDirectoryEntry), 
      delegate()
      {        		    
		    return MBA.GeoUtil.retrieveCdeSchoolDirectoryEntry (cdsCode,false);  
      },Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method    
    }

    /***************************************************************************
     * retrieveCdeCurrentSite */
    /**
     *
     ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnCdeCurrentSite retrieveCdeCurrentSite ( string cdsCode )
    {
      return (ReturnCdeCurrentSite)
      callMethod(typeof(ReturnCdeCurrentSite), 
      delegate()
      {        		    
		    return CdeRecords.retrieveCdeCurrentSite(dbConnApp, log, uInfo, cdsCode);		    
      },Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method    
    }

    /***************************************************************************
     * validateAddress */
    /**
     *
     ***************************************************************************/
   
  }
}
