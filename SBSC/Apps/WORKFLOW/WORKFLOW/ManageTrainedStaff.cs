using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using MBA;

namespace WORKFLOW
{
    public partial class ManageTrainedStaff : System.Windows.Forms.Form
    {
        public ManageTrainedStaff()
        {
            InitializeComponent();
        }

        private void closebutton_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private static ManageTrainedStaff m_SChildform1;

        /***************************************************************************
         * if not created yet or disposed, Create an instance
         * if just created or created earlier.Return it
         ***************************************************************************/
        public static ManageTrainedStaff GetChildInstance()
        {
            if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
                m_SChildform1 = new ManageTrainedStaff();
            return m_SChildform1;
        }

        private string sql;       

        private void ManageTrainedStaff_Load(object sender, EventArgs e)
        {
       /***************************************************************************
        * populate the comboboxes 
        ***************************************************************************/
            sql = "select id,worktype from Type_Of_Work";
            WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql,null, workTypecomboBox, "WorkType", "WorkType", "id",true,"");

            sql = "select rating_id,rating from staff_training_rates";
            WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql,null, ratingcomboBox, "Rates", "rating", "rating_id",true,"");

            sql = "select id,firstname+' '+lastname as name from dbo.USERS_DATA_CORE(dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null) " +
                  "where userGroupID = dbo.CONST_USER_GROUP_SBS() and roleID in (3,4) and id != 828 and accountIsLockedOut = 0 order by firstname";

            WinFormsCommon.PopulateComboBox(SBSCParent.connUsers, sql,null, staffcomboBox, "Staff", "name", "id",true,"");
            trainedradioButton.Checked = true;
            trnrecsradioButton.Checked = true;
        }
        
        private void savebutton_Click(object sender, EventArgs e)
        {
        /***************************************************************************
         * Saves or updates a record as per selected task.
         ***************************************************************************/
            string recType;

            if (trnrecsradioButton.Checked) recType = "Training Record";
            else recType = "Audit Review Record";

            switch (recType)
            {
                case ("Audit Review Record"):
                    {
                        if (WinFormsCommon.IsNull(workTypecomboBox.SelectedValue) == "" || WinFormsCommon.IsNull(staffcomboBox.SelectedValue) == "" || percentGoodnumericUpDown.Value == 0)
                            MessageBox.Show("Please select Type of work, staff and enter the percentage of audit review!");
                        else
                        {
                            WORKFLOW.Staff.StaffAuditReviewSave(SBSCParent.connSpedmon, staffcomboBox.SelectedValue.ToString(), workTypecomboBox.SelectedValue.ToString(),
                                                                      percentGoodnumericUpDown.Value.ToString(), notetextBox.Text, auditdateTimePicker.Value.ToShortDateString(), SBSCParent.userID.ToString());
                            MessageBox.Show("Staff audit review record saved!");
                            ClearControls();
                        }
                    }
                    break;
                case ("Training Record"):
                    {
                        int trained = 0;
                        string rating = "";   
                     
                        if (ratingcomboBox.Text != "")
                            rating = ratingcomboBox.SelectedValue.ToString();

                        if (trainedradioButton.Checked)
                            trained = 1;

                        if (WinFormsCommon.IsNull(workTypecomboBox.SelectedValue) == "" || WinFormsCommon.IsNull(staffcomboBox.SelectedValue) == "")
                            MessageBox.Show("Please select Type of work and staff!");
                        else
                            if (WinFormsCommon.IsNull(ratingcomboBox.SelectedValue) == "" && trainedradioButton.Checked)
                                MessageBox.Show("Please select the rating!");
                            else
                            {
                                WORKFLOW.Staff.TrainedStaffSave(SBSCParent.connSpedmon, staffcomboBox.SelectedValue.ToString(),
                                                                workTypecomboBox.SelectedValue.ToString(),trained.ToString(),rating,"","", "0","1","");
                                MessageBox.Show("Staff Training record saved!");
                                ClearControls();
                            }
                    }
                    break;
            }
        }

        private void ClearControls()
        {
        /***************************************************************************
         * Clears all the controls to save new record.
         ***************************************************************************/
            workTypecomboBox.SelectedIndex = 0;
            staffcomboBox.SelectedIndex    = 0;
            ratingcomboBox.SelectedIndex   = 0;
            notTrainedradioButton.Checked  = false;
            percentGoodnumericUpDown.Value = 0;
            auditdateTimePicker.Value      = DateTime.Now;
            notetextBox.Text               = "";
            trainedradioButton.Checked     = true;
        }

        private void trnrecsradioButton_CheckedChanged(object sender, EventArgs e)
        {
        /***************************************************************************
         * Shows and hides the controls as per selected tasks
         ***************************************************************************/
            manageTrnpanel.Show();
            auditpanel.Hide();
            ClearControls();
        }

        private void auditRecradioButton_CheckedChanged(object sender, EventArgs e)
        {
        /***************************************************************************
         * Shows and hides the controls as per selected tasks
         ***************************************************************************/
            manageTrnpanel.Hide();
            auditpanel.Show();
            ClearControls();
        }        

        private void cancelbutton_Click(object sender, EventArgs e)
        {
            ClearControls();
        }             
    }
}
