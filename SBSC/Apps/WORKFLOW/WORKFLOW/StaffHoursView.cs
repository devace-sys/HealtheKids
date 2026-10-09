using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Security.Permissions;
using System.IO;
using MBA;


namespace WORKFLOW
{
    public partial class StaffHoursView : System.Windows.Forms.Form
    {
        public StaffHoursView()
        {
            InitializeComponent();
        }

        private void closebutton_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private static StaffHoursView m_SChildform1;

        /***************************************************************************
         * if not created yet or disposed, Create an instance of the form
         * if just created or created earlier.Return it
         ***************************************************************************/
        public static StaffHoursView GetChildInstance()
        {
            if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
                m_SChildform1 = new StaffHoursView();
            return m_SChildform1;
        }

        private string sql;
        private string day = "";
        private bool pageloaded = false;

        private void StaffHoursView_Load(object sender, EventArgs e)
        {
            if (SBSCParent.isInputStaff)
            {
                //sql = "select Status_Code,Status from Input_Batches_Status where status_code in (60,70,80,90,100)";
                staffcomboBox.Hide();
                editbutton.Hide();
                clearbutton.Hide();
                stafflabel.Hide();
            }

            sql = "select id,firstname+' '+lastname as name from dbo.USERS_DATA_CORE(dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null) " +
                                  "where userGroupID = dbo.CONST_USER_GROUP_SBS() and roleID in (3,4) and " +
                                  "accountIsLockedOut = 0 order by firstname";
            WinFormsCommon.PopulateComboBox(SBSCParent.connUsers, sql,null, staffcomboBox, "users", "name", "id",true,"All");

            workWeekdateTimePicker.Value = Util.generateStartDate(2);

            //if (workWeekdateTimePicker.Value.DayOfWeek.ToString() == "Sunday") { daycomboBox.Enabled = true; view(); }
            //else { daycomboBox.Enabled = false; staffcomboBox.Enabled = false; staffHoursdataGridView.Hide(); }
            pageloaded = true;
        }
      
         

        /***************************************************************************
         * Set the day value depending on the daycombobox selection
         ***************************************************************************/
        private void daycomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (daycomboBox.Text != "" && workWeekdateTimePicker.Value.DayOfWeek.ToString() == "Sunday")
            {
                switch (daycomboBox.Text)
                {
                    case "Sunday":
                        {
                            day = workWeekdateTimePicker.Value.ToShortDateString();
                            break;
                        }
                    case "Monday":
                        {
                            day = workWeekdateTimePicker.Value.AddDays(1).ToShortDateString();
                            break;
                        }
                    case "Tuesday":
                        {
                            day = workWeekdateTimePicker.Value.AddDays(2).ToShortDateString();
                            break;
                        }
                    case "Wednesday":
                        {
                            day = workWeekdateTimePicker.Value.AddDays(3).ToShortDateString();
                            break;
                        }
                    case "Thursday":
                        {
                            day = workWeekdateTimePicker.Value.AddDays(4).ToShortDateString();
                            break;
                        }
                    case "Friday":
                        {
                            day = workWeekdateTimePicker.Value.AddDays(5).ToShortDateString();
                            break;
                        }
                    case "Saturday":
                        {
                            day = workWeekdateTimePicker.Value.AddDays(6).ToShortDateString();
                            break;
                        }
                }
            }
            else day = "";
            view();
        }

        private void clearbutton_Click(object sender, EventArgs e)
        {
            staffcomboBox.Text = "All";
            daycomboBox.Text = "";
            view();          
        }       

       /***************************************************************************
        * Refreshes the datagrid rows filterd by the selected values in the comboboxes
        ***************************************************************************/
        private void view()
        {
            staffHoursdataGridView.Show();
            DataTable dt = new DataTable();
            string user = "";
            if (staffcomboBox.Text != "System.Data.DataRowView")
                user = WinFormsCommon.IsNull(staffcomboBox.SelectedValue);
            if (SBSCParent.isInputStaff)
                user = SBSCParent.userID.ToString();

            dt = WORKFLOW.Staff.StaffHoursView(SBSCParent.connSpedmon, WinFormsCommon.IsNull(user),
                                WinFormsCommon.IsNull(workWeekdateTimePicker.Value), day, "", "", "");
            staffHoursdataGridView.DataSource = dt;
            if (staffHoursdataGridView.Rows.Count > 0)
            {
                staffHoursdataGridView.Columns[0].Visible = false;
                staffHoursdataGridView.Columns[1].Visible = false;
            }
        }

        private void staffcomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (pageloaded)
            {
                if (staffcomboBox.SelectedIndex != 0 && workWeekdateTimePicker.Value.DayOfWeek.ToString() == "Sunday")
                    editbutton.Enabled = true;
                else
                    editbutton.Enabled = false;

                view();
            }
        }

       /***************************************************************************
        * opens the StaffHours Edit form by passing the userID and week start date to it.
        ***************************************************************************/
        public static StaffHoursSave editForm;        

        private void editbutton_Click(object sender, EventArgs e)
        {
            editForm = StaffHoursSave.GetChildInstance();
            //this is needed to clear all the previous values in the form textbox controls.  
            if (editForm.userID != null)
            {
                editForm.Close();
                editForm = StaffHoursSave.GetChildInstance();
            }
  
            editForm.MdiParent = this.ParentForm;
            editForm.userID    = staffcomboBox.SelectedValue.ToString();
            editForm.username  = staffcomboBox.Text;
            editForm.DateStart = workWeekdateTimePicker.Value;
            editForm.Show();
            editForm.StaffHours();
            editForm.BringToFront();
        }

        private void workWeekdateTimePicker_ValueChanged_1(object sender, EventArgs e)
        {
            if (workWeekdateTimePicker.Value.DayOfWeek.ToString() == "Sunday")
            {
                day = "";
                daycomboBox.Text = "";
                daycomboBox.Enabled = true;
                staffcomboBox.Enabled = true;

                if (staffcomboBox.SelectedIndex != 0)
                    editbutton.Enabled = true;
                else
                    editbutton.Enabled = false;

                view();
            }
            else { daycomboBox.Enabled = false; staffcomboBox.Enabled = false; editbutton.Enabled = false; staffHoursdataGridView.Hide(); }
        }

        private void StaffHoursView_Activated(object sender, EventArgs e)
        {
         /***************************************************************************
          * To refresh the datagrid rows after editing 
          ***************************************************************************/
            clearbutton_Click(sender, e);            
        }           
       
    }
}
