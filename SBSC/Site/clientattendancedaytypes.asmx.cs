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
   * ClientAttendanceDayTypesSvc */
  /*
   * Web services end point for Client Attendance Day Types methods
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

  public class ClientAttendanceDayTypesSvc : MBA.WebSvc
  {
    public ClientAttendanceDayTypesSvc() : base() { }

  
   /***************************************************************************
    * save */
    /**
    * Save day type
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save
    
      (string clientid,
       string name,
       string description,       
       string editDelReason,
       string validaterec,
       string savetype,
       string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.ClientAttendanceDayTypes.save (this.dbConnApp, 
                                                      this.log, 
                                                      this.uInfo,
                                                      clientid,
                                                      name,
                                                      description,
                                                      editDelReason,
                                                      validaterec,
                                                      savetype,
                                                      recid);
                                                    
                                                    
                                           
      },
      Constants.ROLE_SBS_ALL);  // Who can call this method           
    }
   
   /***************************************************************************
    * viewSel */
    /**
    * Selection view of client day types
    *
    * @param    clientid    Optional
    * @param    term        Optional
    ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSel viewSel (string clientid, string term)
    {
      return (ReturnSel)
      callMethod(typeof(ReturnSel), 
      delegate()
      {
        return Spedmon.ClientAttendanceDayTypes.viewSel(this.dbConnApp, this.log, this.uInfo, true, "", clientid, term); 
      },
      Constants.ROLE_SBS_ALL); // Who can call this method    
    }

    /***************************************************************************
     * delete */
    /**
     * "delete" a day type record.
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
            return Spedmon.ClientAttendanceDayTypes.delete(this.dbConnApp,
                                               this.log,
                                               this.uInfo,
                                               editDelReason,
                                               validaterec,
                                               recid);
        },
          Constants.ROLE_SBS_ALL);  // Who can call this method           
    }
  }
}
