using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;

using MBA;

using System.Configuration;
using System.Net.Configuration;

namespace Workflow_v2
{
    public partial class WorkflowInstance
    {
        private void loadWorkflowConfig()
        {
            
            /*-------------------------------

            * Test to see if a config file
            * exists and if it does not
            * throw an exception
            *------------------------------*/
            if (!WindowsApplication.AppConfigExists(AppDomain.CurrentDomain.GetData("APP_CONFIG_FILE").ToString()))
                throw new ArgumentException("Missing app config file");

            /* bring in connection strings */

            ConnSpedmonStr = ConfigurationManager.ConnectionStrings["Spedmon"].ConnectionString.ToString();
            ConnUsersStr = ConfigurationManager.ConnectionStrings["Users"].ConnectionString.ToString();

            ApplicationName = "spedcare"; /* TODO: define this as 'Workflow' in config file (and setup new application Workflow in DB) */

            /* File paths from config to provide correct roots for access */
            basePath = ConfigurationManager.AppSettings["basePath"].ToString();
            oldpath= ConfigurationManager.AppSettings["oldPath"].ToString();

        }

        private void permissionVisibilityControl()
        {

        }


        private void tabPagesDataRefresh(System.Windows.Forms.TabPage currentTab)
        {
            /* Central method for calling methods for refreshing stuff on different tab pages. */

            if (currentTab.Name.ToString() == SqlRptTab.Name.ToString())
            {

            }

            else if (currentTab.Name.ToString() == PermissionsTab.Name.ToString())
            {  
            }
            //else

                //throw new NotImplementedException(currentTab.Name.ToString() + " does not have data refresh/load method in tabPagesDataRefresh().");
        }

        public void hideFlaggedDGVCols(System.Windows.Forms.DataGridView dgv, char charFlag)
        {
            foreach (System.Windows.Forms.DataGridViewColumn c in dgv.Columns)
            {
                /* Hide rows starting with an underscore */
                if (c.Name[0] == charFlag)
                    c.Visible = false;
            }
        }

        public void showFlaggedDGVCols(System.Windows.Forms.DataGridView dgv, char charFlag)
        {
            foreach (System.Windows.Forms.DataGridViewColumn c in dgv.Columns)
            {
                /* Hide rows starting with an underscore */
                if (c.Name[0] == charFlag)
                    c.Visible = true;
            }
        }

    }
}
