using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Windows.Forms;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace WORKFLOW
{
    /***************************************************************************
     * INPUT_BATCHES */
    /**
     * Methods to manage INPUT_BATCHES
     ***************************************************************************/
    class InputBatches
    {
        
        /***************************************************************************
         * INPUT_BATCHES_SAVE */
        /**
         ***************************************************************************/
        public static void InputBatchesSave(SqlConnection conn,
                                            string filename,
                                            string clientID,                                            
                                            string dateSent,
                                            string dateRecieved,
                                            string fileloc,
                                            string partial,
                                            string parentID,
                                            string typeofwork,
                                            string oldestDOS,
                                            string estinputhrs,
                                            string userID1,
                                            string userID2,
                                            string prtnum,
                                            string degofdiff,
                                            string statuscode,
                                            string notes,
                                            string editDelReason,
                                            string validateRec,
                                            string saveType,
                                            string recID)
        {
            string sql = "INPUTBATCHES_SAVE";
            string msg = null;
            try
            {              
                string vfilename    = Validate.reqString(filename, "");
                string vfileloc     = Validate.reqString(fileloc, "");
                object vtypofwrk    = Validate.reqInteger(typeofwork, msg,true);

                object vOldstDos    = Validate.optDate   (oldestDOS,    msg);
                object vClientID    = Validate.reqInteger(clientID,     msg);
                object vDateSent    = Validate.reqDate   (dateSent,     msg);
                object vDateRcvd    = Validate.optDate   (dateRecieved, msg);
                object vParentID    = Validate.optInteger(parentID,     msg);
                object vEstInputHrs = null;
                if (estinputhrs != "")
                   vEstInputHrs     = Convert.ToDecimal(estinputhrs);
                object vUserID1     = Validate.optInteger(userID1,    msg, true);
                object vUserID2     = Validate.optInteger(userID2,    msg, true);
                object vPrtNum      = Validate.optInteger(prtnum,     msg, true);
                object vDegOfDiff   = Validate.optInteger(degofdiff,  msg, true);
                object vStatus      = Validate.optInteger(statuscode, msg, true);
                object vRecID       = Validate.optInteger(recID,      msg, true);
                Object vNotes       = Validate.optString (notes,      msg);
                Object vPartial     = Validate.optFlag   (partial,    msg);
                int vSaveType       = Validate.reqInteger(saveType,   msg);

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
                parms.Add(Database.SqlParm("@editDelReason",   SqlDbType.VarChar,  "",           ParameterDirection.Input, 7000));
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
            string sql;
            
            /* If the user is NOT considered input staff */
            
            if (!SBSCParent.isInputStaff)
            {
                /* If an actual status code is provided then we use the following query */
                
                if (statuscode != "")
                    sql = "SELECT * FROM INPUT_BATCHES_VIEW(@recID,@fileName,@fileloc,@status,@clientID,@workType,@assignedTo,@active,@canEdit)";
                
                /* If a blank status code is provided then we use the following query to show all "work in process".  */
                
                else
                {
                    sql = "select * FROM dbo.INPUT_BATCHES_VIEW(@recID,@fileName,@fileloc,@status,@clientID,@workType,@assignedTo,@active,@canEdit) " 
                        + "where (statuscode between 10 and 110) or (statuscode in (130,250))";                          
                }                                   
            }

            /* If the user is considered input staff */

            else
            {
                sql = "SELECT * FROM INPUT_BATCHES_VIEW(@recID,@fileName,@fileloc,@status,@clientID,@workType,@assignedTo,@active,@canEdit)" +
                      "where statuscode not in (" + FileStatus.ReviewInputComplete.ToString() + "," + FileStatus.CIS.ToString() + "," + FileStatus.ReviewStarted.ToString() + ")";
            }
            
            string msg = null;              

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
            parms.Add(Database.SqlParm("@fileName",   SqlDbType.VarChar,  vfilename,   ParameterDirection.Input, 7000));
            parms.Add(Database.SqlParm("@fileloc",    SqlDbType.VarChar,  vfileloc,    ParameterDirection.Input, 7000));
            parms.Add(Database.SqlParm("@workType",   SqlDbType.Int,      vtypofwrk,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@assignedTo", SqlDbType.BigInt,   vAssignedTo, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@clientID",   SqlDbType.Int,      vClientID,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@status",     SqlDbType.SmallInt, vStatus,     ParameterDirection.Input));                
            parms.Add(Database.SqlParm("@recID",      SqlDbType.BigInt,   vRecID,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@active",     SqlDbType.Bit,      vActive,     ParameterDirection.Input));
            parms.Add(Database.SqlParm("@canEdit",    SqlDbType.Bit,      vCanEdit,    ParameterDirection.Input));

            DataTable dt = new DataTable();
            try
            {                
                ReturnDB rd = Database.execQuery(SBSCParent.connSpedmon, null, sql, false, parms);                
                dt = Database.convertReturnDBToDatatable(ref rd);                              
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
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
        public static DataTable Practitioners_Problems_VIEW(SqlConnection conn,
                                                            string clientID,
                                                            string pracID,
                                                            string batchID,
                                                            string status,
                                                            string ctgryID,                                                                                                                  
                                                            string active
                                                            )
        {
            string sql = "select * from RPT_PRACTITONERS_REVIEWS(@clientID,@pracID,@batchID,@statusID,@ctgryID,1)";
                            
            string msg = null;

            object vCtgryID  = MBA.Validate.optInteger(ctgryID,  "", true);
            object vPracID   = MBA.Validate.optInteger(pracID,   "", true);
            object vBatchID  = MBA.Validate.optInteger(batchID,  "", true);
            object vstatusID = MBA.Validate.optInteger(status,   "", true);

            object vClientID = MBA.Validate.optInteger(clientID, "", true);           
            Object vActive   = Validate.optFlag(active, msg);

            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@ctgryID",  SqlDbType.Int,    vCtgryID,  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID",   SqlDbType.BigInt, vPracID,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@batchID",  SqlDbType.BigInt, vBatchID,  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@statusID", SqlDbType.Int,    vstatusID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int,    vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@active",   SqlDbType.Bit,    vActive,   ParameterDirection.Input));

            DataTable dt = new DataTable();
            try
            {
                ReturnDB rd = Database.execQuery(SBSCParent.connSpedmon, null, sql, false, parms);
                dt = Database.convertReturnDBToDatatable(ref rd);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            return dt;
        }

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
        public static DataTable InputBatchesWorkControlView(SqlConnection conn,                                                 
                                                 string worktype,                                                 
                                                 string clientID,                                                 
                                                 string canedit,
                                                 string active,
                                                 string recID
                                                 )
        {
            string sql = "SELECT * FROM INPUT_BATCHES_WORK_CONTROL_VIEW(@recID,@clientID,@workType,@active,@canEdit)";
               
            string msg = null;

            Object vClientID = Validate.optInteger(clientID, msg, true);           
            object vtypofwrk = Validate.optInteger(worktype, msg, true);            
            object vRecID    = Validate.optInteger(recID,    msg, true);
            Object vActive   = Validate.optFlag   (active,   msg);
            Object vCanEdit  = Validate.optFlag   (canedit,  msg);

            List<SqlParameter> parms = new List<SqlParameter>();
           
            parms.Add(Database.SqlParm("@workType", SqlDbType.Int,    vtypofwrk, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int,    vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@recID",    SqlDbType.BigInt, vRecID,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@active",   SqlDbType.Bit,    vActive,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@canEdit",  SqlDbType.Bit,    vCanEdit,  ParameterDirection.Input));

            DataTable dt = new DataTable();
            try
            {
                ReturnDB rd = Database.execQuery(SBSCParent.connSpedmon, null, sql, false, parms);
                dt = Database.convertReturnDBToDatatable(ref rd);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            return dt;
        }


        /***************************************************************************
         * InfoRequestDetailsSave */
        /**
         ***************************************************************************/
        public static void InfoRequestResponseDetailSave(SqlConnection conn,
                                                 string userID,       
                                                 string irrID,
                                                 string detailNum,
                                                 string stndQuestionID,
                                                 string question,                                                                                                  
                                                 string questionType,                                                 
                                                 string editDelReason,    
                                                 string validateRec,    
                                                 string saveType,    
                                                 string recID
                                                 )
        {
            string sql = "INFO_REQUEST_RESPONSE_DETAILS_Save";
            string msg = null;
            try
            {
                object vIrrID        = Validate.reqInteger(irrID,          msg, true);
                object vUserID       = Validate.reqInteger(userID,         msg, true);
                object vDetailNum    = Validate.reqInteger(detailNum,      msg, true);
                object vQuestionID   = Validate.optInteger(stndQuestionID, msg, true);
                Object vQuestion     = Validate.reqString (question,       "");
                object vQuestionType = Validate.optInteger(questionType,   msg, true);
                object vRecID        = Validate.optInteger(recID,          msg, true);
                int    vSaveType     = Validate.reqInteger(saveType,       msg);


                List<SqlParameter> parms = new List<SqlParameter>();

                parms.Add(Database.SqlParm("@irrID",          SqlDbType.BigInt,  vIrrID,        ParameterDirection.Input));
                parms.Add(Database.SqlParm("@detailNum",      SqlDbType.BigInt,  vDetailNum,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@userID",         SqlDbType.BigInt,  vUserID,       ParameterDirection.Input));
                parms.Add(Database.SqlParm("@question",       SqlDbType.VarChar, vQuestion,     ParameterDirection.Input));
                parms.Add(Database.SqlParm("@stndQuestionID", SqlDbType.BigInt,  vQuestionID,   ParameterDirection.Input));
                parms.Add(Database.SqlParm("@questionType",   SqlDbType.BigInt,  vQuestionType, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@answer",         SqlDbType.VarChar, null,          ParameterDirection.Input));
                parms.Add(Database.SqlParm("@stndAnswerID",   SqlDbType.BigInt,  null,          ParameterDirection.Input));
                parms.Add(Database.SqlParm("@answerType",     SqlDbType.BigInt,  null,          ParameterDirection.Input));


                parms.Add(Database.SqlParm("@editDelReason",  SqlDbType.VarChar, "",        ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@validateRec",    SqlDbType.Bit,     0,         ParameterDirection.Input));
                parms.Add(Database.SqlParm("@saveType",       SqlDbType.Int,     vSaveType, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@recID",          SqlDbType.BigInt,  vRecID,    ParameterDirection.Input));

                parms.Add(Database.SqlParm("@MsgNotActive",   SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgDupRec",      SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoRec",       SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoEdit",      SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoFullEdit",  SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgDataError",   SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@recordID",       SqlDbType.BigInt, null, ParameterDirection.Output));


                ReturnDB rd = Database.execSproc(conn, null, sql, parms);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        /***************************************************************************
         * InfoRequestResponseSave */
        /**
         ***************************************************************************/
        public static string InfoRequestResponseSave(SqlConnection conn,
                                                   string userID,
                                                   string token,
                                                   string emailTittle,
                                                   string emailMsg,
                                                   string emailTo,
                                                   string emailCc,
                                                   string clientID,
                                                   string toUserID,
                                                   string toName,
                                                   string toPracID,
                                                   string fromUserID,
                                                   string parentID,
                                                   string referenceID,
                                                   string oldestDOS,
                                                   string status,
                                                   string statusFlags,
                                                   string irrType,
                                                   string sentOn,
                                                   string openedOn,
                                                   string respondedOn,
                                                   string expirationDate,
                                                   string editDelReason,
                                                   string validateRec,
                                                   string saveType,
                                                   string recID
                                                   )
        {
            string sql = "INFO_REQUEST_RESPONSE_Save";
            string msg = null;
            try
            {
                object vToken       = Validate.optString (token,          msg);
                object vUserID      = Validate.reqInteger(userID,         msg, true);
                object vEmailTittle = Validate.reqString (emailTittle,    msg);
                object vEmailMsg    = Validate.reqString (emailMsg,       msg);
                object vEmailTo     = Validate.reqString (emailTo,        msg);
                object vEmailCc     = Validate.optString (emailCc,        msg);
                object vFromID      = Validate.reqInteger(fromUserID,     msg);
                object vToName      = Validate.optString(toName, msg);
                object vToID        = Validate.optInteger(toUserID,       msg);
                object vToPracID    = Validate.optInteger(toPracID,       msg);
                object vOldstDos    = Validate.optDate   (oldestDOS,      msg);
                Object vClientID    = Validate.optInteger(clientID,       msg, true);
                Object vParentID    = Validate.optInteger(parentID,       msg, true);
                Object vReferenceID = Validate.reqInteger(referenceID,    msg, true);
                Object vStatus      = Validate.optInteger(status,         msg, true);
                Object vStatusFlags = Validate.optInteger(statusFlags,    msg, true);
                Object vIRRType     = Validate.optInteger(irrType,        msg, true);
                object vSentOn      = Validate.optDate   (sentOn,         msg);
                object vOpenedOn    = Validate.optDate   (openedOn,       msg);
                object vRespondedOn = Validate.optDate   (respondedOn,    msg);
                object vExpDate     = Validate.optDate   (expirationDate, msg);



                object vRecID = Validate.optInteger(recID, msg, true);
                int vSaveType = Validate.reqInteger(saveType, msg);


                List<SqlParameter> parms = new List<SqlParameter>();

                parms.Add(Database.SqlParm("@token",          SqlDbType.VarChar,  vToken,       ParameterDirection.Input));                
                parms.Add(Database.SqlParm("@userID",         SqlDbType.BigInt,   vUserID,      ParameterDirection.Input));
                parms.Add(Database.SqlParm("@clientID",       SqlDbType.Int,      vClientID,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@emailTittle",    SqlDbType.VarChar,  vEmailTittle, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@emailMsg",       SqlDbType.VarChar,  vEmailMsg,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@emailTo",        SqlDbType.VarChar,  vEmailTo,     ParameterDirection.Input));
                parms.Add(Database.SqlParm("@emailCc",        SqlDbType.VarChar,  vEmailCc,     ParameterDirection.Input));
                parms.Add(Database.SqlParm("@fromUserID",     SqlDbType.BigInt,   vFromID,      ParameterDirection.Input));
                parms.Add(Database.SqlParm("@toUserID",       SqlDbType.BigInt,   vToID,        ParameterDirection.Input));
                parms.Add(Database.SqlParm("@toPracID",       SqlDbType.BigInt,   vToPracID,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@toName",         SqlDbType.VarChar,  vToName,      ParameterDirection.Input));
                parms.Add(Database.SqlParm("@parentID",       SqlDbType.BigInt,   vParentID,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@referenceID",    SqlDbType.BigInt,   vReferenceID, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@oldestDOS",      SqlDbType.DateTime, vOldstDos,    ParameterDirection.Input));

                parms.Add(Database.SqlParm("@status",         SqlDbType.Int,      vStatus,      ParameterDirection.Input));
                parms.Add(Database.SqlParm("@statusFlags",    SqlDbType.Int,      vStatusFlags, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@irrType",        SqlDbType.BigInt,   vIRRType,     ParameterDirection.Input));
                parms.Add(Database.SqlParm("@sentOn",         SqlDbType.DateTime, vSentOn,      ParameterDirection.Input));
                parms.Add(Database.SqlParm("@openedOn",       SqlDbType.DateTime, vOpenedOn,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@respondedOn",    SqlDbType.DateTime, vRespondedOn, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@expirationDate", SqlDbType.DateTime, vExpDate,     ParameterDirection.Input));

               


                parms.Add(Database.SqlParm("@editDelReason", SqlDbType.VarChar, "",        ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@validateRec",   SqlDbType.Bit,     0,         ParameterDirection.Input));
                parms.Add(Database.SqlParm("@saveType",      SqlDbType.Int,     vSaveType, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@recID",         SqlDbType.BigInt,  vRecID,    ParameterDirection.Input));

                parms.Add(Database.SqlParm("@MsgNotActive",  SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgDupRec",     SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoRec",      SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoEdit",     SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoFullEdit", SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgDataError",  SqlDbType.VarChar, msg, ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@recordID",      SqlDbType.BigInt,  null, ParameterDirection.Output));


                ReturnDB rd = Database.execSproc(conn, null, sql, parms);

                return rd.parameters[parms.Count-1].value.ToString();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            return "";
        }

       

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
       public static DataTable StampsView(SqlConnection conn,                                                
                                                string category,
                                                string canedit,
                                                string active,
                                                string recID
                                                )
       {
           string sql = "SELECT * FROM Stamps_VIEW(@recID,@category,@type,@active,@canEdit)";

           string msg = null;

           object vtype     = Validate.optString ("Qform",  msg);
           object vCategory = Validate.optInteger(category, msg);
           object vRecID    = Validate.optInteger(recID,    msg);
           Object vActive   = Validate.optFlag   (active,   msg);
           Object vCanEdit  = Validate.optFlag   (canedit,  msg);

           List<SqlParameter> parms = new List<SqlParameter>();

           parms.Add(Database.SqlParm("@type",     SqlDbType.VarChar, vtype,     ParameterDirection.Input));
           parms.Add(Database.SqlParm("@category", SqlDbType.Int,     vCategory, ParameterDirection.Input));

           parms.Add(Database.SqlParm("@recID",    SqlDbType.BigInt,  vRecID, ParameterDirection.Input));
           parms.Add(Database.SqlParm("@active",   SqlDbType.Bit,     vActive, ParameterDirection.Input));
           parms.Add(Database.SqlParm("@canEdit",  SqlDbType.Bit,     vCanEdit, ParameterDirection.Input));

           DataTable dt = new DataTable();
           try
           {
               ReturnDB rd = Database.execQuery(SBSCParent.connSpedmon, null, sql, false, parms);
               dt = Database.convertReturnDBToDatatable(ref rd);
           }
           catch (Exception ex)
           {
               MessageBox.Show(ex.Message);
           }
           return dt;
       }

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
