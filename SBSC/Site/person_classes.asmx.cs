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
   * PersonClassesSvc */
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
  
  public class PersonClassesSvc : MBA.WebSvc
  {
      
    /***************************************************************************
     * viewSel */
    /**
     * Selection view 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSel (  string classpartition
                              , string parentid
                              , string term )
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      { 
        return Spedmon.PersonClasses.viewSel (   dbConnApp 
                                               , log
                                               , uInfo
                                               , false 
                                               , "" 
                                               , classpartition
                                               , parentid
                                               , term );                                             
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

    /***************************************************************************
     * viewSelTypeOfPerson */
    /**
     * Selection view 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSelRole ( string term )
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      { 
        return Spedmon.PersonClasses.viewSelPersonRole ( dbConnApp 
                                                        , log
                                                        , uInfo
                                                        , false
                                                        , ""
                                                        , term );                                             
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

         
    /***************************************************************************
     * viewSelRelationship */
    /**
     * Selection view 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSelRelationship ( string personroleid, string term )            
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      { 
        return Spedmon.PersonClasses.viewSelPersonRelationship (  dbConnApp 
                                                                , log
                                                                , uInfo
                                                                , false 
                                                                , "" 
                                                                , personroleid
                                                                , term );                                             
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }



  }
}
