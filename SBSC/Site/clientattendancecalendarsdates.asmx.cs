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
   * ClientAttendanceCalendarsDatesSvc */
  /*
   * Web services end point for Client Attendance Calendars Dates methods
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

  public class ClientAttendanceCalendarsDatesSvc : MBA.WebSvc
  {
    public ClientAttendanceCalendarsDatesSvc() : base() { }

  
   /***************************************************************************
    * save */
    /**
    * Save calendar dates
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save
    
      (string clientid,
       string fiscalyearid,       
       string calendarid,
       string attendancedaytypeid,
       string datesstr,
       string editDelReason,
       string validaterec,
       string savetype,
       string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.ClientAttendanceCalendarDates.save (this.dbConnApp, 
                                                           this.log, 
                                                           this.uInfo,
                                                           clientid,
                                                           fiscalyearid,
                                                           calendarid,
                                                           attendancedaytypeid,
                                                           datesstr,
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
       string calendarid,
       string attendancedaytypeid)
    {
      return (ReturnValue) 
     
      callMethod(typeof(ReturnValue),       
      delegate()
      {    
        return Spedmon.ClientAttendanceCalendarDates.getValuesAlreadyInUse (this.dbConnApp, 
                                                                            this.log, 
                                                                            this.uInfo,
                                                                            clientid,
                                                                            fiscalyearid, 
                                                                            calendarid,
                                                                            "",
                                                                            "1",
                                                                            false);                                                                                                        
                                           
      },
      Constants.ROLE_SBS_ALL);  // Who can call this method           
    }

    /***************************************************************************
     * getDatesInUse */
    /**
     * Load values already in use
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnValue getDatesInUse
    
      (string clientid,
       string fiscalyearid,       
       string calendarid,
       string attendancedaytypeid)
    {
      return (ReturnValue) 
     
      callMethod(typeof(ReturnValue),       
      delegate()
      {    
        return Spedmon.ClientAttendanceCalendarDates.getValuesAlreadyInUse (this.dbConnApp, 
                                                           this.log, 
                                                           this.uInfo,
                                                           clientid,
                                                           fiscalyearid,
                                                           calendarid,
                                                           attendancedaytypeid,
                                                           "2",
                                                           false);                                                                                                        
                                           
      },
      Constants.ROLE_SBS_ALL);  // Who can call this method           
    }

    /***************************************************************************
     * delete */
    /**
     * "delete" a calendar date record.
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
            return Spedmon.ClientAttendanceCalendarDates.delete(this.dbConnApp,
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
