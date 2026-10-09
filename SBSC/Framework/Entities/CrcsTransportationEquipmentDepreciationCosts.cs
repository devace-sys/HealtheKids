﻿using MBA;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;
 
namespace Spedmon
{
    public class CrcsTransportationEquipmentDepreciationCost : Entity
    {
        public const string DEFAULT_PAGING_ORDER = @"assetID desc";
 
        public long     clientID;
        public string   assetID;
        public long     fiscalYearID;
        public string   assetType;
        public DateTime placedInService;
        public string   placedInServiceOnStr;
        public string   placedInServiceOnStrYMD;
        public int      yearsUseful;
        public decimal  depreciableCost;
        public decimal  fedResourceOrGrant;
        public decimal  annualDepreciation;
        public bool     retiredDuringCostPeriod;
        public DateTime placedOutOfServiceOn;
        public string   placedOutOfServiceOnStr;
        public string   placedOutOfServiceOnStrYMD;
        public decimal  accumulatedDepreciation;
        public decimal  depreciationForReportPeriod;
        public decimal  depreciationForReportPeriodRatio;
        public string   depreciationForReportPeriodRatioStr;
    }
 
    public class CrcsTransportationEquipmentDepreciationCosts : Entities
    {
        public const string URL_MANAGE      = @"user_all_crcs_transportation_equipment_depreciation_costs_manage.aspx";
 
        public const string URL_WEB_SERVICE       = @"crcs_transportation_equipment_depreciation_costs.asmx";
        public const string URL_SAVE              = URL_WEB_SERVICE + @"/save";
        public const string URL_DELETE            = URL_WEB_SERVICE + @"/delete";
        public const string URL_DEFER             = URL_WEB_SERVICE + @"/defer";
        public const string URL_DEFER_STATUS_VIEW = URL_WEB_SERVICE + @"/getDeferralStatus";

        public const string URL_REST_VIEW    = @"api/v1/crcstransportationequipmentdepreciationcosts";
 
        /***************************************************************************
         * URL_REST_VIEW */
        /**
         * 
         **************************************************************************/
 
        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsTransportationEquipmentDepreciationCosts.URL_REST_VIEW, true);
        }
 
        /***************************************************************************
         * URL_MANAGE_BASE */
        /**
         * 
         **************************************************************************/
 
        public static string URL_MANAGE_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsTransportationEquipmentDepreciationCosts.URL_MANAGE, true);
        }
 
        /***************************************************************************
         * URL_SAVE_BASE */
        /**
         * 
         **************************************************************************/
 
        public static string URL_SAVE_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsTransportationEquipmentDepreciationCosts.URL_SAVE, true);
        }
 
        /***************************************************************************
         * URL_DELETE_BASE */
        /**
         * 
         **************************************************************************/
 
        public static string URL_DELETE_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsTransportationEquipmentDepreciationCosts.URL_DELETE, true);
        }

        /***************************************************************************
         * URL_DEFER_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_DEFER_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsTransportationEquipmentDepreciationCosts.URL_DEFER, true);
        }

        /***************************************************************************
         * URL_DEFER_STATUS_VIEW_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_DEFER_STATUS_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsTransportationEquipmentDepreciationCosts.URL_DEFER_STATUS_VIEW, true);
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
 
            string viewUDF = "dbo.CRCS_TRANSPORTATION_EQUIPMENT_DEPRECIATION_COSTS_VIEW (@userID, @userGroup, @userRank, @clientID, @fiscalYearID, @active, @recID)";
 
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
                                , string assetID
                                , string assetType
                                , string placedInServiceOn
                                , string yearsUseful
                                , string depreciableCost
                                , string fedResourceOrGrant
                                , string annualDepreciation
                                , string retiredDuringCostPeriod
                                , string placedOutOfServiceOn
                                , string accumulatedDepreciation
                                , string depreciationForReportPeriod
                                , string editDelReason
                                , string validateRec
                                , string saveType
                                , string recID)
        {
            string saveSproc = @"CRCS_TRANSPORTATION_EQUIPMENT_DEPRECIATION_COSTS_SAVE";
            string dupRecMsg = @"Record already exists";
 
            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/
 
            var vClientID                    = Validate.reqClientID (uInfo                      , clientID);
            var vFiscalYearID                = Validate.reqInteger  (fiscalYearID               , Messages.INVALID_FISCAL_YEAR_ID);
            var vAssetID                     = Validate.optString   (assetID                    , Messages.INVALID_TEXT);
            var vAssetType                   = Validate.optString   (assetType                  , Messages.INVALID_TEXT);
            var vPlacedInServiceOn           = Validate.optDate     (placedInServiceOn          , Messages.INVALID_DATES);
            var vYearsUseful                 = Validate.optInteger  (yearsUseful                , Messages.INVALID_NUMBER, true);
            var vDepreciableCost             = Validate.optUsdAmount(depreciableCost            , Messages.INVALID_DOLLAR_AMT);
            var vFedResourceOrGrant          = Validate.optUsdAmount(fedResourceOrGrant         , Messages.INVALID_DOLLAR_AMT);
            var vAnnualDepreciation          = Validate.optUsdAmount(annualDepreciation         , Messages.INVALID_DOLLAR_AMT);
            var vRetiredDuringCostPeriod     = Validate.optFlag     (retiredDuringCostPeriod    , Messages.INVALID_FLAG);
            var vPlacedOutOfServiceOn        = Validate.optDate     (placedOutOfServiceOn       , Messages.INVALID_DATES);
            var vAccumulatedDepreciation     = Validate.optUsdAmount(accumulatedDepreciation    , Messages.INVALID_DOLLAR_AMT);
            var vDepreciationForReportPeriod = Validate.optUsdAmount(depreciationForReportPeriod, Messages.INVALID_DOLLAR_AMT);
 
            List<SqlParameter> parms = new List<SqlParameter>();
 
            parms.Add(Database.SqlParm("@clientID"                   , SqlDbType.BigInt  , vClientID                   , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@fiscalYearID"               , SqlDbType.BigInt  , vFiscalYearID               , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@assetID"                    , SqlDbType.VarChar , vAssetID                    , ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@assetType"                  , SqlDbType.VarChar , vAssetType                  , ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@placedInServiceOn"          , SqlDbType.Date    , vPlacedInServiceOn          , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@yearsUseful"                , SqlDbType.Int     , vYearsUseful                , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@depreciableCost"            , SqlDbType.Money   , vDepreciableCost            , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@fedResourceOrGrant"         , SqlDbType.Money   , vFedResourceOrGrant         , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@annualDepreciation"         , SqlDbType.Money   , vAnnualDepreciation         , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@retiredDuringCostPeriod"    , SqlDbType.Bit     , vRetiredDuringCostPeriod    , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@placedOutOfServiceOn"       , SqlDbType.Date    , vPlacedOutOfServiceOn       , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@accumulatedDepreciation"    , SqlDbType.Money   , vAccumulatedDepreciation    , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@depreciationForReportPeriod", SqlDbType.Money   , vDepreciationForReportPeriod, ParameterDirection.Input    ));
            
 
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
 
            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = CrcsTransportationEquipmentDepreciationCost.DEFAULT_PAGING_ORDER;
 
            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */
 
            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };
 
            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(CrcsTransportationEquipmentDepreciationCost)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return CrcsTransportationEquipmentDepreciationCosts.view(
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
 
            string deleteSproc = @"CRCS_TRANSPORTATION_EQUIPMENT_DEPRECIATION_COSTS_DELETE";
 
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
 
    }
}