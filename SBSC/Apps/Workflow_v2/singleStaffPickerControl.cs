using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Diagnostics;


using MBA;
using Spedmon;
using System.Data.SqlClient;

namespace Workflow_v2
{
    public partial class singleStaffPickerPanel : UserControl1
    {
        string ConnSpedmonStr;

        private string noBatchAssignedStr = "None currently assigned. Use the 'I need more work!' button.";

        private string rootPath;

        InputBatch currentBatch;

        WorkflowUser CurrentUser; 

        public singleStaffPickerPanel(string SqlConnString, DetailsLog dlog, WorkflowUser uInfo, string batchPathRoot)
        {
            InitializeComponent();
            this.Dock = DockStyle.Fill;

            CurrentUser = uInfo;

            ConnSpedmonStr = SqlConnString;

            currentBatch = new InputBatch();

            this.ctrlUserInfo = CurrentUser.curAppUser;
            this.dbRefresh();

            rootPath = batchPathRoot;

            

        }
        private void dbRefresh()
        {
            //runWorkPicker();

            /* 1: Call up the picker view to get the current batch */
            using (SqlConnection Conn = new SqlConnection(ConnSpedmonStr))
            {
                Conn.Open();

                /* Do an initial run into a temp datagridview */
                ReturnDB testbatchView =

                    /* TODO: Can we use DefineColumns arg to limit the amount of output we need for this. */
                    InputBatches.workPickerView(
                                Conn,
                                this.ctrlDetailsLog,
                                this.ctrlUserInfo,
                                Entities.REC_VIEW_RAW,
                                false,
                                "", "", this.ctrlUserInfo.useridStr, null, true);

                DataTable BatchData =
                    Database.convertReturnDBToDatatable(ref testbatchView);

                string TopBatchID = "";

                if (BatchData.Rows.Count != 0)
                {
                    TopBatchID = BatchData.Rows[0]["id"].ToString();
                    currentBatch = InputBatches.load(Conn, ctrlDetailsLog, ctrlUserInfo, TopBatchID);

                    
                    copyCurrentBatchReftoClipboard();
                }
                else
                {
                    currentBatch = null;
                }
                batchUINullCheck();
            }
        }

        private void runWorkPicker()
        {
            string pickedBatchID;
            InputBatch pickedBatch;

            /* Run work picker to get batch ID to assign to user */
            pickedBatchID = InputBatches.workPickerPickWorkBatch(this.ConnSpedmonStr, ctrlUserInfo.useridStr);

            /* Did we get an actual ID back? */
            if (pickedBatchID == "")
            {
                pickedBatch = null;
                /* TODO: Throw an error message here because there's no available work the user's trained in. */
                MessageBox.Show("There's no work available that you're qualified to input. Check with a work leader for more work.");
            }
            else
            {
                /* load this ID  and check info */
                using (SqlConnection conn = new SqlConnection(ConnSpedmonStr))
                {
                    conn.Open();
                    pickedBatch = InputBatches.load(conn, ctrlDetailsLog, ctrlUserInfo, pickedBatchID);


                    if ((pickedBatch.Current_status_Code == (int)InputBatches.Status.inputStarted) && (pickedBatch.Last_Assigned_User_ID == ctrlUserInfo.userid))
                    {
                        /* Assigned to current user and they've started input? */
                        /* Don't need to DO anything, buuuuuut might be nice to have something happen */
                        if (currentBatch.id == pickedBatch.id)
                        {
                            /* we picked the same batch as current. Weird! */

                            MessageBox.Show("The batch that was selected is the same as the current batch. Has this batch been completed?");
                        }
                    }
                    else if ((pickedBatch.Current_status_Code == (int)InputBatches.Status.assignedInput) && (pickedBatch.Last_Assigned_User_ID == ctrlUserInfo.userid))
                    {
                        /* Assigned to current user and they haven't started input? */
                        /* update batch to reflect status change */
                        pickedBatch.Current_status_Code = (int)InputBatches.Status.inputStarted;
                        InputBatches.save(conn, 2, pickedBatch, pickedBatch.Notes);
                    }
                    else if ((pickedBatch.Current_status_Code == (int)InputBatches.Status.ReadytoAssign))
                    {
                        /* New assignment? */
                        /* update batch to reflect status change and assign */
                        pickedBatch.Current_status_Code = (int)InputBatches.Status.inputStarted;
                        pickedBatch.Current_status_UserID1 = ctrlUserInfo.userid;
                        pickedBatch.Current_status_UserID2 = ctrlUserInfo.userid;
                        InputBatches.save(conn, 2, pickedBatch, "Assigned via work picker");
                    }
                    else
                    {
                        throw new ArgumentException("The input batch " + pickedBatch.File_Name + " is not in an expected status (currently: " + pickedBatch.Current_status_Code.ToString()+")" );
                    }
                }
            }
            currentBatch = pickedBatch;

        }

        private void openCurrentBatch()
        { 
            Process.GetCurrentProcess().Dispose();

            string pathNFile = rootPath + currentBatch.File_Location + currentBatch.File_Name;

            try
            {
                {
                    if (System.IO.File.Exists(pathNFile))
                    {
                        string path = pathNFile;

                        if (string.IsNullOrEmpty(pathNFile))
                            throw new ArgumentException("'path' cannot be null or empty.", "path");

                        if (!WinFormsCommon.FileInUse(pathNFile))
                        {
                            Process.Start(pathNFile);
                        }
                        else MessageBox.Show("File is in use!");
                    }
                    else MessageBox.Show("File isn't at the location recorded in the database. (" + pathNFile + ")" );
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void copyCurrentBatchReftoClipboard()
        {
            Clipboard.SetText(currentBatch.FileReference);
        }



        /* UI state automation */

        private void batchUINullCheck()
        {
            if ((currentBatch == null))
            {
                setStateNullCurrentBatch();
            }
            else
            {
                setStateHaveCurrentBatch();
            }
        }

        private void setStateNullCurrentBatch()
        {
            /* Disable UI elements when they wouldn't operate correctly + appropriate msgs */
            currentBatchNameLabel.Text = noBatchAssignedStr;
            currentBatchNameLabel.Enabled = false;

            btnCopyReference.Enabled = false;
            btnOpenFile.Enabled = false;
            doneWithBatchBtn.Enabled = false;

            btnGetNewBatch.Enabled = true;
        }

        private void setStateHaveCurrentBatch()
        {
            /* enable UI elements when there's a current batch to work with */
            currentBatchNameLabel.Text = currentBatch.FileReference.ToString().ToUpper().Replace(".PDF", "");
            currentBatchNameLabel.Enabled = true;
            btnCopyReference.Enabled = true;
            btnOpenFile.Enabled = true;
            doneWithBatchBtn.Enabled = true;

            btnGetNewBatch.Enabled = false;
        }


        /* Event Handlers */

        private void btnDBRefresh_Click(object sender, EventArgs e)
        {
            dbRefresh();
        }

        private void btnCopyReference_Click(object sender, EventArgs e)
        {
            if (currentBatch != null)
            {
                copyCurrentBatchReftoClipboard();
            }
        }

        private void btnOpenFile_Click(object sender, EventArgs e)
        {
            openCurrentBatch();
        }

        private void currentBatchNameLabel_Click(object sender, EventArgs e)
        {
            openCurrentBatch();
        }

        private void btnGetNewBatch_Click(object sender, EventArgs e)
        {
            runWorkPicker();
            dbRefresh();

        }

        private void testUserIDDebugField_TextChanged(object sender, EventArgs e)
        {
            /* Allows refresh calls for users other than current (debug only) */
            string UserIDVal = "";

            object valueFromTextDebug;
            try
            {
                valueFromTextDebug = MBA.Validate.optInteger(testUserIDDebugField.Text.ToString(), "nontext");
                UserIDVal = valueFromTextDebug.ToString();
            }
            catch
            {
                UserIDVal = this.ctrlUserInfo.userid.ToString();
            }
            finally
            {
                ctrlUserInfo.useridStr = UserIDVal;
                long.TryParse(UserIDVal, out ctrlUserInfo.userid);
                testUserIDDebugField.Text = ctrlUserInfo.useridStr;
            }
        }

        private void singleStaffPickerPanel_Load(object sender, EventArgs e)
        {
            if (CurrentUser.curAppUser.userid != 23)
                testUserIDDebugField.Hide();
        }

        private void doneWithBatchBtn_Click(object sender, EventArgs e)
        {
            DialogResult confirm = MessageBox.Show("Are you done with the batch " + currentBatch.FileReference + "?", "Confirmation", MessageBoxButtons.YesNo);
            if (confirm == DialogResult.Yes)
            {
                using (SqlConnection conn = new SqlConnection(ConnSpedmonStr))
                {
                    conn.Open();
                    InputBatch saveBatch = this.currentBatch;
                    saveBatch.Current_status_Code = (int)InputBatches.Status.ReviewInputComplete;
                    saveBatch.Current_status_UserID1 = ctrlUserInfo.userid;
                    saveBatch.Current_status_UserID2 = ctrlUserInfo.userid;
                    InputBatches.save(conn, 2, saveBatch, "WFA2 completed");

                }
            }
            dbRefresh();

            
        }

    }
}
