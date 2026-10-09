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
    public partial class StaffProblemHistory : System.Windows.Forms.Form
    {
        public StaffProblemHistory()
        {
            InitializeComponent();
        }

        private static StaffProblemHistory m_SChildform1;

        /***************************************************************************
         * if not created yet or disposed, Create an instance
         * if just created or created earlier.Return it
         ***************************************************************************/
        public static StaffProblemHistory GetChildInstance()
        {
            if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
                m_SChildform1 = new StaffProblemHistory();
            return m_SChildform1;
        }

        private string sql;

        private void closebutton_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void StaffProblemHistory_Load(object sender, EventArgs e)
        {
            if (SBSCParent.isInputStaff)
            {
                sql = "select id,firstname+' '+lastname as name from dbo.USERS_DATA_CORE(dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null)  " +
                                  "where id = " + SBSCParent.userID;
                WinFormsCommon.PopulateComboBox(SBSCParent.connUsers, sql, null, staffcomboBox, "users", "name", "id", false, "");
            }
            else
            {
                sql = "select id,firstname+' '+lastname as name from dbo.USERS_DATA_CORE(dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null) " +
                                  "where userGroupID = dbo.CONST_USER_GROUP_SBS() and roleID in (3,4) order by firstname";
                WinFormsCommon.PopulateComboBox(SBSCParent.connUsers, sql, null, staffcomboBox, "users", "name", "id", true, "All");
            }

            sql = "select id,CATEGORY_NAME as name from STAFF_PROBLEM_CATEGORIES";
            WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql, null, ctgcomboBox, "Categories", "name", "id", true, "All");   
        }

       /***************************************************************************
        * Refreshes the datagrid and restores the sort order and selected rows.
        ***************************************************************************/  
        private void viewbutton_Click(object sender, EventArgs e)
        {
           
            WinFormsCommon.loadDataGrid(ref dataGridView1, 5, 7,
                                         delegate
                                         {
                                             return WORKFLOW.Staff.Staffs_Problems_VIEW(SBSCParent.connSpedmon,
                                             WinFormsCommon.IsNull(staffcomboBox.SelectedValue), "",
                                             WinFormsCommon.IsNull(ctgcomboBox.SelectedValue), "1"
                                             );
                                         });
            
        }

       /***************************************************************************
        * clears the selections
        ***************************************************************************/
        private void clearbutton_Click(object sender, EventArgs e)
        {
            staffcomboBox.SelectedIndex = 0;
            ctgcomboBox.SelectedIndex = 0;
            viewbutton_Click(sender, e);          
        }

       /***************************************************************************
        * refreshes the datagridview when the form is activated
        ***************************************************************************/
        private void StaffProblemHistory_Activated(object sender, EventArgs e)
        {
            viewbutton_Click(sender, e);
        }
    }
}
