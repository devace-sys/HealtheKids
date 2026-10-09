using MBA;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;



namespace Spedmon
{

    public class ClientComplianceClientItem : ClientComplianceItem
    {
        public const string DEFAULT_PAGING_ORDER = @"taskName asc, clientName asc";

        public long     clientID;
        public string   clientName;
        public long     clientComplianceItemID;
        public bool     isComplete;
        public DateTime dateCompleted;
        public string   dateCompletedStr;
        public string   dateCompletedStrYMD;

        //public DateTime revisedGracePeriodEnd;
        //public string  revisedGracePeriodEndStr;
        //public string  revisedGracePeriodEndStrYMD;

        public string descriptiveRankingPerClientFyTask;

    }

    public class ClientComplianceClientItems : Entities
    {

        public const string URL_WEB_SERVICE = "client_compliance_client_items.asmx";
        public const string URL_SAVE   = URL_WEB_SERVICE + "/save";

        public const string URL_DELETE_INLINE = URL_WEB_SERVICE + "/deleteinline";

        public const string URL_REST_VIEW = @"api/v1/clientcomplianceclientitems";

        public const string URL_WEB_REPORT = @"client_compliance_client_items.ashx";


        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(URL_REST_VIEW, true);
        }

        public static string URL_WEB_REPORT_BASE()
        {
            return MBA.HttpApplication.createLink(URL_WEB_REPORT , true);
        }

        public static string URL_DELETE_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink( URL_DELETE_INLINE , true);
        }

        public static string URL_SAVE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_SAVE, true);
        }

        public static ReturnDB view(SqlConnection connSpedmon
                                     , DetailsLog log
                                     , UserInfo uInfo
                                     , int recViewType
                                     , bool pagedOrTop
                                     , string idx
                                     , string canEdit
                                     , string active
                                     , string clientID
                                     , string taskID
                                     , string isPending
                                     , string isNotCompleted
                                     , string isCompleted

                                     , string fyID
                                     , defineCols dc
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

            string viewUDF = "dbo.CLIENT_COMPLIANCE_CLIENT_ITEMS_VIEW (@userID, @userGroup, @userRank, @clientID, @taskID, @isPending, @isNotCompleted, @isCompleted, @active, @recID, @fyID )";

            var vClientID       = Validate.optClientID (uInfo,          clientID);
            var vTaskID         = Validate.optInteger  (taskID,         Messages.INVALID_TASK_ID);
            var vIsPending      = Validate.optFlag     (isPending,      Messages.INVALID_FLAG);
            var vIsNotCompleted = Validate.optFlag     (isNotCompleted, Messages.INVALID_FLAG);
            var vIsCompleted    = Validate.optFlag     (isCompleted,    Messages.INVALID_FLAG);

            var vfyID           = Validate.optInteger(fyID, Messages.INVALID_FISCAL_YEAR_ID);


            parms.Add(Database.SqlParm("@clientID",       SqlDbType.BigInt,  vClientID,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@taskID",         SqlDbType.BigInt,  vTaskID,         ParameterDirection.Input));
            parms.Add(Database.SqlParm("@isPending",      SqlDbType.Bit,     vIsPending,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@isNotCompleted", SqlDbType.Bit,     vIsNotCompleted, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@isCompleted",    SqlDbType.Bit,     vIsCompleted,    ParameterDirection.Input));

            parms.Add(Database.SqlParm("@fyID", SqlDbType.BigInt, vfyID, ParameterDirection.Input));


            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
        }

        public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                           , DetailsLog log
                                           , UserInfo uInfo
                                           , bool pageObjectList
                                           , string pageOrder
                                           , string idx
                                           , string active
                                           , string clientID
                                           , string taskID
                                           , string isPending
                                           , string isNotCompleted
                                           , string isCompleted

                                           , string fyID
                                           )
        {
            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = ClientComplianceClientItem.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(ClientComplianceClientItem)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return view(connSpedmon
                                                        , log
                                                        , uInfo
                                                        , Entities.REC_VIEW_OBJECTS
                                                        , pageObjectList
                                                        , idx
                                                        , "" // canEdit
                                                        , active
                                                        , clientID
                                                        , taskID
                                                        , isPending
                                                        , isNotCompleted
                                                        , isCompleted

                                                        , fyID
                                                        , dc
                                               );
                                          });
        }

        public static ReturnSaveRecord save(SqlConnection connSpedmon
                                         , DetailsLog log
                                         , UserInfo uInfo
                                         , string clientID				
                                         , string clientComplianceItemID 
                                         , string notes
                                         , string isComplete

                                        , string dueDate
                                        , string dateToShowonDashboard

                                        , string editDueDateAllClients
                                        , string editDashboardDateAllclients

                                        , string taskName

                                         , string dateCompleted
                                         , string editDelReason
                                         , string validateRec
                                         , string saveType
                                         , string recID)
        {


            string saveSproc = @"CLIENT_COMPLIANCE_CLIENT_ITEM_SAVE";
            string dupRecMsg = @"This client compliance item already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vClientID				= Validate.reqInteger(clientID				, Messages.INVALID_CLIENT_ID);
            var vClientComplianceItemID = Validate.reqInteger(clientComplianceItemID, Messages.INVALID_ENTITY_ID);
            var vNotes                  = Validate.optString (notes                 , Messages.INVALID_NOTES);
            var vIsComplete             = Validate.optFlag   (isComplete            , Messages.INVALID_FLAG);
            var vDateCompleted          = Validate.optDate   (dateCompleted         , Messages.INVALID_DATE);

             var vDueDate = Validate.reqDate(dueDate, Messages.INVALID_DATE);

             var vDateToShowonDashboard = Validate.reqDate(dateToShowonDashboard, Messages.INVALID_DATE);

            var vEditDueDateAllClients = Validate.optFlag(editDueDateAllClients , "invalid flag option");

            var vEditDashboardDateAllclients = Validate.optFlag(editDashboardDateAllclients , "invalid flag option" );

            var vTaskName = Validate.reqString(taskName, "invalid task name");



            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"              , SqlDbType.BigInt  , vClientID			     , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@clientComplianceItemID", SqlDbType.BigInt  , vClientComplianceItemID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@notes"                 , SqlDbType.NVarChar, vNotes                 , ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@isComplete"            , SqlDbType.Bit     , vIsComplete            , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@dateCompleted"         , SqlDbType.DateTime, vDateCompleted         , ParameterDirection.Input));

             parms.Add(Database.SqlParm("@dueDate", SqlDbType.DateTime, vDueDate, ParameterDirection.Input));

             parms.Add(Database.SqlParm("@dashboardDate", SqlDbType.DateTime, vDateToShowonDashboard, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@editDueDateAllClients",        SqlDbType.Bit, vEditDueDateAllClients, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@editDashboardDateAllClients",  SqlDbType.Bit, vEditDashboardDateAllclients, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@taskName", SqlDbType.VarChar, vTaskName, ParameterDirection.Input, 256));


            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
        }


        public static ReturnSaveRecord delete(SqlConnection connApp
                                                         , DetailsLog log
                                                         , UserInfo uInfo
                                                         , string   deleteForAllClients
                                                         , string recID)
        {

            var opSproc = "CLIENT_COMPLIANCE_ITEMS_DELETE";
            var parms = new List<SqlParameter>();

            var vDeleteForAllClients = Validate.reqFlag(deleteForAllClients, "delete for all clients?");

            parms.Add(
                Database.SqlParm("@deleteForAllClients", SqlDbType.Bit, vDeleteForAllClients, ParameterDirection.Input, 50)
            );

            return Entities.recordOp(connApp, log, uInfo, "", "0", recID, opSproc, ref parms);


        }

        public static ReturnDataTable viewTbl(
              SqlConnection connSpedmon,
              DetailsLog log,
              UserInfo uInfo,
              bool paged,
              string pageNumber,

              string clientID
            , string taskID
            , string isPending
            , string isNotCompleted
            , string isCompleted
            , string fyID)
        {

            
            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {

                if (uInfo.pcalStaff)
                    ss.addDisplayColumn("[clientName] as [Client Name]");

                ss.addDisplayColumn("taskName                             as   [Task]");
                ss.addDisplayColumn("descriptiveRankingPerClientFyTask    as   [Item Count]");

                ss.addDisplayColumn("isComplete       as   [Completed ?]");
                
                ss.addDisplayColumn("dueDateStrYMD                        as   [Due Date]");
                ss.addDisplayColumn("dateToShowOnDashboardStrYMD          as   [Dashboard Date]");
                ss.addDisplayColumn("dateCompletedStrYMD                  as   [Date Completed]");
                ss.addDisplayColumn("notes                                as   [Notes]");

                ss.addDisplayColumn("lastModifiedByNameStr                as   [Last Edit By]");
                ss.addDisplayColumn("lastModifiedStr                      as   [lastModified]");

                pageroworder = "dueDate ASC, taskName ASC";
            };

            return Entities.viewTbl(
                connSpedmon, log, uInfo, paged, pageNumber,
                   delegate
                   {


                       return ClientComplianceClientItems.view(
                            connSpedmon
                         , log
                         , uInfo
                         , Entities.REC_VIEW_TBL // int recViewType

                         , paged
                         , pageNumber

                         , "" // string canEdit
                         , "Y"
                         , clientID

                         , taskID
                         , isPending
                         , isNotCompleted
                         , isCompleted
                         , fyID

                         , dc);
                   }
                 , @"Compliance Tasks"
              , Messages.CONFIDENTIAL
              );
        }

    }
}

