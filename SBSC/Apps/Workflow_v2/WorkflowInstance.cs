using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Data.SqlClient;


using MBA;

namespace Workflow_v2
{
    public partial class WorkflowInstance : System.Windows.Forms.Form
    {

        public WorkflowUser currentUser;
        public UserInfo currentSpedmonUser;
        public DetailsLog WFIdetailsLog;

        public static string ConnSpedmonStr { get; private set; }
        public static string ConnUsersStr { get; private set; }
        public static string ApplicationName { get; private set; }

        public static string basePath;
        public static string oldpath; 



        public int getHeightChildControls(Control c)
        {
            int totalHeight = 0;

            /* Base case */

            if (c.Controls.Count == 0)
                totalHeight = c.Height ;
            else
            {
                foreach (Control cChild in c.Controls)
                    totalHeight += cChild.Height;
            }
            return totalHeight - c.Margin.Bottom;
        }

        public WorkflowInstance()
        {
            loadWorkflowConfig();

            InitializeComponent();
            /* Config event handlers */

            workflowTabControl1.Selected += new TabControlEventHandler(workflowTabControl1_Selected);

            /* Event handlers for things in data mgmt */

            permissionVisibilityControl();
        }

        private void WorkflowInstance_Load(object sender, EventArgs e)
        {
            ///todo: now that we have database connections and everything, validate enumerated permissions we have stored for this app
            ///
            //try { WorkflowPermissions.permissionsDBValidate(ConnUsersStr); }
            //catch (InvalidOperationException permission_fail)
            //{
            //    throw permission_fail;
            //    Application.Exit();
            //}

            /* get user data */
            currentUser = new WorkflowUser(ConnUsersStr, ApplicationName);
            
            this.Text = this.Text + " (login: " + currentUser.userName+ " - " + currentUser.curAppUser.userRole + ")";

            /* Tie tabPages to panel controls */
            tabControlLoadPagePanels(workflowTabControl1.TabPages);

            /* Get the frontmost tab so we can call its load event */
            tabPagesDataRefresh(workflowTabControl1.SelectedTab);
        }

        #region workflowTabControl1 Events

        void workflowTabControl1_Selected(object sender, TabControlEventArgs e)
        {
            //tabPagesDataRefresh(e.TabPage);
        }

        void tabControlLoadPagePanels(TabControl.TabPageCollection pages)
        {
            foreach (TabPage page in pages)
            {
                switch (page.Name)
                {
                    case "singleStaffPickerTab":
                        singleStaffPickerPanel BatchPickerControl = new singleStaffPickerPanel(ConnSpedmonStr, WFIdetailsLog, currentUser, basePath);
                        page.Controls.Add(BatchPickerControl);

                        break;

                    case "SqlRptTab":
                        if (currentUser.userIs22Plus())
                        {
                            SqlRptPanel SqlRptControl = new SqlRptPanel(ConnSpedmonStr);
                            page.Controls.Add(SqlRptControl);
                        }
                        else
                        {
                            page.Parent.Controls.Remove(page);
                        }


                        break;

                    case "PermissionsTab":
                        /* hide PermissionsTab because it's blank */
                        if (1!=1  /*currentUser.userIs22Plus()*/ )
                        { }
                        else
                        {
                            page.Parent.Controls.Remove(page);
                        }

                        break;
                }

            }
        }

        #endregion

        private void PermissionsTab_Click(object sender, EventArgs e)
        {

        }













    }
}
