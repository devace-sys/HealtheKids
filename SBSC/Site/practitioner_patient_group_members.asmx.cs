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
   * PractitionerPatientGroupMembersSvc */
  /*
   * Web services end point for Practitioner Patient Group Members methods
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
  
  public class PractitionerPatientGroupMembersSvc : MBA.WebSvc
  {
    public PractitionerPatientGroupMembersSvc() : base() { } 

    /***************************************************************************
     * delete */
    /**
     * "delete" a patient group member record (member only, not group)
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
                                   string entityID )
    {
      return (ReturnSaveRecord)
      callMethod(typeof(ReturnSaveRecord),
      delegate()
      {
        return Spedmon.PractitionerPatientGroupMembers.delete(this.dbConnApp,
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
    * saveall */
    /**
    * Save all selected patients group members
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord saveall
      (string clientid,
       string pracid,       
       string patselectedjson,
       string groupid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.PractitionerPatientGroupMembers.saveall
         (this.dbConnApp,
          this.log,
          this.uInfo,
          clientid,
          pracid,
          patselectedjson,
          groupid,
          "N");
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }     

   /***************************************************************************
    * save */
    /**
    * Save patient group members (members only not group)
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save 
      (string organizationID,
       string ownerID,       
       string groupID,
       string entityID,      
       string saveType,
       string recID)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecordWithJSONData),       
      delegate()
      {    
        return Spedmon.PractitionerPatientGroupMembers.save
         (this.dbConnApp,
          this.log,
          this.uInfo,
          organizationID,
          ownerID,
          groupID,
		      entityID,
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
     * Selection view of practitioner patient groups
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
        return Spedmon.PractitionerPatientGroupMembers.viewSel(this.dbConnApp, 
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
     * viewSelByClientPrac */
    /**
     * Selection view of practitioner patient groups
     * Note Same underlying method as viewSel with different public parms
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSelByClientPrac (  string clientid
                                          , string pracid
                                          , string patgroupid						  
                                          , string term)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      {
        return Spedmon.PractitionerPatientGroupMembers.viewSel(this.dbConnApp, 
                                             this.log, 
                                             this.uInfo,
                                             false, 
                                             "", 
                                             clientid, 
                                             pracid,
                                             patgroupid,											 
                                             term, "","","");
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

    /***************************************************************************
     * viewSelWithMtdYtdTots */
    /**
     * Selection view of practitioner patient groups
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
        return Spedmon.PractitionerPatientGroupMembers.viewSel(this.dbConnApp, 
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
  }
}
