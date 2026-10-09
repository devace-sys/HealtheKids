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
   * SitesSvc */
  /*
   * Web services end point for Sites methods
   *
   * Unless indicated, each of these methdos are for sbs users only
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

  public class SitesSvc : MBA.WebSvc
  {
    public SitesSvc() : base() { }
    
    
  
  /***************************************************************************
    * viewSel */
    /**
    * Selection view of clients
    *
    * @param  clientID     ID of sites parent client
    * @param  term         Required, search term string (blank for all)
    ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSel viewSel(string clientid, string term)
    {
      return (ReturnSel)
      callMethod(typeof(ReturnSel), 
      delegate()
      {
        return Spedmon.Sites.viewSel (  this.dbConnApp
                                      , this.log
                                      , this.uInfo
                                      , true
                                      , ""
                                      , clientid
                                      , term
                                      );
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method    
    }

    /***************************************************************************
     * delete */
    /**
     * 
     * @param  validaterec   Required, True=Yes, False=No
     * @param  editDelReason Reason for delete
     * @param  recid         Record id to delete
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]


    public ReturnSaveRecord delete (
                                  string editDelReason,
                                  string validaterec,
                                  string recid)
    {
    return (ReturnSaveRecord)
    callMethod(typeof(ReturnSaveRecord),    
    delegate()
    {    
      return Spedmon.Sites.delete(
           this.dbConnApp
          ,this.log
          ,this.uInfo
          ,editDelReason
          ,validaterec
          ,recid);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method          
    }

    /***************************************************************************
     * deleteinline */
    /**
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord deleteinline (string recid)
    {
    return (ReturnSaveRecord)
    callMethod(typeof(ReturnSaveRecord),    
    delegate()
    {    
      return Spedmon.Sites.delete (
            this.dbConnApp
          , this.log
          , this.uInfo
          , @""
          , "N"
          , recid);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method          
    }

    /***************************************************************************
    * undelete */
    /**
     * "undelete" a entity record record.
     *
     * @param  validaterec   Required, True=Yes, False=No
     * @param  editDelReason Reason for delete
     * @param  recid         Record id to delete
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord undelete( 
                                      string editDelReason,
                                      string validaterec,
                                      string recid)
                                  
    {
        return (ReturnSaveRecord)
        callMethod(typeof(ReturnSaveRecord),
        delegate()
        {
            return Spedmon.Sites.unDelete(
                 this.dbConnApp
                ,this.log
                ,this.uInfo
                ,editDelReason
                ,validaterec
                ,recid);
        },
          Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method          
    }

    /***************************************************************************
    * undeleteinline */
    /**
     *
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord undeleteinline (string recid)
                                  
    {
        return (ReturnSaveRecord)
        callMethod(typeof(ReturnSaveRecord),
        delegate()
        {
            return Spedmon.Sites.unDelete(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , @""
                , "N"
                , recid);
        },
          Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method          
    }

    /***************************************************************************
     * save */
    /**
     * Save entity records
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save (
        string  clientID
      , string  cds7       
      , string  name
      , string  address1
      , string  address2
      , string  city
      , string  state
      , string  zip5
      , string  zip4
      , string  phonenumber
      , string  client_provided_site_uid
      , string cybhitpaapproved
      , string cybhitpaapprovedon
      , string  editDelReason
      , string  validaterec
      , string  savetype
      , string  recid )
   {
       
 
      return (ReturnSaveRecord)
     
      callMethod(typeof(ReturnSaveRecord),      
      delegate()
      {    
        return Spedmon.Sites.save (
            this.dbConnApp
          , this.log
          , this.uInfo
          , clientID
          , cds7   
          , name
          , address1
          , address2
          , city
          , state
          , zip5
          , zip4
          , phonenumber
          , client_provided_site_uid
          , cybhitpaapproved
          , cybhitpaapprovedon
          , editDelReason
          , validaterec
          , savetype
          , recid );
         
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method          
    }
  }
}
  
