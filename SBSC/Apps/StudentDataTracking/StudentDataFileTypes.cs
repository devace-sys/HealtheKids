using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MBA;

namespace StudentDataTracking
{
    public partial class StudentDataFileTypes : System.Windows.Forms.Form
    {
        public StudentDataFileTypes()
        {
            InitializeComponent();
        }         

        private static StudentDataFileTypes m_SChildform1;

        /***************************************************************************
         * if not created yet or disposed, Create an instance of the form
         * if just created or created earlier.Return it
         ***************************************************************************/
        public static StudentDataFileTypes GetChildInstance()
        {
            if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
                m_SChildform1 = new StudentDataFileTypes();
            return m_SChildform1;
        }
        private string sql;
        private string notes;
        private DialogResult r = new DialogResult();
        List<SqlParameter> parms = new List<SqlParameter>();

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
           /***************************************************************************
            * if Edit button is clicked loads the selected record values for editting 
            * if Delete button is clicked, re-confirms and deactivates the record.
            ***************************************************************************/
            if (dataGridView1.SelectedRows.Count != 0)
            {
                GetRecordValues(0);
                if (e.ColumnIndex == 0)
                {
                    nametextBox.Text = name;
                    desctextBox.Text = desc;

                    saveType = "2";
                }

                if (e.ColumnIndex == 1)
                { 
                    sql = "select count(*) from dbo.STUDENT_DATA_TRACKING where ACTIVE = 1 and FILE_TYPE_ID = @recID";
                    parms.Add(Database.SqlParm("@recID", SqlDbType.Int, recID, ParameterDirection.Input));
                    int sdtRecs = Convert.ToInt16(WinFormsCommon.execScalar(StudentDataTracking.connSpedmon, sql, parms));
                    //clear parms list 
                    parms.Clear();

                    r = MessageBox.Show("Are you sure you want to delete this data type?", "Delete", MessageBoxButtons.OKCancel);
                    
                    if (sdtRecs > 0)
                    r = MessageBox.Show("There are active Student data Tracking records with this file type. By Deleting this filetype you will lose these student data tracking records. Do you want to continue deleting this file type?", 
                                        "Delete", MessageBoxButtons.OKCancel);

                    if (r == DialogResult.OK)
                    {
                        notes = Microsoft.VisualBasic.Interaction.InputBox("Enter reason for delete", "File Delete", "", 183, 308);

                        StudentData.StudentDataFileTypesDelete(StudentDataTracking.connSpedmon, notes, "1", recID, StudentDataTracking.userID.ToString());

                        viewbutton_Click(sender, e);                        
                    }
                }
            }
        }

        private string name;
        private string desc;
        private string recID;
        private static DataGridViewRow dgvRow;
        private string saveType = "1";

        private void StudentDataFileTypes_Load(object sender, EventArgs e)
        {
            viewbutton_Click(sender, e);
        }

        private void viewbutton_Click(object sender, EventArgs e)
        {
          /***************************************************************************
           * Loads or Refreshes the datagrid and restores the sort order and selected rows.
           ***************************************************************************/ 
            DataTable dt = new DataTable();
            dt = StudentData.StudentDataFileTypesView(StudentDataTracking.connSpedmon,"","1","");                                                 
            dataGridView1.DataSource = dt;
        }

        private void closebutton_Click(object sender, EventArgs e)
        {
            this.Close();
        }

       /***************************************************************************
        * gets the columns values of selected row
        ***************************************************************************/
        private void GetValues()
        {
            name = nametextBox.Text;
            desc = desctextBox.Text;
        }
       /***************************************************************************
        * Gets the selected record properties in the datagrid.
        ***************************************************************************/
        private void GetRecordValues(int row)
        {
            if (dataGridView1.SelectedRows.Count >= 1)
            {
                dgvRow = dataGridView1.SelectedRows[row];
                name   = dgvRow.Cells["TYPE_NAME"].Value.ToString();
                recID  = dgvRow.Cells["id"].Value.ToString();
                desc   = dgvRow.Cells["DESCRIPTION"].Value.ToString();                
            }
        }

        private void savebutton_Click(object sender, EventArgs e)
        {
            GetValues();
            if (name != "")
            {
                if (saveType == "1") recID = "";
                StudentData.StudentDataFileTypeSave(StudentDataTracking.connSpedmon, name, desc, StudentDataTracking.userID.ToString(), saveType, recID);

                viewbutton_Click(sender, e);
                cancelbutton_Click(sender, e);
            }
            else MessageBox.Show("File type name can not be empty.");
        }

        private void cancelbutton_Click(object sender, EventArgs e)
        {
            //cancels current operation
            nametextBox.Text = "";
            desctextBox.Text = "";
            saveType         = "1";
        }
             
    }
}
