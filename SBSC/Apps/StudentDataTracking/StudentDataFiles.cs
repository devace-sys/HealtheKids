using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MBA;

namespace StudentDataTracking
{
    public partial class StudentDataFiles : System.Windows.Forms.Form
    {
        public StudentDataFiles()
        {
            InitializeComponent();
        }

        private static StudentDataFiles m_SChildform1;

        /***************************************************************************
         * if not created yet or disposed, Create an instance of the form
         * if just created or created earlier.Return it
         ***************************************************************************/
        public static StudentDataFiles GetChildInstance()
        {
            if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
                m_SChildform1 = new StudentDataFiles();
            return m_SChildform1;
        }

        private string sql;
        private string clientID;
        private string fileTypeID;
        private string companyID;
        private string frequency;
        private string requestedBy;
        private string requestedUser;
        private int saveType = 1;
        private string recID;
        private static DataGridViewRow dgvRow;
        private DialogResult r = new DialogResult();
        private string notes;
        private string autoReq;

        private void StudentDataFileTypes_Load(object sender, EventArgs e)
        {
            // loading the comboBoxes
            sql = "select id,name from CLIENTS_VIEW(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null) where id != 112 order by name";
            WinFormsCommon.PopulateComboBox(StudentDataTracking.connSpedmon, sql, null, clientcomboBox, "Clients", "name", "id", true, "");

            sql = "select id,name from COMPANIES_VIEW(null,null,null,null) order by name";
            WinFormsCommon.PopulateComboBox(StudentDataTracking.connSpedmon, sql, null, companycomboBox, "Companies", "name", "id", true, "");

            sql = "select id,type_name as name from STUDENT_DATA_FILE_TYPES_View(null,1,null) order by name";
            WinFormsCommon.PopulateComboBox(StudentDataTracking.connSpedmon, sql, null, fileTypecomboBox, "FileTypes", "name", "id", true, "");

            sql = "select id,firstname+' '+lastname as name from USERS_VIEW_CORE(dbo.CONST_APP_NAME_SPEDCARE()) " +
                 "where userGroup = dbo.CONST_USER_GROUP_SBS() order by firstname";

            WinFormsCommon.PopulateComboBox(StudentDataTracking.connUsers, sql, null, userscomboBox, "users", "name", "id", true, "All");

            viewbutton_Click(sender, e);
        }

      /***************************************************************************
       * Loads or Refreshes the datagrid and restores the sort order and selected rows.
       ***************************************************************************/    
        private void viewbutton_Click(object sender, EventArgs e)
        {
            

            if (monthlyradioButton.Checked) frequency = "m";
            else frequency = "q";

            WinFormsCommon.loadDataGrid(ref dataGridView1, 10, 13,
                                        delegate{return StudentData.StudentDataFileView(StudentDataTracking.connSpedmon,
                                                 WinFormsCommon.IsNull(clientcomboBox.SelectedValue),
                                                 WinFormsCommon.IsNull(fileTypecomboBox.SelectedValue),
                                                 WinFormsCommon.IsNull(companycomboBox.SelectedValue),
                                                 frequency, "", WinFormsCommon.IsNull(userscomboBox.SelectedValue), "", "1", "");
            });
            
        }

       /***************************************************************************
        * gets the column values of selected row
        ***************************************************************************/
        private void GetRecordAttributes()
        {
            clientID    = WinFormsCommon.IsNull(clientcomboBox.SelectedValue);
            fileTypeID  = WinFormsCommon.IsNull(fileTypecomboBox.SelectedValue);
            companyID   = WinFormsCommon.IsNull(companycomboBox.SelectedValue);
            requestedBy = WinFormsCommon.IsNull(userscomboBox.SelectedValue);
            if (monthlyradioButton.Checked) frequency = "m";
            else frequency = "q";

            if (autoReqcheckBox.Checked) autoReq = "1";
            else autoReq = "0";
        }

        private void savebutton_Click(object sender, EventArgs e)
        {
            // saves the record
            GetRecordAttributes();
            if (clientID != "" && fileTypeID != "" && companyID != "" && requestedBy != "")
            {
                if (saveType == 1) recID = "";
                StudentData.StudentDataFileSave(StudentDataTracking.connSpedmon, clientID, fileTypeID, companyID, frequency, autoReq,
                                                WinFormsCommon.IsNull(userscomboBox.SelectedValue), requestedBy, saveType.ToString(), recID);
                saveType = 1;
                cancelbutton_Click(sender, e);
                viewbutton_Click(sender, e);
            }
            else MessageBox.Show("Please select all the required fields to save.","Message");
        }

        private void cancelbutton_Click(object sender, EventArgs e)
        {
            //cancels current operation
            clientcomboBox.SelectedIndex   = 0;
            fileTypecomboBox.SelectedIndex = 0;
            companycomboBox.SelectedIndex  = 0;
            userscomboBox.SelectedIndex    = 0;
            saveType = 1;
        }

       /***************************************************************************
       * Gets the selected record properties in the datagrid.
       ***************************************************************************/
        private void GetDGVRowValues(int row)
        {
            if (dataGridView1.SelectedRows.Count >= 1)
            {
                dgvRow        = dataGridView1.SelectedRows[row];
                clientID      = dgvRow.Cells["Client_ID"].Value.ToString();                 
                recID         = dgvRow.Cells["id"].Value.ToString();
                fileTypeID    = dgvRow.Cells["FILE_TYPE_ID"].Value.ToString();
                companyID     = dgvRow.Cells["COMPANY_ID"].Value.ToString();
                frequency     = dgvRow.Cells["FREQUENCY"].Value.ToString();
                requestedBy   = dgvRow.Cells["REQUESTED_USERID"].Value.ToString();
                requestedUser = dgvRow.Cells["REQUESTED_USER"].Value.ToString();
                if (dgvRow.Cells["AUTO_REQUEST"].Value.ToString().ToLower() == "true")
                    autoReq = "1";
                else autoReq = "0";
            }
        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            /***************************************************************************
             * if Edit button is clicked loads the selected record values for editting 
             * if Delete button is clicked, confirms and deactivates the record.
             ***************************************************************************/
            if (dataGridView1.SelectedRows.Count != 0)
            {
                GetDGVRowValues(0);
                if (e.ColumnIndex == 0)
                {
                    clientcomboBox.SelectedValue   = clientID;
                    fileTypecomboBox.SelectedValue = fileTypeID;
                    companycomboBox.SelectedValue  = companyID;
                    if (requestedBy != "") 
                        userscomboBox.SelectedValue = requestedBy;
                    else userscomboBox.Text = requestedUser;
                    
                    if (autoReq == "1")
                        autoReqcheckBox.Checked = true;
                    else autoReqcheckBox.Checked = false;

                    if (frequency == "m") monthlyradioButton.Checked = true;
                    else quarterlyradioButton.Checked = true;
                    
                    saveType = 2;                   
                }

                if (e.ColumnIndex == 1)
                {
                    r = MessageBox.Show("Are you sure you want to delete this student data file request?", "Delete Flag", MessageBoxButtons.OKCancel);
                    if (r == DialogResult.OK)
                    {
                        notes = Microsoft.VisualBasic.Interaction.InputBox("Enter reason for delete", "File Delete", "", 183, 308);

                        StudentData.StudentDataFileDelete(StudentDataTracking.connSpedmon, notes, "1", recID, StudentDataTracking.userID.ToString());

                        viewbutton_Click(sender, e);
                        saveType = 1;
                        cancelbutton_Click(sender, e);
                    }
                }
            } 
        }

        private void closebutton_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void autoReqcheckBox_CheckedChanged(object sender, EventArgs e)
        {
            if (autoReqcheckBox.Checked) autoReq = "1";
            else autoReq = "0";
        }       
       
    }
}
