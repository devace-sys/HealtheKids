using MBA;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace Spedmon
{
    public class ClientComplianceItem : Entity
    {
        public long     taskID;
        public string   taskName;

        public DateTime dueDate;
        public string   dueDateStr;
        public string   dueDateStrYMD;

        public DateTime dateToShowOnDashboard;
        public string   dateToShowOnDashboardStr;
        public string   dateToShowOnDashboardStrYMD;

        public long     fyID;

        public string   FY_DEFINITION;

        public string   lastModifiedByNameStr;

        public DateTime  lastModified;

        public string    lastModifiedStr;


    }

    public class ClientComplianceItems : Entities
    {
        public const string URL_WEB_SERVICE = "client_compliance_items.asmx";
        public const string URL_LOAD_N = URL_WEB_SERVICE + "/loadN";

        public static string URL_SAVE = URL_WEB_SERVICE + "/save";

        public static string URL_SAVE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_SAVE, true);
        }

        public static string URL_LOAD_N_BASE()
        {
            return MBA.HttpApplication.createLink(URL_LOAD_N, true);
        }

        public static ReturnDB view(SqlConnection connSpedmon
                                     , DetailsLog log
                                     , UserInfo uInfo
                                     , int recViewType
                                     , bool pagedOrTop
                                     , string idx
                                     , string canEdit
                                     , string active
                                     , string taskID
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
            string viewUDF = "dbo.CLIENT_COMPLIANCE_ITEMS_VIEW (@userID, @userGroup, @userRank, @taskID, @active, @recID)";

            var vTaskID = Validate.optInteger(taskID, Messages.INVALID_TASK_ID);


            parms.Add(Database.SqlParm("@taskID", SqlDbType.BigInt, vTaskID, ParameterDirection.Input));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
        }
        
        public static ClientComplianceItem loadN(SqlConnection connSpedmon
                                     , DetailsLog log
                                     , UserInfo uInfo
                                     , int n
                                     , string active
                                     , string taskID
                                     , string recID
        )
        {

            return (ClientComplianceItem)Entities.loadNRecord(connSpedmon
                                                     , log
                                                     , uInfo
                                                     , n
                                                     , typeof(ClientComplianceItem)
                                                     , delegate
                                                     {
                                                         return view(connSpedmon
                                                                   , log
                                                                   , uInfo
                                                                   , Entities.REC_VIEW_LOAD_N
                                                                   , false
                                                                   , recID
                                                                   , ""
                                                                   , active
                                                                   , taskID
                                                                   , null);
                                                     });
        }

        public static ReturnSaveRecord save(SqlConnection connSpedmon
                                         , DetailsLog log
                                         , UserInfo uInfo
                                         , string taskID
                                         , string dueDate			  
                                         , string dateToShowOnDashboard
                                         , string editDelReason
                                         , string validateRec
                                         , string saveType
                                         , string recID)
        {

            string saveSproc = @"CLIENT_COMPLIANCE_ITEM_SAVE";
            string dupRecMsg = @"This client compliance item already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vTaskID                = Validate.reqInteger(taskID               , "Invalid Task");
            var vDueDate               = Validate.reqDate   (dueDate              , "Invalid Due Date");
            var vDateToShowOnDashboard = Validate.reqDate   (dateToShowOnDashboard, "Invalid date to show on dashboard");

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@taskID"               , SqlDbType.BigInt, vTaskID               , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@dueDate"              , SqlDbType.Date  , vDueDate              , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@dateToShowOnDashboard", SqlDbType.Date  , vDateToShowOnDashboard, ParameterDirection.Input));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
        }

    }
}

