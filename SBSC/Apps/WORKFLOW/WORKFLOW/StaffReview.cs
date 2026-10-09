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

namespace WORKFLOW
{
    public partial class StaffReview : System.Windows.Forms.Form
    {
        public StaffReview()
        {
            InitializeComponent();
        }

        private static StaffReview m_SChildform1;
        /***************************************************************************
         * if not created yet or disposed, Create an instance
         * if just created or created earlier.Return it
         ***************************************************************************/
        public static StaffReview GetChildInstance()
        {
            if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
                m_SChildform1 = new StaffReview();
            return m_SChildform1;
        }

        public string inputBatchID;   
        public string staffID;
        public string staffName;
        private string sql;
        private List<SqlParameter> parms = new List<SqlParameter>();
        private bool pageLoaded = false;
        private DialogResult r = new DialogResult();

     /***************************************************************************
      * Loads all the drop downs and the datagrid
      ***************************************************************************/
        private void StaffReview_Load(object sender, EventArgs e)
        {                     
            sql = "select id,CATEGORY_NAME as name from STAFF_PROBLEM_CATEGORIES";
            WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql, null, ctgcomboBox, "Categories", "name", "id", true, "");
            tittlelabel.Text = tittlelabel.Text + " " + staffName;                    
            pageLoaded = true;

            view();
        }

        /***************************************************************************
         * Refreshes the datagrid and restores the sort order and selected rows.
         ***************************************************************************/
        private void view()
        {           
            DataTable dt = new DataTable();
            dt = WORKFLOW.Staff.Staffs_Problems_VIEW(SBSCParent.connSpedmon,"", inputBatchID, "","1" );
            dataGridView1.DataSource = dt;

            if (dt.Rows.Count != 0)
            {
                for (int j = 7; j <= 9; j++)
                    dataGridView1.Columns[j].Visible = false;
            }
                                 
        }

       /***************************************************************************
        * clears the input controls 
        ***************************************************************************/
        private void cancelbutton_Click(object sender, EventArgs e)
        {
            ctgcomboBox.SelectedIndex = 0;
            revtextBox.Text = "";
        }

        private void closebutton_Click(object sender, EventArgs e)
        {
           this.Dispose();
        }

       /***************************************************************************
        * editing and deleting of staff reviews
        ***************************************************************************/
        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            if (dataGridView1.SelectedRows.Count == 1)
            {
                GetRecAttributes(0);
                if (e.ColumnIndex == 0)
                {
                    ctgcomboBox.SelectedValue = Convert.ToInt64(categoryID);
                    LoadReview(categoryID);
                    revtextBox.Focus();
                }

                if (e.ColumnIndex == 1)
                {
                    r = DialogResult.No;
                    r = MessageBox.Show("Are you sure you want to delete this review?", "Delete File", MessageBoxButtons.YesNo);

                    if (r == DialogResult.Yes)
                    {
                        WORKFLOW.Staff.Staffs_Problems_delete(SBSCParent.connSpedmon, "", "0", recID, SBSCParent.userID.ToString());
                        view();
                    }
                }
            }
        }

       /***************************************************************************
        * Loads the review textbox 
        ***************************************************************************/
        private void LoadReview(string ctgry)
        {
            if (ctgry != "")
            {                              
                DataTable dt = new DataTable();
                dt = Staff.Staffs_Problems_VIEW(SBSCParent.connSpedmon, staffID, inputBatchID, ctgry, "1");
                if (dt.Rows.Count > 0)
                   revtextBox.Text = dt.Rows[0]["Review"].ToString();
            }
        }
   
        private DataGridViewRow dgvRow;
        private string categoryID;
        private string review;
        private string recID;

      /***************************************************************************
       * Gets the selected staff review record properties in the datagrid.
       ***************************************************************************/
        private void GetRecAttributes(int row)
        {
            if (dataGridView1.SelectedRows.Count == 1)
            {
                dgvRow     = dataGridView1.SelectedRows[row];
                categoryID = dgvRow.Cells["CategoryID"].Value.ToString();
                review     = dgvRow.Cells["Review"].Value.ToString();
                recID      = dgvRow.Cells["ReviewID"].Value.ToString();
            }
        }

       /***************************************************************************
        * updates the review textbox when the selection changes.
        ***************************************************************************/
        private void ctgcomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
             if (pageLoaded && ctgcomboBox.Text != "") 
                LoadReview(ctgcomboBox.SelectedValue.ToString());
        }

       /***************************************************************************
        * Adds or edits a review record
        ***************************************************************************/
        private void addbutton_Click(object sender, EventArgs e)
        {
            if (revtextBox.Text != "")
            {
                review = revtextBox.Text;
                categoryID = ctgcomboBox.SelectedValue.ToString();
                ctgcomboBox.SelectedIndex = 0;
                revtextBox.Text = "";
                WORKFLOW.Staff.StaffReviewSave(SBSCParent.connSpedmon, staffID, inputBatchID.ToString(), categoryID, SBSCParent.userID.ToString(), review, "");
                view();
            }
            else MessageBox.Show("Please enter review!");
        }      
    }
}
