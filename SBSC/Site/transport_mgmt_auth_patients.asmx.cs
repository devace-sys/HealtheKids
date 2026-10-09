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
   * TransportMgmtAuthPatientsSvc*/
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
  
  public class TransportMgmtAuthPatientsSvc : MBA.WebSvc
  {

    /***************************************************************************
     * delete */
    /**
     * "delete"  member
     * 
     * @param  validaterec   Required, True=Yes, False=No
     * @param  editDelReason Reason for delete
     * @param  recid         Record id to delete
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord delete(  string organizationID
                                   , string ownerID
                                   , string groupID
                                   , string entityID )
    {
      return (ReturnSaveRecord)
      callMethod(
        typeof(ReturnSaveRecord)
      , delegate() {
        return Spedmon.TransportationMgmtAuthorizedPatients.delete( dbConnApp
                                                                   , log
                                                                   , uInfo
                                                                   , ""
                                                                   , "N"
                                                                   , organizationID
                                                                   , ownerID
                                                                   , entityID
                                                                   , "1" );
      }
      , Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
   }
   
   /***************************************************************************
    * save */
    /**
    * Save  member
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save (  string organizationID
                                  , string ownerID
                                  , string entityID
                                  , string sitePlaceID
                                  , string homePlaceID
                                  , string saveType
                                  , string recID ) 
    {
      return (ReturnSaveRecord) 
     
      callMethod(
        typeof (ReturnSaveRecord)
      , delegate ()
      {    
        return Spedmon.TransportationMgmtAuthorizedPatients.save (   dbConnApp
                                                                   , log
                                                                   , uInfo
                                                                   , organizationID
                                                                   , ownerID
                                                                   , entityID
                                                                   , sitePlaceID
                                                                   , homePlaceID
                                                                   , ""
                                                                   , "N"
                                                                   , saveType
                                                                   , recID );
      },

      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }
    

    /***************************************************************************
     * viewSel */
    /**
     * Selection view 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSel (  string organizationID
                              , string ownerID
                              , string term )
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      {
        return Spedmon.TransportationMgmtAuthorizedPatients.viewSel(   dbConnApp 
                                                                     , log
                                                                     , uInfo
                                                                     , false 
                                                                     , "" 
                                                                     , organizationID 
                                                                     , ownerID
                                                                     , term);
                                             
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

         
  }
}
