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
   * TransportMgmtAuthRoutesSvc*/
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
  
  public class TransportMgmtAuthRoutesSvc : MBA.WebSvc
  {

    /***************************************************************************
     * delete */
    /**
     * "delete" route
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
                                   //, string effDate 
                                   )
    {
      return (ReturnSaveRecord)
      callMethod(
        typeof(ReturnSaveRecord)
      , delegate() {
        return Spedmon.TransportationMgmtAuthorizedRoutes.delete( dbConnApp
                                                                   , log
                                                                   , uInfo
                                                                   , ""
                                                                   , "N"
                                                                   , organizationID
                                                                   , ownerID
                                                                   , groupID );
      }
      , Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
   }
   
   /***************************************************************************
    * save */
    /**
    * Save 
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save (  string organizationID
                                  , string ownerID                                  
                                  , string name
								  , string busNumber
                                  , string origPlaceID
                                  , string destPlaceID
                                  , string busdriverid
                                  , string saveType
                                  , string recID ) 
    {
      return (ReturnSaveRecord) 
     
      callMethod(
        typeof (ReturnSaveRecord)
      , delegate ()
      {    
        return Spedmon.TransportationMgmtAuthorizedRoutes.save (   dbConnApp
                                                                 , log
                                                                 , uInfo
                                                                 , organizationID
                                                                 , ownerID
                                                                 , name
																 , busNumber
                                                                 , origPlaceID
                                                                 , destPlaceID
                                                                 , ""
                                                                 , busdriverid
                                                                 , ""
                                                                 , "N"
                                                                 , saveType
                                                                 , recID );
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }

    /***************************************************************************
    * duplicate */
    /**
    * Save duplicate of a record
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord duplicate(  string organizationID
                                  , string ownerID                                  
                                  , string groupID                                  
                                  , string name) 
    {
      return (ReturnSaveRecord) 
     
      callMethod(
        typeof (ReturnSaveRecord)
      , delegate ()
      {    
        return Spedmon.TransportationMgmtAuthorizedRoutes.duplicate(   dbConnApp
                                                                 , log
                                                                 , uInfo
                                                                 , organizationID
                                                                 , ownerID
                                                                 , groupID
                                                                 , name 
                                                                 , false );
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }

    /***************************************************************************
    * duplicate */
    /**
    * Save duplicate of a record
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord duplicateandreversestops(  string organizationID
                                  , string ownerID                                  
                                  , string groupID                                  
                                  , string name) 
    {
      return (ReturnSaveRecord) 
     
      callMethod(
        typeof (ReturnSaveRecord)
      , delegate ()
      {    
        return Spedmon.TransportationMgmtAuthorizedRoutes.duplicate(   dbConnApp
                                                                 , log
                                                                 , uInfo
                                                                 , organizationID
                                                                 , ownerID
                                                                 , groupID
                                                                 , name
                                                                 , true );
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

    public ReturnSel viewSel (  string clientid
                              , string transmgmtid
                              , string term )
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      {
        return Spedmon.TransportationMgmtAuthorizedRoutes.viewSel( dbConnApp 
                                                                     , log
                                                                     , uInfo
                                                                     , false 
                                                                     , "" 
                                                                     , clientid
                                                                     , transmgmtid
                                                                     , term);
                                             
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

    /***************************************************************************
     * viewSelPatNotAssigned */
    /**
     * Selection view 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSelPatNotAssigned (  string organizationID
                                            , string ownerID
                                            , string patID)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      {
        return Spedmon.TransportationMgmtAuthorizedRoutes.viewSelPatNotAssigned ( dbConnApp 
                                                                     , log
                                                                     , uInfo
                                                                     , false 
                                                                     , "" 
                                                                     , organizationID 
                                                                     , ownerID
                                                                     , patID);
                                             
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

         
  }
}
