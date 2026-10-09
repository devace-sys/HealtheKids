using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Windows.Forms;
using System.Data;
using System.Data.SqlClient;
using MBA;


namespace StudentDataTracking
{
    class StudentData
    {
        /***************************************************************************
          * Student_Data_File_SAVE */
        /**
         ***************************************************************************/
        public static void StudentDataFileSave(SqlConnection conn,
                                               string clientID,
                                               string fileTypeID,
                                               string companyID,
                                               string frequency, 
                                               string autoRequest,
                                               string requestedBy,
                                               string userID,                               
                                               string saveType,
                                               string recID
                                               )
        {
            string sql = "CLIENT_STUDENT_DATA_FILES_SAVE";
            string msg = null;
            try
            {
                object vClientID    = Validate.reqInteger(clientID,    msg, true);
                object vUserID      = Validate.reqInteger(userID,      msg, true);
                object vCompanyID   = Validate.reqInteger(companyID,   msg, true);
                object vFileTypeID  = Validate.reqInteger(fileTypeID,  msg, true);
                object vRequestedBy = Validate.optInteger(requestedBy,   msg, true);
                object vRecID       = Validate.optInteger(recID,       msg, true);
                string vFrequency   = Validate.reqString (frequency,1, msg);
                int vSaveType       = Validate.reqInteger(saveType,    msg);
                Object vAutoRequest = Validate.optFlag   (autoRequest, msg);


                List<SqlParameter> parms = new List<SqlParameter>();

                parms.Add(Database.SqlParm("@clientID",      SqlDbType.BigInt,  vClientID,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@fileTypeID",    SqlDbType.BigInt,  vFileTypeID,  ParameterDirection.Input));
                parms.Add(Database.SqlParm("@companyID",     SqlDbType.BigInt,  vCompanyID,   ParameterDirection.Input));
                parms.Add(Database.SqlParm("@frequency",     SqlDbType.Char,    vFrequency,   ParameterDirection.Input));
                parms.Add(Database.SqlParm("@autoReq",       SqlDbType.Bit,     vAutoRequest, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@requestedBy",   SqlDbType.BigInt,  vRequestedBy, ParameterDirection.Input));

                parms.Add(Database.SqlParm("@userID",        SqlDbType.BigInt,  vUserID,   ParameterDirection.Input));
                parms.Add(Database.SqlParm("@editDelReason", SqlDbType.VarChar, "",        ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@validateRec",   SqlDbType.Bit,     1,         ParameterDirection.Input));
                parms.Add(Database.SqlParm("@saveType",      SqlDbType.Int,     vSaveType, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@recID",         SqlDbType.BigInt,  vRecID,    ParameterDirection.Input));

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
        * Student_Data_File_VIEW */
        /**
         ***************************************************************************/
        public static DataTable StudentDataFileView(SqlConnection conn,
                                                    string clientID,
                                                    string fileTypeID,
                                                    string companyID,
                                                    string frequency,
                                                    string autoRequest,  
                                                    string requestedBy,                     
                                                    string canedit,
                                                    string active,
                                                    string recID
                                                    )
        {
            string sql;
            sql = "SELECT * FROM CLIENT_STUDENT_DATA_FILES_VIEW(@recID,@clientID,@fileTypeID,@companyID,@frequency,@autoReq,@requestedBy,@active,@canEdit)";
               
            string msg = null;

            Object vClientID    = Validate.optInteger(clientID,      msg, true);
            object vCompanyID   = Validate.optInteger(companyID,     msg, true);
            object vFileTypeID  = Validate.optInteger(fileTypeID,    msg, true);
            object vRecID       = Validate.optInteger(recID,         msg, true);
            object vRequestedBy = Validate.optInteger(requestedBy,   msg, true);
            string vFrequency   = Validate.reqString (frequency,  1, msg);
            Object vAutoRequest = Validate.optFlag   (autoRequest,   msg);
            Object vActive      = Validate.optFlag   (active,        msg);
            Object vCanEdit     = Validate.optFlag   (canedit,       msg);

            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID",   SqlDbType.BigInt, vClientID,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fileTypeID", SqlDbType.BigInt, vFileTypeID,  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@companyID",  SqlDbType.BigInt, vCompanyID,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@frequency",  SqlDbType.Char,   vFrequency,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@autoReq",    SqlDbType.Bit,    vAutoRequest, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@requestedBy",SqlDbType.BigInt, vRequestedBy, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@recID",      SqlDbType.BigInt, vRecID,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@active",     SqlDbType.Bit,    vActive,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@canEdit",    SqlDbType.Bit,    vCanEdit,     ParameterDirection.Input));

            DataTable dt = new DataTable();
            try
            {
                ReturnDB rd = Database.execQuery(conn, null, sql, false, parms);
                dt = Database.convertReturnDBToDatatable(ref rd);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            return dt;
        }

        /***************************************************************************
       * StudentDataFile_DELETE */
        /**
         * "Deletes" a INPUTBATCH record
         ***************************************************************************/
        public static void StudentDataFileDelete(SqlConnection conn, string editDelReason, string validateRec, string recID, string userID)
        {
            string sql = "CLIENT_STUDENT_DATA_FILES_Delete";
            string msg = null;
            ReturnSaveRecord so = new ReturnSaveRecord();

            try
            {
                bool vValidateRec = Validate.reqFlag(validateRec, msg);
                long vRecID       = Validate.reqInteger(recID, msg);
                List<SqlParameter> parms = new List<SqlParameter>();

                parms.Add(Database.SqlParm("@userID", SqlDbType.BigInt, userID, ParameterDirection.Input));

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
         * Student_Data_FileType_SAVE */
        /**
         ***************************************************************************/
        public static void StudentDataFileTypeSave(SqlConnection conn,                                            
                                                   string name,
                                                   string description,
                                                   string userID,
                                                   string saveType,
                                                   string recID                                                   
                                                   )
        {
            string sql = "STUDENT_DATA_FILE_TYPES_SAVE";
            string msg = null;
            try
            {
                string vName        = Validate.reqString (name,        msg);
                string vDescription = Validate.optString (description, msg);
                object vRecID       = Validate.optInteger(recID,       msg, true);
                int vSaveType       = Validate.reqInteger(saveType,    msg);
                object vUserID      = Validate.optInteger(userID,      msg, true);

                List<SqlParameter> parms = new List<SqlParameter>();
                
                parms.Add(Database.SqlParm("@fileTypeName",  SqlDbType.VarChar, vName,        ParameterDirection.Input));
                parms.Add(Database.SqlParm("@description",   SqlDbType.VarChar, vDescription, ParameterDirection.Input));

                parms.Add(Database.SqlParm("@userID",        SqlDbType.BigInt,  vUserID,      ParameterDirection.Input));
                parms.Add(Database.SqlParm("@editDelReason", SqlDbType.VarChar, "",           ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@validateRec",   SqlDbType.Bit,     1,            ParameterDirection.Input));
                parms.Add(Database.SqlParm("@saveType",      SqlDbType.Int,     vSaveType,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@recID",         SqlDbType.BigInt,  vRecID,       ParameterDirection.Input));

                parms.Add(Database.SqlParm("@MsgNotActive",  SqlDbType.VarChar, msg,          ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgDupRec",     SqlDbType.VarChar, msg,          ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoRec",      SqlDbType.VarChar, msg,          ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoEdit",     SqlDbType.VarChar, msg,          ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgDataError",  SqlDbType.VarChar, msg,          ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@recordID",      SqlDbType.BigInt,  null,         ParameterDirection.Output));


                ReturnDB rd = Database.execSproc(conn, null, sql, parms);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }


        /***************************************************************************
       * StudentDataFileTypes_DELETE */
        /**
         * "Deletes" a INPUTBATCH record
         ***************************************************************************/
        public static void StudentDataFileTypesDelete(SqlConnection conn, string editDelReason, string validateRec, string recID, string userID)
        {
            string sql = "STUDENT_DATA_FILE_TYPE_Delete";
            string msg = null;
            ReturnSaveRecord so = new ReturnSaveRecord();

            try
            {
                bool vValidateRec = Validate.reqFlag(validateRec, msg);
                long vRecID       = Validate.reqInteger(recID, msg);
                List<SqlParameter> parms = new List<SqlParameter>();

                parms.Add(Database.SqlParm("@userID", SqlDbType.BigInt, userID, ParameterDirection.Input));

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
        * Student_Data_File_Types_VIEW */
        /**
         ***************************************************************************/
        public static DataTable StudentDataFileTypesView(SqlConnection conn,                                                 
                                                         string canedit,
                                                         string active,
                                                         string recID
                                                         )
        {
            string sql;
            sql = "SELECT * FROM STUDENT_DATA_FILE_TYPES_VIEW(@recID,@active,@canEdit)";

            string msg = null;
            
            object vRecID   = Validate.optInteger(recID,   msg, true);
            Object vActive  = Validate.optFlag   (active,  msg);
            Object vCanEdit = Validate.optFlag   (canedit, msg);

            List<SqlParameter> parms = new List<SqlParameter>();
           
            parms.Add(Database.SqlParm("@recID",   SqlDbType.BigInt, vRecID,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@active",  SqlDbType.Bit,    vActive,  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@canEdit", SqlDbType.Bit,    vCanEdit, ParameterDirection.Input));

            DataTable dt = new DataTable();
            try
            {
                ReturnDB rd = Database.execQuery(conn, null, sql, false, parms);
                dt = Database.convertReturnDBToDatatable(ref rd);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            return dt;
        }



        /***************************************************************************
          * Student_Data_Contact_SAVE */
        /**
         ***************************************************************************/
        public static void StudentDataContactSave(SqlConnection conn,
                                                  string clientID,
                                                  string fileTypeID,
                                                  string lastname,
                                                  string firstname,
                                                  string email,
                                                  string secondaryEmail,
                                                  string notes,
                                                  string userID,
                                                  string saveType,
                                                  string recID
                                                  )
        {
            string sql = "CLIENT_STUDENT_DATA_CONTACT_SAVE";
            string msg = null;
            try
            {
                object vClientID       = Validate.reqInteger(clientID,   Messages.INVALID_CLIENT_ID, true);
                object vUserID         = Validate.reqInteger(userID,     msg, true);
                object vFileTypeID     = Validate.reqInteger(fileTypeID, "Invalid File type.", true);
                object vRecID          = Validate.optInteger(recID,      msg, true);
                string vFirstName      = Validate.reqString (firstname,  Messages.INVALID_FNAME);
                string vLastName       = Validate.reqString (lastname,   Messages.INVALID_LNAME);
                string vEmail          = Validate.reqEmail  (email,      Messages.INVALID_EMAIL);
                string vSecondaryEmail = Validate.optString (secondaryEmail, msg);
                Object vNotes          = Validate.optString (notes,      msg);

                int vSaveType          = Validate.reqInteger(saveType,   msg);


                List<SqlParameter> parms = new List<SqlParameter>();

                parms.Add(Database.SqlParm("@clientID",       SqlDbType.BigInt,  vClientID,      ParameterDirection.Input));
                parms.Add(Database.SqlParm("@fileTypeID",     SqlDbType.BigInt,  vFileTypeID,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@firstName",      SqlDbType.VarChar, firstname,      ParameterDirection.Input));
                parms.Add(Database.SqlParm("@lastName",       SqlDbType.VarChar, lastname,       ParameterDirection.Input));
                parms.Add(Database.SqlParm("@email",          SqlDbType.VarChar, email,          ParameterDirection.Input));
                parms.Add(Database.SqlParm("@notes",          SqlDbType.VarChar, vNotes,         ParameterDirection.Input));
                parms.Add(Database.SqlParm("@secondaryEmail", SqlDbType.VarChar, secondaryEmail, ParameterDirection.Input));


                parms.Add(Database.SqlParm("@userID",        SqlDbType.BigInt,  vUserID,   ParameterDirection.Input));
                parms.Add(Database.SqlParm("@editDelReason", SqlDbType.VarChar, "",        ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@validateRec",   SqlDbType.Bit,     1,         ParameterDirection.Input));
                parms.Add(Database.SqlParm("@saveType",      SqlDbType.Int,     vSaveType, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@recID",         SqlDbType.BigInt,  vRecID,    ParameterDirection.Input));

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
        * Student_Data_Contact_VIEW */
        /**
         ***************************************************************************/
        public static DataTable StudentDataContactView(SqlConnection conn,
                                                       string clientID,
                                                       string fileTypeID,                                                 
                                                       string canedit,
                                                       string active,
                                                       string recID
                                                       )
        {
            string sql;
            sql = "SELECT * FROM CLIENT_STUDENT_DATA_CONTACT_VIEW(@recID,@clientID,@fileTypeID,@canEdit)";

            string msg = null;

            Object vClientID   = Validate.optInteger(clientID,   msg, true);
            object vFileTypeID = Validate.optInteger(fileTypeID, msg, true);
            object vRecID      = Validate.optInteger(recID,      msg, true);           
            Object vCanEdit    = Validate.optFlag   (canedit,    msg);

            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID",   SqlDbType.BigInt, vClientID,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fileTypeID", SqlDbType.BigInt, vFileTypeID, ParameterDirection.Input));           
            parms.Add(Database.SqlParm("@recID",      SqlDbType.BigInt, vRecID,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@canEdit",    SqlDbType.Bit,    vCanEdit,    ParameterDirection.Input));

            DataTable dt = new DataTable();
            try
            {
                ReturnDB rd = Database.execQuery(conn, null, sql, false, parms);
                dt = Database.convertReturnDBToDatatable(ref rd);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            return dt;
        }


        /***************************************************************************
        * Student_Data_Contact_VIEW */
        /**
         ***************************************************************************/
        public static DataTable StudentDataFilestoRequest(SqlConnection conn, 
                                                          string date,
                                                          string q1,
                                                          string q2,
                                                          string q3,
                                                          string q4,
                                                          string frequency)
        {
            string sql;
            sql = "select * from STUDENT_DATA_FILES_TO_REQUEST(@date, @quarter1, @quarter2, @quarter3, @quarter4, @frequency)";

            string msg = null;
            
            Object vDate      = Validate.reqDate(date, msg);
            Object vQ1        = Validate.reqDate(q1, msg);
            Object vQ2        = Validate.reqDate(q2, msg);
            Object vQ3        = Validate.reqDate(q3, msg);
            Object vQ4        = Validate.reqDate(q4, msg);
            Object vFrequency = Validate.optString(frequency, msg);

            List<SqlParameter> parms = new List<SqlParameter>();
           
            parms.Add(Database.SqlParm("@date",      SqlDbType.DateTime, vDate,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@quarter1",  SqlDbType.DateTime, vQ1,        ParameterDirection.Input));
            parms.Add(Database.SqlParm("@quarter2",  SqlDbType.DateTime, vQ2,        ParameterDirection.Input));
            parms.Add(Database.SqlParm("@quarter3",  SqlDbType.DateTime, vQ3,        ParameterDirection.Input));
            parms.Add(Database.SqlParm("@quarter4",  SqlDbType.DateTime, vQ4,        ParameterDirection.Input));
            parms.Add(Database.SqlParm("@frequency", SqlDbType.VarChar,  vFrequency, ParameterDirection.Input));

            DataTable dt = new DataTable();
            try
            {
                ReturnDB rd = Database.execQuery(conn, null, sql, false, parms);
                dt = Database.convertReturnDBToDatatable(ref rd);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            return dt;
        }

        /***************************************************************************
        * Student_Data_Contact_SAVE */
        /**
         ***************************************************************************/
        public static void StudentDataTrackingRecSave(SqlConnection conn,
                                                      string clientID,
                                                      string fileTypeID,
                                                      string quarter,
                                                      string dateRequested,
                                                      string dateFollwedup,
                                                      string dateNotified,
                                                      string dateReceived,
                                                      string whoPrePTxtFile,
                                                      string dateinFolders,
                                                      string dateSentDHS,
                                                      string dateReceivedDHS,
                                                      string dateMovedClFolders,
                                                      string dhsFilename,
                                                      string whoMovTxtMedFile,
                                                      string popFileID,
                                                      string notes,
                                                      string userID,
                                                      string saveType,
                                                      string recID
                                                      )
        {
            string sql = "STUDENT_DATA_TRACKING_RECORD_Save";
            string msg = null;
            try
            {
                object vClientID         = Validate.reqInteger(clientID,           Messages.INVALID_CLIENT_ID, true);
                object vUserID           = Validate.reqInteger(userID,             msg, true);
                object vFileTypeID       = Validate.reqInteger(fileTypeID,        "Invalid File type.", true);
                object vQuarter          = Validate.reqInteger(quarter,            msg);
                object vRecID            = Validate.optInteger(recID,              msg, true);
                object vDateReq          = Validate.optDate   (dateRequested,      msg);
                object vDateFollow       = Validate.optDate   (dateFollwedup,     "Date follwedup is Invalid!");
                object vDateNotified     = Validate.optDate   (dateNotified,      "Date notified to rep is Invalid!");
                object vDateReceived     = Validate.optDate   (dateReceived,      "Date Received is Invalid!");
                string vWhoPrepTxt       = Validate.optString (whoPrePTxtFile,     msg);
                object vDateInFolder     = Validate.optDate   (dateinFolders,      "Date put in folders is invalid!");
                object vDateSentDHS      = Validate.optDate   (dateSentDHS,        "Date sent to DHS is invalid!");
                object vDateRecvdDHS     = Validate.optDate   (dateReceivedDHS,    "Date Received from DHS is invalid!");
                object vDateMovClFolders = Validate.optDate   (dateMovedClFolders, "Date moved to client folders id invalid!");
                string vDHSFileName      = Validate.optString (dhsFilename,        msg);
                string vWhoMovTxtMedFile = Validate.optString (whoMovTxtMedFile,   msg);
                object vPopFileID        = Validate.optInteger(popFileID,          msg, true);
                Object vNotes            = Validate.optString (notes,              msg);
                int vSaveType            = Validate.reqInteger(saveType,        msg);


                List<SqlParameter> parms = new List<SqlParameter>();

                parms.Add(Database.SqlParm("@clientID",         SqlDbType.BigInt,   vClientID,         ParameterDirection.Input));
                parms.Add(Database.SqlParm("@fileTypeID",       SqlDbType.BigInt,   vFileTypeID,       ParameterDirection.Input));
                parms.Add(Database.SqlParm("@quarter",          SqlDbType.Int,      vQuarter,          ParameterDirection.Input));
                parms.Add(Database.SqlParm("@dateRequested",    SqlDbType.DateTime, vDateReq,          ParameterDirection.Input));
                parms.Add(Database.SqlParm("@dateFollowedUp",   SqlDbType.DateTime, vDateFollow,       ParameterDirection.Input));
                parms.Add(Database.SqlParm("@dateNotified",     SqlDbType.DateTime, vDateNotified,     ParameterDirection.Input));
                parms.Add(Database.SqlParm("@dateReceived",     SqlDbType.DateTime, vDateReceived,     ParameterDirection.Input));
                parms.Add(Database.SqlParm("@whoPrepTxtFile",   SqlDbType.VarChar,  vWhoPrepTxt,       ParameterDirection.Input));
                parms.Add(Database.SqlParm("@dateinFolders",    SqlDbType.DateTime, vDateInFolder,     ParameterDirection.Input));
                parms.Add(Database.SqlParm("@dateSentDHS",      SqlDbType.DateTime, vDateSentDHS,      ParameterDirection.Input));
                parms.Add(Database.SqlParm("@dateReceivedDHS",  SqlDbType.DateTime, vDateRecvdDHS,     ParameterDirection.Input));
                parms.Add(Database.SqlParm("@dateMovClFolders", SqlDbType.DateTime, vDateMovClFolders, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@dhsFilename",      SqlDbType.VarChar,  vDHSFileName,      ParameterDirection.Input));
                parms.Add(Database.SqlParm("@whoMovTxtMedFile", SqlDbType.VarChar,  vWhoMovTxtMedFile, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@popFileID",        SqlDbType.BigInt,   vPopFileID,        ParameterDirection.Input));
                parms.Add(Database.SqlParm("@notes",            SqlDbType.VarChar,  vNotes,            ParameterDirection.Input));

                parms.Add(Database.SqlParm("@userID",           SqlDbType.BigInt,   vUserID,           ParameterDirection.Input));
                parms.Add(Database.SqlParm("@editDelReason",    SqlDbType.VarChar,  "",                ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@validateRec",      SqlDbType.Bit,      1,                 ParameterDirection.Input));
                parms.Add(Database.SqlParm("@saveType",         SqlDbType.Int,      vSaveType,         ParameterDirection.Input));
                parms.Add(Database.SqlParm("@recID",            SqlDbType.BigInt,   vRecID,            ParameterDirection.Input));

                parms.Add(Database.SqlParm("@MsgNotActive",     SqlDbType.VarChar,  msg,               ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgDupRec",        SqlDbType.VarChar,  msg,               ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoRec",         SqlDbType.VarChar,  msg,               ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoEdit",        SqlDbType.VarChar,  msg,               ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgDataError",     SqlDbType.VarChar,  msg,               ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@recordID",         SqlDbType.BigInt,   null,              ParameterDirection.Output));


                ReturnDB rd = Database.execSproc(conn, null, sql, parms);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        /***************************************************************************
        * Student_Data_Contact_SAVE */
        /**
         * filter the view where if received = 1 then Date_Received is not null
         *                                   = 2 then Date_Received is null
         *                                   = 0 then view all
         ***************************************************************************/
        public static DataTable StudentDataTrackingView(SqlConnection conn,
                                                        string clientID,
                                                        string fileTypeID,
                                                        string quarter,
                                                        string fiscalYear,
                                                        string canedit,                               
                                                        string recID,
                                                        string received,
                                                        string requestedBy,
                                                        string active
                                                        )
        {
            string sql;
            if (received == "1")
                sql = "SELECT * FROM STUDENT_DATA_TRACKING_VIEW(@recID,@clientID,@fileTypeID,@quarter,@fiscalYear,@requestedBy,@canEdit,@active) where DATE_RECEIVED is not null";
            else if(received == "2")
                sql = "SELECT * FROM STUDENT_DATA_TRACKING_VIEW(@recID,@clientID,@fileTypeID,@quarter,@fiscalYear,@requestedBy,@canEdit,@active) where DATE_RECEIVED is null";
            else sql = "SELECT * FROM STUDENT_DATA_TRACKING_VIEW(@recID,@clientID,@fileTypeID,@quarter,@fiscalYear,@requestedBy,@canEdit,@active) ";

            string msg = null;
           
            object vClientID   = Validate.optInteger(clientID,    msg, true);
            object vFileTypeID = Validate.optInteger(fileTypeID,  msg, true);
            object vQuarter    = Validate.optInteger(quarter,     msg);
            object vFiscalYear = Validate.optInteger(fiscalYear,  msg);
            object vRecID      = Validate.optInteger(recID,       msg, true);
            object vReqBy      = Validate.optInteger(requestedBy, msg, true);
            Object vCanEdit    = Validate.optFlag   (canedit,     msg);
            Object vActive     = Validate.optFlag   (active,      msg);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID",    SqlDbType.BigInt, vClientID,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fileTypeID",  SqlDbType.BigInt, vFileTypeID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@quarter",     SqlDbType.Int,    vQuarter,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fiscalYear",  SqlDbType.Int,    vFiscalYear, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@requestedBy", SqlDbType.BigInt, vReqBy,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@recID",       SqlDbType.BigInt, vRecID,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@canEdit",     SqlDbType.Bit,    vCanEdit,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@active",      SqlDbType.Bit,    vActive,     ParameterDirection.Input));

            DataTable dt = new DataTable();
            try
            {
                ReturnDB rd = Database.execQuery(conn, null, sql, false, parms);
                dt          = Database.convertReturnDBToDatatable(ref rd);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            return dt;
            
        }

        /***************************************************************************
         * STUDENT_DATA_TRACKING_RECORD_DELETE */
        /**
         * "Deletes" a STUDENT_DATA_TRACKING_RECORD
         ***************************************************************************/
        public static void StudentDataTrackingRecDelete(SqlConnection conn, string editDelReason, string validateRec, string recID, string userID)
        {
            string sql = "STUDENT_DATA_TRACKING_RECORD_Delete";
            string msg = null;
            ReturnSaveRecord so = new ReturnSaveRecord();

            try
            {
                bool vValidateRec = Validate.reqFlag(validateRec, msg);
                long vRecID       = Validate.reqInteger(recID, msg);
                List<SqlParameter> parms = new List<SqlParameter>();

                parms.Add(Database.SqlParm("@userID", SqlDbType.BigInt, userID, ParameterDirection.Input));

                parms.Add(Database.SqlParm("@editDelReason", SqlDbType.VarChar, editDelReason, ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@validateRec",   SqlDbType.Bit,     vValidateRec,  ParameterDirection.Input));
                parms.Add(Database.SqlParm("@recID",         SqlDbType.BigInt,  vRecID,        ParameterDirection.Input));
                parms.Add(Database.SqlParm("@MsgNoRec",      SqlDbType.VarChar, msg,           ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoEdit",     SqlDbType.VarChar, msg,           ParameterDirection.Input, 1000));

                parms.Add(Database.SqlParm("@recordID",      SqlDbType.BigInt, null,           ParameterDirection.Output));

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
