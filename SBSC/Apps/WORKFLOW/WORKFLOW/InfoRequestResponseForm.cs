using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Drawing.Imaging;
using System.Security.Permissions;
using System.IO;
using MBA;

namespace WORKFLOW
{
    public partial class InfoRequestResponseForm : System.Windows.Forms.Form
    {

        #region InfoRequestResponseForm_Variables

        private static InfoRequestResponseForm m_SChildform1;

        public string QformID;
        public string qformName;
        public int qformStatus;
        public string clientID;
        public string parentID;
        public string oldDOS;
        private string sql;
        public static string question = "";
        public static string questionType = "";
        public static string questionID = "";
        private string irrID = "";
        int irrStatus;
        private string repEmail = "";
        private string repUserID;
        private string repPhone;
        private string repName;
        private string repFirstName;
        private bool pracemailexists = false;

        private string emailTo;
        private string toUserID;
        bool formLoaded = false;
        private DialogResult r = new DialogResult();

        private List<SqlParameter> parms = new List<SqlParameter>();



        DataGridViewCellStyle dataGridViewCellStyle = new System.Windows.Forms.DataGridViewCellStyle();
        DataGridViewTextBoxColumn Question = new System.Windows.Forms.DataGridViewTextBoxColumn();
        DataGridViewTextBoxColumn Answer = new System.Windows.Forms.DataGridViewTextBoxColumn();
        DataGridViewTextBoxColumn id = new System.Windows.Forms.DataGridViewTextBoxColumn();
        DataGridViewTextBoxColumn Question_Type = new System.Windows.Forms.DataGridViewTextBoxColumn();


        DataGridViewTextBoxColumn Standard_QuestionID = new System.Windows.Forms.DataGridViewTextBoxColumn();


        private SelectQuestion selectQuestionsForm;
        private int rowSelected;

        private const string selectStampBtn = "Select";
        private const string openFileBtn = "btn_upload";

        private string UploadFileRoot = SBSCParent.QFormResponseFilePath;

        private string Qform_Directory_Path = "";



        #endregion

        #region InfoRequestResponseForm_Internal_Methods

        private void getIRR_IDForQformBatch(string batchID)
        {

            sql = "select id from INFO_REQUEST_RESPONSE where ReferenceID = @batchID and (Expiration_Date IS NULL OR Expiration_Date > getdate()) and Status != 99";
            parms.Clear();
            object vbatchID = MBA.Validate.optInteger(QformID, "", true);
            parms.Add(Database.SqlParm("@batchID", SqlDbType.BigInt, vbatchID, ParameterDirection.Input));
            irrID = WinFormsCommon.execScalar(SBSCParent.connUsers, sql, parms);

        }

        private void loadPractitionerCombobox()
        {
            //Load practitioners combobox                                      
            sql = "select id, name from dbo.PRACTITONERS_VIEW(null, null, null, 0, null, @clientID, null, null, null, null, null, null, 1, null,null) ";
            parms.Clear();
            object vClientID = MBA.Validate.optInteger(clientID, "", true);
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql, parms, praccomboBox, "Practitioners", "name", "id", true, "");
        }

        private void getRepInfo()
        {
            sql = "select u.firstName + ' ' + u.lastName as name,u.id,u.email,u.phone,u.firstName from (" +
      "(select coalesce(ClientRepIDLEACurrent,ClientRepIDMAACurrent) as repID,CLIENT_ID from CLIENTS_Client) cc " +
      "left join  CLIENTS_Client_Reps as cr on cr.id       = cc.repID " +
      "left join users.dbo.USERS_DATA_CORE(users.dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null) u on u.id = cr.user_id) " +
      "where cc.CLIENT_ID = @clientID";

            DataTable dt = new DataTable();

            ReturnDB rd = Database.execQuery(SBSCParent.connSpedmon, null, sql, false, parms);
            dt = Database.convertReturnDBToDatatable(ref rd);
            repEmail = dt.Rows[0]["email"].ToString();
            repUserID = dt.Rows[0]["id"].ToString();
            repName = dt.Rows[0]["name"].ToString();
            repFirstName = dt.Rows[0]["name"].ToString();
            repPhone = dt.Rows[0]["phone"].ToString();
        }


        /***************************************************************************
        * Creates IRR record
        ***************************************************************************/
        private void CreateIRRRecord(int savetype)
        {

            string emailTittle = Messages.QFORM_TITTLE;
            string emailMsg = " ";
            string emailTo = "";
            string emailCc = repEmail;
            string token = "";
            string toName = "";
            try
            {
                /***************************************************************************
                 * get the email ID to whom this qform is being sent, if a Practitioner is not
                 * selected or if the practitioner email doesn't exist in the database and
                 * if the user didn't enter the practitioner's email address then qform will
                 * be sent to rep. if the user had entered the practitioner's email then save it.
                 ***************************************************************************/
                if (praccomboBox.SelectedIndex != 0 && pracEmailtextBox.Text != "")
                {
                    if (!pracemailexists)
                    {
                        sql = "update PRACTITIONER_Practitioner set EMAIL = @email where PRACTITIONER_ID = @id";
                        parms.Clear();
                        object vEmailID = MBA.Validate.reqEmail(pracEmailtextBox.Text, "Invalid Practitioner Email address");
                        object vPracID = MBA.Validate.reqInteger(praccomboBox.SelectedValue.ToString(), "");
                        parms.Add(Database.SqlParm("@email", SqlDbType.VarChar, vEmailID, ParameterDirection.Input));
                        parms.Add(Database.SqlParm("@id", SqlDbType.BigInt, vPracID, ParameterDirection.Input));
                        WinFormsCommon.execScalar(SBSCParent.connSpedmon, sql, parms);
                    }
                    emailTo = pracEmailtextBox.Text;
                    emailMsg = Messages.QFORM_BODY + "District Representative: " + repName + ", Email: " + repEmail + ", Phone: " + repPhone;
                    //get the first name of the practitioner
                    toName = praccomboBox.Text.Remove(0, praccomboBox.Text.IndexOf(",") + 1);

                    sql = "select id from users.dbo.USERS_DATA_CORE(users.dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null) where email = @email";
                    parms.Clear();
                    object vEmail = MBA.Validate.reqString(emailTo, "");
                    parms.Add(Database.SqlParm("@email", SqlDbType.VarChar, vEmail, ParameterDirection.Input));
                    toUserID = WinFormsCommon.execScalar(SBSCParent.connUsers, sql, parms);
                }
                else
                {
                    emailTo = repEmail;
                    emailCc = "";
                    emailMsg = Messages.QFORM_BODY_REP;
                    toName = repFirstName;
                    toUserID = repUserID;
                }

                //create token if this is a new IRR Record
                if (savetype == 1) token = MBA.Credential.generateNewToken(emailTo);
                if (!string.IsNullOrEmpty(oldDOS))
                    irrID = InputBatches.InfoRequestResponseSave(SBSCParent.connUsers, SBSCParent.userID.ToString(), token, emailTittle, emailMsg, emailTo, emailCc,
                             clientID, toUserID, toName, WinFormsCommon.IsNull(praccomboBox.SelectedValue), SBSCParent.userID.ToString(),
                             parentID, QformID, oldDOS, Constants.QFORM_STATE_NEW, "", "", "", "", "", "", "", "0", savetype.ToString(), irrID);

            }
            catch (Exception ex)
            { MessageBox.Show(ex.Message); }
        }

        /***************************************************************************
        * Load Questions into datagridview
        ***************************************************************************/
        private void LoadQuestions(string QformId)
        {

            DataTable dt = new DataTable();



            dt = MBA.Qforms.InfoRequestResponseDetailView(SBSCParent.connUsers, QformID, irrID, "", "", "1", "");

            if (dt.Rows.Count != 0)
            {
                toUserID = dt.Rows[0]["To_UserID"].ToString();
                emailTo = dt.Rows[0]["Email_To"].ToString();
                if (dt.Rows[0]["To_PracID"].ToString() != "")
                    praccomboBox.SelectedValue = dt.Rows[0]["To_PracID"].ToString();

                dataGridView1.DataSource = dt;

                //get the irr status to load the form according
                irrStatus = Convert.ToInt16(dt.Rows[0]["Status"]);

                dataGridView1.Columns["Question"].DefaultCellStyle = dataGridViewCellStyle;
            }
            else
            {
                dt.Columns.Add("Question", typeof(String));
                dt.Columns.Add("Answer", typeof(String));
                dt.Columns.Add("Standard_QuestionID", typeof(String));
                dt.Columns.Add("Question_Type", typeof(String));
                dt.Columns.Add("id", typeof(String));

                dataGridView1.DataSource = dt;

            }



        }



        #endregion




        #region InfoRequestResponseForm_Form-Event_Methods


        public InfoRequestResponseForm()
        {
            InitializeComponent();
        }


        /***************************************************************************
         * if not created yet or disposed, Create an instance of the form
         * if just created or created earlier.Return it
         ***************************************************************************/
        public static InfoRequestResponseForm GetChildInstance()
        {
            if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
                m_SChildform1 = new InfoRequestResponseForm();
            return m_SChildform1;
        }


        private void InfoRequestResponseForm_Load(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(oldDOS))
            {
                MessageBox.Show("Please enter the oldest date of service for this batch before creating the Question form.");
                this.Close();
            }

            /* I'm pulling a lot of the code in here out into individual functions, just to make it more readable during the pre-refactor. -DW 20140505 */

            //if exists get the IIR ID for the Qform.
            getIRR_IDForQformBatch(QformID);

            //Load practitioners combobox
            loadPractitionerCombobox();

            //get the reps info
            getRepInfo();

            /* Load the questions on this qform */
            LoadQuestions(QformID);


            /* Check the status of the Qform to see if it's been sent yet - this determines visibility of specific information */


            /* Hide & lock down all columns initially */
            foreach (DataGridViewColumn c_i in dataGridView1.Columns)
            {
                c_i.Visible = false;
                c_i.ReadOnly = true;
                c_i.SortMode = DataGridViewColumnSortMode.NotSortable;
            }

            if (irrStatus < Convert.ToInt16(Constants.QFORM_STATE_SENT))
            {
                dataGridView1.Columns[0].Visible = true;
                foreach (DataGridViewColumn c_i in dataGridView1.Columns)
                {
                    if (c_i.Name == "Question")
                    {
                        c_i.Visible = true;

                        /* Edits are allowed to unsent Qform questions to provide greater flexibility for input staff */
                        c_i.ReadOnly = false;
                        c_i.CellTemplate = new DataGridViewTextBoxCell();
                    }
                    else
                        c_i.ReadOnly = true;
                }
                dataGridView1.Columns["Question"].Width = 800;
            }
            else
            {
              /***************************************************************************
               * if the qform is sent do not let any edits
               ***************************************************************************/

                foreach (DataGridViewColumn c_i in dataGridView1.Columns)
                {
                    if ((c_i.Name == "Question") || (c_i.Name == "Answer"))
                        c_i.Visible = true;
                }
                dataGridView1.Columns["Question"].Width = 475;
                dataGridView1.Columns["Answer"].Width = 475;
                dataGridView1.Columns["Answer"].DefaultCellStyle = dataGridViewCellStyle;
                dataGridView1.RowHeadersVisible = false;
                addnewbutton.Hide();
                savebutton.Hide();
                deleteRowbutton.Hide();
                praccomboBox.Enabled = false;




                string batString = QformID;
                string qfrString = irrID;
                Qform_Directory_Path = Path.Combine(Path.Combine(UploadFileRoot, batString), qfrString);


                /* Stick a button column on the dgv & apply styling */
                DataGridViewButtonColumn fileButton = new DataGridViewButtonColumn();
                    fileButton.Name = openFileBtn;
                    fileButton.HeaderText = "Uploaded files";
                    fileButton.Width = 65;
                    fileButton.FlatStyle = FlatStyle.Standard;
                    fileButton.Text = "Files Attached";
                    fileButton.FlatStyle = FlatStyle.Popup;
                    dataGridView1.Columns.Add(fileButton);

                foreach (DataGridViewRow aRow in dataGridView1.Rows)
                {
                    String InfoReqResponseID = aRow.Cells["id"].Value.ToString();
                    string AnswerFilePath = Path.Combine(Qform_Directory_Path, InfoReqResponseID);
                    DirectoryInfo AnswerDirectory = new DirectoryInfo(AnswerFilePath);

                    if ((AnswerDirectory.Exists == true) && (AnswerDirectory.GetFiles().Length != 0))
                    {
                        /* ^ This confirms that files exist in the filesystem directory for this detail-path */

                        /* TODO: Additional check in SQL to confirm that this detailID has file upload references */


                        object v_irrdId = MBA.Validate.reqInteger(InfoReqResponseID, "");
                        sql = "select COUNT(*) from users.dbo.INFO_REQUEST_RESPONSE_FILES where info_request_response_detail_ID = @detail_id";

                        parms.Clear();
                        parms.Add(Database.SqlParm("@detail_id", SqlDbType.VarChar, v_irrdId, ParameterDirection.Input));
                        ReturnDB rd = Database.execQuery(SBSCParent.connSpedmon, null, sql, false, parms);

                        if (rd.hasRecords == true)
                        {
                            aRow.Cells[openFileBtn].Style.BackColor = Color.LightGreen;
                            aRow.Cells[openFileBtn].Style.SelectionBackColor = Color.Green;
                            aRow.Cells[openFileBtn].Value = "Files Attached";
                        }
                    }

                    else
                    {
                        /* Hide button for rows that have no files uploaded */
                        aRow.Cells[openFileBtn] = new DataGridViewTextBoxCell();
                    }
                }
            }

            dataGridView1.Columns[0].DefaultCellStyle.WrapMode = DataGridViewTriState.True;
            qformlabel.Text = qformlabel.Text + qformName;
            formLoaded = true;

        }

        /***************************************************************************
        * Saves IRR record, creating one if there is no saved IRR record
        ***************************************************************************/
        private void savebutton_Click(object sender, EventArgs e)
        {
            r = DialogResult.Yes;

            //if the practitioner is not selected warn the user.
            if (praccomboBox.SelectedIndex == 0)
                r = MessageBox.Show("Are you sure to not select a Practitioner for this Qform?", "Practitioner not selected", MessageBoxButtons.YesNo);

            if (r == DialogResult.Yes && dataGridView1.RowCount != 0)
            {
                if (irrID == "")
                    CreateIRRRecord(1);
                else CreateIRRRecord(2);

                int i = 1;
                foreach (DataGridViewRow row in dataGridView1.Rows)
                {
                    string savetype = "1";
                    string recID = WinFormsCommon.IsNull(row.Cells["id"].Value);
                    if (recID != "") savetype = "2";

                    if (savetype == "1" && WinFormsCommon.IsNull(row.Cells["Question"].Value) == "") continue;

                    InputBatches.InfoRequestResponseDetailSave(SBSCParent.connUsers, SBSCParent.userID.ToString(), irrID, i.ToString(),
                                                               WinFormsCommon.IsNull(row.Cells["Standard_QuestionID"].Value),
                                                               WinFormsCommon.IsNull(row.Cells["Question"].Value),
                                                               WinFormsCommon.IsNull(row.Cells["Question_Type"].Value), "", "0", savetype, recID);
                }
                MessageBox.Show("Questions saved!");

            }
            this.Dispose();

        }

        /***************************************************************************
         * Addes new row to the datagrid
         ***************************************************************************/
        private void addnewbutton_Click(object sender, EventArgs e)
        {
            /* Because we're bound to a datasource, we modify that instead of the dgv */
            //DataGridViewRow newRow = new DataGridViewRow();
            //dataGridView1.Rows.Add(newRow);

            DataRow newRow = ((DataTable)dataGridView1.DataSource).NewRow();
            ((DataTable)dataGridView1.DataSource).Rows.Add(newRow);

        }

        private void cancelbutton_Click(object sender, EventArgs e)
        {
            this.Dispose();
        }

        /***************************************************************************
         * handle internal button events in dgv
         ***************************************************************************/
        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            /* Check to make sure dgv is instatiated before we try calling any events inside */
            if (((DataGridView)sender).CurrentCell != null)
            {
                /* Check type to see which cell content was activated */
                if (((DataGridView)sender).CurrentCell.GetType().Equals(typeof(DataGridViewButtonCell)))
                {
                    string columnName;

                    columnName = ((DataGridView)sender).Columns[e.ColumnIndex].Name;
                    /* Determine which column the button is part of */


                    switch(columnName)
                    {
                        case selectStampBtn:
                            {
                                /***************************************************************************
                                 * Show the list of questions when select button is clicked
                                 ***************************************************************************/

                                if (dataGridView1.RowCount > 0)
                                {
                                    rowSelected = e.RowIndex;
                                    selectQuestionsForm = SelectQuestion.GetChildInstance();
                                    selectQuestionsForm.ShowDialog();
                                }
                            }
                            break;

                        case openFileBtn:
                            {
                                DataTable dt = ((DataTable)((DataGridView)sender).DataSource);

                                string ansID = ((DataGridView)sender).Rows[e.RowIndex].Cells["id"].Value.ToString();

                                string AnswerFilePath = Path.Combine(Qform_Directory_Path, ansID);

                                InfoRequestResponseFilesForm fileListing = new InfoRequestResponseFilesForm(e.RowIndex+1, ansID, AnswerFilePath);
                                fileListing.Location = this.Location;
                                fileListing.StartPosition = FormStartPosition.Manual;
                                fileListing.ShowDialog();

                            }
                            break;

                        default:
                            break;

                    }

                }
            }
        }




        private void dataGridView1_EditingControlShowing(object sender, DataGridViewEditingControlShowingEventArgs e)
        {
        }

        void dataGridView1_CellEndEdit(object sender, DataGridViewCellEventArgs e)
        {
        }

        private void DataGridView1_CellValueChanged(object sender, DataGridViewCellEventArgs e)
        {
        }

        private void dataGridView1_CellBeginEdit(object sender,DataGridViewCellCancelEventArgs e)
        {
        }


        private void InfoRequestResponseForm_Activated(object sender, EventArgs e)
        {
            /***************************************************************************
             * Update the datagridview cell with the selected question from SelectQuestion form
             * - do this via the datasource, not by updating the DGV
             ***************************************************************************/
            try
            {
                if (question != "")
                {
                    DataTable dt = ((DataTable)dataGridView1.DataSource);
                    DataRow curr_Row = dt.Rows[rowSelected];
                    curr_Row["Question"] = question;
                    curr_Row["Standard_QuestionID"] = questionID;
                    curr_Row["Question_Type"] = questionType;
                }

                question     = "";
                questionID   = "";
                questionType = "";

            }
            catch (Exception ex)
            { MessageBox.Show(ex.Message); }
        }

        private void deleteRowbutton_Click(object sender, EventArgs e)
        {
         /***************************************************************************
          * deletes a row or Question in datagridview
          ***************************************************************************/
            if (dataGridView1.SelectedRows.Count == 1)
            {
               DataGridViewRow dgvRow = dataGridView1.SelectedRows[0];
               r = DialogResult.Yes;
               r = MessageBox.Show("Are you sure to delete this question?", "Delete Question", MessageBoxButtons.YesNo);

               if (r == DialogResult.Yes)
               {
                   //if the question is already saved delete it from the database
                   if(WinFormsCommon.IsNull(dgvRow.Cells["ID"].Value) != "")
                       InputBatches.InfoRequestResponseDetaildelete(SBSCParent.connUsers, "", "0", dgvRow.Cells["id"].Value.ToString(), SBSCParent.userID.ToString());

                   dataGridView1.Rows.RemoveAt(dataGridView1.SelectedRows[0].Index);
               }
            }
            else MessageBox.Show("Please select one row to Delete.");
        }

        private void praccomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            pracEmailtextBox.Text = "";
           /***************************************************************************
            * get the email ID of the practitioner if exists, if not prompt the user.
            ***************************************************************************/
            if (praccomboBox.SelectedIndex != 0)
            {
                pracemailexists = false;

                sql = "select pp.EMAIL as pracEmail,u.email as userEmail from PRACTITONERS_VIEW(null,null,null,null,null,@clientID,null,null,null,null,null,null,1,null,null) pp " +
                      "left join users.dbo.USERS_DATA_CORE(users.dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null) u on u.id = pp.userIDInt " +
                      "where pp.id = @pracID";
                parms.Clear();
                object vClientID = MBA.Validate.optInteger(clientID, "", true);
                object vPracID   = MBA.Validate.reqInteger(praccomboBox.SelectedValue.ToString(), "");
                parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@pracID", SqlDbType.VarChar, vPracID, ParameterDirection.Input));

                DataTable dt = new DataTable();
                ReturnDB rd = Database.execQuery(SBSCParent.connSpedmon, null, sql, false, parms);
                dt = Database.convertReturnDBToDatatable(ref rd);

                if (!string.IsNullOrEmpty(dt.Rows[0]["pracEmail"].ToString()))
                {
                    pracEmailtextBox.Text = dt.Rows[0]["pracEmail"].ToString();
                    pracemailexists = true;
                }

                else if (!string.IsNullOrEmpty(dt.Rows[0]["userEmail"].ToString()))
                    pracEmailtextBox.Text = dt.Rows[0]["pracEmail"].ToString();
                else if(!dataGridView1.ReadOnly && formLoaded)
                {
                    MessageBox.Show("The email address for this practitioner does not exist in the database. If you know the practitioners email address please enter it in Practitioner's Email text box", "Practitioner's Email", MessageBoxButtons.OK);
                    pracEmailtextBox.Focus();
                }


            }
        }

        private void pracEmailtextBox_Leave(object sender, EventArgs e)
        {
            if (formLoaded)
            {
                try
                {
                    MBA.Validate.optEmail(pracEmailtextBox.Text, "Invalid Email address");
                }
                catch(Exception ex)
                {
                    MessageBox.Show(ex.Message);
                    pracEmailtextBox.Focus();
                }
            }
        }


        #endregion


    }
}
