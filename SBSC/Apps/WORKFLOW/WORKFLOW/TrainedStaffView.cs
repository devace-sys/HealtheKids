using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Data.SqlClient;
using MBA;


namespace WORKFLOW
{
    public partial class TrainedStaffView : System.Windows.Forms.Form
    {
        public TrainedStaffView()
        {
            InitializeComponent();
        }
        
        private static TrainedStaffView m_SChildform1;

        /***************************************************************************
         * if not created yet or disposed, Create an instance
         * if just created or created earlier.Return it
         ***************************************************************************/
        public static TrainedStaffView GetChildInstance()
        {
            if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
                m_SChildform1 = new TrainedStaffView();
            return m_SChildform1;
        }

        private string sql;
        //private List<SqlParameter> parms;
        private void TrainedStaffView_Load(object sender, EventArgs e)
        {
       /***************************************************************************
        * Load comboboxes
        ***************************************************************************/
            sql = "select id,worktype from Type_Of_Work";
            WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql,null, workTypecomboBox, "WorkType", "WorkType", "id", true,"All");

            sql = "select id,firstname+' '+lastname as name from dbo.USERS_DATA_CORE(dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null)  " +
                  "where userGroupID = dbo.CONST_USER_GROUP_SBS() and roleID in (3,4) and id != 828 and accountIsLockedOut = 0 order by firstname";
            
            WinFormsCommon.PopulateComboBox(SBSCParent.connUsers, sql, null, staffcomboBox, "Staff", "name", "id", true,"All");
        }

        private void viewbutton_Click(object sender, EventArgs e)
        {
            DataTable dt = new DataTable();

            dt = WORKFLOW.Staff.TrainedStaffView(SBSCParent.connSpedmon, WinFormsCommon.IsNull(workTypecomboBox.SelectedValue),
                                                       WinFormsCommon.IsNull(staffcomboBox.SelectedValue), "1", "");
            trainedStaffdataGridView.DataSource = dt;
            // hide unwanted columns
            if (dt.Rows.Count != 0)
            {
                trainedStaffdataGridView.Columns[0].Visible = false;
                trainedStaffdataGridView.Columns[2].Visible = false;
            }

        }
      /***************************************************************************
       * Updates the view when form is activated
       ***************************************************************************/
        private void TrainedStaffView_Activated(object sender, EventArgs e)
        {
            viewbutton_Click(sender, e);
        }

       /***************************************************************************
        * clears the selections
        ***************************************************************************/
        private void clearbutton_Click(object sender, EventArgs e)
        {
            staffcomboBox.SelectedIndex = 0;
            workTypecomboBox.SelectedIndex = 0;
            viewbutton_Click(sender, e);          
        }

        private void closebutton_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void detailbutton_Click(object sender, EventArgs e)
        {
       /***************************************************************************
        * Loads the datagrid with Training record.
        ***************************************************************************/
            DataTable dt = new DataTable();

            dt = WORKFLOW.Staff.TrainedStaffDetailView(SBSCParent.connSpedmon,staffcomboBox.Text);
            trainedStaffdataGridView.DataSource = dt;            
        }
        
    }
}
