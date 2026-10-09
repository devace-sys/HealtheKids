using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;



namespace Spedmon
{
    /***************************************************************************
     * ClaimsProcessingExceptionList */
    /**
     * 
     ***************************************************************************/

    public class ClaimsProcessingExceptionList : Entities
    {
        /***************************************************************************
         * viewSel */
        /**
         * Returns a list of CLAIMS_PROCESSING_EXCEPTION_LIST
         * 
         ***************************************************************************/

        public static ReturnSel viewSel(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, bool top, string topSize)
        {          

            /*----------------------------
             * Define our context column
             *----------------------------*/

            defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("Description as context1");
            };

            /*----------------------------
              * Call base method which
              * handles the rest and return
              * results
              *----------------------------*/

            return Entities.viewSel(connSpedmon, log, uInfo, top, topSize,
            delegate { return ClaimsProcessingExceptionList.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, "", "1", dc); });

        }

        /***************************************************************************
         * view */
        /**
         * Returns a list of CLAIMS_PROCESSING_EXCEPTION_LIST
         * 
         ***************************************************************************/

        public static ReturnDB view(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                     int        recViewType,
                                     bool       pagedOrTop,
                                     string     idx,
                                     string     canEdit,
                                     string     active,                      
                                     defineCols dc
                                     )
        {

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();
            string viewUDF = "dbo.CLAIMS_PROCESSING_EXCEPTION_LIST_VIEW(@userID, @userGroup, @userRank, @recID)";
           
            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }  
    }
}
