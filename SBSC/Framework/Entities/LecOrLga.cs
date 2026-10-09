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
     * LecOrLgaRecord */
    /**
     *
     **************************************************************************/

    public class LecOrLgaRecord : Entity
    {
    }

    /***************************************************************************
     * LecOrLga */
    /**
     ***************************************************************************/

    public class LecOrLga : Entities
    {       

        /***************************************************************************
         * view */
        /** 
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
                                     , string term
                                     , defineCols dc)
        {

            string viewUDF = "dbo.LEC_OR_LGA_VIEW (@userID, @userGroup, @userRank, @active, @term, @recID)";

            /*----------------------------
            * Validate parameters specific
            * to this entity.view
            * and populate their
            * coresponding database
            * parameters
            *----------------------------*/

            Object vTerm = Validate.optString(term, Messages.INVALID_SEARCH_TERM);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@term", SqlDbType.VarChar, vTerm, ParameterDirection.Input, 50));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        /*************************************************************************
        * viewList */
        /**
         * 
         ***************************************************************************/

        public static List<LecOrLgaRecord> viewList(SqlConnection connSpedmon
                                                             , DetailsLog log
                                                             , UserInfo uInfo
                                                             , string active)

        {
            var recs = new List<LecOrLgaRecord>();
            ReturnDB rd = LecOrLga.view(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, null, null, active, "", null);
            List<Object> slo = Database.convertRecordsToList(ref rd.records, typeof(LecOrLgaRecord));
            foreach (var o in slo)
            {
                recs.Add((LecOrLgaRecord)o);
            }
            return recs;
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
         * @return                 ReturnEntity
         ***************************************************************************/

        public static LecOrLgaRecord load(SqlConnection connSpedmon
                                                     , DetailsLog log
                                                     , UserInfo uInfo
                                                     , string recID)
        {
            return (LecOrLgaRecord)Entities.load(connSpedmon, log, uInfo, recID, typeof(LecOrLgaRecord),
            delegate { return LecOrLga.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, "", "", "1", "", null); });
        }

        /***************************************************************************
         * viewSel */
        /**
         * 
         ***************************************************************************/

        public static ReturnSel viewSel(SqlConnection connSpedmon
                                         , DetailsLog log
                                         , UserInfo uInfo
                                         , bool top
                                         , string topSize
                                         , string term)
        {

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {
                ss.addDisplayColumn("[name] as recData1");
            };

            return Entities.viewSel(connSpedmon
                                    , log
                                    , uInfo
                                    , top
                                    , topSize
                                    , delegate {
                                        return LecOrLga.view(connSpedmon
                                                           , log
                                                           , uInfo
                                                           , Entities.REC_VIEW_SEL
                                                           , top
                                                           , topSize
                                                           , ""
                                                           , "1"
                                                           , term
                                                           , dc);
                                    });


        }

    }
}
