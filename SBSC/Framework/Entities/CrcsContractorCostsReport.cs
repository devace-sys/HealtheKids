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
    public class CrcsContractorCostReport : Entity
    {
        public const string DEFAULT_PAGING_ORDER = @"displayOrder asc";

        public long    clientID;
        public long    grpSvcClassNameID;
        public long    fiscalYearID;
        public string  grpSvcClassName;
        public int     displayOrder;
        public decimal contractorCosts5800;
        public decimal contractorCosts5100;
        public decimal federalResourceAmounts;
        public decimal hoursPaid;
        public decimal avgContractRatePerHour;
    }

    public class CrcsContractorCostsReport : Entities
    {
        public const string URL_REST_VIEW    = @"api/v1/crcscontractorcostsreport";

        /***************************************************************************
         * URL_REST_VIEW */
        /**
         * 
         **************************************************************************/

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsContractorCostsReport.URL_REST_VIEW, true);
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

            string viewUDF = "dbo.CRCS_CONTRACTOR_COSTS_TOTALS_VIEW (@userID, @userGroup, @userRank, @clientID, @fiscalYearID, @recID)";

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

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = CrcsContractorCostReport.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(CrcsContractorCostReport)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return CrcsContractorCostsReport.view(
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
