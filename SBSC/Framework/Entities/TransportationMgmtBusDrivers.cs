using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using MBA;


namespace Spedmon
{
    public class TransportationMgmtBusDriver : Entity
    {
        public long   clientID;
        public string firstName;
        public string lastName;
    }

    /***************************************************************************
     * TransportationMgmtBusDrivers */
    /**
     ***************************************************************************/

    public class TransportationMgmtBusDrivers : Entities
    {
        public const string URL_SERVICE_BASE            = @"transportation_mgmt_bus_drivers.asmx";
        public const string URL_VIEW_SEL                = URL_SERVICE_BASE + @"/viewSel";
        public const string URL_SAVE                    = URL_SERVICE_BASE + @"/save";
        public const string URL_DELETE                  = URL_SERVICE_BASE + @"/delete";
        public const string URL_VIEW_ENTITY             = URL_SERVICE_BASE + @"/viewEntity";

        public static string URL_VIEW_SEL_BASE()
        {
          return MBA.HttpApplication.createLink(TransportationMgmtBusDrivers.URL_VIEW_SEL, true);
        }

        public static string URL_SAVE_BASE()
        {
            return MBA.HttpApplication.createLink(TransportationMgmtBusDrivers.URL_SAVE, true);
        }

        public static string URL_DELETE_BASE()
        {
            return MBA.HttpApplication.createLink(TransportationMgmtBusDrivers.URL_DELETE, true);
        }

        public static string URL_VIEW_ENTITY_BASE()
        {
            return MBA.HttpApplication.createLink(TransportationMgmtBusDrivers.URL_VIEW_ENTITY, true);
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

            var vClientID = Validate.reqClientID(uInfo, clientID);

            List<SqlParameter> parms = new List<SqlParameter>();

            string viewUDF = "dbo.TRANSPORTATION_MGMT_BUS_DRIVERS_VIEW (@userID, @userGroup, @userRank, @clientID, @term)";

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt , vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@term"    , SqlDbType.VarChar, term     , ParameterDirection.Input, 1000));

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
                                         , string clientID
                                         , string term)
        {

            string vTerm = Validate.optString(term);

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {
                ss.addDisplayColumn("firstName      as [recData1]");
                ss.addDisplayColumn("lastName       as [recData2]");
            };

            return Entities.viewSel(connSpedmon, log, uInfo, paged, pageNumber,
              delegate { return TransportationMgmtBusDrivers.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, clientID, vTerm, dc); });
        }

        /***************************************************************************
         * save */
        /**
         * 
         ***************************************************************************/
        public static Return save (SqlConnection dbConnSpedmon
                                , DetailsLog log
                                , UserInfo uInfo
                                , string clientID
                                , string firstName
                                , string lastName
                                , string editDelReason
                                , string validateRec
                                , string saveType
                                , string recID)
        {
            string saveSproc = @"TRANSPORTATION_MGMT_BUS_DRIVERS_SAVE";
            string dupRecMsg = @"Record already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vClientID  = Validate.reqClientID(uInfo    , clientID);
            var vFirstName = Validate.optString  (firstName, @"Invalid first name");
            var vLastName  = Validate.reqString  (lastName , @"Invalid last name");

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID" , SqlDbType.BigInt , vClientID , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@firstName", SqlDbType.VarChar, vFirstName, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@lastName" , SqlDbType.VarChar, vLastName , ParameterDirection.Input, 50));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.save(dbConnSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
        }

        /***************************************************************************
        * delete */
        /**
         *
         ***************************************************************************/

        public static ReturnSaveRecord delete(SqlConnection connSpedmon
                                               , DetailsLog log
                                               , UserInfo uInfo
                                               , string editDelReason
                                               , string validateRec
                                               , string recID)
        {

            string deleteSproc = @"TRANSPORTATION_MGMT_BUS_DRIVERS_DELETE";

            /*###########################################################################
              # Validate parameters specific to this entity delete and create their 
              # database parameters.
              ###########################################################################*/

            var vClientID = Validate.optClientID(uInfo, "");

            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, deleteSproc, ref parms);
        }

        /***************************************************************************
        * load */
        /**
         * 
         ***************************************************************************/

        public static TransportationMgmtBusDriver load(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                         string clientID, string recID)
        {
            return (TransportationMgmtBusDriver)Entities.load(connSpedmon, log, uInfo, recID, typeof(TransportationMgmtBusDriver),
            delegate { return TransportationMgmtBusDrivers.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", clientID, "", null); });
        }

        /***************************************************************************
        * viewEntity */
        /**
         * 
         ***************************************************************************/
        public static ReturnEntity viewEntity(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                         string clientID, string recID)
        {
            ReturnEntity so = new ReturnEntity();
            TransportationMgmtBusDriver t = TransportationMgmtBusDrivers.load(connSpedmon, log, uInfo, clientID, recID);
            so.entity = (Entity)t;
            return so;
        }

    }
}
