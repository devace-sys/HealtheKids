using MBA;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;

namespace Spedmon
{
    public class InputBatchInProcess : Entity
    {
        public const string DEFAULT_PAGING_ORDER = @"name asc";

        public long clientID;
        public string clientName;
        public string displayLabel;
        public int curStatusCode;
        public string curStatusDescription;
        public string curStatusCodeAndDescription;
        public DateTime dateReceived;
        public string dateReceivedStr;
        public string dateReceivedStrYMD;
        public DateTime oldestDOS;
        public string oldestDOSStr;
        public string oldestDOSStrYMD;
        public long workTypeID;
        public string workTypeName;
        public long lastAssignedID;
        public string lastAssignedTo;
        public DateTime statusDate;
        public string statusDateStr;
        public string pcalConsultant;
        public DateTime dateSent;
        public string fileLoc;
        public bool partial;
        public long parentID;
        public Decimal estInputHrs;
        public long userID1;
        public int prtNum;
        public int degOfDiff;
    }

    public class InputBatchesInProcess : Entities
    {
        public const string URL_MANAGE = @"user_all_batches_in_process_manage.aspx";

        public const string URL_WEB_SERVICE = @"input_batches_in_process.asmx";
        public const string URL_SAVE = URL_WEB_SERVICE + @"/save";
        public const string URL_DELETE = URL_WEB_SERVICE + @"/delete";

        public const string URL_REST_VIEW = @"api/v1/inputbatchesinprocess";

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(InputBatchesInProcess.URL_REST_VIEW, true);
        }

        public static string URL_MANAGE_BASE()
        {
            return MBA.HttpApplication.createLink(InputBatchesInProcess.URL_MANAGE, true);
        }

        public static string URL_SAVE_BASE()
        {
            return MBA.HttpApplication.createLink(InputBatchesInProcess.URL_SAVE, true);
        }

        public static string URL_DELETE_BASE()
        {
            return MBA.HttpApplication.createLink(InputBatchesInProcess.URL_DELETE, true);
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
                                     , string batchStatusCode
                                     , string assignedUserID
                                     , string batchID
                                     , string term
                                     , string workTypeID
                                     , string showJustBatchesInProcess
                                     , defineCols dc)
        {

            string viewUDF = "dbo.INPUT_BATCHES_IN_PROCESS_VIEW (@userID, @userGroup, @userRank, @clientID, @currentStatus, @assignedUserID, @batchID, @active, @term, @recID, @workTypeID, @showJustBatchesInProcess)";

            /*----------------------------
            * Validate parameters specific
            * to this entity.view
            * and populate their
            * coresponding database
            * parameters
            *----------------------------*/

            var vClientID               = Validate.optClientID (uInfo, clientID);
            var vBatchStatusCode        = Validate.optInteger  (batchStatusCode, @"Invalid status code");
            var vAssignedUserID         = Validate.optInteger  (assignedUserID, Messages.INVALID_USER_ID);
            var vBatchID                = Validate.optInteger  (batchID,    @"Invalid Batch");
            var vTerm                   = Validate.optString   (term,       @"Invalid file name");
            var vWorkTypeID             = Validate.optInteger  (workTypeID, @"Invalid work type");
            
            var vShowJustBatchInProcess = Validate.optFlagYNUnknown(showJustBatchesInProcess,     @"Invalid value for show just batch in process");
            
            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID",                 SqlDbType.BigInt,  vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@currentStatus",            SqlDbType.Int,     vBatchStatusCode, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@assignedUserID",           SqlDbType.BigInt,  vAssignedUserID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@batchID",                  SqlDbType.BigInt,  vBatchID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@term",                     SqlDbType.VarChar, vTerm,                   ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@workTypeID",               SqlDbType.BigInt,  vWorkTypeID,             ParameterDirection.Input));
            parms.Add(Database.SqlParm("@showJustBatchesInProcess", SqlDbType.Bit,     vShowJustBatchInProcess, ParameterDirection.Input));
            
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
         * Returns a list of objects
         * 
         ***************************************************************************/
        public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                  , DetailsLog log
                                                  , UserInfo uInfo
                                                  , bool pageObjectList
                                                  , string pageOrder
                                                  , string idx
                                                  , string active
                                                  , string clientID
                                                  , string batchStatusCode
                                                  , string assignedUserID
                                                  , string batchID
                                                  , string workTypeID
                                                  , string term
                                                  , string showJustBatchesInProcess
        )
        {

            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = InputBatchInProcess.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(InputBatchInProcess)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return InputBatchesInProcess.view(
                                                                         connSpedmon
                                                                       , log
                                                                       , uInfo
                                                                       , Entities.REC_VIEW_OBJECTS
                                                                       , pageObjectList
                                                                       , idx
                                                                       , "" // canEdit
                                                                       , active
                                                                       , clientID
                                                                       , batchStatusCode
                                                                       , assignedUserID
                                                                       , batchID
                                                                       , term
                                                                       , workTypeID
                                                                       , showJustBatchesInProcess
                                                                       , dc
                                               );
                                          });
        }

        /***************************************************************************
         * save 
         *
         * 
         * 
         ***************************************************************************/

        public static Return save(SqlConnection dbConnSpedmon
                                 , DetailsLog log
                                 , UserInfo uInfo
                                 , string filename
                                 , string clientID
                                 , string dateSent
                                 , string dateRecieved
                                 , string fileloc
                                 , string partial
                                 , string parentID
                                 , string typeofwork
                                 , string oldestDOS
                                 , string estinputhrs
                                 , string userID1
                                 , string userID2
                                 , string prtnum
                                 , string degofdiff
                                 , string statuscode
                                 , string notes
                                 , string editDelReason
                                 , string validateRec
                                 , string saveType
                                 , string recID)
        {
            string saveSproc = @"INPUT_BATCHES_Save";
            string dupRecMsg = @"Record already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vFilename = Validate.reqString(filename, @"Invalid file name");
            var vClientID = Validate.reqClientID(uInfo, clientID);
            var vDateSent = Validate.reqDate(dateSent, @"Invalid date sent");
            var vDateRecieved = Validate.optDate(dateRecieved, Messages.INVALID_DATE);
            var vFileloc = Validate.reqString(fileloc, @"Invalid file location");
            var vPartial = Validate.optFlag(partial, Messages.INVALID_FLAG);
            var vParentID = Validate.optInteger(parentID, Messages.INVALID_NUMBER, true);
            var vTypofwrk = Validate.reqInteger(typeofwork, @"Invalid work type", true);
            var vOldstDos = Validate.optDate(oldestDOS, Messages.INVALID_DATE);
            var vEstInputHrs = Validate.optFixed(estinputhrs, @"Invalid estimated time");
            var vUserID1 = Validate.optInteger(userID1, Messages.INVALID_USER_ID, true);
            var vUserID2 = Validate.optInteger(userID2, Messages.INVALID_USER_ID, true);
            var vPrtNum = Validate.optInteger(prtnum, @"Invalid part number", true);
            var vDegOfDiff = Validate.optInteger(degofdiff, @"Invalid degree of difficulity", true);
            var vStatus = Validate.optInteger(statuscode, @"Invalid status code", true);
            var vNotes = Validate.optString(notes, Messages.INVALID_NOTES);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@filename", SqlDbType.VarChar, vFilename, ParameterDirection.Input, 7000));
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@dateSent", SqlDbType.DateTime, vDateSent, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@dateRecieved", SqlDbType.DateTime, vDateRecieved, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fileLocation", SqlDbType.VarChar, vFileloc, ParameterDirection.Input, 7000));
            parms.Add(Database.SqlParm("@partial", SqlDbType.Bit, vPartial, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@parentID", SqlDbType.BigInt, vParentID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@typeofwork", SqlDbType.Int, vTypofwrk, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@oldest_dos", SqlDbType.DateTime, vOldstDos, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@estmtedinpthrs", SqlDbType.Decimal, vEstInputHrs, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userID1", SqlDbType.BigInt, vUserID1, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userID2", SqlDbType.BigInt, vUserID2, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@priorityNum", SqlDbType.SmallInt, vPrtNum, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@degreeofdifcult", SqlDbType.SmallInt, vDegOfDiff, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@statuscode", SqlDbType.SmallInt, vStatus, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@note", SqlDbType.VarChar, vNotes, ParameterDirection.Input, -1));

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

            string deleteSproc = @"INPUT_BATCHES_IN_PROCESS_DELETE";

            /*###########################################################################
              # Validate parameters specific to this entity delete and create their 
              # database parameters.
              ###########################################################################*/

            List<SqlParameter> parms = new List<SqlParameter>();

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, deleteSproc, ref parms);
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
                                         , string clientID
                                         , string term)
        {

            string vTerm = Validate.optString(term);

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {

            };

            return Entities.viewSel(connSpedmon
                                    , log
                                    , uInfo
                                    , top
                                    , topSize
                                    , delegate {
                                        return InputBatchesInProcess.view(connSpedmon
                                                           , log
                                                           , uInfo
                                                           , Entities.REC_VIEW_SEL
                                                           , top
                                                           , topSize
                                                           , ""
                                                           , "1"
                                                           , ""
                                                           , ""
                                                           , ""
                                                           , ""
                                                           , vTerm
                                                           , "" // workTypeID
                                                           , ""
                                                           , dc);
                                    });


        }

    }
}
