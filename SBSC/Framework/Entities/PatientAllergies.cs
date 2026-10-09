
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * PatientAllergy */
    /**
     * 
     *************************************************************************/

    public class PatientAllergy /*: Entity*/
    {
        public const string DEFAULT_PAGING_ORDER = @"isPriority desc, allergyName asc";

        public long    id;
        public long    clientID;
        public long    patID;
        public long    allergyID;
        public string  allergyName;
        public string  notes;
        public bool    isPriority;
    }

    /***************************************************************************
     * PatientAllergies */
    /**
     * 
     *************************************************************************/

    public class PatientAllergies : Entities
    {

        public const string URL_WEB_SERVICE   = @"patient_allergies.asmx";
        public const string URL_DELETE_INLINE = URL_WEB_SERVICE + @"/deleteinline";
        public const string URL_REST_VIEW     = "api/v1/patientallergies";
        public const string URL_SAVE          = @"user_all_patient_allergy_save.aspx";
        public const string SEL_LABEL         = @"Patient Allergy";
        public const string SEL_LABEL_ADD_NEW = SEL_LABEL + " - New";
        public const string SEL_LABEL_EDIT    = SEL_LABEL + " - Edit";

        public static string URL_SAVE_BASE (int saveType)
        {
            return MBA.HttpApplication.createLink ( URL_SAVE
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

        public static ReturnDB view (SqlConnection connSpedmon
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


            string viewUDF = " dbo.PATIENT_ALLERGIES_VIEW (@userID, @userGroup, @userRank, @clientID, @patID, @recID ,@canEdit,@active )";

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

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PatientAllergy.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(PatientAllergy)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return PatientAllergies.view(connSpedmon
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
              delegate { return PatientAllergies.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", clientID, patID, active, dc); });
        }

        /***************************************************************************
         * save */
        /**
         * 
         *************************************************************************/

        public static ReturnSaveRecord save (  SqlConnection connSpedmon
                                              , DetailsLog log
                                              , UserInfo uInfo
                                              , string clientID
                                              , string patID
                                              , string allergyID
                                              , string isPriority
                                              , string notes
                                              , string editDelReason
                                              , string validateRec
                                              , string saveType
                                              , string recID)
        {

            string saveSproc = @"PATIENT_ALLERGIES_SAVE";

            string dupRecMsg = @"Entry already exists";

            int vClientID    = Validate.reqClientID (uInfo,      clientID);
            int vPatID       = Validate.reqPatID    (uInfo,      patID);
            long vAllergyID  = Validate.reqInteger  (allergyID,  @"Please provide a valid allergy selection");
            bool vIsPriority = Validate.reqFlag     (isPriority, @"Invalid value for is priority",true);
            string vNotes    = Validate.optString   (notes,     Messages.INVALD_NOTES);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID",   SqlDbType.Int,     vClientID,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID",      SqlDbType.Int,     vPatID,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@allergyID",  SqlDbType.BigInt,  vAllergyID,  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@isPriority", SqlDbType.Bit,     vIsPriority, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@notes",      SqlDbType.VarChar, vNotes,      ParameterDirection.Input, -1));
            
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


            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "PATIENT_ALLERGIES_DELETE", ref parms);

        }

        /***************************************************************************
         * load */
        /**
         * 
         *************************************************************************/
        public static PatientAllergy load (
             SqlConnection connSpedmon
            , DetailsLog   log
            , UserInfo     uInfo
            , string       clientID
            , string       patID
            , string       recID )
        {
        return (PatientAllergy) Entities.load(connSpedmon, log, uInfo, recID, typeof(PatientAllergy),
        delegate {
            return PatientAllergies.view (
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
