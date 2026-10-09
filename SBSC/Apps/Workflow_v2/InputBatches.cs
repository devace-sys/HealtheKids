using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Windows.Forms;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Workflow_v2
{

    class InputBatch : Entity
    {

        public Int64 ClientID;
        public int Type_Of_Work;
        public string File_Name;
        public string File_Location;
        public bool Partial_File;
        public DateTime Date_Recieved;
        public DateTime Date_Sent;
        public DateTime Oldest_DOS;
        public Decimal Estimated_Input_Hours;
        public DateTime Current_Status_Date;
        public int Current_status_Code;
        public Int64 Current_status_UserID1; //Last_Updating_User_ID
        public Int64 Current_status_UserID2; //Last_Assigned_User_ID
        public int Priority_number;
        public int Degree_Of_Difficulty;
        public bool Active;
        public string Notes;
        public Int64 ParentBatchID;

        /* interpretations of core data elements */
        public string FileReference;
        public Int64 Last_Updating_User_ID;
        public Int64 Last_Assigned_User_ID;


        

    }
    /***************************************************************************
     * INPUT_BATCHES */
    /**
     * Methods to manage INPUT_BATCHES
     ***************************************************************************/
    class InputBatches : Entities
    {
        /* Batch Status Enumeration */
        public enum Status : int
        {
            ReadytoBatch = 10,
            PrescreenPENDING = 30,
            ReadytoAssign = 50,
            assignedInput = 60,
            inputStarted = 70,
            ReviewQuestionForm = 80,
            ReviewNotBillable = 85,
            CIS = 90,
            ReviewInputComplete = 100,
            ReviewStarted = 110,
            Retrain = 130,
            FinishedClaims = 200,
            QuestionFormToAnI = 300,
            NonBillableToAnI = 310,
            tooLarge = 320,
            corrupted = 330,
            deleted = 340,
            QuestionFormToPrac = 290
        }

        public static ReturnDB view(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                                int recViewType,
                                                bool pagedOrTop,
                                                string idx,
                                                string canEdit,
                                                string filename,
                                                string fileloc,
                                                string worktype,
                                                string statuscode,
                                                string clientID,
                                                string assignedTo,
                                                string canedit,
                                                string active,
                                                string recID,
                                                defineCols dc
                                                )
                
        {
            string viewUDF;
            string msg = null;

            /* TODO - refactor this UDF to be a better generic view.
             * (this will require Workflow 1 to be put to pasture) 
             */
            viewUDF = "dbo.INPUT_BATCHES_VIEW_CORE(@recID,@fileName,@fileloc,@status,@clientID,@workType,@assignedTo,@active,@canEdit)";
                Object vClientID   = Validate.optInteger(clientID,   msg, true);
                string vfilename   = Validate.optString (filename,   "");
                string vfileloc    = Validate.optString (fileloc,    "");
                object vtypofwrk   = Validate.optInteger(worktype,   msg, true);
                object vAssignedTo = Validate.optInteger(assignedTo, msg, true);             
                object vStatus     = Validate.optInteger(statuscode, msg, true);
                object vRecID      = Validate.optInteger(recID,      msg, true);
                Object vActive     = Validate.optFlag   (active,     msg);
                Object vCanEdit    = Validate.optFlag   (canedit,    msg);

                List<SqlParameter> parms = new List<SqlParameter>();
                parms.Add(Database.SqlParm("@fileName", SqlDbType.VarChar, vfilename, ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@fileloc", SqlDbType.VarChar, vfileloc, ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@workType", SqlDbType.Int, vtypofwrk, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@assignedTo", SqlDbType.BigInt, vAssignedTo, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@status", SqlDbType.SmallInt, vStatus, ParameterDirection.Input));

                return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
        }
        
        
        public static InputBatch load (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
                                     string recID)
        {
            InputBatch loadedBatch = (InputBatch)Entities.load(connSpedmon, log, uInfo, recID, typeof(InputBatch),
            delegate { return InputBatches.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD,false,recID,"","","","","","","","","","",null); });

            if (loadedBatch != null)
            {
                loadedBatch.FileReference = loadedBatch.File_Name.Replace(".pdf", "");

                loadedBatch.Last_Updating_User_ID = loadedBatch.Current_status_UserID1;
                loadedBatch.Last_Assigned_User_ID= loadedBatch.Current_status_UserID2;
            }
            return loadedBatch;
        }


        public static ReturnDB workPickerView(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                                int recViewType,
                                                bool pagedOrTop,
                                                string idx,
                                                string canEdit, string userID, defineCols dc, bool viewOnly)
        {
            string viewUDF;
            string msg = null;
            viewUDF = "dbo.INPUT_BATCHES_WORK_PICKER_VIEW(@userID, @userGroup, @userRank,@recID,@canEdit,@active, @requestingUserID, @viewOnly)";

            object vRequestingWorker = Validate.reqInteger(userID, msg, true);
            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@requestingUserID", SqlDbType.BigInt, vRequestingWorker, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@viewOnly", SqlDbType.Bit, vRequestingWorker, ParameterDirection.Input));

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, null, viewUDF, ref parms, null, dc);
        }



        public static string workPickerPickWorkBatch(string connectionString, string userID)
        {
            string pickedBatch = "";
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                try
                {
                    
                    object vUserID = Validate.reqInteger(userID, "Can't pick work without user information.");

                    List<SqlParameter> parms = new List<SqlParameter>();
                    parms.Add(Database.SqlParm("@userID", SqlDbType.BigInt, vUserID, ParameterDirection.Input));

                    parms.Add(Database.SqlParm("@recordID", SqlDbType.BigInt, null, ParameterDirection.Output));

                    /*----------------------------
                     * Call our stored procedure
                     *----------------------------*/
                    string sql = "INPUT_BATCHES_WORK_PICKER";
                    Database.execSproc(conn, null, sql, parms);

                        pickedBatch = parms[1].Value.ToString();


                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.Message);
                }
            }
             return pickedBatch;
        }




        /***************************************************************************
         * INPUT_BATCHES_SAVE */
        /**
         ***************************************************************************/
        public static void save(SqlConnection conn, int savetype, InputBatch record, string auditNote)
        {
            string sql = "INPUTBATCHES_SAVE";
            string msg = "";
            try
            {              
                string vfilename    = Validate.reqString(   record.File_Name,                             msg);
                string vfileloc     = Validate.reqString(   record.File_Location,                         msg);
                object vtypofwrk    = Validate.reqInteger(  record.Type_Of_Work.ToString(),               msg,true);

                object vOldstDos    = Validate.optDate   (  record.Oldest_DOS.ToString(),                 msg);
                object vClientID    = Validate.reqInteger(  record.ClientID.ToString(),                   msg);
                object vDateSent    = Validate.reqDate   (  record.Date_Sent.ToString(),                  msg);
                object vDateRcvd    = Validate.optDate   (  record.Date_Recieved.ToString(),              msg);

                object vParentID;
                if (record.ParentBatchID == 0)
                    vParentID = null;
                else
                    vParentID    = Validate.optInteger(  record.ParentBatchID.ToString(),              msg);
                object vEstInputHrs = null;
                if (record.Estimated_Input_Hours.ToString() != "")
                   vEstInputHrs     = record.Estimated_Input_Hours;
                object vUserID1     = Validate.optInteger(  record.Current_status_UserID1.ToString(),     msg, true);
                object vUserID2     = Validate.optInteger(  record.Current_status_UserID2.ToString(),     msg, true);
                object vPrtNum      = Validate.optInteger(  record.Priority_number.ToString(),            msg, true);
                object vDegOfDiff   = Validate.optInteger(  record.Degree_Of_Difficulty.ToString(),       msg, true);
                object vStatus      = Validate.optInteger(  record.Current_status_Code.ToString(),        msg, true);
                object vRecID       = Validate.optInteger(  record.id.ToString(),                         msg, true);
                Object vNotes =       Validate.optString(   auditNote, msg);
                Object vPartial     = Validate.optFlag   (  record.Partial_File.ToString(),               msg);
                int vSaveType       = Validate.reqInteger(  savetype.ToString(),                          msg);

                List<SqlParameter> parms = new List<SqlParameter>();
                parms.Add(Database.SqlParm("@filename",        SqlDbType.VarChar,  vfilename,    ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@clientID",        SqlDbType.BigInt,   vClientID,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@dateSent",        SqlDbType.DateTime, vDateSent,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@dateRecieved",    SqlDbType.DateTime, vDateRcvd,    ParameterDirection.Input));

                parms.Add(Database.SqlParm("@fileLocation",    SqlDbType.VarChar,  vfileloc,     ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@partial",         SqlDbType.Bit,      vPartial,     ParameterDirection.Input));
                parms.Add(Database.SqlParm("@parentID",        SqlDbType.BigInt,   vParentID,    ParameterDirection.Input));

                parms.Add(Database.SqlParm("@typeofwork",      SqlDbType.Int,      vtypofwrk,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@oldest_dos",      SqlDbType.DateTime, vOldstDos,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@estmtedinpthrs",  SqlDbType.Decimal,  vEstInputHrs, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@userID1",         SqlDbType.BigInt,   vUserID1,     ParameterDirection.Input));
                parms.Add(Database.SqlParm("@userID2",         SqlDbType.BigInt,   vUserID2,     ParameterDirection.Input));
                parms.Add(Database.SqlParm("@priorityNum",     SqlDbType.SmallInt, vPrtNum,      ParameterDirection.Input));
                parms.Add(Database.SqlParm("@degreeofdifcult", SqlDbType.SmallInt, vDegOfDiff,   ParameterDirection.Input));
                parms.Add(Database.SqlParm("@statuscode",      SqlDbType.SmallInt, vStatus,      ParameterDirection.Input));
                parms.Add(Database.SqlParm("@note",            SqlDbType.VarChar,  vNotes,       ParameterDirection.Input));
                parms.Add(Database.SqlParm("@editDelReason",   SqlDbType.VarChar, "",     ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@validateRec",     SqlDbType.Bit,      0,            ParameterDirection.Input));
                parms.Add(Database.SqlParm("@saveType",        SqlDbType.Int,      vSaveType,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@recID",           SqlDbType.BigInt,   vRecID,       ParameterDirection.Input));

                parms.Add(Database.SqlParm("@MsgNotActive",    SqlDbType.VarChar,  msg,          ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgDupRec",       SqlDbType.VarChar,  msg,          ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoRec",        SqlDbType.VarChar,  msg,          ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoEdit",       SqlDbType.VarChar,  msg,          ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgDataError",    SqlDbType.VarChar,  msg,          ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@recordID",        SqlDbType.BigInt,   null,         ParameterDirection.Output));

                ReturnDB rd = Database.execSproc(conn, null, sql, parms);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        /***************************************************************************
         * INPUT_BATCHES_VIEW */
        /**
         ***************************************************************************/
        public static DataTable InputBatchesView(SqlConnection conn,
                                                 string filename,
                                                 string fileloc,
                                                 string worktype,                                           
                                                 string statuscode,
                                                 string clientID,
                                                 string assignedTo,
                                                 string canedit,
                                                 string active,
                                                 string recID
                                                 )
        {
        //    string sql;
        //    if (!SBSCParent.isInputStaff)
        //    {
        //        if (statuscode != "")
        //            sql = "SELECT * FROM INPUT_BATCHES_VIEW(@recID,@fileName,@fileloc,@status,@clientID,@workType,@assignedTo,@active,@canEdit)";
        //        else
        //            sql = "SELECT * FROM INPUT_BATCHES_VIEW(@recID,@fileName,@fileloc,@status,@clientID,@workType,@assignedTo,@active,@canEdit) " +
        //                  "where statuscode not in (" + FileStatus.FinishedClaims.ToString() + "," 
        //                                              + FileStatus.QuestionFormToAnI.ToString() + ","
        //                                              + FileStatus.QuestionFormToPrac.ToString() + ","
        //                                              + FileStatus.NonBillableToAnI.ToString() + ")";
                                                   
        //    }
        //    else
        //        sql = "SELECT * FROM INPUT_BATCHES_VIEW(@recID,@fileName,@fileloc,@status,@clientID,@workType,@assignedTo,@active,@canEdit)" +
        //              "where statuscode not in (" + FileStatus.ReviewInputComplete.ToString() + "," + FileStatus.CIS.ToString() + "," + FileStatus.ReviewStarted.ToString() + ")";

        //    string msg = null;              

        //    Object vClientID   = Validate.optInteger(clientID,   msg, true);
        //    string vfilename   = Validate.optString (filename,   "");
        //    string vfileloc    = Validate.optString (fileloc,    "");
        //    object vtypofwrk   = Validate.optInteger(worktype,   msg, true);
        //    object vAssignedTo = Validate.optInteger(assignedTo, msg, true);             
        //    object vStatus     = Validate.optInteger(statuscode, msg, true);
        //    object vRecID      = Validate.optInteger(recID,      msg, true);
        //    Object vActive     = Validate.optFlag   (active,     msg);
        //    Object vCanEdit    = Validate.optFlag   (canedit,    msg);

        //    List<SqlParameter> parms = new List<SqlParameter>();
        //    parms.Add(Database.SqlParm("@fileName",   SqlDbType.VarChar,  vfilename,   ParameterDirection.Input, 7000));
        //    parms.Add(Database.SqlParm("@fileloc",    SqlDbType.VarChar,  vfileloc,    ParameterDirection.Input, 7000));
        //    parms.Add(Database.SqlParm("@workType",   SqlDbType.Int,      vtypofwrk,   ParameterDirection.Input));
        //    parms.Add(Database.SqlParm("@assignedTo", SqlDbType.BigInt,   vAssignedTo, ParameterDirection.Input));
        //    parms.Add(Database.SqlParm("@clientID",   SqlDbType.Int,      vClientID,   ParameterDirection.Input));
        //    parms.Add(Database.SqlParm("@status",     SqlDbType.SmallInt, vStatus,     ParameterDirection.Input));                
        //    parms.Add(Database.SqlParm("@recID",      SqlDbType.BigInt,   vRecID,      ParameterDirection.Input));
        //    parms.Add(Database.SqlParm("@active",     SqlDbType.Bit,      vActive,     ParameterDirection.Input));
        //    parms.Add(Database.SqlParm("@canEdit",    SqlDbType.Bit,      vCanEdit,    ParameterDirection.Input));

            DataTable dt = new DataTable();
        //    try
        //    {                
        //        ReturnDB rd = Database.execQuery(SBSCParent.connSpedmon, null, sql, false, parms);                
        //        dt = Database.convertReturnDBToDatatable(ref rd);                              
        //    }
        //    catch (Exception ex)
        //    {
        //        MessageBox.Show(ex.Message);
        //    }
           return dt;            
        }

        /***************************************************************************
        * INPUT_BATCHES_DELETE */
        /**
         * "Deletes" a INPUTBATCH record
         ***************************************************************************/
        public static void InputBatchesdelete(SqlConnection conn,string editDelReason, string validateRec, string recID,string fileloc, string userID1)
        {
            string sql = "INPUTBATCHES_Delete";
            string msg = null;
            ReturnSaveRecord so = new ReturnSaveRecord();

            try
            { 
                bool vValidateRec = Validate.reqFlag(validateRec, msg);
                long vRecID       = Validate.reqInteger(recID, msg);
                string vfileloc   = Validate.optString(fileloc, "");
                List<SqlParameter> parms = new List<SqlParameter>();

                parms.Add(Database.SqlParm("@userID",        SqlDbType.BigInt,  userID1,       ParameterDirection.Input));           

                parms.Add(Database.SqlParm("@editDelReason", SqlDbType.VarChar, editDelReason, ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@validateRec",   SqlDbType.Bit,     vValidateRec,  ParameterDirection.Input));
                parms.Add(Database.SqlParm("@recID",         SqlDbType.BigInt,  vRecID,        ParameterDirection.Input));
                parms.Add(Database.SqlParm("@fileLoc",       SqlDbType.VarChar, vfileloc,      ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@MsgNoRec",      SqlDbType.VarChar, msg,           ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoEdit",     SqlDbType.VarChar, msg,           ParameterDirection.Input, 1000));

                parms.Add(Database.SqlParm("@recordID",      SqlDbType.BigInt,  null,          ParameterDirection.Output));

                /*----------------------------
                 * Call our stored procedure
                 *----------------------------*/
                ReturnDB rd = Database.execSproc(conn, null, sql, parms);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        /***************************************************************************
         * Practitioner_Review_SAVE */
        /**
         ***************************************************************************/
        public static void PracReviewSave(SqlConnection conn,                                           
                                            string pracID,
                                            string batchID,                                            
                                            string categoryID,                                            
                                            string userID,
                                            string review,
                                            string saveType                                                                           
                                            )
        {
            string sql = "Practitioners_Review_Save";
            string msg = null;
            try
            {
                object vPracID     = Validate.optInteger(pracID,     msg, true);
                object vUserID     = Validate.optInteger(userID,     msg, true);
                object vCategoryID = Validate.optInteger(categoryID, msg, true);               
                object vBatchID    = Validate.optInteger(batchID,    msg, true);
                Object vReview     = Validate.optString(review,      "");

                List<SqlParameter> parms = new List<SqlParameter>();

                parms.Add(Database.SqlParm("@pracID",     SqlDbType.BigInt,   vPracID,     ParameterDirection.Input));
                parms.Add(Database.SqlParm("@batchID",    SqlDbType.BigInt,   vBatchID,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@categoryID", SqlDbType.BigInt,   vCategoryID, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@userID",     SqlDbType.BigInt,   vUserID,     ParameterDirection.Input));                
                parms.Add(Database.SqlParm("@review",     SqlDbType.VarChar,  vReview,     ParameterDirection.Input));
                              
                ReturnDB rd = Database.execSproc(conn, null, sql, parms);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }


        /***************************************************************************
        * Practitioners_Problems_DELETE */
        /**
         * "Deletes" a Practitioners_Problems record
         ***************************************************************************/
        public static void Practitioners_Problems_delete(SqlConnection conn, string editDelReason, string validateRec, string recID, string userID1)
        {
            string sql = "PRACTITIONERS_REVIEW_Delete";
            string msg = null;
            ReturnSaveRecord so = new ReturnSaveRecord();

            try
            {
                bool vValidateRec = Validate.reqFlag(validateRec, msg);
                long vRecID = Validate.reqInteger(recID, msg);
                List<SqlParameter> parms = new List<SqlParameter>();

                parms.Add(Database.SqlParm("@userID", SqlDbType.BigInt, userID1, ParameterDirection.Input));

                parms.Add(Database.SqlParm("@editDelReason", SqlDbType.VarChar, editDelReason, ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@validateRec",   SqlDbType.Bit,     vValidateRec,  ParameterDirection.Input));
                parms.Add(Database.SqlParm("@recID",         SqlDbType.BigInt,  vRecID,        ParameterDirection.Input));
                parms.Add(Database.SqlParm("@MsgNoRec",      SqlDbType.VarChar, msg,           ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoEdit",     SqlDbType.VarChar, msg,           ParameterDirection.Input, 1000));

                parms.Add(Database.SqlParm("@recordID", SqlDbType.BigInt, null, ParameterDirection.Output));

                /*----------------------------
                 * Call our stored procedure
                 *----------------------------*/
                ReturnDB rd = Database.execSproc(conn, null, sql, parms);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }




        /***************************************************************************
         * Practitioners_Problems_VIEW */
        /**
         ***************************************************************************/
        //public static DataTable Practitioners_Problems_VIEW(SqlConnection conn,
        //                                                    string clientID,
        //                                                    string pracID,
        //                                                    string batchID,
        //                                                    string status,
        //                                                    string ctgryID,                                                                                                                  
        //                                                    string active
        //                                                    )
        //{
        //    string sql = "select * from RPT_PRACTITONERS_REVIEWS(@clientID,@pracID,@batchID,@statusID,@ctgryID,1)";
                            
        //    string msg = null;

        //    object vCtgryID  = MBA.Validate.optInteger(ctgryID,  "", true);
        //    object vPracID   = MBA.Validate.optInteger(pracID,   "", true);
        //    object vBatchID  = MBA.Validate.optInteger(batchID,  "", true);
        //    object vstatusID = MBA.Validate.optInteger(status,   "", true);

        //    object vClientID = MBA.Validate.optInteger(clientID, "", true);           
        //    Object vActive   = Validate.optFlag(active, msg);

        //    List<SqlParameter> parms = new List<SqlParameter>();
        //    parms.Add(Database.SqlParm("@ctgryID",  SqlDbType.Int,    vCtgryID,  ParameterDirection.Input));
        //    parms.Add(Database.SqlParm("@pracID",   SqlDbType.BigInt, vPracID,   ParameterDirection.Input));
        //    parms.Add(Database.SqlParm("@batchID",  SqlDbType.BigInt, vBatchID,  ParameterDirection.Input));
        //    parms.Add(Database.SqlParm("@statusID", SqlDbType.Int,    vstatusID, ParameterDirection.Input));
        //    parms.Add(Database.SqlParm("@clientID", SqlDbType.Int,    vClientID, ParameterDirection.Input));
        //    parms.Add(Database.SqlParm("@active",   SqlDbType.Bit,    vActive,   ParameterDirection.Input));

        //    DataTable dt = new DataTable();
        //    try
        //    {
        //        ReturnDB rd = Database.execQuery(SBSCParent.connSpedmon, null, sql, false, parms);
        //        dt = Database.convertReturnDBToDatatable(ref rd);
        //    }
        //    catch (Exception ex)
        //    {
        //        MessageBox.Show(ex.Message);
        //    }
        //    return dt;
        //}

        /***************************************************************************
         * PRACTITIONERS_SENT_MAIL_INFO_Save */
        /**
         ***************************************************************************/
        public static void PracSentEmailInfoSave(SqlConnection conn,
                                                 string pracID,
                                                 string batchID,
                                                 string userID,
                                                 string review,
                                                 string saveType
                                            )
        {
            string sql = "PRACTITIONERS_SENT_EMAIL_INFO_Save";
            string msg = null;
            try
            {
                object vPracID  = Validate.optInteger(pracID, msg, true);
                object vUserID  = Validate.optInteger(userID, msg, true);
                object vBatchID = Validate.optInteger(batchID, msg, true);
                Object vReview  = Validate.optString(review, "");

                List<SqlParameter> parms = new List<SqlParameter>();

                parms.Add(Database.SqlParm("@pracID",  SqlDbType.BigInt,  vPracID,  ParameterDirection.Input));
                parms.Add(Database.SqlParm("@batchID", SqlDbType.BigInt,  vBatchID, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@userID",  SqlDbType.BigInt,  vUserID,  ParameterDirection.Input));
                parms.Add(Database.SqlParm("@reason",  SqlDbType.VarChar, vReview,  ParameterDirection.Input));

                ReturnDB rd = Database.execSproc(conn, null, sql, parms);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }


        /***************************************************************************
         * INPUT_BATCHES_WORK_CONTROL_SAVE */
        /**
         ***************************************************************************/
        public static void InputBatchesWorkControlSave(SqlConnection conn,                                           
                                            string clientID,       
                                            string typeofwork,                       
                                            string userID,
                                            string notes,
                                            string startDate,
                                            string endDate,
                                            string editDelReason,
                                            string validateRec,
                                            string saveType,
                                            string recID)
        {
            string sql = "INPUT_BATCHES_WORK_CONTROL_Save";
            string msg = null;
            try
            {
               
                object vtypofwrk  = Validate.optInteger(typeofwork, msg);
                object vClientID  = Validate.reqInteger(clientID,   "Please select a Client.");
                object vStartDate = Validate.optDate   (startDate,  msg);
                object vEndDate   = Validate.optDate   (endDate,    msg);               
                object vUserID    = Validate.optInteger(userID,     msg, true);               
                object vRecID     = Validate.optInteger(recID,      msg, true);
                Object vNotes     = Validate.reqString (notes,      "Please enter note.");              
                int vSaveType     = Validate.reqInteger(saveType,   msg);

                List<SqlParameter> parms = new List<SqlParameter>();
                parms.Add(Database.SqlParm("@clientID",      SqlDbType.BigInt,   vClientID,  ParameterDirection.Input));
                parms.Add(Database.SqlParm("@startDate",     SqlDbType.DateTime, vStartDate, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@endDate",       SqlDbType.DateTime, vEndDate,   ParameterDirection.Input));


                parms.Add(Database.SqlParm("@workTypeID",    SqlDbType.Int,      vtypofwrk, ParameterDirection.Input));
                 
                parms.Add(Database.SqlParm("@userID",        SqlDbType.BigInt,   vUserID,   ParameterDirection.Input));
                
                parms.Add(Database.SqlParm("@note",          SqlDbType.VarChar,  vNotes,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@editDelReason", SqlDbType.VarChar,  "",        ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@validateRec",   SqlDbType.Bit,      1,         ParameterDirection.Input));
                parms.Add(Database.SqlParm("@saveType",      SqlDbType.Int,      vSaveType, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@recID",         SqlDbType.BigInt,   vRecID,    ParameterDirection.Input));

                parms.Add(Database.SqlParm("@MsgNotActive",  SqlDbType.VarChar, msg,  ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgDupRec",     SqlDbType.VarChar, msg,  ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoRec",      SqlDbType.VarChar, msg,  ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoEdit",     SqlDbType.VarChar, msg,  ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgDataError",  SqlDbType.VarChar, msg,  ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@recordID",      SqlDbType.BigInt,  null, ParameterDirection.Output));

                ReturnDB rd = Database.execSproc(conn, null, sql, parms);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        /***************************************************************************
       * INPUT_BATCHES_WORK_CONTROL_DELETE */
        /**
         * "Deletes" a INPUT_BATCH_WORK_CONTROL_ record
         ***************************************************************************/
        public static void InputBatchesWorkControldelete(SqlConnection conn, string editDelReason, string validateRec, string recID, string userID1)
        {
            string sql = "INPUT_BATCHES_WORK_CONTROL_Delete";
            string msg = null;
            ReturnSaveRecord so = new ReturnSaveRecord();

            try
            {
                bool vValidateRec = Validate.reqFlag(validateRec, msg);
                long vRecID       = Validate.reqInteger(recID, msg);
                List<SqlParameter> parms = new List<SqlParameter>();

                parms.Add(Database.SqlParm("@userID",        SqlDbType.BigInt,  userID1,       ParameterDirection.Input));

                parms.Add(Database.SqlParm("@editDelReason", SqlDbType.VarChar, editDelReason, ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@validateRec",   SqlDbType.Bit,     vValidateRec,  ParameterDirection.Input));
                parms.Add(Database.SqlParm("@recID",         SqlDbType.BigInt,  vRecID,        ParameterDirection.Input));
                parms.Add(Database.SqlParm("@MsgNoRec",      SqlDbType.VarChar, msg,           ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoEdit",     SqlDbType.VarChar, msg,           ParameterDirection.Input, 1000));

                parms.Add(Database.SqlParm("@recordID",      SqlDbType.BigInt,  null,          ParameterDirection.Output));

                /*----------------------------
                 * Call our stored procedure
                 *----------------------------*/
                ReturnDB rd = Database.execSproc(conn, null, sql, parms);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }


        /***************************************************************************
         * INPUT_BATCHES_WORK_CONTROL_VIEW */
        /**
         ***************************************************************************/
        //public static DataTable InputBatchesWorkControlView(SqlConnection conn,                                                 
        //                                         string worktype,                                                 
        //                                         string clientID,                                                 
        //                                         string canedit,
        //                                         string active,
        //                                         string recID
        //                                         )
        //{
        //    string sql = "SELECT * FROM INPUT_BATCHES_WORK_CONTROL_VIEW(@recID,@clientID,@workType,@active,@canEdit)";
               
        //    string msg = null;

        //    Object vClientID = Validate.optInteger(clientID, msg, true);           
        //    object vtypofwrk = Validate.optInteger(worktype, msg, true);            
        //    object vRecID    = Validate.optInteger(recID,    msg, true);
        //    Object vActive   = Validate.optFlag   (active,   msg);
        //    Object vCanEdit  = Validate.optFlag   (canedit,  msg);

        //    List<SqlParameter> parms = new List<SqlParameter>();
           
        //    parms.Add(Database.SqlParm("@workType", SqlDbType.Int,    vtypofwrk, ParameterDirection.Input));
        //    parms.Add(Database.SqlParm("@clientID", SqlDbType.Int,    vClientID, ParameterDirection.Input));
        //    parms.Add(Database.SqlParm("@recID",    SqlDbType.BigInt, vRecID,    ParameterDirection.Input));
        //    parms.Add(Database.SqlParm("@active",   SqlDbType.Bit,    vActive,   ParameterDirection.Input));
        //    parms.Add(Database.SqlParm("@canEdit",  SqlDbType.Bit,    vCanEdit,  ParameterDirection.Input));

        //    DataTable dt = new DataTable();
        //    try
        //    {
        //        ReturnDB rd = Database.execQuery(SBSCParent.connSpedmon, null, sql, false, parms);
        //        dt = Database.convertReturnDBToDatatable(ref rd);
        //    }
        //    catch (Exception ex)
        //    {
        //        MessageBox.Show(ex.Message);
        //    }
        //    return dt;
        //}


        ///***************************************************************************
        // * InfoRequestDetailsSave */
        ///**
        // ***************************************************************************/
        //public static void InfoRequestResponseDetailSave(SqlConnection conn,
        //                                         string userID,       
        //                                         string irrID,
        //                                         string detailNum,
        //                                         string stndQuestionID,
        //                                         string question,                                                                                                  
        //                                         string questionType,                                                 
        //                                         string editDelReason,    
        //                                         string validateRec,    
        //                                         string saveType,    
        //                                         string recID
        //                                         )
        //{
        //    string sql = "INFO_REQUEST_RESPONSE_DETAILS_Save";
        //    string msg = null;
        //    try
        //    {
        //        object vIrrID        = Validate.reqInteger(irrID,          msg, true);
        //        object vUserID       = Validate.reqInteger(userID,         msg, true);
        //        object vDetailNum    = Validate.reqInteger(detailNum,      msg, true);
        //        object vQuestionID   = Validate.optInteger(stndQuestionID, msg, true);
        //        Object vQuestion     = Validate.reqString (question,       "");
        //        object vQuestionType = Validate.optInteger(questionType,   msg, true);
        //        object vRecID        = Validate.optInteger(recID,          msg, true);
        //        int    vSaveType     = Validate.reqInteger(saveType,       msg);


        //        List<SqlParameter> parms = new List<SqlParameter>();

        //        parms.Add(Database.SqlParm("@irrID",          SqlDbType.BigInt,  vIrrID,        ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@detailNum",      SqlDbType.BigInt,  vDetailNum,    ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@userID",         SqlDbType.BigInt,  vUserID,       ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@question",       SqlDbType.VarChar, vQuestion,     ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@stndQuestionID", SqlDbType.BigInt,  vQuestionID,   ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@questionType",   SqlDbType.BigInt,  vQuestionType, ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@answer",         SqlDbType.VarChar, null,          ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@stndAnswerID",   SqlDbType.BigInt,  null,          ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@answerType",     SqlDbType.BigInt,  null,          ParameterDirection.Input));


        //        parms.Add(Database.SqlParm("@editDelReason",  SqlDbType.VarChar, "",        ParameterDirection.Input, 7000));
        //        parms.Add(Database.SqlParm("@validateRec",    SqlDbType.Bit,     0,         ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@saveType",       SqlDbType.Int,     vSaveType, ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@recID",          SqlDbType.BigInt,  vRecID,    ParameterDirection.Input));

        //        parms.Add(Database.SqlParm("@MsgNotActive",   SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
        //        parms.Add(Database.SqlParm("@MsgDupRec",      SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
        //        parms.Add(Database.SqlParm("@MsgNoRec",       SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
        //        parms.Add(Database.SqlParm("@MsgNoEdit",      SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
        //        parms.Add(Database.SqlParm("@MsgNoFullEdit",  SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
        //        parms.Add(Database.SqlParm("@MsgDataError",   SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
        //        parms.Add(Database.SqlParm("@recordID",       SqlDbType.BigInt, null, ParameterDirection.Output));


        //        ReturnDB rd = Database.execSproc(conn, null, sql, parms);
        //    }
        //    catch (Exception ex)
        //    {
        //        MessageBox.Show(ex.Message);
        //    }
        //}

        ///***************************************************************************
        // * InfoRequestResponseSave */
        ///**
        // ***************************************************************************/
        //public static string InfoRequestResponseSave(SqlConnection conn,
        //                                           string userID,
        //                                           string token,
        //                                           string emailTittle,
        //                                           string emailMsg,
        //                                           string emailTo,
        //                                           string emailCc,
        //                                           string clientID,
        //                                           string toUserID,
        //                                           string toName,
        //                                           string toPracID,
        //                                           string fromUserID,
        //                                           string parentID,
        //                                           string referenceID,
        //                                           string oldestDOS,
        //                                           string status,
        //                                           string statusFlags,
        //                                           string irrType,
        //                                           string sentOn,
        //                                           string openedOn,
        //                                           string respondedOn,
        //                                           string expirationDate,
        //                                           string editDelReason,
        //                                           string validateRec,
        //                                           string saveType,
        //                                           string recID
        //                                           )
        //{
        //    string sql = "INFO_REQUEST_RESPONSE_Save";
        //    string msg = null;
        //    try
        //    {
        //        object vToken       = Validate.optString (token,          msg);
        //        object vUserID      = Validate.reqInteger(userID,         msg, true);
        //        object vEmailTittle = Validate.reqString (emailTittle,    msg);
        //        object vEmailMsg    = Validate.reqString (emailMsg,       msg);
        //        object vEmailTo     = Validate.reqString (emailTo,        msg);
        //        object vEmailCc     = Validate.optString (emailCc,        msg);
        //        object vFromID      = Validate.reqInteger(fromUserID,     msg);
        //        object vToName      = Validate.optString(toName, msg);
        //        object vToID        = Validate.optInteger(toUserID,       msg);
        //        object vToPracID    = Validate.optInteger(toPracID,       msg);
        //        object vOldstDos    = Validate.optDate   (oldestDOS,      msg);
        //        Object vClientID    = Validate.optInteger(clientID,       msg, true);
        //        Object vParentID    = Validate.optInteger(parentID,       msg, true);
        //        Object vReferenceID = Validate.reqInteger(referenceID,    msg, true);
        //        Object vStatus      = Validate.optInteger(status,         msg, true);
        //        Object vStatusFlags = Validate.optInteger(statusFlags,    msg, true);
        //        Object vIRRType     = Validate.optInteger(irrType,        msg, true);
        //        object vSentOn      = Validate.optDate   (sentOn,         msg);
        //        object vOpenedOn    = Validate.optDate   (openedOn,       msg);
        //        object vRespondedOn = Validate.optDate   (respondedOn,    msg);
        //        object vExpDate     = Validate.optDate   (expirationDate, msg);



        //        object vRecID = Validate.optInteger(recID, msg, true);
        //        int vSaveType = Validate.reqInteger(saveType, msg);


        //        List<SqlParameter> parms = new List<SqlParameter>();

        //        parms.Add(Database.SqlParm("@token",          SqlDbType.VarChar,  vToken,       ParameterDirection.Input));                
        //        parms.Add(Database.SqlParm("@userID",         SqlDbType.BigInt,   vUserID,      ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@clientID",       SqlDbType.Int,      vClientID,    ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@emailTittle",    SqlDbType.VarChar,  vEmailTittle, ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@emailMsg",       SqlDbType.VarChar,  vEmailMsg,    ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@emailTo",        SqlDbType.VarChar,  vEmailTo,     ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@emailCc",        SqlDbType.VarChar,  vEmailCc,     ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@fromUserID",     SqlDbType.BigInt,   vFromID,      ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@toUserID",       SqlDbType.BigInt,   vToID,        ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@toPracID",       SqlDbType.BigInt,   vToPracID,    ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@toName",         SqlDbType.VarChar,  vToName,      ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@parentID",       SqlDbType.BigInt,   vParentID,    ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@referenceID",    SqlDbType.BigInt,   vReferenceID, ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@oldestDOS",      SqlDbType.DateTime, vOldstDos,    ParameterDirection.Input));

        //        parms.Add(Database.SqlParm("@status",         SqlDbType.Int,      vStatus,      ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@statusFlags",    SqlDbType.Int,      vStatusFlags, ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@irrType",        SqlDbType.BigInt,   vIRRType,     ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@sentOn",         SqlDbType.DateTime, vSentOn,      ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@openedOn",       SqlDbType.DateTime, vOpenedOn,    ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@respondedOn",    SqlDbType.DateTime, vRespondedOn, ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@expirationDate", SqlDbType.DateTime, vExpDate,     ParameterDirection.Input));

               


        //        parms.Add(Database.SqlParm("@editDelReason", SqlDbType.VarChar, "",        ParameterDirection.Input, 7000));
        //        parms.Add(Database.SqlParm("@validateRec",   SqlDbType.Bit,     0,         ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@saveType",      SqlDbType.Int,     vSaveType, ParameterDirection.Input));
        //        parms.Add(Database.SqlParm("@recID",         SqlDbType.BigInt,  vRecID,    ParameterDirection.Input));

        //        parms.Add(Database.SqlParm("@MsgNotActive",  SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
        //        parms.Add(Database.SqlParm("@MsgDupRec",     SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
        //        parms.Add(Database.SqlParm("@MsgNoRec",      SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
        //        parms.Add(Database.SqlParm("@MsgNoEdit",     SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
        //        parms.Add(Database.SqlParm("@MsgNoFullEdit", SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
        //        parms.Add(Database.SqlParm("@MsgDataError",  SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
        //        parms.Add(Database.SqlParm("@recordID",      SqlDbType.BigInt,  null, ParameterDirection.Output));


        //        ReturnDB rd = Database.execSproc(conn, null, sql, parms);

        //        return rd.parameters[parms.Count-1].value.ToString();
        //    }
        //    catch (Exception ex)
        //    {
        //        MessageBox.Show(ex.Message);
        //    }
        //    return "";
        //}

       

        /***************************************************************************
         * INFO_REQUEST_RESPONSE_DETAILS_Delete */
        /**
         * "Deletes" a INFO_REQUEST_RESPONSE_DETAILS record
         ***************************************************************************/
        public static void InfoRequestResponseDetaildelete(SqlConnection conn, string editDelReason, string validateRec, string recID, string userID1)
        {
            string sql = "INFO_REQUEST_RESPONSE_DETAILS_Delete";
            string msg = null;
            ReturnSaveRecord so = new ReturnSaveRecord();

            try
            {
                bool vValidateRec = Validate.reqFlag(validateRec, msg);
                long vRecID        = Validate.reqInteger(recID, msg);
                List<SqlParameter> parms = new List<SqlParameter>();

                parms.Add(Database.SqlParm("@userID", SqlDbType.BigInt, userID1, ParameterDirection.Input));

                parms.Add(Database.SqlParm("@editDelReason", SqlDbType.VarChar, editDelReason, ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@validateRec",   SqlDbType.Bit,     vValidateRec,  ParameterDirection.Input));
                parms.Add(Database.SqlParm("@recID",         SqlDbType.BigInt,  vRecID,        ParameterDirection.Input));
                parms.Add(Database.SqlParm("@MsgNoRec",      SqlDbType.VarChar, msg,           ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoEdit",     SqlDbType.VarChar, msg,           ParameterDirection.Input, 1000));

                parms.Add(Database.SqlParm("@recordID", SqlDbType.BigInt, null, ParameterDirection.Output));

                /*----------------------------
                 * Call our stored procedure
                 *----------------------------*/
                ReturnDB rd = Database.execSproc(conn, null, sql, parms);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        /***************************************************************************
         * INFO_REQUEST_RESPONSE_Delete */
        /**
         * "Deletes" a INFO_REQUEST_RESPONSE record
         ***************************************************************************/
        public static void InfoRequestResponsedelete(SqlConnection conn, string editDelReason, string validateRec, string recID, string userID1)
        {
            string sql = "INFO_REQUEST_RESPONSE_Delete";
            string msg = null;
            ReturnSaveRecord so = new ReturnSaveRecord();

            try
            {
                bool vValidateRec = Validate.reqFlag(validateRec, msg);
                long vRecID       = Validate.reqInteger(recID, msg);
                List<SqlParameter> parms = new List<SqlParameter>();

                parms.Add(Database.SqlParm("@userID", SqlDbType.BigInt, userID1, ParameterDirection.Input));

                parms.Add(Database.SqlParm("@editDelReason", SqlDbType.VarChar, editDelReason, ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@validateRec",   SqlDbType.Bit,     vValidateRec,  ParameterDirection.Input));
                parms.Add(Database.SqlParm("@recID",         SqlDbType.BigInt,  vRecID,        ParameterDirection.Input));
                parms.Add(Database.SqlParm("@MsgNoRec",      SqlDbType.VarChar, msg,           ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoEdit",     SqlDbType.VarChar, msg,           ParameterDirection.Input, 1000));

                parms.Add(Database.SqlParm("@recordID",      SqlDbType.BigInt,  null,          ParameterDirection.Output));

                /*----------------------------
                 * Call our stored procedure
                 *----------------------------*/
                ReturnDB rd = Database.execSproc(conn, null, sql, parms);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        /*--------------------------------------------------
         * Change default "Enter" key behavior in DataGridView
         * so when Enter key is pressed it goes to next line in 
         * the datagridrow instead of going to next cell
         *--------------------------------------------------*/
        public class zxyDataGridView : DataGridView
        {

            protected override bool ProcessDataGridViewKey(KeyEventArgs e)
            {

                switch (e.KeyCode)
                {

                    case Keys.Tab:

                        return false;

                    case Keys.Enter:
                        {

                            if (this.EditingControl != null)
                            {

                                if (this.EditingControl is System.Windows.Forms.TextBox)
                                {

                                    System.Windows.Forms.TextBox tx = this.EditingControl as System.Windows.Forms.TextBox;

                                    int tmp = tx.SelectionStart;

                                    tx.Text = tx.Text.Insert(tx.SelectionStart, Environment.NewLine);

                                    tx.SelectionStart = tmp + Environment.NewLine.Length;
                                    return true;
                                }

                            }

                        }

                        return false;

                }

                return base.ProcessDataGridViewKey(e);

            }

        }

       public static void dataGridView1_EditingControlShowing(object sender,
            DataGridViewEditingControlShowingEventArgs e)
       {

           if (e.Control is System.Windows.Forms.TextBox)
           {

               System.Windows.Forms.TextBox tb = e.Control as System.Windows.Forms.TextBox;

               tb.AcceptsTab = true;

           }

       }


       /***************************************************************************
        * StampSave */
       /**
        ***************************************************************************/
       public static void StampSave(SqlConnection conn,
                                    string userID,
                                    string name,
                                    string description,
                                    string category,
                                    string type,                                                                 
                                    string editDelReason,
                                    string validateRec,
                                    string saveType,
                                    string recID
                                    )
       {
           string sql = "Stamp_Save";
           string msg = null;
           try
           {
               object vName           = Validate.reqString(name, msg);
               object vDescription    = Validate.reqString(description, msg);
               object vtype           = Validate.optString(type, msg);
               object vCategory       = Validate.optInteger(category, msg);
               object vUserID         = Validate.reqInteger(userID, msg, true);

               object vRecID = Validate.optInteger(recID, msg);
               int vSaveType = Validate.reqInteger(saveType, msg);


               List<SqlParameter> parms = new List<SqlParameter>();

              
               parms.Add(Database.SqlParm("@name",        SqlDbType.VarChar, vName,        ParameterDirection.Input));
               parms.Add(Database.SqlParm("@description", SqlDbType.VarChar, vDescription, ParameterDirection.Input));
               parms.Add(Database.SqlParm("@type",        SqlDbType.VarChar, vtype,        ParameterDirection.Input));
               parms.Add(Database.SqlParm("@category",    SqlDbType.Int,     vCategory,    ParameterDirection.Input));


               parms.Add(Database.SqlParm("@editDelReason", SqlDbType.VarChar, "",        ParameterDirection.Input, 7000));
               parms.Add(Database.SqlParm("@validateRec",   SqlDbType.Bit,     0,         ParameterDirection.Input));
               parms.Add(Database.SqlParm("@saveType",      SqlDbType.Int,     vSaveType, ParameterDirection.Input));
               parms.Add(Database.SqlParm("@recID",         SqlDbType.BigInt,  vRecID,    ParameterDirection.Input));
               parms.Add(Database.SqlParm("@userID",        SqlDbType.BigInt,  vUserID,   ParameterDirection.Input));

               parms.Add(Database.SqlParm("@MsgNotActive",  SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
               parms.Add(Database.SqlParm("@MsgDupRec",     SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
               parms.Add(Database.SqlParm("@MsgNoRec",      SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
               parms.Add(Database.SqlParm("@MsgNoEdit",     SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
               parms.Add(Database.SqlParm("@MsgDataError",  SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
               parms.Add(Database.SqlParm("@recordID",      SqlDbType.BigInt, null, ParameterDirection.Output));


               ReturnDB rd = Database.execSproc(conn, null, sql, parms);
           }
           catch (Exception ex)
           {
               MessageBox.Show(ex.Message);
           }
       }


       /***************************************************************************
      * Stamps_VIEW */
       /**
        ***************************************************************************/
       //public static DataTable StampsView(SqlConnection conn,                                                
       //                                         string category,
       //                                         string canedit,
       //                                         string active,
       //                                         string recID
       //                                         )
       //{
       //    string sql = "SELECT * FROM Stamps_VIEW(@recID,@category,@type,@active,@canEdit)";

       //    string msg = null;

       //    object vtype     = Validate.optString ("Qform",  msg);
       //    object vCategory = Validate.optInteger(category, msg);
       //    object vRecID    = Validate.optInteger(recID,    msg);
       //    Object vActive   = Validate.optFlag   (active,   msg);
       //    Object vCanEdit  = Validate.optFlag   (canedit,  msg);

       //    List<SqlParameter> parms = new List<SqlParameter>();

       //    parms.Add(Database.SqlParm("@type",     SqlDbType.VarChar, vtype,     ParameterDirection.Input));
       //    parms.Add(Database.SqlParm("@category", SqlDbType.Int,     vCategory, ParameterDirection.Input));

       //    parms.Add(Database.SqlParm("@recID",    SqlDbType.BigInt,  vRecID, ParameterDirection.Input));
       //    parms.Add(Database.SqlParm("@active",   SqlDbType.Bit,     vActive, ParameterDirection.Input));
       //    parms.Add(Database.SqlParm("@canEdit",  SqlDbType.Bit,     vCanEdit, ParameterDirection.Input));

       //    DataTable dt = new DataTable();
       //    try
       //    {
       //        ReturnDB rd = Database.execQuery(SBSCParent.connSpedmon, null, sql, false, parms);
       //        dt = Database.convertReturnDBToDatatable(ref rd);
       //    }
       //    catch (Exception ex)
       //    {
       //        MessageBox.Show(ex.Message);
       //    }
       //    return dt;
       //}

       /***************************************************************************
        * STAMP_Delete */
       /**
        * "Deletes" a STAMP record
        ***************************************************************************/
       public static void StampDelete(SqlConnection conn, string editDelReason, string validateRec, string recID, string userID1)
       {
           string sql = "STAMP_Delete";
           string msg = null;
           ReturnSaveRecord so = new ReturnSaveRecord();

           try
           {
               bool vValidateRec = Validate.reqFlag(validateRec, msg);
               long vRecID       = Validate.reqInteger(recID, msg);
               List<SqlParameter> parms = new List<SqlParameter>();

               parms.Add(Database.SqlParm("@userID", SqlDbType.BigInt, userID1, ParameterDirection.Input));

               parms.Add(Database.SqlParm("@editDelReason", SqlDbType.VarChar, editDelReason, ParameterDirection.Input, 7000));
               parms.Add(Database.SqlParm("@validateRec",   SqlDbType.Bit,     vValidateRec,  ParameterDirection.Input));
               parms.Add(Database.SqlParm("@recID",         SqlDbType.BigInt,  vRecID,        ParameterDirection.Input));
               parms.Add(Database.SqlParm("@MsgNoRec",      SqlDbType.VarChar, msg,           ParameterDirection.Input, 1000));
               parms.Add(Database.SqlParm("@MsgNoEdit",     SqlDbType.VarChar, msg,           ParameterDirection.Input, 1000));

               parms.Add(Database.SqlParm("@recordID",      SqlDbType.BigInt,  null,          ParameterDirection.Output));

               /*----------------------------
                * Call our stored procedure
                *----------------------------*/
               ReturnDB rd = Database.execSproc(conn, null, sql, parms);
           }
           catch (Exception ex)
           {
               MessageBox.Show(ex.Message);
           }
       }


    }
}
