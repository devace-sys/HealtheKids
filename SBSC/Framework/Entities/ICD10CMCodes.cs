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
     * SpEdReasons */
    /**
     ***************************************************************************/
    public class ICD10CMCode : Entity
    {
        public const string DEFAULT_PAGING_ORDER = "id asc";
        public string code;
        public string codeChapter;
        public string codeCategory;
        public string codeSubCategory;

    }

    public class ICD10CMCodes : Entities
    {
        public const string URL_SERVICE_BASE = @"icd_10_cm_codes.asmx";
        public const string URL_VIEW_SEL     = URL_SERVICE_BASE + @"/viewSel";
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

            var parms = new List<SqlParameter>();
            string viewUDF = "dbo.ICD_10_CM_CODES_VIEW(@userID, @userGroup, @userRank, @term, @recID)";

            parms.Add(Database.SqlParm("@term", SqlDbType.VarChar, term, ParameterDirection.Input, 256));

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
         * 
         ***************************************************************************/

        public static ReturnSel viewSel(SqlConnection connSpedmon
                                         , DetailsLog log
                                         , UserInfo uInfo
                                         , bool paged
                                         , string pageNumber
                                         , string active
                                         , string term
                                         )
        {

            string vTerm = Validate.optString(term);

            /*----------------------------
             * Define our context column
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
            };

            return Entities.viewSel(connSpedmon, log, uInfo, paged, pageNumber,
              delegate { return ICD10CMCodes.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, vTerm, dc); });
        }

    }
}
