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
     * PlanWriterPlansConditionsDiagnosisSvc*/
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

    public class PlanWriterDiagnosesSvc : MBA.WebSvc
    {

        /***************************************************************************
        * saveDiagnosis */
        /**
         * Save diagnosis records
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord saveDiagnosis(
             string clientid
           , string diagnosisName
           , string diagnosisDescription
           , string templatetype
           , string groupserviceclassnameid
           , string editDelReason
           , string validaterec
           , string savetype
           , string recid)
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.PlanWriterDiagnoses.saveDiagnosis(
              this.dbConnApp
            , this.log
            , this.uInfo
            , clientid
            , diagnosisName
            , diagnosisDescription
            , templatetype
            , groupserviceclassnameid
            , editDelReason
            , validaterec
            , savetype
            , recid);
            },
            Constants.ROLE_CARE_PLAN_WRITER);  // Who can call this method           
        }

        /***************************************************************************
         * viewSel */
        /**
         * Selection view 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSel(string clientid
                               , string recid
                               , string templatetype
                               , string groupserviceclassnameid
                               , string term )
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate ()
            {
                return Spedmon.PlanWriterDiagnoses.viewSel(dbConnApp
                                                                     , log
                                                                     , uInfo
                                                                     , false
                                                                     , ""
                                                                     , clientid
                                                                     , recid
                                                                     , groupserviceclassnameid
                                                                     , templatetype
                                                                     , term
                                                                     );

            },
            Constants.ROLE_CARE_PLAN_WRITER); // Who can call this method
        }

        /***************************************************************************
         * delete */
        /**
         * "Deletes" a diagnosis
         * 
         * @param  editDelReason   Reason for edit/delete 
         * @param  validateRec     Perform validation for this record?
         * @param  recID           Record id reference for edit and delete
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord delete(string editDelReason
                                         , string validaterec
                                         , string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord), delegate ()
            {
                return Spedmon.PlanWriterDiagnoses.delete(this.dbConnApp, log, uInfo, editDelReason, validaterec, recid);
            },
            Constants.ROLE_CARE_PLAN_WRITER);  // Who can call this method           
        }

    }
}
