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
     * PatientParentMcalConsentsSvc */
    /*
     * Web services end point 
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

   public class PatientParentMcalConsentsSvc : MBA.WebSvc
   {
     public PatientParentMcalConsentsSvc() : base() { }

    /***************************************************************************
     * updatepatientparentmcalconsent */
    /**
     ***************************************************************************/
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord updatepatientparentmcalconsent (
        string clientid
      , string patid
      , string consentbool
      , string effdate
      , string notes
      , string casemanager)
    {
      return (ReturnSaveRecord)
      callMethod (  typeof(ReturnSaveRecord)
                 , delegate () {
        return Spedmon.PatientParentMcalConsents.updatePatientParentMcalConsent (
            this.dbConnApp
          , this.log
          , this.uInfo
          , clientid
          , patid
          , consentbool
          , effdate
          , notes
          , casemanager);
      }
      , Constants.ROLE_SBS_ALL_LEA_COORD);  // Who can call this method           
    }

    /***************************************************************************
     * getclientmcalbillingdefaultconsentmsgtext */
    /**
     ***************************************************************************/
 
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnValue getclientmcalbillingdefaultconsentmsgtext (string clientid)
    {
      return (ReturnValue)

        callMethod( typeof(ReturnValue) 
                   , delegate () {
        return Spedmon.PatientParentMcalConsents.getClientMCALBillingDefaultConsentMsgText (
              this.dbConnApp
            , this.log
            , this.uInfo
            , clientid);
        }
        , Constants.ROLE_SBS_ALL_LEA_COORD);  // Who can call this method           
    }

    /***************************************************************************
     * setclientmcalbillingdefaultconsentmsgtext */
    /**
     ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSaveRecord setclientmcalbillingdefaultconsentmsgtext (string clientid, string msgtext)
    {
        return (ReturnSaveRecord)

        callMethod( typeof(ReturnSaveRecord) 
                   , delegate () {
        return Spedmon.PatientParentMcalConsents.setClientMCALBillingDefaultConsentMsgText (
              this.dbConnApp
            , this.log
            , this.uInfo
            , clientid
            , msgtext);
        }
        , Constants.ROLE_SBS_ALL_LEA_COORD);  // Who can call this method           
    }


        /*getClientMCALBillingDefaultConsentMsgText*/
    }
}
