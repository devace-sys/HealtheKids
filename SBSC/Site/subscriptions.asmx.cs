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
   * SubscriptionsSvc */
  /*
   * Web services end point for Publication methods.
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
  
  public class SubscriptionsSvc : MBA.WebSvc
  {

    /***************************************************************************
     * delete */
    /**
     * "delete" a subscription record
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
        
        return Subscriptions.delete(this.dbConnApp,
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
    * Save subscription records
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save
      (string clientid, 
       string publicationid,
       string subscriberid,
       string autodistribute,
       string reportFileType,
       string distributionnotes,
       string editDelReason,
       string validaterec,
       string savetype,
       string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.Subscriptions.save(this.dbConnApp, 
                                           this.log,
                                           this.uInfo,
                                           clientid,
                                           publicationid,
                                           subscriberid,
                                           autodistribute,
                                           reportFileType, //reqfiletype,
                                           distributionnotes,
                                           editDelReason,
                                           validaterec,
                                           savetype,
                                           recid);
                                           
      },
      Constants.ROLE_SVC_PRAC);  // Who can call this method           
    }
    
  
  }
}
