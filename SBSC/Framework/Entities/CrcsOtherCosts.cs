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
    public class CrcsOtherCost : Entity
    {
        public const string DEFAULT_PAGING_ORDER = @"grpSvcClassName asc";

        public long    clientID;
        public long    grpSvcClassNameID;
        public long    fiscalYearID;
        public string  grpSvcClassName;
        public decimal materialsAndSupplies;
        public decimal nonCapitalizedEquipment;
        public decimal travelAndConference;
        public decimal duesAndMembership;
        public decimal communications;
        public decimal otherFederalCosts;
        public string  federalResourceCodes;
        public bool    deferred;
    }

    public class CrcsOtherCosts : Entities
    {
        public const string URL_MANAGE      = @"user_all_crcs_other_costs_manage.aspx";

        public const string URL_WEB_SERVICE = @"crcs_other_costs.asmx";
        public const string URL_SAVE        = URL_WEB_SERVICE + @"/save";
        public const string URL_DEFER       = URL_WEB_SERVICE + @"/defer";

        public const string URL_REST_VIEW    = @"api/v1/crcsothercosts";

        /***************************************************************************
         * URL_REST_VIEW */
        /**
         * 
         **************************************************************************/

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsOtherCosts.URL_REST_VIEW, true);
        }

        /***************************************************************************
         * URL_MANAGE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_MANAGE_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsOtherCosts.URL_MANAGE, true);
        }

        /***************************************************************************
         * URL_SAVE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_SAVE_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsOtherCosts.URL_SAVE, true);
        }

        /***************************************************************************
         * URL_SERVICE_DEFER_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_DEFER_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsOtherCosts.URL_DEFER, true);
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

            string viewUDF = "dbo.CRCS_OTHER_COSTS_VIEW (@userID, @userGroup, @userRank, @clientID, @fiscalYearID, @recID)";

            /*----------------------------
            * Validate parameters specific
            * to this entity.view
            * and populate their
            * coresponding database
            * parameters
            *----------------------------*/

            var vClientID     = Validate.optClientID(uInfo       , clientID);
            var vFiscalYearID = Validate.optInteger (fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"    , SqlDbType.BigInt, vClientID    , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fiscalYearID", SqlDbType.BigInt, vFiscalYearID, ParameterDirection.Input));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }
        public static Return save(SqlConnection dbConnSpedmon
                                , DetailsLog log
                                , UserInfo uInfo
                                , string clientID				
                                , string grpSvcClassNameID
                                , string fiscalYearID
                                , string materialsAndSupplies   
                                , string nonCapitalizedEquipment
                                , string travelAndConference	
                                , string duesAndMembership		
                                , string communications			
                                , string otherFederalCosts		
                                , string federalResourceCodes
                                , string editDelReason
                                , string validateRec
                                , string saveType
                                , string recID)
        {
            string saveSproc = @"CRCS_OTHER_COSTS_SAVE";
            string dupRecMsg = @"Record already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vClientID                = Validate.reqClientID (uInfo                   , clientID);
            var vGrpSvcClassNameID       = Validate.reqInteger  (grpSvcClassNameID       , Messages.INVALID_NUMBER);
            var vFiscalYearID            = Validate.reqInteger  (fiscalYearID            , Messages.INVALID_FISCAL_YEAR_ID);
            var vMaterialsAndSupplies    = Validate.optUsdAmount(materialsAndSupplies    , Messages.INVALID_DOLLAR_AMT);
            var vNonCapitalizedEquipment = Validate.optUsdAmount(nonCapitalizedEquipment , Messages.INVALID_DOLLAR_AMT);
            var vTravelAndConference	 = Validate.optUsdAmount(travelAndConference 	, Messages.INVALID_DOLLAR_AMT);
            var vDuesAndMembership		 = Validate.optUsdAmount(duesAndMembership		, Messages.INVALID_DOLLAR_AMT);
            var vCommunications			 = Validate.optUsdAmount(communications			, Messages.INVALID_DOLLAR_AMT);
            var vOtherFederalCosts		 = Validate.optUsdAmount(otherFederalCosts		, Messages.INVALID_DOLLAR_AMT);
            var vFederalResourceCodes    = Validate.optString   (federalResourceCodes    , Messages.INVALID_TEXT);
            


            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"               , SqlDbType.BigInt  , vClientID                , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@grpSvcClassNameID"      , SqlDbType.BigInt  , vGrpSvcClassNameID       , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fiscalYearID"           , SqlDbType.BigInt  , vFiscalYearID            , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@materialsAndSupplies"   , SqlDbType.Money   , vMaterialsAndSupplies    , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@nonCapitalizedEquipment", SqlDbType.Money   , vNonCapitalizedEquipment , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@travelAndConference"    , SqlDbType.Money   , vTravelAndConference	    , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@duesAndMembership"      , SqlDbType.Money   , vDuesAndMembership		, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@communications"         , SqlDbType.Money   , vCommunications			, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@otherFederalCosts"      , SqlDbType.Money   , vOtherFederalCosts		, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@federalResourceCodes"   , SqlDbType.VarChar , vFederalResourceCodes    , ParameterDirection.Input, 50));
            


            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.save(dbConnSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
        }
        
        public static Return defer(SqlConnection dbConnSpedmon
                                , DetailsLog log
                                , UserInfo uInfo
                                , string clientID				
                                , string grpSvcClassNameID
                                , string fiscalYearID
                                , string deferred)
        {
            string sprocName = @"CRCS_OTHER_COSTS_DEFER";
            string dupRecMsg = @"Record already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vClientID                = Validate.reqClientID (uInfo                   , clientID);
            var vGrpSvcClassNameID       = Validate.reqInteger  (grpSvcClassNameID       , Messages.INVALID_NUMBER);
            var vFiscalYearID            = Validate.reqInteger  (fiscalYearID            , Messages.INVALID_FISCAL_YEAR_ID);
            var vDeferred                = Validate.reqFlag     (deferred                , Messages.INVALID_FLAG);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"               , SqlDbType.BigInt  , vClientID                , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@grpSvcClassNameID"      , SqlDbType.BigInt  , vGrpSvcClassNameID       , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fiscalYearID"           , SqlDbType.BigInt  , vFiscalYearID            , ParameterDirection.Input));                       
            parms.Add(Database.SqlParm("@deferred"               , SqlDbType.Bit     , vDeferred                , ParameterDirection.Input));                       

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.save(dbConnSpedmon, log, uInfo, Constants.SAVE_TYPE_DELETE.ToString(), "0", "", "-1", sprocName, dupRecMsg, ref parms, null);
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

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = CrcsOtherCost.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(CrcsOtherCost)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return CrcsOtherCosts.view(
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

    }
}
