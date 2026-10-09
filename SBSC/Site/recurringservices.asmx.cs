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
   * RecurringServicesSvc */
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
  
  public class RecurringServicesSvc: MBA.WebSvc
  {
   
   /***************************************************************************
    * Delete */
    /**
    * Permanent delete
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord delete
      (string editDelReason,
       string validaterec,
       string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {
        return RecurringServices.delete (this.dbConnApp, 
                                         this.log, 
                                         this.uInfo,
                                         editDelReason,
                                         validaterec,
                                         recid);                                                                                       
      },
      Constants.ROLE_SBS_ALL);  // Who can call this method           
   }
   
   /***************************************************************************
    * opend*/
    /**
    * End recurring service record
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord opend
      (string effectivedate,
       string editDelReason,
       string validaterec,
       string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {
        return RecurringServices.opEnd(
                                      this.dbConnApp, 
                                      this.log, 
                                      this.uInfo,
                                      editDelReason,
                                      validaterec,
                                      recid,
                                      effectivedate);                                                                                       
      },
      Constants.ROLE_SBS_ALL);  // Who can call this method           
    }

    /***************************************************************************
     * viewPossibleDups */
    /**
     * View possible dup records
     * 
     * @param  clientid     Required, client id
     * @param  patid        Required, patient id
     * @param  fiscalyearid Required, fiscal year id
     * @param  startdate    Required, start date
     * @param  enddate      Required, end date
     * @param  term         Required, search term string (last, first)
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnInfoTable viewPossibleDups (string clientid,
                                             string patid,
                                             string fiscalyearid,
                                             string startdate,
                                             string enddate,
                                             string recid)
    {
      return (ReturnInfoTable) 
      callMethod(typeof(ReturnInfoTable), 
      delegate()
      {
        return Spedmon.RecurringServices.viewPossibleDups (this.dbConnApp, this.log, this.uInfo, clientid, patid, fiscalyearid, startdate, enddate, recid);
      },
      Constants.ROLE_SBS_ALL); // Who can call this method
    } 
   
   /***************************************************************************
    * save */
    /**
    * Save recurring services record
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save
      (string clientid,
       string patid,
       string fiscalyearid,
       string startdate,
       string enddate,
       string calendarid,
       string scheduleid, 
       string pracids,
       string details_pracs_all,
       string details_tmt_bs,
       string details_tmt_ds_ind,
       string details_tmt_ds_grp,
       string details_tmt_as,
       string details_trans_hm_ss,
       string details_trans_ss_hm,
       string details_trans_ss_os,
       string details_trans_os_ss,
       string notes,
       string editDelReason,
       string validaterec,
       string savetype,
       string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {
        return RecurringServices.save(this.dbConnApp, 
                                      this.log, 
                                      this.uInfo, 
                                      clientid, 
                                      patid, 
                                      fiscalyearid,
                                      startdate,
                                      enddate,
                                      calendarid,
                                      scheduleid,
                                      pracids,
                                      details_pracs_all,
                                      details_tmt_bs,
                                      details_tmt_ds_ind,
                                      details_tmt_ds_grp,
                                      details_tmt_as,
                                      details_trans_hm_ss,
                                      details_trans_ss_hm,
                                      details_trans_ss_os,
                                      details_trans_os_ss,
                                      notes,
                                      editDelReason,
                                      validaterec,
                                      savetype,
                                      recid);                                                                                       
      },
      Constants.ROLE_SBS_ALL);  // Who can call this method           
    }  
  }
}
