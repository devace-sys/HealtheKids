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
     * SpEdAssessmentTools */
    /**
     ***************************************************************************/

    public class SpEdAssessmentTools : Entities
    {

        public const string URL_SERVICE_BASE = @"sped_assessment_tools.asmx";
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
                                    , string domain
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
            string viewUDF = "dbo.SPED_ASSESSMENT_TOOLS_VIEW (@userID, @userGroup, @userRank, @domain, @term)";

            parms.Add(Database.SqlParm("@domain", SqlDbType.VarChar, domain, ParameterDirection.Input, 50));
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
         * General tools for all domains
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
             delegate { return SpEdAssessmentTools.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, null, vTerm, dc); });
        }

        /***************************************************************************
         * viewSelReading */
        /**
         * Reading domain tools
         ***************************************************************************/

        public static ReturnSel viewSelReading(SqlConnection connSpedmon
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
             delegate { return SpEdAssessmentTools.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, "READING", vTerm, dc); });
        }

        /***************************************************************************
         * viewSelWriting */
        /**
         * Writing domain tools
         ***************************************************************************/

        public static ReturnSel viewSelWriting(SqlConnection connSpedmon
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
             delegate { return SpEdAssessmentTools.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, "WRITING", vTerm, dc); });
        }

        /***************************************************************************
         * viewSelMath */
        /**
         * Math domain tools
         ***************************************************************************/

        public static ReturnSel viewSelMath(SqlConnection connSpedmon
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
             delegate { return SpEdAssessmentTools.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, "MATH", vTerm, dc); });
        }

        /***************************************************************************
         * viewSelCommunicationDev */
        /**
         * Communication Development domain tools
         ***************************************************************************/

        public static ReturnSel viewSelCommunicationDev(SqlConnection connSpedmon
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
             delegate { return SpEdAssessmentTools.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, "COMMUNICATION_DEV", vTerm, dc); });
        }

        /***************************************************************************
         * viewSelGrossFineMotor */
        /**
         * Gross/Fine Motor domain tools
         ***************************************************************************/

        public static ReturnSel viewSelGrossFineMotor(SqlConnection connSpedmon
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
             delegate { return SpEdAssessmentTools.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, "GROSS_FINE_MOTOR", vTerm, dc); });
        }

        /***************************************************************************
         * viewSelHealth */
        /**
         * Health domain tools
         ***************************************************************************/

        public static ReturnSel viewSelHealth(SqlConnection connSpedmon
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
             delegate { return SpEdAssessmentTools.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, "HEALTH", vTerm, dc); });
        }

        /***************************************************************************
         * viewSelVocational */
        /**
         * Vocational domain tools
         ***************************************************************************/

        public static ReturnSel viewSelVocational(SqlConnection connSpedmon
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
             delegate { return SpEdAssessmentTools.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, "VOCATIONAL", vTerm, dc); });
        }

        /***************************************************************************
         * viewSelAdaptiveDailyLiving */
        /**
         * Adaptive/Daily Living domain tools
         ***************************************************************************/

        public static ReturnSel viewSelAdaptiveDailyLiving(SqlConnection connSpedmon
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
             delegate { return SpEdAssessmentTools.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, "ADAPTIVE_DAILY_LIVING", vTerm, dc); });
        }

        /***************************************************************************
         * viewSelSocialEmotionalBehavioral */
        /**
         * Social/Emotional/Behavioral domain tools
         ***************************************************************************/

        public static ReturnSel viewSelSocialEmotionalBehavioral(SqlConnection connSpedmon
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
             delegate { return SpEdAssessmentTools.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, "SOCIAL_EMOTIONAL_BEHAVIORAL", vTerm, dc); });
        }

    }
}