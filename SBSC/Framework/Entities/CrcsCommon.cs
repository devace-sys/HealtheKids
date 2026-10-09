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
    /***************************************************************************
     * CRCSCompletionStatus  */
    /**
     * Used for summary reporting
     ***************************************************************************/
    public class CRCSCompletionStatus
    {
        public bool crcsPracSalariesCompletedQ1;
        public bool crcsPracSalariesCompletedQ2;
        public bool crcsPracSalariesCompletedQ3;
        public bool crcsPracSalariesCompletedQ4;
        public bool crcsPracSalariesCompleted;
        public bool crcsOtherCostsCompleted;
        public bool crcsContractorCostsCompleted;
        public bool crcsMedEquipmentDepreciationCostsCompleted;
        public bool crcsTransportationCompleted;
        public bool crcsTransportationPersonnelCostsCompleted;
        public bool crcsTransportationOtherCostsCompleted;
        public bool crcsTransportationEquipmentDepreciationCostsCompleted;
        public bool crcsProgramInfoCompleted;
    }

    /***************************************************************************
     * ReturnCRCSCompletionStatus  */
    /**
     * Used for summary reporting
     ***************************************************************************/

    public class ReturnCRCSCompletionStatus : Return
    {
        public ReturnCRCSCompletionStatus() : base() { }
        public ReturnCRCSCompletionStatus(string msg) : base(msg) { }
        public ReturnCRCSCompletionStatus(Exception e) : base(e) { }
        public ReturnCRCSCompletionStatus(Warning e) : base(e) { }
        public ReturnCRCSCompletionStatus(Critical e) : base(e) { }
        public ReturnCRCSCompletionStatus(SessionExpired e) : base(e) { }
        public bool hasRecord = false;
        public CRCSCompletionStatus crcsCompletionStatus;
    }

    /***************************************************************************
     * CrcsTransportationVehicleData  */
    /**
     * Used for vehicle data on the Transportation tab
     ***************************************************************************/

    public class CrcsTransportationVehicleData : Entity
    {
        public long clientID;
        public long fiscalYearID;
        public int vehicleRateType;
        public int numVehiclesInFleet;
        public int numSpeciallyAdapted;
    }

    public class CrcsCommon : Entities
    {
        public const string MENU_ID_MANAGE                  = @"crcscompletionmanage";
        public const string MENU_ID_CLAIMS_REPORT           = "viewcrcsclaimslink";
        public const string SEL_LABEL                       = @"CRCS";
        public const string SEL_LABEL_MANAGE                = @"Manage CRCS";
        public const string SEL_LABEL_CLAIMS_REPORT         = @"CRCS Claims Report";
        public const string URL_MANAGE                      = @"user_all_crcs_completion_manage.aspx";
        public const string URL_CLAIMS_REPORT               = @"rpt_crc_claims.aspx";
        public const string URL_WEB_SERVICE                 = @"crcs_common.asmx";

        public const string URL_GET_COMPLETION_STATUS            = URL_WEB_SERVICE + @"/getCompletionStatus";
        public const string URL_SEND_COMPLETED_NOTIFICATION      = URL_WEB_SERVICE + @"/sendcompletednotification";
        public const string URL_SAVE_TRANSPORTATION_VEHICLE_DATA = URL_WEB_SERVICE + @"/savetransportationvehicledata";
        public const string URL_LOAD_TRANSPORTATION_VEHICLE_DATA = URL_WEB_SERVICE + @"/loadtransportationvehicledata";

        public const string URL_TRANSPORTATION_MANAGE                               = @"user_all_crcs_transportation_manage.aspx";

        public const string URL_COMPLETION_REPORT_TAB                               = @"user_all_crcs_completion_report.aspx";

        public const string STRUCTURED_DATA_IMPORT_PROFILES_FILE_PAYROLL_IMPORT     = @"crcs-bulk-payroll-import-for-calculated-breakdown.json";

        public const string URL_PAYROLL_BULK_IMPORT_WIZARD_FOR_CALCULATED_BREAKDOWN = @"user_all_crcs_calc_breakdowns_payroll_bulk_import.aspx";

        public static string URL_PAYROLL_BULK_IMPORT_WIZARD_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsCommon.URL_PAYROLL_BULK_IMPORT_WIZARD_FOR_CALCULATED_BREAKDOWN, true, new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE));
        }
        public static string URL_TRANSPORTATION_MANAGE_BASE() {
            return MBA.HttpApplication.createLink(CrcsCommon.URL_TRANSPORTATION_MANAGE, true);
        }
        public static string URL_GET_COMPLETION_STATUS_BASE() {
            return MBA.HttpApplication.createLink(CrcsCommon.URL_GET_COMPLETION_STATUS, true);
        }

        public static string URL_SEND_COMPLETED_NOTIFICATION_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsCommon.URL_SEND_COMPLETED_NOTIFICATION, true);
        }

        public static string URL_SAVE_TRANSPORTATION_VEHICLE_DATA_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsCommon.URL_SAVE_TRANSPORTATION_VEHICLE_DATA, true);
        }

        public static string URL_LOAD_TRANSPORTATION_VEHICLE_DATA_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsCommon.URL_LOAD_TRANSPORTATION_VEHICLE_DATA, true);
        }

        /***************************************************************************
         * URL_REPORT_TAB_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_COMPLETION_REPORT_TAB_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsCommon.URL_COMPLETION_REPORT_TAB, true);
        }

        // IMPORTANT: the following constants MUST match the table "dbo.CRCS_CATEGORY_CODES"
        public const string SALARY_BENEFITS_TAB_ID                             = @"1";
        public const string OTHER_COSTS_TAB_ID                                 = @"2";
        public const string CONTRACTOR_COSTS_TAB_ID                            = @"3";
        public const string MED_EQUIPMENT_DEPRECIATION_COSTS_TAB_ID            = @"4";
        public const string TRANSPORTATION_TAB_ID                              = @"5";

        public const string TRANSPORTATION_PERSONNEL_COSTS_TAB_ID              = @"6";
        public const string TRANSPORTATION_OTHER_COSTS_TAB_ID                  = @"7";
        public const string TRANSPORTATION_EQUIPMENT_DEPRECIATION_COSTS_TAB_ID = @"8";
        public const string SALARY_BENEFITS_BEFORE_19_20_FY_TAB_ID             = @"9";
        public const string PROGRAM_INFO_TAB_ID                                = @"10";
        public const string COMPLETION_REPORT_TAB_ID                           = @"11";
        public const string TRANSPORTATION_REIMBURSEMENTS_TAB_ID               = @"12";

        /***************************************************************************
         * getCRCSCompletionStatus 
         *
         * Returns CRCS completion status for different CRCS categories
         * 
         ***************************************************************************/

        public static ReturnCRCSCompletionStatus getCompletionStatus(SqlConnection connSpedmon
                                                  , DetailsLog log
                                                  , UserInfo uInfo
                                                  , string clientID
                                                  , string fiscalYearID
        )
        {
            
            var so = new ReturnCRCSCompletionStatus();
            
            long   vClientID     = Validate.reqClientID (uInfo, clientID);
            long   vFiscalYearID = Validate.reqInteger  (fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);

            var parms = new List<SqlParameter>();

              parms.Add(Database.SqlParm("@clientID",      SqlDbType.BigInt,   vClientID,      ParameterDirection.Input));
              parms.Add(Database.SqlParm("@fiscalYearID",  SqlDbType.BigInt,   vFiscalYearID,  ParameterDirection.Input));

              var sql = @"select top 1 * from dbo.CRCS_COMPLETION_STATUS_VIEW (@clientID, @fiscalYearID)";

              ReturnDB rd = Database.execQuery(connSpedmon,log,sql,false,parms);
      
              so.hasRecord = rd.hasRecords;
              so.crcsCompletionStatus = new CRCSCompletionStatus();
              if (so.hasRecord)
              {
                so.crcsCompletionStatus = (CRCSCompletionStatus)Database.convertRecord(rd.records, typeof(CRCSCompletionStatus));
              }
              return so;      
           
        }

        public static ReturnDB populateDefaultsForFiscalYear ( 
              SqlConnection connSpedmon
            , DetailsLog log
            , UserInfo uInfo
            , string clientID)
        {
            var so = new ReturnDB();

            var vClientID = Validate.optClientID(uInfo, clientID);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));

            var spName = @"dbo.CRCS_POPULATE_DEFAULTS_FOR_FISCAL_YEAR_SAVE";
            
            so = Database.execSproc(connSpedmon, log, spName,parms);

            return so;
        }

        /***************************************************************************
         * sendCompletedNotification */
        /**
         * 
         ***************************************************************************/

        public static ReturnSaveOrReplaceRecord sendCompletedNotification(SqlConnection connSpedmon
                                                                , DetailsLog log
                                                                , UserInfo uInfo
                                                                , string clientID )
        {

            var vClientID         = Validate.reqClientID(uInfo           , clientID);

            /*----------------------------
             * Validate parameters specific
             * to this entity.save
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"        , SqlDbType.BigInt, vClientID        , ParameterDirection.Input));

            return Entities.saveOrReplaceRecord(connSpedmon
                                                  , log
                                                  , uInfo
                                                  , "N"
                                                  , "CRCS_SEND_COMPLETED_NOTIFICATION"
                                                  , ref parms
                                                  , null
                                                );

        }

        /***************************************************************************
         * saveTransportationVehicleData 
         * 
         ***************************************************************************/

        public static ReturnSaveOrReplaceRecord saveTransportationVehicleData(SqlConnection connSpedmon
                                , DetailsLog log
                                , UserInfo uInfo
                                , string clientID
                                , string fiscalYearID
                                , string vehicleRateType
                                , string numVehiclesInFleet
                                , string numSpeciallyAdapted )
        {

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vClientID            = Validate.reqClientID(uInfo, clientID);
            var vFiscalYearID        = Validate.reqInteger (fiscalYearID       , Messages.INVALID_FISCAL_YEAR_ID);
            var vVehicleRateType     = Validate.optInteger (vehicleRateType    , @"Invalid vehicle rate selection", true);
            var vNumVehiclesInFleet  = Validate.optInteger (numVehiclesInFleet , @"Invalid vehicle rate selection", true);
            var vNumSpeciallyAdapted = Validate.optInteger (numSpeciallyAdapted, @"Invalid vehicle rate selection", true);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"           , SqlDbType.BigInt, vClientID           , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fiscalYearID"       , SqlDbType.BigInt, vFiscalYearID       , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@vehicleRateType"    , SqlDbType.Int   , vVehicleRateType    , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@numVehiclesInFleet" , SqlDbType.Int   , vNumVehiclesInFleet , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@numSpeciallyAdapted", SqlDbType.Int   , vNumSpeciallyAdapted, ParameterDirection.Input));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.saveOrReplaceRecord(connSpedmon
                                                  , log
                                                  , uInfo
                                                  , "N"
                                                  , "CRCS_TRANSPORTATION_VEHICLE_DATA_SAVE"
                                                  , ref parms
                                                  , null
                                                );
        }

        /***************************************************************************
         * viewTransportationVehicleData */
        /**
         * 
         ***************************************************************************/

        public static ReturnDB viewTransportationVehicleData(SqlConnection connSpedmon
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

            string viewUDF = "dbo.CRCS_TRANSPORTATION_VEHICLE_DATA_VIEW (@userID, @userGroup, @userRank, @clientID, @fiscalYearID)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            var vClientID         = Validate.reqClientID(uInfo           , clientID);
            var vFiscalYearID     = Validate.reqInteger (fiscalYearID    , Messages.INVALID_FISCAL_YEAR_ID);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"        , SqlDbType.BigInt, vClientID        , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fiscalYearID"    , SqlDbType.BigInt, vFiscalYearID    , ParameterDirection.Input));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        /***************************************************************************
        * loadTransportationVehicleData */
        /**
         ***************************************************************************/

        public static CrcsTransportationVehicleData loadTransportationVehicleData(SqlConnection connSpedmon
                                              , DetailsLog log
                                              , UserInfo uInfo
                                              , string clientID
                                              , string fiscalYearID)
        {
            var vClientID     = Validate.reqClientID(uInfo, clientID);
            var vFiscalYearID = Validate.reqInteger (fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);

            CrcsTransportationVehicleData ctvd = new CrcsTransportationVehicleData();

            try
            {
                ctvd = (CrcsTransportationVehicleData)Entities.loadNRecord(connSpedmon, log, uInfo, 0, typeof(CrcsTransportationVehicleData),
                    delegate
                    {
                        return CrcsCommon.viewTransportationVehicleData(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD_N, false, "", "", "Y", clientID, fiscalYearID, null);
                    }
                );
            }
            catch
            {
                ctvd.clientID = vClientID;
                ctvd.fiscalYearID = vFiscalYearID;
                ctvd.vehicleRateType = 2;
            }

            return ctvd;

        }


        public static ReturnSaveRecordWithJSONData importPayrollDataForCalculatedBreakdown(SqlConnection connSpedmon
                                                                , DetailsLog log
                                                                , UserInfo uInfo
                                                                , string clientID

                                                                , string fyear_id
                                                                , string quarternum

                                                                , string dataToImportJSON
                                                                , string validateRec
                                                                )
        {

            ReturnSaveRecordWithJSONData rd = new ReturnSaveRecordWithJSONData();

            /*----------------------------
                * Validate incoming data
                *----------------------------*/

            long vClientID = Validate.reqClientID(uInfo, clientID);

            long vFyearID     = Validate.reqInteger(fyear_id, Messages.INVALID_FISCAL_YEAR_ID);
            long vQuarterNum  = Validate.reqInteger(quarternum, Messages.INVALID_QUARTER);

            MBA.StructuredDataFieldAdditionalValidation _fnAdditionalFieldValidation = delegate (int rowNum, StructuredDataField field, string valueIn)
            {
                string valueOut = valueIn;
                return valueOut;
            };

            string vDataToImport = MBA.StructuredDataImportFiles.validate(   STRUCTURED_DATA_IMPORT_PROFILES_FILE_PAYROLL_IMPORT
                                                                            , dataToImportJSON
                                                                            , @"Please select the type of file and a file"
                                                                            , @"Please select the type of file"
                                                                            , @"Please select a file that has records"
                                                                            , @"All of the records in this data file have data issues"
                                                                            , null
                                                                            , _fnAdditionalFieldValidation);
            /*----------------------------
                * Populate db parameters
                *----------------------------*/

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@fyear_id",   SqlDbType.BigInt, vFyearID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@quarternum", SqlDbType.BigInt, vQuarterNum, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@importDataJSON", SqlDbType.VarChar, vDataToImport, ParameterDirection.Input, -1));

            /*----------------------------
                * Call base method which
                * handles the rest and return
                * results
                *----------------------------*/

            rd = Entities.saveAndReturnJSONData(
                              connSpedmon
                            , log
                            , uInfo
                            , Constants.SAVE_TYPE_NEW.ToString()
                            , validateRec
                            , ""
                            , ""
                            , "CRCS_CALC_SALARY_BREAKDOWNS_FROM_PAYROLL_BULK_IMPORT"
                            , @"Duplicate file"
                            , ref parms
                            , null
                            );

            return rd;

        }


    }
}
