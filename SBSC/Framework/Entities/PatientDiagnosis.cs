
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * PatientDiagnosis */
    /**
     * 
     *************************************************************************/

    public class PatientDiagnosis /*: Entity*/
    {
        public const string DEFAULT_PAGING_ORDER = @"diagnosisName asc"; 

        public long   id;
        public long   clientID;
        public long   patID;
        public long   diagnosisID;
        public string diagnosisName;
        public string icd10CMCodeName;
        public string icd10CMCode;
    }

    /***************************************************************************
     * PatientDiagnoses */
    /**
     * 
     *************************************************************************/

    public class PatientDiagnoses : Entities
    {

        public const string URL_WEB_SERVICE   = @"patient_diagnoses.asmx";
        public const string URL_SAVE_INLINE   = URL_WEB_SERVICE + @"/saveinline";
        public const string URL_DELETE_INLINE = URL_WEB_SERVICE + @"/deleteinline";
        public const string URL_REST_VIEW     = "api/v1/patientdiagnoses";

        public static string URL_SAVE_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_SAVE_INLINE, true);
        }
        public static string URL_DELETE_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_DELETE_INLINE, true);
        }

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(URL_REST_VIEW, true);
        }

        /***************************************************************************
         * view */
        /**
         * 
         *************************************************************************/

        public static ReturnDB view(SqlConnection connSpedmon
                                      , DetailsLog log
                                      , UserInfo uInfo
                                      , int recViewType
                                      , bool pagedOrTop
                                      , string idx
                                      , string canEdit
                                      , string clientID
                                      , string patID
                                      , string active
                                      , defineCols dc)
        {

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            int vClientID = Validate.reqClientID(uInfo, clientID);
            int vPatID    = Validate.reqPatID(uInfo, patID);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID", SqlDbType.BigInt, vPatID, ParameterDirection.Input));


            string viewUDF = " dbo.PATIENT_DIAGNOSES_VIEW (@userID, @userGroup, @userRank, @clientID, @patID, @recID,@canEdit,@active )";

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        /***************************************************************************
         * viewObjects */
        /**
         * 
         *************************************************************************/

        public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                  , DetailsLog log
                                                  , UserInfo uInfo
                                                  , bool pageObjectList
                                                  , string pageOrder
                                                  , string idx
                                                  , string active
                                                  , string clientID
                                                  , string patID)
        {

            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PatientDiagnosis.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(PatientDiagnosis)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return PatientDiagnoses.view(connSpedmon
                                                                                    , log
                                                                                    , uInfo
                                                                                    , Entities.REC_VIEW_OBJECTS
                                                                                    , pageObjectList
                                                                                    , idx
                                                                                    , "" /*canEdit*/
                                                                                    , clientID
                                                                                    , patID
                                                                                    , active
                                                                                    , dc);
                                          });

        }

        /***************************************************************************
          * viewTbl */
        /**
         * Returns a data table of records for preview or record selection.
         * 
         * @return                 ReturnDataTable
         ***************************************************************************/

        public static ReturnDataTable viewTbl(SqlConnection connSpedmon
                                                 , DetailsLog log
                                                 , UserInfo uInfo
                                                 , bool paged
                                                 , string pageNumber
                                                 , string clientID
                                                 , string patID
                                                 , string active)
        {
            ReturnDataTable so = new ReturnDataTable();
            string tableName = ORPDocuments.SEL_LABEL;

            /*###########################################################################
              # Define our display columns and set the page order.  Page order needs to
              # be in the same sort order as the udf called in the view.
              ###########################################################################*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("id");
                ss.addDisplayColumn("diagnosisID              as [Diagnosis ID]", true);
                ss.addDisplayColumn("diagnosisName            as [Diagnosis\nName]", true);
                ss.addDisplayColumn("icd10CMCodeName          as [Code\nName]", true);
                ss.addDisplayColumn("icd10CMCode              as [Code]");
                pageroworder = ss.pageRowOrder();
            };

            /*###########################################################################
              # Call the base method which handles the rest and returns a ReturnDataTable
              ###########################################################################*/

            so = Entities.viewTbl(connSpedmon
                           , log
                           , uInfo
                           , paged
                           , pageNumber
                           , delegate { return
                                PatientDiagnoses.view(connSpedmon
                                                   , log
                                                   , uInfo
                                                   , Entities.REC_VIEW_TBL
                                                   , paged
                                                   , pageNumber
                                                   , ""
                                                   , clientID
                                                   , patID
                                                   , active
                                                   , dc);
                                       });

            /*###########################################################################
              # Add a title and footer to ReturnDataTable then return
              ###########################################################################*/

            so.tableName = tableName;
            so.tableFooter = Messages.CONFIDENTIAL;

            return so;
        }

        /***************************************************************************
         * viewSel */
        /**
         * 
         ***************************************************************************/

        public static ReturnSel viewSel(SqlConnection connSpedmon
                                         , DetailsLog log
                                         , UserInfo uInfo
                                         , bool paged
                                         , string pageNumber
                                         , string active
                                         , string clientID
                                         , string patID
                                         )
        {
            /*----------------------------
             * Define our context column
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
            };

            return Entities.viewSel(connSpedmon, log, uInfo, paged, pageNumber,
              delegate { return PatientDiagnoses.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", clientID, patID, active, dc); });
        }

        /***************************************************************************
         * save */
        /**
         * 
         *************************************************************************/

        public static ReturnSaveRecord save(SqlConnection connSpedmon
                                              , DetailsLog log
                                              , UserInfo uInfo
                                              , string clientID
                                              , string patID
                                              , string diagnosisID
                                              , string editDelReason
                                              , string validateRec
                                              , string saveType
                                              , string recID)
        {

            string saveSproc = @"PATIENT_DIAGNOSES_SAVE";

            string dupRecMsg = @"Entry already exists";

            int vClientID     = Validate.reqClientID(uInfo, clientID);
            int vPatID        = Validate.reqPatID(uInfo, patID);
            long vDiagnosisID = Validate.reqInteger(diagnosisID, @"Please provide a valid diagnosis selection");

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID",    SqlDbType.Int, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID",       SqlDbType.Int, vPatID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@diagnosisID", SqlDbType.BigInt, vDiagnosisID, ParameterDirection.Input));

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
        }

        /***************************************************************************
         * delete */
        /**
         * 
         *************************************************************************/

        public static ReturnSaveRecord delete (
             SqlConnection connSpedmon
            , DetailsLog   log
            , UserInfo     uInfo
            , string       editDelReason
            , string       validateRec
            , string       recID )
        {

            /*----------------------------
             * Check for required and 
             * optional parameters
             * and validate data integrity
             * of all supplied parameters
             *----------------------------*/

            Object vClientID = Validate.optClientID(uInfo, "");

            /*----------------------------
             * Collect all of the parameters
             * that are specific to this
             * delete method.
             *----------------------------*/

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

            /*----------------------------
             * Call base method 
             *----------------------------*/

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "PATIENT_DIAGNOSES_DELETE", ref parms);
        }
    }

}
