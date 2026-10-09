using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    public class CompanyFiscalQuarter : Entity
    {
        public long     fyID; 
        public int      quarterNumber;
        public DateTime quarterStartDate;
        public string   quarterStartDateStr;
        public string   quarterStartDateStrYMD;
        public DateTime quarterEndDate;
        public string   quarterEndDateStr;
        public string   quarterEndDateStrYMD;
    }

    public class CompanyFiscalQuarters : Entities
    {
        public static ReturnDB view(SqlConnection connSpedmon
                            , DetailsLog log
                            , UserInfo uInfo
                            , int recViewType
                            , bool pagedOrTop
                            , string recID
                            , string canEdit
                            , string active
                            , string year
                            , string fiscalYearID
                            , string quarterNumber
                            , defineCols dc)
        {

            string viewUDF = "dbo.COMPANY_FISCAL_QUARTERS_VIEW(@userID, @userGroup, @userRank, @year, @fiscalYearID, @quarterNumber, @recID)";

            var vYear          = Validate.optDate   (year, Messages.INVALID_DATE);
            var vFiscalYearID  = Validate.optInteger(fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);
            var vQuarterNumber = Validate.optInteger(quarterNumber, Messages.INVALID_QUARTER);


            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@year"         , SqlDbType.DateTime, vYear         , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fiscalYearID" , SqlDbType.BigInt  , vFiscalYearID , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@quarterNumber", SqlDbType.BigInt  , vQuarterNumber, ParameterDirection.Input));

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, recID, canEdit, active, viewUDF, ref parms, null, dc);

        }


        /// <summary>
        /// Loads all fiscal quarters within a year
        /// </summary>
        /// <param name="recID">fiscal year ID. Can be null.</param>
        /// <param name="yearDate">filter results by the year portion of this date. Can be null.</param>
        /// <param name="fiscalYearID">filter results by this year. Can be null.</param>
        /// <param name="quarterNumber">filter results by this quarter number. Can be null.</param>
        /// <returns></returns>
        /// 


        /***************************************************************************
          *  loadByFqID */
        /**
         * Fetches a CompanyFiscalQuarter by its unique numeric record ID.
         * 
         * @return                 CompanyFiscalQuarter
         ***************************************************************************/

        public static CompanyFiscalQuarter loadByFqID(SqlConnection connSpedmon
                                             , DetailsLog log
                                             , UserInfo uInfo
                                             , string active
                                             , string recID)
        {
            return (CompanyFiscalQuarter)Entities.loadNRecord(connSpedmon, log, uInfo, 0, typeof(CompanyFiscalQuarter),
            delegate { return view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", active, "", "", "", null); });
        }

        /***************************************************************************
         *  load */
        /**
         * Fetches a CompanyFiscalQuarter by quarterNumber 1-4 and its year date or fiscalYearID.
         * NOTE: FAILS TO FETCH BY recID: this is a BUG.
         * 
         * @return                 CompanyFiscalQuarter
         ***************************************************************************/
        public static CompanyFiscalQuarter load(SqlConnection connSpedmon
                                                     , DetailsLog log
                                                     , UserInfo uInfo
                                                     , string active
                                                     , string yearDate
                                                     , string fiscalYearID
                                                     , string quarterNumber
                                                     , string recID)  // note: all existing calls to this method pass in recID = null
        {            
            return (CompanyFiscalQuarter)Entities.loadNRecord(connSpedmon, log, uInfo, 0, typeof(CompanyFiscalQuarter),
            delegate { return view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD_N, false, recID, "", active, yearDate, fiscalYearID, quarterNumber, null); });
            // NOTE: this method fails to fetch by fqID.  changing Entities.REC_VIEW_LOAD_N
            // to Entities.REC_VIEW_LOAD makes it work.  Created another method (above) so
            // as to avoid fixing "bugs" when the code has worked in production without incident
        }
    }
}
