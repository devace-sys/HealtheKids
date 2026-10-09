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
     * servicerecords.asmx */
    /*
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

    public class ServiceRecordsSvc : MBA.WebSvc
    {

        /***************************************************************************
         * delete */
        /**
         * "delete" a service record.
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
            delegate ()
            {
                return Spedmon.ServiceRecords.delete(this.dbConnApp,
                                           this.log,
                                           this.uInfo,
                                           editDelReason,
                                           validaterec,
                                           recid);
            },
              Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        /***************************************************************************
         * deleteBatch */
        /**
         * "delete" one or more service records.
         * 
         * @param  validaterec     Required, True=Yes, False=No
         * @param  editDelReason   Reason for delete
         * @param  recidmulti      One or more record ids to delete
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord deleteBatch(
                                      string editDelReason,
                                      string validaterec,
                                      string recidmulti)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {

                return Spedmon.ServiceRecords.deleteBatch(this.dbConnApp,
                                                    this.log,
                                                    this.uInfo,
                                                    editDelReason,
                                                    validaterec,
                                                    recidmulti);
            },
            Constants.ROLE_SBS_STAFF);  // Who can call this method           
        }



        /***************************************************************************
         * save */
        /**
         * Save new, edit, or delete a service record.
         * 
         * @param  clientid      Required, client id
         * @param  pracid        Required, practitoner id
         * @param  patid         Required, patient id
         * @param  dos           Required, date of service
         * @param  isiep         Required, is IEP or IFSP
         * @param  nameid        Required, name id of service
         * @param  nummin        Required for most time based services,
         *                       number of minutes
         * @param  trip1miles    Optional, number of miles for trip 1 for
         *                       transportation based services.
         * @param  trip2miles    Optional, number of miles for trip 2 for
         *                       transportation based services.
         * @param  trip3miles    Optional, number of miles for trip 3 for
         *                       transportation based services.
         * @param  trip4miles    Optional, number of miles for trip 4 for
         *                       transportation based services.
         * @param  notes         Record notes
         * @param  validaterec   Required, True=Yes, False=No
         * @param  savetype      Required, 1=New, 2=Edit, 3=Delete
         * @param  recid         Required for edit, delete.  Record id to edit
         *                       or delete
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord save(string reference,
                                      string clientid,
                                      string pracid,
                                      string patid,
                                      string ismultidos,
                                      string dos,
                                      string dosmulti,
                                      string isiep,
                                      string nameid,
                                      string hasOrpDocID,
                                      string orpDocID,
                                      string hasSvcDetFlags,
                                      string svcDetFlag1,
                                      string svcDetFlag2,
                                      string svcDetFlag3,
                                      string svcDetFlag4,
                                      string starttime,
                                      string nummin,
                                      string trip1start,
                                      string trip1end,
                                      string trip2start,
                                      string trip2end,
                                      string trip3start,
                                      string trip3end,
                                      string trip4start,
                                      string trip4end,
                                      string attendancestatus,
                                      string notes,
                                      string editDelReason,
                                      string validaterec,
                                      string savetype,
                                      string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
        // TODO: Remove these      
        string batchnum = "";
                string papclmnum = "";

                return Spedmon.ServiceRecords.save(this.dbConnApp,
                                           this.log,
                                           this.uInfo,
                                           reference,
                                           batchnum,
                                           papclmnum,
                                           ismultidos,
                                           dos,
                                           dosmulti,
                                           clientid,
                                           pracid,
                                           patid,
                                           isiep,
                                           nameid,
                                           hasOrpDocID,
                                           orpDocID,
                                           hasSvcDetFlags,
                                           svcDetFlag1,
                                           svcDetFlag2,
                                           svcDetFlag3,
                                           svcDetFlag4,
                                           starttime,
                                           nummin,
                                           trip1start,
                                           trip1end,
                                           trip2start,
                                           trip2end,
                                           trip3start,
                                           trip3end,
                                           trip4start,
                                           trip4end,
                                           attendancestatus,
                                           notes,
                                           editDelReason,
                                           validaterec,
                                           savetype,
                                           recid);
            },
              Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }


        /***************************************************************************
         * saveinline */
        /**
         * New save new, edit, or delete a service record.
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord saveinline(string reference
                                           , string clientid
                                           , string groupid
                                           , string pracid
                                           , string patid
                                           , string dos
                                           , string svcnameslistdatasourceid
                                           , string nameid
                                           //   , string hasOrpDocID
                                           //   , string orpDocID                                 
                                           , string hasSvcDetFlags
                                           , string svcDetFlag1
                                           , string svcDetFlag2
                                           , string svcDetFlag3
                                           , string svcDetFlag4
                                           , string starttime
                                           , string nummin
                                           //, string trip1start 
                                           //, string trip1end
                                           //, string trip2start 
                                           //, string trip2end
                                           //, string trip3start 
                                           //, string trip3end
                                           //, string trip4start 
                                           //, string trip4end
                                           , string attendancestatus
                                           , string notes
                                           , string svcNotesFormBuilderQuestionsJSON
                                           , string svcNotesFormBuilderAnswersJSON
                                           , string patientGoalProgressJSON
                                           , string hasPatientGoalTrackingData
                                           , string hasFillablePdfSelections
                                           , string fillablePdfSelectionsJSON
                                           , string fillablePdfAnswersJSON
                                           , string savetype
                                           , string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {

                return Spedmon.ServiceRecords.saveInline(
                                              this.dbConnApp
                                            , this.log
                                            , this.uInfo
                                            , reference
                                            , dos
                                            , clientid
                                            , groupid
                                            , pracid
                                            , patid
                                            , svcnameslistdatasourceid
                                            , nameid
                                            // , hasOrpDocID
                                            //, orpDocID
                                            , hasSvcDetFlags
                                            , svcDetFlag1
                                            , svcDetFlag2
                                            , svcDetFlag3
                                            , svcDetFlag4
                                            , starttime
                                            , nummin
                                            //, trip1start
                                            //, trip1end
                                            //, trip2start
                                            //, trip2end
                                            //, trip3start
                                            //, trip3end
                                            //, trip4start
                                            //, trip4end                                  
                                            , attendancestatus
                                            , notes
                                            , svcNotesFormBuilderQuestionsJSON
                                            , svcNotesFormBuilderAnswersJSON
                                            , patientGoalProgressJSON
                                            , hasPatientGoalTrackingData
                                            , hasFillablePdfSelections
                                            , fillablePdfSelectionsJSON
                                            , fillablePdfAnswersJSON
                                            , savetype
                                            , recid);
            },
              Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        /***************************************************************************
         * deleteinline */
        /**
         * Deletes svc rec
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord deleteinline(string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {

                return Spedmon.ServiceRecords.deleteInline(
                                            this.dbConnApp
                                          , this.log
                                          , this.uInfo
                                          , recid);
            }, Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           

        }


        /***************************************************************************
         * saveandrmtsmomentmatch */
        /**
         * Custom save new only method for rmts matching
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord saveandrmtsmomentmatch(string clientid
                                                        , string pracid
                                                        , string patid
                                                        , string dos
                                                        , string svcnameslistdatasourceid
                                                        , string nameid
                                                        , string hasOrpDocID
                                                        , string orpDocID
                                                        , string hasSvcDetFlags
                                                        , string svcDetFlag1
                                                        , string svcDetFlag2
                                                        , string svcDetFlag3
                                                        , string svcDetFlag4
                                                        , string starttime
                                                        , string nummin
                                                        , string attendancestatus
                                                        , string notes
                                                        , string svcNotesFormBuilderQuestionsJSON
                                                        , string svcNotesFormBuilderAnswersJSON
                                                        , string patientGoalProgressJSON
                                                        , string hasPatientGoalTrackingData
                                                        , string hasFillablePdfSelections
                                                        , string fillablePdfSelectionsJSON
                                                        , string fillablePdfAnswersJSON
                                                        , string rmtsmomentid
                                                        , string editDelReason
                                                        , string validaterec
                                                        , string savetype
                                                        , string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
              delegate ()
              {
                  return Spedmon.ServiceRecords.saveAndRmtsMomentMatch(
                                              this.dbConnApp
                                            , this.log
                                            , this.uInfo
                                            , ""
                                            , dos
                                            , clientid
                                            , pracid
                                            , patid
                                            , svcnameslistdatasourceid
                                            , nameid
                                            , hasOrpDocID
                                            , orpDocID
                                            , hasSvcDetFlags
                                            , svcDetFlag1
                                            , svcDetFlag2
                                            , svcDetFlag3
                                            , svcDetFlag4
                                            , starttime
                                            , nummin
                                            , attendancestatus
                                            , notes
                                            , svcNotesFormBuilderQuestionsJSON
                                            , svcNotesFormBuilderAnswersJSON
                                            , patientGoalProgressJSON
                                            , hasPatientGoalTrackingData
                                            , hasFillablePdfSelections
                                            , fillablePdfSelectionsJSON
                                            , fillablePdfAnswersJSON
                                            , rmtsmomentid
                                            , validaterec);
              },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        /***************************************************************************
         * flagexistingasrmtsmoment */
        /**
         * Flags an existing service record as an RMTS moment
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord flagexistingasrmtsmoment(string clientid
                                                          , string pracid
                                                          , string isrmtsmoment
                                                          , string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {

                return Spedmon.ServiceRecords.flagExistingAsRMTSMoment(
                                              this.dbConnApp
                                            , this.log
                                            , this.uInfo
                                            , clientid
                                            , pracid
                                            , isrmtsmoment
                                            , recid);
            },
              Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        /***************************************************************************
         * savebatch */
        /**
        * Save a batch of new service records.
        * 
        * @param  reference     Required, reference file name for batch
        * @param  clientid      Required, client id
        * @param  pracid        Required, practitoner id
        * @param  patid         Required, patient id
        * @param  dos           Required, date of service
        * @param  isiep         Required, is IEP or IFSP
        * @param  nameid        Required, name id of service
        * @param  details       Required, JSON string containing dos, 
        *                       minutes or miles, and notes for each service
        * @param  validaterec   Required, True=Yes, False=No
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord savebatch(string reference,
                                           string clientid,
                                           string pracid,
                                           string patid,
                                           string dossvcs,
                                           string isiep,
                                           string nameid,
                                           string hasOrpDocID,
                                           string orpDocID,
                                           string hasSvcDetFlags,
                                           string svcDetFlag1,
                                           string svcDetFlag2,
                                           string svcDetFlag3,
                                           string svcDetFlag4,
                                           string details,
                                           string validaterec)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.ServiceRecords.saveBatch(this.dbConnApp,
                                                 this.log,
                                                 this.uInfo,
                                                 reference,
                                                 clientid,
                                                 pracid,
                                                 dossvcs,
                                                 patid,
                                                 isiep,
                                                 nameid,
                                                 hasOrpDocID,
                                                 orpDocID,
                                                 hasSvcDetFlags,
                                                 svcDetFlag1,
                                                 svcDetFlag2,
                                                 svcDetFlag3,
                                                 svcDetFlag4,
                                                 details,
                                                 validaterec);
            },
              Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        /***************************************************************************
         * savebatchcaseloadorgroupservice */
        /**
        * Save a batch of new service records for a caseload or group
        * 
        * @param  reference     Required, reference file name for batch
        * @param  clientid      Required, client id
        * @param  pracid        Required, practitoner id
        * @param  patid         Required, patient id
        * @param  dos           Required, date of service
        * @param  isiep         Required, is IEP or IFSP
        * @param  nameid        Required, name id of service
        * @param  details       Required, JSON string containing dos, 
        *                       minutes or miles, and notes for each service
        * @param  validaterec   Required, True=Yes, False=No
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord savebatchcaseloadorgroupservice(string reference,
                                                                 string clientid,
                                                                 string pracid,
                                                                 string groupid,
                                                                 string entireCaseload,
                                                                 string serviceTypeID,
                                                                 string serviceProcCode,
                                                                 string serviceNameID,
                                                                 string isiep,
                                                                 string dos,
                                                                 string details,
                                                                 string validaterec)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.ServiceRecords.saveBatchCaseloadOrGroupService(this.dbConnApp,
                                                                       this.log,
                                                                       this.uInfo,
                                                                       reference,
                                                                       clientid,
                                                                       pracid,
                                                                       groupid,
                                                                       entireCaseload,
                                                                       serviceTypeID,
                                                                       serviceProcCode,
                                                                       serviceNameID,
                                                                       isiep,
                                                                       dos,
                                                                       details,
                                                                       validaterec);
            },
              Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        /***************************************************************************
         * savebatchmultiencounter */
        /**
         * Saves multiple dates multiple encounters
         *
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord savebatchmultiencounter(string reference
                                                         , string clientid
                                                         , string pracid
                                                         , string patid
                                                         , string dossvcs
                                                         , string isiep
                                                         , string nameid
                                                         , string hasOrpDocID
                                                         , string orpDocID
                                                         , string hasSvcDetFlags
                                                         , string svcDetFlag1
                                                         , string svcDetFlag2
                                                         , string svcDetFlag3
                                                         , string svcDetFlag4
                                                         , string details
                                                         , string validaterec)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.ServiceRecords.saveBatchMultiEncounter(this.dbConnApp
                                                                 , this.log
                                                                 , this.uInfo
                                                                 , reference
                                                                 , clientid
                                                                 , pracid
                                                                 , dossvcs
                                                                 , patid
                                                                 , isiep
                                                                 , nameid
                                                                 , hasOrpDocID
                                                                 , orpDocID
                                                                 , hasSvcDetFlags
                                                                 , svcDetFlag1
                                                                 , svcDetFlag2
                                                                 , svcDetFlag3
                                                                 , svcDetFlag4
                                                                 , details
                                                                 , validaterec);
            },

            Constants.ROLE_SBS_ALL);  // Who can call this method           
        }

        /***************************************************************************
        * savevisionandhearingservice */
        /**
        * Save a a service record for visiona and hearing
        * 
        * @param  reference        Required, reference file name
        * @param  clientid         Required, client id
        * @param  visionpracid     Required, practitoner id
        * @param  hearingpracid    Required, practitoner id
        * @param  patid            Required, patient id
        * @param  dos              Required, date of service
        * @param  nameid           Required, name id of service
        * @param  notes            notes for this service record
        * @param  validaterec      Required, True=Yes, False=No
        * @param  servicetypesjson Required, service types
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord savevisionandhearingservice(
              string reference
            , string clientid
            , string visionpracid
            , string hearingpracid
            , string patid
            , string dos
            , string servicetypesjson
            , string notes
            , string validaterec
        )
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.ServiceRecords.saveVisionAndHearingService(
                      this.dbConnApp
                    , this.log
                    , this.uInfo
                    , reference
                    , clientid
                    , visionpracid
                    , hearingpracid
                    , patid
                    , dos
                    , servicetypesjson
                    , notes
                    , validaterec
                );
            },
              Constants.ROLE_SVC_REC_VISION_HEARING_MASS_SCREEN);  // Who can call this method           
        }

        /***************************************************************************
        * savesvcrecsondos */
        /**
        * Saves service records either for scheduled dos or multi.
        * This is a practitioner only method right now
        * 
        * @param  clientid                 Required, client id
        * @param  dos                      Required, date of service
        * @param  validaterec              Required, True=Yes, False=No
        * @param  svcrecForDOSJSON Required, caseload objects
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord savesvcrecsondos(
              string clientid
            , string pracid
            , string dos
            , string svcetrmde
            , string svcrecForDOSJSON
            , string validaterec
        )
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.ServiceRecords.saveSvcRecsOnDOS(
                      this.dbConnApp
                    , this.log
                    , this.uInfo
                    , clientid
                    , pracid
                    , svcrecForDOSJSON
                    , validaterec
                    , svcetrmde
                );
            },
              Constants.ROLE_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC);  // Who can call this method           
        }

        /***************************************************************************
         * viewLastSvcNotesAsOfRefDateInfoTable */
        /**
         * QForms related the given clientID, pracID
         *
         * @param  clientID       Required, client ID
         * @param  pracID         Required, practitioner ID
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnInfoTable viewLastSvcNotesAsOfRefDateInfoTable(string clientid
                                                                     , string pracid
                                                                     , string patid
                                                                     , string refdate)
        {
            return (ReturnInfoTable)
            callMethod(typeof(ReturnInfoTable),
            delegate ()
            {
                ReturnInfoTable so = Spedmon.ServiceRecords.viewLastSvcNotesAsOfRefDateInfoTable(this.dbConnApp, this.log, this.uInfo, clientid, pracid, patid, refdate);
                return so;
            },
            Constants.ROLE_LEA_PROVIDER); // Who can call this method
        }

        /***************************************************************************
         * getStoredFileWorkFlowURL */
        /**
         * Gets the url that can be used to view a batch file
         *
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnValue getStoredFileWorkFlowURL(string batchid, string filereference)
        {
            return (ReturnValue)
            callMethod(typeof(ReturnValue),
            delegate ()
            {
                ReturnValue so = Spedmon.ServiceRecords.getStoredFileWorkFlowURL(batchid, filereference);
                return so;
            },
            Constants.ROLE_SBS_ALL_LEA_COORD_AND_ASSIST); // Who can call this method
        }

        /***************************************************************************
         * savesvcrecsbatchmultipracpatdossvc */
        /**
         * 
         *
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord savesvcrecsbatchmultipracpatdossvc (  string reference
                                                                    , string svcrecForDOSJSON
                                                                    , string svcetrmde
                                                                    , string validaterec)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.ServiceRecords.saveSvcRecsBatchMultiPracPatDosSvc (
                      this.dbConnUser
                    , this.dbConnApp
                    , this.log
                    , this.uInfo
                    , reference
                    , svcrecForDOSJSON
                    , svcetrmde
                    , validaterec                    
                );
            }, Constants.ROLE_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC);  // Who can call this method           
        }

        /***************************************************************************
         * savesvcrecsbatchpcalnontransport */
        /**
         * 
         *
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord savesvcrecsbatchpcalnontransport (  string reference
                                                                  , string svcrecForDOSJSON
                                                                  , string svcetrmde
                                                                  , string validaterec )
        {
           
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.ServiceRecords.saveSvcRecsBatchPcalNonTransport (                      
                      this.dbConnUser
                    , this.dbConnApp
                    , this.log
                    , this.uInfo
                    , reference
                    , svcrecForDOSJSON
                    , svcetrmde
                    , validaterec                    
                );
            }, Constants.ROLE_SBS_ALL);  // Who can call this method           
        }

    }
}
