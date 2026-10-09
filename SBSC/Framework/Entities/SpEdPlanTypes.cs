using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using MBA;


namespace Spedmon
{
    public class SpEdPlanType : Entity
    {
        public string codeSetName;
        public int    codeValue;
        public string definition;
        public string codeName;
    }

    /***************************************************************************
     * SpEdPlanTypes */
    /**
     ***************************************************************************/

    public class SpEdPlanTypes : Entities
    {
        public const string URL_SERVICE_BASE            = @"sped_plan_types.asmx";
        public const string URL_VIEW_SEL                = URL_SERVICE_BASE + @"/viewSel";

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

            List<SqlParameter> parms = new List<SqlParameter>();
            string viewUDF = "dbo.SPED_PLAN_TYPE_VIEW (@userID, @userGroup, @userRank, @term, @recID)";

            parms.Add(Database.SqlParm("@term", SqlDbType.VarChar, term, ParameterDirection.Input, 1000));

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
                                         , string term)
        {

            string vTerm = Validate.optString(term);

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {
            };

            return Entities.viewSel(connSpedmon, log, uInfo, paged, pageNumber,
              delegate { return SpEdPlanTypes.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, vTerm, dc); });
        }

        /***************************************************************************
         * load */
        /**
         * 
         ***************************************************************************/

        public static SpEdPlanType load(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string recID)
        {
          return (SpEdPlanType)Entities.load(connSpedmon, log, uInfo, recID, typeof(SpEdPlanType),
          delegate { return SpEdPlanTypes.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "" , "", "", null); });
        }

        }
}
