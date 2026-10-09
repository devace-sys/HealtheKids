
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * PatientKnownHealthProblem */
    /**
     * 
     *************************************************************************/

    public class PatientKnownHealthProblem/*: Entity*/
    {
        public const string DEFAULT_PAGING_ORDER = @"isPriority desc, knownHealthProblemName asc";

        public long   id;
        public long   clientID;
        public long   patID;
        public long   knownHealthProblemID;
        public string knownHealthProblemName;
        public string notes;
        public bool   isPriority;
    }

    /***************************************************************************
     * PatientknownHealthProblems */
    /**
     * 
     *************************************************************************/

    public class PatientKnownHealthProblems : Entities
    {

        public const string URL_WEB_SERVICE   = @"patient_knownhealthproblems.asmx";
        public const string URL_DELETE_INLINE = URL_WEB_SERVICE + @"/deleteinline";
        public const string URL_REST_VIEW     = "api/v1/patientknownhealthproblems";
        public const string URL_SAVE          = @"/user_all_patient_known_health_problem_save.aspx";
        public const string SEL_LABEL         = @"Patient Known Health Problems";
        public const string SEL_LABEL_ADD_NEW = SEL_LABEL + " - New";
        public const string SEL_LABEL_EDIT    = SEL_LABEL + " - Edit";

        public static string URL_SAVE_BASE(int saveType)
        {
            return MBA.HttpApplication.createLink(URL_SAVE
                                                   , true
                                                   , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                   , new NameValue(Constants.PARM_SAVE_TYPE, saveType));


        }
        public static string URL_SAVE_NEW_BASE()
        {
            return URL_SAVE_BASE(Constants.SAVE_TYPE_NEW);

        }
        public static string URL_EDIT_BASE ()
        {
            return URL_SAVE_BASE(Constants.SAVE_TYPE_EDIT);
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
            int vPatID = Validate.reqPatID(uInfo, patID);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID", SqlDbType.Int, vPatID, ParameterDirection.Input));


            string viewUDF = " dbo.PATIENT_KNOWN_HEALTH_PROBLEMS_VIEW(@userID, @userGroup, @userRank, @clientID, @patID, @recID,@canEdit,@active )";

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

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PatientKnownHealthProblem.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(PatientKnownHealthProblem)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return PatientKnownHealthProblems.view(connSpedmon
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
              delegate { return PatientKnownHealthProblems.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", clientID, patID, active, dc); });
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
                                              , string knownHealthProblemID
                                              , string isPriority
                                              , string notes
                                              , string editDelReason
                                              , string validateRec
                                              , string saveType
                                              , string recID)
        {

            string saveSproc = @"PATIENT_KNOWN_HEALTH_PROBLEMS_SAVE";

            string dupRecMsg = @"Entry already exists";

            int vClientID              = Validate.reqClientID(uInfo, clientID);
            int vPatID                 = Validate.reqPatID(uInfo, patID);
            long vKnownHealthProblemID = Validate.reqInteger(knownHealthProblemID, @"Please provide a valid known health issue selection");
            bool vIsPriority           = Validate.reqFlag(isPriority, @"Invalid value for is priority", true);
            string vNotes              = Validate.optString(notes, Messages.INVALD_NOTES);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID",             SqlDbType.BigInt, vClientID,             ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID",                SqlDbType.BigInt, vPatID,                ParameterDirection.Input));
            parms.Add(Database.SqlParm("@knownHealthProblemID", SqlDbType.BigInt, vKnownHealthProblemID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@isPriority",           SqlDbType.Bit, vIsPriority,              ParameterDirection.Input));
            parms.Add(Database.SqlParm("@notes",                SqlDbType.VarChar, vNotes,               ParameterDirection.Input, -1));

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
        }

        /***************************************************************************
        * delete */
        /**
        * 
        *************************************************************************/

        public static ReturnSaveRecord delete(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                           string editDelReason, string validateRec, string recID)
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

            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

            /*----------------------------
             * Call base method 
             *----------------------------*/

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "PATIENT_KNOWN_HEALTH_PROBLEMS_DELETE", ref parms);
        }

        /***************************************************************************
         * load */
        /**
         * 
         *************************************************************************/
        public static PatientKnownHealthProblem load(
             SqlConnection connSpedmon
            , DetailsLog log
            , UserInfo uInfo
            , string clientID
            , string patID
            , string recID)
        {
            return (PatientKnownHealthProblem)Entities.load(connSpedmon, log, uInfo, recID, typeof(PatientKnownHealthProblem),
            delegate {
                return PatientKnownHealthProblems.view(
                    connSpedmon
                    , log
                    , uInfo
                    , Entities.REC_VIEW_LOAD
                    , false
                    , recID
                    , ""
                    , clientID
                    , patID
                    , @"Y"
                    , null);
            });
        }
    }

}
