using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    public class SvcAuthStatsHist : Entity
    {
        public string effectivePeriod;
        public string orpPracName;
        public string orpPracTitle;
    }

    public class SvcAuthStatsHists : Entities
    {
        /***************************************************************************
         * view */
        /**
         * Note: We retrieve pracID internally for practitioners and force this
         * to be the pracID to the view udf so pracs can only see orders that
         * are related to their discipline family.
         **************************************************************************/

        public static ReturnDB view(
                                    SqlConnection connSpedmon
                                  , DetailsLog log
                                  , UserInfo uInfo
                                  , int recViewType
                                  , bool pagedOrTop
                                  , string idx
                                  , string canEdit
                                  , string active
                                  , string clientID
                                  , string orpDocumentID
                                  , defineCols dc)
        {


            string viewUDF = "dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_HISTORY (@userID, @userGroup, @userRank, @clientID, @orpDocumentID)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            Object vClientID = Validate.optClientID(uInfo, clientID);
            Object vOrpDocumentID = Validate.optInteger(orpDocumentID, Messages.INVALID_ORP_DOC_ID);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@orpDocumentID", SqlDbType.BigInt, vOrpDocumentID, ParameterDirection.Input));


            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        /***************************************************************************
         * viewTbl */
        /**
         * Returns a data table of records for preview or record selection.
         * 
         * @return                 ReturnDataTable
         ***************************************************************************/

        public static ReturnDataTable viewTbl(
                                                 SqlConnection connSpedmon
                                               , DetailsLog log
                                               , UserInfo uInfo
                                               , string clientID
                                               , string orpDocumentID
        )
        {

            ReturnDataTable so = new ReturnDataTable();

            /*----------------------------
             * Define our columns and
             * set the page order for 
             * paging
             * 
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("name              as [Modifier's Name] ");
                ss.addDisplayColumn("effectivePeriod   as [Effective Period / Authorization Date]");
                ss.addDisplayColumn("action            as [Action]          ");
                ss.addDisplayColumn("orpPracName       as [ORP Name]        ");
                ss.addDisplayColumn("orpPracTitle      as [ORP Title]       ");

                pageroworder = ss.pageRowOrder();

            };

            /*----------------------------
             * Call base method which
             * handles the rest 
             *----------------------------*/

            so = Entities.viewTbl(connSpedmon, log, uInfo, false, null,
              delegate { return SvcAuthStatsHists.view(connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, false, null, null, null, clientID, orpDocumentID, dc); });

            /*----------------------------
             * Add a title and footer
             *----------------------------*/

            so.tableName = "Authorization History";
            so.tableFooter = Messages.CONFIDENTIAL;

            /*----------------------------
             * Done
             *----------------------------*/

            return so;

        }
    }
}