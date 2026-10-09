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
    public partial class SelectQuestion : System.Windows.Forms.Form
    {
        public SelectQuestion()
        {
            InitializeComponent();
        }
        private static SelectQuestion m_SChildform1;

        /***************************************************************************
         * if not created yet or disposed, Create an instance of the form
         * if just created or created earlier.Return it
         ***************************************************************************/
        public static SelectQuestion GetChildInstance()
        {
            if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
               m_SChildform1 = new SelectQuestion();
            return m_SChildform1;
        }

        private string sql;
        private bool formLoaded = false;
        private void SelectQuestion_Load(object sender, EventArgs e)
        {
          /***************************************************************************
           * Load the typeComboBox.
           ***************************************************************************/

            /* As of 4/23/2014, stamps were simplified to all belong to a single type, making the stamp category combobox superfluous. 
            * 
            *  To avoid too much UI tweaking. the combobox just gets hidden and the database call commented out.
            * 
            * - DW 4/23/2014 */
            /*
            sql = "select ID,CATEGORY_NAME as name from STAMP_CATEGORIES";
            WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql, null, typecomboBox, "Category", "name", "id", true, "");
             */
            typecomboBox.Hide();
            label1.Hide();

            formLoaded = true;

            dataGridView1.EditingControlShowing += new DataGridViewEditingControlShowingEventHandler(InputBatches.dataGridView1_EditingControlShowing);

            typecomboBox_SelectedIndexChanged(sender, e);
        }
       

        /***************************************************************************
         * Fills the datagrid with questions from the selected category
         ***************************************************************************/
        private void typecomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            DataTable dt;
            ReturnDB rd;
            if (formLoaded)
            {
                 try
                {
                    if (typecomboBox.Text != "")
                        sql = "select description as Question, STAMP_ID as ID from STAMPS_STAMP WHERE TYPE = 'Qform' and active = 1 and CATEGORY = " + typecomboBox.SelectedValue.ToString();
                    else
                        sql = "select description as Question, STAMP_ID as ID from STAMPS_STAMP WHERE TYPE = 'Qform'  and active = 1";

                    rd = Database.execQuery(SBSCParent.connSpedmon, null, sql, false, null);

                    dt = Database.convertReturnDBToDatatable(ref rd);

                    dataGridView1.DataSource = dt;
                    DataGridViewCellStyle dataGridViewCellStyle = new System.Windows.Forms.DataGridViewCellStyle();

                    if (dataGridView1.RowCount != 0)
                    {
                        dataGridViewCellStyle.Alignment    = System.Windows.Forms.DataGridViewContentAlignment.TopLeft;
                        dataGridViewCellStyle.WrapMode     = System.Windows.Forms.DataGridViewTriState.True;
                        dataGridView1.RowsDefaultCellStyle = dataGridViewCellStyle;
                        dataGridView1.Columns[0].Width     = dataGridView1.Width - 10;
                                                                                           
                    }
                }
                 catch (Exception ex)
                 { MessageBox.Show(ex.Message); }
            }
        }

        /***************************************************************************
         * Saves the selected question and id in InfoRequestRespose form and closes
         ***************************************************************************/
        private void selectbutton_Click(object sender, EventArgs e)
        {
            if (dataGridView1.SelectedRows.Count >= 1)
            {
                InfoRequestResponseForm.question     = dataGridView1.SelectedRows[0].Cells[0].Value.ToString();
                InfoRequestResponseForm.questionID   = dataGridView1.SelectedRows[0].Cells[1].Value.ToString();
                InfoRequestResponseForm.questionType = null; /* no stamp types used as of this point */
            }
             this.Dispose();
        }

        private void cancelbutton_Click(object sender, EventArgs e)
        {
            this.Dispose();
        }

        private void label1_Click(object sender, EventArgs e)
        {

        }
              
    }
}
