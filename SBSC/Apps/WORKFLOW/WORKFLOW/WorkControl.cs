using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MBA;

namespace WORKFLOW
{
    public partial class WorkControl : System.Windows.Forms.Form
    {
        public WorkControl()
        {
            InitializeComponent();
        }

        private static WorkControl m_SChildform1;

        /***************************************************************************
         * if not created yet or disposed, Create an instance
         * if just created or created earlier.Return it
         ***************************************************************************/
        public static WorkControl GetChildInstance()
        {
            if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
                m_SChildform1 = new WorkControl();
            return m_SChildform1;
        }

        /***************************************************************************
         * Work control feature is about adding a flag for client or type of work to 
         * hold it from processing the batch files for a given date range.
         ***************************************************************************/

        private string sql;
        private string clientID;
        private string startDate;
        private string endDate;        
        private string recID;
        private string workTypeID;
        private string notes;
        private int    saveType = 1;
        private DialogResult r  = new DialogResult();
        private bool pageLoaded = false;
        private static DataGridViewRow dgvRow;

       /***************************************************************************
        * Loads the ComboBoxes and view.
        ***************************************************************************/
        private void WorkControl_Load(object sender, EventArgs e)
        {
            sql = "select id,name from CLIENTS_VIEW(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null) order by name";
            WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql, null, clientcomboBox, "Clients", "name", "id", true, "");

            sql = "select id,worktype from Type_Of_Work";
            WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql, null, workTypecomboBox, "WorkType", "WorkType", "id", true, "");

            viewbutton_Click(sender, e);
            pageLoaded = true;
        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            if (dataGridView1.SelectedRows.Count != 0)
            {
                GetFileAttributes(0);
                if (e.ColumnIndex == 0)
                {                                       
                    clientcomboBox.SelectedValue   = clientID;
                    if (workTypeID == "") workTypeID = "0";
                    workTypecomboBox.SelectedValue = workTypeID;
                    startdatetextBox.Text          = WinFormsCommon.IsNull(startDate);
                    enddatetextBox.Text            = WinFormsCommon.IsNull(endDate);
                    notestextBox.Text              = notes;
                    saveType                       = 2;

                    clientcomboBox.Enabled   = false;
                    workTypecomboBox.Enabled = false;
                }

                if (e.ColumnIndex == 1)
                {
                     r = MessageBox.Show("Are you sure you want to delete this work control flag?", "Delete Flag", MessageBoxButtons.OKCancel);
                     if (r == DialogResult.OK)
                     {
                         notes = Microsoft.VisualBasic.Interaction.InputBox("Enter reason for delete", "File Delete", "", 183, 308);
                         WORKFLOW.InputBatches.InputBatchesWorkControldelete(SBSCParent.connSpedmon, "", "0", recID, SBSCParent.userID.ToString());

                         viewbutton_Click(sender, e);
                         saveType = 1;
                         clearbutton_Click(sender, e);
                     }
                }
            } 
        }

        DataGridViewColumn oldSortColumn;
        private void viewbutton_Click(object sender, EventArgs e)
        {
            ListSortDirection oldSortOrder;
            List<String> selectedRows = new List<String>();

            // Store the sort details.
            switch (dataGridView1.SortOrder)
            {
                case System.Windows.Forms.SortOrder.Ascending:
                    oldSortOrder = ListSortDirection.Ascending;
                    break;
                case System.Windows.Forms.SortOrder.Descending:
                    oldSortOrder = ListSortDirection.Descending;
                    break;
                default:
                    oldSortOrder = ListSortDirection.Ascending;
                    break;
            }

            oldSortColumn = dataGridView1.SortedColumn;

            selectedRows.Clear();
            // Store the selected rows
            foreach (DataGridViewRow row in dataGridView1.SelectedRows)
            {
                selectedRows.Add(row.Cells["id"].Value.ToString());
            }

            DataTable dt = new DataTable();
           
            dt = WORKFLOW.InputBatches.InputBatchesWorkControlView(SBSCParent.connSpedmon, 
                                                       "", "", "", "1", "");
            dataGridView1.DataSource = dt;

            // hide unwanted columns
            if (dt.Rows.Count != 0)
            {
                for (int j = 8; j <= 10; j++)
                    dataGridView1.Columns[j].Visible = false;
            }

            //Restore the sort
            try
            {
                if (oldSortColumn != null)
                    dataGridView1.Sort(dataGridView1.Columns[oldSortColumn.Name], oldSortOrder);
            }
            catch { };

            //Restore Selected rows
            int i = 0;
            try
            {
                foreach (DataGridViewRow row in dataGridView1.Rows)
                {
                    row.Selected = false;
                    if (selectedRows.Contains(row.Cells["id"].Value.ToString()))
                    {
                        row.Selected = true;
                        dataGridView1.FirstDisplayedScrollingRowIndex = i;
                    }
                    i += 1;
                }
            }
            catch { }
        }

       /***************************************************************************
        * Gets the selected record properties in the datagrid.
        ***************************************************************************/
        private void GetFileAttributes(int row)
        {
            if (dataGridView1.SelectedRows.Count >= 1)
            {
                dgvRow      = dataGridView1.SelectedRows[row];
                clientID    = dgvRow.Cells["Client_ID"].Value.ToString();
                startDate   = dgvRow.Cells["Start_Date"].Value.ToString();
                if (startDate != "") startDate = Convert.ToDateTime(startDate).ToShortDateString();
                endDate     = dgvRow.Cells["End_Date"].Value.ToString();
                if (endDate != "") endDate = Convert.ToDateTime(endDate).ToShortDateString();
                recID       = dgvRow.Cells["id"].Value.ToString();
                workTypeID  = dgvRow.Cells["WorkTypeID"].Value.ToString();                
                notes       = dgvRow.Cells["Note"].Value.ToString();               
            }
        }

      /***************************************************************************
       * gets the columns values of selected row
       ***************************************************************************/
        private void GetRecordAttributes()
        {
            clientID   = WinFormsCommon.IsNull(clientcomboBox.SelectedValue);
            workTypeID = WinFormsCommon.IsNull(workTypecomboBox.SelectedValue);
            startDate  = startdatetextBox.Text;
            endDate    = enddatetextBox.Text; 
            notes      = notestextBox.Text;
        }

      /***************************************************************************
       * Saves or edit a Work control flag
       ***************************************************************************/
        private void savebutton_Click(object sender, EventArgs e)
        {

            GetRecordAttributes();
            //Check if a flag already exists, if exists warn the user if he wants to overwrite it.
            if (!string.IsNullOrEmpty(clientID))
            {
                if (workTypeID == "")
                    sql = "select dbo.INPUT_BATCHES_WORK_CONTROL_CHECK(" + clientID + ",null)";
                else
                    sql = "select dbo.INPUT_BATCHES_WORK_CONTROL_CHECK(" + clientID + "," + workTypeID + ")";

                string workControlNote = WinFormsCommon.execScalar(SBSCParent.connSpedmon, sql, null);

                if (workControlNote != "" & saveType == 1)
                    MessageBox.Show("A Work control flag - '" + workControlNote + "' already exists for this Client! ", "Flag already Exists!", MessageBoxButtons.OK);

                else
                {
                    WORKFLOW.InputBatches.InputBatchesWorkControlSave(SBSCParent.connSpedmon, clientID, workTypeID, SBSCParent.userID.ToString(),
                                                                      notes, startDate, endDate, null, "1", saveType.ToString(), recID);
                    saveType = 1;
                    clearbutton_Click(sender, e);
                    viewbutton_Click(sender, e);
                    clientcomboBox.Enabled = true;
                    workTypecomboBox.Enabled = true;
                }
            }
            else MessageBox.Show("Please select a client.");
        }

      /***************************************************************************
       * Clears the controls and resets the savetype to new
       ***************************************************************************/
        private void clearbutton_Click(object sender, EventArgs e)
        {
            clientcomboBox.SelectedIndex   = 0;
            workTypecomboBox.SelectedIndex = 0;
            notestextBox.Text              = "";
            startdatetextBox.Text          = "";
            enddatetextBox.Text            = "";
            saveType                       = 1;
            recID                          = "";
            clientcomboBox.Enabled         = true;
            workTypecomboBox.Enabled       = true;
        }

     /***************************************************************************
      * stardatetextBox and enddatetextBox is updated when ever the date in the
      * datetimepicker control changes
      ***************************************************************************/
        private void startdateTimePicker_ValueChanged(object sender, EventArgs e)
        {
            if(pageLoaded)
              startdatetextBox.Text = startdateTimePicker.Value.ToShortDateString();
        }

        private void enddateTimePicker_ValueChanged(object sender, EventArgs e)
        {
            if (pageLoaded)
                enddatetextBox.Text = enddateTimePicker.Value.ToShortDateString();
        }

        private void clrDatesbutton_Click(object sender, EventArgs e)
        {
            //clears the date in startdate and enddate textboxes
            startdatetextBox.Text = "";
            enddatetextBox.Text   = "";
        }      

        private void closebutton_Click(object sender, EventArgs e)
        {
            this.Close();
        }               
    }
}
