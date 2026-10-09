using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * TeleCommIEPType  */
    /**
     *
     ***************************************************************************/

    public class TeleCommIEPType : Entity
    {
        public string formName;
        public string formsHTML;
        public string formsJSON;
    }

    /***************************************************************************
     * TeleCommIEPTypes  */
    /**
     *
     ***************************************************************************/

    public class TeleCommIEPTypes : Entities
    {
        public const string SEL_LABEL_MANAGE_IEP = @"Manage HYQueue IEP Meetings";
        public const string MENU_LINK_MANAGE    = @"telecommieptypesmanagelink";
        public static string SEL_LABEL_MANAGE   = @"Manage Telecomm IEP Types";
        public static string SEL_LABEL_ADD_NEW  = @"Add New IEP Form Type";
        public static string URL_SBS_ALL_MANAGE = @"sbs_all_telecomm_iep_types_manage.aspx";
        public static string URL_SBS_ALL_SAVE   = @"sbs_all_telecomm_iep_types_save.aspx";

        /***************************************************************************
        * view */
        /**
         *
         **************************************************************************/
        public static ReturnDB view  (  SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , int           recViewType
                                      , bool          pagedOrTop
                                      , string        idx
                                      , string        canEdit
                                      , string        active
                                      , string        term
                                      , defineCols    dc )
        {

            string viewUDF = @"dbo.TELECOMM_IEP_TYPES_VIEW (@userID, @userGroup, @userRank, @term, @recID, @canEdit, @active)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

            string vTerm = Validate.optString(term, @"Invalid search term");

            parms.Add(Database.SqlParm("@term", SqlDbType.VarChar, vTerm, ParameterDirection.Input, 256));

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/


            return Entities.view (  connSpedmon
                                  , log
                                  , uInfo
                                  , recViewType
                                  , pagedOrTop
                                  , idx
                                  , canEdit
                                  , active
                                  , viewUDF
                                  , ref parms
                                  , null
                                  , dc );
        }

        /***************************************************************************
        * viewSel */
        /**
         * Returns a data table of records for preview or record selection.
         *
         * @return                 ReturnDataTable
         ***************************************************************************/

        public static ReturnSel viewSel(SqlConnection connSpedmon
                                          , DetailsLog log
                                          , UserInfo uInfo
                                          , bool top
                                          , string topSize
                                          , string term)
        {

            /*----------------------------
             * Define our context column
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                //ss.addDisplayColumn("id as ID");
                //ss.addDisplayColumn("name as Name");
                //ss.addDisplayColumn("formsHTML as HTML");
                //ss.addDisplayColumn("formsJSON as JSON");
            };

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.viewSel(connSpedmon
                                    , log
                                    , uInfo
                                    , top
                                    , topSize
                                    , delegate {
                                        return TeleCommIEPTypes.view(connSpedmon
                                                                       , log
                                                                       , uInfo
                                                                       , Entities.REC_VIEW_SEL
                                                                       , top
                                                                       , topSize
                                                                       , ""
                                                                       , "Y"
                                                                       , term
                                                                       , dc);
                                    });

        }

        /***************************************************************************
         * viewTbl */
        /**
         * View Table * 
         * @return             ReturnDataTables
         ***************************************************************************/

        public static ReturnDataTable viewTbl  (  SqlConnection connSpedmon
                                                , DetailsLog    log
                                                , UserInfo      uInfo
                                                , bool          paged
                                                , string        pageNumber
                                                , string        canEdit
                                                , string        active
                                                , string        term
                                               )
        {
            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("id");
                ss.addDisplayColumn("formName as [Form Name]", true);
                //ss.addDisplayColumn("formsHTML as HTML", true);
                //ss.addDisplayColumn("formsJSON as JSON", true);

                pageroworder = ss.pageRowOrder();  
            };

            return Entities.viewTbl(connSpedmon
                                   , log
                                   , uInfo
                                   , paged
                                   , pageNumber
                                   , delegate
                                   {
                                       return TeleCommIEPTypes.view(connSpedmon
                                                                       , log
                                                                       , uInfo
                                                                       , Entities.REC_VIEW_TBL
                                                                       , paged
                                                                       , pageNumber
                                                                       , canEdit
                                                                       , active
                                                                       , term
                                                                       , dc);
                                   }
                                  , @"Telecomm IEP Types - View"
                                  , Messages.CONFIDENTIAL
              );
        }

        /***************************************************************************
            * load */
        /**
            * Outputs data for a single record
            *
            * Note: This calls the view method and the view method takes care of
            * enforcing the client id.
            *
            * @param  connSpedmon     Spedmon database connection object
            * @param  log             Logging object
            * @param  uInfo           User Info
            * @param  recID             Record ID
            * @return                 ReturnEntity
            ***************************************************************************/

        public static TeleCommIEPType load(SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo uInfo
                                                , string recID)
        {
            return (TeleCommIEPType)Entities.load(connSpedmon
                                                         , log
                                                         , uInfo
                                                         , recID
                                                         , typeof(TeleCommIEPType)
                                                         , delegate {
                                                             return TeleCommIEPTypes.view(connSpedmon
                                                                                          , log
                                                                                          , uInfo
                                                                                          , Entities.REC_VIEW_LOAD
                                                                                          , false
                                                                                          , recID
                                                                                          , ""
                                                                                          , ""
                                                                                          , ""
                                                                                          , null);
                                                         });
        }

        /***************************************************************************
        * delete */
        /**
         * "Deletes" a telecomm IEP type record
         * 
         * @param  editDelReason   Reason for edit/delete 
         * @param  validateRec     Perform validation for this record?
         * @param  recID           Record id reference for edit and delete
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/

        public static ReturnSaveRecord delete(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                               string editDelReason, string validateRec,
                                               string recID)
        {

            /*----------------------------
             * Check for required and 
             * optional parameters
             * and validate data integrity
             * of all supplied parameters
             *----------------------------*/

            /*----------------------------
             * Collect all of the parameters
             * that are specific to this
             * delete method.
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

            /*----------------------------
             * Call base method 
             *----------------------------*/

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "TELECOMM_IEP_TYPES_Delete", ref parms);
        }

        /***************************************************************************
        * save */
        /**
        * Save a telecomm IEP type record
        *
        * @param  userID          User id of who is recording service
        * @param  userGroup       1 = Client, 2 = SBSC (from users db)
        * @param  userRank        Users role ranking
        * @name                   name of the Telecomm IEP type
        * @formsHTML              HTML data of the Telecomm IEP type
        * @formsJSON              JSON data of the Telecomm IEP type
        * @active                 active bit of the Telecomm IEP type
        * @param  editDelReason   Reason for record edit or delete
        * @param  validateRec     1 = Performs data integrity validation tasks
        *                             Perform advisory validation tasks that can
        *                             only be conducted by referencing data from the
        *                             database and then exits WITHOUT saving the record
        *                         0 = Peform data integrity validation tasks and
        *                             if these tasks succeed peforms the desired
        *                             operation (saveType) on the record and exits
        * @param  saveType        Type of operation to perform
        *                         1 = New, 2 = Edit, 3 = Delete
        * @param  recID           Record id of existing record to edit or delete.
        * @return                 ReturnSaveNewRecord
        ***************************************************************************/

        public static ReturnSaveRecord save(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,

                                             string name,
                                             string formsHTML,
                                             string formsJSON,

                                             string editDelReason,
                                             string validateRec,
                                             string saveType,
                                             string recID)
        {



            /*----------------------------
             * Validate parameters specific
             * to this entity.save
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();


            string vName        = Validate.reqString(name, @"Invalid name for telecomm IEP type");      // Maybe move this validation string to Constants class
            string vFormsHTML   = Validate.reqString(formsHTML, @"Invalid HTML for telecomm IEP type"); // Maybe move this validation string to Constants class
            string vFormsJSON   = Validate.reqString(formsJSON, @"Invalid JSON for telecomm IEP type"); // Maybe move this validation string to Constants class


            parms.Add(Database.SqlParm("@name"     , SqlDbType.VarChar, vName,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@formsHTML", SqlDbType.VarChar, vFormsHTML, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@formsJSON", SqlDbType.VarChar, vFormsJSON, ParameterDirection.Input));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "TELECOMM_IEP_TYPES_Save", @"Duplicate Telecomm IEP type!", ref parms, null);

        }
    }
}
