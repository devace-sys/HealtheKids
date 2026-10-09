using System;
using System.Collections.Generic;
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
    public partial class Stamps : System.Windows.Forms.Form
    {
        public Stamps()
        {
            InitializeComponent();
        }
        private static Stamps m_SChildform1;

        /***************************************************************************
         * if not created yet or disposed, Create an instance of the form
         * if just created or created earlier.Return it
         ***************************************************************************/
        public static Stamps GetChildInstance()
        {
            if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
                m_SChildform1 = new Stamps();
            return m_SChildform1;
        }
        private string recID;
        private string saveType = "1";
        private string description;
        private string type = "Qform";
        private string category;
        private string name;
        private string sql;
        private static DataGridViewRow dgvRow;
        DialogResult r;
        private void Stamps_Load(object sender, EventArgs e)
        {
         /***************************************************************************
          * Load the ComboBoxes. This form is only for Saving and editing Qform type stamps          
          ***************************************************************************/
            
            /* As of 4/23/2014, stamps were simplified to all belong to a single type, making the stamp category combobox superfluous. 
             * 
             *  To avoid too much UI tweaking. the combobox just gets hidden and the database call commented out.
             * 
             * - DW 4/23/2014 */
            
            /*
            sql = "select ID,CATEGORY_NAME as name from STAMP_CATEGORIES";
            WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql, null, categorycomboBox, "Category", "name", "id", true, "");
             */
            label1.Hide();
            categorycomboBox.Hide();

            viewbutton_Click(sender, e);

            DataGridViewCellStyle dataGridViewCellStyle = new System.Windows.Forms.DataGridViewCellStyle();

            if (dataGridView1.RowCount != 0)
            {
                dataGridViewCellStyle.Alignment    = System.Windows.Forms.DataGridViewContentAlignment.TopLeft;
                dataGridViewCellStyle.WrapMode     = System.Windows.Forms.DataGridViewTriState.True;
                dataGridView1.RowsDefaultCellStyle = dataGridViewCellStyle;

                dataGridView1.Columns[2].Width = 800;                
            }
        }

        /***************************************************************************
      * gets the values from the controls for Edit or save
      ***************************************************************************/
        private void GetValues()
        {
            name        = nametextBox.Text;
            description = descriptiontextBox.Text;
            category    = WinFormsCommon.IsNull(categorycomboBox.SelectedValue);
        }

        /***************************************************************************
         * Gets the selected Input Batch record properties in the datagrid.
         ***************************************************************************/
        private void GetRecordAttributes(int row)
        {
            if (dataGridView1.SelectedRows.Count >= 1)
            {
                dgvRow      = dataGridView1.SelectedRows[row];             

                recID       = dgvRow.Cells["id"].Value.ToString();
                name        = dgvRow.Cells["STAMP_NAME"].Value.ToString();
                description = dgvRow.Cells["DESCRIPTION"].Value.ToString();
                category    = dgvRow.Cells["CATEGORY"].Value.ToString();
            }
        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            if (dataGridView1.SelectedRows.Count != 0)
            {
                /***************************************************************************
                 * if Edit button is clicked loads the selected row values for editting 
                 ***************************************************************************/

                GetRecordAttributes(0);
                if (e.ColumnIndex == 0)
                {
                    nametextBox.Text               = name;
                    descriptiontextBox.Text        = description;
                    if (!string.IsNullOrEmpty(category))
                        categorycomboBox.SelectedValue = category;
                    else categorycomboBox.SelectedIndex = 0;
                    saveType                       = "2";
                }

                if (e.ColumnIndex == 1)
                {
                    /***************************************************************************
                     * deletes a stamp
                     ***************************************************************************/
                    if (dataGridView1.SelectedRows.Count == 1)
                    {
                        
                        r = DialogResult.Yes;
                        r = MessageBox.Show("Are you sure to delete this Stamp?", "Delete Stamp", MessageBoxButtons.YesNo);

                        if (r == DialogResult.Yes)
                        {
                            InputBatches.StampDelete(SBSCParent.connSpedmon, "", "0", recID, SBSCParent.userID.ToString());
                            viewbutton_Click(sender, e);
                            cancelbutton_Click(sender, e);
                        }
                    }
                    else MessageBox.Show("Please select one row to Delete.");           
                    
                }
            }
        }

        private void closebutton_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void cancelbutton_Click(object sender, EventArgs e)
        {
            nametextBox.Text          = "";
            descriptiontextBox.Text   = "";
            categorycomboBox.SelectedIndex = 0;
            recID                     = "";
            saveType                  = "1";
        }

        private void viewbutton_Click(object sender, EventArgs e)
        {
            WinFormsCommon.loadDataGrid(ref dataGridView1, 5, 7,
                                       delegate
                                       {
                                           return InputBatches.StampsView(SBSCParent.connSpedmon,
                                           WinFormsCommon.IsNull(categorycomboBox.SelectedValue),
                                            "", "1", "");
                                       });          
        }

        private void savebutton_Click(object sender, EventArgs e)
        {
            //saves the record
            GetValues();
            try
            {
                r = DialogResult.Yes;
                if (string.IsNullOrEmpty(category))                
                   r = MessageBox.Show("You did not select a category for this stamp. Do you want to continue saving?","Category not selected",MessageBoxButtons.YesNo);

                if (r == DialogResult.Yes)
                {
                    InputBatches.StampSave(SBSCParent.connSpedmon, SBSCParent.userID.ToString(), name, description, category, type, "", "0", saveType, recID);
                    cancelbutton_Click(sender, e);
                    viewbutton_Click(sender, e);
                    saveType = "1";
                }
            }
            catch (Exception ex) { MessageBox.Show(ex.Message); }
        }

    }
}
