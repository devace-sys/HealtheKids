using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Security.Permissions;
using System.IO;
using System.Diagnostics;

using MBA;

namespace WORKFLOW
{
    public partial class InputBatchesEdit : System.Windows.Forms.Form
    {
        public InputBatchesEdit()
        {
            InitializeComponent();
        }

        private static InputBatchesEdit m_SChildform1;

        /***************************************************************************
         * if not created yet or disposed, Create an instance
         * if just created or created earlier.Return it
         ***************************************************************************/
        public static InputBatchesEdit GetChildInstance()
        {
            if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
                m_SChildform1 = new InputBatchesEdit();
            return m_SChildform1;
        }

        public Int64 fileID;

        private string sql;
        private string fname;
        private string clientID;
        private string clientShortName;
        private string clientCDS;
        private string dateSent;
        private string dateRecieved;
        private string fnameOriginal;
        private string filelocation;
        private string fileLoc;
        private string workType;
        private string currentStatus;
        private int currentStatusCode;
        private bool filled = false;
        private bool assigned = false;
        private string assignedID = "";
        private string assignedTO = "";
        private string partial;
        private string parentID;
        private bool update;
        private string assignedCurrent;
        private DateTime weekStartDate = DateTime.Now;
        private DialogResult r;
        private List<SqlParameter> parms = new List<SqlParameter>();


        private void InputBatchesEdit_Load(object sender, EventArgs e)
        {
            try
            {
                if (SBSCParent.isInputStaff)
                {
                    //Hide the file details if user is Input staff.
                    detailspanel.Hide();
                    editFilenamebutton.Hide();
                }
                int i = Convert.ToInt16(DateTime.Now.DayOfWeek);
                if (i > 0) weekStartDate = DateTime.Now.AddDays((0 - i));
                /***************************************************************************
                 * Load the controls with the details of the selected record
                 ***************************************************************************/
                daydateTimePicker.MinDate = DateTime.Now.Date;

                if (SBSCParent.isInputStaff)
                    sql = "select Status_Code,Status from Input_Batches_Status where status_code in (" +
                                                            FileStatus.assignedInput.ToString() + "," +
                                                            FileStatus.inputStarted.ToString() + "," +
                                                            FileStatus.ReviewQuestionForm.ToString() + "," +
                                                            FileStatus.ReviewNotBillable.ToString() + "," +
                                                            FileStatus.ReviewInputComplete.ToString() + "," +
                                                            FileStatus.CIS.ToString() + ")";
                else
                    sql = "select Status_Code,Status from Input_Batches_Status where status_code not in (" +
                                             FileStatus.corrupted.ToString() + "," +
                                             FileStatus.deleted.ToString() + "," +
                                             FileStatus.QuestionFormToPrac.ToString() + "," +
                                             FileStatus.tooLarge.ToString() + ")";
                WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql, null, statuscomboBox, "Status", "Status", "Status_Code", false, "");


                sql = "select * from INPUT_BATCHES_VIEW(" + fileID.ToString() + ",null,null,null,null,null,null,null,null)";
                ReturnDB rd = Database.execQuery(SBSCParent.connSpedmon, null, sql, false, null);
                DataTable dt = new DataTable();
                dt = Database.convertReturnDBToDatatable(ref rd);
                DataRow dr = dt.Rows[0];
                inputBatchtextBox.Text = dr["FileName"].ToString();
                fname = inputBatchtextBox.Text;
                fnameOriginal = fname;
                if (dr["AssignedTo"].ToString() != "")
                    assigned = true;

                userscomboBox.Text = dr["AssignedTo"].ToString();
                statuscomboBox.Text = dr["Status"].ToString();
                currentStatus = dr["Status"].ToString();
                workTypelabel.Text = dr["WorkType"].ToString();
                workType = dr["WorkTypeID"].ToString();
                partial = dr["PartialFile"].ToString();
                parentID = dr["ParentBatchID"].ToString();
                clientID = dr["ClientID"].ToString();
                clientShortName = dr["Client"].ToString();
                clientCDS = dr["CLIENT_CDS"].ToString();
                dateSent = dr["DateOnFile"].ToString();
                dateRecieved = dr["DateRecieved"].ToString();
                fileLoc = dr["FileLocation"].ToString();
                filelocation = SBSCParent.basePath + dr["FileLocation"].ToString();
                currentStatusCode = Convert.ToInt16(dr["StatusCode"]);
                notetextBox.Text = dr["Notes"].ToString();
                if (dr["OldestDateOfService"] != DBNull.Value)
                    oldDostextBox.Text = dr["OldestDateOfService"].ToString();
                //oldDosdateTimePicker.Value = Convert.ToDateTime(dr["OldestDateOfService"]).Date;
                else
                    oldDosdateTimePicker.Value = DateTime.Now.Date;
                if (dr["Priority"] != DBNull.Value)
                    prioritynumericUpDown.Value = Convert.ToDecimal(dr["Priority"]);
                else
                    prioritynumericUpDown.Value = Convert.ToDecimal(0);
                if (dr["Difficulty"] != DBNull.Value)
                    difficultynumericUpDown.Value = Convert.ToDecimal(dr["Difficulty"]);
                else
                    difficultynumericUpDown.Value = Convert.ToDecimal(0);

                if (dr["EstimatedHours"] != DBNull.Value)
                    InputhrnumericUpDown.Value = Convert.ToDecimal(dr["EstimatedHours"]);
                else
                    InputhrnumericUpDown.Value = Convert.ToDecimal(0.00);

                if (currentStatusCode == 320 || currentStatusCode == 330)
                    detailspanel.Hide();
                assignedTO = dr["AssignedTo"].ToString();
                assignedID = dr["User2"].ToString();
                if (assigned)
                {
                    if (statuscomboBox.SelectedValue.ToString() != FileStatus.assignedInput.ToString())
                    {
                        userscomboBox.Items.Add(assignedTO);
                        userscomboBox.SelectedIndex = 0;
                    }
                    else
                    {
                        allradioButton.Checked = true;
                        userscomboBox.SelectedValue = assignedID;
                        userscomboBox.SelectedText = assignedTO;
                    }
                }
                allradioButton.Checked = true;
                filled = true;
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        private string destinationPath;
        private PractitionerReview pracReview;

        private void updatebutton_Click(object sender, EventArgs e)
        {
            /***************************************************************************
             * updates the Input_Batches record          
             ***************************************************************************/
            try
            {
                update = true;

                r = DialogResult.Yes;
                destinationPath = "";
                if (Convert.ToInt16(statuscomboBox.SelectedValue) != currentStatusCode || currentStatusCode == FileStatus.ReadytoAssign)
                    switch (Convert.ToInt16(statuscomboBox.SelectedValue))
                    {
                        case (FileStatus.FinishedClaims):
                            {
                                if (!WinFormsCommon.FileInUse(filelocation + fname))
                                {
                                    destinationPath = FilePaths.PATH_FinishedClaims;
                                    if (currentStatusCode != FileStatus.ReviewInputComplete && currentStatusCode != FileStatus.ReviewStarted)
                                        r = MessageBox.Show(fname + " status is not Input Complete or Input Review started! Do you still want to move this file to Finished work folder?",
                                                             "Work Complete?", MessageBoxButtons.YesNo);
                                    else
                                        r = MessageBox.Show("Are you sure to move " + fname + " to Finished work Folder?", "Finished Work?", MessageBoxButtons.YesNo);
                                }
                                else
                                {
                                    MessageBox.Show("File can not be moved to Finished work folder when it is open! Please Close " + fname + " and try again.");
                                    r = DialogResult.No;
                                }
                            }
                            break;
                        case (FileStatus.NonBillableToAnI):
                            {
                                if (!WinFormsCommon.FileInUse(filelocation + fname))
                                {
                                    if (currentStatusCode != FileStatus.assignedInput && currentStatusCode != FileStatus.inputStarted && currentStatusCode != FileStatus.ReviewInputComplete)
                                        r = MessageBox.Show("Are you sure to move " + fname + " to Non-Billable files Folder?", "Non-Billable?", MessageBoxButtons.YesNo);
                                    else r = MessageBox.Show(fname + " is currently assigned, are you sure to move this file to Non-Billable files Folder?",
                                                             "Non-Billable?", MessageBoxButtons.YesNo);

                                    destinationPath = FilePaths.PATH_NotBillableForms;
                                }
                                else
                                {
                                    MessageBox.Show("File can not be moved to A&I folders when it is open! Please Close " + fname + " and try again.");
                                    r = DialogResult.No;
                                }
                            }
                            break;
                        case (FileStatus.QuestionFormToAnI):
                            {
                                MessageBox.Show("File can not be changed to this status. Please use the View screen to do this.");
                                r = DialogResult.No;
                            }
                            break;
                        case (FileStatus.CIS):
                            {
                                if (!WinFormsCommon.FileInUse(filelocation + fname))
                                {
                                    if (currentStatusCode != FileStatus.assignedInput && currentStatusCode != FileStatus.inputStarted && currentStatusCode != FileStatus.ReviewInputComplete)
                                        r = MessageBox.Show("Are you sure to move " + fname + " to CIS Folder?", "CIS?", MessageBoxButtons.YesNo);
                                    else r = MessageBox.Show(fname + " is currently assigned, are you sure to move this file to CIS Folder?", "CIS?", MessageBoxButtons.YesNo);

                                    destinationPath = FilePaths.PATH_CIS;
                                }
                                else
                                {
                                    MessageBox.Show("File can not be moved to CIS folder when it is open! Please Close " + fname + " and try again.");
                                    r = DialogResult.No;
                                }
                            }
                            break;
                        case (FileStatus.ReadytoAssign):
                            {
                                destinationPath = FilePaths.PATH_WorkinProcess;


                                /***************************************************************************
                                 * If the file status is Finished,NB,Qforms or CIS and has been assigned before
                                 * then prompt the user if they want to assign the file back to the same staff.
                                 ***************************************************************************/
                                if (((currentStatusCode == FileStatus.FinishedClaims) || (currentStatusCode == FileStatus.NonBillableToAnI) ||
                                     (currentStatusCode == FileStatus.QuestionFormToAnI) || (currentStatusCode == FileStatus.CIS)))

                                    r = MessageBox.Show(fname + " has been marked as " + currentStatus + "! Do you want to move this file to ReadytoBatch folder?", "Finished Work?", MessageBoxButtons.YesNo);

                                r = DialogResult.No;
                                /***************************************************************************
                                 * check if the estimated hours and oldest date of service has been entered
                                 * if not do not let the update, these details are compulsary
                                 * inorder to mark a file as prescreen accept.
                                 ***************************************************************************/

                                if (InputhrnumericUpDown.Value == 0)
                                {
                                    MessageBox.Show("Please enter Estimated Input hours!");
                                    break;
                                }
                                //else if (oldDosdateTimePicker.Value >= Convert.ToDateTime(dateSent))
                                else if (Convert.ToDateTime(oldDostextBox.Text) >= Convert.ToDateTime(dateSent))
                                {
                                    MessageBox.Show("Invalid Oldest date of service! Should be less than the date on file name");
                                    break;
                                }
                                else r = DialogResult.Yes;
                                if (assignedTO != "")
                                    if (currentStatusCode == FileStatus.assignedInput)
                                    {
                                        r = MessageBox.Show("File is currently assigned to " + assignedTO + ". Do you want to unassign this file?", "UnAssign file?", MessageBoxButtons.YesNo);
                                        if (r == DialogResult.Yes)
                                        {
                                            assignedID = "";
                                            userscomboBox.SelectedIndex = 0;
                                            userscomboBox.SelectedText = "";
                                        }
                                    }
                                    else
                                    {
                                        r = MessageBox.Show("Do you want to assign this file back to " + assignedTO + "?", "Assign file?", MessageBoxButtons.YesNo);
                                        if (r == DialogResult.No)
                                        {
                                            assignedID = "";
                                            userscomboBox.SelectedIndex = 0;
                                            userscomboBox.SelectedText = "";
                                        }
                                        else
                                        {
                                            destinationPath = FilePaths.PATH_STAFF_FOLDER + assignedTO + @"\WorkingFiles\";
                                            statuscomboBox.SelectedValue = FileStatus.assignedInput;
                                        }
                                        r = DialogResult.Yes;
                                    }
                            }
                            break;
                        case (FileStatus.PrescreenPENDING):
                            {
                                if (currentStatusCode != FileStatus.ReadytoBatch && currentStatusCode != FileStatus.ReadytoAssign &&
                                                currentStatusCode != FileStatus.QuestionFormToAnI && currentStatusCode != FileStatus.NonBillableToAnI)
                                {
                                    MessageBox.Show("File has been marked as " + currentStatus + "! Can not change to this status.", "Warning!");
                                    r = DialogResult.No;
                                }
                                destinationPath = FilePaths.PATH_WorkinProcess;
                            }
                            break;
                        case (FileStatus.assignedInput):
                            {
                                if (!WinFormsCommon.FileInUse(filelocation + fname))
                                {
                                    if (userscomboBox.Text.Contains("#"))
                                        assignedCurrent = userscomboBox.Text.Substring(0, userscomboBox.Text.IndexOf("#") - 1);
                                    else assignedCurrent = userscomboBox.Text;

                                    if (Convert.ToDecimal(InputhrnumericUpDown.Value) != 0 && Convert.ToDateTime(oldDostextBox.Text) <= Convert.ToDateTime(dateSent) && assignedCurrent != "")
                                    {

                                        if (assignedTO != assignedCurrent && filelocation == SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTO + @"\WorkingFiles\")
                                            r = MessageBox.Show("File is currently assigned to" + assignedTO + ", are you sure to assign to " +
                                                                 assignedCurrent + " ?", "Assign Work?", MessageBoxButtons.YesNo);

                                        if (r == DialogResult.Yes || assignedID == "") assignedID = userscomboBox.SelectedValue.ToString();

                                        destinationPath = FilePaths.PATH_STAFF_FOLDER + assignedCurrent + @"\WorkingFiles\";

                                        /***************************************************************************
                                         * Before assigning work create a safety copy in safety copies folder.
                                         * if the staff doesn't have a folder in Staff folders create one
                                         ***************************************************************************/
                                        if (SBSCParent.OK_TO_MANAGE_FILES)
                                        {
                                            if (!System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_SafetyCopies + fname))
                                                System.IO.File.Copy(filelocation + fname, SBSCParent.basePath + FilePaths.PATH_SafetyCopies + fname, true);
                                            if (!Directory.Exists(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedCurrent + @"\") && assignedCurrent != "")
                                                System.IO.Directory.CreateDirectory(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedCurrent + @"\");
                                            if (!Directory.Exists(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedCurrent + @"\WorkingFiles\") && assignedCurrent != "")
                                                System.IO.Directory.CreateDirectory(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedCurrent + @"\WorkingFiles\");
                                            if (!Directory.Exists(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedCurrent + @"\SafetyCopies\") && assignedCurrent != "")
                                                System.IO.Directory.CreateDirectory(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedCurrent + @"\SafetyCopies\");

                                            if (assignedTO != "" && assignedTO != assignedCurrent && System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTO + @"\SafetyCopies\" + fname))
                                                System.IO.File.Delete(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTO + @"\SafetyCopies\" + fname);
                                        }
                                    }
                                    else
                                    {
                                        r = DialogResult.No;
                                        MessageBox.Show("File is not ready to assign! Please make sure you entered estimated input hours,oldest date of service and select a staff to assign.");
                                    }
                                }
                                else
                                {
                                    MessageBox.Show("File can not be moved to staff's folder when it is open! Please Close " + fname + " and try again.");
                                    r = DialogResult.No;
                                }
                            }
                            break;
                        case (FileStatus.inputStarted):
                            {
                                if (assignedID == null || assignedID == "")
                                {
                                    MessageBox.Show("Unable to process your request!  File is not assigned to Input.");
                                    update = false;
                                }
                                else if (currentStatusCode != FileStatus.assignedInput &&
                                         currentStatusCode != FileStatus.Retrain &&
                                         currentStatusCode != FileStatus.ReviewQuestionForm &&
                                         currentStatusCode != FileStatus.ReviewNotBillable &&
                                         currentStatusCode != FileStatus.ReviewInputComplete)
                                    r = MessageBox.Show("File is marked as " + currentStatus + ". Are you sure to assign this file back to " + assignedTO +
                                                        " and mark file as Input started?", "Warning?", MessageBoxButtons.YesNo);
                                else
                                    r = MessageBox.Show("File is marked as " + currentStatus + ".Are you sure to mark this file as Input started?", "Warning?", MessageBoxButtons.YesNo);
                            }
                            break;
                        case (FileStatus.Retrain):
                            {
                                if (currentStatusCode != FileStatus.ReviewInputComplete ||
                                    currentStatusCode != FileStatus.ReviewNotBillable ||
                                    currentStatusCode != FileStatus.ReviewStarted ||
                                    currentStatusCode != FileStatus.ReviewQuestionForm || assignedID == "")
                                {
                                    MessageBox.Show("Unable to process your request!  File is not assigned to Input or file is not ready for 'Review'.");
                                    update = false;
                                }
                            }
                            break;
                        case (FileStatus.ReviewStarted):
                            {
                                if (currentStatusCode != FileStatus.ReviewInputComplete || currentStatusCode != FileStatus.ReviewNotBillable ||
                                    currentStatusCode != FileStatus.Retrain ||
                                    currentStatusCode != FileStatus.ReviewQuestionForm || assignedID == "")
                                {
                                    MessageBox.Show("Unable to process your request!  File is not assigned to Input or file is not ready for 'Review'.");
                                    update = false;
                                }
                            }
                            break;
                        case (FileStatus.ReviewInputComplete):
                            {
                                if (assignedID == null || assignedID == "")
                                {
                                    MessageBox.Show("Unable to process your request!  File is not assigned to Input.");
                                    update = false;
                                }
                                else
                                    if (currentStatusCode != FileStatus.assignedInput &&
                                         currentStatusCode != FileStatus.inputStarted &&
                                         currentStatusCode != FileStatus.Retrain &&
                                         currentStatusCode != FileStatus.ReviewQuestionForm &&
                                         currentStatusCode != FileStatus.ReviewNotBillable)
                                    r = MessageBox.Show("File is marked as " + currentStatus + ". Are you sure to assign this file back to " + assignedTO +
                                                " and mark file as Entered to Review -Input Complete?", "Warning?", MessageBoxButtons.YesNo);
                                else
                                    r = MessageBox.Show("File is marked as " + currentStatus + ". Are you sure to mark this file as Entered to Review - Input Complete", "Warning?", MessageBoxButtons.YesNo);
                            }
                            break;
                        case (FileStatus.ReviewQuestionForm):
                            {
                                MessageBox.Show("File can not be changed to this status. Please use the View screen to do this.");
                                r = DialogResult.No;
                            }
                            break;
                        case (FileStatus.ReviewNotBillable):
                            {
                                if (assignedID == null || assignedID == "")
                                {
                                    MessageBox.Show("Unable to process your request!  File is not assigned to Input.");
                                    update = false;
                                }
                                else
                                    if (currentStatusCode != FileStatus.assignedInput &&
                                        currentStatusCode != FileStatus.inputStarted &&
                                        currentStatusCode != FileStatus.Retrain &&
                                        currentStatusCode != FileStatus.ReviewQuestionForm)
                                    r = MessageBox.Show("File is marked as " + currentStatus + ". Are you sure to assign this file back to " + assignedTO +
                                                        " and mark file as Entered to Review - Not Billable?", "Warning?", MessageBoxButtons.YesNo);
                                else
                                    r = MessageBox.Show("File is marked as " + currentStatus + ". Are you sure to mark this file as Entered to Review - Not Billable?", "Warning?", MessageBoxButtons.YesNo);
                            }
                            break;
                        case (FileStatus.ReadytoBatch):
                            {
                                if (currentStatusCode != FileStatus.ReadytoBatch && currentStatusCode != FileStatus.ReadytoAssign && currentStatusCode != FileStatus.PrescreenPENDING &&
                                    currentStatusCode != FileStatus.QuestionFormToAnI && currentStatusCode != FileStatus.NonBillableToAnI)
                                {
                                    MessageBox.Show("File has been marked as " + currentStatus + "! Can not change to this status.", "Warning!");
                                    r = DialogResult.No;
                                }
                                else
                                    r = MessageBox.Show("File has been marked as " + currentStatus + "! Do you want to change the status as Recieved?.", "Warning!", MessageBoxButtons.YesNo);

                                destinationPath = FilePaths.PATH_WorkinProcess;
                                assignedID = "";
                            }
                            break;
                    }
                if (r == DialogResult.Yes)
                {
                    if (SBSCParent.OK_TO_MANAGE_FILES)
                        if (filelocation != SBSCParent.basePath + destinationPath && destinationPath != string.Empty)
                        {
                            update = WinFormsCommon.CanMoveFile(filelocation, SBSCParent.basePath + destinationPath, fname);
                            filelocation = SBSCParent.basePath + destinationPath;
                            fileLoc = destinationPath;
                        }

                    if (update)
                    {
                        string oldDos = oldDostextBox.Text;
                        if (oldDosdateTimePicker.Value.Date == DateTime.Now.Date) oldDos = "";
                        WORKFLOW.InputBatches.InputBatchesSave(SBSCParent.connSpedmon, fname, clientID, dateSent, dateRecieved, fileLoc,
                                                               WinFormsCommon.IsNull(partial), parentID,
                                                               WinFormsCommon.IsNull(workType),
                                                               oldDos,
                                                               InputhrnumericUpDown.Value.ToString(),
                                                               SBSCParent.userID.ToString(),
                                                               assignedID,//WinFormsCommon.IsNull(userscomboBox.SelectedValue),
                                                               prioritynumericUpDown.Value.ToString(),
                                                               difficultynumericUpDown.Value.ToString(),
                                                               WinFormsCommon.IsNull(statuscomboBox.SelectedValue),
                                                               notetextBox.Text, null, "0", "2", fileID.ToString());
                        MessageBox.Show("Update completed!", "Updated");

                        SBSCParent.refreshIBView = true;
                        RemoveSafetyCopies();
                    }
                }
            }
            catch (SqlException ex)
            { MessageBox.Show(ex.Message); }

        }

        private void RemoveSafetyCopies()
        {
            int filestatus = Convert.ToInt16(statuscomboBox.SelectedValue);
            if (filestatus == FileStatus.FinishedClaims || filestatus == FileStatus.QuestionFormToAnI || filestatus == FileStatus.NonBillableToAnI)
            {
                if (SBSCParent.OK_TO_MANAGE_FILES)
                {
                    if (System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_SafetyCopies + fname)) System.IO.File.Delete(SBSCParent.basePath + FilePaths.PATH_SafetyCopies + fname);
                    if (System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedCurrent + @"\SafetyCopies\" + fname))
                        System.IO.File.Delete(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedCurrent + @"\SafetyCopies\" + fname);
                }
            }
        }

        private void ClearControls()
        {
            /***************************************************************************
             * Clears all the input controls in the form
             ***************************************************************************/
            statuscomboBox.Text = "";
            oldDosdateTimePicker.Value = DateTime.Now.Date;
            oldDostextBox.Text = "";
            prioritynumericUpDown.Value = Convert.ToDecimal(0);
            difficultynumericUpDown.Value = Convert.ToDecimal(0);
            InputhrnumericUpDown.Value = Convert.ToDecimal(0.00);
        }

        private void cancelbutton_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        /***************************************************************************
         * Changes the file name, but allows only when file status is 
         * Prescreen accept,Prescreen reject or Recieved.
         ***************************************************************************/
        private void editFilenamebutton_Click(object sender, EventArgs e)
        {
            fname = Microsoft.VisualBasic.Interaction.InputBox("Change file name.", "Filename", fname, 183, 308);

            fnameOriginal = inputBatchtextBox.Text;

            /***************************************************************************
             * If the file is renamed.
             ***************************************************************************/
            if (fname != fnameOriginal && fname != "" &&
                WinFormsCommon.CheckFileName(SBSCParent.connSpedmon, fname, ref dateSent, ref workType, ref clientID, ref clientCDS, ref clientShortName))
            {
                update = true;
                if (!fname.ToLower().Contains(".pdf")) fname = fname + ".pdf";

                if (System.IO.File.Exists(filelocation + fnameOriginal))
                {
                    if (!System.IO.File.Exists(filelocation + fname))
                    {
                        if (SBSCParent.OK_TO_MANAGE_FILES)
                            System.IO.File.Move(filelocation + fnameOriginal, filelocation + fname);
                        else
                            update = false;
                    }
                    else
                    {
                        MessageBox.Show("A file with the name " + fname + " already exists!");
                        update = false;
                    }
                }
                else update = false;
                if (update)
                    try
                    {
                        WORKFLOW.InputBatches.InputBatchesSave(SBSCParent.connSpedmon, fname, clientID, dateSent, dateRecieved, fileLoc,
                                                               partial, parentID, workType, oldDosdateTimePicker.Value.ToShortDateString(),
                                                               InputhrnumericUpDown.Value.ToString(),
                                                               SBSCParent.userID.ToString(),
                                                               assignedID,
                                                               prioritynumericUpDown.Value.ToString(),
                                                               difficultynumericUpDown.Value.ToString(),
                                                               WinFormsCommon.IsNull(statuscomboBox.SelectedValue),
                                                               notetextBox.Text, null, "0", "2", fileID.ToString());
                        inputBatchtextBox.Text = fname;
                        sql = "select WorkType from TYPE_OF_WORK where id = @workType";
                        parms.Clear();
                        parms.Add(Database.SqlParm("@workType", SqlDbType.VarChar, workType, ParameterDirection.Input));
                        workTypelabel.Text = WinFormsCommon.execScalar(SBSCParent.connSpedmon, sql, parms);
                        MessageBox.Show("Finished renaming the file!");
                        SBSCParent.refreshIBView = true;
                    }
                    catch (SqlException ex)
                    { MessageBox.Show(ex.Message); }
            }
            else
                fname = fnameOriginal;

        }

        /***************************************************************************
         * Fills the users combobox with staff names.
         ***************************************************************************/
        private void allradioButton_CheckedChanged(object sender, EventArgs e)
        {
            if (allradioButton.Checked && Convert.ToInt16(statuscomboBox.SelectedValue) == FileStatus.assignedInput)
            {
                userscomboBox.DataSource = null;
                userscomboBox.Items.Clear();
                sql = "select id,firstname+' '+lastname as name from dbo.USERS_DATA_CORE(dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null) " +
                                  "where userGroupID = dbo.CONST_USER_GROUP_SBS() and roleID in (3,4) and id != 828 and " +
                                  "accountIsLockedOut = 0 order by firstname";
                WinFormsCommon.PopulateComboBox(SBSCParent.connUsers, sql, null, userscomboBox, "Staff", "name", "id", true, "");
            }
        }


        /***************************************************************************
         * Fills the users combobox with staff who has promised hours.
         ***************************************************************************/
        private void allAvblradioButton_CheckedChanged(object sender, EventArgs e)
        {
            if (allAvblradioButton.Checked && workTypelabel.Text != "" && Convert.ToInt16(statuscomboBox.SelectedValue) == FileStatus.assignedInput)
            {
                userscomboBox.DataSource = null;
                userscomboBox.Items.Clear();
                sql = "SELECT [STAFF_ID] as id,NAME+' # for week '+WEEK_START+'- Hoursleft - '+convert(varchar(10)," +
                    "sum([dayHOURS])-AssignedHours)+', Assigned -'+convert(varchar(10),AssignedHours) as name " +
                    "from STAFF_PROMISED_HOURS_VIEW(null,null,null,null,null,null)" +
                    "where  DateOfDay >='" + DateTime.Now.Date.ToShortDateString() +
                    "' group by Staff_ID,NAME,WEEK_START,AssignedHours having sum([dayHOURS])>0 order by week_start";

                WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql, null, userscomboBox, "Staff", "name", "id", true, "");
            }
        }

        /***************************************************************************
         * Fills the users combobox with staff who has promised hours in the current week.
         ***************************************************************************/
        private void allAvblWeekradioButton_CheckedChanged(object sender, EventArgs e)
        {
            if (allAvblWeekradioButton.Checked)
                if (workTypelabel.Text != "" && Convert.ToInt16(statuscomboBox.SelectedValue) == FileStatus.assignedInput)
                {
                    userscomboBox.DataSource = null;
                    userscomboBox.Items.Clear();
                    sql = "select distinct id,name+' #  Rating-'+convert(varchar(5),rate)+'. Working '+convert(varchar(10),weekHOURS)+' hours,Hours assigned - '+" +
                          "convert(varchar(10),ASSIGNEDHours)  as name from STAFF_TrainedandAvailable_VIEW('" + weekStartDate.ToShortDateString() + "',null," +
                            workType + "," + InputhrnumericUpDown.Value.ToString() + ")";
                    WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql, null, userscomboBox, "Staff", "name", "id", true, "");
                }
        }
        /***************************************************************************
        * Fills the users combobox with staff who has promised hours on the 
        * selected date and trained in the type of work.
        ***************************************************************************/
        private void dayradioButton_CheckedChanged(object sender, EventArgs e)
        {
            if (dayradioButton.Checked)
                if (workTypelabel.Text != "" && Convert.ToInt16(statuscomboBox.SelectedValue) == FileStatus.assignedInput)
                {
                    userscomboBox.DataSource = null;
                    userscomboBox.Items.Clear();
                    sql = "select distinct ID,name+' # '+Shifts+' Working '+convert(varchar(10),DAYHOURS)+' hours,Assigned hours '+" +
                          "convert(varchar(10),ASSIGNEDHOURS) as name from STAFF_TrainedandAvailable_VIEW(null,'" + daydateTimePicker.Value.ToShortDateString()
                          + "'," + "null," + InputhrnumericUpDown.Value.ToString() + ")";

                    WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql, null, userscomboBox, "Staff", "name", "id", true, "");
                }
        }

        /***************************************************************************
         * Fills the users combobox with staff who has promised hours on the selected date.
         ***************************************************************************/

        private void daytrndradioButton_CheckedChanged(object sender, EventArgs e)
        {
            if (daytrndradioButton.Checked)
                if (workTypelabel.Text != "" && Convert.ToInt16(statuscomboBox.SelectedValue) == FileStatus.assignedInput)
                {
                    userscomboBox.DataSource = null;
                    userscomboBox.Items.Clear();
                    sql = "select ID,name+' # '+Shifts+' Working '+convert(varchar(10),DAYHOURS)+' hours,Assigned hours '+" +
                          "convert(varchar(10),ASSIGNEDHOURS)+',Training Rate:'+CONVERT(VARCHAR(5),RATE) as name from STAFF_TrainedandAvailable_VIEW(null,'" +
                          daydateTimePicker.Value.ToShortDateString() + "'," + workType + "," +
                          InputhrnumericUpDown.Value.ToString() + ")";

                    WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql, null, userscomboBox, "Staff", "name", "id", true, "");
                }
        }

        private void statuscomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            /***************************************************************************
             * Fill the users combobox only if status is Assigned to Inputstaff
             ***************************************************************************/
            if (filled)
                if (Convert.ToInt16(statuscomboBox.SelectedValue) == FileStatus.assignedInput)
                {
                    if (allradioButton.Checked == true)
                        allradioButton_CheckedChanged(sender, e);
                    else if (allAvblradioButton.Checked == true)
                        allAvblradioButton_CheckedChanged(sender, e);
                    else if (allAvblWeekradioButton.Checked == true)
                        allAvblWeekradioButton_CheckedChanged(sender, e);
                    else if (dayradioButton.Checked == true)
                        dayradioButton_CheckedChanged(sender, e);
                    else if (daytrndradioButton.Checked == true)
                        daytrndradioButton_CheckedChanged(sender, e);
                    else allradioButton.Checked = true;
                    if (assignedID != "")
                    {
                        userscomboBox.SelectedValue = assignedID;
                        userscomboBox.SelectedText = assignedTO;
                    }
                }
        }
        /***************************************************************************
         * Fill the users combobox if 
         ***************************************************************************/
        private void daydateTimePicker_ValueChanged(object sender, EventArgs e)
        {
            daytrndradioButton_CheckedChanged(sender, e);
            dayradioButton_CheckedChanged(sender, e);

            if (!dayradioButton.Checked && !daytrndradioButton.Checked)
                dayradioButton.Checked = true;

        }

        private void userscomboBox_MouseClick(object sender, MouseEventArgs e)
        {
            if (statuscomboBox.SelectedValue.ToString() != FileStatus.assignedInput.ToString())
            {
                MessageBox.Show("Please change the status to 'AssignTo' to fill this drop down");
                statuscomboBox.Focus();
            }
        }

        private void oldDosdateTimePicker_ValueChanged(object sender, EventArgs e)
        {
            if (filled)
                oldDostextBox.Text = oldDosdateTimePicker.Value.ToShortDateString();
        }

        private void clearDatebutton_Click(object sender, EventArgs e)
        {
            oldDostextBox.Text = "";
        }

    }
}
