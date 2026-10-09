using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;



namespace Spedmon
{
    /***************************************************************************
     * PatExpectedService */
    /**
    ***************************************************************************/
     public class PatExpectedService : Entity {
        public string startDateStr;
        public int minsAnn;
        public int minsInd;
        public int minsGrp;
        public int planType;
        public string weekDaysJSON;
    }

    /***************************************************************************
     * PatExpectedServices */
    /**
     * 
     ***************************************************************************/

    public class PatExpectedServices : Entities
    {
        public const string URL_ASMX               = "pat_expected_services.asmx";
        public const string URL_ASMX_LOAD_PAT_DATA = URL_ASMX + "/loadLatestPatData";

        /**************************************************************************
         * GEN_URL_ASMX_LOAD_PAT_DATA
         **************************************************************************/
        public static string GEN_URL_ASMX_LOAD_PAT_DATA()
        {
            return MBA.HttpApplication.createLink(URL_ASMX_LOAD_PAT_DATA, true);
        }

        /***************************************************************************
         * view */
        /**
         * Returns a list of records for given criteria
         * 
         ***************************************************************************/

        public static ReturnDB view (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
                                     int    recViewType,
                                     bool   pagedOrTop,
                                     string idx,
                                     string canEdit,
                                     string active,
                                     string clientID, 
                                     string pracID,
                                     string patID,
                                     defineCols dc)
        {
            string viewUDF = "PATIENTS_EXPECTED_SERVICES_VIEW(@userID, @userGroup, @userRank, @clientID, @pracID, @patID)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

            long vClientID = Validate.reqClientID(uInfo, clientID);
            long vPracID   = Validate.reqPracID(uInfo, pracID);
            long vPatID    = Validate.reqInteger(patID, Messages.INVALID_PAT_ID);

            // add params
            
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID",   SqlDbType.Int, vPracID,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID",    SqlDbType.Int, vPatID,    ParameterDirection.Input));          

          /*----------------------------
           * Call base method which
           * handles the rest and return
           * results
           *----------------------------*/
          
          return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      

        }

        /***************************************************************************
        * loadLatestPatData */
        /**
        * Returns the latest data for the selected patient
        * 
        ***************************************************************************/

        public static ReturnEntity loadLatestPatData(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                     string clientID,
                                     string pracID,
                                     string patID)
        {            

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            ReturnEntity so = new ReturnEntity();
            so.entity = (PatExpectedService)Entities.loadNRecord(connSpedmon, log, uInfo, 0, typeof(PatExpectedService),
                delegate
                {
                    return PatExpectedServices.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD_N, false, "", "", "Y", clientID, pracID, patID, null);
                }
            );

            return so;
        }
    }
}

