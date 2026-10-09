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
   * SubscribersSvc */
  /*
   * Web services end point for subscriber methods.
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
  
  public class SubscribersSvc : MBA.WebSvc
  {

    /***************************************************************************
     * delete */
    /**
     * "delete" a subscriber record
     * 
     * @param  validaterec   Required, True=Yes, False=No
     * @param  editDelReason Reason for delete
     * @param  recid         Record id to delete
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord delete(
                                  string editDelReason,
                                  string validaterec,
                                  string recid)
    {
      return (ReturnSaveRecord)
      callMethod(typeof(ReturnSaveRecord),
      delegate()
      {
        
        return Subscribers.delete(this.dbConnApp,
                                  this.log,
                                  this.uInfo,
                                  editDelReason,
                                  validaterec,
                                  recid);
                                           
      },
        Constants.ROLE_SVC_PRAC);  // Who can call this method           
    }


   /***************************************************************************
    * save */
    /**
    * Save subscriber records
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save (
       string clientid, 
       string lname,
       string fname,
       string email,
       string isInternal,
       string editDelReason,
       string validaterec,
       string savetype,
       string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.Subscribers.save(this.dbConnApp, 
                                           this.log,
                                           this.uInfo,
                                           clientid,
                                           lname,
                                           fname,
                                           email,
                                           isInternal,
                                           editDelReason,
                                           validaterec,
                                           savetype,
                                           recid);
                                           
      },
      Constants.ROLE_SVC_PRAC);  // Who can call this method           
    }
    
    /***************************************************************************
     * viewSel */
    /**
     * Selection view of subscribers
     * 
     * @param  term         Required, search term string (last, first)
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSel (string clientid, string term)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel), 
      delegate()
      {
          bool internalOnly = this.uInfo.pcalStaff && Util.IsNullOrEmpty(clientid);
          // If an internal user is logged-in and no client is selected from the drop-down, then we intend to create a subscription
          // that sends data pertaining to all clients.  This subscription must go to an internal subscriber only!!!!
          return Spedmon.Subscribers.viewSel(this.dbConnApp, this.log, this.uInfo,true,"",clientid, internalOnly, term);
      },
      Constants.ROLE_SVC_PRAC); // Who can call this method
    } 
    
  
  }
}
