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
   * PractitionerPatientGroupsSvc */
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
  
  public class PractitionerPatientGroupsSvc : MBA.WebSvc
  {
    
    public PractitionerPatientGroupsSvc() : base() { }
    
    /***************************************************************************
     * delete */
    /**
     * "delete" a patient group (entire group, including members)
     * 
     * @param  validaterec   Required, True=Yes, False=No
     * @param  editDelReason Reason for delete
     * @param  recid         Record id to delete
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord delete(string organizationID,
                                   string ownerID,
                                   string groupID
                                  )
    {
      return (ReturnSaveRecord)
      callMethod(typeof(ReturnSaveRecord),
      delegate()
      {
        return Spedmon.PractitionerPatientGroups.delete(this.dbConnApp,
                                            this.log,
                                            this.uInfo,
                                            "",
                                            "N",                                            
                                            organizationID,
                                            ownerID,
                                            groupID);
      },
        Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }

    
   /***************************************************************************
    * save */
    /**
    * Save patient group (group only not members)
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save 
      (string clientid,
       string pracid,       
       string groupName,
       string svcnameslistdatasourceid,
       string viatelehealth,
       string nameid,
       string recurring,
       string startdate,
       string enddate,
       string nummins,
       string mon,
       string monstarttime,
       string tue,
       string tuestarttime,
       string wed,
       string wedstarttime,
       string thu,
       string thustarttime,
       string fri,
       string fristarttime,
       string notes,
       string savetype,
       string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.PractitionerPatientGroups.save
         (this.dbConnApp,
          this.log,
          this.uInfo,
          clientid,
          pracid,
          groupName,
          svcnameslistdatasourceid,
          viatelehealth,
          nameid,
          recurring,
          startdate,
          enddate,
          nummins,
          mon,
	      monstarttime, 
          tue,
	      tuestarttime,
          wed,
	      wedstarttime,
          thu,
	      thustarttime,
          fri,
	      fristarttime,
          notes,
          "",
          "N",
          savetype,
          recid);
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

    public ReturnSel viewSel (string organizationID,
                              string ownerID,                               
                              string term)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      {
        return Spedmon.PractitionerPatientGroups.viewSel(this.dbConnApp, 
                                             this.log, 
                                             this.uInfo,
                                             false, 
                                             "", 
                                             organizationID, 
                                             ownerID,                                              
                                             term);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

    /***************************************************************************
     * viewSelByClientPrac */
    /**
     * Selection view of practitioner patient groups
     * Note Same underlying method as viewSel with different public parms
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSelByClientPrac (  string clientid
                                          , string pracid                                                  
                                          , string term )
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      {
        return Spedmon.PractitionerPatientGroups.viewSel(this.dbConnApp, 
                                             this.log, 
                                             this.uInfo,
                                             false, 
                                             "", 
                                             clientid, 
                                             pracid,                                              
                                             term);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }
    
    /***************************************************************************
     * viewEntity */
    /**
     * load one record
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnEntity viewEntity(string clientid, string pracid, string recid)
    {
      return (ReturnEntity) 
      callMethod(typeof(ReturnEntity),
      delegate()
      {
        return Spedmon.PractitionerPatientGroups.viewEntity(
            this.dbConnApp
          , this.log
          , this.uInfo
          , clientid
          , pracid
          , recid);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    } 
    

  }
}
