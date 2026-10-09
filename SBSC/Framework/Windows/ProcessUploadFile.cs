using MBA;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace Spedmon
{
    public class ProcessUploadFile : BatchApplication
    {
        protected static string _scanAppWorkingDir = @"C:\spedmon\data\files\File-Uploads";
        protected static string _scanApp           = @"C:\Program Files\ESET\ESET NOD32 Antivirus\ecls.exe";
        protected static string _scanLogFolder     = @"c:\spedmon\data\files\File-Uploads\AV-Scan-Logs";
        protected static string _scanAppArguments  = @"/log-all /log-rewrite /log-file=""{0}"" ""{1}""";
        protected static string _appEnvironment    = "1";
        protected static long   _appEnvironmentID    = 0;

        protected static List<FileUpload> fileUploads = null;
        protected static int _fileUploadsCount = 0;

        protected static AntivirusApp avsd;

        protected delegate void avHandler(object sender, AntivirusProgress e);

        /***************************************************************************
         * GetAndCheckAppSettings() */
        /**
         * Get application settings
         ***************************************************************************/

        static bool GetAndCheckAppSettings()
        {

            bool _result = true;

            try
            {
                DisplayNotice(Return.RET_INFO, "Getting application settings");

                _appEnvironment    = Constants.getAppSetting("appEnvironment", "0");
                _scanAppWorkingDir = Constants.getAppSetting("scanAppWorkingDir", "");
                _scanApp           = Constants.getAppSetting("scanApp", "");
                _scanLogFolder     = Constants.getAppSetting("scanLogFolder", "");

                if (_appEnvironment == "0")
                {
                    DisplayNotice(Return.RET_ERROR, "No app environment setting.");
                    _result = false;
                }

                if (_scanAppWorkingDir == "")
                {
                    DisplayNotice(Return.RET_ERROR, "No scan app working dir setting.");
                    _result = false;
                }

                if (_scanApp == "")
                {
                    DisplayNotice(Return.RET_ERROR, "No scan app setting.");
                    _result = false;
                }

                if (_scanLogFolder == "")
                {
                    DisplayNotice(Return.RET_ERROR, "No scan log folder setting.");
                    _result = false;
                }

                if (!long.TryParse(_appEnvironment, out _appEnvironmentID))
                {
                    DisplayNotice(Return.RET_ERROR, "Invalid app environment");
                    _result = false;

                }
                else
                {
                    if ((_appEnvironmentID < 1) || (_appEnvironmentID > 3))
                    {
                        DisplayNotice(Return.RET_ERROR, "Invalid app environment");
                        _result = false;
                    }
                }

            }
            catch
            {
                _result = false;
            }

            return _result;

        }

        /***************************************************************************
         * SetupExternalApplications */
        /**
         * Setup antivirus check
         ***************************************************************************/

        static bool SetupExternalApplications()
        {
            bool _result = true;

            try
            {
                if (!Directory.Exists(_scanLogFolder)) Directory.CreateDirectory(_scanLogFolder);
                avsd = AntivirusApp.Create(AntivirusApp.SCAN_APP_ESET, _scanAppWorkingDir);
                DisplayNotice(Return.RET_INFO, "Setting up AV scan app");
                DisplayNotice(Return.RET_INFO, avsd.scanApp);

                if (!avsd.scanAppExists)
                { 
                  DisplayNotice(Return.RET_WARNING, "AV scan app not found");
                }
                
            }
            catch
            {
                _result = false;
            }
            return _result;
        }
        
        /***************************************************************************
         * GetUnprocessedFileList */
        /**
         * Gets list of files ready to be processed
         ***************************************************************************/

        static bool GetUnprocessedFileList()
        {

            bool _result = true;

            try
            {
                DisplayNotice(Return.RET_INFO, "Checking for incoming files that are ready to be processed");
                fileUploads = null;
                fileUploads = FileUploads.viewFileUploadsToProcessDataList (dbConnApp, log, uInfo, _appEnvironmentID);
                if (fileUploads != null) _fileUploadsCount = fileUploads.Count;
            }
            catch (Exception _exception)
            {
                _result = false;
            }

            return _result;

        }

        /***************************************************************************
         * ProcessUnprocessedFileList */
        /**
         * Process the list
         ***************************************************************************/

        static bool ProcessUnprocessedFileList()
        {

            bool result = true;

            try
            {

                DisplayNotice(Return.RET_INFO, "There are {0} incoming file(s) that are ready to be processed", _fileUploadsCount.ToString());

                if (_fileUploadsCount == 0) return result;
                
                foreach (FileUpload fileUpload in fileUploads)
                {
                    if (cancelApp) break;
                    bool processOK = true;

                    FileUpload fileUploadIn = fileUpload;
                    FileUpload fileUploadOut = fileUpload;

                    DisplayNotice(Return.RET_INFO, fileUpload.savedName);
                    
                    if (fileUpload.fileIsGenerated == true)
                    { 
                      result = FileUploads.processGeneratedFileUpload (  dbConnApp
                                                                         , log
                                                                         , uInfo
                                                                         , _appEnvironmentID
                                                                         , fileUploadIn.id
                                                                         , fileUploadIn
                                                                         , fileUploadIn.receiveOriginalRootPathFilename
                                                                         , avsd
                                                                         , _scanLogFolder
                                                                         , out fileUploadOut
                                                                         , out processOK);
                    }
                    else
                    { 
                      result = FileUploads.processNewIncomingFileUpload (  dbConnApp
                                                                         , log
                                                                         , uInfo
                                                                         , _appEnvironmentID
                                                                         , fileUploadIn.id
                                                                         , fileUploadIn
                                                                         , fileUploadIn.receiveOriginalRootPathFilename
                                                                         , avsd
                                                                         , _scanLogFolder
                                                                         , out fileUploadOut
                                                                         , out processOK);
                    }
                } // File uploads      

            }
            catch
            {
                result = false;
            }
            return result;
        }

        /***************************************************************************
         * StartProcessingFiles */
        /**
         * Entry delegate
         ***************************************************************************/
        static void StartProcessingUploadedFileDelegate()
        {
            if (!GetAndCheckAppSettings()) return;
            if (!SetupExternalApplications()) return;


            if (!GetUnprocessedFileList()) return;
            if (!ProcessUnprocessedFileList()) return;
        }

        /***************************************************************************
         * StartProcessingFiles */
        /**
         * Entry point
         ***************************************************************************/
        public static void StartProcessingFiles(string[] args = null)
        {
     
            /*============================================================
             * Enter application
             *============================================================*/

            try
            {

                /*-------------------------------
                 * Define main delegate
                 *------------------------------*/

                GenericCallBack mainDel = delegate { StartProcessingUploadedFileDelegate(); };

                /*-------------------------------
                 * Start the application
                 *------------------------------*/

                  enter ( Spedmon.Constants.APP_NAME
                          , "Process Incoming Files"
                          , Spedmon.Constants.APP_VERSION
                          , ref args
                          , ref mainDel);
                
            }

            /*============================================================
             * Exception handler of last resort
             *============================================================*/

            catch (Exception e)
            {
                /*-------------------------------
                 * Let the user know and indicate
                 * a fatal state in our exit state
                 *------------------------------*/

                DisplayNotice(Return.RET_FATAL, e.Message);
                exitState = Return.RET_FATAL;
            }

            /*============================================================
             * Clean up
             *============================================================*/

            finally
            {
                cleanup();
            }

        }
    }
}
