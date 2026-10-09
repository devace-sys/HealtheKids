using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using MBA;


namespace Spedmon
{
    public class CrcsCategoryCompleted : Entity
    {
        public long clientID;
        public long fiscalYearID;
        public int  quarterNumber;
        public int  crcsCategoryCode;
        public bool completed;
    }

    /***************************************************************************
     * CrcsCategoriesCompleted */
    /**
     ***************************************************************************/

    public class CrcsCategoriesCompleted : Entities
    {

        /***************************************************************************
         * saveOrReplace */
        /**
         * 
         ***************************************************************************/

        public static ReturnSaveOrReplaceRecord saveOrReplace(SqlConnection connSpedmon
                                                                , DetailsLog log
                                                                , UserInfo uInfo
                                                                , string clientID
                                                                , string fiscalYearID
                                                                , string quarterNumber
                                                                , string crcsCategoryCode
                                                                , string completed )
        {

            var vClientID         = Validate.reqClientID(uInfo           , clientID);
            var vFiscalYearID     = Validate.reqInteger (fiscalYearID    , Messages.INVALID_FISCAL_YEAR_ID);
            var vQuarterNumber    = Validate.reqInteger (quarterNumber   , Messages.INVALID_QUARTER);
            var vCrcsCategoryCode = Validate.reqInteger (crcsCategoryCode, @"Invalid CRCS code");
            var vCompleted        = Validate.reqFlag    (completed       , Messages.INVALID_FLAG);

            /*----------------------------
             * Validate parameters specific
             * to this entity.save
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"        , SqlDbType.BigInt, vClientID        , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fiscalYearID"    , SqlDbType.BigInt, vFiscalYearID    , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@quarterNumber"   , SqlDbType.Int   , vQuarterNumber   , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@crcsCategoryCode", SqlDbType.Int   , vCrcsCategoryCode, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@completed"       , SqlDbType.Bit   , vCompleted       , ParameterDirection.Input));

            return Entities.saveOrReplaceRecord(connSpedmon
                                                  , log
                                                  , uInfo
                                                  , "N"
                                                  , "CRCS_CATEGORY_COMPLETED_SAVE"
                                                  , ref parms
                                                  , null
                                                );

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
                                     , string quarterNumber
                                     , string crcsCategoryCode
                                     , defineCols dc)
        {

            string viewUDF = "dbo.CRCS_CATEGORY_COMPLETED_VIEW (@userID, @userGroup, @userRank, @clientID, @fiscalYearID, @quarterNumber, @crcsCategoryCode)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            var vClientID         = Validate.reqClientID(uInfo           , clientID);
            var vFiscalYearID     = Validate.reqInteger (fiscalYearID    , Messages.INVALID_FISCAL_YEAR_ID);
            var vQuarterNumber    = Validate.reqInteger (quarterNumber   , Messages.INVALID_QUARTER);
            var vCrcsCategoryCode = Validate.reqInteger (crcsCategoryCode, @"Invalid CRCS code");

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"        , SqlDbType.BigInt, vClientID        , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fiscalYearID"    , SqlDbType.BigInt, vFiscalYearID    , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@quarterNumber"   , SqlDbType.Int   , vQuarterNumber   , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@crcsCategoryCode", SqlDbType.Int   , vCrcsCategoryCode, ParameterDirection.Input));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        /***************************************************************************
        * load */
        /**
         ***************************************************************************/

        public static CrcsCategoryCompleted load(SqlConnection connSpedmon
                                              , DetailsLog log
                                              , UserInfo uInfo
                                              , string clientID
                                              , string fiscalYearID
                                              , string quarterNumber
                                              , string crcsCategoryCode )
        {
            var vClientID         = Validate.reqClientID(uInfo           , clientID);
            var vFiscalYearID     = Validate.reqInteger (fiscalYearID    , Messages.INVALID_FISCAL_YEAR_ID);
            var vQuarterNumber    = Validate.reqInteger (quarterNumber   , Messages.INVALID_QUARTER);
            var vCrcsCategoryCode = Validate.reqInteger (crcsCategoryCode, @"Invalid CRCS code");

            CrcsCategoryCompleted ccc = new CrcsCategoryCompleted();

            try
            {
                ccc = (CrcsCategoryCompleted)Entities.loadNRecord(connSpedmon, log, uInfo, 0, typeof(CrcsCategoryCompleted),
                    delegate
                    {
                        return CrcsCategoriesCompleted.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD_N, false, "", "", "Y", clientID, fiscalYearID, quarterNumber, crcsCategoryCode, null);
                    }
                );
            }
            catch
            {
                ccc.clientID         = vClientID;
                ccc.fiscalYearID     = vFiscalYearID;
                ccc.quarterNumber    = vQuarterNumber;
                ccc.crcsCategoryCode = vCrcsCategoryCode;
                ccc.completed        = false;
            }
			
            return ccc;
        }

    }
}
