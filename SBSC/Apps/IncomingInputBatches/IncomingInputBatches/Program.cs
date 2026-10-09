using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;
using System.Configuration;
using System.Net.Configuration;
using System.Security.Permissions;
using System.Data;
using System.Data.SqlClient;
using System.Net.Mail;
using System.Net.Mime;
using MBA;

using iTextSharp;
using iTextSharp.text;
using iTextSharp.text.pdf;

namespace IncomingInputBatches
{
    class Program
    {

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
         * SendFilesToAnI */
        /**
         * 
         ***************************************************************************/

        private static void SendFilesToAnI(string filepath, FileInfo[] fi, string subject, string message)
        {
            try
            {
                long totalFileSizeinKB = 0;
                if (fi.Length > 0)
                {
                    SmtpSection smtpSection = ConfigurationManager.GetSection("system.net/mailSettings/smtp") as SmtpSection;
                    SmtpClient sc = new SmtpClient(smtpSection.Network.Host.ToString());
                    sc.Timeout = 1000000;
                    MailMessage mm = new MailMessage(smtpSection.From.ToString(), Program.EmailTo); ;
                    
                    foreach (FileInfo f in fi)
                    {
                        mm.Subject = subject;                       
                       
                        mm.Body = message + "Sending back\r\n";
                        mm.Body = mm.Body + f.Name + " \r\n";
                        ContentType ct = new ContentType(@"application/pdf");
                        Attachment ma = new Attachment(filepath + f.Name, ct);
                        ma.Name = f.Name;
                        mm.Attachments.Add(ma);
                        WriteLogEntry(@"Sending back " + f.Name + ". Reason : " + subject.Substring(subject.IndexOf("-") + 1));

                        totalFileSizeinKB += f.Length / 1024;
                        /*-------------------------------------------------------
                         * if the total size of the attachments greater than 20 mb
                         * send mail will fail due to size limit.
                         * so we are dividing the attachments in groups and sending 
                         * separate emails.
                         *-------------------------------------------------------*/
                        if ((totalFileSizeinKB / 1024) > 15)
                        {
                            mm.Body = mm.Body + " \r\n" + emailSignature;                           
                            sc.Send(mm);
                            totalFileSizeinKB = 0;
                            mm.Dispose();
                            mm = new MailMessage(smtpSection.From.ToString(), Program.EmailTo);
                            sc = new SmtpClient(smtpSection.Network.Host.ToString());
                        }
                    }

                    if (totalFileSizeinKB > 0)
                    {
                        mm.Body = mm.Body + " \r\n" + emailSignature;
                        sc.Send(mm);
                    }
                }
            }
            catch (Exception e)
            {
                throw new Warning(e.Message);
            }
        }
       
       
        /***************************************************************************
         * Properties */
        /**
         * Various properties
         ***************************************************************************/
        
        protected static SqlConnection conn;
        protected static string connstr;
        protected static string basePath;
        protected static string oldPath;

        protected static string localPath;
        protected static string EmailTo;
        protected static string EmailCc;
        protected static string EmailMc;

        protected static string PATH_IncomingBatchesFromAnI;
        protected static string PATH_TooLarge;
        protected static string PATH_InCorrectFileName;
        protected static string PATH_DuplicateFiles;

        protected static string PATH_Archive;
        protected static string PATH_WorkinProcess;
        protected static string PATH_CorruptedForms;

        protected static string emailSignature = "Thanks,\r\n\r\n" +
                                 "Mail@Practi-Cal.com\r\n" +
                                 "School Business Services of California, Inc.\r\n" +
                                 "1275 Halyard Drive Suite 150\r\n" +
                                 "West Sacramento, CA 95691\r\n" +
                                 "Phone: (877) 957-7272\r\n" +
                                 "Fax: (916) 375-1735\r\n\r\n" +
                                 "CONFIDENTIALITY: This communication and any documents, files, or previous e-mail messages attached to it constitute an electronic communication within " +
                                 "the scope of the Electronic Communication Privacy Act, 18 USCA 2510. This communication may contain non-public, confidential, or legally privileged information " +
                                 "intended for the sole use of the designated recipient(s). The unlawful interception, use or disclosure of such information is strictly prohibited under 18 USCA 2511 " +
                                 "and any applicable laws. If you are not the intended recipient of this communication, you are hereby notified to destroy all copies of this e-mail message and to contact the sender.";


        /***************************************************************************
         * Main */
        /**
         * Our entry point for the application
         ***************************************************************************/

        private static FileInfo[] fi;
        private static FileInfo[] fiIncorrect;
        private static FileInfo[] fiBig;
        private static FileInfo[] fiCorrupt;
        private static FileInfo[] fiDup;


        private static DirectoryInfo sourcedrcty;
        private static DirectoryInfo IncorrectFiles;
        private static DirectoryInfo TooLargeFiles;
        private static DirectoryInfo CorruptedFiles;
        private static DirectoryInfo DuplicateFiles;

        static void Main(string[] args)
        {
            try
            {
                /*-------------------------------
                 * Replace app config with our
                 * own
                 *------------------------------*/

                AppDomain.CurrentDomain.SetData("APP_CONFIG_FILE", "IncomingInputBatches.config");

                /*-------------------------------
                 * Get and create various values
                 *------------------------------*/

                string appname    = WindowsApplication.GetExeName();
                string configname = WindowsApplication.GetAppConfigName();
                string filename;
                DateTime today =  DateTime.Now;
                /*-------------------------------
                 * Test to see if a config file
                 * exists and if it does not
                 * throw an exception
                 *------------------------------*/

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

                // Start up code here (initiatization, etc)

                /*-------------------------------
                 * Fetch base path for workflow
                 * and init folder locations
                 *------------------------------*/

                WriteLogEntry(@"Fetching settings");

                basePath  = ConfigurationManager.AppSettings["basePath"].ToString();
                oldPath   = ConfigurationManager.AppSettings["oldPath"].ToString();
                localPath = ConfigurationManager.AppSettings["localPath"].ToString();
                EmailTo   = ConfigurationManager.AppSettings["appEmailTo"].ToString();
                EmailCc   = ConfigurationManager.AppSettings["appEmailCc"].ToString();
                EmailMc   = ConfigurationManager.AppSettings["appEmailMc"].ToString();
                connstr   = ConfigurationManager.ConnectionStrings["Spedmon"].ConnectionString.ToString();

                PATH_IncomingBatchesFromAnI = basePath + Program.oldPath + @"01 Work in Process\01 Ready to Batch\";
                PATH_Archive = basePath + Program.oldPath + @"08 Archive\Scans\";
                /*--------------------------------------------------------------------------------
                 * Base path is different on development,test and live servers, so do not save the
                 * base path in the database.
                 *------------------------------------------------------------------------------*/
                PATH_WorkinProcess     = Program.oldPath + @"Work in Process\";

                //local working folders
                PATH_TooLarge          = Program.localPath + @"TooLargeFiles\";
                PATH_InCorrectFileName = Program.localPath + @"InCorrectFileName\";
                PATH_DuplicateFiles    = Program.localPath + @"DuplicateFiles\";
                PATH_CorruptedForms    = Program.localPath + @"CorruptedFiles\";

                sourcedrcty    = new DirectoryInfo(PATH_IncomingBatchesFromAnI);
                IncorrectFiles = new DirectoryInfo(PATH_InCorrectFileName);
                TooLargeFiles  = new DirectoryInfo(PATH_TooLarge);
                CorruptedFiles = new DirectoryInfo(PATH_CorruptedForms);
                DuplicateFiles = new DirectoryInfo(PATH_DuplicateFiles);


                WriteLogEntry(@"PATH_Archive                 = " + PATH_Archive);
                WriteLogEntry(@"PATH_IncomingBatchesFromAnI  = " + PATH_IncomingBatchesFromAnI);
                WriteLogEntry(@"PATH_WorkinProcess           = " + PATH_WorkinProcess);
                WriteLogEntry(@"PATH_TooLarge                = " + PATH_TooLarge);
                WriteLogEntry(@"PATH_InCorrectFiles          = " + PATH_InCorrectFileName);
                WriteLogEntry(@"PATH_CorruptedFiles          = " + PATH_CorruptedForms);
                WriteLogEntry(@"PATH_DuplicateFiles          = " + PATH_DuplicateFiles);

                /*--------------------------------------------
                 * Clean up the files in the following folders 
                 * since they have already been sent back 
                 *-------------------------------------------*/

                WriteLogEntry(@"Cleaning up old files");

                fiIncorrect = IncorrectFiles.GetFiles();
                foreach (FileInfo f in fiIncorrect)
                    System.IO.File.Delete(PATH_InCorrectFileName + f.Name);

                fiBig = TooLargeFiles.GetFiles();
                foreach (FileInfo f in fiBig)
                    System.IO.File.Delete(PATH_TooLarge + f.Name);

                fiCorrupt = CorruptedFiles.GetFiles();
                foreach (FileInfo f in fiCorrupt)
                    System.IO.File.Delete(PATH_CorruptedForms + f.Name);

                fiDup = DuplicateFiles.GetFiles();
                foreach (FileInfo f in fiDup)
                    System.IO.File.Delete(PATH_DuplicateFiles + f.Name);

                string sourceFile;
                string destination;
                string archiveFile;

                if (!sourcedrcty.Exists) throw new Exception("Source directory does not exist");


                /*-------------------------------
                 * Processing
                 *------------------------------*/

                WriteLogEntry(@"Looking for new files");

                // Processing code here

                /*-------------------------------
                 * Get info about files in path
                 *------------------------------*/

                fi = sourcedrcty.GetFiles("*.pdf");

                if (fi.Length > 0)
                    WriteLogEntry(@"Found new files");
                else
                    WriteLogEntry(@"No new files");

                conn = Database.openConn(connstr);

                SqlCommand comm = conn.CreateCommand();

                object vRecID      = null;
                object vStatusCode = null;
                object vClientID   = null;
                object vType       = null;
                string vDupMsg     = null;
                string sql2;
                string CDS;
                string clientShorname;
                string datesentstr = "";
                string workType;
                Regex rx = new Regex(@"(\d{8})-(.+-?.+)-(\d{7})-(\w+-?\w+).");

                DateTime dateSent = today;
                bool saveRec;
                int vSaveType = 1;

                List<SqlParameter> parms = new List<SqlParameter>();

                parms.Add(Database.SqlParm("@parentID", SqlDbType.BigInt, null, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@partial",         SqlDbType.Bit,      0,         ParameterDirection.Input));
                parms.Add(Database.SqlParm("@oldest_dos",      SqlDbType.DateTime, vRecID,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@dateRecieved",    SqlDbType.DateTime, null,      ParameterDirection.Input));
                parms.Add(Database.SqlParm("@estmtedinpthrs",  SqlDbType.Decimal,  vRecID,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@userID1",         SqlDbType.BigInt,   vRecID,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@userID2",         SqlDbType.BigInt,   vRecID,    ParameterDirection.Input));
                parms.Add(Database.SqlParm("@priorityNum",     SqlDbType.SmallInt, 0,         ParameterDirection.Input));
                parms.Add(Database.SqlParm("@degreeofdifcult", SqlDbType.SmallInt, 0,         ParameterDirection.Input));
                parms.Add(Database.SqlParm("@note",            SqlDbType.VarChar,  vDupMsg,   ParameterDirection.Input));
                parms.Add(Database.SqlParm("@editDelReason",   SqlDbType.VarChar,  "",        ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@validateRec",     SqlDbType.Bit,      0,         ParameterDirection.Input));
                parms.Add(Database.SqlParm("@saveType",        SqlDbType.Int,      vSaveType, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@recID",           SqlDbType.BigInt,   vRecID,    ParameterDirection.Input));

                parms.Add(Database.SqlParm("@MsgNotActive",    SqlDbType.VarChar,  vDupMsg,   ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgDupRec",       SqlDbType.VarChar,  vDupMsg,   ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoRec",        SqlDbType.VarChar,  vDupMsg,   ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgNoEdit",       SqlDbType.VarChar,  vDupMsg,   ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@MsgDataError",    SqlDbType.VarChar,  vDupMsg,   ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@recordID",        SqlDbType.BigInt,   null,      ParameterDirection.Output));

                parms.Add(Database.SqlParm("@typeofwork",      SqlDbType.BigInt,   null,      ParameterDirection.Input));
                parms.Add(Database.SqlParm("@clientID",        SqlDbType.BigInt,   null,      ParameterDirection.Input));
                parms.Add(Database.SqlParm("@dateSent",        SqlDbType.DateTime, null,      ParameterDirection.Input));
                parms.Add(Database.SqlParm("@statuscode",      SqlDbType.SmallInt, null,      ParameterDirection.Input));
                parms.Add(Database.SqlParm("@filename",        SqlDbType.VarChar,  null,      ParameterDirection.Input, 7000));
                parms.Add(Database.SqlParm("@fileLocation",    SqlDbType.VarChar,  null,      ParameterDirection.Input, 7000));
                 
                iTextSharp.text.Document document = new iTextSharp.text.Document(PageSize.LETTER);

                PdfWriter writer = PdfWriter.GetInstance(document, new MemoryStream());
                document.Open();

                PdfContentByte cb = writer.DirectContent;
                //cb.PdfWriter.SetPdfVersion(PdfWriter.PDF_VERSION_1_3);

                /*-------------------------------
                 * Main processing loop
                 *------------------------------*/

                foreach (FileInfo f in fi)
                {
                    WriteLogEntry(f.Name);
                    filename = f.Name;
                    Match m  = rx.Match(f.Name);
                    DateTime adjDateSent = dateSent;

                    if (m.Success)
                        workType = m.Groups[4].ToString();
                    else workType = "";

                    filename = f.Name.ToUpper();
                    /*---------------------------------------------------------
                     * if the file is sent on a friday after 12:00pm it is 
                     * considered as it is sent on following monday. so we have 
                     * to change the date on the file name and the date sent field.
                     * -------------------------------------------------------*/

                    if (dateSent.DayOfWeek == DayOfWeek.Friday && today.Hour >= 12 && today.DayOfWeek == DayOfWeek.Friday)
                        adjDateSent = dateSent.AddDays(3);
                    if (dateSent.DayOfWeek == DayOfWeek.Saturday)
                        adjDateSent = dateSent.AddDays(2);
                    if (dateSent.DayOfWeek == DayOfWeek.Sunday)
                        adjDateSent = dateSent.AddDays(1);

                    if ((dateSent.DayOfWeek == DayOfWeek.Friday && today.Hour >= 12) || (dateSent.DayOfWeek == DayOfWeek.Saturday) || (dateSent.DayOfWeek == DayOfWeek.Sunday))
                    {
                        filename = f.Name.Replace(dateSent.ToString("yyyyMMdd"), adjDateSent.ToString("yyyyMMdd"));
                        //filename = filename.Replace(".PDF", "(f).pdf");
                        filename = filename.Substring(0, filename.Length - 4);
                        if (!System.IO.File.Exists(PATH_Archive + filename + "(f).PDF"))
                            filename = filename + "(f).PDF";
                        else if (!System.IO.File.Exists(PATH_Archive + filename + "(f1).PDF"))
                            filename = filename + "(f1).PDF";
                        else filename = filename + "(f2).PDF";
                        dateSent = adjDateSent;
                    }

                    /*-------------------------------------------
                     * Look for a duplicate file in the archive
                     * directory and if one exists append a duplicate
                     * indicator to the file.
                     *-------------------------------------------*/
                    try
                    {
                        if (System.IO.File.Exists(PATH_Archive + filename))
                        {
                            WriteLogEntry(@f.Name + " is a duplicate.");
                            WriteLogEntry("Copying " + filename + " from " + PATH_IncomingBatchesFromAnI + " to " + PATH_DuplicateFiles);

                            f.CopyTo(PATH_DuplicateFiles + f.Name, true);

                            string dupfileName = filename;
                            dupfileName = dupfileName.Replace(f.Extension, string.Empty);
                            WriteLogEntry("Copying " + filename + " from " + PATH_IncomingBatchesFromAnI + " to " + PATH_Archive);
                            archiveFile = PATH_Archive + dupfileName + "DupFileName.pdf";
                            f.CopyTo(archiveFile, true);

                            f.Delete();
                            continue;
                        }
                    }
                    catch
                    {
                        continue;
                    }

                    /*-------------------------------------------
                     * Insert a row in SPEDMON.DBO.INPUT_BATCHES TABLE 
                     * for each file in source directory .
                     *-------------------------------------------*/

                    int pages = 0;
                    sourceFile = PATH_IncomingBatchesFromAnI + f.Name;

                    destination = PATH_WorkinProcess;

                    try
                    {
                        PdfReader reader = new PdfReader(sourceFile);
                        pages = reader.NumberOfPages;
                        reader.Info["Producer"] = "";
                        vStatusCode = 10;
                        /*-------------------------------------------
                         * Except for 1-1 files
                         * If file is too large move it to TooLarge folder                     
                         *
                         * TODO: Move rule to maxincomingpagesize config
                         * setting
                         *-------------------------------------------*/
                        if (!workType.Contains("1-1") && (pages > 60))
                        {
                            WriteLogEntry(@f.Name + " exceeds page limit");
                            destination = PATH_TooLarge;
                            vStatusCode = 320;
                        }
                       
                    }
                    catch
                    {                       
                        continue;
                    }

                    archiveFile = PATH_Archive + filename;
                    f.CopyTo(archiveFile, true);
                    //if file is corrupted or too large move it and continue to next file
                    if (Convert.ToInt16(vStatusCode) == 320 || Convert.ToInt16(vStatusCode) == 330)
                    {
                        WriteLogEntry("Copying " + f.Name + " from " + PATH_IncomingBatchesFromAnI + " to " + destination);
                        f.CopyTo(destination + f.Name, true);
                        f.Delete();
                        continue;
                    }

                    saveRec = true;

                    /*-------------------------------------------
                     * Verify if the file name is in correct format
                     * as per bussiness rule and all the information
                     * supplied are valid using regular expressions
                     * 
                     * for example : 20121024-ELKGROVE-3467314-HS.pdf
                     * is in correct format, 
                     * the date 20121024 in the file name, the district
                     * short name - ELKGROVE or CDS - 3467314 and the 
                     * Work type - HS are all correct.
                     * if any of these is incorrect it is considered as 
                     * incorrect file name                                 
                     *-------------------------------------------*/

                   
                    if (m.Success)
                    {
                        datesentstr = m.Groups[1].ToString();
                        datesentstr = datesentstr.Substring(0, 4) + "-" + datesentstr.Substring(4, 2) + "-" + datesentstr.Substring(6, 2);
                    }

                    if (m.Success && DateTime.TryParse(datesentstr, out dateSent))
                    {
                        clientShorname = m.Groups[2].ToString();
                        CDS = m.Groups[3].ToString();
                        workType = m.Groups[4].ToString();

                        sql2 = "select CLIENT_ID from CLIENTS_Client where ShortName = @clientShortName or CLIENT_CDS = @clientCDS";
                        comm.Parameters.Add("@clientShortName", System.Data.SqlDbType.VarChar);
                        comm.Parameters["@clientShortName"].Value = clientShorname;
                        comm.Parameters.Add("@clientCDS", System.Data.SqlDbType.VarChar);
                        comm.Parameters["@clientCDS"].Value = CDS;
                        comm.CommandText = sql2;
                        vClientID = comm.ExecuteScalar();

                        comm.Parameters.Clear();

                        //sql2 = "select id from TYPE_OF_WORK where @workType = WorkCode";
                        sql2 = "select id from TYPE_OF_WORK where @workType like WorkCode+'%'";
                        comm.Parameters.Add("@workType", System.Data.SqlDbType.VarChar);
                        comm.Parameters["@workType"].Value = workType;
                        comm.CommandText = sql2;
                        vType = comm.ExecuteScalar();
                    }
                    else saveRec = false;

                    if (vClientID == null || vType == null) saveRec = false;

                    if (saveRec)
                    {
                        Database.replaceParameterValue("@typeofwork",   vType,       ref parms);
                        Database.replaceParameterValue("@clientID",     vClientID,   ref parms);
                        Database.replaceParameterValue("@dateSent",     dateSent,    ref parms);
                        Database.replaceParameterValue("@statuscode",   vStatusCode, ref parms);
                        Database.replaceParameterValue("@filename",     filename,    ref parms);
                        Database.replaceParameterValue("@fileLocation", destination, ref parms);
                        if (Convert.ToInt16(vStatusCode) == 330)
                            WriteLogEntry("Copying " + f.Name + " from " + PATH_IncomingBatchesFromAnI + " to " + basePath + destination);
                        f.CopyTo(basePath + destination + filename, true);

                        ReturnDB rd = Database.execSproc(conn, dlog, "INPUTBATCHES_SAVE", parms);
                    }
                    else
                    {
                        WriteLogEntry("Copying " + f.Name + " from " + PATH_IncomingBatchesFromAnI + " to " + PATH_InCorrectFileName);
                        f.CopyTo(PATH_InCorrectFileName + f.Name, true);
                    }

                    //delete file from the source after moving.
                    f.Delete();
                }


                /*-------------------------------
                 * Exit normally
                 *------------------------------*/

                // Exit code here

                WriteLogEntry(@"Exiting Normally");
                retcode = (int)ExitCode.Success;
            }

            catch (Exception e)
            {

                /*-------------------------------
                 * Exit with errors
                 *------------------------------*/
                WriteLogEntry(Logger.LogLevel.Alert, e.Message);
                WriteLogEntry(Logger.LogLevel.Crit, @"Exiting with errors");

                retcode = (int)ExitCode.OtherError | (int)ExitCode.Failure;

            }

            finally
            {
                fiIncorrect = IncorrectFiles.GetFiles();

                SendFilesToAnI(PATH_InCorrectFileName, fiIncorrect,
                               "PROBLEM: Batch(s) with Incorrect Filename",
                               "Hi Chuck and Claims,\r\n\r\n" +
                               "We have received the attached batch(s) that were not named using the correct filename format.\r\n\r\n" +
                               "If you have any questions, please let us know. Otherwise, we look forward to receiving the renamed file(s) very soon.\r\n\r\n"
                               );
                fiBig = TooLargeFiles.GetFiles();
                SendFilesToAnI(PATH_TooLarge, fiBig,
                              "PROBLEM: Batch File(s) are Too Big",
                              "Hi Chuck and Claims,\r\n\r\n" +
                              "We have received the attached batch file(s) that are too big.  Please split the file(s) so each batch includes no more than 30 pages.\r\n\r\n" +
                              "If you have any questions, please let us know. Otherwise, we look forward to receiving the smaller files very soon.\r\n\r\n"
                               );
                fiCorrupt = CorruptedFiles.GetFiles();
                SendFilesToAnI(PATH_CorruptedForms, fiCorrupt,
                              "PROBLEM: Batch File(s) are Corrupted",
                              "Hi Chuck and Claims,\r\n\r\n" +
                              "We have received the attached batch file(s) that are corrupted and won’t open.\r\n\r\n" +
                              "If you have any questions, please let us know. Otherwise, we look forward to receiving the corrected file(s) very soon.\r\n\r\n"
                               );
                fiDup = DuplicateFiles.GetFiles();
                SendFilesToAnI(PATH_DuplicateFiles, fiDup,
                              "PROBLEM: Batch(s) with Duplicate Filename",
                              "Hi Chuck and Claims,\r\n\r\n" +
                              "We have received the attached batch(s) with a filename that has already been used. \r\n\r\n" +
                              "If the work is different in the two batches with same file name, please rename and resubmit. \r\n\r\n" +
                              "If you have any questions, please let us know. Otherwise, we look forward to receiving the renamed file(s) very soon.\r\n\r\n"
                               );

                /*-------------------------------
                 * Close database connections
                 * log files, etc
                 *------------------------------*/

                Database.closeConn(conn);

                if (log != null)
                    log.Dispose();

                Environment.Exit(retcode);
            }
        }

    }

}
