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
   * ClientAttendanceScheduleTimesSvc */
  /*
   * Web services end point for Client Attendance Schedule Times methods
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

  public class ClientAttendanceScheduleTimesSvc : MBA.WebSvc
  {
    public ClientAttendanceScheduleTimesSvc() : base() { }

  
   /***************************************************************************
    * save */
    /**
    * Save schedule times
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save
    
      (string clientid,
       string fiscalyearid,       
       string scheduleid,
       string attendancedaytypeid,
       string starttime,
       string endtime,
       string period0TimeStart,
       string period0TimeEnd,
       string period1TimeStart,
       string period1TimeEnd, 
       string period2TimeStart,
       string period2TimeEnd, 
       string period3TimeStart,
       string period3TimeEnd, 
       string period4TimeStart,
       string period4TimeEnd, 
       string period5TimeStart,
       string period5TimeEnd, 
       string period6TimeStart,
       string period6TimeEnd, 
       string period7TimeStart,
       string period7TimeEnd,
       string period8TimeStart,
       string period8TimeEnd,
       string period9TimeStart,
       string period9TimeEnd, 
       string period10TimeStart,
       string period10TimeEnd,
       string editDelReason,
       string validaterec,
       string savetype,
       string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.ClientAttendanceScheduleTimes.save (this.dbConnApp, 
                                                      this.log, 
                                                      this.uInfo,
                                                      clientid,
                                                      fiscalyearid,
                                                      scheduleid,
                                                      attendancedaytypeid,
                                                      starttime,
                                                      endtime,
                                                      period0TimeStart,
                                                      period0TimeEnd,
                                                      period1TimeStart,
                                                      period1TimeEnd, 
                                                      period2TimeStart,
                                                      period2TimeEnd, 
                                                      period3TimeStart,
                                                      period3TimeEnd, 
                                                      period4TimeStart,
                                                      period4TimeEnd, 
                                                      period5TimeStart,
                                                      period5TimeEnd, 
                                                      period6TimeStart,
                                                      period6TimeEnd, 
                                                      period7TimeStart,
                                                      period7TimeEnd, 
                                                      period8TimeStart,
                                                      period8TimeEnd, 
                                                      period9TimeStart,
                                                      period9TimeEnd, 
                                                      period10TimeStart,
                                                      period10TimeEnd,
                                                      editDelReason,
                                                      validaterec,
                                                      savetype,
                                                      recid);                                                                                                        
                                           
      },
      Constants.ROLE_SBS_ALL);  // Who can call this method           
    }
  
    /***************************************************************************
     * getDayTypesInUse */
    /**
     * Load day types already in use
     ***************************************************************************/    
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnValue getDayTypesInUse
    
      (string clientid,
       string fiscalyearid,       
       string scheduleid,
       string attendancedaytypeid)
    {
      return (ReturnValue) 
     
      callMethod(typeof(ReturnValue),       
      delegate()
      {    
        return Spedmon.ClientAttendanceScheduleTimes.getValuesAlreadyInUse (this.dbConnApp, 
                                                                            this.log, 
                                                                            this.uInfo,
                                                                            clientid,
                                                                            fiscalyearid, 
                                                                            scheduleid,
                                                                            "",
                                                                            "1",
                                                                            false);                                                                                                        
                                           
      },
      Constants.ROLE_SBS_ALL);  // Who can call this method           
    }


    /***************************************************************************
     * delete */
    /**
     * "delete" a schedule times record.
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
            return Spedmon.ClientAttendanceScheduleTimes.delete(this.dbConnApp,
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
