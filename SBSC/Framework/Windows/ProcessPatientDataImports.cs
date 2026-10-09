using MBA;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace Spedmon
{
    public class ProcessPatientDataImports : BatchApplication
    {
        private static Mutex                                      _mtx              = new Mutex();
        private static List<StructuredDataImportFilePatientData>  _dataImports      = null;
        private static int                                        _dataImportsCount = 0;

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
                _dataImports = null;
                _dataImports = StructuredDataImportFilesPatientData.viewList(dbConnApp,log, uInfo, "","Y","","");
                if (_dataImports != null) _dataImportsCount = _dataImports.Count;
            }
            catch (Exception _err)
            {
                 DisplayNotice(Return.RET_CRITICAL, _err.Message);
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

                DisplayNotice(Return.RET_INFO, "There are {0} incoming file(s) that are ready to be processed", _dataImportsCount.ToString());

                if (_dataImportsCount == 0) return result;
                
                foreach (StructuredDataImportFilePatientData dataImport in _dataImports)
                {
                    if (cancelApp) break;
                    DisplayNotice(Return.RET_INFO, "Processing {0} from {1} [{2}]", dataImport.fileProfileName, dataImport.clientName, dataImport.fileName);
                    StructuredDataImportFilesPatientData.matchData (dbConnApp,log,uInfo,dataImport.clientID,dataImport.id);
                    if (cancelApp) break;                   
                } /* Imports */

            }
            catch (Exception _err)
            {
                DisplayNotice(Return.RET_CRITICAL, _err.Message);
                result = false;
            }
            return result;
        }

        /***************************************************************************
         * StartProcessingImportedDataFileDelegate */
        /**
         * Entry delegate
         ***************************************************************************/
        static void StartProcessingImportedDataFilesDelegate()
        {
            if (!GetUnprocessedFileList())     return;
            if (!ProcessUnprocessedFileList()) return;
        }
    
        /***************************************************************************
         * StartProcessingFiles */
        /**
         * Entry point
         ***************************************************************************/
        public static void StartProcessingImportedDataFiles(string[] args = null)
        {

            /*============================================================
             * Enter application
             *============================================================*/

            try
            {            
                /*-------------------------------
                 * Define main delegate
                 *------------------------------*/

                GenericCallBack mainDel = delegate { StartProcessingImportedDataFilesDelegate(); };

                /*-------------------------------
                 * Start the application
                 *------------------------------*/
               
                 enter ( Spedmon.Constants.APP_NAME
                        , "Process Imported Student Data Files"
                        , Spedmon.Constants.APP_VERSION
                        , ref args
                        , ref mainDel);
                
            }

            /*============================================================
             * Exception handler of last resort
             *============================================================*/

            catch (Exception _err)
            {
                /*-------------------------------
                 * Let the user know and indicate
                 * a fatal state in our exit state
                 *------------------------------*/

                DisplayNotice(Return.RET_FATAL, _err.Message);
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
