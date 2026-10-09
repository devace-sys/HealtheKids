using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.IO;

namespace MBA
{      
  /***************************************************************************
   * AntivirusApp */
  /**
   * Class
   *
   * 
   ***************************************************************************/ 
  
  public class AntivirusApp
  {
    public int    scanAppID;
    public string scanAppName;
    public string scanAppURI;
        
    public string scanAppWorkingDir;
    public string scanApp;
    public string scanAppArguments;    
    public string scanAppResultTextThreatFoundPattern;
    
    public static int SCAN_APP_ESET = 1;
  
    public static AntivirusApp Create (int scanAppID, string scanAppWorkingDir)
    {
      AntivirusApp avs = new AntivirusApp();

      if (scanAppID == SCAN_APP_ESET)
      {
        avs.scanAppID                = SCAN_APP_ESET;
        avs.scanAppName              = @"ESET NOD32 Antivirus - Business Edition";
        avs.scanAppURI               = @"www.eset.com";      
        avs.scanApp                  = @"C:\Program Files\ESET\ESET NOD32 Antivirus\ecls.exe";
        avs.scanAppArguments         = @"/clean-mode=Rigorous /log-all /log-rewrite /log-file=""{0}"" ""{1}"""; 
        avs.scanAppWorkingDir        = scanAppWorkingDir;
        avs.scanAppResultTextThreatFoundPattern = @"threat=\""[^\""]*\""";
      } 
           
      return avs;
    }
        
  }
    
  /***************************************************************************
   * FileToScan */
  /**
   * Class
   *
   * 
   ***************************************************************************/ 

  public class FileToScan
  {
    public FileInfo file;        
    public string   logFile;
    public string   fullLogFileName;
        
       
    public FileToScan ()
    {
    }
          
    public static string GenerateLogFileName (FileInfo file)
    {      
      return System.Guid.NewGuid().ToString() + '-' + System.DateTime.Today.ToYYYYMMDDString() + ".log";
    }
    
    public static string GenerateFullLogFileName (string scanLogFolder, string logFile)
    {      
      return Path.Combine(scanLogFolder, logFile);
    }
    
    public static FileToScan CreateFileToScan (string fullLogFileFolderName, FileInfo file)
    {
      FileToScan fts = new FileToScan();
      
      fts.file             = file;
      fts.logFile          = GenerateLogFileName(fts.file);
      fts.fullLogFileName  = GenerateFullLogFileName(fullLogFileFolderName,fts.logFile);      
      return fts;
    } 

    public static List<FileToScan> CreateFilesToScanList (string fullLogFileFolderName, string fullFolderName)
    {
      List<FileToScan> ftsl = new List<FileToScan>();
          
      try
      {
        DirectoryInfo di = new DirectoryInfo(fullFolderName);        
        FileInfo[] files = di.GetFiles();
      
        foreach (FileInfo fi in files)
        {          
          FileToScan fts = FileToScan.CreateFileToScan(fullLogFileFolderName, fi);
          ftsl.Add(fts);
        }      
      }
      catch (Exception e)
      {
      }
      
      return ftsl;  
    }
  }
        
 /***************************************************************************
   * AntivirusScanResult */
  /**
   * Class
   *
   * 
   ***************************************************************************/ 
  
  public class AntivirusScanResult
  {
             
    public static int     SCAN_RESULT_CODE_UNDEFINED                       = -1;        
    public static int     SCAN_RESULT_CODE_FILE_IS_OK                      = 0;    
    public static int     SCAN_RESULT_CODE_FILE_INFECTED_ATTEMPTED_CLEAN   = 1;    
    public static int     SCAN_RESULT_CODE_FILE_INFECTED_CANNOT_BE_CLEANED = 2;
    public static int     SCAN_RESULT_CODE_FILE_CANNOT_BE_SCANNED          = 3;    
    public static int     SCAN_RESULT_CODE_FILE_CANNOT_BE_OPENED           = 4;
            
    public static string  SCAN_RESULT_UNDEFINED                            = "Undefined";        
    public static string  SCAN_RESULT_FILE_IS_OK                           = "File is OK";
    public static string  SCAN_RESULT_FILE_INFECTED_ATTEMPTED_CLEAN        = "File is infected and we attempted a clean";
    public static string  SCAN_RESULT_FILE_INFECTED_CANNOT_BE_CLEANED      = "File is infected and cannot be cleaned";
    public static string  SCAN_RESULT_FILE_CANNOT_BE_SCANNED               = "File could not be scanned";
    public static string  SCAN_RESULT_FILE_CANNOT_BE_OPENED                = "File could not be opened or scanned";    

    public static int     ACTION_CODE_UNDEFINED                            = -1;
    public static int     ACTION_CODE_KEEP_FILE                            =  0;
    public static int     ACTION_CODE_DELETE_FILE_INFORM_USER              =  1;

    public static string  ACTION_UNDEFINED                                = "Undefined";
    public static string  ACTION_KEEP_FILE                                = "Keeping file";
    public static string  ACTION_DELETE_FILE_INFORM_USER                  = "Deleting file and informing user we deleted it";
             
    public AntivirusApp       scanApp;
    public FileToScan         scanFile;    
    public FileInfo           logFile;       
    
    public bool               scanAppExecuteState    = false; 
    public int                scanAppExitCode        = -1;
    public string             scanAppOutputText      = "";
    public string             scanAppThreatFoundText = "";    
    public int                resultCode             = SCAN_RESULT_CODE_UNDEFINED;
    public int                actionCode             = ACTION_CODE_UNDEFINED;    
    public bool               keepFile               = false;
    public bool               informUser             = false;
    
    public AntivirusScanResult()
    {
      scanApp             = null;
      scanFile            = null;
      logFile             = null;
      scanAppExecuteState = false;
      scanAppExitCode     = -1;
      scanAppOutputText   = "";
      resultCode          = SCAN_RESULT_CODE_UNDEFINED;
      actionCode          = ACTION_CODE_UNDEFINED;
      keepFile            = false;
      informUser          = false;     
    }
    
    
    protected string _getResultText()
    {
      if (resultCode == SCAN_RESULT_CODE_UNDEFINED)                       return SCAN_RESULT_UNDEFINED;
      if (resultCode == SCAN_RESULT_CODE_FILE_IS_OK)                      return SCAN_RESULT_FILE_IS_OK;
      if (resultCode == SCAN_RESULT_CODE_FILE_INFECTED_ATTEMPTED_CLEAN)   return SCAN_RESULT_FILE_INFECTED_ATTEMPTED_CLEAN;
      if (resultCode == SCAN_RESULT_CODE_FILE_INFECTED_CANNOT_BE_CLEANED) return SCAN_RESULT_FILE_INFECTED_CANNOT_BE_CLEANED;
      if (resultCode == SCAN_RESULT_CODE_FILE_CANNOT_BE_SCANNED)          return SCAN_RESULT_FILE_CANNOT_BE_SCANNED;
      if (resultCode == SCAN_RESULT_CODE_FILE_CANNOT_BE_OPENED)           return SCAN_RESULT_FILE_CANNOT_BE_OPENED;
      
      return SCAN_RESULT_UNDEFINED;
    }
    
    protected string _getActionText()
    {
      if (actionCode == ACTION_CODE_UNDEFINED)               return ACTION_UNDEFINED;
      if (actionCode == ACTION_CODE_KEEP_FILE)               return ACTION_KEEP_FILE;
      if (actionCode == ACTION_CODE_DELETE_FILE_INFORM_USER) return ACTION_DELETE_FILE_INFORM_USER;

      return ACTION_UNDEFINED;
    }
    
    public string resultText { get {return _getResultText();}}
    public string actionText { get {return _getActionText();}}
    
    public static int DetermineResultCode (AntivirusApp scanApp, int scanAppExitCode)
    {
      if (scanApp.scanAppID == AntivirusApp.SCAN_APP_ESET)
      {
        if (scanAppExitCode == 0  ) return AntivirusScanResult.SCAN_RESULT_CODE_FILE_IS_OK;
        if (scanAppExitCode == 1  ) return AntivirusScanResult.SCAN_RESULT_CODE_FILE_INFECTED_ATTEMPTED_CLEAN;
        if (scanAppExitCode == 10 ) return AntivirusScanResult.SCAN_RESULT_CODE_FILE_CANNOT_BE_OPENED;
        if (scanAppExitCode == 50 ) return AntivirusScanResult.SCAN_RESULT_CODE_FILE_INFECTED_CANNOT_BE_CLEANED;
        if (scanAppExitCode == 100) return AntivirusScanResult.SCAN_RESULT_CODE_FILE_CANNOT_BE_SCANNED;       
      }
      
      return AntivirusScanResult.SCAN_RESULT_CODE_UNDEFINED;
    }
    
    public static int DetermineActionCode (AntivirusApp scanApp, int resultCode)
    {
     if (scanApp.scanAppID == AntivirusApp.SCAN_APP_ESET)     
     {
       if (resultCode == SCAN_RESULT_CODE_UNDEFINED)                   return AntivirusScanResult.ACTION_CODE_UNDEFINED;
       if (resultCode == SCAN_RESULT_CODE_FILE_IS_OK)                  return AntivirusScanResult.ACTION_CODE_KEEP_FILE;
       
       if  (  
              (resultCode == SCAN_RESULT_CODE_FILE_INFECTED_ATTEMPTED_CLEAN)
           || (resultCode == SCAN_RESULT_CODE_FILE_CANNOT_BE_OPENED)
           || (resultCode == SCAN_RESULT_CODE_FILE_INFECTED_CANNOT_BE_CLEANED) 
           || (resultCode == SCAN_RESULT_CODE_FILE_CANNOT_BE_SCANNED)) return AntivirusScanResult.ACTION_CODE_DELETE_FILE_INFORM_USER;
           
       return AntivirusScanResult.ACTION_CODE_UNDEFINED;
     }
     return AntivirusScanResult.ACTION_CODE_UNDEFINED;
    }
    
    public static bool DetermineKeepFile(int actionCode)
    {
      if (actionCode == AntivirusScanResult.ACTION_CODE_UNDEFINED)             return false;
      if (actionCode == AntivirusScanResult.ACTION_CODE_KEEP_FILE)             return true;
      return false;
    }            

    public static bool DetermineInformUser (int actionCode)
    {
      if (actionCode == AntivirusScanResult.ACTION_CODE_UNDEFINED)             return false;
      if (actionCode == AntivirusScanResult.ACTION_CODE_KEEP_FILE)             return false;      
      return true;
    }            
        
  }
  
  /***************************************************************************
   * AntivirusProgress */
  /**
   * Event
   * 
   ***************************************************************************/    
  
  public class AntivirusProgress:EventArgs
  {
    
    protected string _progressMessage;
    
    public AntivirusProgress()
    {
    }

    public AntivirusProgress(string progressMessage)
    {
      _progressMessage = progressMessage;
    }
    
    public string ProgressMessage { get { return _progressMessage; } set { _progressMessage = value; }}
                 	  
  }
  
  /***************************************************************************
   * Antivirus */
  /**
   * Class
   *
   * 
   ***************************************************************************/ 
       
  public class Antivirus
  {         
  
    /***************************************************************************
     * ScanFiles */
    /**
     * Spawn process to virus scan file
     *
     * @param  scanApp      Class holding info on av app to use
     * @param  scanFiles    List of files to scan
     ***************************************************************************/  
    
    public static List<AntivirusScanResult> ScanFiles (   AntivirusApp   scanApp 
                                                        , ref List<FileToScan>         scanFiles
                                                      )
    {    
      List<AntivirusScanResult> scanResults = new List<AntivirusScanResult>();     
      foreach (FileToScan scanFile in scanFiles) scanResults.Add(ScanFile(scanApp, scanFile));            
      return scanResults;            
    }
        
	  public delegate void avHandler(object sender, AntivirusProgress e);
    public static event avHandler avProgress;             
    
    /***************************************************************************
     * ScanFile */
    /**
     * Spawn process to virus scan file
     *
     * @param  scanAppWorkingDir    Working directory for scan app
     * @param  scanApp              Executable name
     * @param  fullFileName         Complete path + file name of file to scan
     * @param  fullLogFileName      Complete path + file name of file for scan results
     ***************************************************************************/                             
     
    public static AntivirusScanResult ScanFile (   AntivirusApp     scanApp
                                                 , FileToScan       scanFile)
 
    {
      
      AntivirusScanResult asr = new AntivirusScanResult();

    
      try
      {                        
        
        asr.scanApp  = scanApp;
        asr.scanFile = scanFile;
      
        using (Process scanProcess = new Process())
        {
                                
          scanProcess.StartInfo.WorkingDirectory = scanApp.scanAppWorkingDir;
          scanProcess.StartInfo.FileName         = scanApp.scanApp;
          scanProcess.StartInfo.Arguments        = String.Format(@scanApp.scanAppArguments, scanFile.fullLogFileName, scanFile.file.FullName);
          scanProcess.StartInfo.UseShellExecute  = false;
          scanProcess.StartInfo.CreateNoWindow   = true; 
         
       //   avProgress.Invoke(null,new AntivirusProgress("Scanning " + scanFile.file.FullName));
          
                  
          scanProcess.Start();                    
          scanProcess.WaitForExit();
        
          asr.scanAppExitCode = scanProcess.ExitCode;
      
          scanProcess.Close();
        }
        
        
        asr.logFile = new FileInfo(scanFile.fullLogFileName);
        
        using (StreamReader sr = new StreamReader(scanFile.fullLogFileName))
        {
          asr.scanAppOutputText = sr.ReadToEnd();
          sr.Close();
        }
        
        System.IO.File.Delete(scanFile.fullLogFileName);       
        
        asr.scanAppThreatFoundText = System.Text.RegularExpressions.Regex.Match(asr.scanAppOutputText,asr.scanApp.scanAppResultTextThreatFoundPattern).Value;
                
        asr.scanAppExecuteState = true;
        asr.resultCode          = AntivirusScanResult.DetermineResultCode (asr.scanApp, asr.scanAppExitCode);
        asr.actionCode          = AntivirusScanResult.DetermineActionCode (asr.scanApp, asr.resultCode);
        asr.keepFile            = AntivirusScanResult.DetermineKeepFile   (asr.actionCode);
        asr.informUser          = AntivirusScanResult.DetermineInformUser (asr.actionCode);

      
        
        return asr;
      }
      
      catch (Exception e)
      {
        asr.scanAppExecuteState = false;
        
        asr.scanAppExitCode     = -1;
        asr.scanAppOutputText   = e.Message;    
      }
      
      return asr;
      
    }



    
  
  }
}
