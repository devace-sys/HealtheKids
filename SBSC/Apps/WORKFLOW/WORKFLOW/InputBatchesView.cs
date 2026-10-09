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
using System.Text.RegularExpressions;
using System.Diagnostics;
using System.Configuration;
using System.Net.Configuration;
using System.Net.Mail;
using System.Net.Mime;
using System.Globalization;
using NPOI.HSSF.UserModel;
using NPOI.HPSF;
using NPOI.POIFS.FileSystem;
using NPOI.HSSF.Record;
using NPOI.Util;
using NPOI.SS.Util;
using NPOI.HSSF.Model;
using NPOI.SS.UserModel;
using NPOI.HSSF.EventModel;
using NPOI.HSSF.Util;
using NPOI.SS.Formula;
using NPOI.HSSF.Record.AutoFilter;

using iTextSharp;
using iTextSharp.text;
using iTextSharp.text.pdf;

using MBA;

namespace WORKFLOW
{
    public partial class InputBatchesView : System.Windows.Forms.Form
    {
        public InputBatchesView()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private static InputBatchesView m_SChildform1;

        /***************************************************************************
         * if not created yet or disposed, Create an instance
         * if just created or created earlier.Return it
         ***************************************************************************/
        public static InputBatchesView GetChildInstance()
        {
            if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
                m_SChildform1 = new InputBatchesView();
            return m_SChildform1;
        }

        private string sql;
        private List<SqlParameter> parms = new List<SqlParameter>();
        DataTable dt = new DataTable();
        private string fname;
        private string clientID;
        private string clientShortName;
        private string clientCDS;
        private string dateSent;
        private string dateRecieved;
        private string sourceDirectory;
        private static DataGridViewRow dgvRow;
        private DialogResult r = new DialogResult();
        private int filestatus;
        private string fileStatusName;
        private string fileLocation;
        private string fileLoc;
        private string recID;
        private string assignedTo;
        private string oldDOS;
        private string workType;
        private string priority;
        private string difficulty;
        private string assignedID;
        private string partial;
        private string parentID;
        private string estinputhrs;
        private string prescreenededBy;
        private string notes;
        private DateTime weekStartDate = DateTime.Now;
        int d = Convert.ToInt16(DateTime.Now.DayOfWeek);
        private bool filled = false;
        private int i;
        private int k = 1;
        private bool refreshView;
        private string workControlNote;
        private bool trainedInQforms = false;

        static HSSFWorkbook hssfworkbook;

        /***************************************************************************
         * Loads all the ComboBoxes based on users role.
         ***************************************************************************/
        private void InputBatchesView_Load(object sender, EventArgs e)
        {
            estHrslabel.Hide();
            estInputnumericUpDown.Hide();
            oldDoslabel.Hide();
            oldDosdateTimePicker.Hide();

            if (d > 0) weekStartDate = DateTime.Now.AddDays((0 - d));

            //loading changeStatuscomboBox if the user is input staff check if they are trained in Qforms. if yes then allow permission to handle direct Qforms to prac.
            if (SBSCParent.isInputStaff)
            {
                sql = "  select rating from TRAINED_STAFF where WORKTYPE_ID = (select id from dbo.TYPE_OF_WORK where WorkCode = 'Qforms') and STAFF_ID = @staffID";
                parms.Clear();
                object vStaffID = MBA.Validate.optInteger(SBSCParent.userID.ToString(), "");
                object vWorkTypeID = MBA.Validate.optInteger(Staff.QformWorkTypeID.ToString(), "");
                parms.Add(Database.SqlParm("@staffID", SqlDbType.BigInt, vStaffID, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@workTypeID", SqlDbType.Int, vWorkTypeID, ParameterDirection.Input));
                string rating = WinFormsCommon.execScalar(SBSCParent.connSpedmon, sql, parms);

                if (rating == "4")
                {
                    sql = "select Status_Code,Status from Input_Batches_Status where status_code in (" +
                                                             FileStatus.inputStarted.ToString() + "," +
                                                             FileStatus.ReviewInputComplete.ToString() + "," +
                                                             FileStatus.QuestionFormToPrac.ToString() +
                                                             ") order by status_code";
                    trainedInQforms = true;
                }
                else
                    sql = "select Status_Code,Status from Input_Batches_Status where status_code in (" +
                                                           FileStatus.inputStarted.ToString() + "," +
                                                           FileStatus.ReviewInputComplete.ToString() + ") order by status_code";

                userscomboBox.Hide();
                userslabel.Hide();
                dataGridView1.Columns[1].Visible = false;
                deletebutton.Hide();
                assignWorkpanel.Hide();
                editStaffRevbutton.Hide();
                prioritybutton.Hide();
                priorlabel.Hide();
                prioritynumericUpDown.Hide();
            }
            else sql = "select Status_Code,Status from Input_Batches_Status where status_code not in (" +
                                             FileStatus.ReadytoBatch.ToString() + "," +
                                             FileStatus.assignedInput.ToString() + "," +
                                             FileStatus.corrupted.ToString() + "," +
                                             FileStatus.deleted.ToString() + "," +
                                             FileStatus.ReviewQuestionForm.ToString() + "," +
                                             FileStatus.ReviewNotBillable.ToString() + "," +
                                             FileStatus.CIS.ToString() + "," +
                                             FileStatus.tooLarge.ToString() +
                                             ") order by status_code";

            WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql, null, changeStatuscomboBox, "Status", "Status", "Status_Code", true, "");

            //loading statuscomboBox
            if (SBSCParent.isInputStaff)
            {
                sql = "select Status_Code,Status from Input_Batches_Status where status_code in (" +
                                                            FileStatus.assignedInput.ToString() + "," +
                                                            FileStatus.inputStarted.ToString() + "," +
                                                            FileStatus.ReviewQuestionForm.ToString() + "," +
                                                            FileStatus.ReviewNotBillable.ToString() + "," +
                                                            FileStatus.Retrain.ToString() + ") order by status_code";
            }
            else sql = "select Status_Code,Status from Input_Batches_Status where status_code not in (" +
                                                            FileStatus.corrupted.ToString() + "," +
                                                            FileStatus.deleted.ToString() + "," +
                                                            FileStatus.tooLarge.ToString() + ") order by status_code";

            WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql, null, statuscomboBox, "Status", "Status", "Status_Code", true, "Work in process");
            sql = "select id,name from CLIENTS_VIEW(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null) where id != 112 order by name";
            WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql, null, clientcomboBox, "Clients", "name", "id", true, "All");

            //Loading userscomboBox
            sql = "select id,firstname+' '+lastname as name from dbo.USERS_DATA_CORE(dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null) " +
                  "where userGroupID = dbo.CONST_USER_GROUP_SBS() and roleID in (3,4) and id != 828 order by firstname";

            WinFormsCommon.PopulateComboBox(SBSCParent.connUsers, sql, null, userscomboBox, "users", "name", "id", true, "All");

            //Loading typecomboBox
            sql = "select id,worktype from Type_Of_Work";
            WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql, null, typecomboBox, "WorkType", "WorkType", "id", true, "All");

            allradioButton.Checked = true;
            filled = true;

        }

        /***************************************************************************
         * Checks if the file is in use, if not opens it.
         ***************************************************************************/
        private void openFile()
        {
            Process.GetCurrentProcess().Dispose();
            GetFileAttributes(0);
            sourceDirectory = fileLocation;
            refreshView = false;

            r = DialogResult.Yes;

            if (filestatus == FileStatus.FinishedClaims)
                r = MessageBox.Show("File has been moved to finished work folder. Do you want to open this file?", "Message", MessageBoxButtons.YesNo);

            if (filestatus == FileStatus.QuestionFormToAnI)
                r = MessageBox.Show("File has been marked as Question form. Do you want to open this file?", "Message", MessageBoxButtons.YesNo);

            if (filestatus == FileStatus.NonBillableToAnI)
                r = MessageBox.Show("File has been moved to Non Billable forms folder. Do you want to open this file?", "Message", MessageBoxButtons.YesNo);

            try
            {
                if (r == DialogResult.Yes)
                {
                    if (System.IO.File.Exists(sourceDirectory + fname))
                    {
                        string path = sourceDirectory + fname;

                        if (string.IsNullOrEmpty(path))
                            throw new ArgumentException("'path' cannot be null or empty.", "path");

                        if (!WinFormsCommon.FileInUse(path))
                        {
                            bool saveCopy = true;
                            /***************************************************************************
                             * When ever the file is open, over writes or create the safety copy if the file is not corrupt
                             * 
                             * if file status is assigned or input started and is opened by a work leader
                             * do not save a safety copy unless the file is assigned to the Work leader himself.
                             * 
                             * If the Work leader is reviewing the work, over write the safety copy in the 
                             * staff folder instead of over writing the Workleader's original safety copy 
                             * that does not have any markup's.
                             ***************************************************************************/

                            if ((filestatus == FileStatus.inputStarted || filestatus == FileStatus.assignedInput) &&
                                (!SBSCParent.isInputStaff && assignedTo != SBSCParent.userName))
                                saveCopy = false;

                            if (SBSCParent.OK_TO_MANAGE_FILES &&
                                filestatus != FileStatus.ReadytoBatch && filestatus != FileStatus.ReadytoAssign &&
                                filestatus != FileStatus.QuestionFormToAnI && filestatus != FileStatus.NonBillableToAnI &&
                                filestatus != FileStatus.FinishedClaims && filestatus != FileStatus.PrescreenPENDING &&
                                filestatus != FileStatus.CIS && saveCopy)
                            {
                                string testFile = "Test" + fname;
                                string safetyCopyFolder;
                                if (SBSCParent.isInputStaff || assignedTo == SBSCParent.userName)
                                {
                                    /***************************************************************************                                       
                                     * if the staff doesn't have a safety copies folder create one
                                     ***************************************************************************/
                                    if (SBSCParent.userName != "" && !Directory.Exists(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + SBSCParent.userName + @"\SafetyCopies\"))
                                        System.IO.Directory.CreateDirectory(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + SBSCParent.userName + @"\SafetyCopies\");
                                    safetyCopyFolder = SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + SBSCParent.userName + @"\SafetyCopies\";
                                }
                                else if (assignedTo != "" && filestatus == FileStatus.ReviewInputComplete)
                                {
                                    if (!Directory.Exists(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\SafetyCopies\"))
                                        System.IO.Directory.CreateDirectory(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\SafetyCopies\");
                                    safetyCopyFolder = SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\SafetyCopies\";
                                }
                                else safetyCopyFolder = SBSCParent.basePath + FilePaths.PATH_SafetyCopies;
                                /***************************************************************************
                                 * Check if the file is corrupt, if not update the safety copy
                                 ***************************************************************************/
                                try
                                {
                                    iTextSharp.text.Document document = new iTextSharp.text.Document(PageSize.LETTER);
                                    PdfReader reader = new PdfReader(fileLocation + fname);

                                    PdfWriter writer = PdfWriter.GetInstance(document, new FileStream(safetyCopyFolder + testFile, FileMode.Create));
                                    document.Open();

                                    PdfContentByte cb = writer.DirectContent;
                                    int pages = reader.NumberOfPages;

                                    for (int i = 0; i < pages;)
                                    {
                                        document.NewPage();
                                        PdfImportedPage page = writer.GetImportedPage(reader, ++i);
                                        cb.AddTemplate(page, 0, 0);
                                    }
                                    document.Close();

                                    System.IO.File.Copy(fileLocation + fname, safetyCopyFolder + fname, true);
                                }
                                catch
                                {
                                    r = MessageBox.Show("This file is corrupted! Do you want to restore with the last backup of this file?", "File Corrupted!", MessageBoxButtons.YesNo);

                                    if (r == DialogResult.Yes)
                                        if (System.IO.File.Exists(safetyCopyFolder + fname) && filestatus != FileStatus.ReviewInputComplete)
                                            System.IO.File.Copy(safetyCopyFolder + fname, fileLocation + fname, true);
                                        else
                                            if (assignedTo != "" && System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\SafetyCopies\" + fname))
                                            System.IO.File.Copy(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\SafetyCopies\" + fname, fileLocation + fname, true);
                                        else
                                        {
                                            r = MessageBox.Show("Safety backup copy for this file can not be found! Do you want to get a fresh copy from Archive?", "Missing Safety Copy!", MessageBoxButtons.YesNo);
                                            if (r == DialogResult.Yes)
                                                if (System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_Archive + fname))
                                                    System.IO.File.Copy(SBSCParent.basePath + FilePaths.PATH_Archive + fname, fileLocation + fname, true);
                                                else MessageBox.Show("Unable to find a safety copy for this file!");
                                        }
                                }

                                if (System.IO.File.Exists(safetyCopyFolder + testFile))
                                    System.IO.File.Delete(safetyCopyFolder + testFile);
                            }

                            Process.Start(path);
                            SBSCParent.fileOpen = true;
                            /*---------------------------------------------------------				      
                             * if a file with status assignedInput is opened, prompt the
                             * user if they want to mark the file as InputStarted.
                             *---------------------------------------------------------*/

                            if (filestatus == FileStatus.assignedInput)
                            {
                                r = MessageBox.Show("Do you want to change the status of " + fname + " to 'Input Started'?", "Message", MessageBoxButtons.YesNo);

                                if (r == DialogResult.Yes)
                                {
                                    filestatus = FileStatus.inputStarted;
                                    WORKFLOW.InputBatches.InputBatchesSave(SBSCParent.connSpedmon, fname, clientID, dateSent, null, fileLoc, WinFormsCommon.IsNull(partial), parentID,
                                                                           workType, oldDOS, WinFormsCommon.IsNull(estinputhrs), SBSCParent.userID.ToString(), assignedID, priority,
                                                                           difficulty, filestatus.ToString(), notes, null, "0", "2", recID);
                                    refreshView = true;
                                }
                            }
                        }
                        else MessageBox.Show("File is in use!");
                    }
                    else MessageBox.Show("File not be found!");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        /***************************************************************************
         * Refreshes the datagrid and restores the sort order and selected rows.
         ***************************************************************************/
        private void viewbutton_Click(object sender, EventArgs e)
        {

            string user = WinFormsCommon.IsNull(userscomboBox.SelectedValue);
            string fileloc = "";

            if (SBSCParent.isInputStaff)
            {
                user = SBSCParent.userID.ToString();
                fileloc = SBSCParent.PATH_WorkingFolder;
            }

            WinFormsCommon.loadDataGrid(ref dataGridView1, 15, 20,
                                         delegate
                                         {
                                             return WORKFLOW.InputBatches.InputBatchesView(SBSCParent.connSpedmon, "", fileloc,
                                                  WinFormsCommon.IsNull(typecomboBox.SelectedValue),
                                                  WinFormsCommon.IsNull(statuscomboBox.SelectedValue),
                                                  WinFormsCommon.IsNull(clientcomboBox.SelectedValue),
                                                  user, "", "1", "");
                                         });

        }

        private void InputBatchesView_Activated(object sender, EventArgs e)
        {
            /***************************************************************************
             * Refreshes the datagrid when the form is activated.
             ***************************************************************************/
            if (SBSCParent.refreshIBView)
            {
                SBSCParent.refreshIBView = false;
                viewbutton_Click(sender, e);
                avblradioButton_CheckedChanged(sender, e);

                if (dataGridView1.SelectedRows.Count == 0)
                    avblStaffcomboBox.SelectedIndex = 0;
            }
        }

        public static InputBatchesEdit editForm;
        /***************************************************************************
         * Handles Opening the pdf file and edit form for input batches.
         ***************************************************************************/
        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            if (dataGridView1.SelectedRows.Count != 0)
            {
                if (e.ColumnIndex == 0)
                {
                    openFile();
                    if (refreshView) viewbutton_Click(sender, e);
                    refreshView = false;
                }

                if (e.ColumnIndex == 1)
                {
                    GetFileAttributes(0);
                    if (filestatus == FileStatus.QuestionFormToPrac)
                        MessageBox.Show("File info can not be changed since it is already sent to practitioner!");
                    else
                    {
                        editForm = InputBatchesEdit.GetChildInstance();
                        editForm.MdiParent = this.ParentForm;
                        editForm.fileID = Convert.ToInt64(recID);
                        editForm.Show();
                        editForm.BringToFront();
                    }
                }
            }
        }

        /***************************************************************************
         * Clears the drop downs.
         ***************************************************************************/
        private void clearbutton_Click(object sender, EventArgs e)
        {
            statuscomboBox.SelectedIndex = 0;
            clientcomboBox.SelectedIndex = 0;
            userscomboBox.SelectedIndex = 0;
            typecomboBox.SelectedIndex = 0;
            viewbutton_Click(sender, e);
        }

        /***************************************************************************
         * Handles split file functionality.
         ***************************************************************************/
        public SplitFile splitForm;
        private void splitbutton_Click(object sender, EventArgs e)
        {
            if (dataGridView1.SelectedRows.Count == 1)
            {
                GetFileAttributes(0);
                if (filestatus <= FileStatus.Retrain)
                {
                    r = DialogResult.Cancel;
                    r = MessageBox.Show("You are going to split the file " + fname + ".", "Split File", MessageBoxButtons.OKCancel);

                    if (r == DialogResult.OK)
                        if (System.IO.File.Exists(fileLocation + fname))
                        {
                            splitForm = SplitFile.GetChildInstance();

                            //Close the old Split form if any and get fresh form. 
                            if (splitForm.fname != null)
                            {
                                splitForm.Dispose();
                                splitForm = SplitFile.GetChildInstance();
                            }

                            /*---------------------------------------------------------				      
                             * get the file info before opening the split form.
                             *---------------------------------------------------------*/

                            splitForm.fname = fname;
                            splitForm.assignedTo = assignedTo;
                            splitForm.assignedID = assignedID;
                            splitForm.recID = recID;
                            splitForm.workType = workType;
                            splitForm.oldDOS = oldDOS;
                            splitForm.priority = priority;
                            splitForm.difficulty = difficulty;
                            splitForm.fileLocation = fileLocation;
                            splitForm.fileLoc = fileLoc;
                            splitForm.filestatus = filestatus;
                            splitForm.dateRecieved = dateRecieved;
                            splitForm.estTime = estinputhrs;

                            splitForm.ShowDialog();
                            if (SBSCParent.refreshIBView) viewbutton_Click(sender, e);
                        }
                        else MessageBox.Show("File not found!");
                }
                else
                    MessageBox.Show("File can not be split with current status!");
            }
            else
                MessageBox.Show("Please select a single file to split!");

        }
        /***************************************************************************
         * Gets the selected Input Batch record column values in the datagrid.
         ***************************************************************************/
        private void GetFileAttributes(int row)
        {
            if (dataGridView1.SelectedRows.Count >= 1)
            {
                dgvRow = dataGridView1.SelectedRows[row];
                fname = dgvRow.Cells["FileName"].Value.ToString();
                clientID = dgvRow.Cells["ClientID"].Value.ToString();
                dateSent = dgvRow.Cells["DateOnFile"].Value.ToString();
                dateRecieved = dgvRow.Cells["DateRecieved"].Value.ToString();
                assignedTo = dgvRow.Cells["AssignedTo"].Value.ToString();
                assignedID = dgvRow.Cells["User2"].Value.ToString();
                prescreenededBy = dgvRow.Cells["User1"].Value.ToString();
                recID = dgvRow.Cells["id"].Value.ToString();
                workType = dgvRow.Cells["WorkTypeID"].Value.ToString();
                oldDOS = dgvRow.Cells["OldestDateOfService"].Value.ToString();
                if (oldDOS != string.Empty)
                    oldDOS = Convert.ToDateTime(oldDOS).ToShortDateString();
                priority = dgvRow.Cells["Priority"].Value.ToString();
                difficulty = dgvRow.Cells["Difficulty"].Value.ToString();
                fileLocation = SBSCParent.basePath + dgvRow.Cells["FileLocation"].Value.ToString();
                fileLoc = dgvRow.Cells["FileLocation"].Value.ToString();
                filestatus = Convert.ToInt16(dgvRow.Cells["StatusCode"].Value);
                fileStatusName = dgvRow.Cells["Status"].Value.ToString();
                partial = dgvRow.Cells["PartialFile"].Value.ToString();
                estinputhrs = dgvRow.Cells["EstimatedHours"].Value.ToString();
                clientShortName = dgvRow.Cells["Client"].Value.ToString();
                clientCDS = dgvRow.Cells["CLIENT_CDS"].Value.ToString();
                notes = dgvRow.Cells["Notes"].Value.ToString();
                parentID = dgvRow.Cells["ParentBatchID"].Value.ToString();
                if (estinputhrs == "") estinputhrs = "0";

                //if the file is a question form allow the user to view Practitioner reviews 
                if (fname.Contains("Qform") && (filestatus == FileStatus.QuestionFormToAnI || filestatus == FileStatus.ReviewQuestionForm))
                    editPracRevbutton.Show();
                else
                    editPracRevbutton.Hide();
                //if Info request response record exists then show Info request response form
                sql = "select count(*) from dbo.INFO_REQUEST_RESPONSE where ReferenceID = @batchID and status != 99";
                parms.Clear();
                object vBatchID = MBA.Validate.reqInteger(recID, "", true);
                parms.Add(Database.SqlParm("@batchID", SqlDbType.BigInt, vBatchID, ParameterDirection.Input));
                if (Convert.ToInt16(WinFormsCommon.execScalar(SBSCParent.connUsers, sql, parms)) > 0 || filestatus == FileStatus.ReviewQuestionForm || fname.Contains("Qform"))
                    editQuestionsbutton.Show();
                else editQuestionsbutton.Hide();
            }
            else MessageBox.Show("Please select a InputBatch!");
        }

        /***************************************************************************
         * Deletes a Inputbatch record by moving the file to the Deleted Files folder.
         * If the file is assigned to the staff deletes the file from the corresponding 
         * staff's workingfiles folder and safety copies folder
         ***************************************************************************/
        private void deletebutton_Click(object sender, EventArgs e)
        {
            if (dataGridView1.SelectedRows.Count != 0)
            {
                try
                {
                    int i = 0;
                    refreshView = false;
                    bool delete = false;
                    foreach (DataGridViewRow dgvRow in dataGridView1.SelectedRows)
                    {
                        GetFileAttributes(i);
                        r = DialogResult.OK;
                        if (filestatus == FileStatus.assignedInput)
                            r = MessageBox.Show("File is currently assigned to input, do you still want to delete this file?", "Delete File", MessageBoxButtons.OKCancel);
                        if (r == DialogResult.OK)
                        {
                            r = MessageBox.Show("Are you sure you want to delete this file " + fname + "?", "Delete File", MessageBoxButtons.OKCancel);
                            if (r == DialogResult.OK)
                            {
                                notes = Microsoft.VisualBasic.Interaction.InputBox("Enter reason for delete", "File Delete", "", 183, 308);
                                delete = true;
                                if (System.IO.File.Exists(fileLocation + fname))
                                {
                                    if (!WinFormsCommon.FileInUse(fileLocation + fname))
                                    {
                                        delete = true;
                                        if (SBSCParent.OK_TO_MANAGE_FILES)
                                        {
                                            if (System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_Deleted + fname)) System.IO.File.Delete(SBSCParent.basePath + FilePaths.PATH_Deleted + fname);
                                            System.IO.File.Move(fileLocation + fname, SBSCParent.basePath + FilePaths.PATH_Deleted + fname);
                                        }
                                    }
                                    else
                                    {
                                        MessageBox.Show("Please close " + fname + " and try again!");
                                        delete = false;
                                    }
                                }
                                if (delete)
                                {
                                    //delete safety copies
                                    if (SBSCParent.OK_TO_MANAGE_FILES)
                                    {
                                        if (System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_SafetyCopies + fname)) System.IO.File.Delete(SBSCParent.basePath + FilePaths.PATH_SafetyCopies + fname);

                                        if (assignedTo != "" && System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\SafetyCopies\" + fname))
                                            System.IO.File.Delete(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\SafetyCopies\" + fname);
                                    }

                                    WORKFLOW.InputBatches.InputBatchesdelete(SBSCParent.connSpedmon, notes, "0", recID, FilePaths.PATH_Deleted, SBSCParent.userID.ToString());
                                    refreshView = true;
                                    notes = "";
                                }
                            }
                        }
                        i += 1;
                    }
                    if (refreshView) viewbutton_Click(sender, e);
                }
                catch (Exception ex)
                { MessageBox.Show(ex.Message); }
            }
            else
                MessageBox.Show("Please select a file to delete!");
        }

        /***************************************************************************
         * if exists, deletes the training record and the staff schedule created by the user.
         ***************************************************************************/
        private void InputBatchesView_FormClosing(object sender, FormClosingEventArgs e)
        {
            SBSCParent.refreshIBView = true;
            Process.GetCurrentProcess().Close();
            //delete reports if created
            try
            {
                if (System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_Training_Record + "Training_Record_" + SBSCParent.userName + ".xls"))
                    System.IO.File.Delete(SBSCParent.basePath + FilePaths.PATH_Training_Record + "Training_Record_" + SBSCParent.userName + ".xls");

                if (System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_Staff_Schedule + "Staff_Schedule_" + SBSCParent.userName + ".xls"))
                    System.IO.File.Delete(SBSCParent.basePath + FilePaths.PATH_Staff_Schedule + "Staff_Schedule_" + SBSCParent.userName + ".xls");
            }
            catch
            {
            }
        }

        /***************************************************************************
         * Replaces the selected file from safety copies folder,
         * If the file is Input complete and Work leader is restoring the file it will
         * be restored from the staff's safety copies so all the markups will be not be erased. 
         ***************************************************************************/
        private void restorebutton_Click(object sender, EventArgs e)
        {
            if (dataGridView1.SelectedRows.Count != 0)
            {
                r = DialogResult.Yes;
                GetFileAttributes(0);
                if (!WinFormsCommon.FileInUse(fileLocation + fname))
                {
                    r = MessageBox.Show("Are you sure to restore " + fname + " from safety copies?", "Message", MessageBoxButtons.YesNo);
                    if (r == DialogResult.Yes)
                    {
                        string safetyCopyFolder;

                        if (SBSCParent.isInputStaff || assignedTo == SBSCParent.userName)
                            safetyCopyFolder = SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + SBSCParent.userName + @"\SafetyCopies\";
                        else
                            safetyCopyFolder = SBSCParent.basePath + FilePaths.PATH_SafetyCopies;

                        bool restored = false;

                        if (SBSCParent.OK_TO_MANAGE_FILES)
                        {
                            if (filestatus != FileStatus.ReviewInputComplete && System.IO.File.Exists(safetyCopyFolder + fname))
                            {
                                System.IO.File.Copy(safetyCopyFolder + fname, fileLocation + fname, true);
                                restored = true;
                            }
                            else
                                if (assignedTo != "" && System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\SafetyCopies\" + fname))
                            {
                                System.IO.File.Copy(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\SafetyCopies\" + fname, fileLocation + fname, true);
                                restored = true;
                            }
                            else
                            {
                                r = MessageBox.Show("Can not find Safety copy! Do you want to replace it with a fresh copy from Archive?", "Message", MessageBoxButtons.YesNo);
                                if (r == DialogResult.Yes)
                                    if (System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_Archive + fname))
                                    {
                                        System.IO.File.Copy(SBSCParent.basePath + FilePaths.PATH_Archive + fname, fileLocation + fname, true);
                                        restored = true;
                                    }
                                    else
                                        MessageBox.Show("Safety copy for this file can not be found in archive, please contact your Work leader or system administrator for help.");
                            }
                        }
                        if (restored) MessageBox.Show("File restored!");
                    }
                }
                else MessageBox.Show("Please close " + fname + " and try again! File can not be restored when it is open.");
            }
            else
                MessageBox.Show("Please select a file to Restore!");
        }

        /***************************************************************************
         * Attaches the selected file in the datagridview to the email 
         ***************************************************************************/
        private void attachFilebutton_Click(object sender, EventArgs e)
        {

            if (SBSCParent.emailForm == null || SBSCParent.emailForm.IsDisposed)
            {
                MessageBox.Show("Please open a Email form to attach file!");
            }
            else
                if (dataGridView1.SelectedRows.Count != 0)
            {
                try
                {
                    string message = "";
                    int i = 0;
                    foreach (DataGridViewRow dgvRow in dataGridView1.SelectedRows)
                    {
                        GetFileAttributes(i);
                        bool attach = true;
                        if (!System.IO.File.Exists(fileLocation + fname))
                            if (System.IO.File.Exists(fileLocation + fname.Substring(0, fname.Length - 3) + "pdf"))
                                fname = fname.Substring(0, fname.Length - 3) + "pdf";
                            else
                            {
                                message = message + fname + " not found. ";
                                attach = false;
                            }
                        //Check if the file has already been attached
                        foreach (string file in SBSCParent.emailForm.attachments)
                            if (file.Contains(fname)) attach = false;

                        if (attach)
                        {

                            SBSCParent.emailForm.attachments.Add(fileLocation + fname);
                            SBSCParent.emailForm.fileAttachments.Add(fname);

                            attach = false;
                        }
                        i += 1;
                    }
                    if (message != "") MessageBox.Show(message);
                    SBSCParent.emailForm.BringToFront();
                }
                catch { }
            }
            else MessageBox.Show("Please select a batch file to attach to the email form!");
        }

        // Destination path of the file or files that are being modified
        private string destinationPath = "";
        private PractitionerReview pracReview;
        private StaffReview staffReview;
        private InfoRequestResponseForm QuestionsForm;
        /***************************************************************************
         * Updates the file status to the selected status and moves the file accordingly.
         ***************************************************************************/
        private void changeStatusbutton_Click(object sender, EventArgs e)
        {
            //variables for sending Qform link
            string msg = "";
            string[] emailTo = new string[1];
            string[] emailCc = new string[1];
            string emailTittle = "";
            string toUserID = "";
            object vIrrID = "";
            List<string> attachments = new List<string>();

            if (dataGridView1.SelectedRows.Count > 1 && changeStatuscomboBox.SelectedIndex != 0 && Convert.ToInt16(changeStatuscomboBox.SelectedValue) == FileStatus.ReadytoAssign)
                MessageBox.Show("Unable to process your request! To mark file as Batched (Ready to Assign) we should enter Estimated input hours and Oldest date of service for each file individually!");
            else
                if (changeStatuscomboBox.SelectedIndex != 0 && dataGridView1.SelectedRows.Count != 0)
            {
                try
                {
                    int i = 0;
                    refreshView = false;

                    //loop through each row in selected rows and make changes.
                    foreach (DataGridViewRow dgvRow in dataGridView1.SelectedRows)
                    {
                        GetFileAttributes(i);
                        bool update = true;
                        r = DialogResult.Yes;
                        destinationPath = "";

                        if (filestatus != Convert.ToInt16(changeStatuscomboBox.SelectedValue) || filestatus == FileStatus.ReadytoAssign)
                            switch (Convert.ToInt16(changeStatuscomboBox.SelectedValue))
                            {
                                case (FileStatus.FinishedClaims):
                                    {
                                        if (!WinFormsCommon.FileInUse(fileLocation + fname))
                                        {
                                            if (filestatus != FileStatus.ReviewInputComplete && filestatus != FileStatus.ReviewStarted)
                                                r = MessageBox.Show(fname + " status is not Entered to Review - Input Complete or Work leader Review started! Do you still want to move this file to Finished work folder?",
                                                                     "Work Complete?", MessageBoxButtons.YesNo);
                                            else
                                                r = MessageBox.Show("Are you sure to move " + fname + " to Finished work Folder?", "Finished Work?", MessageBoxButtons.YesNo);
                                            destinationPath = FilePaths.PATH_FinishedClaims;
                                            filestatus = FileStatus.FinishedClaims;
                                        }
                                        else
                                        {
                                            MessageBox.Show("File can not be moved to Finished work folder when the file is open! Please Close " + fname + " and try again.");
                                            r = DialogResult.No;
                                        }
                                    }
                                    break;
                                case (FileStatus.NonBillableToAnI):
                                    {
                                        if (!WinFormsCommon.FileInUse(fileLocation + fname))
                                        {
                                            if (filestatus != FileStatus.assignedInput && filestatus != FileStatus.inputStarted && filestatus != FileStatus.ReviewInputComplete)
                                                r = MessageBox.Show("Are you sure to move " + fname + " to 'Not Billable Files From MBA to Give to District Representatives' Folder?", "Non-Billable?", MessageBoxButtons.YesNo);
                                            else r = MessageBox.Show(fname + " is currently assigned, are you sure to move this file to Not Billable Files From MBA to Give to District Representatives' folder?",
                                                                     "Non-Billable?", MessageBoxButtons.YesNo);

                                            destinationPath = FilePaths.PATH_NotBillableForms;
                                            filestatus = FileStatus.NonBillableToAnI;
                                        }
                                        else
                                        {
                                            MessageBox.Show("File can not be moved to A&I folder when the file is open! Please Close " + fname + " and try again.");
                                            r = DialogResult.No;
                                        }
                                    }
                                    break;
                                case (FileStatus.QuestionFormToAnI):
                                    {
                                        if (!WinFormsCommon.FileInUse(fileLocation + fname))
                                        {
                                            if (partial == "True")
                                            {
                                                if (filestatus != FileStatus.assignedInput && filestatus != FileStatus.inputStarted)
                                                    r = MessageBox.Show("Are you sure to move " + fname + " to Question Forms From MBA to Give to District Representatives Folder?", "Q-Form?", MessageBoxButtons.YesNo);
                                                else r = MessageBox.Show(fname + " is currently assigned, are you sure to move this file to Question Forms From MBA to Give to District Representatives Folder?", "Q-Form?", MessageBoxButtons.YesNo);


                                                if (r == DialogResult.Yes)
                                                {
                                                    if (filestatus == FileStatus.ReviewQuestionForm || (fname.Contains("Qform") && filestatus == FileStatus.ReviewInputComplete))
                                                        r = MessageBox.Show("Do you want to edit practitioner reviews?", "Edit Practitioner Reviews?", MessageBoxButtons.YesNo);
                                                    /***************************************************************************
                                                     * opens a form to enter review about the practitioner
                                                     ***************************************************************************/
                                                    if (r == DialogResult.Yes)
                                                    {
                                                        pracReview = PractitionerReview.GetChildInstance();
                                                        pracReview.clientID = clientID;
                                                        pracReview.inputBatchID = recID;
                                                        pracReview.status = FileStatus.QuestionFormToAnI.ToString();
                                                        pracReview.fname = fname;
                                                        pracReview.fileLocation = fileLocation;
                                                        pracReview.ShowDialog();
                                                    }
                                                    r = DialogResult.Yes;
                                                }

                                                destinationPath = FilePaths.PATH_QuestionForms;
                                                filestatus = FileStatus.QuestionFormToAnI;
                                            }
                                            else
                                            {
                                                MessageBox.Show("Please use Split file method to mark the entire file as Qform, select all the pages and delete the original file after splitting!");
                                                r = DialogResult.No;
                                            }
                                        }
                                        else
                                        {
                                            MessageBox.Show("File can not be moved to A&I folder when it is open! Please Close " + fname + " and try again!");
                                            r = DialogResult.No;
                                        }
                                    }
                                    break;
                                case (FileStatus.QuestionFormToPrac):
                                    {  /***************************************************************************
                                            * The questions will be emailed to the practitioner or rep when the file is changed to this status
                                            * we have to check the following before making this change
                                            * 1. File should not be open as the program has to move the file from one location to another                                           
                                            * 2. Make sure there is atleast one active row in dbo.INFO_REQUEST_RESPONSE_DETAILS, 
                                            *    to prevent emailing an empty Qform link to the practitioner.   
                                            ***************************************************************************/
                                        if (!WinFormsCommon.FileInUse(fileLocation + fname))
                                        {
                                            if (partial == "True")
                                            {
                                                if (filestatus != FileStatus.assignedInput && filestatus != FileStatus.inputStarted)
                                                    r = MessageBox.Show("Are you sure to mark " + fname + " as Question Form ?", "Q-Form?", MessageBoxButtons.YesNo);
                                                else r = MessageBox.Show(fname + " is currently assigned, are you sure to mark this file as Question Form?", "Q-Form?", MessageBoxButtons.YesNo);


                                                //make sure the oldest date of service is not empty as we need this to figure out the school year
                                                if (oldDOS == "")
                                                {
                                                    MessageBox.Show("Please enter the Oldest date of service for this file before changing to this status.");
                                                    r = DialogResult.No;
                                                    break;
                                                }

                                                if (r == DialogResult.Yes)
                                                {
                                                    MessageBox.Show("Please close the file " + fname + " if it is open.", "Close file", MessageBoxButtons.OK);

                                                    sql = "select * from dbo.INFO_REQUEST_RESPONSE where ReferenceID = @batchID and Status = " + MBA.Constants.QFORM_STATE_NEW;
                                                    parms.Clear();
                                                    object vBatchID = MBA.Validate.reqInteger(recID, "", true);
                                                    parms.Add(Database.SqlParm("@batchID", SqlDbType.BigInt, vBatchID, ParameterDirection.Input));
                                                    ReturnDB rd = Database.execQuery(SBSCParent.connUsers, null, sql, false, parms);
                                                    dt = Database.convertReturnDBToDatatable(ref rd);

                                                    if (dt.Rows.Count == 1)
                                                    {
                                                        DataRow dr = dt.Rows[0];
                                                        string token = dr["Token"].ToString();
                                                        emailTittle = dr["Email_Tittle"].ToString();
                                                        string emailMsg = dr["Email_Msg"].ToString();
                                                        string irrID = dr["id"].ToString();
                                                        string toName = dr["To_Name"].ToString();
                                                        //Check if we have rows in dbo.INFO_REQUEST_RESPONSE_DETAILS table if not do not allow edit
                                                        sql = " select COUNT(*) from dbo.INFO_REQUEST_RESPONSE_DETAILS where InfoRequestResponseID = @irrID and active = 1";
                                                        parms.Clear();
                                                        vIrrID = MBA.Validate.optInteger(irrID, "", true);
                                                        parms.Add(Database.SqlParm("@irrID", SqlDbType.BigInt, vIrrID, ParameterDirection.Input));
                                                        int questionsCount = Convert.ToInt16(WinFormsCommon.execScalar(SBSCParent.connUsers, sql, parms));

                                                        if (questionsCount > 0 && dr["Status"].ToString() != MBA.Constants.QFORM_STATE_ANSWERED)
                                                        {
                                                            //get the server name to create the link
                                                            string servername = ConfigurationManager.AppSettings["serverName"].ToString();

                                                            emailTo = WinFormsCommon.splitString(dr["Email_To"].ToString());
                                                            emailCc = WinFormsCommon.splitString(dr["Email_CC"].ToString());

                                                            toName = MBA.Util.nameCase(toName);
                                                            string lnk = MBA.HttpApplication.createLink(servername + MBA.Constants.APP_VDIR + "Questionform.aspx", new NameValue(MBA.Constants.PARM_QFTOKEN, token), new NameValue(MBA.Constants.PARM_QFORMMODE, "0"));
                                                            msg = MBA.Util.createMessageString(emailMsg, toName, lnk);

                                                            filestatus = FileStatus.QuestionFormToPrac;
                                                            destinationPath = FilePaths.PATH_WorkinProcess;
                                                        }
                                                        else
                                                        {
                                                            MessageBox.Show("The Questions form for this file is empty. Please fill the Questions and try again.");
                                                            r = DialogResult.No;
                                                        }
                                                    }
                                                    else
                                                    {
                                                        MessageBox.Show("The Questions form for this file is empty. Please fill the Questions and try again. /r/nIf you are marking the entire file as Qform, split the file by selecting all the pages and delete the original file after splitting!");
                                                        r = DialogResult.No;
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                MessageBox.Show("Please use Split file method to mark the entire file as Qform, select all the pages and delete the original file after splitting!");
                                                r = DialogResult.No;
                                            }

                                        }
                                        else
                                        {
                                            MessageBox.Show("File can not be moved to A&I folder when it is open! Please Close " + fname + " and try again!");
                                            r = DialogResult.No;
                                        }
                                    }
                                    break;
                                case (FileStatus.CIS):
                                    {
                                        if (!WinFormsCommon.FileInUse(fileLocation + fname))
                                        {
                                            if (filestatus != FileStatus.assignedInput && filestatus != FileStatus.inputStarted && filestatus != FileStatus.ReviewInputComplete)
                                                r = MessageBox.Show("Are you sure to move " + fname + " to CIS Folder?", "CIS?", MessageBoxButtons.YesNo);
                                            else r = MessageBox.Show(fname + " is currently assigned, are you sure to move this file to CIS Folder?", "CIS?", MessageBoxButtons.YesNo);

                                            destinationPath = FilePaths.PATH_CIS;
                                            filestatus = FileStatus.CIS;
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
                                        int prevStatus = filestatus;
                                        destinationPath = FilePaths.PATH_WorkinProcess;
                                        filestatus = FileStatus.ReadytoAssign;

                                        /***************************************************************************
                                         * If the file status is Finished,NB,Qforms or CIS and has been assigned before
                                         * then prompt the user if they want to re assign the file to same staff.
                                         ***************************************************************************/
                                        if (((prevStatus == FileStatus.FinishedClaims) || (prevStatus == FileStatus.NonBillableToAnI) ||
                                             (prevStatus == FileStatus.QuestionFormToAnI) || (prevStatus == FileStatus.CIS)))
                                        {
                                            r = MessageBox.Show(fname + " has been marked as " + fileStatusName + "! Do you want to mark this file as ReadytoAssign?", "Message", MessageBoxButtons.YesNo);
                                            if (r == DialogResult.Yes && assignedTo != "")
                                            {
                                                r = MessageBox.Show("Do you want to assign " + fname + " back to " + assignedTo + "?", "Reassign file?", MessageBoxButtons.YesNo);
                                                if (r == DialogResult.Yes)
                                                {
                                                    destinationPath = FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\WorkingFiles\";
                                                    filestatus = FileStatus.assignedInput;
                                                }
                                                else r = DialogResult.Yes;
                                            }
                                        }
                                        if (r == DialogResult.Yes)
                                        {
                                            if (saveDetails && (estInputnumericUpDown.Value > 0))
                                                estinputhrs = estInputnumericUpDown.Value.ToString();
                                            else estinputhrs = "0";

                                            if (saveDetails && oldDosdateTimePicker.Value < Convert.ToDateTime(dateSent))
                                                oldDOS = oldDosdateTimePicker.Value.ToShortDateString();
                                            else oldDOS = "";

                                            r = DialogResult.No;

                                            /***************************************************************************
                                             * check if the estimated hours and oldest date of service has been entered
                                             * if not do not let the update, these details are required
                                             * inorder to mark file as Batched(Ready to Assign).
                                             ***************************************************************************/

                                            if (Convert.ToDouble(estinputhrs) <= 0)
                                            {
                                                MessageBox.Show("Please enter Estimated Input hours!");
                                                break;
                                            }
                                            else if (oldDOS == "")
                                            {
                                                MessageBox.Show("Invalid Oldest date of service! Should be less than the date on file name");
                                                break;
                                            }
                                            else r = DialogResult.Yes;

                                            if (prevStatus == FileStatus.assignedInput && assignedTo != "")
                                            {
                                                r = MessageBox.Show("File is currently assigned to " + assignedTo + ". Do you want to unassign this file?", "UnAssign file?", MessageBoxButtons.YesNo);
                                                if (r == DialogResult.Yes) assignedTo = "";
                                            }
                                        }
                                    }
                                    break;
                                case (FileStatus.PrescreenPENDING):
                                    {
                                        if (filestatus != FileStatus.ReadytoBatch && filestatus != FileStatus.ReadytoAssign &&
                                            filestatus != FileStatus.QuestionFormToAnI && filestatus != FileStatus.NonBillableToAnI)
                                        {
                                            MessageBox.Show("File has been marked as " + fileStatusName + "! Can not change to this status.", "Warning!");
                                            r = DialogResult.No;
                                        }

                                        filestatus = FileStatus.PrescreenPENDING;
                                        destinationPath = FilePaths.PATH_WorkinProcess;
                                    }
                                    break;
                                case (FileStatus.ReviewInputComplete):
                                    {
                                        if (assignedID == null || assignedID == "" || fileLoc != FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\WorkingFiles\")
                                        {
                                            MessageBox.Show("Unable to process your request!  File is not assigned to Input.");
                                            update = false;
                                        }
                                        else
                                        {
                                            if (((filestatus == FileStatus.FinishedClaims) || (filestatus == FileStatus.NonBillableToAnI) ||
                                                 (filestatus == FileStatus.QuestionFormToAnI) || (filestatus == FileStatus.CIS)))
                                            {
                                                MessageBox.Show("File has been marked as " + fileStatusName + "! Can not change to this status.", "Warning!");
                                                r = DialogResult.No;
                                            }
                                            else
                                                r = MessageBox.Show("Are you sure to mark " + fname + " as Entered to Review - Input Complete?", "Entered to Review - Input Complete?", MessageBoxButtons.YesNo);

                                            filestatus = FileStatus.ReviewInputComplete;
                                        }
                                    }
                                    break;
                                case (FileStatus.ReviewQuestionForm):
                                    {
                                        if (((filestatus == FileStatus.FinishedClaims) || (filestatus == FileStatus.NonBillableToAnI) ||
                                              (filestatus == FileStatus.QuestionFormToAnI) || (filestatus == FileStatus.CIS)))
                                        {
                                            MessageBox.Show("File has been marked as " + fileStatusName + "! Can not change to this status.", "Warning!");
                                            r = DialogResult.No;
                                        }
                                        else
                                            r = MessageBox.Show("Are you sure to mark " + fname + " as Entered to Review - Question Form?", "Entered to Review - Question Form?", MessageBoxButtons.YesNo);

                                        filestatus = FileStatus.ReviewQuestionForm;
                                    }
                                    break;
                                case (FileStatus.ReviewNotBillable):
                                    {
                                        if (((filestatus == FileStatus.FinishedClaims) || (filestatus == FileStatus.NonBillableToAnI) ||
                                             (filestatus == FileStatus.QuestionFormToAnI) || (filestatus == FileStatus.CIS)))
                                        {
                                            MessageBox.Show("File has been marked as " + fileStatusName + "! Can not change to this status.", "Warning!");
                                            r = DialogResult.No;
                                        }
                                        else
                                            r = MessageBox.Show("Are you sure to mark " + fname + " as Entered to Review - Not Billable?", "Entered to Review - Not Billable?", MessageBoxButtons.YesNo);

                                        filestatus = FileStatus.ReviewNotBillable;
                                    }
                                    break;
                                case (FileStatus.Retrain):
                                    {
                                        if ((filestatus == FileStatus.ReviewInputComplete || filestatus == FileStatus.ReviewQuestionForm ||
                                             filestatus == FileStatus.ReviewNotBillable || filestatus == FileStatus.ReviewStarted)
                                             && assignedTo != "" && fileLoc == FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\WorkingFiles\")
                                        {
                                            r = MessageBox.Show("Are you sure to mark " + fname + " as Retrain?", "Retrain?", MessageBoxButtons.YesNo);
                                            /***************************************************************************
                                             * opens a form to enter review about the staff
                                             ***************************************************************************/
                                            if (r == DialogResult.Yes)
                                            {
                                                staffReview = StaffReview.GetChildInstance();
                                                staffReview.inputBatchID = recID;
                                                staffReview.staffID = assignedID;
                                                staffReview.staffName = assignedTo;
                                                staffReview.ShowDialog();
                                            }
                                        }
                                        else
                                        {
                                            MessageBox.Show("Unable to process your request! File is not marked as Entered to Review - Input Complete");
                                            update = false;
                                        }
                                        filestatus = FileStatus.Retrain;
                                    }
                                    break;
                                case (FileStatus.ReviewStarted):
                                    {
                                        if ((filestatus == FileStatus.ReviewInputComplete || filestatus == FileStatus.Retrain) && assignedTo != "")
                                            filestatus = FileStatus.ReviewStarted;
                                        else
                                        {
                                            MessageBox.Show("Unable to process your request!  File is not marked as Entered to Review - Input Complete.");
                                            update = false;
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
                                        else
                                        {
                                            if (filestatus != FileStatus.assignedInput &&
                                                filestatus != FileStatus.Retrain &&
                                                filestatus != FileStatus.ReviewQuestionForm &&
                                                filestatus != FileStatus.ReviewNotBillable &&
                                                filestatus != FileStatus.ReviewInputComplete)
                                                r = MessageBox.Show("File is marked as " + fileStatusName + ". Are you sure to assign this file back to " + assignedTo +
                                                                    " and mark file as Input started?", "Warning?", MessageBoxButtons.YesNo);
                                            else
                                                r = MessageBox.Show("File is marked as " + fileStatusName + ".Are you sure to mark this file as Input started?", "Warning?", MessageBoxButtons.YesNo);

                                            filestatus = FileStatus.inputStarted;
                                        }

                                    }
                                    break;

                                default:
                                    {
                                        MessageBox.Show("Sorry status can not be changed here! please use edit screen.");
                                        r = DialogResult.No;
                                    }
                                    break;
                            }
                        else r = DialogResult.No;

                        if (r == DialogResult.Yes)
                        {

                            if (SBSCParent.OK_TO_MANAGE_FILES)
                                if (fileLocation != SBSCParent.basePath + destinationPath && destinationPath != string.Empty)//&& System.IO.File.Exists(fileLocation + fname)
                                {
                                    update = WinFormsCommon.CanMoveFile(fileLocation, SBSCParent.basePath + destinationPath, fname);
                                    fileLoc = destinationPath;
                                }

                            if (update && Convert.ToInt16(changeStatuscomboBox.SelectedValue) == FileStatus.QuestionFormToPrac)
                            {
                                attachments.Add(SBSCParent.basePath + fileLoc + fname);
                                WinFormsCommon.emailFile(SBSCParent.smtpNoReply, SBSCParent.appQformEmailFrom, emailTo, emailCc, emailTittle, msg, attachments);

                                //update SentOn and status fields in Irr record after sending the email with link
                                sql = "update INFO_REQUEST_RESPONSE  set To_UserID = @toUserID, SentOn = getdate(), Status = " + MBA.Constants.QFORM_STATE_SENT + " where ID = @irrID";
                                parms.Clear();
                                object vToUserID = MBA.Validate.optInteger(toUserID, "", true);
                                parms.Add(Database.SqlParm("@toUserID", SqlDbType.BigInt, vToUserID, ParameterDirection.Input));
                                parms.Add(Database.SqlParm("@irrID", SqlDbType.BigInt, vIrrID, ParameterDirection.Input));
                                WinFormsCommon.execScalar(SBSCParent.connUsers, sql, parms);
                            }

                            if (update)
                            {
                                WORKFLOW.InputBatches.InputBatchesSave(SBSCParent.connSpedmon, fname, clientID, dateSent, null, fileLoc, WinFormsCommon.IsNull(partial), parentID,
                                                                        workType, oldDOS, WinFormsCommon.IsNull(estinputhrs), SBSCParent.userID.ToString(), assignedID, priority,
                                                                        difficulty, filestatus.ToString(), notes, null, "0", "2", recID);
                                refreshView = true;
                            }
                        }
                        i += 1;
                    }

                    if (refreshView)
                    {
                        RemoveSafetyCopies();
                        viewbutton_Click(sender, e);
                        changeStatuscomboBox.SelectedIndex = 0;
                        MessageBox.Show("Update Complete!");
                    }
                }
                catch (SqlException ex)
                { MessageBox.Show(ex.Message); }
            }
            else
            {
                MessageBox.Show("Please select a file and status!");
                changeStatuscomboBox.SelectedIndex = 0;
            }
        }

        /***************************************************************************
        * Deletes the safety copies when the file status changes to finished,Qform or NB
        ***************************************************************************/
        private void RemoveSafetyCopies()
        {
            if (filestatus == FileStatus.FinishedClaims || filestatus == FileStatus.NonBillableToAnI)
            {
                if (SBSCParent.OK_TO_MANAGE_FILES)
                {
                    if (System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_SafetyCopies + fname))
                        System.IO.File.Delete(SBSCParent.basePath + FilePaths.PATH_SafetyCopies + fname);

                    if (assignedTo != "" && System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\SafetyCopies\" + fname))
                        System.IO.File.Delete(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\SafetyCopies\" + fname);
                }
            }
        }

        private void assignbutton_Click(object sender, EventArgs e)
        {
            /***************************************************************************
             * Checks if the file has been done prescreening and
             * assigns the selected file or files to the selected staff.
             ***************************************************************************/
            if (dataGridView1.SelectedRows.Count != 0 && avblStaffcomboBox.SelectedIndex != 0)
            {
                int i = 0;
                refreshView = false;
                string assignedCurrent;

                /***************************************************************************
                 * Get only the staff's name from avblStaffcomboBox
                 ***************************************************************************/
                if (avblStaffcomboBox.Text.Contains("#"))
                    assignedCurrent = avblStaffcomboBox.Text.Substring(0, avblStaffcomboBox.Text.IndexOf("#") - 1);
                else assignedCurrent = avblStaffcomboBox.Text;

                foreach (DataGridViewRow dgvRow in dataGridView1.SelectedRows)
                {
                    GetFileAttributes(i);
                    if (System.IO.File.Exists(fileLocation + fname))
                        if (!WinFormsCommon.FileInUse(fileLocation + fname))
                        {
                            bool update = false;
                            r = DialogResult.Yes;
                            /***************************************************************************
                             * Warn the user if there is any work control flag on the file being assigned
                             ***************************************************************************/
                            sql = "select dbo.INPUT_BATCHES_WORK_CONTROL_CHECK(" + clientID + "," + workType + ")";
                            workControlNote = WinFormsCommon.execScalar(SBSCParent.connSpedmon, sql, null);
                            if (workControlNote != "")
                                r = MessageBox.Show(workControlNote + " \r\n" + "Do you want to continue assigning " + fname + " ?", "Workcontrol flag!", MessageBoxButtons.YesNo);
                            if (r == DialogResult.Yes)
                            {
                                if (System.IO.File.Exists(fileLocation + fname) && Convert.ToDecimal(estinputhrs) != 0 && oldDOS != "")
                                {
                                    /***************************************************************************
                                     * If the file status is Finished,NB,Qforms or CIS alert the user.
                                     ***************************************************************************/
                                    destinationPath = FilePaths.PATH_STAFF_FOLDER + assignedCurrent + @"\WorkingFiles\";

                                    if ((filestatus == FileStatus.FinishedClaims) || (filestatus == FileStatus.NonBillableToAnI) ||
                                                           (filestatus == FileStatus.QuestionFormToAnI) || (filestatus == FileStatus.CIS))
                                    {
                                        r = MessageBox.Show("File has been marked as " + fileStatusName + "! Do you still want to assign this file.", "Warning!", MessageBoxButtons.YesNo);

                                        if (r == DialogResult.Yes)
                                            destinationPath = FilePaths.PATH_STAFF_FOLDER + assignedCurrent + @"\WorkingFiles\";
                                    }

                                    if (assignedTo != "" && assignedTo != assignedCurrent && fileLocation == SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\WorkingFiles\")
                                    {
                                        r = MessageBox.Show("File is currently assigned to" + assignedTo + ", are you sure to assign it to " +
                                                             assignedCurrent + " ?", "Assign Work?", MessageBoxButtons.YesNo);
                                        //if yes then delete previously assigned staff's safety copy
                                        if (r == DialogResult.Yes && SBSCParent.OK_TO_MANAGE_FILES && System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\SafetyCopies\" + fname))
                                            System.IO.File.Delete(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\SafetyCopies\" + fname);
                                    }

                                    if (r == DialogResult.Yes)
                                    {
                                        /***************************************************************************
                                         * If the file is assigned to staff create a safety copy in safety copies folder.
                                         * if the staff doesn't have a folder in Staff folders create one
                                         ***************************************************************************/

                                        if (SBSCParent.OK_TO_MANAGE_FILES)
                                        {
                                            if (!Directory.Exists(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedCurrent + @"\") && assignedCurrent != "")
                                                System.IO.Directory.CreateDirectory(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedCurrent + @"\");

                                            if (!Directory.Exists(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedCurrent + @"\WorkingFiles\") && assignedCurrent != "")
                                                System.IO.Directory.CreateDirectory(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedCurrent + @"\WorkingFiles\");

                                            if (!Directory.Exists(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedCurrent + @"\SafetyCopies\") && assignedCurrent != "")
                                                System.IO.Directory.CreateDirectory(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedCurrent + @"\SafetyCopies\");
                                        }

                                        if (SBSCParent.OK_TO_MANAGE_FILES)
                                        {
                                            if (fileLocation != SBSCParent.basePath + destinationPath)
                                            {
                                                update = WinFormsCommon.CanMoveFile(fileLocation, SBSCParent.basePath + destinationPath, fname);

                                                if (assignedTo != "" && System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\SafetyCopies\" + fname))
                                                    System.IO.File.Delete(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\SafetyCopies\" + fname);

                                                //Create a safety copy
                                                if (!System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_SafetyCopies + fname))
                                                    System.IO.File.Copy(SBSCParent.basePath + destinationPath + fname, SBSCParent.basePath + FilePaths.PATH_SafetyCopies + fname, true);

                                                assignedID = avblStaffcomboBox.SelectedValue.ToString();

                                                filestatus = FileStatus.assignedInput;
                                                fileLoc = destinationPath;
                                            }
                                        }
                                        else
                                        {
                                            assignedID = avblStaffcomboBox.SelectedValue.ToString();
                                            filestatus = FileStatus.assignedInput;
                                            update = true;
                                        }

                                        if (update)
                                        {
                                            WORKFLOW.InputBatches.InputBatchesSave(SBSCParent.connSpedmon, fname, clientID, dateSent, null, fileLoc, WinFormsCommon.IsNull(partial), parentID,
                                                                                    workType, oldDOS, WinFormsCommon.IsNull(estinputhrs), SBSCParent.userID.ToString(), assignedID, priority,
                                                                                    difficulty, filestatus.ToString(), notes, null, "0", "2", recID);
                                            refreshView = true;
                                        }
                                    }
                                }
                                else MessageBox.Show("File is not Ready to Assign! Please enter estimated input hours and oldest date of service before Assigning work.");
                            }
                        }
                        else
                        {
                            MessageBox.Show("File can not be assigned when it is in use! Please Close " + fname + " and try again!");
                            r = DialogResult.No;
                        }
                    else MessageBox.Show("File not found!");

                    i += 1;
                }

                if (refreshView)
                {
                    viewbutton_Click(sender, e);
                    avblradioButton_CheckedChanged(sender, e);
                    MessageBox.Show("Update Complete!");
                }
            }
            else MessageBox.Show("Please select a file and a staff to Assign work");
        }

        private bool saveDetails = true;

        private void dataGridView1_SelectionChanged(object sender, EventArgs e)
        {
            /***************************************************************************
             * Allows updating the estimated input hours and oldest date of service 
             * for one batch at a time            
             ***************************************************************************/

            if (filled)
                if (dataGridView1.SelectedRows.Count != 1)
                {
                    estHrslabel.Hide();
                    estInputnumericUpDown.Hide();
                    oldDosdateTimePicker.Hide();
                    oldDoslabel.Hide();
                    saveDetails = false;
                    changeStatustextBox.Text = "";
                }
                else
                {
                    GetFileAttributes(0);
                    changeStatustextBox.Text = fname.Substring(0, fname.Length - 4);
                    estInputnumericUpDown.Value = Convert.ToDecimal(estinputhrs);
                    if (oldDOS != "") oldDosdateTimePicker.Value = Convert.ToDateTime(oldDOS);
                    else oldDosdateTimePicker.Value = DateTime.Now;
                    saveDetails = true;
                    allradioButton.Checked = true;
                    if (assignedTo != "") avblStaffcomboBox.SelectedValue = assignedID;
                    else avblStaffcomboBox.SelectedIndex = 0;
                }
        }

        private void changeStatuscomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            /***************************************************************************
             * let the user change the estimated input hours and oldest date of service
             * only when the selected status is Batched(Ready to Assign).
             ***************************************************************************/
            if (filled && changeStatuscomboBox.SelectedIndex != 0 &&
                Convert.ToInt16(changeStatuscomboBox.SelectedValue) == FileStatus.ReadytoAssign &&
                dataGridView1.SelectedRows.Count == 1)
            {
                GetFileAttributes(0);
                estHrslabel.Show();
                estInputnumericUpDown.Show();
                oldDosdateTimePicker.Show();
                DateTime olddos = Convert.ToDateTime(dateSent);
                oldDosdateTimePicker.Value = Convert.ToDateTime(olddos.Year.ToString() + "/" + olddos.Month.ToString() + "/" + "1");
                oldDoslabel.Show();
            }
            else
            {
                estHrslabel.Hide();
                estInputnumericUpDown.Hide();
                oldDosdateTimePicker.Hide();
                oldDoslabel.Hide();
            }
        }

        private void searchbutton_Click(object sender, EventArgs e)
        {
            /***************************************************************************
             * Searches the datagrid for a given filename and highlights the matching rows.
             ***************************************************************************/
            string searchFile = "";
            searchFile = Microsoft.VisualBasic.Interaction.InputBox("Enter all or part of the file name.", "Filename", "", 183, 308);
            searchFile = searchFile.ToLower();
            bool found = false;
            int i = 0;
            string filename;
            if (searchFile != "")
                foreach (DataGridViewRow row in dataGridView1.Rows)
                {
                    row.Selected = false;
                    filename = row.Cells["FileName"].Value.ToString().ToLower();

                    if (filename.Contains(searchFile))
                    {
                        row.Selected = true;
                        found = true;
                        dataGridView1.FirstDisplayedScrollingRowIndex = i;
                    }
                    i += 1;
                }
            if (!found && searchFile != "") MessageBox.Show("File not found!");
        }

        private void allradioButton_CheckedChanged(object sender, EventArgs e)
        {
            /***************************************************************************
             * Loads the combobox with all the staff names with or with out promised hours.
             ***************************************************************************/
            if (allradioButton.Checked)
            {
                sql = "select id,firstname+' '+lastname as name from dbo.USERS_DATA_CORE(dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null)  " +
                                  "where userGroupID = dbo.CONST_USER_GROUP_SBS() and roleID in (3,4) and id != 828 and id != 812 and " +
                                  "accountIsLockedOut = 0 order by firstname";
                WinFormsCommon.PopulateComboBox(SBSCParent.connUsers, sql, null, avblStaffcomboBox, "Staff", "name", "id", true, "");
            }
        }

        private void avblradioButton_CheckedChanged(object sender, EventArgs e)
        {
            /***************************************************************************
             * Fills the combobox with the staff names who has promised hours
             ***************************************************************************/
            if (avblradioButton.Checked)
            {

                if (d > 0) weekStartDate = DateTime.Now.AddDays((0 - d));
                if (nextweekcheckBox.Checked) weekStartDate = weekStartDate.AddDays(7);
                sql = "SELECT s.[STAFF_ID] as id,s.NAME+' # for '+WEEK_START+' Total:'+convert(varchar(10)," +
                      "sum([dayHOURS]))+', Assigned:'+convert(varchar(10),AssignedHours)+',Leftovers:'+convert(varchar(10),LEFTOVERS) as name " +
                      "from STAFF_PROMISED_HOURS_VIEW(null,null,'" + weekStartDate.Date.ToShortDateString() + "',null,null,null) as s " +
                      "join users.dbo.USERS_DATA_CORE(users.dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null) AS U on u.id = s.staff_id " +
                      "where u.roleID in (3,4) and u.id != 828 and u.id != 812 " +
                      "group by Staff_ID,s.NAME,WEEK_START,AssignedHours,leftovers having sum([dayHOURS])>0 order by week_start";

                WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql, null, avblStaffcomboBox, "Staff", "name", "id", true, "");
            }
            else allradioButton.Checked = true;
        }

        private bool istrnrecrpt;

        private void schedulebutton_Click(object sender, EventArgs e)
        {
            /***************************************************************************
             * Creates a copy of staff schedule in the staff training records folder 
             * this file will be deleted when the user exits the app.
             * Opens a report in an excel with the summary, details of promised hours of all staff
             * and details of each client's hours on hand,oldest recieved and oldest date of service
             ***************************************************************************/
            Process.GetCurrentProcess().Close();
            InitializeWorkbook();


            //Sheet with data from the Log file 
            HSSFSheet sheet1 = (HSSFSheet)hssfworkbook.CreateSheet("SUMMARY");

            DateTime lastFriday;
            double d1;
            IRow row;
            ICell cell;
            //determine the last friday's date
            lastFriday = DateTime.Now.AddDays(-2 - Convert.ToInt16(DateTime.Now.DayOfWeek));

            row = sheet1.CreateRow(0);
            cell = row.CreateCell(0);
            cell.SetCellValue("Summary for the week " + lastFriday.AddDays(-7).ToShortDateString() + " - " + lastFriday.ToShortDateString());

            row = sheet1.CreateRow(2);
            cell = row.CreateCell(0);
            cell.SetCellValue("TOTAL HOURS ON HAND AS OF " + lastFriday.ToShortDateString());

            cell = row.CreateCell(1);
            string sqlSummary = "select SUM(hoursonhand) as HoursOnHand from HOURS_ON_HAND(null,'" + lastFriday.ToShortDateString() + "')";
            string value = WinFormsCommon.execScalar(SBSCParent.connSpedmon, sqlSummary, null);
            double.TryParse(value, out d1);
            cell.SetCellValue(d1);

            row = sheet1.CreateRow(3);
            cell = row.CreateCell(0);
            cell.SetCellValue("TOTAL HOURS OF GOOD WORK RECIEVED");

            cell = row.CreateCell(1);
            sqlSummary = "select SUM(TotalThisWeek) as TotalThisWeek from RPT_WF_CLIENT_DETAILS_SUMMARY(null,'" + lastFriday.ToShortDateString() + "')";
            value = WinFormsCommon.execScalar(SBSCParent.connSpedmon, sqlSummary, null);
            double.TryParse(value, out d1);
            cell.SetCellValue(d1);

            row = sheet1.CreateRow(4);
            cell = row.CreateCell(0);
            cell.SetCellValue("TOTAL HOURS ASSIGNED");

            cell = row.CreateCell(1);
            sqlSummary = "select SUM(TotalHoursAssigned ) from hours_assigned(null,'" + lastFriday.ToShortDateString() + "')";
            value = WinFormsCommon.execScalar(SBSCParent.connSpedmon, sqlSummary, null);
            double.TryParse(value, out d1);
            cell.SetCellValue(d1);

            row = sheet1.CreateRow(5);
            cell = row.CreateCell(0);
            cell.SetCellValue("TOTAL LEFTOVER HOURS");

            cell = row.CreateCell(1);
            sqlSummary = "select sum(LeftoverHours) as leftovers from HOURS_LEFTOVER(null,'" + lastFriday.ToShortDateString() + "')";
            value = WinFormsCommon.execScalar(SBSCParent.connSpedmon, sqlSummary, null);
            double.TryParse(value, out d1);
            cell.SetCellValue(d1);

            sheet1.SetColumnWidth(0, 10000);

            HSSFSheet sheet2 = (HSSFSheet)hssfworkbook.CreateSheet("STAFF WEEKLY SCHEDULE");

            istrnrecrpt = false;

            string[] colHeadings = { "Staff Name", "Week Start", "Day", "Date", "Shift-1", "Shift-2", "Shift-3", "Total Day Hours", "Total Week Hours", "Total Assigned", "Leftovers", "Note" };

            if (d > 0) weekStartDate = DateTime.Now.AddDays((0 - d));
            if (nextweekcheckBox.Checked) weekStartDate = weekStartDate.AddDays(7);

            sql = "select NAME,WEEK_START,DAY,convert(char,DateOfDay,101),SHIFT_1,SHIFT_2,SHIFT_3,DAYHOURS,WEEKHOURS,ASSIGNEDHOURS,LEFTOVERS,NOTE " +
                  "from STAFF_PROMISED_HOURS_VIEW(null,null,'" + weekStartDate.Date.ToShortDateString() + "',null,null,null)";

            FillData(sql, sheet2, colHeadings, hssfworkbook);

            sheet2.GroupColumn(4, 6);
            sheet2.SetColumnWidth(0, 6000);
            sheet2.SetColumnWidth(1, 3000);
            sheet2.SetColumnWidth(2, 3000);
            sheet2.SetColumnWidth(3, 3000);
            sheet2.SetColumnWidth(4, 4500);
            sheet2.SetColumnWidth(5, 4500);
            sheet2.SetColumnWidth(6, 4500);
            sheet2.SetColumnWidth(7, 3000);
            sheet2.SetColumnWidth(8, 3000);
            sheet2.SetColumnWidth(9, 3000);
            sheet2.SetColumnWidth(10, 3000);
            sheet2.SetColumnWidth(11, 15000);

            HSSFSheet sheet3 = (HSSFSheet)hssfworkbook.CreateSheet("Client Details as of " + lastFriday.ToShortDateString().Replace("/", "-"));

            string[] colHeadings2 = { "Client Name", "ShortName - CDS", "DistrictRep", "Good Work recieved This Week", "Hours on Hand", "Oldest Date of Service", "Oldest Recieved Date" };

            sql = "Select * from RPT_WF_CLIENT_DETAILS_SUMMARY(null,'" + lastFriday.ToShortDateString() + "')";

            FillData(sql, sheet3, colHeadings2, hssfworkbook);

            sheet3.SetColumnWidth(0, 10000);
            sheet3.SetColumnWidth(1, 8000);
            sheet3.SetColumnWidth(2, 6000);
            sheet3.SetColumnWidth(3, 4000);
            sheet3.SetColumnWidth(4, 4000);
            sheet3.SetColumnWidth(5, 4000);
            sheet3.SetColumnWidth(6, 4000);

            try
            {
                System.IO.FileStream fs = System.IO.File.OpenWrite(SBSCParent.basePath + FilePaths.PATH_Staff_Schedule + "Staff_Schedule_" + SBSCParent.userName + ".xls");
                hssfworkbook.Write(fs);
                fs.Dispose();
                Process.Start(SBSCParent.basePath + FilePaths.PATH_Staff_Schedule + "Staff_Schedule_" + SBSCParent.userName + ".xls");
            }
            catch
            {
                MessageBox.Show("A weekly schedule is already open! please close it to open another weekly schedule.");
            }
        }

        static void InitializeWorkbook()
        {
            hssfworkbook = new HSSFWorkbook();
            //create a entry of DocumentSummaryInformation
            DocumentSummaryInformation dsi = PropertySetFactory.CreateDocumentSummaryInformation();
            dsi.Company = "NPOI Team";
            hssfworkbook.DocumentSummaryInformation = dsi;
            //create a entry of SummaryInformation
            SummaryInformation si = PropertySetFactory.CreateSummaryInformation();
            si.Subject = "NPOI SDK Example";
            hssfworkbook.SummaryInformation = si;
        }

        private void trnrecordbutton_Click(object sender, EventArgs e)
        {
            /***************************************************************************
             * Creates a copy of training record in the staff training records folder 
             * this file will be deleted when the user exits the app.
             * Opens a Training record and Audit report in excel. 
             * when ever a new work type
             * is added this methods needs to be changed, the column headings has to be updated
             * with the new work type
             ***************************************************************************/
            try
            {
                Process.GetCurrentProcess().Close();
                InitializeWorkbook();

                string[] colHeadings1 = {"Total Number of Tasks","Number of Tasks Trained","Total Number of Tasks NOT YET TRAINED","Percentage of Tasks Trained",
                                       "Staff Name","1:1 - One on One Aide","CN - Counselor","HA - Health Aide","HS - Health Services","LVN - Licensed Vocational Nurse",
                                       "LMFT - Marriage & Family Therapist","NPS - Non Public Schools or Agencies","RN - Nurse (Registered Nurse)",
                                       "OT - Occupational Therapist","PT - Physical Therapist","TCM - Program Specialist","PSY - Psychologist",
                                       "SW - Social Worker","SP - Speech Language Pathologist","Trans - Transportation","AUD - Audiology","Qforms"};


                sql = "select * from RPT_STAFF_TRAINING_RECORDS()";

                //Sheet with data from the Log file 
                HSSFSheet sheet1 = (HSSFSheet)hssfworkbook.CreateSheet("STAFF TRAINING RECORD");
                istrnrecrpt = true;
                FillData(sql, sheet1, colHeadings1, hssfworkbook);
                //sheet.GroupColumn(1, 2);           
                sheet1.SetColumnWidth(4, 6000);

                //sheet.CreateFreezePane(0, 1);  
                int[] range = new int[4] { 1, k - 4, 5, 20 };
                ConditionalFormat(range, "0.50", NPOI.HSSF.Util.HSSFColor.Red.Index, sheet1);
                range[2] = 3; range[3] = 3;
                ConditionalFormat(range, "60", NPOI.HSSF.Util.HSSFColor.Red.Index, sheet1);
                range[0] = k - 1; range[1] = k - 1; range[2] = 5; range[3] = 20;
                ConditionalFormat(range, "50", NPOI.HSSF.Util.HSSFColor.Red.Index, sheet1);

                HSSFSheet sheet2 = (HSSFSheet)hssfworkbook.CreateSheet("STAFF AUDIT REVIEW");
                sql = "select * from RPT_AUDIT_REVIEW()";
                string[] colHeadings2 = {"Staff Name","1:1 - One on One Aide","CN - Counselor","HA - Health Aide","HS - Health Services","LVN - Licensed Vocational Nurse",
                                       "LMFT - Marriage & Family Therapist","NPS - Non Public Schools or Agencies","RN - Nurse (Registered Nurse)",
                                       "OT - Occupational Therapist","PT - Physical Therapist","TCM - Program Specialist","PSY - Psychologist",
                                       "SW - Social Worker","SP - Speech Language Pathologist","Trans - Transportation","AUD - Audiology","Qforms"};
                FillData(sql, sheet2, colHeadings2, hssfworkbook);
                sheet2.SetColumnWidth(0, 6000);
                sheet2.SetColumnWidth(1, 4000);
                sheet2.SetColumnWidth(2, 4000);
                sheet2.SetColumnWidth(3, 4000);
                sheet2.SetColumnWidth(4, 4000);
                sheet2.SetColumnWidth(5, 4000);
                sheet2.SetColumnWidth(6, 4000);
                sheet2.SetColumnWidth(7, 4000);
                sheet2.SetColumnWidth(8, 4000);
                sheet2.SetColumnWidth(9, 4000);
                sheet2.SetColumnWidth(10, 4000);
                sheet2.SetColumnWidth(11, 4000);
                sheet2.SetColumnWidth(12, 4000);
                sheet2.SetColumnWidth(13, 4000);
                sheet2.SetColumnWidth(14, 4000);
                sheet2.SetColumnWidth(15, 4000);
                sheet2.SetColumnWidth(16, 4000);

                try
                {
                    System.IO.FileStream fs = System.IO.File.OpenWrite(SBSCParent.basePath + FilePaths.PATH_Training_Record + "Training_Record_" + SBSCParent.userName + ".xls");
                    hssfworkbook.Write(fs);

                    fs.Dispose();
                    Process.Start(SBSCParent.basePath + FilePaths.PATH_Training_Record + "Training_Record_" + SBSCParent.userName + ".xls");
                }
                catch
                {
                    MessageBox.Show("A Training record is already open! please close it to open another Training record.");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString());
            }
        }

        private void ConditionalFormat(int[] r, string formula, short colorIndex, HSSFSheet sheet)
        {
            /******************************************************************
             * Adds conditional formating to the range supplied in the array 'r'
             * with one rule,with the formula and colorIndex supplied
             ******************************************************************/
            ISheetConditionalFormatting hscf = sheet.SheetConditionalFormatting;
            IConditionalFormattingRule rule = hscf.CreateConditionalFormattingRule(ComparisonOperator.GreaterThan, formula, null);
            IPatternFormatting patternFmt = rule.CreatePatternFormatting();
            patternFmt.FillBackgroundColor = colorIndex;
            CellRangeAddress[] regions = { new CellRangeAddress(r[0], r[1], r[2], r[3]) };
            hscf.AddConditionalFormatting(regions, rule);
        }

        private void FormatStyle(ICellStyle style1, HSSFWorkbook hssfworkbook, short colorIndex, short fontsize, bool isbold, bool wrapText)
        {
            /******************************************************************
             * Special formating for column headings.
             ******************************************************************/
            IFont font = hssfworkbook.CreateFont();
            font.Color = colorIndex;
            if (isbold)
                font.Boldweight.Equals(FontBoldWeight.Bold);
            font.FontHeightInPoints = fontsize;
            font.FontName = "Times New Roman";
            style1.WrapText = wrapText;
            style1.SetFont(font);
            style1.DataFormat = HSSFDataFormat.GetBuiltinFormat("0.00");
        }

        ICellStyle style1;
        ICellStyle style2;
        ICellStyle style3;

        private void FillData(string sql, HSSFSheet sheet, string[] colHeadings, HSSFWorkbook hssfworkbook)
        {
            /******************************************************************
             * Fills the sheet with data from sql and adds basic formating.          
             ******************************************************************/
            try
            {
                SqlCommand comm = SBSCParent.connSpedmon.CreateCommand();
                comm.CommandType = CommandType.Text;
                comm.CommandText = sql;
                SqlDataReader dr = comm.ExecuteReader();

                //Style to apply for column headings              
                style1 = hssfworkbook.CreateCellStyle();
                style2 = hssfworkbook.CreateCellStyle();
                style3 = hssfworkbook.CreateCellStyle();

                FormatStyle(style1, hssfworkbook, NPOI.HSSF.Util.HSSFColor.Blue.Index, 14, true, true);

                style1.Alignment = NPOI.SS.UserModel.HorizontalAlignment.Center;
                FormatStyle(style2, hssfworkbook, NPOI.HSSF.Util.HSSFColor.Black.Index, 12, true, true);
                FormatStyle(style3, hssfworkbook, NPOI.HSSF.Util.HSSFColor.Blue.Index, 12, true, true);

                IRow row;
                // set the column headings for the sheet
                if (colHeadings != null)
                {
                    row = sheet.CreateRow(0);
                    if (istrnrecrpt)
                    {
                        style1.Rotation = 90;
                        row.Height = 3100;
                    }
                    else row.Height = 1100;
                    for (i = 0; i < colHeadings.Length; i++)
                    {
                        ICell cell = row.CreateCell(i);
                        cell.SetCellValue(colHeadings[i]);
                        cell.CellStyle = style1;
                    }
                }
                i = 0;
                k = 1;
                double d;

                /*------------------------------------------------------------------
                 * Go through each row in the data reader and copy them to the sheet
                 * Convert the string values from datareader into numeric values.
                 * This is needed to apply conditional formating and formulas.
                 *------------------------------------------------------------------*/
                if (dr.HasRows)
                {
                    while (dr.Read())
                    {
                        row = sheet.CreateRow(k);
                        if (sql == "select * from RPT_AUDIT_REVIEW()") row.Height = 1000;
                        else row.Height = 300;
                        for (i = 0; i < dr.VisibleFieldCount; i++)
                        {
                            ICell cell = row.CreateCell(i);
                            cell.SetCellValue(dr.GetValue(i).ToString());
                            if (double.TryParse(dr.GetValue(i).ToString(), out d))
                            {
                                sheet.GetRow(k).GetCell(i).SetCellValue(d);
                            }
                            if (istrnrecrpt && i == 4)
                                cell.CellStyle = style3;
                            else
                                cell.CellStyle = style2;
                        }
                        k = k + 1;
                    }
                }
                dr.Dispose();
                //sheet.DisplayZeros = false;
                sheet.HorizontallyCenter = true;
                dr.Dispose();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString());
            }
        }

        private void nextweekcheckBox_CheckedChanged(object sender, EventArgs e)
        {
            avblradioButton_CheckedChanged(sender, e);
        }

        /***************************************************************************
         * Renames the selected file by checking if the new file name name is in correct format
         ***************************************************************************/
        private void renamebutton_Click(object sender, EventArgs e)
        {
            if (dataGridView1.SelectedRows.Count != 0)
            {
                GetFileAttributes(0);
                string newfname;
                string fnameOriginal = fname;
                if (System.IO.File.Exists(fileLocation + fname))
                {
                    newfname = Microsoft.VisualBasic.Interaction.InputBox("Change file name.", "Filename", fname, 183, 308);
                    //Add the file extension if missing
                    if (newfname != "" && !newfname.ToLower().Contains(".pdf")) newfname = newfname + ".pdf";

                    /***************************************************************************
                     * If the file is renamed, update the file name in the Input Batches table also.
                     ***************************************************************************/
                    try
                    {
                        if (newfname != fnameOriginal && newfname != "" &&
                            WinFormsCommon.CheckFileName(SBSCParent.connSpedmon, newfname, ref dateSent, ref workType, ref clientID, ref clientCDS, ref clientShortName))
                        {
                            if (!WinFormsCommon.FileInUse(fileLocation + fname))
                            {
                                bool update = true;
                                if (System.IO.File.Exists(fileLocation + fnameOriginal))
                                {
                                    if (!System.IO.File.Exists(fileLocation + newfname))
                                    {
                                        if (SBSCParent.OK_TO_MANAGE_FILES)
                                        {
                                            System.IO.File.Move(fileLocation + fnameOriginal, fileLocation + newfname);

                                            //Rename the file in the safety copies folders.

                                            if (System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_SafetyCopies + fname) && !System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_SafetyCopies + newfname))
                                                System.IO.File.Move(SBSCParent.basePath + FilePaths.PATH_SafetyCopies + fnameOriginal, SBSCParent.basePath + FilePaths.PATH_SafetyCopies + newfname);

                                            if (assignedTo != "" && System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\SafetyCopies\" + fname) &&
                                                                   !System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\SafetyCopies\" + newfname))
                                                System.IO.File.Move(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\SafetyCopies\" + fnameOriginal,
                                                                    SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + assignedTo + @"\SafetyCopies\" + newfname);

                                            //Rename the file in the Archive folders.
                                            if (System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_Archive + fname) && !System.IO.File.Exists(SBSCParent.basePath + FilePaths.PATH_Archive + newfname))
                                                System.IO.File.Move(SBSCParent.basePath + FilePaths.PATH_Archive + fnameOriginal, SBSCParent.basePath + FilePaths.PATH_Archive + newfname);
                                        }
                                        else
                                            update = false;
                                    }
                                    else
                                    {
                                        MessageBox.Show("A file with the name " + newfname + " already exists! Please try again.");
                                        update = false;
                                    }
                                }
                                else
                                {
                                    MessageBox.Show("Can not find the file " + fname + "!");
                                    update = false;
                                }
                                if (update)
                                    try
                                    {
                                        WORKFLOW.InputBatches.InputBatchesSave(SBSCParent.connSpedmon, newfname, clientID, dateSent, dateRecieved, fileLoc,
                                                                    partial, parentID, workType, oldDOS, estinputhrs, SBSCParent.userID.ToString(), assignedID, priority, difficulty, filestatus.ToString(), notes, "", "0", "2", recID);
                                        viewbutton_Click(sender, e);
                                        MessageBox.Show("Finished renaming the file!");
                                    }
                                    catch (SqlException ex)
                                    { MessageBox.Show(ex.Message); }
                            }
                            else MessageBox.Show("Please close " + fname + " and try again!");
                        }
                        else
                            newfname = fnameOriginal;
                    }
                    catch (SqlException ex)
                    { MessageBox.Show(ex.Message); }
                }
                else MessageBox.Show(fname + " can not be found!");
            }
            else MessageBox.Show("Please select a file to Rename!");
        }

        /***************************************************************************
         * Opens a form to Edit or save practitioner's problems for a selected input batch
         ***************************************************************************/
        private void editPracRevbutton_Click(object sender, EventArgs e)
        {
            if (dataGridView1.SelectedRows.Count == 1)
            {
                GetFileAttributes(0);

                pracReview = PractitionerReview.GetChildInstance();
                pracReview.clientID = clientID;
                pracReview.inputBatchID = recID;
                pracReview.status = filestatus.ToString();
                pracReview.fname = fname;
                pracReview.fileLocation = fileLocation;
                pracReview.ShowDialog();
            }
            else MessageBox.Show("Please select a file to enter Practitioner review");
        }

        /***************************************************************************
         * Opens a form to Edit or save staff reviews for a selected input batch
         ***************************************************************************/
        private void editStaffRevbutton_Click(object sender, EventArgs e)
        {
            if (dataGridView1.SelectedRows.Count == 1)
            {
                GetFileAttributes(0);
                if (assignedID != "")
                {
                    staffReview = StaffReview.GetChildInstance();
                    staffReview.inputBatchID = recID;
                    staffReview.staffID = assignedID;
                    staffReview.staffName = assignedTo;
                    staffReview.ShowDialog();
                }
                else MessageBox.Show("Can not enter staff review when the file is not assigned!");
            }
            else MessageBox.Show("Please select a file to enter Staff review");
        }

        /***************************************************************************
         * Allows the user to change the priority of selected files, so the staff will know
         * which files to work on first.
         ***************************************************************************/
        private void prioritybutton_Click(object sender, EventArgs e)
        {
            if (dataGridView1.SelectedRows.Count != 0)
            {
                try
                {
                    int i = 0;
                    refreshView = false;
                    foreach (DataGridViewRow dgvRow in dataGridView1.SelectedRows)
                    {
                        GetFileAttributes(i);
                        WORKFLOW.InputBatches.InputBatchesSave(SBSCParent.connSpedmon, fname, clientID, dateSent, null, fileLoc, WinFormsCommon.IsNull(partial), parentID,
                                                               workType, oldDOS, WinFormsCommon.IsNull(estinputhrs), SBSCParent.userID.ToString(), assignedID,
                                                               prioritynumericUpDown.Value.ToString(), difficulty, filestatus.ToString(), notes, null, "0", "2", recID);
                        refreshView = true;

                        i += 1;
                    }
                    viewbutton_Click(sender, e);
                    MessageBox.Show("Update Complete!");
                }
                catch (SqlException ex)
                { MessageBox.Show(ex.Message); }
            }
            else
            {
                MessageBox.Show("No files are selected!");
                changeStatuscomboBox.SelectedIndex = 0;
            }
        }

        private void editQuestionsbutton_Click(object sender, EventArgs e)
        {
            if (dataGridView1.SelectedRows.Count == 1)
            {
                GetFileAttributes(0);
                QuestionsForm = InfoRequestResponseForm.GetChildInstance();
                QuestionsForm.QformID = recID;
                QuestionsForm.qformStatus = filestatus;
                QuestionsForm.clientID = clientID;
                QuestionsForm.qformName = fname;
                QuestionsForm.oldDOS = oldDOS;
                QuestionsForm.ShowDialog();
            }
            else MessageBox.Show("Please select a file");
        }

        /***************************************************************************
         * Adds a cover page to the file from the parent file
         ***************************************************************************/
        private void AddcoverPagebutton_Click(object sender, EventArgs e)
        {
            GetFileAttributes(0);

            string ParentFileName;

            sql = "select File_Location + File_Name from INPUT_BATCHES  where id = @batchID";
            parms.Clear();
            object vbatchID = MBA.Validate.optInteger(parentID, "", true);
            parms.Add(Database.SqlParm("@batchID", SqlDbType.BigInt, vbatchID, ParameterDirection.Input));
            ParentFileName = SBSCParent.basePath + WinFormsCommon.execScalar(SBSCParent.connSpedmon, sql, parms);
            //make sure the file is not kept open by the user
            MessageBox.Show("Please close the file if it is open.");

            r = DialogResult.No;
            r = MessageBox.Show("Do you want to add a cover page to this batch?", "Cover page", MessageBoxButtons.YesNo);

            if (r == DialogResult.Yes && !string.IsNullOrEmpty(parentID))
            {
                try
                {
                    string ParentPDF = ParentFileName;
                    string Qform = fileLocation + fname;

                    //Daniel please add your code here
                    if (SBSCParent.OK_TO_MANAGE_FILES)
                    {
                        pdfSplice(ParentPDF, 1, 1, Qform, 1, 0, Qform + "_tmerge");

                        System.IO.File.Delete(Qform);
                        System.IO.File.Move(Qform + "_tmerge", Qform);
                    }

                }
                catch (Exception ex) { MessageBox.Show(ex.Message); }

            }
        }


        /****************************************************
         * Splice two PDFs together on variable criteris 
         ****************************************************/

        private int pdfSplice(String file1Path, int file1StartPos, int file1PageCount, String file2Path, int file2StartPos, int file2PageCount, string destinationFile)
        {
            /* This uses call structures derived from http://stackoverflow.com/questions/4276019/itextsharp-pdfcopy-use-examples */

            /* Splices two PDFs together using a subset of the pages from each document, creating a new file (specified as destination argument). 
             * A page set for a file is defined as starting with the page in the StartPos argument and proceeding through the PDF for the specified count of pages.
             */

            /* Basic argument validation */

            if ((file1Path == destinationFile) || (file2Path == destinationFile))
            {
                throw new ArgumentException("pdfSplice() does simultaneous read-write & cannot write to an open source file.");
            }


            if ((file1StartPos < 1) || (file2StartPos < 1))
            {
                throw new ArgumentException("pdfSplice() does not take negative/zero values as starting position arguments.");
            }

            if ((file1PageCount < 0) || (file2PageCount < 0))
            {
                throw new ArgumentException("pdfSplice() does not take negative values for page count arguments.");
            }


            FileStream fs_OutgoingPdf = new FileStream(destinationFile,
                                                  FileMode.OpenOrCreate,
                                                  FileAccess.Write);

            iTextSharp.text.pdf.PdfReader firstReader = new iTextSharp.text.pdf.PdfReader(file1Path);
            iTextSharp.text.pdf.PdfReader secondReader = new iTextSharp.text.pdf.PdfReader(file2Path);

            /* Cap number of pages read from file  to max # of pages*/
            /* if number of pages to read is 0 read the PDF until the end of the document*/

            if (firstReader.NumberOfPages < file1PageCount || file1PageCount == 0)
            {
                file1PageCount = firstReader.NumberOfPages;
            }

            if (secondReader.NumberOfPages < file2PageCount || file2PageCount == 0)
            {
                file2PageCount = secondReader.NumberOfPages;
            }

            iTextSharp.text.Document pdfDoc = new iTextSharp.text.Document();
            iTextSharp.text.pdf.PdfCopy writer = new iTextSharp.text.pdf.PdfCopy(pdfDoc, fs_OutgoingPdf);
            iTextSharp.text.pdf.PdfImportedPage page;

            pdfDoc.Open();

            /* Go through PDF #1 from the starting position, writing pages to file */

            for (int i = file1StartPos; i <= file1PageCount; i++)
            {
                pdfDoc.SetPageSize(firstReader.GetPageSizeWithRotation(i));
                pdfDoc.NewPage();
                page = writer.GetImportedPage(firstReader, i);
                writer.AddPage(page);
            }

            /* Repeat with PDF #2 */
            for (int i = file1StartPos; i <= file2PageCount; i++)
            {
                pdfDoc.SetPageSize(secondReader.GetPageSizeWithRotation(i));
                pdfDoc.NewPage();
                page = writer.GetImportedPage(secondReader, i);
                writer.AddPage(page);
            }

            pdfDoc.Close();

            return 0;
        }




    }

}
