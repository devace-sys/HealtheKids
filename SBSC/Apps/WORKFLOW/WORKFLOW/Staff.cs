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
     * Staff_Hours */
    /**
     * Methods to manage Staff_Hours
     ***************************************************************************/
    class Staff

    {
        //constant for Qform worktype ID from Spedmon.dbo.TYPE_OF_WORK table
        public static int QformWorkTypeID = 16;


        /***************************************************************************
         * StaffHoursSave */
        /**
         ***************************************************************************/
        
        public static void StaffHoursSave(SqlConnection conn,
                                            string staffID,
                                            string startdate,
                                            string day,
                                            string shift1start,
                                            string shift1end,
                                            string shift2start,
                                            string shift2end,
                                            string shift3start,
                                            string shift3end,                                           
                                            string notes,
                                            string totalHours,
                                            string editDelReason,
                                            string validateRec,
                                            string saveType,
                                            string recID)
        {
            string sql = "STAFF_PROMISED_HOURS_Save";
            string msg = null;
            try
            {
                int vStaffID        = Validate.reqInteger(staffID,   msg);
                object vStartdate   = Validate.reqDate   (startdate, msg, Constants.VAL_OPT_DATE_NONE);
                object vDay         = Validate.reqDate   (day,       msg, Constants.VAL_OPT_DATE_NONE);

                object vShift1start = WinFormsCommon.optTime(shift1start);
                object vShift1end   = WinFormsCommon.optTime(shift1end);
                object vShift2start = WinFormsCommon.optTime(shift2start);
                object vShift2end   = WinFormsCommon.optTime(shift2end);
                object vShift3start = WinFormsCommon.optTime(shift3start);
                object vShift3end   = WinFormsCommon.optTime(shift3end);
                Object vNotes       = Validate.optString(notes,      msg);
                object vTotalHours  = Validate.optString(totalHours, msg);
                int vSaveType       = Validate.reqInteger(saveType,  msg);
                object vRecID       = Validate.optInteger(recID,     msg, true);

                List<SqlParameter> parms = new List<SqlParameter>();
                parms.Add(Database.SqlParm("@staffID",       SqlDbType.Int,      vStaffID,     ParameterDirection.Input, 7000));                
                parms.Add(Database.SqlParm("@weekstart",     SqlDbType.DateTime, vStartdate,   ParameterDirection.Input));
                parms.Add(Database.SqlParm("@day",           SqlDbType.DateTime, vDay,         ParameterDirection.Input));

                parms.Add(Database.SqlParm("@shift1Start",   SqlDbType.Time,     vShift1start, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@shift1End",     SqlDbType.Time,     vShift1end,   ParameterDirection.Input));
                parms.Add(Database.SqlParm("@shift2Start",   SqlDbType.Time,     vShift2start, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@shift2End",     SqlDbType.Time,     vShift2end,   ParameterDirection.Input));
                parms.Add(Database.SqlParm("@shift3Start",   SqlDbType.Time,     vShift3start, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@shift3End",     SqlDbType.Time,     vShift3end,   ParameterDirection.Input));

                parms.Add(Database.SqlParm("@note",          SqlDbType.VarChar,  vNotes,       ParameterDirection.Input));
                parms.Add(Database.SqlParm("@totalHrs",      SqlDbType.VarChar,  vTotalHours,  ParameterDirection.Input));

                parms.Add(Database.SqlParm("@editDelReason", SqlDbType.VarChar,  "",           ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@validateRec",   SqlDbType.Bit,      0,            ParameterDirection.Input));
                parms.Add(Database.SqlParm("@saveType",      SqlDbType.Int,      vSaveType,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@recID",         SqlDbType.BigInt,   vRecID,       ParameterDirection.Input));

                parms.Add(Database.SqlParm("@MsgNotActive",  SqlDbType.VarChar,  msg,          ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgDupRec",     SqlDbType.VarChar,  msg,          ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoRec",      SqlDbType.VarChar,  msg,          ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoEdit",     SqlDbType.VarChar,  msg,          ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgDataError",  SqlDbType.VarChar,  msg,          ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@recordID",      SqlDbType.BigInt,   null,         ParameterDirection.Output));

                ReturnDB rd = Database.execQuery(conn, null, sql, true, parms);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

        }

        /***************************************************************************
        * StaffHoursView */
        /**
         ***************************************************************************/
        public static DataTable StaffHoursView(SqlConnection conn,
                                                 string staffID,
                                                 string startdate, 
                                                 string day,                                    
                                                 string canedit,
                                                 string active,
                                                 string recID)
        {
            if (SBSCParent.isInputStaff)
                staffID = SBSCParent.userID.ToString();

            string sql = "SELECT * FROM STAFF_PROMISED_HOURS_VIEW(@recid,@staffid,@startdate,@day,@active,@canedit) ";

            string msg = null;

            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.CommandType = CommandType.Text;

            Object vStaffID   = Validate.optInteger(staffID,   msg, true);
            object vStartdate = Validate.reqDate   (startdate, msg, Constants.VAL_OPT_DATE_NONE);
            object vday       = Validate.optDate   (day,       msg, Constants.VAL_OPT_DATE_NONE);

            object vRecID     = Validate.optInteger(recID,     msg, true);
            Object vActive    = Validate.optFlag   (active,    msg);
            Object vCanEdit   = Validate.optFlag   (canedit,   msg);

            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@staffID",   SqlDbType.Int,      vStaffID,   ParameterDirection.Input, 7000));
            parms.Add(Database.SqlParm("@startdate", SqlDbType.DateTime, vStartdate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@day",       SqlDbType.DateTime, vday,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@recID",     SqlDbType.BigInt,   vRecID,     ParameterDirection.Input));
            parms.Add(Database.SqlParm("@active",    SqlDbType.Bit,      vActive,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@canEdit",   SqlDbType.Bit,      vCanEdit,   ParameterDirection.Input));

            ReturnDB rd = Database.execQuery(conn, null, sql, false, parms);
            return (Database.convertReturnDBToDatatable(ref rd));

        }

        /***************************************************************************
        * TRAINED_STAFF_VIEW */
        /**
         ***************************************************************************/
        public static DataTable TrainedStaffView(SqlConnection conn,
                                                 string workTypeID, 
                                                 string staffID,                                   
                                                 string isTrained,
                                                 string recID)
        {

            string sql = "SELECT * FROM TRAINED_STAFF_VIEW(@recid,@workTypeid,@staffID,@isTrained) ";

            string msg = null;

            SqlCommand cmd  = new SqlCommand(sql, conn);
            cmd.CommandType = CommandType.Text;

            Object vWorkTypeID = Validate.optInteger(workTypeID, msg, true);
            Object vStaffID    = Validate.optInteger(staffID,    msg, true);

            object vRecID      = Validate.optInteger(recID,      msg, true);
            Object vTrained    = Validate.optFlag   (isTrained,  msg);

            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@workTypeID", SqlDbType.Int,    vWorkTypeID, ParameterDirection.Input, 7000));
            parms.Add(Database.SqlParm("@staffID",    SqlDbType.Int,    vStaffID,    ParameterDirection.Input, 7000));
            parms.Add(Database.SqlParm("@recID",      SqlDbType.BigInt, vRecID,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@isTrained",  SqlDbType.Bit,    vTrained,    ParameterDirection.Input));

            ReturnDB rd = Database.execQuery(conn, null, sql, false, parms);
            return (Database.convertReturnDBToDatatable(ref rd));

        }

        /***************************************************************************
        * TRAINED_STAFF_DETAIL_VIEW */
        /**
         ***************************************************************************/
        public static DataTable TrainedStaffDetailView(SqlConnection conn,string staffName)                                                 
        {

            string sql      = "SELECT * FROM RPT_STAFF_TRAINING_RECORDS() where staffname like '"+staffName+"%'";
            SqlCommand cmd  = new SqlCommand(sql, conn);
            cmd.CommandType = CommandType.Text;

            ReturnDB rd     = Database.execQuery(conn, null, sql, false, null);
            return (Database.convertReturnDBToDatatable(ref rd));

        }


        /***************************************************************************
         * Trained_Staff_Save */
        /**
         * Saves a Staff audit review record
         * 
         * @param  staffID                Input staff ID       
         * @param  workTypeID
         * @param  rate 
         * @param  userID
         * @param  auditDate         
         * @param  notes
         ***************************************************************************/
        public static void TrainedStaffSave(SqlConnection conn,
                                            string staffID,
                                            string workID,
                                            string isTrained,
                                            string rating,
                                            string notes,
                                            string editDelReason,
                                            string validateRec,
                                            string saveType,
                                            string recID)
        {
            string sql = "TRAINED_STAFF_Save";
            string msg = null;
            try
            {
                int vStaffID      = Validate.reqInteger(staffID, msg);
                int vWorkTypeID   = Validate.reqInteger(workID, msg);
                object vRating    = Validate.optInteger(rating, msg);
                Object vIsTrained = Validate.optFlag(isTrained, msg);

             
                Object vNotes = Validate.optString(notes, msg);
                int vSaveType = Validate.reqInteger(saveType, msg);
                object vRecID = Validate.optInteger(recID, msg, true);

                List<SqlParameter> parms = new List<SqlParameter>();
                parms.Add(Database.SqlParm("@staffID",       SqlDbType.Int,     vStaffID,    ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@workTypeID",    SqlDbType.Int,     vWorkTypeID, ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@rate",          SqlDbType.Int,     vRating,     ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@trained",       SqlDbType.Bit,     vIsTrained,  ParameterDirection.Input));
                 
                parms.Add(Database.SqlParm("@note",          SqlDbType.VarChar, vNotes,      ParameterDirection.Input));
                parms.Add(Database.SqlParm("@editDelReason", SqlDbType.VarChar, "",          ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@validateRec",   SqlDbType.Bit,     1,           ParameterDirection.Input));
                parms.Add(Database.SqlParm("@saveType",      SqlDbType.Int,     vSaveType,   ParameterDirection.Input));
                parms.Add(Database.SqlParm("@recID",         SqlDbType.BigInt,  vRecID,      ParameterDirection.Input));

                parms.Add(Database.SqlParm("@MsgNotActive",  SqlDbType.VarChar, msg,         ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgDupRec",     SqlDbType.VarChar, msg,         ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoRec",      SqlDbType.VarChar, msg,         ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoEdit",     SqlDbType.VarChar, msg,         ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgDataError",  SqlDbType.VarChar, msg,         ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@recordID",      SqlDbType.BigInt, null,         ParameterDirection.Output));

                ReturnDB rd = Database.execQuery(conn, null, sql, true, parms);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

        }


        /***************************************************************************
         * STAFF_AUDIT_REVIEW_Save */
        /**
         * Saves a Staff audit review record
         * 
         * @param  staffID                Input staff ID       
         * @param  workTypeID
         * @param  rate 
         * @param  userID
         * @param  auditDate         
         * @param  notes
         ***************************************************************************/
        public static void StaffAuditReviewSave(SqlConnection conn,
                                                string staffID,
                                                string workID,                                                
                                                string rating,
                                                string notes,
                                                string auditDate,
                                                string userID
                                                )
        {
            string sql = "STAFF_AUDIT_REVIEW_Save";
            string msg = null;
            try
            {
                int vStaffID       = Validate.reqInteger(staffID,   msg);
                int vWorkTypeID    = Validate.reqInteger(workID,    msg);
                object vRating     = Validate.optInteger(rating,    msg);
                object vAudittdate = Validate.reqDate   (auditDate, msg, Constants.VAL_OPT_DATE_NONE);
                Object vNotes      = Validate.optString (notes,     msg);
                object vUserID     = Validate.optInteger(userID,    msg, true);

                List<SqlParameter> parms = new List<SqlParameter>();
                parms.Add(Database.SqlParm("@staffID",    SqlDbType.Int,      vStaffID,    ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@workTypeID", SqlDbType.Int,      vWorkTypeID, ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@rate",       SqlDbType.Int,      vRating,     ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@userID",     SqlDbType.Int,      vUserID,     ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@auditDate",  SqlDbType.DateTime, vAudittdate, ParameterDirection.Input));                            
                parms.Add(Database.SqlParm("@note",       SqlDbType.VarChar,  vNotes,      ParameterDirection.Input));                            
                ReturnDB rd = Database.execQuery(conn, null, sql, true, parms);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

        }

        //STAFF_REVIEWS

        /***************************************************************************
         * Staff_Review_SAVE */
        /**
         * Saves or edits a staff
         ***************************************************************************/
        public static void StaffReviewSave(SqlConnection conn,
                                            string StaffID,
                                            string batchID,
                                            string categoryID,
                                            string userID,
                                            string review,
                                            string saveType
                                            )
        {
            string sql = "Staff_Review_Save";
            string msg = null;
            try
            {
                object vStaffID    = Validate.optInteger(StaffID,    msg, true);
                object vUserID     = Validate.optInteger(userID,     msg, true);
                object vCategoryID = Validate.optInteger(categoryID, msg, true);
                object vBatchID    = Validate.optInteger(batchID,    msg, true);
                Object vReview     = Validate.optString (review,     "");

                List<SqlParameter> parms = new List<SqlParameter>();

                parms.Add(Database.SqlParm("@StaffID",    SqlDbType.BigInt,  vStaffID,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@batchID",    SqlDbType.BigInt,  vBatchID,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@categoryID", SqlDbType.BigInt,  vCategoryID, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@userID",     SqlDbType.BigInt,  vUserID,     ParameterDirection.Input));
                parms.Add(Database.SqlParm("@review",     SqlDbType.VarChar, vReview,     ParameterDirection.Input));

                ReturnDB rd = Database.execSproc(conn, null, sql, parms);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        /***************************************************************************
        * STAFF_REVIEW_DELETE */
        /**
         * "Deletes" a Staffs_Problems record
         ***************************************************************************/
        public static void Staffs_Problems_delete(SqlConnection conn, string editDelReason, string validateRec, string recID, string userID1)
        {
            string sql = "STAFF_REVIEW_Delete";
            string msg = null;
            ReturnSaveRecord so = new ReturnSaveRecord();

            try
            {
                bool vValidateRec = Validate.reqFlag(validateRec, msg);
                long vRecID       = Validate.reqInteger(recID,    msg);

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
         * Staffs_Problems_VIEW */
        /**
         ***************************************************************************/
        public static DataTable Staffs_Problems_VIEW(SqlConnection conn,
                                                            string StaffID,
                                                            string batchID,
                                                            string ctgryID,
                                                            string active
                                                            )
        {
            string sql = "select * from RPT_STAFF_REVIEWS(@StaffID,@batchID,@ctgryID,1)";


            string msg = null;

            object vCtgryID = MBA.Validate.optInteger(ctgryID, "", true);
            object vStaffID = MBA.Validate.optInteger(StaffID, "", true);
            object vBatchID = MBA.Validate.optInteger(batchID, "", true);
            Object vActive  = Validate.optFlag(active, msg);

            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@ctgryID", SqlDbType.Int,    vCtgryID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@StaffID", SqlDbType.BigInt, vStaffID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@batchID", SqlDbType.BigInt, vBatchID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@active",  SqlDbType.Bit,    vActive, ParameterDirection.Input));

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
    }
}
