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
   * OneOnOneAideAssignmentsSvc */
  /*
   * Web services end point for 1:1 aid assignment methods.
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
  
  public class OneOnOneAideAssignmentsSvc: MBA.WebSvc
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
        
        return OneOnOneAideAssignments.delete(this.dbConnApp,
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
    * Save 1:1 assignment
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save
      (string clientid,
       string patid,
       string siteid,
       string pracid,
       string lname,
       string fname,
       string aidetype,
       string svcsauthiniep,
       string svcsmednec,
       string busminsam,
       string sitemins,
       string busminspm,
       string startdate,
       string enddate,
       string notes,
       string fiscalyearid,
       string calendarid,
       string scheduleid,
       string editDelReason,
       string validaterec,
       string savetype,
       string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.OneOnOneAideAssignments.save (this.dbConnApp, 
                                                    this.log, 
                                                    this.uInfo,
                                                    clientid,
                                                    patid,
                                                    siteid,
                                                    pracid,
                                                    lname,
                                                    fname,
                                                    aidetype,
                                                    svcsauthiniep,
                                                    svcsmednec,
                                                    busminsam,
                                                    sitemins,
                                                    busminspm,
                                                    startdate,
                                                    enddate,
                                                    notes,
                                                    fiscalyearid,
                                                    calendarid,
                                                    scheduleid,
                                                    editDelReason,
                                                    validaterec,
                                                    savetype,
                                                    recid);
                                                    
                                                    
                                           
      },
      Constants.ROLE_SBS_ALL);  // Who can call this method           
    }
    
   /***************************************************************************
    * viewExpectedServicesInfoTbl */
    /**
    * Returns ReturnInfoTable containing data about expected 1:1 services
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnInfoTable viewExpectedServicesInfoTbl
      (string clientid,
       string patid, 
       string refdate,
       string includebs,
       string startdatebs,
       string enddatebs,
       string includeds,
       string startdateds,
       string enddateds,
       string includeas,
       string startdateas,
       string enddateas
       )
    {
      return (ReturnInfoTable) 
     
      callMethod(typeof(ReturnInfoTable),       
      delegate()
      {    
        return Spedmon.OneOnOneAideAssignments.viewExpectedServicesInfoTbl 
          (this.dbConnApp, 
           this.log, 
           this.uInfo,
           clientid,
           patid,
           refdate,
           includebs,
           startdatebs,
           enddatebs,
           includeds,
           startdateds,
           enddateds,
           includeas,
           startdateas,
           enddateas);
                                                    
                                                    
                                           
      },
      Constants.ROLE_SBS_ALL);  // Who can call this method           
    }


  
  }
}
