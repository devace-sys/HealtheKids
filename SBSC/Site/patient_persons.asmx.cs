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
     * PatientPersonsSvc */
    /*
     * Web services end points
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

    public class PatientPersonsSvc : MBA.WebSvc
    {

        /***************************************************************************
         * delete */
        /**
         * "delete" a patient contact record.
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
                                      string clientid,
                                      string patientid,
                                      string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.PatientPersons.delete(this.dbConnApp,
                                           this.log,
                                           this.uInfo,
                                           editDelReason,
                                           validaterec,
                                           clientid,
                                           patientid,
                                           recid);
            },
              Constants.ROLE_SBS_ALL);  // Who can call this method           
        }

        /***************************************************************************
         * deleteinline */
        /**
         * "delete" a patient contact record.
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord deleteinline(string clientid
                                             , string patid
                                             , string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.PatientPersons.delete(this.dbConnApp
                                              , this.log
                                              , this.uInfo
                                              , @"" /*editDelReason*/
                                              , @"N" /*validaterec*/
                                              , clientid
                                              , patid
                                              , recid);
            },
              Constants.ROLE_SBS_ALL);  // Who can call this method           
        }

        /***************************************************************************
         * save */
        /**
         * Save 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord save(string clientid
                                      , string patientid
                                                      , string personroleid
                                                    , string personrelationshipid
                                      , string lastname
                                                      , string firstname
                                                      , string middlename
                                                      , string phone
                                                      , string fax
                                                      , string email
                                      , string address1
                                      , string address2
                                      , string city
                                      , string state
                                      , string zip5
                                      , string zip4
                                                      , string additionaldata1
                                      , string additionaldata2
                                                      , string editDelReason
                                      , string validaterec
                                      , string savetype
                                      , string recid)
        {
            return (ReturnSaveRecord)

            callMethod(
              typeof(ReturnSaveRecord)
            , delegate ()
            {
                return Spedmon.PatientPersons.save(dbConnApp
                                               , log
                                               , uInfo
                                               , clientid
                                               , patientid
                                                               , personroleid
                                                             , personrelationshipid
                                               , lastname
                                                               , firstname
                                                               , middlename
                                                               , phone
                                                               , fax
                                                               , email
                                               , address1
                                               , address2
                                               , city
                                               , state
                                               , zip5
                                               , zip4
                                                               , additionaldata1
                                               , additionaldata2
                                                               , editDelReason
                                               , validaterec
                                               , savetype
                                               , recid);
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        /***************************************************************************
          * saveinline */
        /**
         * Save 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord saveinline(string clientid
                                            , string patid
                                            , string personroleid
                                            , string personrelationshipid
                                            , string lastname
                                            , string firstname
                                            , string middlename
                                            , string phone
                                            , string fax
                                            , string email
                                            , string address1
                                            , string address2
                                            , string city
                                            , string state
                                            , string zip5
                                            , string zip4
                                            , string additionaldata1
                                            , string additionaldata2
                                            , string savetype
                                            , string recid)
        {
            return (ReturnSaveRecord)

            callMethod(
              typeof(ReturnSaveRecord)
            , delegate ()
            {
                return Spedmon.PatientPersons.save(dbConnApp
                                               , log
                                               , uInfo
                                               , clientid
                                               , patid
                                               , personroleid
                                               , personrelationshipid
                                               , lastname
                                               , firstname
                                               , middlename
                                               , phone
                                               , fax
                                               , email
                                               , address1
                                               , address2
                                               , city
                                               , state
                                               , zip5
                                               , zip4
                                               , additionaldata1
                                               , additionaldata2
                                               , @"" /*editDelReason*/
                                               , @"N" /*validaterec*/
                                               , savetype
                                               , recid);
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        /***************************************************************************
         * saveContact */
        /**
         * Same as save but with address completion 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord saveContact(string clientid
                                      , string patientid
                                                      , string personroleid
                                                    , string personrelationshipid
                                      , string lastname
                                                      , string firstname
                                                      , string middlename
                                                      , string phone
                                                      , string fax
                                                      , string email
                                      , string street1
                                      , string street2
                                      , string city
                                      , string state
                                      , string zip5
                                      , string zip4
                                                      , string additionaldata1
                                      , string additionaldata2
                                                      , string editDelReason
                                      , string validaterec
                                      , string savetype
                                      , string recid)
        {
            return (ReturnSaveRecord)

            callMethod(
              typeof(ReturnSaveRecord)
            , delegate ()
            {
                return Spedmon.PatientPersons.save(dbConnApp
                                               , log
                                               , uInfo
                                               , clientid
                                               , patientid
                                                               , personroleid
                                                             , personrelationshipid
                                               , lastname
                                                               , firstname
                                                               , middlename
                                                               , phone
                                                               , fax
                                                               , email
                                               , street1
                                               , street2
                                               , city
                                               , state
                                               , zip5
                                               , zip4
                                                               , additionaldata1
                                               , additionaldata2
                                                               , editDelReason
                                               , validaterec
                                               , savetype
                                               , recid);
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }


        /***************************************************************************
         * viewSel */
        /**
         * Selection view 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSel(string clientid
                                  , string patientid
                                  , string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate ()
            {
                return Spedmon.PatientPersons.viewSel(dbConnApp
                                                 , log
                                                 , uInfo
                                                 , false
                                                 , ""
                                                 , clientid
                                                 , patientid
                                                 , term);
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
        }

        /***************************************************************************
         * viewSelParents */
        /**
         * Selection view 
         ***************************************************************************/
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSel viewSelParentsGuardiansOnly(string clientid
                                                        , string patid
                                                        , string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate ()
            {
                return Spedmon.PatientPersons.viewSelParentsGuardiansOnly(dbConnApp
                                                 , log
                                                 , uInfo
                                                 , false
                                                 , ""
                                                 , clientid
                                                 , patid
                                                 , term);
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
        }

        /***************************************************************************
         * getPatientPerson */
        /**
         * Returns PatientPerson data
         *
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnPatientPerson getPatientPerson(string clientid, string patid, string personid)
        {
            return (ReturnPatientPerson)
            callMethod(typeof(ReturnPatientPerson),
            delegate ()
            {
                ReturnPatientPerson so = Spedmon.PatientPersons.getPatientPerson(this.dbConnApp, this.log, this.uInfo, clientid, patid, personid);
                return so;
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
        }

        /***************************************************************************
        * inviteParentGuardianPortal */
        /**
         * create a new invitation to a parent/patient portal
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord inviteParentGuardianPortal(string clientid
                                                             , string patid
                                                             , string recid)
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.PatientPersons.inviteParentGuardianPortal(this.dbConnApp
                                                                        , this.log
                                                                        , this.uInfo
                                                                        , clientid
                                                                        , patid
                                                                        , ""
                                                                        , "false"
                                                                        , "1"
                                                                        , recid);
            },
                                                                        Constants.ROLE_ALL_PCAL_AND_CLIENT);
        }
    }
}
