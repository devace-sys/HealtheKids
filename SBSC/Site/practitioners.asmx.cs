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
   * PractionersSvc */
  /*
   * Web services end point for Practitioner methods
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
  public class PractitionersSvc : MBA.WebSvc
  {
    public PractitionersSvc() : base() { }
    
   /***************************************************************************
    * delete */
   /**
    * "delete" a service practitioner record.
    * 
    * @param  validaterec   Required, True=Yes, False=No
    * @param  editDelReason Reason for delete
    * @param  recid         Record id to delete
    ***************************************************************************/  
              
    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord delete (
                                  string editDelReason,
                                  string validaterec,
                                  string recid)
    {
    return (ReturnSaveRecord)
    callMethod(typeof(ReturnSaveRecord),    
    delegate()
    {    
      return Spedmon.Practitioners.delete(this.dbConnApp,
                                         this.log,
                                         this.uInfo,
                                         editDelReason,
                                         validaterec,
                                         recid);
      },
      Constants.ROLE_SVC_PRAC);  // Who can call this method           
    }

    /***************************************************************************
     * deleteinline */
    /**
     * "delete" a service practitioner record.
     * 
     * @param  recid         Record id to delete
     ***************************************************************************/  
              
    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord deleteinline (string recid)
    {
      return (ReturnSaveRecord)
      callMethod(typeof(ReturnSaveRecord),    
      delegate()
      {    
        return Spedmon.Practitioners.delete(this.dbConnApp,
                                           this.log,
                                           this.uInfo,
                                           "",
                                           "0",
                                           recid);
      },
      Constants.ROLE_SVC_PRAC);  // Who can call this method           
   }

   /***************************************************************************
    * undelete */
   /**
    * "undelete" a practitioner record.
    * 
    * @param  validaterec   Required, True=Yes, False=No
    * @param  editDelReason Reason for delete
    * @param  recid         Record id to delete
    ***************************************************************************/  
              
    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord undelete (
                                  string editDelReason,
                                  string validaterec,
                                  string recid)
    {
    return (ReturnSaveRecord)
    callMethod(typeof(ReturnSaveRecord),    
    delegate()
    {    
      return Spedmon.Practitioners.unDelete(this.dbConnApp,
                                         this.log,
                                         this.uInfo,
                                         editDelReason,
                                         validaterec,
                                         recid);
      },
      Constants.ROLE_SVC_PRAC);  // Who can call this method           
    }

   /***************************************************************************
    * undeleteinline */
   /**
    * "undelete" a practitioner record.
    * 
    * @param  recid         Record id to delete
    ***************************************************************************/  
              
    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord undeleteinline (string recid)
    {
    return (ReturnSaveRecord)
    callMethod(typeof(ReturnSaveRecord),    
    delegate()
    {    
      return Spedmon.Practitioners.unDelete(this.dbConnApp,
                                         this.log,
                                         this.uInfo,
                                         "",
                                         "0",
                                         recid);
      },
      Constants.ROLE_SVC_PRAC);  // Who can call this method           
    }


    /***************************************************************************
     * save */
    /**
     * Save practitioner records
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save (
       string clientid, 
       string lname,
       string fname,
       string groupdisp,
       string employee_relationship,
       string clientEmployeeID,
       string startDate,
       string endDate,
       string cprCertEffectiveDate,
       string cprCertExpirationDate,
       string email,
       string phone,
       string fax,
       string street1,
       string street2,
       string city,
       string state,
       string zip5,
       string zip4,
       string npi_number,
       string is_valid_mcal_orp,
       string is_valid_mcal_orp_last_validated,       
       string grouprept,
       string inc_in_fin_repts,

       string participatesinleabop,
       string participatesinleabopnonsped,
       string participatesincyhbi,
       string participatesinruhealth,

       string currentlywithclient ,

       string submitclaims,
       string submitClaimsEffectiveDate,  
     
       string claim_TCM,
       string claim_TCMEffectiveDate,
       string cybhitpaapproved,
       string cybhitpaapprovedon,
       string cybhitpaid,
       string cybhisubmitclaims,
       string notes,
       string qualificationsJSONData,
       string deptHead,
       string deptheadcanseeentirepracticefamilyindeptreviewreports,
       string displaypercent,
       string displaymoney,
       string acescertcompletedon,
       string dob,
       string gender,
       string ssn,
       string cybhidegreecode,
       string cybhidegreecode2,
       string cybhidegreecode3,
       string cybhispecialtycode,
       string cybhispecialtycode2,
       string cybhispecialtycode3,
       string cybhispecialtycode4,
       string editDelReason,
       string validaterec,
       string savetype,
       string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.Practitioners.save
         (this.dbConnApp,
          this.log,
          this.uInfo,
          clientid, 
          lname,
          fname,
          groupdisp,
          employee_relationship,
          clientEmployeeID,
          startDate,
          endDate,
          cprCertEffectiveDate,
          cprCertExpirationDate,
          email,
          phone,
          fax,
          street1,
          street2,
          city,
          state,
          zip5,
          zip4,
          npi_number,
          is_valid_mcal_orp,
          is_valid_mcal_orp_last_validated,       
          grouprept,
          inc_in_fin_repts,
          participatesinleabop,
          participatesinleabopnonsped,
          participatesincyhbi,
          participatesinruhealth,

          currentlywithclient ,

          submitclaims,
          submitClaimsEffectiveDate,       
          claim_TCM,
          claim_TCMEffectiveDate,
          cybhitpaapproved,
          cybhitpaapprovedon,
          cybhitpaid,
          cybhisubmitclaims,
          notes,
          qualificationsJSONData,
          deptHead,
          deptheadcanseeentirepracticefamilyindeptreviewreports,
          displaypercent,
          displaymoney,
          acescertcompletedon,
          dob,
          gender,
          ssn,
          cybhidegreecode,
          cybhidegreecode2,
          cybhidegreecode3,
          cybhispecialtycode,
          cybhispecialtycode2,
          cybhispecialtycode3,
          cybhispecialtycode4,
          editDelReason,
          validaterec,
          savetype,
          recid);
      },
      Constants.ROLE_SVC_SUP_PRAC);  // Who can call this method           
    }

    /***************************************************************************
     * viewEntity */
    /**
     * Details about the given clientID, pracID
     *
     * @param  clientID       Required, client ID
     * @param  pracID         Required, practitioner ID
     ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnEntity viewEntity(string clientid, string pracid)
    {
      return (ReturnEntity)
      callMethod(typeof(ReturnEntity), 
      delegate()
      {
        /*-------------------------------
         * If the user is from sbs
         * they can select any practitioner
         *------------------------------*/
        
        switch (rd.wu.usr.roleName.ToLower())
        {
          
          case Constants.ROLE_LEA_INPUT_STAFF:
          {
            /*-------------------------------
             * LEA input staff
             * any practitioner within their
             * client id
             *------------------------------*/
            clientid = rd.wu.pr.clientID.ToString();
            break;

          }
          case Constants.ROLE_LEA_CORDINATOR:
          {
            /*-------------------------------
             * Service coordinators can view
             * any practitioner within their
             * client id
             *------------------------------*/
            clientid = rd.wu.pr.clientID.ToString();
            break;
          }
          default:{break;}
        }
        ReturnEntity so = Spedmon.Practitioners.viewEntity(this.dbConnApp,this.log,this.uInfo,clientid,pracid);
        so.entity.notes = Util.textToHTMLPre(so.entity.notes);
        return so; 
      },
      Constants.ROLE_SVC_PRAC); // Who can call this method
    }      
    
    
    /***************************************************************************
     * viewQFormsInfoTable */
    /**
     * QForms related the given clientID, pracID
     *
     * @param  clientID       Required, client ID
     * @param  pracID         Required, practitioner ID
     ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnInfoTable viewQFormsInfoTable (string clientid, string pracid)
    {
      return (ReturnInfoTable)
      callMethod(typeof(ReturnInfoTable), 
      delegate()
      {
        ReturnInfoTable so = Spedmon.Practitioners.viewQFormInfoTable(this.dbConnApp,this.log,this.uInfo,clientid,pracid);
        return so; 
      },
      Constants.ROLE_SVC_PRAC); // Who can call this method
    }      
    
    
    /***************************************************************************
     * viewSel */
    /**
     * Selection view of practitioners.
     * 
     * @param  clientid     Required, client id
     * @param  term         Required, search term string (blank for all)
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
       
    public ReturnSel viewSel (string clientid, string term)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      {        
        return Spedmon.Practitioners.viewSel(this.dbConnApp, this.log, this.uInfo, true, "", "0", clientid, "", term, "","");
      },
      Constants.ROLE_SVC_SUP_PRAC); // Who can call this method
    }
       
    /* Note: This is the prefered method and has replaced the use of viewSel in most places */

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSel2 (string pracdatasource, string clientid, string patid, string term, string dos, string groupserviceclassnameid)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      {
        return Spedmon.Practitioners.viewSel(this.dbConnApp, this.log, this.uInfo, true, "", pracdatasource, clientid, patid, term, dos, groupserviceclassnameid);
      },
      Constants.ROLE_SVC_SUP_PRAC); // Who can call this method
    }

    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSelPotentialORPOnly (string clientid, string term, string groupserviceclassnameid)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      {        
        return Spedmon.Practitioners.viewSel(this.dbConnApp, this.log, this.uInfo, true, "", "6", clientid, "", term, "", groupserviceclassnameid);
      },
      Constants.ROLE_SVC_SUP_PRAC); // Who can call this method
    }

    /***************************************************************************
     * getPractitioner */
    /**
     * Returns PatientPerson data
     *
     ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnPractitioner getPractitioner (string clientid, string pracid)
    {
      return (ReturnPractitioner)
      callMethod(typeof(ReturnPractitioner), 
      delegate()
      {
        ReturnPractitioner so = Spedmon.Practitioners.getPractitioner (this.dbConnApp,this.log,this.uInfo, pracid);
        return so; 
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

    /***************************************************************************
     * npiLookup */
    /**
     * Returns result of a lookup query to CMS
     *
     ***************************************************************************/
    
     [WebMethod]
     [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
     public ReturnValue npiLookup (string term, string selectmode)
     {
        return (ReturnValue)
        callMethod(typeof(ReturnValue),
        delegate ()
        {                
          return Spedmon.Practitioners.npiLookup(term, selectmode);                   
        },
        Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
     }

    /***************************************************************************
        * updatepatientparentmcalconsent */
    /**
        ***************************************************************************/
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord updateflagcurrentlywclient (
        string clientid
        , string pracid
        , string currentlywclient)
    {
        return (ReturnSaveRecord)
        callMethod(typeof(ReturnSaveRecord)
                    , delegate () {
                        return Spedmon.Practitioners.updateFlagCurrentlyWClient(
                        this.dbConnApp
                    , this.log
                    , this.uInfo
                    , clientid
                    , pracid
                    , currentlywclient);
                    }
        , Constants.ROLE_SBS_ALL_LEA_COORD);            
    }

    /***************************************************************************
    * cybhipracsprocessfile */
    /**
    * Process cybhi pracs file
    ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecordWithJSONData cybhipracsprocessfile (
          string clientid
        , string fileclass
        , string fromexternalsource
        , string filecontent
        , string validaterec )
    {
        return (ReturnSaveRecordWithJSONData)

        callMethod(typeof(ReturnSaveRecordWithJSONData),
        delegate ()
        {
          return Spedmon.Practitioners.cybhiPracsProcessFile(
            this.dbConnApp
          , this.log
          , this.uInfo
          , clientid
          , fileclass
          , fromexternalsource
          , filecontent
          , validaterec );
        },
        Constants.ROLE_SBS_ALL);  // Who can call this method           
    }


    }
}
