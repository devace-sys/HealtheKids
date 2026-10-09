using MBA;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace Spedmon
{

    /***************************************************************************
     * CdeComplianceBucketSummaries */
    /**
     * 
     ****************************************************************************/

    public class CdeComplianceBucketSummaries : Entities
    {

        /***************************************************************************
         * getOverallSummary */
        /**
         * Gets overall summary
         * 
         * @return            ReturnObject
         ***************************************************************************/

        public static ReturnObject getOverallSummary (  SqlConnection connSpedmon
                                                      , DetailsLog log
                                                      , UserInfo uInfo
                                                      , string clientID
                                                      , string siteID)
        {

            var so      = new ReturnObject();
            var objType = typeof(CdeComplianceOverallValue);

            so.hasRecord = false;
            so.objectFullName = objType.FullName;

            var parms = new List<SqlParameter>();
            validateAndAddCommonUserInfoParameters(uInfo, ref parms);

            var vClientID = Validate.reqClientID(uInfo, clientID);
            var vSiteID = Validate.optInteger(siteID, Messages.INVALID_SITE_ID);

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@siteID", SqlDbType.BigInt, vSiteID, ParameterDirection.Input));

            var sql = "select top 1 * from dbo.RPT_CDE_COMPLIANCE_OVERALL_SUMMARY (@userID, @userGroup, @userRank, @clientID, @siteID)";
            var rd = Database.execQuery(connSpedmon, log, sql, false, parms);

            if (rd.hasRecords == true)
            {
                CdeComplianceOverallValue obj = (CdeComplianceOverallValue)Database.convertRecord(rd.records, objType);
                so.hasRecord = true;                
                so.data = obj;
            }
            return so;
        }
        
      
        /***************************************************************************
         * view */
        /**
         * View base method
         * 
         * @return            ReturnDB
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
                                     , string startDate
                                     , string endDate
                                     , defineCols dc)
        {

            string viewUDF = "dbo.RPT_CDE_COMPLIANCE_BUCKETS_SUMMARY(@userID,@userGroup,@userRank,@clientID,@startDate,@endDate)";

            /*----------------------------
             * If no dates passed then 
             * calculate and use current
             * claiming window
             *----------------------------*/

            if (String.IsNullOrWhiteSpace(startDate) && String.IsNullOrWhiteSpace(endDate))
            {
                Util.parseDateRange(Util.GenerateDateRange(9), out startDate, out endDate);
            }

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            Object vClientID = Validate.reqClientID(uInfo, clientID);
            DateTime vStartDate = Validate.reqDate(startDate, Messages.INVALID_START_DATE);
            DateTime vEndDate = Validate.reqDate(endDate, Messages.INVALID_END_DATE);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@startDate", SqlDbType.DateTime, vStartDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@endDate", SqlDbType.DateTime, vEndDate, ParameterDirection.Input));

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
         * Loads single record
         * 
         * Note: This calls the view method and the view method takes care of
         * enforcing client specific data
         * 
         * @param  connSpedmon     Spedmon database connection object
         * @param  log             Logging object
         * @param  clientID        Client ID
         * @return                 ReturnEntity
         ***************************************************************************/
        public static CdeComplianceBucketSummary load(SqlConnection connSpedmon
                                                        , DetailsLog log
                                                        , UserInfo uInfo
                                                        , string clientID
                                                        , string startDate
                                                        , string endDate)
        {
            return (CdeComplianceBucketSummary)Entities.loadNRecord(connSpedmon, log, uInfo, 0, typeof(CdeComplianceBucketSummary),
            delegate { return CdeComplianceBucketSummaries.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD_N, false, "", "", "", clientID, startDate, endDate, null); });
        }

        /***************************************************************************
         * get */
        /**
         * 
         **************************************************************************/
        public static ReturnEntity get(SqlConnection connSpedmon
                                         , DetailsLog log
                                         , UserInfo uInfo
                                         , string clientID)
        {
            var so = new ReturnEntity();
            so.entity = CdeComplianceBucketSummaries.load(connSpedmon, log, uInfo, clientID, String.Empty, String.Empty);
            return so;
        }

        /***************************************************************************
         * getCdeComplianceBucketsSummary */
        /**
         * 
         ***************************************************************************/
        public static ReturnTotalNumAmts getCdeComplianceBucketsSummary(SqlConnection connSpedmon
                                                                          , DetailsLog log
                                                                          , UserInfo uInfo
                                                                          , string clientID)
        {
            ReturnTotalNumAmts so = new ReturnTotalNumAmts();
            var amts = new List<TotalNumAmt>();
            var cbs = CdeComplianceBucketSummaries.load(connSpedmon, log, uInfo, clientID, String.Empty, String.Empty);
            TotalNumAmt c = new TotalNumAmt();
            c.label = CdeComplianceCommon.LABEL_BUCKET_C_LINES(@" ");
            c.totalNumVal = cbs.patsInBucketC;
            c.totalNumStr = cbs.patsInBucketC.ToString();
            amts.Add(c);

            TotalNumAmt b = new TotalNumAmt();
            b.label = CdeComplianceCommon.LABEL_BUCKET_B_LINES(@" ");
            b.totalNumVal = cbs.patsInBucketB;
            b.totalNumStr = cbs.patsInBucketB.ToString();
            amts.Add(b);

            TotalNumAmt a = new TotalNumAmt();
            a.label = CdeComplianceCommon.LABEL_BUCKET_A_LINES(@" ");
            a.totalNumVal = cbs.patsInBucketA;
            a.totalNumStr = cbs.patsInBucketA.ToString();
            amts.Add(a);

            so.totalNumAmts = amts.ToArray();
            return so;

        }


    }
}
