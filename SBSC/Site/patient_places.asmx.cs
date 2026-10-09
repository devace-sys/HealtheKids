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
   * PatientPlacesSvc */
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
  
  public class PatientPlacesSvc : MBA.WebSvc
  {
    
    /***************************************************************************
     * save */
    /**
     * Save 
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save (  string clientid
                                  , string patid
                                  , string name
                                  , string address1
                                  , string address2
                                  , string city
                                  , string state
                                  , string zip5
                                  , string zip4
                                  , string editDelReason
                                  , string validaterec
                                  , string savetype
                                  , string recid ) 
    {
      return (ReturnSaveRecord) 
     
      callMethod(
        typeof (ReturnSaveRecord)
      , delegate ()
      {    
        return Spedmon.PatientPlaces.save (  dbConnApp
                                             , log
                                             , uInfo
                                             , clientid
                                             , patid
                                             , name                                                                      
                                             , address1
                                             , address2
                                             , city
                                             , state
                                             , zip5
                                             , zip4
                                             , editDelReason
                                             , validaterec
                                             , savetype
                                             , recid );
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }
      
    
    /***************************************************************************
     * viewPlacesInfo */
    /**
     * View info
     * 
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnInfoTable viewinfo (string clientid , string patid)
    {
      return (ReturnInfoTable) 
      callMethod(typeof(ReturnInfoTable), 
      delegate()
      {
        return Spedmon.PatientPlaces.viewPlacesInfo (   this.dbConnApp
                                                      , this.log
                                                      , this.uInfo
                                                      , clientid
                                                      , patid);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    } 

    /***************************************************************************
     * viewSel */
    /**
     * Selection view 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSel (  string clientid
                              , string patid
                              , string term )
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      { 
        return Spedmon.PatientPlaces.viewSel (   dbConnApp 
                                               , log
                                               , uInfo
                                               , false 
                                               , "" 
                                               , clientid
                                               , patid
                                               , term );                                             
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

         
  }
}
