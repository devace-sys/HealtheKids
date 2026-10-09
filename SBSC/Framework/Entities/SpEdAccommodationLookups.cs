using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using MBA;


namespace Spedmon
{

    /***************************************************************************
     * SpEdAccommodationLookups */
    /**
     ***************************************************************************/

    public class SpEdAccommodationLookups : Entities
    {

        public const string URL_SERVICE_BASE = @"sped_accommodation_lookups.asmx";
        public const string URL_VIEW_SEL = URL_SERVICE_BASE + @"/viewSel";

        public static string URL_VIEW_SEL_BASE()
        {
            return MBA.HttpApplication.createLink(URL_VIEW_SEL, true);
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
                                    , string lookupType
                                    , string domainCode
                                    , string term
                                    , defineCols dc)
        {

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();
            string viewUDF = "dbo.SPED_ACCOMMODATION_LOOKUP_VIEW (@userID, @userGroup, @userRank, @lookupType, @domainCode, @term)";

            parms.Add(Database.SqlParm("@lookupType", SqlDbType.VarChar, lookupType, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@domainCode", SqlDbType.VarChar, domainCode, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@term",       SqlDbType.VarChar, term,       ParameterDirection.Input, 256));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        /***************************************************************************
         * viewSel */
        /**
         * Active accommodation lookup values for a given lookup type
         ***************************************************************************/

        public static ReturnSel viewSel(SqlConnection connSpedmon
                                        , DetailsLog log
                                        , UserInfo uInfo
                                        , bool   paged
                                        , string pageNumber
                                        , string active
                                        , string lookupType
                                        , string domainCode
                                        , string term)
        {

            string vLookupType = Validate.optString(lookupType);
            string vDomainCode = Validate.optString(domainCode);
            string vTerm       = Validate.optString(term);

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {
            };

            return Entities.viewSel(connSpedmon, log, uInfo, paged, pageNumber,
             delegate { return SpEdAccommodationLookups.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, vLookupType, vDomainCode, vTerm, dc); });
        }

    }
}