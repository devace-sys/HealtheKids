using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Data.SqlClient;
using MBA;


namespace WORKFLOW
{
    public partial class InfoRequestResponseFilesForm : System.Windows.Forms.Form
    {

        private string InfoReqResponseID;
        private string QuestionNumber;
        private string AnswerFolderPath;

        private void initFormFrmDB()
        {
            /* Hook into SQL and use irrid to get batch name and question upload data */

            string sql = "";
            List<SqlParameter> parms = new List<SqlParameter>();

            sql = "select ib.File_Name from Spedmon.dbo.INPUT_BATCHES ib inner join Users.dbo.INFO_REQUEST_RESPONSE irr on ib.id = irr.ReferenceID inner join Users.dbo.INFO_REQUEST_RESPONSE_DETAILS irrd on irrd.InfoRequestResponseID = irr.id and irrd.id = @detail_id";
            parms.Clear();
            object v_irrdId = MBA.Validate.reqInteger(InfoReqResponseID, "");
            parms.Add(Database.SqlParm("@detail_id", SqlDbType.VarChar, v_irrdId, ParameterDirection.Input));
            string BatchName = WinFormsCommon.execScalar(SBSCParent.connUsers, sql, parms);
            this.Text = "Response Files for " + BatchName + ", question " + QuestionNumber;



            sql = "select file_key,filename from users.dbo.INFO_REQUEST_RESPONSE_FILES where info_request_response_detail_ID = @detail_id";


            DataTable dt = new DataTable();
            parms.Clear();
            parms.Add(Database.SqlParm("@detail_id", SqlDbType.VarChar, v_irrdId, ParameterDirection.Input));
            ReturnDB rd = Database.execQuery(SBSCParent.connSpedmon, null, sql, false, parms);
            dt = Database.convertReturnDBToDatatable(ref rd);

            dataGridView1.DataSource = dt;

            dataGridView1.ReadOnly = true;
            dataGridView1.AllowUserToAddRows = false;

            foreach (DataGridViewColumn col in dataGridView1.Columns)
            {
                col.Visible = false;
            }

            if (dataGridView1.ColumnCount == 0)
            {
                MessageBox.Show("There appear to be files uploaded onto the server, but the database has no record of files uploaded for this specific answer (ID #" + InfoReqResponseID + "). Contact technical support for assistance in resolving this issue.", "Error", MessageBoxButtons.OK);
            }

            else if (dataGridView1.ColumnCount == 2)
            {
                dataGridView1.Columns["filename"].Visible = true;
                dataGridView1.Columns["filename"].HeaderText = "Double-click to Open File";
                dataGridView1.Columns["filename"].MinimumWidth = 255;
            } 

        }


        public InfoRequestResponseFilesForm(int num_question, string irr_id, string folderpath)
        {
            InitializeComponent();

            InfoReqResponseID = irr_id;
            QuestionNumber = num_question.ToString();
            AnswerFolderPath = folderpath;
            initFormFrmDB();

        }

        private void dataGridView1_CellMouseDoubleClick(object sender, DataGridViewCellMouseEventArgs e)
        {
            string Fullfilepath = Path.Combine(AnswerFolderPath, ((DataGridView)sender).CurrentRow.Cells["file_key"].Value.ToString());

            FileInfo openFile = new FileInfo(Fullfilepath);

          

            if (openFile.Exists)
                System.Diagnostics.Process.Start(openFile.FullName);
        }
    }
}
