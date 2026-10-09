using MBA;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;

namespace Spedmon
{
    public class CrcsTransportationOtherCost : Entity
    {
        public const string DEFAULT_PAGING_ORDER = @"displayOrder asc";

        public long    clientID;
        public long    fiscalYearID;
        public string  description;
        public decimal grossCosts;
        public decimal grossRatio;
        public string  grossRatioStr;
        public decimal expenditures;
        public decimal expendituresRatio;
        public string  expendituresRatioStr;
        public bool    deferred;
        public int     displayOrder;
    }

    public class CrcsTransportationOtherCosts : Entities
    {
        public const string URL_MANAGE      = @"user_all_crcs_transportation_other_costs_manage.aspx";

        public const string URL_WEB_SERVICE = @"crcs_transportation_other_costs.asmx";
        public const string URL_SAVE        = URL_WEB_SERVICE + @"/save";
        public const string URL_DELETE      = URL_WEB_SERVICE + @"/delete";
        public const string URL_DEFER       = URL_WEB_SERVICE + @"/defer";

        public const string URL_REST_VIEW   = @"api/v1/crcstransportationothercosts";

        /***************************************************************************
         * URL_REST_VIEW */
        /**
         * 
         **************************************************************************/

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsTransportationOtherCosts.URL_REST_VIEW, true);
        }

        /***************************************************************************
         * URL_MANAGE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_MANAGE_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsTransportationOtherCosts.URL_MANAGE, true);
        }

        /***************************************************************************
         * URL_SAVE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_SAVE_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsTransportationOtherCosts.URL_SAVE, true);
        }

        /***************************************************************************
         * URL_DELETE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_DELETE_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsTransportationOtherCosts.URL_DELETE, true);
        }

        /***************************************************************************
         * URL_SERVICE_DEFER_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_DEFER_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsTransportationOtherCosts.URL_DEFER, true);
        }

        /***************************************************************************
         * view */
        /**
         * 
         ***************************************************************************/

        public static ReturnDB view(SqlConnection connSpedmon
                                     , DetailsLog log
                                     , UserInfo uInfo
                                     , int recViewType
                                     , bool pagedOrTop
                                     , string idx
                                     , string canEdit
                                     , string active
                                     , string clientID
                                     , string fiscalYearID
                                     , defineCols dc)
        {

            string viewUDF = "dbo.CRCS_TRANSPORTATION_OTHER_COSTS_VIEW (@userID, @userGroup, @userRank, @clientID, @fiscalYearID, @active, @recID)";

            /*----------------------------
            * Validate parameters specific
            * to this entity.view
            * and populate their
            * coresponding database
            * parameters
            *----------------------------*/

            var vClientID = Validate.optClientID(uInfo, clientID);
            var vFiscalYearID = Validate.optInteger(fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fiscalYearID", SqlDbType.BigInt, vFiscalYearID, ParameterDirection.Input));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        /***************************************************************************
         * save */
        /**
         * 
         ***************************************************************************/

        public static Return save(SqlConnection dbConnSpedmon
                                , DetailsLog log
                                , UserInfo uInfo
                                , string clientID
                                , string fiscalYearID
                                , string grossCosts 
                                , string expenditures
                                , string editDelReason
                                , string validateRec
                                , string saveType
                                , string recID)
        {
            string saveSproc = @"CRCS_TRANSPORTATION_OTHER_COSTS_SAVE";
            string dupRecMsg = @"Record already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vClientID     = Validate.reqClientID (uInfo       , clientID);
            var vFiscalYearID = Validate.reqInteger  (fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);
            var vGrossCosts   = Validate.optUsdAmount(grossCosts  , Messages.INVALID_DOLLAR_AMT);
            var vExpenditures = Validate.optUsdAmount(expenditures, Messages.INVALID_DOLLAR_AMT);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"    , SqlDbType.BigInt  , vClientID          , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fiscalYearID", SqlDbType.BigInt  , vFiscalYearID      , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@grossCosts"  , SqlDbType.Money   , vGrossCosts        , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@expenditures", SqlDbType.Money   , vExpenditures      , ParameterDirection.Input));


            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.save(dbConnSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
        }


        /***************************************************************************
         * viewObjects 
         *
         * Returns a list of objects
         * 
         ***************************************************************************/

        public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                  , DetailsLog log
                                                  , UserInfo uInfo
                                                  , bool pageObjectList
                                                  , string pageOrder
                                                  , string idx
                                                  , string active
                                                  , string clientID
                                                  , string fiscalYearID
        )
        {

            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = CrcsTransportationOtherCost.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(CrcsTransportationOtherCost)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return CrcsTransportationOtherCosts.view(
                                                                         connSpedmon
                                                                       , log
                                                                       , uInfo
                                                                       , Entities.REC_VIEW_OBJECTS
                                                                       , pageObjectList
                                                                       , idx
                                                                       , "" // canEdit
                                                                       , active
                                                                       , clientID
                                                                       , fiscalYearID
                                                                       , dc
                                               );
                                          });
        }

        /***************************************************************************
        * delete */
        /**
         *
         ***************************************************************************/

        public static ReturnSaveRecord delete(SqlConnection connSpedmon
                                               , DetailsLog log
                                               , UserInfo uInfo
                                               , string editDelReason
                                               , string validateRec
                                               , string recID)
        {

            string deleteSproc = @"CRCS_TRANSPORTATION_OTHER_COSTS_DELETE";

            /*###########################################################################
              # Validate parameters specific to this entity delete and create their 
              # database parameters.
              ###########################################################################*/

            var vClientID = Validate.optClientID(uInfo, "");

            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, deleteSproc, ref parms);
        }

        /***************************************************************************
        * defer */
        /**
         *
         ***************************************************************************/
        public static Return defer(SqlConnection dbConnSpedmon
                                , DetailsLog log
                                , UserInfo uInfo
                                , string deferred
                                , string recID)
        {
            string sprocName = @"CRCS_TRANSPORTATION_OTHER_COSTS_DEFER";
            string dupRecMsg = @"Record already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vDeferred = Validate.reqFlag     (deferred , Messages.INVALID_FLAG);

            List<SqlParameter> parms = new List<SqlParameter>();
                  
            parms.Add(Database.SqlParm("@deferred"               , SqlDbType.Bit     , vDeferred                , ParameterDirection.Input));                       

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.save(dbConnSpedmon, log, uInfo, Constants.SAVE_TYPE_EDIT.ToString(), "0", "", recID, sprocName, dupRecMsg, ref parms, null);
        }

    }
}
