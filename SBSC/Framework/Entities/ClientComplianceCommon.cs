using MBA;
using System.Collections.Generic;

using System.Data;
using System.Data.SqlClient;

namespace Spedmon
{
    public class ClientComplianceCommon : Entities
    {
        public const string OUTSTANDING_TASKS_TAB_ID = @"1";
        public const string ALL_TASKS_TAB_ID         = @"2";

        public const string MENU_ID_MANAGE           = @"clientcompliancemanage";
        public const string SEL_LABEL_MANAGE         = @"Manage Client Compliance Tasks";
        public const string URL_MANAGE               = @"user_all_client_compliance_manage.aspx";

        public const string URL_WEB_SERVICE          = @"client_compliance_common.asmx";
        public const string URL_SAVE_FOR_CLIENTS     = URL_WEB_SERVICE + "/saveItemForClients";

        public static string URL_SAVE_FOR_CLIENTS_BASE() {
            return MBA.HttpApplication.createLink(URL_SAVE_FOR_CLIENTS, true);
        }

        /// <summary>
        /// Add status filter selections to ctrlItemStatus
        /// </summary>
        public static void addStatusFilterSelections (ref MBA.RadioBox ctrlItemStatus)
        {
          /* Add filter options */
      
          ctrlItemStatus.AddSelection(@"Not Completed", "2" );
          ctrlItemStatus.AddSelection(@"Completed",     "3");
          ctrlItemStatus.AddSelection(@"Pending",       "1");
          ctrlItemStatus.AddSelection(@"Any Status",    "0", true);
        }

        /// <summary>
        /// Saves a client compliance item and creates a record for every client for that item
        /// </summary>
        public static ReturnSaveRecord saveItemForClients(SqlConnection connSpedmon
                                         , DetailsLog log
                                         , UserInfo uInfo
                                         , string taskID
                                         , string dueDate
                                         , string dateToShowOnDashboard
                                         

                                         , string forAllClients
                                         , string clientID

                                         , string isComplete

                                         , string editDelReason
                                         , string validateRec
                                         , string saveType
                                         , string recID)
        {            
            string saveSproc = @"CLIENT_COMPLIANCE_ITEM_SAVE_FOR_CLIENTS_ONE_OR_ALL";
            string dupRecMsg = @"This client compliance item already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vTaskID                = Validate.reqInteger(taskID               , Messages.INVALID_TASK_ID);
            var vDueDate               = Validate.reqDate   (dueDate              , "Invalid Due Date");
            var vDateToShowOnDashboard = Validate.reqDate   (dateToShowOnDashboard, "Invalid date to show on dashboard");
            var vIsComplete            = Validate.optFlag   (isComplete           , Messages.INVALID_FLAG);

            var vForAllClients         = Validate.reqFlag( forAllClients , "add for all clients?");

            int? vClientID;
            if (! (vForAllClients))
                vClientID = Validate.reqClientID(uInfo, clientID);
            else
                vClientID = null;


            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@taskID"               , SqlDbType.BigInt, vTaskID               , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@dueDate"              , SqlDbType.Date  , vDueDate              , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@dateToShowOnDashboard", SqlDbType.Date  , vDateToShowOnDashboard, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@isComplete"           , SqlDbType.Bit   , vIsComplete           , ParameterDirection.Input));


            //parms.Add(Database.SqlParm("@forAllClients", SqlDbType.Date, vDateToShowOnDashboard, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));


            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
        }
    }
}
