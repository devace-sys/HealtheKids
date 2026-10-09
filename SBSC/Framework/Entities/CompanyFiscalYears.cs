using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using MBA;


namespace Spedmon
{

    public class CompanyFiscalYear : Entity
    {
        public long ID; // { set { this.id = value; } get { return this.id; } }

                        // is case sensitive...
    }

    /***************************************************************************
     * CompanyFiscalYears */
    /**
     ***************************************************************************/

    public class CompanyFiscalYears : Entities
    {
        public const string URL_WEB_SERVICE = @"company_fiscal_years.asmx";
        public const string URL_VIEW_SEL    = URL_WEB_SERVICE + @"/viewSel";
        public const string URL_VIEW_SEL2   = URL_WEB_SERVICE + @"/viewSel2";

        /***************************************************************************
         * URL_REST_VIEW_SEL */
        /**
         * 
         **************************************************************************/ 
        public static string URL_REST_VIEW_SEL()
        {
          return MBA.HttpApplication.createLink(CompanyFiscalYears.URL_VIEW_SEL, true);
        }

        /***************************************************************************
         * URL_REST_VIEW_SEL */
        /**
         * 
         **************************************************************************/ 
        public static string URL_REST_VIEW_SEL2()
        {
          return MBA.HttpApplication.createLink(CompanyFiscalYears.URL_VIEW_SEL2, true);
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
                                     , string yearsBack
                                     , string yearsForward
                                     , string year
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
            string viewUDF = "dbo.COMPANY_FISCAL_YEARS_VIEW (@userID, @userGroup, @userRank, @yearsBack, @yearsForward, @year, @term, @recID)";

            /*----------------------------
            * Validate parameters specific
            * to this entity.view
            * and populate their
            * coresponding database
            * parameters
            *----------------------------*/

            Object vYearsBack    = Validate.optString(yearsBack   , Messages.INVALID_NUMBER);
            Object vYearsForward = Validate.optString(yearsForward, Messages.INVALID_NUMBER);
            Object vYear         = Validate.optDate  (year        , Messages.INVALID_REF_DATE);
            Object vTerm         = Validate.optString(term        , Messages.INVALID_SEARCH_TERM);

            parms.Add(Database.SqlParm("@yearsBack"    , SqlDbType.Int      , vYearsBack    , ParameterDirection.Input      ));
            parms.Add(Database.SqlParm("@yearsForward" , SqlDbType.Int      , vYearsForward , ParameterDirection.Input      ));
            parms.Add(Database.SqlParm("@year"         , SqlDbType.DateTime , vYear         , ParameterDirection.Input      ));
            parms.Add(Database.SqlParm("@term"         , SqlDbType.VarChar  , vTerm         , ParameterDirection.Input, 1000));

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
                                         , string term
                                         , string yearsBack
                                         , string yearsForward
                                         , string year)
        {

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {

              //pageroworder = "id desc";

              // NOTE: doesn't work.

              // apparently

                 //  pageroworder = "order by " + pageroworder;
                 //  sb.Append(pageroworder);

              // are called only under 
                 // else if (rowlimit == ROW_LIMIT_PAGED) {

              // ...
              // but before that, whenever
                 //  recViewType == REC_VIEW_SEL
              // then
                 //  rowLimit = Database.ROW_LIMIT_TOP


              // I guess that means that ViewSel queries have to have the ORDER BY
              // defined in the UDF; in middleware it doesn't do anything
            };

            return Entities.viewSel(connSpedmon, log, uInfo, paged, pageNumber,
              delegate { return CompanyFiscalYears.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", "1", term, yearsBack, yearsForward, year, dc); });
        }

        /***************************************************************************
         * load */
        /**
         * 
         ***************************************************************************/

        public static CompanyFiscalYear load(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string recID)
        {
            return (CompanyFiscalYear)Entities.load(connSpedmon, log, uInfo, recID, typeof(CompanyFiscalYear),
            delegate { return CompanyFiscalYears.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", "", "0", "0", "", null); });
        }

        public static CompanyFiscalYear loadCurrent(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo)
        {
            return (CompanyFiscalYear)Entities.load(null, null, null, typeof(CompanyFiscalYear),
            delegate { return CompanyFiscalYears.view(connSpedmon, log, uInfo, Entities.REC_VIEW_OBJECT, false, "", "", "", "", "0", "0", DateTime.Now.ToString(), null); });
                                                                               // REC_VIEW_LOAD doesn't work with a blank idx/recID
        }

    }
}
