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
   * PractitionerCaseLoadMembersSvc */
  /*
   * Web services end point for Caseload methods.
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
  
  public class PractitionerCaseLoadMembersSvc : MBA.WebSvc
  {

    /***************************************************************************
     * delete */
    /**
     * "delete" caseload member
     * 
     * @param  validaterec   Required, True=Yes, False=No
     * @param  editDelReason Reason for delete
     * @param  recid         Record id to delete
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord delete(string organizationID,
                                   string ownerID,
                                   string groupID,
                                   string entityID)
    {
      return (ReturnSaveRecord)
      callMethod(typeof(ReturnSaveRecord),
      delegate()
      {
        return Spedmon.PractitionerCaseloadMembers.delete(this.dbConnApp,
                                                          this.log,
                                                          this.uInfo,
                                                          "",
                                                          "N", 
                                                          organizationID,
                                                          ownerID, 
                                                          groupID,
                                                          entityID);
      },
        Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }


   
   /***************************************************************************
    * save */
    /**
    * Save caseload member
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save 
      (string organizationID,
       string ownerID,
       string groupID,
       string entityID,      
       string numMinsInd,
	   string numMinsGrp,
       string numMinsAnn,
       string startDateTmtSvcs,
       string planType,
       string weekdaysjson,
       string promisedsvcstartdate,
       string promisedsvcenddate,
       string promisedsvccode,
       string orpdocid,
       string saveType,
       string recID)
    {
      // If none of the checkboxes are checked, set 'weekdaysjson' to a default value
      if (String.IsNullOrEmpty(weekdaysjson)) { 
        weekdaysjson = "{\"monInd\":false,\"tueInd\":false,\"wedInd\":false,\"thurInd\":false,\"friInd\":false,\"monGrp\":false,\"tueGrp\":false,\"wedGrp\":false,\"thurGrp\":false,\"friGrp\":false}";
      }

      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.PractitionerCaseloadMembers.save
         (this.dbConnApp,
          this.log,
          this.uInfo,
          organizationID,
          ownerID,
          groupID,
          entityID,
		  numMinsInd,
		  numMinsGrp,
          numMinsAnn,
          startDateTmtSvcs,
          planType,
          weekdaysjson,
          promisedsvcstartdate,
          promisedsvcenddate,
          promisedsvccode,
          orpdocid,
          "",
          "N",
          saveType,
          recID);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }
    
    /***************************************************************************
     * viewSel */
    /**
     * Selection view of practitioner caseload members
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSel (string organizationID,
                              string ownerID,
                              string groupID,						  
                              string term)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      {
        return Spedmon.PractitionerCaseloadMembers.viewSel(this.dbConnApp, 
                                             this.log, 
                                             this.uInfo,
                                             false, 
                                             "", 
                                             organizationID, 
                                             ownerID,
                                             groupID,											 
                                             term, "","","");
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

    /***************************************************************************
     * viewSelWithMtdYtdTots */
    /**
     * Selection view of practitioner caseload members
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSelWithMtdYtdTots (string organizationID,
                                            string ownerID,
                                            string groupID,						  
                                            string term,
                                            string iep,
                                            string nameID,
                                            string refDate)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      {
        return Spedmon.PractitionerCaseloadMembers.viewSel(this.dbConnApp, 
                                             this.log, 
                                             this.uInfo,
                                             false, 
                                             "", 
                                             organizationID, 
                                             ownerID,
                                             groupID,											 
                                             term, iep, nameID, refDate);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }
    
    /***************************************************************************
     * viewExpectedTreatmentServicesCompliance */
    /**
     * Returns html table of compliance data
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnHTMLContent viewExpectedTreatmentServicesCompliance(string clientID , string pracID)
    {
      return (ReturnHTMLContent) 
      callMethod(typeof(ReturnHTMLContent),
      delegate()
      {
        return Spedmon.PractitionerCaseloadMembers.viewExpectedTreatmentServicesCompliance(
            this.dbConnApp
          , this.log
          , this.uInfo
          , clientID
          , pracID);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    } 
        
    /***************************************************************************
     * viewListExpectedTmtSvcsOnDos */
    /**
     * 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnObjects viewListExpectedTmtSvcsOnDos(string clientid , string pracid, string dos, string pracpatgroupid)
    {
      return (ReturnObjects) 
      callMethod(typeof(ReturnObjects),
      delegate()
      {

        var returnData = Spedmon.PractitionerCaseloadMembers.viewListExpectedSvcsOnDos(
            this.dbConnApp
          , this.log
          , this.uInfo
          , clientid
          , pracid
          , ""
          , dos
          , pracpatgroupid);

         var retObjs = new ReturnObjects();

         retObjs.data = returnData.ToArray();
        
         return retObjs;
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
        return Spedmon.PractitionerCaseloadMembers.viewEntity(
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
