using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Diagnostics;

using MBA;

namespace WORKFLOW
{
    public partial class PractitionerReview : System.Windows.Forms.Form
    {
        public PractitionerReview()
        {
            InitializeComponent();
        }

        private static PractitionerReview m_SChildform1;

        /***************************************************************************
         * if not created yet or disposed, Create an instance
         * if just created or created earlier.Return it
         ***************************************************************************/
        public static PractitionerReview GetChildInstance()
        {
            if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
                m_SChildform1 = new PractitionerReview();
            return m_SChildform1;
        }

        public string inputBatchID;
        public string clientID;
        public string status;
        public string fname;
        public string fileLocation;
        private List<SqlParameter> parms = new List<SqlParameter>();
        private bool pageLoaded = false;
        private DialogResult r = new DialogResult();
        private void PractitionerReview_Load(object sender, EventArgs e)
        {
            tittlelabel.Text = tittlelabel.Text + " for the file " + fname;
            string sql = "select id,name from dbo.PRACTITONERS_VIEW(null, null, null, null, null, @clientID, null, null, null, null, null, null, 1, null,null)";
            parms.Clear();
            object vClientID = MBA.Validate.optInteger(clientID, "", true);
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql, parms, praccomboBox, "Practitioners", "name", "id", true, "");

            sql = "select id,CATEGORY_NAME as name from STAMP_CATEGORIES";
            WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql, null, ctgcomboBox, "Categories", "name", "id", true, "");

            pageLoaded = true;

            view();
        }

        /***************************************************************************
         * Refreshes the datagrid and restores the sort order and selected rows.
         ***************************************************************************/
        private void view()
        {
            try
            {
                DataTable dt = new DataTable();
                dt = WORKFLOW.InputBatches.Practitioners_Problems_VIEW(SBSCParent.connSpedmon, clientID, "", inputBatchID, "", "", "1");
                dataGridView1.DataSource = dt;

                if (dt.Rows.Count != 0)
                {
                    for (int j = 7; j <= 10; j++)
                        dataGridView1.Columns[j].Visible = false;
                }

            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void closebutton_Click(object sender, EventArgs e)
        {
            if (System.IO.File.Exists(fileLocation + fname) && WinFormsCommon.FileInUse(fileLocation + fname))
                MessageBox.Show("Please close " + fname + "!", "Close file");
            else  this.Dispose();
        }

       /***************************************************************************
        * Loads the review if a review already exists for the practitioner
        ***************************************************************************/
        private void LoadReview(string prac, string ctgry)
        {
            try
            {
                if (ctgry != "" && prac != "")
                {
                    DataTable dt = new DataTable();
                    dt = InputBatches.Practitioners_Problems_VIEW(SBSCParent.connSpedmon,clientID, pracID, inputBatchID, "", ctgry, "1");
                    if(dt.Rows.Count > 0)
                       revtextBox.Text = dt.Rows[0]["Review"].ToString();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            if (dataGridView1.SelectedRows.Count == 1)
            {
                GetRecAttributes(0);
                if (e.ColumnIndex == 0)
                {
                    praccomboBox.SelectedValue = Convert.ToInt64(pracID);
                    ctgcomboBox.SelectedValue  = Convert.ToInt64(categoryID);
                    LoadReview(pracID, categoryID);
                    revtextBox.Focus();
                }

                if (e.ColumnIndex == 1)
                {
                    r = DialogResult.No;
                    r = MessageBox.Show("Are you sure you want to delete this review?", "Delete File", MessageBoxButtons.YesNo);

                    if (r==DialogResult.Yes)
                    {
                        WORKFLOW.InputBatches.Practitioners_Problems_delete(SBSCParent.connSpedmon, "", "0", recID, SBSCParent.userID.ToString());
                        view();
                    }
                }
            }
        }

        /***************************************************************************
         * Gets the selected Input Batch record properties in the datagrid.
         ***************************************************************************/
        private DataGridViewRow dgvRow;
        private string pracID;
        private string categoryID;
        private string review;
        private string recID;

        private void GetRecAttributes(int row)
        {
            if (dataGridView1.SelectedRows.Count == 1)
            {
                dgvRow      = dataGridView1.SelectedRows[row];
                pracID      = dgvRow.Cells["PractitionerID"].Value.ToString();
                categoryID  = dgvRow.Cells["CategoryID"].Value.ToString();
                review      = dgvRow.Cells["Review"].Value.ToString();
                recID       = dgvRow.Cells["ReviewID"].Value.ToString();
            }
        }

        private void addbutton_Click(object sender, EventArgs e)
        {
            try
            {
                if (revtextBox.Text != "")
                {
                    review                     = revtextBox.Text;
                    pracID                     = praccomboBox.SelectedValue.ToString();
                    categoryID                 = ctgcomboBox.SelectedValue.ToString();
                    praccomboBox.SelectedIndex = 0;
                    ctgcomboBox.SelectedIndex  = 0;
                    revtextBox.Text            = "";
                    WORKFLOW.InputBatches.PracReviewSave(SBSCParent.connSpedmon, pracID, inputBatchID.ToString(), categoryID, SBSCParent.userID.ToString(), review, "");
                    view();
                }
                else MessageBox.Show("Please enter review!");
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void praccomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (pageLoaded && praccomboBox.Text != "" && ctgcomboBox.Text != "")
                LoadReview(praccomboBox.SelectedValue.ToString(), ctgcomboBox.SelectedValue.ToString());
        }

        private void ctgcomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (pageLoaded && praccomboBox.Text != "" && ctgcomboBox.Text != "")
                LoadReview(praccomboBox.SelectedValue.ToString(), ctgcomboBox.SelectedValue.ToString());
        }

        private void cancelbutton_Click(object sender, EventArgs e)
        {
            praccomboBox.SelectedIndex = 0;
            ctgcomboBox.SelectedIndex = 0;
            revtextBox.Text = "";
        }

       /***************************************************************************
        * Opens the Input batch file
        ***************************************************************************/
        private void openFilebutton_Click(object sender, EventArgs e)
        {
            if (!WinFormsCommon.FileInUse(fileLocation + fname))
                Process.Start(fileLocation + fname);
        }
    }
}
