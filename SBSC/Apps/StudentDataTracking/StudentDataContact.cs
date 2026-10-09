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
    public partial class StudentDataContact : System.Windows.Forms.Form
    {
        public StudentDataContact()
        {
            InitializeComponent();
        }
        private static StudentDataContact m_SChildform1;

        /***************************************************************************
         * if not created yet or disposed, Create an instance of the form
         * if just created or created earlier.Return it
         ***************************************************************************/
        public static StudentDataContact GetChildInstance()
        {
            if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
                m_SChildform1 = new StudentDataContact();
            return m_SChildform1;
        }

        private string sql;
        private string saveType = "1";
        private string clientID;
        private string fileTypeID;
        private string firstName;
        private string lastName;
        private string email;
        private string secondaryEmail;
        private string notes;
        private string recID;
        private static DataGridViewRow dgvRow;

        private void StudentDataContact_Load(object sender, EventArgs e)
        {
            // loading the comboBoxes
            sql = "select id,name from CLIENTS_VIEW(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null) where id != 112 order by name";
            WinFormsCommon.PopulateComboBox(StudentDataTracking.connSpedmon, sql, null, clientcomboBox, "Clients", "name", "id", true, "");

            sql = "select id,type_name as name from STUDENT_DATA_FILE_TYPES_View(null,1,null) order by name";
            WinFormsCommon.PopulateComboBox(StudentDataTracking.connSpedmon, sql, null, fileTypecomboBox, "FileTypes", "name", "id", true, "");
            viewbutton_Click(sender, e);
        }

        private void viewbutton_Click(object sender, EventArgs e)
        {
        
            WinFormsCommon.loadDataGrid(ref dataGridView1, 7, 11,
                                        delegate{return StudentData.StudentDataContactView(StudentDataTracking.connSpedmon,
                                                 WinFormsCommon.IsNull(clientcomboBox.SelectedValue),
                                                 WinFormsCommon.IsNull(fileTypecomboBox.SelectedValue),
                                                  "", "1", "");
                                        });            
        }

        private void cancelbutton_Click(object sender, EventArgs e)
        {
            //cancels current operation and clears the controls
            clientcomboBox.SelectedIndex   = 0;
            fileTypecomboBox.SelectedIndex = 0;
            firstNametextBox.Text          = "";
            lastNametextBox.Text           = "";
            emailtextBox.Text              = "";
            saveType                       = "1";
            notestextBox.Text              = "";
            secondayEmailtextBox.Text      = "";
            recID                          = ""; 
        }

        private void savebutton_Click(object sender, EventArgs e)
        {
            //saves the record
            GetValues();
            char[] delimeters = new char[2]{',',';'} ;
            try
            {
                string[] secondaryContacts;
                // validate secondary contact emails if entered.
                if(secondayEmailtextBox.Text != "")
                   secondaryContacts = MBA.Validate.reqEmails(secondayEmailtextBox.Text, delimeters, "Invalid secondary contact email.");

                StudentData.StudentDataContactSave(StudentDataTracking.connSpedmon, clientID, fileTypeID, lastName, firstName, email, secondaryEmail, notes,
                                                       StudentDataTracking.userID.ToString(), saveType, recID);

                cancelbutton_Click(sender, e);
                viewbutton_Click(sender, e);
                saveType = "1";
            }
            catch (Exception ex) { MessageBox.Show(ex.Message); }
        }

       /***************************************************************************
       * gets the values from the controls for Edit or save
       ***************************************************************************/
        private void GetValues()
        {
            clientID       = WinFormsCommon.IsNull(clientcomboBox.SelectedValue);
            fileTypeID     = WinFormsCommon.IsNull(fileTypecomboBox.SelectedValue);
            firstName      = firstNametextBox.Text;
            lastName       = lastNametextBox.Text;
            email          = emailtextBox.Text;
            notes          = notestextBox.Text;
            secondaryEmail = secondayEmailtextBox.Text;
        }

       /***************************************************************************
        * Gets the selected Input Batch record properties in the datagrid.
        ***************************************************************************/
        private void GetRecordAttributes(int row)
        {
            if (dataGridView1.SelectedRows.Count >= 1)
            {
                dgvRow         = dataGridView1.SelectedRows[row];
                clientID       = dgvRow.Cells["Client_ID"].Value.ToString();

                recID          = dgvRow.Cells["id"].Value.ToString();
                fileTypeID     = dgvRow.Cells["FILE_TYPE_ID"].Value.ToString();
                firstName      = dgvRow.Cells["CONTACT_FIRST_NAME"].Value.ToString();
                lastName       = dgvRow.Cells["CONTACT_LAST_NAME"].Value.ToString();
                email          = dgvRow.Cells["CONTACT_EMAIL"].Value.ToString();
                notes          = dgvRow.Cells["NOTES"].Value.ToString();
                secondaryEmail = dgvRow.Cells["SECONDARY_CONTACT_EMAIL"].Value.ToString();
            }
        }

        private void closebutton_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            if (dataGridView1.SelectedRows.Count != 0)
            {
              /***************************************************************************
               * if Edit button is clicked loads the selected record values for editting 
               ***************************************************************************/

                GetRecordAttributes(0);
                if (e.ColumnIndex == 0)
                {
                    clientcomboBox.SelectedValue   = clientID;
                    fileTypecomboBox.SelectedValue = fileTypeID;
                    firstNametextBox.Text          = firstName ;
                    lastNametextBox.Text           = lastName;
                    emailtextBox.Text              = email;
                    notestextBox.Text              = notes;
                    secondayEmailtextBox.Text      = secondaryEmail;
                    saveType                       = "2";
                }
            }
        }
      
    }
}
