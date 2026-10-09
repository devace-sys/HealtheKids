using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;

namespace MBA
{
    public class QformDetail 
    {
        public int      detailNum;
        public string   Question;
        public string   Answer;
        public string   Token;
        public long     id;
        public bool     isExpired;
        public DateTime RespondedOn;
        public DateTime OpenedOn;
        public long     InfoRequestResponseID;
        public int      Status;
        public long     ReferenceID;
        public string   OldestDOSOnQform;
        public string   RepName;
        public string   RepEmail;
        public string   RepPhone;
    }


    /***************************************************************************
     * QformDetails */
    /**
     * List of Qform details 
     **************************************************************************/

    public class QformDetails
    {
        public List<QformDetail> details;
    }


    public class Qforms : Entities
    {
        public static QformDetails load(SqlConnection conn, SqlConnection connApp, string token)
        {
           DataTable dt = InfoRequestResponseDetailView(conn, "", "", "",token, "1", "");
           List<QformDetail> qformDetails = new List<QformDetail>();
           foreach (DataRow r in dt.Rows)
           {
               //do not load the Qform details if the status is QFORM_STATE_ANSWERED
               QformDetail detail = new QformDetail();

               if (r["Status"].ToString() == Constants.QFORM_STATE_ANSWERED)
                   break;

               detail.detailNum = Convert.ToInt16(r["detailNum"]);
               detail.Status    = Convert.ToInt16(r["Status"]);
               detail.Question  = r["Question"].ToString();
               detail.Answer    = r["Answer"].ToString();
               detail.id        = (long)r["ID"];
               detail.Token     = r["Token"].ToString();
               detail.InfoRequestResponseID = (long) r["InfoRequestResponseID"];
               detail.ReferenceID           = (long) r["ReferenceID"];
               List<SqlParameter> parms = new List<SqlParameter>();

               object vOldDOS   = MBA.Validate.reqDate(r["OldestDOSOnQform"].ToString(), "Invalid date");
               parms.Add(Database.SqlParm("@oldDOS", SqlDbType.DateTime, vOldDOS, ParameterDirection.Input));

               detail.OldestDOSOnQform = WinFormsCommon.execScalar(connApp, "select FY_DEFINITION from dbo.COMPANY_FISCAL_YEARS where @oldDOS between FY_START and FY_END", parms);

               detail.RepName   = r["RepName"].ToString();
               detail.RepEmail  = r["RepEmail"].ToString();
               detail.RepPhone  = r["RepPhone"].ToString();
               if(r["OpenedOn"].ToString() != "")
                 detail.OpenedOn = Convert.ToDateTime(r["OpenedOn"]);
               if (r["RespondedOn"].ToString() != "")
                 detail.RespondedOn = Convert.ToDateTime(r["RespondedOn"]);
               qformDetails.Add(detail);
                  
           }
           QformDetails details = new QformDetails();
           details.details = qformDetails;
           return details;

        }

        /***************************************************************************
       * InfoRequestResponseDetail_VIEW */
        /**
         ***************************************************************************/
        public static DataTable InfoRequestResponseDetailView(SqlConnection conn,
                                                 string batchID,
                                                 string irrID,
                                                 string status,
                                                 string token,
                                                 string active,
                                                 string recID
                                                 )
        {
            string sql = "SELECT * FROM INFO_REQUEST_RESPONSE_DETAILS_VIEW(@batchID,@irrID,@status,@token,@recID,@active)";

            string msg = null;

            Object vbatchID = Validate.optInteger(batchID, msg, true);
            object vIrrID   = Validate.optInteger(irrID,   msg, true);
            object vStatus  = Validate.optInteger(status,  "");
            object vRecID   = Validate.optInteger(recID,   msg, true);
            object vToken   = Validate.optString (token,   msg);
            Object vActive  = Validate.optFlag   (active,  msg);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@batchID", SqlDbType.BigInt,  vbatchID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@irrID",   SqlDbType.BigInt,  vIrrID,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@status",  SqlDbType.Int,     vStatus,  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@token",   SqlDbType.VarChar, vToken,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@recID",   SqlDbType.BigInt,  vRecID,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@active",  SqlDbType.Bit,     vActive,  ParameterDirection.Input));

            DataTable dt = new DataTable();
           
            ReturnDB rd = Database.execQuery(conn, null, sql, false, parms);
            dt = Database.convertReturnDBToDatatable(ref rd);
           
            return dt;
        }

        /***************************************************************************
         * InfoRequestResponseDetail_SaveAnswers */
        /**
         ***************************************************************************/
        public static void InfoRequestResponseDetailSaveAnswers(SqlConnection conn,
                                                                string detailID,                                                         
                                                                string answer)
        {
            string sql = "update INFO_REQUEST_RESPONSE_DETAILS set Answer = @answer where id = @detailID";

            List<SqlParameter> parms = new List<SqlParameter>();
            object vAnswer   = MBA.Validate.optString(answer, "");
            object vdetailID = MBA.Validate.reqInteger(detailID, "", true);


            parms.Add(Database.SqlParm("@detailID", SqlDbType.BigInt,  vdetailID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@answer",   SqlDbType.VarChar, vAnswer,   ParameterDirection.Input));

            SqlCommand comm = new SqlCommand(sql, conn);

            if (parms != null)
                foreach (SqlParameter parm in parms)
                    comm.Parameters.Add(parm);

            comm.ExecuteScalar();
        }

        /***************************************************************************
         * InfoRequestResponse_Update */
        /**
         * update the InfoRequestResponse table if the qform is opened for the first time 
         * or if the qform is answered either partially or fully for the first time 
         * and change the status accordingly.
         ***************************************************************************/
        public static void InfoRequestResponseUpdate(SqlConnection connUsers,
                                                     SqlConnection connSpedmon,
                                                     string irrID,
                                                     string openedOn,
                                                     string respondedOn,
                                                     string status,
                                                     string qformBatchID,
                                                     string userIP
                                                     )
        {
            string sql = "";
            List<SqlParameter> parms = new List<SqlParameter>();
            object vIrrID        = MBA.Validate.reqInteger(irrID,        "Invalid ID");
            object vOpenedOn     = MBA.Validate.optDate   (openedOn,     "Invalid date");
            object vRespondedOn  = MBA.Validate.optDate   (respondedOn,  "Invalid date");
            object vStatus       = Validate.reqInteger    (status,       "Invalid status");
            object vQformBatchID = Validate.reqInteger    (qformBatchID, "Invalid batchID");
            object vUserIP       = Validate.reqString(userIP, "Invalid IP address");
            sql = "update INFO_REQUEST_RESPONSE set OpenedOn = @openedOn, RespondedOn = @respondedOn, Status = @status where id = @irrID";
            

            parms.Add(Database.SqlParm("@irrID",       SqlDbType.BigInt,   vIrrID,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@openedOn",    SqlDbType.DateTime, vOpenedOn,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@respondedOn", SqlDbType.DateTime, vRespondedOn, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@status",      SqlDbType.Int,      vStatus,      ParameterDirection.Input));
           
            WinFormsCommon.execScalar(connUsers, sql, parms);

            if (vStatus.ToString() == Constants.QFORM_STATE_ANSWERED)
            {
                parms.Clear();
                parms.Add(Database.SqlParm("@qformBatchID", SqlDbType.BigInt, vQformBatchID, ParameterDirection.Input));

                //todo: replace the hardcoded file status value for ReadytoBatch with a constant in Workflow project's, FileStatus.cs
                sql = "update INPUT_BATCHES set Current_status_Code =  "+ "10" +", Date_Recieved = GETDATE(), Date_Sent = GETDATE() where id = @qformBatchID";
                WinFormsCommon.execScalar(connSpedmon, sql, parms);
            }
         
        }

         /***************************************************************************
         * InfoRequestResponseAuditLog */
        /**
         * creates a new row in InfoRequestResponse audit log table with users ip address   
         * when ever the link is opened
         ***************************************************************************/
        public static void InfoRequestResponseAuditLog(SqlConnection connUsers,
                                                     string irrID,
                                                     string status,
                                                     string userIP
                                                     )
        {
            string sql = "";
            List<SqlParameter> parms = new List<SqlParameter>();
            object vIrrID  = MBA.Validate.reqInteger(irrID, "Invalid ID");
            object vStatus = Validate.reqInteger(status, "Invalid status");
            object vUserIP = Validate.reqString(userIP, "Invalid IP address");

            parms.Add(Database.SqlParm("@irrID", SqlDbType.BigInt, vIrrID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@status", SqlDbType.Int, vStatus, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userIP", SqlDbType.VarChar, vUserIP, ParameterDirection.Input));
            sql = "Insert into dbo.INFO_REQUEST_RESPONSE_AUDIT_LOG values (@irrID,getdate(),null,2,@status,'Link Opened',@userIP)";
            WinFormsCommon.execScalar(connUsers, sql, parms);
        }

        public static void InfoRequestResponseAddFile(SqlConnection connUsers,
                                             string irrDetailID,
                                             string uniqueFName,
                                             string fNameUploaded
                                             )
        {
                string sql = "";
                List<SqlParameter> parms = new List<SqlParameter>();
                object vIrrDetID = MBA.Validate.reqString(irrDetailID, "Invalid detail ID");
                object vUFName = Validate.reqString(uniqueFName, "Invalid status");
                object vFNmUpl = Validate.reqString(fNameUploaded, "Invalid IP address");

                parms.Add(Database.SqlParm("@irrDetID", SqlDbType.BigInt, vIrrDetID, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@vUFName", SqlDbType.VarChar, vUFName, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@vFNmUpl", SqlDbType.VarChar, vFNmUpl, ParameterDirection.Input));
                sql = "Insert into INFO_REQUEST_RESPONSE_FILES (info_request_response_detail_ID, file_key, filename) values (@irrDetID,@vUFName,@vFNmUpl)";
                WinFormsCommon.execScalar(connUsers, sql, parms);
        }

    }

}
