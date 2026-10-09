using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MBA;
using System.Data.SqlClient;
using System.Security.Permissions;
using System.IO;
using System.Configuration;
using System.Net.Configuration;
using System.Net.Mail;
using System.Net.Mime;



namespace StudentDataTracking
{
    public partial class StudentDataTracking : System.Windows.Forms.Form
    {
        public StudentDataTracking()
        {
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
            Success         = 0,
            InvalidArgument = 1,
            OtherError      = 2,
            Failure         = 32
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
        
        public static SqlConnection connSpedmon;
        public static SqlConnection connUsers;
        public static string userName;
        public static Int32  userID;
        public DateTime toDay = DateTime.Now; //Convert.ToDateTime("10/1/2013");
        public string[] commandLineArguments;
        public bool     commmandLineMode = false;
        int?            commandLineNumber = null;
        private string sql;
        private string clientID;
        private string clientName;
        private string contactFirstName;
        private string contactLastName;
        private string contactEmail;
        private string repEmail;
        private string secondaryContact;
        public string fileTypeID;
        string fileType;
        public static string quarter;
        public static string currentQuarter;
        public string curQtrStartDate;
        public static string fiscalYrID;
        public List<DateTime> quarterDates = new List<DateTime>();
        private string autoReq;
        private bool sendEmail = false;
        public static string emailITAddress;
        public static string emailCc;


        private string emailBody;
        private List<string> filesToAttach = new List<string>();

        public SmtpSection smtpSection;
        public string appEmailFrom;

        public static SmtpClient smtp;


        private void loadConfigData()
        {

            string bodyPath = ConfigurationManager.AppSettings["studentDataTrackingEmailBody"].ToString();

            using (StreamReader sr = new StreamReader(bodyPath))
            { emailBody = sr.ReadToEnd(); }

            smtpSection = ConfigurationManager.GetSection("system.net/mailSettings/smtp") as SmtpSection;
            appEmailFrom = ConfigurationManager.AppSettings["appEmailFrom"].ToString();

            string emailAttachmentList = ConfigurationManager.AppSettings["emailFileAttachments"].ToString();

            filesToAttach = emailAttachmentList.Split(',').ToList<string>();

            smtp = new SmtpClient();
            smtp.DeliveryMethod = smtpSection.DeliveryMethod;
            if (smtp.DeliveryMethod != SmtpDeliveryMethod.SpecifiedPickupDirectory)
            {
                smtp.Host = smtpSection.Network.Host; //for gmail
                smtp.Port = smtpSection.Network.Port; //for gmail outgoing,    
                smtp.EnableSsl = true;
                smtp.Credentials = new System.Net.NetworkCredential(ConfigurationManager.AppSettings["appEmailFrom"].ToString(),
                                                               ConfigurationManager.AppSettings["smtpPass"].ToString());
            }
        }
       

        private void StudentDataTracking_Load(object sender, EventArgs e)
        {
            loadConfigData();

            if(smtp.DeliveryMethod == SmtpDeliveryMethod.SpecifiedPickupDirectory)
               smtp.EnableSsl = false;

            List<SqlParameter> parms = new List<SqlParameter>();
          /*-------------------------------------------------------
           * Get startdate of each quarter in to quarterdates list
           * july 1st is the first quarter start date
           * calculate each quarter startdate, if today's month value
           * is < 7 then first quarter startdate will be last year july 1st
           * else it will be current year july 1st
           *-------------------------------------------------------*/
            DateTime firstQuarterStartDate;
            if (toDay.Month < 7) firstQuarterStartDate = new DateTime(toDay.Year -1, 7, 1);
            else firstQuarterStartDate =  new DateTime(toDay.Year, 7, 1);
          
            quarterDates.Add(firstQuarterStartDate);
            quarterDates.Add(firstQuarterStartDate.AddMonths(3));
            quarterDates.Add(firstQuarterStartDate.AddMonths(6));
            quarterDates.Add(firstQuarterStartDate.AddMonths(9));
            //get current quarter value
            if (toDay >= quarterDates[0] && toDay < quarterDates[1])
            { currentQuarter = "1";}
            else if (toDay >= quarterDates[1] && toDay < quarterDates[2])
                currentQuarter = "2";
            else if (toDay >= quarterDates[2] && toDay < quarterDates[3])
                currentQuarter = "3";
            else currentQuarter = "4";
           
            string fy;
            if (toDay.Month >= 7)
                fy = toDay.Year.ToString() + " - " + toDay.AddYears(1).Year.ToString();
            else
                fy = toDay.AddYears(-1).Year.ToString() + " - " + toDay.Year.ToString();

            connSpedmon    = Database.openConn(ConfigurationManager.ConnectionStrings["Spedmon"].ConnectionString.ToString());
            connUsers      = Database.openConn(ConfigurationManager.ConnectionStrings["Users"].ConnectionString.ToString());
            emailITAddress = ConfigurationManager.AppSettings["appEmailIT"].ToString();            
            emailCc        = ConfigurationManager.AppSettings["appEmailCc"].ToString();            
            //get current fiscal year ID value
            fiscalYrID = WinFormsCommon.execScalar(connSpedmon, "SELECT id FROM COMPANY_FISCAL_YEARS where getdate() between FY_START and FY_END", null);

            commandLineArguments = Environment.GetCommandLineArgs();
            sql = "select id,roleID,firstname+' '+lastname as name from USERS_VIEW_CORE(dbo.CONST_APP_NAME_SPEDCARE()) " +
                  "where userGroup = dbo.CONST_USER_GROUP_SBS() and SUBSTRING(UserName,0,CHARINDEX('@',UserName)) = @userName";

            
            parms.Add(Database.SqlParm("@userName", SqlDbType.VarChar, Environment.UserName, ParameterDirection.Input, 7000));
            ReturnDB rd  = Database.execQuery(connUsers, null, sql, false, parms);
            DataTable dt = new DataTable();
            dt = Database.convertReturnDBToDatatable(ref rd);
            //Allow access only to SBSC employees and only with their primary account.
            if (dt.Rows.Count == 1)
            {
                DataRow dr     = dt.Rows[0];
                userID         = Convert.ToInt32(dr[0]);
                userlabel.Text = "Hello " + dr[2].ToString();
                userName       = dr[2].ToString();
                int role       = Convert.ToInt16(dr[1].ToString());
            }
            /******************************************************************
             * If command line arguments exist then process required method and
             * exit the app.
             * 
             * if task number = 1, sends data request email to Client data contact 
             *    task number = 2, checks if the request has been sent else notifies IT 
             *    task number = 3, checks if data file received else notifies IT
             *    task number = 4, checks if data file received else notifies IT
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
                    string appname    = WindowsApplication.GetExeName();
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
                    int commandLineArgNum = 0;
                    foreach (string arg in commandLineArguments)
                    {
                        commandLineArgNum++;
                        //Since the first element in the arguments array will be app name, contitnue the loop.
                        if (commandLineArgNum == 1) continue;
                        
                        string token = arg.Trim().ToLower();

                        if (token.Length > 3)
                        {
                            string option = token.Substring(0, 3);
                            string value  = token.Substring(3);

                            try
                            {
                                if (option == "/n:") commandLineNumber = Convert.ToInt32(value);
                            }
                            catch
                            {
                                WriteLogEntry(@"Arguments supplied are invalid.");
                                Application.Exit();
                                Environment.Exit(1);
                            }
                        }
                    }
                    DataTable dt2;
                    
                    if (commandLineNumber == 1)
                    {
                        /******************************************************************
                         * if the command number is 1, send the student data request emails 
                         * for all the clients who have auto request's on in dbo.CLIENT_STUDENT_DATA_FILES
                         * table.
                         ******************************************************************/
                        dt2 = StudentData.StudentDataFilestoRequest(connSpedmon, toDay.ToShortDateString(), 
                                                                    quarterDates[0].ToShortDateString(),
                                                                    quarterDates[1].ToShortDateString(),
                                                                    quarterDates[2].ToShortDateString(),
                                                                    quarterDates[3].ToShortDateString(), 
                                                                    ""
                                                                   );
                        if (dt2.Rows.Count > 0)
                        {
                            foreach (DataRow row in dt2.Rows)
                            {
                                clientID         = row["CLIENT_ID"].ToString();
                                clientName       = row["CLIENT_NAME"].ToString();
                                fileTypeID       = row["FILE_TYPE_ID"].ToString();
                                contactEmail     = row["CONTACT_EMAIL"].ToString();
                                secondaryContact = row["SECONDARY_CONTACT_EMAIL"].ToString();
                                repEmail         = row["CLIENT_REP_EMAIL"].ToString();
                                contactFirstName = row["CONTACT_FIRST_NAME"].ToString();
                                contactLastName  = row["CONTACT_LAST_NAME"].ToString();
                                quarter          = row["QUARTER"].ToString();
                              
                                autoReq          = row["AUTO_REQUEST"].ToString();
                                
                                DataTable dt3;
                                //check if the student data request email has already been sent. if sent then continue to next row
                                dt3 = StudentData.StudentDataTrackingView(connSpedmon,clientID,fileTypeID,quarter,fiscalYrID,"","", "0","","1");

                                if (dt3.Rows.Count > 0) continue;


                                /* setup stores for holding info for str.Format() */
                                string contactName = char.ToUpper(contactFirstName[0]) + contactFirstName.Substring(1);
                                string replyAddress = ConfigurationManager.AppSettings["appEmailFrom"].ToString();

                                string body = emailBody;

                                body = string.Format(body, contactName, clientName, replyAddress);

                                body = body.Replace("\r\n", "");

                                string[] to = WinFormsCommon.splitString(contactEmail);
                                string[] cc;

                                cc = WinFormsCommon.splitString(repEmail + ", " + secondaryContact);
                                
                                string dateReq;

                                List<string> attachments = filesToAttach;
                                //attachments.Add("Student Data Format (SpEd) (2).doc");

                                if (autoReq == "True")
                                {
                                    dateReq = toDay.ToShortDateString();

                                    StudentData.StudentDataTrackingRecSave(connSpedmon, clientID, fileTypeID, quarter, dateReq,
                                    null, null, null, null, null, null, null, null, null, null, null, null, userID.ToString(), "1", null);

                                    WinFormsCommon.emailFile(smtp, appEmailFrom, to, cc, "Practi-Cal Student Data Request " + fy + "[Q#" + quarter + " " + clientName + "]", body, attachments);

                                }
                                
                            }
                        }
                        
                    }

                    if (commandLineNumber == 2)
                    {
                       /******************************************************************
                        * if the commandline number is 2, send the reminder email to IT
                        * if the date requested field is still blank after one week of date scheduled.
                        ******************************************************************/
                        
                        string body   = "Hi, " + @"<br/>" +"       This is an automatic email sent from Student data tracking application. " +
                                        "This is a reminder to send the student data requests to all the districts if haven't already. If you have requested already, please add the records in student data application." + @"<br/><br/>";
                        
                        body += "Thank you.";
                        string[] to = WinFormsCommon.splitString(ConfigurationManager.AppSettings["appEmailIT"].ToString());



                        WinFormsCommon.emailFile(smtp, appEmailFrom, to, null, "Practi-Cal Student Data Request not sent!", body, null);                       

                    }

                    if (commandLineNumber == 3)
                    {
                       /******************************************************************
                        * if the commandline number is 3, remind IT to follow-up if the date
                        * recieved field is still blank after two weeks of date requested
                        ******************************************************************/
                       
                        DataTable dt3 = StudentData.StudentDataTrackingView(connSpedmon, "", "", currentQuarter, fiscalYrID, "", "","0","", "1");
                        string body;
                        body = "Hi, " + "  This is an automatic email sent from Student data tracking application. The DATE_RECEIVED field for the following districts " +
                                    " is not filled in the Student data tracking records. " +
                                   "Please followup with the districts and update student data tracking records as soon as the data file is received. " +
                                   "If you have already received the student data file please update student data tracking records." + @"<br/><br/>";
                           
                        foreach (DataRow row in dt3.Rows)
                        {                                
                            clientName  = row["District_Full_ Name"].ToString();
                            fileType    = row["DATA_TYPE"].ToString();
                            if (row["DATE_RECEIVED"].ToString() == "" && row["DATE_REQUESTED"].ToString() != "" && 
                                Convert.ToDateTime(row["DATE_REQUESTED"]).AddDays(14) <= DateTime.Now)
                            {
                                body += "District name: " + clientName + ",  Data Type: " + fileType + @"<br/><br/>";
                                sendEmail = true;
                            }
                        }
                        body += "Thank you.";  
                        string[] to = WinFormsCommon.splitString(ConfigurationManager.AppSettings["appEmailIT"].ToString());
                       
                        if (sendEmail)
                            WinFormsCommon.emailFile(smtp, appEmailFrom, to, null, "Practi-Cal Student Data Request not received!", body, null);
                                                                                           
                    }

                    if (commandLineNumber == 4)
                    {
                        /******************************************************************
                         * if the commandline number is 4, remind IT to follow-up if the date
                         * recieved field is still blank after four weeks of date requested
                         ******************************************************************/
                        
                        DataTable dt3 = StudentData.StudentDataTrackingView(connSpedmon, "", "", currentQuarter, fiscalYrID, "", "", "0","", "1");
                        string body;
                        body = "Hi, " + "  This is an automatic email sent from Student data tracking application. The DATE_RECEIVED field for the following districts " +
                                 " is not filled in the Student data tracking records. " +
                                 "If you have already received the student data file please update student data tracking records." +
                                 " If not please followup with the district and update student data tracking records as soon as the data file is received. " + @"<br/><br/>"
                                 ;
                        foreach (DataRow row in dt3.Rows)
                        {                                
                            clientName  = row["District_Full_ Name"].ToString();
                            fileType    = row["DATA_TYPE"].ToString();
                            if (row["DATE_RECEIVED"].ToString() == "" && row["DATE_REQUESTED"].ToString() != "" && 
                                Convert.ToDateTime(row["DATE_REQUESTED"]).AddDays(28) <= DateTime.Now)
                            {
                                body += "District name: " + clientName + ",  Data Type: " + fileType + @"<br/><br/>";
                                sendEmail = true;
                            }
                        }
                        body += "Thank you.";  

                        string[] to = WinFormsCommon.splitString(ConfigurationManager.AppSettings["appEmailIT"].ToString());
                        
                        if(sendEmail)
                            WinFormsCommon.emailFile(smtp, appEmailFrom, to, null, "Practi-Cal Student Data file not received!", body, null);                                              
                    }

                    WriteLogEntry(@"Emails sent successfully!");
                    WriteLogEntry(@"Exiting normally.");
                }
            }
            catch (Exception ex)
            { /*-------------------------------
               * Exit with errors
               *------------------------------*/
                Database.closeConn(connSpedmon);
                WriteLogEntry(Logger.LogLevel.Alert, ex.Message);
                WriteLogEntry(Logger.LogLevel.Crit, @"Exiting with errors.");

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
        }        

        private void fileTypesToolStripMenuItem_Click(object sender, EventArgs e)
        {
            StudentDataFileTypes form1 = StudentDataFileTypes.GetChildInstance();
            form1.MdiParent = this;
            form1.Show();
            form1.BringToFront();
        }

        private void DataFilesToolStripMenuItem_Click(object sender, EventArgs e)
        {
            StudentDataFiles form1 = StudentDataFiles.GetChildInstance();
            form1.MdiParent = this;
            form1.Show();
            form1.BringToFront();
        }

        private void dataContactToolStripMenuItem_Click(object sender, EventArgs e)
        {
            StudentDataContact form1 = StudentDataContact.GetChildInstance();
            form1.MdiParent = this;
            form1.Show();
            form1.BringToFront();
        }        
                     
        private void viewToolStripMenuItem_Click(object sender, EventArgs e)
        {
            StudentDataTrackingView form1 = StudentDataTrackingView.GetChildInstance(appEmailFrom);
            form1.MdiParent = this;
            form1.Show();
            form1.BringToFront();
        }

        private void saveToolStripMenuItem_Click(object sender, EventArgs e)
        {
            StudentDataTrackingEdit editForm = StudentDataTrackingEdit.GetChildInstance();
            editForm.MdiParent = this;
            editForm.Show();
            editForm.BringToFront();
        }       

        private void StudentDataTracking_FormClosing(object sender, FormClosingEventArgs e)
        {
            DialogResult d = new DialogResult();
           
            d = MessageBox.Show("Are you sure you want to exit the application?", "Student data application", MessageBoxButtons.YesNo);
            if (d == DialogResult.No)
                e.Cancel = true;
        }
       
    }
}
