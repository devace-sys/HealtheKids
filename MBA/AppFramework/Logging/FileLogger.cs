/*******************************************************************************
* $Id: FileLogger.cs 1053 2009-04-07 17:16:45Z sthames $
*******************************************************************************/
using System;
using System.Threading;
using System.IO;

namespace MBA
  {
  /*****************************************************************************
  * FileLogger Class */
  /**
  * Handles logging to a file.
  *****************************************************************************/
  public class FileLogger : Logger
    { 
    /***************************************************************************
    * Properties
    ***************************************************************************/
    /** Log File Name. */    protected string m_LogFile    = null;
    /** File Mutex. */       protected Mutex  m_Mutex      = null;
    /** Mutex Owned Flag. */ protected bool   m_MutexOwned = false;
    
    /***************************************************************************
    * Constructor */
    /**
    * Creates the logging object.  Log file will be named 
    * "<logPath>\<logName>_YY-MM-DD.log".
    *
    * @param  logPath  Log file Path
    * @param  logName  Log File Name 
    ***************************************************************************/
    public FileLogger(string logPath, string logName)
      {
      /*----------------------------------------*/
      /* Set the log file name and build mutex. */
      /*----------------------------------------*/
      m_LogFile = Path.Combine(logPath, logName);
      m_Mutex   = new Mutex(false, logName);
      } 
    
    /***************************************************************************
    * disposeManaged */
    /**
    * Disposes of the logger object.
    ***************************************************************************/
    protected override void disposeManaged() 
      { 
      if (m_MutexOwned)
        m_Mutex.ReleaseMutex();
      } 
    
    /***************************************************************************
    * writeLog */
    /**
    * Performs the actual write to log file.
    *
    * @param  level  Logging Level
    * @param  msg    Log Message
    ***************************************************************************/
    public override void writeLog(LogLevel level, string msg)
      {
      /*-------------------------------------------*/
      /* Secure the file. Return if not available. */
      /*-------------------------------------------*/
      if (!(m_MutexOwned = m_Mutex.WaitOne(5000, false)))
        return;

      /*-----------------*/
      /* Write the file. */
      /*-----------------*/
      DateTime     now    = DateTime.Now;
      string       fname  = String.Format("{0}_{1}.log", m_LogFile, now.ToString("yy-MM-dd"));
      StreamWriter writer = System.IO.File.AppendText(fname);

      writer.WriteLine("[{0}] [{1}] {2}", now.ToString("yy-MM-dd hh:mm:ss.ff"), level.ToString().ToLower(), msg);
      writer.Close();

      /*-------------------*/
      /* Release the file. */
      /*-------------------*/
      m_Mutex.ReleaseMutex();
      m_MutexOwned = false;
      }

    /***************************************************************************
    * Test Main
    ***************************************************************************/
    [STAThread]
    static void Main(string[] args)
      {
      FileLogger elog = new FileLogger("MyProcess", "MyLog");
      elog.logLevel = FileLogger.LogLevel.Notice;
      elog.logEmerg("MyProcess started at {0}!",DateTime.Now);
      elog.logLevel = FileLogger.LogLevel.Info;
      elog.logSummary("My Process is Still Running!"); 
      elog.logNotice("MyProcess ended at {0}!",DateTime.Now); 
      }
    }
  }











