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
   * PatientGroupsSvc */
  /*
   * Web services end point for Groups methods
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
  public class PatientGroupsSvc : MBA.WebSvc
  {
    public PatientGroupsSvc() : base() { }
    
   /***************************************************************************
    * save */
    /**
    * Save patient groups
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save 
      (string clientid,
       string pracid,       
       string name,
       string description,
       
       string startdate,
       string starttime,
       string nummins,
        
       string grpmtg2,
       string grpmtg3,
       string grpmtg4,
       string grpmtg5,
       string grpmtg6,
       
       string patids,
       string tmteffdate,
       string editDelReason,
       string validaterec,
       string savetype,
       string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.PatientGroups.save
         (this.dbConnApp,
          this.log,
          this.uInfo,
          clientid,
          pracid,
          name,
          description,
          
          startdate,
          starttime,
          nummins,
          
          grpmtg2,
          grpmtg3,
          grpmtg4,
          grpmtg5,
          grpmtg6,
                    
          patids,
          tmteffdate,          
          editDelReason,
          validaterec,
          savetype,
          recid);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }                   

    /***************************************************************************
     * delete */
    /**
     * "delete" a patient group record
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
                                  string recid,
                                  string enddate)
    {
      return (ReturnSaveRecord)
      callMethod(typeof(ReturnSaveRecord),
      delegate()
      {
        return Spedmon.PatientGroups.delete(this.dbConnApp,
                                            this.log,
                                            this.uInfo,
                                            editDelReason,
                                            validaterec,
                                            enddate,
                                            recid);
      },
        Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }

     
   /***************************************************************************
    * viewExpectedServicesInfoTbl */
    /**
    * Returns ReturnInfoTable containing data about expected group services
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnInfoTable viewExpectedServicesInfoTbl
      (string clientid,
       string pracid,
       string groupid, 
       string dos,
       string isiep)
    {
      return (ReturnInfoTable) 
     
      callMethod(typeof(ReturnInfoTable),       
      delegate()
      {    
        return Spedmon.PatientGroups.viewExpectedServicesInfoTbl 
          (this.dbConnApp, 
           this.log, 
           this.uInfo,
           clientid,
           pracid,
           groupid,
           dos,
           isiep);
                                                    
                                                    
                                           
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }    
    
    /***************************************************************************
     * viewSel */
    /**
     * Selection view of practitioner patient groups
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSel (string clientid, 
                              string pracid, 
                              string dos,
                              string term)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      {
        return Spedmon.PatientGroups.viewSel(this.dbConnApp, 
                                             this.log, 
                                             this.uInfo,
                                             false, 
                                             "", 
                                             clientid, 
                                             pracid, 
                                             dos,
                                             term);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }


  }
}
