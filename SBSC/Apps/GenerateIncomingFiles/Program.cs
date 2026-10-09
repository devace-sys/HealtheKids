using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.IO;
using System.Web;
using Spedmon;
using MBA;


namespace Spedmon
{
  
  /***************************************************************************
   * GenerateIncomingFilesApp */
  /**
   * Application class
   ***************************************************************************/   

  class GenerateIncomingFilesApp:BatchApplication
  {
     protected static List<ServiceAuthorizationRequestPermanentRecord> sarRequestPermRecords = null;
     protected static int _sarPermRecRequestCount = 0;

    
    /***************************************************************************
     * GetAndCheckAppSettings() */
    /**
     * Get application settings
     ***************************************************************************/ 

    static bool GetAndCheckAppSettings ()
    {

      bool _result = true;
      
      try
      {
        DisplayNotice (Return.RET_INFO,"Getting application settings");
   
                
      }
      catch
      {
        _result = false;        
      }
      
      return _result;
      
    }
        /***************************************************************************
         * GetPendingServiceAuthorizationRequestPermanentRecordsList */
        /**
         * Gets list of files ready to be processed
         ***************************************************************************/
        static bool GetPendingServiceAuthorizationRequestPermanentRecordsList()
        {

            bool _result = true;

            try
            {
                DisplayNotice(Return.RET_INFO, "Checking for pending service authorization permanent record requests");
                _sarPermRecRequestCount = 0;
                sarRequestPermRecords = null;
                sarRequestPermRecords = ServiceAuthorizationRequestsPermanentRecords.viewDataList (   dbConnApp
                                                                                                    , log
                                                                                                    , uInfo
                                                                                                    , ""
                                                                                                    , "Y"
                                                                                                    , "Y"
                                                                                                    , "Y"
                                                                                                    , ""
                                                                                                    , ""
                                                                                                    , "");

                if (sarRequestPermRecords != null)
                    _sarPermRecRequestCount = sarRequestPermRecords.Count();

            }
            catch
            {
                _result = false;
            }

            return _result;

        }

        static bool GenerateServiceAuthorizationRequestPermanentRecord(ServiceAuthorizationRequestPermanentRecord sarRequestPermRec)
        {
            UserInfo requestPermRecCreatedBy = null;
            ReturnFileBytes rfb = null;
            ReturnSaveRecord rsr = null;
            ReturnSaveRecord sfup = null;
            
            try
            {
                var rui = MBA.UserInfo.retrieveUserInfo(dbConnUser, log, "spedcare", sarRequestPermRec.createdBy, ref requestPermRecCreatedBy);
            }
            catch
            {
                return false;
            }

            try
            {
                rfb = ServiceAuthorizationCommon.generateRequestResponseFile( dbConnApp
                                                                              , log
                                                                              , requestPermRecCreatedBy
                                                                              , sarRequestPermRec.requestID.ToString());
            }
            catch (Exception rfbErr)
            {
                DisplayNotice(Return.RET_ERROR, rfbErr.Message);
                return false;
            }
            
            try
            {
                rsr = StoredFiles.save ( dbConnApp
                                        , log
                                        , uInfo
                                        , sarRequestPermRec.fileClass.ToString()
                                        , ""
                                        , ""
                                        , sarRequestPermRec.fileNameSpace
                                        , sarRequestPermRec.fileSource
                                        , sarRequestPermRec.clientID.ToString()
                                        , MBA.Util.zeroOrNullToEmptyStrOrValueStr(sarRequestPermRec.orpPracID)
                                        , MBA.Util.zeroOrNullToEmptyStrOrValueStr(sarRequestPermRec.patID)
                                        , MBA.Util.zeroOrNullToEmptyStrOrValueStr(sarRequestPermRec.referencedEntityID)
                                        , rfb
                                        , @""
                                        , @"N"
                                        , Constants.SAVE_TYPE_NEW.ToString()
                                        , "");
            }
            catch (Exception sfsErr)
            {
                DisplayNotice(Return.RET_ERROR, sfsErr.Message);
                return false;
            }

            try
            {
                sfup = ServiceAuthorizationRequestsPermanentRecords.setFileUploadPending (  dbConnApp
                                                                                          , log
                                                                                          , uInfo
                                                                                          , "N"
                                                                                          , rsr.recordID.ToString()
                                                                                          , ""
                                                                                          , "N"
                                                                                          , sarRequestPermRec.id.ToString());

            }
            catch (Exception sfupErr)
            {
                DisplayNotice(Return.RET_ERROR, sfupErr.Message);
                return false;
            }

            return true;
        }

        /***************************************************************************
         * GenerateServiceAuthorizationRequestPermanentRecords */
        /**
         * Create file upload records and files for internally generated files
         * that we want to put in the file uploads system
         ***************************************************************************/

        static bool GenerateServiceAuthorizationRequestPermanentRecords()
        {
            try
            {
                foreach (ServiceAuthorizationRequestPermanentRecord sarRequestPermRec in sarRequestPermRecords)
                {                    
                    if (cancelApp) break;                    
                    var permRecInfoStr = String.Format(@"Svc Auth Req ID: {0} Perm Rec Request ID: {1}", sarRequestPermRec.requestID, sarRequestPermRec.id);
                    DisplayNotice(Return.RET_INFO, permRecInfoStr);                    
                    GenerateServiceAuthorizationRequestPermanentRecord(sarRequestPermRec);
                }
            }
            catch
            {
                return false;
            }
            return true;
        }

        /***************************************************************************
         * ProcessPendingServiceAuthorizationRequestPermanentRecords */
        /**
         * Process 
         ***************************************************************************/

        static void ProcessPendingServiceAuthorizationRequestPermanentRecords()
        {
            DisplayNotice(Return.RET_INFO, "Checking for service authorization permanent record requests");
            if (!GetPendingServiceAuthorizationRequestPermanentRecordsList()) return;
            if (_sarPermRecRequestCount == 0)
            {
                DisplayNotice(Return.RET_INFO, "No pending service authorization permanent record requests");
                return;
            }
            DisplayNotice(Return.RET_INFO, "There are {0} service authorization permanent request(s) to be processed", _sarPermRecRequestCount.ToString());
            if (!GenerateServiceAuthorizationRequestPermanentRecords()) return;
        }

    /***************************************************************************
     * main */
    /**
     * Entry delegate
     ***************************************************************************/   
     
    static void main()
    {
      GetAndCheckAppSettings ();
      ProcessPendingServiceAuthorizationRequestPermanentRecords();
    }
        
    /***************************************************************************
     * Main */
    /**
     * Entry point
     ***************************************************************************/                             

    static void Main(string[] args)
    {
      /*============================================================
       * Enter application
       *============================================================*/  

      try
      {
                                          
       /*-------------------------------
        * Define main delegate
        *------------------------------*/
        
        GenericCallBack mainDel = delegate {main();};
                   
       /*-------------------------------
        * Start the application
        *------------------------------*/
        
        enter(Spedmon.Constants.APP_NAME, 
              "Generate Incoming Files", 
              Spedmon.Constants.APP_VERSION, 
              ref args, 
              ref mainDel);        
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

     /*============================================================
      * Exit
      *============================================================*/
      
      exit();                
                  
    }
  }
}
