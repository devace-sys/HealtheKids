using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Globalization;
using MBA;
using System.Data.SqlClient;
using System.Security.Permissions;
using System.IO;
using System.Configuration;
using System.Net.Configuration;

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

using System.Net.Mail;
using System.Net.Mime;

namespace WORKFLOW
{
    public partial class SBSCParent : System.Windows.Forms.Form
    {
        public SBSCParent()
        {
            GetAppSettings();
            InitializeComponent();
        }

        /***************************************************************************
       * ExitCode */
        /**
         * Various exit codes.  These codes can be combined with a bitwised OR.
         * 
         * For example:
         * 
         *   int retCode = (int) ExitCode.InvalidArgument | (int) ExitCode.Failure
         ***************************************************************************/

        [Flags]

        enum ExitCode : int
        {
            Success = 0,
            InvalidArgument = 1,
            OtherError = 2,
            Failure = 32
        }

        /***************************************************************************
         * retCode */
        /**
         * Return code for this application
         ***************************************************************************/

        protected static int retcode = (int)ExitCode.Success;

        /***************************************************************************
         * log */
        /**
         * Our logging object
         ***************************************************************************/

        protected static FileLogger log = null;

        /***************************************************************************
         * WriteLogEntry */
        /**
         * Writes an entry to the log 
         * 
         ***************************************************************************/

        static void WriteLogEntry(Logger.LogLevel level, string message)
        {
            if (log != null)
                log.writeLog(level, message);
            else
                Console.WriteLine(message);
        }

        static void WriteLogEntry(string message)
        {
            log.writeLog(Logger.LogLevel.Info, message);
        }


        /***************************************************************************
         * Various settings and db connections
         ***************************************************************************/

        public static string basePath;
        public static string oldpath;
        public static string rptAnIpath;
        public static string wfSummaryRptPath;
        public static string QFormResponseFilePath;
        public static SmtpSection smtpSection;
        public static string appEmailFrom;
        public static string appQformEmailFrom;
        public static SmtpClient smtp;
        public static SmtpClient smtpNoReply;
        public static SqlConnection connSpedmon;
        public static SqlConnection connUsers;

        /***************************************************************************
         * Variables to store the user credentials
         ***************************************************************************/

        public static bool isInputStaff = false;
        public static string PATH_WorkingFolder;
        public static string userName;
        public static Int32 userID;
        public static bool refreshIBView = true;
        public static bool fileOpen = false;
        public bool commmandLineMode = false;
        public string[] commandLineArguments;
        static HSSFWorkbook hssfworkbook;
        static HSSFWorkbook templateWorkbook;
        public int rowCount;
        public string index;
        public string fname;
        DateTime fyStart;
        int? commandLineReportNumber = null;
        DateTime? commandLineStartWeek = null;
        DateTime? commandLineEndWeek = null;
        string[] toEmailIDList;
        string[] ccEmailIDList;
        string[] bccEmailIDList;


        public static bool OK_TO_MANAGE_FILES = true;

        private void GetAppSettings()
        {
            
            OK_TO_MANAGE_FILES = true;

            string okToManageFilesStr = ConfigurationManager.AppSettings["okToManageFiles"];
            
            if (!String.IsNullOrWhiteSpace(okToManageFilesStr)) {
                var okToManageFilesVal = MBA.Util.evaluateFlag(okToManageFilesStr,false);
                if (okToManageFilesVal.HasValue) {
                    OK_TO_MANAGE_FILES = okToManageFilesVal.Value;
                }                  
            }

            basePath = ConfigurationManager.AppSettings["basePath"].ToString();
            oldpath = ConfigurationManager.AppSettings["oldPath"].ToString();
            rptAnIpath = ConfigurationManager.AppSettings["AnIPath"].ToString();
            wfSummaryRptPath = ConfigurationManager.AppSettings["WFSummaryRpt"].ToString();
            QFormResponseFilePath = ConfigurationManager.AppSettings["QFormResponseFilePath"].ToString();

            smtpSection = ConfigurationManager.GetSection("system.net/mailSettings/smtp") as SmtpSection;
            appEmailFrom = ConfigurationManager.AppSettings["appEmailFrom"].ToString();
            appQformEmailFrom = ConfigurationManager.AppSettings["appQformEmailFrom"].ToString();

            smtp = new SmtpClient()
            {
                Host = smtpSection.Network.Host, //for gmail
                Port = smtpSection.Network.Port, //for gmail outgoing,    
                EnableSsl = true,
                Credentials = new System.Net.NetworkCredential(smtpSection.From, ConfigurationManager.AppSettings["smtpPass"].ToString())
            };

            smtpNoReply = new SmtpClient()
            {
                Host = smtpSection.Network.Host, //for gmail
                Port = smtpSection.Network.Port, //for gmail outgoing,    
                EnableSsl = true,
                Credentials = new System.Net.NetworkCredential(appQformEmailFrom, ConfigurationManager.AppSettings["smtpNoReplyPass"].ToString())
            };
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }


        /***************************************************************************
         * Display menu items as per user's role.
         ***************************************************************************/
        private void form1_Load(object sender, EventArgs e)
        {
            if (smtp.DeliveryMethod == SmtpDeliveryMethod.SpecifiedPickupDirectory)
            {
                smtp.EnableSsl = false;
                smtpNoReply.EnableSsl = false;
            }

            commandLineArguments = Environment.GetCommandLineArgs();

            label2.Text = Environment.UserName;

            connSpedmon = Database.openConn(ConfigurationManager.ConnectionStrings["Spedmon"].ConnectionString.ToString());
            connUsers = Database.openConn(ConfigurationManager.ConnectionStrings["Users"].ConnectionString.ToString());
            connSpedmon.ConnectionTimeout.Equals(1500);
            connUsers.ConnectionTimeout.Equals(1500);

            string sql;
            List<SqlParameter> parms = new List<SqlParameter>();

            /******************************************************************
             * If command line arguments exist then process required method and
             * exit the app.
             ******************************************************************/
            try
            {
                if (commandLineArguments.Length > 1)
                {
                    /*-------------------------------
                     * Test to see if a config file
                     * exists and if it does not
                     * throw an exception
                     *------------------------------*/
                    string appname = WindowsApplication.GetExeName();
                    string configname = WindowsApplication.GetAppConfigName();
                    WindowsApplication.AppConfigExists(configname);

                    /*-------------------------------
                     * Fetch base path for log file
                     * from config file
                     *------------------------------*/

                    string logpath = ConfigurationManager.AppSettings["logFilePath"].ToString();

                    /*-------------------------------
                     * Create log file
                     *------------------------------*/

                    string logname = appname;
                    log = new FileLogger(logpath, logname);

                    // TODO: Refactor to use details log exclusively

                    DetailsLog dlog = new DetailsLog();

                    /*-------------------------------
                     * Starting
                     *------------------------------*/

                    WriteLogEntry(@"Starting");

                    commmandLineMode = true;
                    /******************************************************************
                     * Get the command line arguments
                     ******************************************************************/
                    //rptAnIpath = ConfigurationManager.AppSettings["AnIPath"].ToString() + @"A&I Weekly Report\Reports Sent\";
                    bool hasParameters = false;
                    int commandLineArgNum = 0;
                    if (commandLineArguments.Length > 2) hasParameters = true;
                    foreach (string arg in commandLineArguments)
                    {
                        commandLineArgNum++;
                        //Since the first element in the arguments array will be app name, contitnue the loop.
                        if (commandLineArgNum == 1) continue;
                        if (commandLineArgNum == 3) hasParameters = true;
                        string token = arg.Trim().ToLower();

                        if (token.Length > 4)
                        {
                            string option = token.Substring(0, 4);
                            string value = token.Substring(4);

                            try
                            {
                                if (option == "/rn:") commandLineReportNumber = Convert.ToInt32(value);
                                if (option == "/d1:") commandLineStartWeek = Convert.ToDateTime(value);
                                if (option == "/d2:") commandLineEndWeek = Convert.ToDateTime(value);
                            }
                            catch
                            {
                                WriteLogEntry(@"Creating the report failed. Arguments supplied are invalid.");
                                Application.Exit();
                                Environment.Exit(1);
                            }
                        }
                    }
                    /******************************************************************
                     * If no arguments are passed for the dates set the date range to
                     * the last week, i.e enddate = last fridays date and startdate = enddate - 6 days
                     ******************************************************************/
                    DateTime fyEnd;

                    if (commandLineReportNumber == 1)
                    {
                        DateTime today = DateTime.Now;
                        if (hasParameters == false)
                        {
                            commandLineStartWeek = today.AddDays(-8 - Convert.ToInt16(DateTime.Now.DayOfWeek));
                            commandLineEndWeek = today.AddDays(-2 - Convert.ToInt16(DateTime.Now.DayOfWeek));
                        }
                        //set the report file name according to the date values.
                        fname = "A&I Weekly Report as of " + Convert.ToDateTime(commandLineEndWeek).ToString("yyyyMMdd") + ".xls";
                        Dates.ComputeFiscalYear(Convert.ToDateTime(commandLineEndWeek), out fyStart, out fyEnd);

                        DateTime clientInvoiceDate;
                        DateTime thanksGivingDate;
                        /******************************************************************
                         * Get the latest date from Client invoices table
                         * Get the date of Thanksgiving day in the current year
                         ******************************************************************/
                        clientInvoiceDate = Convert.ToDateTime(WinFormsCommon.execScalar(connSpedmon, "select MAX(INVOICE_DATE) from Client_Invoices", null));
                        thanksGivingDate = Convert.ToDateTime(WinFormsCommon.execScalar(connSpedmon, "SELECT DATE FROM HOLIDAYS() where Holiday = 'ThanksGivingDay'", null));


                        string to = ConfigurationManager.AppSettings["appEmailTo"].ToString();
                        toEmailIDList = WinFormsCommon.splitString(to);
                        string cc = ConfigurationManager.AppSettings["appEmailCc"].ToString();
                        ccEmailIDList = WinFormsCommon.splitString(cc);
                        string bcc = ConfigurationManager.AppSettings["appEmailBcc"].ToString();
                        bccEmailIDList = WinFormsCommon.splitString(bcc);

                        /******************************************************************
                         * Check if the report exists, if yes exit.
                         * Run the report only if the client invoices are avialable except 
                         * on thanks giving week. the report should be ran during Thanks giving
                         * week even though the client invoices doesn't exist.
                         ******************************************************************/
                        if (!System.IO.File.Exists(FilePaths.PATH_AnI_Reports + fname))
                            if (clientInvoiceDate >= commandLineStartWeek || (thanksGivingDate >= commandLineStartWeek && thanksGivingDate <= commandLineEndWeek))
                            {
                                WriteLogEntry(@"Creating the A&I report");
                                RunAnIReport();
                                WriteLogEntry(@"Sending " + fname);
                                //emailExcelFile(FilePaths.PATH_AnI_Reports + fname, ConfigurationManager.AppSettings["appEmailTo"].ToString(), ConfigurationManager.AppSettings["appEmailCc"].ToString());

                                List<string> attachments = new List<string>();
                                attachments.Add(FilePaths.PATH_AnI_Reports + fname);

                                if (System.IO.File.Exists(FilePaths.PATH_AnI_Reports + fname))
                                    WinFormsCommon.emailFile(smtp, appEmailFrom, toEmailIDList, ccEmailIDList, fname, "Attached please find the A&I Report for the last week. " +
                                    "If you have any questions, please email Terry at terry@help4schools.com.", attachments);
                            }
                            else
                            {
                                string[] emailIDList;
                                emailIDList = WinFormsCommon.splitString(cc + "," + bcc);

                                WinFormsCommon.emailFile(smtp, appEmailFrom, toEmailIDList, emailIDList, "A&I report is not ready!", "Not all of Friday's business is recorded yet." +
                                                      " This report will be delayed one day. If you have any questions, please email Terry at terry@help4schools.com.", null);
                            }
                        else WriteLogEntry(@"A&I report is not created at this time. Report already exists!");
                    }
                    if (commandLineReportNumber == 2)
                    {
                        WriteLogEntry(@"Creating Workflow summary report.");
                        WorkflowSummaryReport();
                        string to = ConfigurationManager.AppSettings["appEmailSummaryRpt"].ToString();
                        toEmailIDList = WinFormsCommon.splitString(to);
                        WriteLogEntry(@"Sending " + fname);

                        List<string> attachments = new List<string>();
                        attachments.Add(wfSummaryRptPath + fname);

                        if (System.IO.File.Exists(wfSummaryRptPath + fname))
                            WinFormsCommon.emailFile(smtp, appEmailFrom, toEmailIDList, null, fname, "Attached please find the Workflow summary report for the last week. ", attachments);
                    }

                    if (commandLineReportNumber == 3)
                    {
                        /******************************************************************
                         * Sends a follow-up email to all un answered qforms 
                         ******************************************************************/
                        sql = "select * from dbo.QFORMS_FOLLOWUP_LIST()";
                        ReturnDB rd1 = Database.execQuery(SBSCParent.connUsers, null, sql, false, null);
                        DataTable dt1 = Database.convertReturnDBToDatatable(ref rd1);
                        WriteLogEntry(@"Sending follow-up emails for un-answered Qforms");
                        foreach (DataRow r in dt1.Rows)
                        {
                            string token = r["Token"].ToString();
                            string emailTittle = r["Email_Tittle"].ToString();
                            string emailMsg = r["Email_Msg"].ToString();
                            string irrID = r["id"].ToString();
                            string fileLocation = SBSCParent.basePath + r["File_Location"].ToString();
                            string filename = r["File_Name"].ToString();
                            string toName = r["To_Name"].ToString();
                            int countFollowedUp = 0;
                            if (r["CountFollowedUp"] != DBNull.Value)
                                countFollowedUp = Convert.ToInt16(r["CountFollowedUp"]);

                            //Check if we have rows in dbo.INFO_REQUEST_RESPONSE_DETAILS table if not do not allow edit
                            sql = " select COUNT(*) from dbo.INFO_REQUEST_RESPONSE_DETAILS where InfoRequestResponseID = @irrID and active = 1";
                            parms.Clear();
                            object vIrrID = MBA.Validate.optInteger(irrID, "", true);
                            parms.Add(Database.SqlParm("@irrID", SqlDbType.BigInt, vIrrID, ParameterDirection.Input));
                            int questionsCount = Convert.ToInt16(WinFormsCommon.execScalar(SBSCParent.connUsers, sql, parms));
                            /******************************************************************
                             * Make sure we have atleast one or more questions for the Qform.
                             * We are not following up more than 2 times for Qforms.
                             ******************************************************************/
                            if (questionsCount > 0 && countFollowedUp < 3)
                            {
                                List<string> attachments = new List<string>();
                                attachments.Add(fileLocation + filename);

                                //get the server name to create the link
                                string servername = ConfigurationManager.AppSettings["serverName"].ToString();

                                string[] emailTo = WinFormsCommon.splitString(r["Email_To"].ToString());
                                string[] emailCc = WinFormsCommon.splitString(r["Email_CC"].ToString());
                                //if we are following up for the second time, then send the follow-up email to rep and cc Chuck 
                                if (countFollowedUp == 1)
                                {
                                    //since we cc the rep for all Qforms sent to practitioners, we are replacing the to address with cc.
                                    if (r["Email_CC"].ToString() != string.Empty)
                                        emailTo = WinFormsCommon.splitString(r["Email_CC"].ToString());
                                    emailCc = WinFormsCommon.splitString(ConfigurationManager.AppSettings["ChuckEmail"].ToString());
                                }

                                toName = MBA.Util.nameCase(toName);
                                string lnk = MBA.HttpApplication.createLink(servername + MBA.Constants.APP_VDIR + "Questionform.aspx", new NameValue(MBA.Constants.PARM_QFTOKEN, token), new NameValue(MBA.Constants.PARM_QFORMMODE, "0"));
                                string msg = MBA.Util.createMessageString(Messages.QFORM_FOLLOWUP_BODY, toName, lnk);

                                WinFormsCommon.emailFile(SBSCParent.smtp, SBSCParent.appEmailFrom, emailTo, emailCc, emailTittle, msg, attachments);

                                //update SentOn and status fields in Irr record after sending the email with link
                                sql = "update INFO_REQUEST_RESPONSE  set FollowedUpOn = getdate(),  CountFollowedUp = ISNULL(CountFollowedUp,0) + 1 where ID = @irrID";
                                parms.Clear();
                                parms.Add(Database.SqlParm("@irrID", SqlDbType.BigInt, vIrrID, ParameterDirection.Input));
                                WinFormsCommon.execScalar(SBSCParent.connUsers, sql, parms);

                            }
                        }
                        WriteLogEntry(@"Finished sending follow-up emails.");

                    }
                }
            }
            catch (Exception ex)
            { /*-------------------------------
               * Exit with errors
               *------------------------------*/
                Database.closeConn(connSpedmon);
                if (commandLineReportNumber == 3)
                {
                    WriteLogEntry(Logger.LogLevel.Alert, ex.Message);
                    WriteLogEntry(Logger.LogLevel.Crit, @"Qform emails not sent!");
                }
                else
                {

                    WriteLogEntry(Logger.LogLevel.Alert, ex.Message);
                    WriteLogEntry(Logger.LogLevel.Crit, @"Exiting with errors, report not sent!");
                }

                retcode = (int)ExitCode.OtherError | (int)ExitCode.Failure;
            }
            finally
            {
                if (commmandLineMode)
                {
                    if (log != null)
                        log.Dispose();
                    WindowsApplication.cleanup();
                }
            }

            if (commmandLineMode) Environment.Exit(retcode);


            sql = "select id,roleID,firstname+' '+lastname as name from dbo.USERS_DATA_CORE(dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null) " +
                  "where userGroupID = dbo.CONST_USER_GROUP_SBS() and SUBSTRING(UserName,0,CHARINDEX('@',UserName)) = @userName";
            parms.Clear();
            parms.Add(Database.SqlParm("@userName", SqlDbType.VarChar, Environment.UserName, ParameterDirection.Input, 7000));

            ReturnDB rd = Database.execQuery(SBSCParent.connUsers, null, sql, false, parms);
            DataTable dt = new DataTable();
            dt = Database.convertReturnDBToDatatable(ref rd);
            //Allow access to SBSC employees and only with their primary account.
            if (dt.Rows.Count == 1)
            {
                DataRow dr = dt.Rows[0];
                userID = Convert.ToInt32(dr[0]);
                label2.Text = "Hello " + dr[2].ToString();
                userName = dr[2].ToString();
                int role = Convert.ToInt16(dr[1].ToString());

                if (role == 4)
                {
                    isInputStaff = true;
                    manageStaffToolStripMenuItem.Visible = false;
                    staffReviewsToolStripMenuItem.Visible = false;
                    workControlToolStripMenuItem.Visible = false;
                    stampsToolStripMenuItem.Visible = false;
                    PATH_WorkingFolder = FilePaths.PATH_STAFF_FOLDER + dr[2].ToString() + @"\WorkingFiles\";
                }
               
                else if (role > 4)
                {
                    MessageBox.Show("Access denied! Please contact your system administrator.");
                    this.Dispose();
                }
                if (OK_TO_MANAGE_FILES == false)
                { 
                  MessageBox.Show( "Please be advised that \n\n (1) when a workbatch status is changed the files will no longer be moved.\n\n (2) renaming of files is no longer allowed.  \n\n These changes are part of the migration of the workflow functionality to SpEdCare.  If any of these changes causes any issues please let your manager know as soon as possible."
                                  , "Workflow Migration to SpEdCare"
                                  ,  MessageBoxButtons.OK
                                  ,  MessageBoxIcon.Information);
                }
            }
            else
            {
                MessageBox.Show("Access denied! Please contact your system administrator.");
                this.Dispose();
            }
        }

        private void inputBatchesToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if ((InputBatchesView.editForm == null) || InputBatchesView.editForm.IsDisposed)
            {
                InputBatchesView form1 = InputBatchesView.GetChildInstance();
                form1.MdiParent = this;
                form1.Show();
                form1.BringToFront();
            }
            else
                InputBatchesView.editForm.BringToFront();
        }

        private void staffHoursSaveToolStripMenuItem_Click(object sender, EventArgs e)
        {
            StaffHoursSave form1 = StaffHoursSave.GetChildInstance();
            form1.MdiParent = this;
            form1.Show();
            form1.BringToFront();
        }

        private void staffHoursViewToolStripMenuItem_Click(object sender, EventArgs e)
        {
            StaffHoursView form1 = StaffHoursView.GetChildInstance();
            form1.MdiParent = this;
            form1.Show();
            form1.BringToFront();
        }

        private void helpToolStripMenuItem_Click(object sender, EventArgs e)
        {
            System.Windows.Forms.Help.ShowHelp(this, basePath + FilePaths.PATH_Help);
        }

        private void trainedStaffViewToolStripMenuItem_Click(object sender, EventArgs e)
        {
            TrainedStaffView form1 = TrainedStaffView.GetChildInstance();
            form1.MdiParent = this;
            form1.Show();
            form1.BringToFront();
        }

        private void manageTrainingRecordsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            ManageTrainedStaff form1 = ManageTrainedStaff.GetChildInstance();
            form1.MdiParent = this;
            form1.Show();
            form1.BringToFront();
        }

        /***************************************************************************
         * opens a report of practitioner's problems
         ***************************************************************************/
        private PractitionersProblemsHistory pracRptForm;
        private void practitionerReviewsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            pracRptForm = PractitionersProblemsHistory.GetChildInstance();
            pracRptForm.Show();
            pracRptForm.BringToFront();
        }

        /***************************************************************************
         * opens a report of staff reviews
         ***************************************************************************/
        private StaffProblemHistory staffRptForm;
        private void staffReviewsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            staffRptForm = StaffProblemHistory.GetChildInstance();
            staffRptForm.Show();
            staffRptForm.BringToFront();
        }

        /***************************************************************************
        * Finished work View
        ***************************************************************************/
        private ResearchForDuplicateClaims finishedWork;
        private void finishedFilesToolStripMenuItem_Click(object sender, EventArgs e)
        {
            finishedWork = ResearchForDuplicateClaims.GetChildInstance();
            finishedWork.Show();
            finishedWork.BringToFront();
        }

        public static EmailForm emailForm;
        private void emailToolStripMenuItem_Click(object sender, EventArgs e)
        {
            emailForm = EmailForm.GetChildInstance();
            //emailForm.emailCc = EmailCc;
            emailForm.Show();
            emailForm.BringToFront();
        }

        /***************************************************************************
         * outputs the A&I report to the template and saves in the given location
         ***************************************************************************/
        private void RunAnIReport()
        {
            try
            {
                InitializeWorkbook();

                FileStream fs = new System.IO.FileStream("A&I Weekly Template.xls",
                                                        System.IO.FileMode.Open, System.IO.FileAccess.Read, System.IO.FileShare.Read);
                HSSFSheet sheet = (HSSFSheet)hssfworkbook.CreateSheet("A&I Weekly Report");

                // Load the template into a NPOI workbook  
                templateWorkbook = new HSSFWorkbook(fs, true);

                // Load the sheet1 you are going to use as a template into NPOI  
                sheet = (HSSFSheet)templateWorkbook.GetSheet("A&I Weekly Report");

                string sql = "select * from RPT_AnI_WEEKLY(null,null,@commandLineStartWeek,@commandLineEndWeek,@fyStart)";

                List<SqlParameter> parms = new List<SqlParameter>();
                parms.Add(Database.SqlParm("@commandLineStartWeek", SqlDbType.Date, commandLineStartWeek, ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@commandLineEndWeek", SqlDbType.Date, commandLineEndWeek, ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@fyStart", SqlDbType.Date, fyStart, ParameterDirection.Input));

                ReturnDB rd = Database.execQuery(connSpedmon, null, sql, false, parms);
                DataTable dt = Database.convertReturnDBToDatatable(ref rd);

                int i = 0;
                int k = 2;
                double d;
                IRow row;

                /*------------------------------------------------------------------
                 * Go through each row in the data reader and copy them to the sheet
                 * Convert the string values from datareader into numeric values.
                 * This is needed to apply conditional formating and formulas.
                 *------------------------------------------------------------------*/
                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow row1 in dt.Rows)
                    {
                        row = sheet.GetRow(k);
                        //row = sheet.CreateRow(k);                        
                        for (i = 0; i < dt.Columns.Count; i++)
                        {

                            ICell cell = row.GetCell(i);//row.CreateCell(i);

                            if (row1[i] == DBNull.Value) continue;
                            else
                            {
                                //Get only the date part of the datetime value
                                if (dt.Columns[i].ColumnName == "Last Date Claims Were Transmitted")
                                    cell.SetCellValue(Convert.ToDateTime(row1[i]).ToShortDateString());
                                else
                                {
                                    cell.SetCellValue(row1[i].ToString());
                                    if (dt.Columns[i].ColumnName != "CDS Code" && double.TryParse(row1[i].ToString(), out d))
                                        sheet.GetRow(k).GetCell(i).SetCellValue(d);
                                }
                            }
                            //hide inactive clients
                            if (dt.Columns[i].ColumnName == "Active" && row1[i].ToString() == "0")
                                row.ZeroHeight = true;

                        }
                        k = k + 1;
                    }
                }
                //hide blank rows in the template
                while (k < 250)
                {
                    row = sheet.GetRow(k);
                    row.ZeroHeight = true;
                    k++;
                }

                sheet.DisplayZeros = false;
                sheet.HorizontallyCenter = true;
                sheet.ForceFormulaRecalculation = true;

                FileStream fs1 = new System.IO.FileStream(FilePaths.PATH_AnI_Reports + fname,
                                                      System.IO.FileMode.Create);
                templateWorkbook.Write(fs1);

                fs.Close();
                fs1.Close();
                dt.Dispose();
            }
            catch (Exception ex)
            { /*-------------------------------
                 * Exit with errors
                 *------------------------------*/
                Database.closeConn(connSpedmon);
                WriteLogEntry(Logger.LogLevel.Alert, ex.Message);
                WriteLogEntry(Logger.LogLevel.Crit, @"Exiting with errors");

                retcode = (int)ExitCode.OtherError | (int)ExitCode.Failure;

                Environment.Exit(retcode);
            }
            finally
            {
                /*-------------------------------
                 * Close database connections
                 * log files, etc
                 *------------------------------*/
                Database.closeConn(connSpedmon);

                if (log != null)
                    log.Dispose();
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

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (!commmandLineMode)
            {
                DialogResult d = new DialogResult();
                if (fileOpen)
                    MessageBox.Show("Please make sure you close all the Input Batch files before you exit the application!", "Exit");
                d = MessageBox.Show("Are you sure you want to exit the application?", "Exit", MessageBoxButtons.YesNo);
                if (d == DialogResult.No)
                    e.Cancel = true;
                else
                {
                    try
                    {
                        if (Directory.Exists(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + SBSCParent.userName + @"\Temp\"))
                            System.IO.Directory.Delete(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + SBSCParent.userName + @"\Temp\", true);
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show("Please close all the files and try again! " + ex.Message);
                        e.Cancel = true;
                    }
                }
            }
        }

        /***************************************************************************
         * Outputs a four week report of staff's promised and actual hours worked
         * and a summary report.
         ***************************************************************************/
        private void WorkflowSummaryReport()
        {
            try
            {
                InitializeWorkbook();
                IRow row;
                double d;

                FileStream fs = new System.IO.FileStream("TemplateWFSummaryReport.xls",
                                System.IO.FileMode.Open, System.IO.FileAccess.Read, System.IO.FileShare.Read);

                HSSFSheet sheet1 = (HSSFSheet)hssfworkbook.CreateSheet("SUMMARY");
                HSSFSheet sheet2 = (HSSFSheet)hssfworkbook.CreateSheet("STAFFDETAILS");
                HSSFSheet sheet3 = (HSSFSheet)hssfworkbook.CreateSheet("CLIENTDETAILS");

                // Load the template into a NPOI workbook  
                templateWorkbook = new HSSFWorkbook(fs, true);

                // Load the sheet1 you are going to use as a template into NPOI  
                sheet1 = (HSSFSheet)templateWorkbook.GetSheet("SUMMARY");
                DateTime lastFriday;
                //determine the last friday's date
                lastFriday = DateTime.Now.AddDays(-2 - Convert.ToInt16(DateTime.Now.DayOfWeek));
                /*------------------------------------------------------
                * find last work week start date which should be a sunday and
                * all the week start dates for the last four weeks.
                *------------------------------------------------------*/
                DateTime now = DateTime.Now.AddDays(0 - Convert.ToInt16(DateTime.Now.DayOfWeek));
                DateTime week1 = now.AddDays(-(int)now.DayOfWeek - 7);
                DateTime week2 = week1.AddDays(-7);
                DateTime week3 = week1.AddDays(-14);
                DateTime week4 = week1.AddDays(-21);

                row = sheet1.GetRow(5);
                ICell cell = row.GetCell(3);
                string sqlSummary = "select SUM(hoursonhand) as HoursOnHand from HOURS_ON_HAND(null,'" + lastFriday.ToShortDateString() + "')";
                string value = WinFormsCommon.execScalar(connSpedmon, sqlSummary, null);
                double.TryParse(value, out d);
                cell.SetCellValue(d);

                cell = row.GetCell(4);
                sqlSummary = "select SUM(hoursonhand) as HoursOnHand from HOURS_ON_HAND(null,'" + lastFriday.AddDays(-7).ToShortDateString() + "')";
                value = WinFormsCommon.execScalar(connSpedmon, sqlSummary, null);
                double.TryParse(value, out d);
                cell.SetCellValue(d);

                cell = row.GetCell(5);
                sqlSummary = "select SUM(hoursonhand) as HoursOnHand from HOURS_ON_HAND(null,'" + lastFriday.AddDays(-14).ToShortDateString() + "')";
                value = WinFormsCommon.execScalar(connSpedmon, sqlSummary, null);
                double.TryParse(value, out d);
                cell.SetCellValue(d);

                cell = row.GetCell(6);
                sqlSummary = "select SUM(hoursonhand) as HoursOnHand from HOURS_ON_HAND(null,'" + lastFriday.AddDays(-21).ToShortDateString() + "')";
                value = WinFormsCommon.execScalar(connSpedmon, sqlSummary, null);
                double.TryParse(value, out d);
                cell.SetCellValue(d);

                row = sheet1.GetRow(6);

                cell = row.GetCell(3);
                sqlSummary = "select SUM(TotalHoursAssigned) from hours_assigned(null,'" + lastFriday.ToShortDateString() + "')";
                value = WinFormsCommon.execScalar(connSpedmon, sqlSummary, null);
                double.TryParse(value, out d);
                cell.SetCellValue(d);

                cell = row.GetCell(4);
                sqlSummary = "select SUM(TotalHoursAssigned) from hours_assigned(null,'" + lastFriday.AddDays(-7).ToShortDateString() + "')";
                value = WinFormsCommon.execScalar(connSpedmon, sqlSummary, null);
                double.TryParse(value, out d);
                cell.SetCellValue(d);

                cell = row.GetCell(5);
                sqlSummary = "select SUM(TotalHoursAssigned ) from hours_assigned(null,'" + lastFriday.AddDays(-14).ToShortDateString() + "')";
                value = WinFormsCommon.execScalar(connSpedmon, sqlSummary, null);
                double.TryParse(value, out d);
                cell.SetCellValue(d);

                cell = row.GetCell(6);
                sqlSummary = "select SUM(TotalHoursAssigned ) from hours_assigned(null,'" + lastFriday.AddDays(-21).ToShortDateString() + "')";
                value = WinFormsCommon.execScalar(connSpedmon, sqlSummary, null);
                double.TryParse(value, out d);
                cell.SetCellValue(d);

                row = sheet1.GetRow(7);
                cell = row.GetCell(3);
                sqlSummary = "select sum(LeftoverHours) as leftovers from HOURS_LEFTOVER(null,'" + lastFriday.ToShortDateString() + "')";
                value = WinFormsCommon.execScalar(connSpedmon, sqlSummary, null);
                double.TryParse(value, out d);
                cell.SetCellValue(d);

                cell = row.GetCell(4);
                sqlSummary = "select sum(LeftoverHours) as leftovers from HOURS_LEFTOVER(null,'" + lastFriday.AddDays(-7).ToShortDateString() + "')";
                value = WinFormsCommon.execScalar(connSpedmon, sqlSummary, null);
                double.TryParse(value, out d);
                cell.SetCellValue(d);

                cell = row.GetCell(5);
                sqlSummary = "select sum(LeftoverHours) as leftovers from HOURS_LEFTOVER(null,'" + lastFriday.AddDays(-14).ToShortDateString() + "')";
                value = WinFormsCommon.execScalar(connSpedmon, sqlSummary, null);
                double.TryParse(value, out d);
                cell.SetCellValue(d);

                cell = row.GetCell(6);
                sqlSummary = "select sum(LeftoverHours) as leftovers from HOURS_LEFTOVER(null,'" + lastFriday.AddDays(-21).ToShortDateString() + "')";
                value = WinFormsCommon.execScalar(connSpedmon, sqlSummary, null);
                double.TryParse(value, out d);
                cell.SetCellValue(d);

                row = sheet1.GetRow(13);
                cell = row.GetCell(3);
                sqlSummary = "select MIN(Date_Recieved) as OldestRecievedDate from INPUT_BATCHES where Current_status_Code in (10,30,50)";
                value = WinFormsCommon.execScalar(connSpedmon, sqlSummary, null);

                if (value != "")
                    cell.SetCellValue(Convert.ToDateTime(value).ToShortDateString());

                row = sheet1.GetRow(14);
                cell = row.GetCell(3);
                sqlSummary = "select MIN(date_recieved) as OldestRecievedDate_Assigned from INPUT_BATCHES where Current_status_Code in (60)";
                value = WinFormsCommon.execScalar(connSpedmon, sqlSummary, null);

                if (value != "")
                    cell.SetCellValue(Convert.ToDateTime(value).ToShortDateString());

                sheet2 = (HSSFSheet)templateWorkbook.GetSheet("STAFFDETAILS");

                string sql = "select * from RPT_SBSC_STAFF_HOURS_SUMMARY(@staffID, @oneWeekBack, @twoWeekBack, @threeWeekBack, @fourWeekBack)";

                fname = "WorkflowSummary as of " + Convert.ToDateTime(week1).AddDays(7).ToString("yyyyMMdd") + ".xls";

                List<SqlParameter> parms = new List<SqlParameter>();
                parms.Add(Database.SqlParm("@oneWeekBack", SqlDbType.Date, week1, ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@twoWeekBack", SqlDbType.Date, week2, ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@threeWeekBack", SqlDbType.Date, week3, ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@fourWeekBack", SqlDbType.Date, week4, ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@staffID", SqlDbType.Int, null, ParameterDirection.Input));

                ReturnDB rd = Database.execQuery(connSpedmon, null, sql, false, parms);
                DataTable dt = Database.convertReturnDBToDatatable(ref rd);

                int i = 0;
                int k = 5;

                /*------------------------------------------------------------------
                 * set the column headings for all the four weeks with the 
                 * date range values for sheet2
                 *------------------------------------------------------------------*/

                row = sheet2.GetRow(3);
                cell = row.GetCell(4);
                cell.SetCellValue(week1.ToShortDateString() + " - " + week1.AddDays(6).ToShortDateString());
                NPOI.SS.Util.CellRangeAddress cra = new NPOI.SS.Util.CellRangeAddress(0, 0, 2, 4);
                sheet2.AddMergedRegion(cra);

                cell = row.GetCell(7);
                cell.SetCellValue(week2.ToShortDateString() + " - " + week2.AddDays(6).ToShortDateString());
                cra = new NPOI.SS.Util.CellRangeAddress(0, 0, 5, 7);
                sheet2.AddMergedRegion(cra);

                cell = row.GetCell(10);
                cell.SetCellValue(week3.ToShortDateString() + " - " + week3.AddDays(6).ToShortDateString());
                cra = new NPOI.SS.Util.CellRangeAddress(0, 0, 8, 10);
                sheet2.AddMergedRegion(cra);
                cell = row.GetCell(13);

                cell.SetCellValue(week4.ToShortDateString() + " - " + week4.AddDays(6).ToShortDateString());
                cra = new NPOI.SS.Util.CellRangeAddress(0, 0, 11, 13);
                sheet2.AddMergedRegion(cra);

                /*------------------------------------------------------------------
                * set the column headings for all the four weeks with the 
                * date range values for sheet1
                *------------------------------------------------------------------*/
                row = sheet1.GetRow(2);
                cell = row.GetCell(1);
                cell.SetCellValue("as of " + Convert.ToDateTime(week1).AddDays(7).ToLongDateString());

                row = sheet1.GetRow(4);
                cell = row.GetCell(3);
                cell.SetCellValue(week1.ToShortDateString() + " - " + week1.AddDays(6).ToShortDateString());

                cell = row.GetCell(4);
                cell.SetCellValue(week2.ToShortDateString() + " - " + week2.AddDays(6).ToShortDateString());

                cell = row.GetCell(5);
                cell.SetCellValue(week3.ToShortDateString() + " - " + week3.AddDays(6).ToShortDateString());

                cell = row.GetCell(6);
                cell.SetCellValue(week4.ToShortDateString() + " - " + week4.AddDays(6).ToShortDateString());

                /*------------------------------------------------------------------
                 * Go through each row in the data reader and copy them to the sheet
                 * Convert the string values from datareader into numeric values.
                 * This is needed to apply conditional formating and formulas.
                 *------------------------------------------------------------------*/
                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow row1 in dt.Rows)
                    {
                        row = sheet2.GetRow(k);

                        for (i = 0; i < dt.Columns.Count; i++)
                        {
                            ICell vcell = row.GetCell(i + 2);
                            vcell.SetCellValue(row1[i].ToString());
                            if (double.TryParse(row1[i].ToString(), out d))
                                sheet2.GetRow(k).GetCell(i + 2).SetCellValue(d);
                        }
                        k = k + 1;
                    }
                }

                sheet3 = (HSSFSheet)templateWorkbook.GetSheet("CLIENTDETAILS");

                sql = "Select * from RPT_WF_CLIENT_DETAILS_SUMMARY(null,'" + lastFriday.ToShortDateString() + "')";
                rd = Database.execQuery(connSpedmon, null, sql, false, null);
                dt = Database.convertReturnDBToDatatable(ref rd);

                row = sheet3.GetRow(0);
                cell = row.GetCell(0);
                cell.SetCellValue("CLIENT DETAILS AS OF " + lastFriday.ToShortDateString());

                i = 0;
                k = 2;
                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow row1 in dt.Rows)
                    {
                        row = sheet3.GetRow(k);

                        for (i = 0; i < dt.Columns.Count; i++)
                        {
                            ICell vcell = row.GetCell(i);
                            vcell.SetCellValue(row1[i].ToString());
                            if (double.TryParse(row1[i].ToString(), out d))
                                sheet3.GetRow(k).GetCell(i).SetCellValue(d);
                        }
                        k = k + 1;
                    }
                }

                sheet2.HorizontallyCenter = true;
                sheet2.ForceFormulaRecalculation = true;
                sheet1.ForceFormulaRecalculation = true;
                sheet2.DisplayZeros = false;

                FileStream fs1 = new System.IO.FileStream(wfSummaryRptPath + fname,
                                                  System.IO.FileMode.Create);
                templateWorkbook.Write(fs1);
                fs.Close();
                fs1.Close();
                dt.Dispose();
            }
            catch (Exception ex)
            { /*-------------------------------
               * Exit with errors
               *------------------------------*/
                Database.closeConn(connSpedmon);
                WriteLogEntry(Logger.LogLevel.Alert, ex.Message);
                WriteLogEntry(Logger.LogLevel.Crit, @"Exiting with errors");

                retcode = (int)ExitCode.OtherError | (int)ExitCode.Failure;

                Environment.Exit(retcode);
            }
            finally
            {
                /*-------------------------------
                 * Close database connections
                 * log files, etc
                 *------------------------------*/
                Database.closeConn(connSpedmon);

                if (log != null)
                    log.Dispose();
            }
        }

        private WorkControl workControlForm;
        private void workControlToolStripMenuItem_Click(object sender, EventArgs e)
        {
            workControlForm = WorkControl.GetChildInstance();
            workControlForm.MdiParent = this;
            workControlForm.Show();
            workControlForm.BringToFront();
        }

        private Stamps stampForm;
        private void stampsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            stampForm = Stamps.GetChildInstance();
            stampForm.MdiParent = this;
            stampForm.Show();
            stampForm.BringToFront();
        }

    }
}
