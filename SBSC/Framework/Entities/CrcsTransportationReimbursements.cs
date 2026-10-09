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
    public class CrcsTransportationReimbursement : Entity
    {
        public const string DEFAULT_PAGING_ORDER = @"patName asc";

        public long patID;
        public string patName;
        public DateTime dob;
        public string dobStr;
        public string siteName;
    }

    public class CrcsTransportationReimbursements : Entities
    {
        public const string URL_MANAGE       = @"user_all_crcs_transportation_reimbursements_manage.aspx";

        public const string URL_WEB_SERVICE  = @"crcs_transportation_reimbursements.asmx";

        public const string URL_REST_VIEW    = @"api/v1/crcstransportationreimbursements";

        /***************************************************************************
         * URL_REST_VIEW */
        /**
         * 
         **************************************************************************/

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsTransportationReimbursements.URL_REST_VIEW, true);
        }        
        
        /***************************************************************************
         * URL_MANAGE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_MANAGE_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsTransportationReimbursements.URL_MANAGE, true);
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

            string viewUDF = "dbo.CRCS_TRANSPORTATION_REIMBURSEMENTS_VIEW (@userID, @userGroup, @userRank, @clientID, @fiscalYearID, @recID)";

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

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = CrcsTransportationReimbursement.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(CrcsTransportationReimbursement)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return CrcsTransportationReimbursements.view(
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
