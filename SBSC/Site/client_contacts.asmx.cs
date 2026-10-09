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
   * ClientContactsSvc */
  /*
   * Web services end point for Client Contact methods
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
  public class ClientContactsSvc : MBA.WebSvc
  {
    public ClientContactsSvc() : base() { }
    
   /***************************************************************************
    * delete */
   /**
    * "delete" a client contact record.
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
      return Spedmon.ClientContacts.delete(this.dbConnApp,
                                         this.log,
                                         this.uInfo,
                                         editDelReason,
                                         validaterec,
                                         recid);
      },
      Constants.ROLE_SBS_ALL);  // Who can call this method           
    }

    /***************************************************************************
     * save */
    /**
     * Save client contact records
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save (
         string clientid
       , string name
       , string roleid
       , string email
       , string phone
       , string editDelReason
       , string validaterec
       , string savetype
       , string recid )
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {                     
        return Spedmon.ClientContacts.save (                        
            this.dbConnApp
          , this.log
          , this.uInfo   
          , clientid
          , name
          , roleid
          , email
          , phone
          , editDelReason
          , validaterec
          , savetype
          , recid);                                           
      },
      Constants.ROLE_SBS_ALL);  // Who can call this method           
    }        
        
    /***************************************************************************
    * viewSel */
    /**
    * 
    ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSel viewSel( string clientid, string term)
    {
      return (ReturnSel)
      callMethod(typeof(ReturnSel), 
      delegate()
      {
        return Spedmon.ClientContacts.viewSel(this.dbConnApp, this.log, this.uInfo, false, "", clientid, term); 
      },
      Constants.ROLE_SBS_ALL); // Who can call this method    
    }

  }
}
