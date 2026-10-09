using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    /***************************************************************************
     * ServiceJournalRecentProcedureEntry */
    /**
     * Service Journal Recent Procedure Entry
     **************************************************************************/

    public class ServiceJournalRecentProcedureEntry
    {
        public long clientID;
        public long patID;
        public long pracID;
        public long journalID;
        public long entryID;


        public DateTime dos;
        public string dosStr;
        public TimeSpan entryStartTime;
        public string entryStartTimeStr;
        public TimeSpan entryEndTime;
        public string entryEndTimeStr;
        public string pracName;
        public string pracTitle;
        public string patName;
        public string procedureName;
        public string procedureNotes;

        public static string DEFAULT_PAGING_ORDER = "dos desc, entryStartTime desc";
    }

    /***************************************************************************
     * ServiceJournalRecentProcedureEntries */
    /**
     * Methods to work with service journal recent procedures entries
     **************************************************************************/

    public class ServiceJournalRecentProcedureEntries : Entities
    {
        public const string URL_REST_VIEW_OPEN = @"api/v1/servicejournalrecentprocedureentries";

        /***************************************************************************
        * URL_REST_VIEW_OPEN_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_REST_VIEW_OPEN_BASE()
        {
            return MBA.HttpApplication.createLink(ServiceJournalRecentProcedureEntries.URL_REST_VIEW_OPEN, true);
        }

        /***************************************************************************
         * view */
        /**
         * 
         **************************************************************************/

        public static ReturnDB view(SqlConnection connSpedmon,
                                     DetailsLog log,
                                     UserInfo uInfo,
                                     int recViewType,
                                     bool pagedOrTop,
                                     string idx,
                                     string canEdit,                                     
                                     string clientID,
                                     string patID,
                                     string dos,
                                     string active,
                                     defineCols dc)
        {

            string viewUDF = "dbo.SvcJournal_Recent_Procedure_Entries_View(@userID, @userGroup, @userRank, @clientID, @patID, @dos)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            Object vClientID    = Validate.reqClientID (uInfo, clientID);
            Object vPatID       = Validate.reqPatID    (uInfo, patID);
            DateTime vDOS       = Validate.reqDate     (dos,   Messages.INVALID_DOS);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID",     SqlDbType.Int,      vClientID,  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID",        SqlDbType.Int,      vPatID,     ParameterDirection.Input));
            parms.Add(Database.SqlParm("@dos",          SqlDbType.DateTime, vDOS,       ParameterDirection.Input));

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
        }

        /***************************************************************************
        * viewObjects 
        *
        * Returns a list of patients objects
        * 
        ***************************************************************************/

        public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                  , DetailsLog log
                                                  , UserInfo uInfo
                                                  , bool pageObjectList
                                                  , string pageOrder
                                                  , string idx                                                  
                                                  , string clientID
                                                  , string patID
                                                  , string dos
                                                  , string active
        )

        {
            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = ServiceJournalRecentProcedureEntry.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                         , log
                                         , uInfo
                                         , typeof(ServiceJournalRecentProcedureEntry)
                                         , pageObjectList
                                         , pageOrder
                                         , delegate
                                         {
                                             return ServiceJournalRecentProcedureEntries.view(connSpedmon
                                                                   , log
                                                                   , uInfo
                                                                   , Entities.REC_VIEW_OBJECTS
                                                                   , pageObjectList
                                                                   , idx
                                                                   , "" /* Can edit */                                                                   
                                                                   , clientID
                                                                   , patID
                                                                   , dos
                                                                   , active
                                                                   , dc);
                                         });


        }
    }
}
