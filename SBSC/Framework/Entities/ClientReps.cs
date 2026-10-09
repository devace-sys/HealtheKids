using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;



namespace Spedmon
{
    /***************************************************************************
     * CompaniesList */
    /**
     * 
     ***************************************************************************/

    public class ClientReps : Entities
    {
        /***************************************************************************
         * viewSel */
        /**
         * Returns a list of Client Reps
         * 
         ***************************************************************************/

        public static ReturnSel viewSel (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, bool top, string topSize)
        {

            /*----------------------------
             * Define our context column
             *----------------------------*/

            defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                
            };

            /*----------------------------
              * Call base method which
              * handles the rest and return
              * results
              *----------------------------*/

            return Entities.viewSel(connSpedmon, log, uInfo, top, topSize,
            delegate { return ClientReps.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, "", "1", dc); });

            //TODO: The Entities.viewSel function is small tiny, it does almost nothing accept call the delegate function that gets passed in.
            //I would consider not even using it.

        }

        /***************************************************************************
         * view */
        /**
         * Returns a list of Client Reps
         * 
         ***************************************************************************/

        public static ReturnDB view(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                     int recViewType,
                                     bool pagedOrTop,
                                     string idx,
                                     string canEdit,
                                     string active,
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
            string viewUDF = "dbo.CLIENT_REPS_VIEW(@userID, @userGroup, @userRank, @active, @recID)";

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        /***************************************************************************
         * getPcalStaffAssociatedRepID */
        /** 
         ***************************************************************************/
        public static ReturnValue getPcalStaffAssociatedRepID (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo) 
        {  
          var so     = new ReturnValue();
          var sql    = @"select top 1 @value = convert(varchar(max),isnull(ccr.id,0)) from dbo.CLIENTS_Client_Reps as ccr where (ccr.[user_id] = @userID)";
          var vValue = @"";
          var parms  = new List<SqlParameter>();

          parms.Add(Database.SqlParm("@userID",  SqlDbType.BigInt,  uInfo.userid, ParameterDirection.Input));   
          parms.Add(Database.SqlParm("@value",   SqlDbType.VarChar, vValue,       ParameterDirection.Output, -1));

          var rd = Database.execQuery(connSpedmon, log, sql, false, parms);
          vValue = (String) Database.getParameterValue("@value", ref parms);
          so.value = vValue;

          return so;
        }

    }
}

