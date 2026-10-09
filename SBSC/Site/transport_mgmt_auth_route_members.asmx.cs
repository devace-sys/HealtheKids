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
   * TransportMgmtAuthRouteMembersSvc */
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
  
  public class TransportMgmtAuthRouteMembersSvc : MBA.WebSvc
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
        return Spedmon.TransportationMgmtAuthorizedRouteMembers.delete( dbConnApp
                                                                        , log
                                                                        , uInfo
                                                                        , ""
                                                                        , "N"
                                                                        , organizationID
                                                                        , ownerID
                                                                        , groupID
                                                                        , entityID
                                                                        , "1" );
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
                                  , string groupID
                                  , string entityID
                                  , string origPlaceID
                                  , string destPlaceID
                                  , string weekDaysJSON
                                  , string selectAmPm
                                  , string savetype
                                  , string recid ) 
    {
      return (ReturnSaveRecord) 
     
      callMethod(
        typeof (ReturnSaveRecord)
      , delegate ()
      {    
        return Spedmon.TransportationMgmtAuthorizedRouteMembers.save (  dbConnApp
                                                                      , log
                                                                      , uInfo
                                                                      , organizationID
                                                                      , ownerID
                                                                      , groupID                                                                      
                                                                      , entityID
                                                                      , origPlaceID
                                                                      , destPlaceID
                                                                      , weekDaysJSON
                                                                      , selectAmPm
                                                                      , ""
                                                                      , "N"
                                                                      , savetype
                                                                      , recid );
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }
    
    
   /***************************************************************************
    * saveMembersDisplayOrder */
    /**
    * Save 
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord saveMembersDisplayOrder (   string organizationID
                                                      , string ownerID
                                                      , string groupID
                                                      , string membersDisplayOrder ) 
    {
      return (ReturnSaveRecord) 
     
      callMethod(
        typeof (ReturnSaveRecord)
      , delegate ()
      {    
        return Spedmon.TransportationMgmtAuthorizedRouteMembers.saveMembersDisplayOrder (  dbConnApp
                                                                                         , log
                                                                                         , uInfo
                                                                                         , organizationID
                                                                                         , ownerID
                                                                                         , groupID                                                                      
                                                                                         , membersDisplayOrder );
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
                              , string groupID
                              , string term )
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      {
        return Spedmon.TransportationMgmtAuthorizedRouteMembers.viewSel(  dbConnApp 
                                                                        , log
                                                                        , uInfo
                                                                        , false 
                                                                        , "" 
                                                                        , organizationID 
                                                                        , ownerID
                                                                        , groupID
                                                                        , term);
                                             
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

         
  }
}
