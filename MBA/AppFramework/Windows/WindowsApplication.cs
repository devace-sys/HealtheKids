using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Net.Configuration;
using MBA;
using MBA.Reporting;

namespace MBA
{
        
  /***************************************************************************
   * NoticeHandler */
  /**
   * This is our notice event handler delegate
   ***************************************************************************/   

  public delegate void NoticeHandler (int severity, string message);
   
  public delegate bool ArgTryParseDel (string sv, out Object rv);
  
  /***************************************************************************
   * WindowsApplication */
  /**
   * This is our base class for windows applications (Forms and Console based)
   ***************************************************************************/   
  
  public abstract class WindowsApplication
  {    
            
    /***************************************************************************
     * exitState */
    /**
     * Exit state of application to return to OS.
     ***************************************************************************/   

    protected static int _exitState;
    public    static int exitState  { get { return _exitState; } set { _exitState = value; } }   

    /***************************************************************************
     * logfile */
    /**
     * Log file for this app (if used)
     ***************************************************************************/   

    protected static FileLogger logfile;

    
    /***************************************************************************
     * getAppSettingEnvironmentID */
    /**
     * Get application environment id
     ***************************************************************************/   

    public static void GetAppSettingEnvironmentID (out string appEnvironment, out long appEnvironmentID)
    {
      appEnvironment   = Constants.getAppSetting ("appEnvironment","0");
      appEnvironmentID = 0;
      long.TryParse(appEnvironment, out appEnvironmentID);      
    }
        
    public static long getAppSettingEnvironmentID()
    {
      string appEnvironment;
      long appEnvironmentID;
      GetAppSettingEnvironmentID(out appEnvironment, out appEnvironmentID);
      return appEnvironmentID;
    }
    
    /***************************************************************************
     * OpenLogFile */
    /**
     * Opens log file for this app
     ***************************************************************************/ 
    
    protected static void OpenLogFile()
    {
      logfile = new FileLogger(GetLogPath(),GetLogName());     
    }

    /***************************************************************************
     * CloseLogFile */
    /**
     * Closes log file for this app
     ***************************************************************************/ 
    
    protected static void CloseLogFile()
    {    
      if (logfile != null) logfile.Dispose();          
    }
            
    /***************************************************************************
     * startDateTime */
    /**
     * When this application actually started
     ***************************************************************************/   
   
    protected static DateTime startDateTime;
    
    /***************************************************************************
     * startDateTime */
    /**
     * When this application actually ended
     ***************************************************************************/   

    protected static DateTime endDateTime;

    /***************************************************************************
     * elapsedTime */
    /**
     * Total application run time
     ***************************************************************************/   
    
    protected static TimeSpan elapsedTime;

    /***************************************************************************
     * rundatetime */
    /**
     * When this application was run or an override passed in as an argument
     * indicating when this application SHOULD have run.
     ***************************************************************************/   
    
    protected static DateTime rundatetime;
    
   
    
    /***************************************************************************
     * debugMode */
    /**
     * Is this a debug exe?
     ***************************************************************************/   
    
    protected static bool debugMode;
    
    /***************************************************************************
     * AppIsInteractive */
    /**
     * Returns true if the app is interactive.  This is true of console and
     * windows apps.  If the app is a service it is not.
     ***************************************************************************/   
    
    public static bool AppIsInteractive()
    {
      return Environment.UserInteractive;
    }
      
    /***************************************************************************
     * GetExePathAndName*/
    /**
     * Returns the executable path + filename (with extension)
     ***************************************************************************/   
    
    public static string GetExePathAndName()
    {
      string value = Environment.GetCommandLineArgs()[0];
      return value;
    }

    /***************************************************************************
     * GetExePath */
    /**
     * Returns just the executable path
     ***************************************************************************/   
    
    public static string GetExePath()
    {
      string value = System.IO.Path.GetDirectoryName(GetExePathAndName());
      return value;
    }
    
    /***************************************************************************
     * GetExeNameWithExtension */
    /**
     * Returns just the executable name WITH extension
     ***************************************************************************/   

    public static string GetExeNameWithExtension()
    {
      string value = System.IO.Path.GetFileName(GetExePathAndName());
      return value;
    }

    /***************************************************************************
     * GetExeName */
    /**
     * Returns just the executable name NO extension.  Also strips out any
     * periods.
     ***************************************************************************/   
    
    public static string GetExeName()
    {
      string value = System.IO.Path.GetFileNameWithoutExtension(GetExePathAndName()).Replace(".", "");      
      return value;
    }
    
    /***************************************************************************
     * GetLogName */
    /**
     * Returns a default log name
     ***************************************************************************/   

    public static string GetLogName()
    {
      string user    = MBA.Network.GetMyUserName();
      string exename = GetExeName();
      string name    = exename + "-" + user;
      return name;
    }
    
    /***************************************************************************
     * GetLogPath */
    /**
     * Returns either the path from a config file or a default path (in this 
     * case the exe directory)
     ***************************************************************************/   
    
    public static string GetLogPath()
    {
      /*-------------------------------
       * Get paths
       *------------------------------*/
      
      string settingsPath = Constants.LOG_FILE_PATH;  // Path from config
      string path         = GetExePath();             // Default path
      
      /*-------------------------------
       * Use path from config if it is
       * defined and valid
       *------------------------------*/
                   
      if (!Util.IsNullOrEmpty(settingsPath))      
        if (Directory.Exists(settingsPath))
          path = settingsPath;               
            
      /*-------------------------------
       * Return path
       *------------------------------*/
      
      return path;
    }

    /***************************************************************************
     * GetAppConfigName */
    /**
     * Returns the name of the appconfig file for this application
     ***************************************************************************/   
    
    public static string GetAppConfigName()
    {
      string path  = GetExePath();
      string name  = GetExeName();      
      string extensions = ".exe.config";
      string value = System.IO.Path.Combine(path, name) + extensions;            
      return value;
    }
        
    /***************************************************************************
     * AppConfigExists */
    /**
     * Tests for existance of app config
     ***************************************************************************/   
     
    public static bool AppConfigExists ()
    {
      string file = GetAppConfigName();
      return AppConfigExists(file);      
    }
    
    public static bool AppConfigExists (string file)
    {
      if (!System.IO.File.Exists(file)) return false;
      return true;
    }
        
    /***************************************************************************
     * notice */
    /**
     * Our notice event
     ***************************************************************************/   
    
    protected static event NoticeHandler notice;
    
    /***************************************************************************
     * LogNotice */
    /**
     * Log notice
     ***************************************************************************/   
    
    protected static void LogNotice(int severity, string message)
    {
      /*============================================================
       * If there is a log file write to it
       *============================================================*/
      
      if (logfile != null)
      {
        if      (severity == Return.RET_SUCCESS)  logfile.writeLog(Logger.LogLevel.Info,message);
        else if (severity == Return.RET_INFO)     logfile.writeLog(Logger.LogLevel.Info,message);
        else if (severity == Return.RET_WARNING)  logfile.writeLog(Logger.LogLevel.Warn,message);
        else if (severity == Return.RET_ERROR)    logfile.writeLog(Logger.LogLevel.Err,message);
        else if (severity == Return.RET_CRITICAL) logfile.writeLog(Logger.LogLevel.Crit,message);
        else if (severity == Return.RET_FATAL)    logfile.writeLog(Logger.LogLevel.Crit,message);       
        else                                      logfile.writeLog(Logger.LogLevel.Info,message);
      }  
    }
           
    /***************************************************************************
     * arguments */
    /**
     * Application entry point arguments
     ***************************************************************************/   
    
    protected static List<NameValue> arguments;
    
    /***************************************************************************
     * hasArguments */
    /**
     * Are there arguments in the argument list?
     ***************************************************************************/   
    
    protected static bool hasArguments()
    {
      bool ha = false; 
      
      if (arguments != null)
        if (arguments.Count > 0)
          ha = true;     
      
      return ha;
    }
        
    /***************************************************************************
     * findArgumentPos */
    /**
     * Returns -1 if not found
     ***************************************************************************/ 
    
    protected static int findArgumentPos(string name)
    {
            
      int pos = -1;          
      int idx = 0;
      
      /*-------------------------------
       * If the argument name is not
       * defined, nothing to find
       *------------------------------*/

      if (Util.IsNullOrEmpty(name))
        return pos;
      
      /*-------------------------------
       * If the argument list has 
       * no entries, nothing to find
       *------------------------------*/
      
      if (!hasArguments())
        return pos;
      
      /*-------------------------------
       * Look for the first argument
       * that has the matching name
       * and return position
       *------------------------------*/
              
      foreach (NameValue argument in arguments)
      {
        if (argument.name == name)
        {          
          pos = idx;
          break;
        }
        idx++;
      }
      
      return pos;
    
    }
    
    /***************************************************************************
     * findArgument */
    /**
     * Returns true if found and argument
     ***************************************************************************/    
    
    protected static bool findArgument (string name, out NameValue argument)
    {
      
      int  pos  = findArgumentPos(name);
      bool ha   = false;            
      argument  = null;
      
      if (pos != -1)
      {
        argument = arguments[pos];
        ha       = true;
      }
      
      return ha;
          
    }
    
    /***************************************************************************
     * hasArgs */
    /**
     * Are there arguments in the args array?
     ***************************************************************************/   
    
    protected static bool hasArgs(ref string[] args)
    {

      bool ha = false; 
      
      /*-------------------------------
       * If the args array has values
       * then we have arguments
       *------------------------------*/
       
      if (args != null)                   
        if (args.Length > 0)  
          ha = true;
      
      return ha;
      
    }
             
    /***************************************************************************
     * ParseArgumentDate */
    /**
     * Parse an argument that should be a date
     ***************************************************************************/   
    
    protected static DateTime ParseArgumentDate (string argName, DateTime defVal)
    {
      return ParseArgumentDate(argName, defVal, null);
    }
    
    protected static DateTime ParseArgumentDate (string argName, DateTime defVal, string preqArg)
    {
      if (hasArguments())
      {      
        if (!Util.IsNullOrEmpty(preqArg))
        {
          if (findArgumentPos(preqArg) == -1)
          {
            string msg = Util.createMessageString("{0} must be provided",preqArg);
            throw new MBA.Critical(msg);
          }
        }
        NameValue arg;
      
        if (findArgument(argName,out arg))
        {
          string   argStr = (String) arg.value;
          DateTime argVal = defVal;
      
          if (DateTime.TryParse(argStr, out argVal))
          {
            return argVal;
          }        
          else
          {
            throw new MBA.Critical("Argument could not be parsed");
          }      
        }
        else
        {
          return defVal;
        }
      }
      else
      {
        return defVal;
      }
    }

    /***************************************************************************
     * appName */
    /**
     * Application name
     ***************************************************************************/   

    protected static string appName;
    
    /***************************************************************************
     * dbConnUser */
    /**
     * Database connection for users database
     ***************************************************************************/   
     
    protected static SqlConnection dbConnUser;

    /***************************************************************************
     * dbConnApp */
    /**
     * Database connection for app database (Spedmon, or other app)
     ***************************************************************************/   

    protected static SqlConnection dbConnApp;
    
    /***************************************************************************
     * OpenDBConnections */
    /**
     * Opens database connections
     ***************************************************************************/ 

    protected static void OpenDBConnections()
    {
      dbConnUser = MBA.Database.openConn(Constants.DB_CONN_USERS);
      dbConnApp  = MBA.Database.openConn(Constants.DB_CONN_APP);         
    }

    /***************************************************************************
     * CloseDBConnections */
    /**
     * Cancels and pending transactions and closes database connections
     ***************************************************************************/ 

    protected static void CloseDBConnections()
    {
      MBA.Database.closeConn(dbConnUser);
      MBA.Database.closeConn(dbConnApp);
    }
    
    /***************************************************************************
     * log */
    /**
     * Details log 
     * Note: This is NOT the log file
     ***************************************************************************/   
         
    protected static DetailsLog log;

    /***************************************************************************
     * uInfo */
    /**
     * User info.  
     ***************************************************************************/   

    public static UserInfo uInfo;    

    /***************************************************************************
     * networkUserName */
    /**
     * Network user name
     ***************************************************************************/   

    public static string networkUserName;

    /***************************************************************************
     * networkUserIP */
    /**
     * Network user IP
     ***************************************************************************/   

    public static string networkUserIP;
    
    /***************************************************************************
     * dbConnInfoSummary */
    /**
     * Database connection info summary
     ***************************************************************************/   
        
    public static string dbConnInfoSummary;
    
    /***************************************************************************
     * dbConnInfoUsers */
    /**
     * Database connection info for users database
     ***************************************************************************/   
    
    protected static SqlConnectionStringBuilder dbConnInfoUsers;
    
    /***************************************************************************
     * dbConnInfoApp */
    /**
     * Database connection info for app database (Spedmon, etc.)
     ***************************************************************************/   
    
    protected static SqlConnectionStringBuilder dbConnInfoApp;
    
    /***************************************************************************
     * cleanup */
    /**
     * Cleanup point for applications.
     * All subclasses should use this method prior to exiting the app
     ****************************************************************************/        

    public static void cleanup()
    {
      
      /*============================================================
       * Close database connections (this also cancels any pending
       * transactions)
       *============================================================*/
         
      CloseDBConnections();
       
      /*============================================================
       * Close log file if it is open
       *============================================================*/
      
      CloseLogFile();
    }
    
    /***************************************************************************
     * exit */
    /**
     * Exit point for applications.  This returns the exit state to the OS.     
     * All subclasses should use this method to end their apps.
     ****************************************************************************/        
    
    public static void exit()    
    {
      System.Environment.Exit((int) exitState);
    }
    
    /***************************************************************************
     * enter */
    /**
     * Entry point for application.  
     * All subclasses should use this method to run their apps.
     ***************************************************************************/  
           
    public static int enter (   string appname
                              , string apptitle
                              , string version
                              , ref string[] args
                              , bool batchapp
                              , ref GenericCallBack   start 
                              , ref GenericCallBack   main 
                              , ref GenericCallBack   end
                              , ref NoticeHandler     noticehdlr
                              , ref ExceptionCallBack except
                              , ref GenericCallBack   final)
    {
                  
      /*============================================================
       * Start
       *============================================================*/
      
      /*----------------------------
       * Setup exit state default
       * Unless set by something else
       * in the app it will stay 
       * at this condition
       *----------------------------*/ 
       
      exitState = Return.RET_SUCCESS;
      
      /*-------------------------------
       * Is this a debug or test exe
       *------------------------------*/

      debugMode = false;
      
      #if DEBUG
        debugMode = true; 
      #endif       
      
      /*============================================================
       * Enter
       *============================================================*/
      
      try
      { 
      
        /*============================================================
         * Initialize variables and set default conditions
         *============================================================*/

        /*-------------------------------
         * Start datetime and initial 
         * rundate and rundatetime
         *------------------------------*/

        startDateTime = System.DateTime.Now;         
        rundatetime   = startDateTime;
      
        /*============================================================
         * Setup Event handlers
         *============================================================*/      
                                    
        /*----------------------------
         * Notices
         *----------------------------*/

        notice += noticehdlr;  

        /*============================================================
         * Get app config name
         *============================================================*/
                                       
        string configFile = GetAppConfigName(); 
        
        /*----------------------------
         * If the app config does not
         * exist get out
         *----------------------------*/

        if (!AppConfigExists(configFile))
        {
          string msg = Util.createMessageString(@"Could not find {0}.  Please make sure the config file was installed.",configFile);
          throw new Fatal(msg);
        }

        /*============================================================
         * Create application name (summary)
         *============================================================*/
                 
         appName = Util.nameCase(appname) + " - " + apptitle + " - Version " + version;

        
        /*============================================================
         * Retrieve network info
         *============================================================*/
        
        /*----------------------------
         * Network User Name (NT Name)
         *----------------------------*/     
      
        networkUserName = MBA.Network.GetMyUserName();

        /*----------------------------
         * Network User IP Address
         *----------------------------*/     

        networkUserIP = MBA.Network.GetMyIPAddress();
                
        /*============================================================
         * Open log file if applicable
         *============================================================*/
                
        if (batchapp) 
          OpenLogFile();
                
        /*============================================================
         * Parse arguments
         *============================================================*/

        arguments = ParseArguments(ref args);
                 
        /*============================================================
         * Create database connection info summary if applicable
         * 
         * Note: Database connections are handled by callMethod*()
         *============================================================*/
    
        dbConnInfoUsers = Database.connInfo(Constants.DB_CONN_USERS);
        dbConnInfoApp   = Database.connInfo(Constants.DB_CONN_APP);
        log             = new DetailsLog();
        
        if (dbConnInfoUsers.DataSource == dbConnInfoApp.DataSource)
          dbConnInfoSummary = dbConnInfoUsers.DataSource;
        else
          dbConnInfoSummary = dbConnInfoUsers.DataSource + "|" + dbConnInfoApp.DataSource;        
               
        /*============================================================
         * Populate user info class
         * (This is needed for AppFramework method calls)
         *============================================================*/

        // TODO: Refactor this when we start working with apps that we require a username password for.
       
        uInfo = new UserInfo();
        
        /*-------------------------------
         * Non batch application
         * Use current user info
         *------------------------------*/

        if (!batchapp)
        {
          /******** Retrieve current users info ********/

          Return so = (Return) callMethod(typeof(Return), delegate {
            
            return MBA.UserInfo.retrieveUserInfo(dbConnUser, 
                                                 log, 
                                                 appname, 
                                                 networkUserName, 
                                                 networkUserIP, 
                                                 ref uInfo);          
          
          }, false, true);        
         
          /******** If there were issues retrieving user info, get out ********/

         if (so.status != Return.RET_SUCCESS)
           fatalExit();  
         
        }

        /*-------------------------------
         * Batch application
         * Use predefined user info for
         * batch apps
         *------------------------------*/
        
        else
        {
          networkUserName = Constants.USER_NAME_SYSTEM;          
          MBA.UserInfo.createBatchUserInfo(networkUserIP, ref uInfo);
        }
              
       /*============================================================
        * Call start delegate
        * Note: This is defined by a subclass
        *============================================================*/

        start();

       /*============================================================
        * Call main delegate
        *
        * Notes: 
        * 
        * This delegate is defined by the actual application and
        * it is passed down by the various subclasses.
        * 
        * Main delegates can change exit state by setting the property
        *============================================================*/
                                                                        
        main();
                     
       /*============================================================
        * Call end delegate
        * Note: This is defined by a subclass
        *============================================================*/

        end();
                        
      }      
      
      /*============================================================
       * Exception handling
       * Note: This will handle any exceptions in this block and
       * any exceptions thrown by the various delegates
       *============================================================*/
      
      catch(Exception e)
      {   
       
       /*----------------------------
        * Call except delegate
        *----------------------------*/
        
        except(e);

       /*----------------------------
        * Set exit state
        *----------------------------*/

        exitState = Return.RET_ERROR;
      }          
      
      /*============================================================
       * Cleanup 
       *============================================================*/

      finally
      {
       
       /*----------------------------
        * Grab application end 
        * datetime.  Subclasses can
        * use this as they see fit.
        *----------------------------*/
        
        endDateTime = System.DateTime.Now;
        
       /*----------------------------
        * Calculate elapsed time
        * Subclasses can use this as
        * they see fit
        *----------------------------*/
        
        long totTicks = endDateTime.Ticks - startDateTime.Ticks;
        elapsedTime   = TimeSpan.FromTicks(totTicks);      
        
        /*----------------------------
         * Call final delegate
         *----------------------------*/
        
        final();  

       /*----------------------------
        * Close log file if it 
        * is open
        *----------------------------*/
        
        CloseLogFile();
                      
      }
      
      /*============================================================
       * End and exit
       *============================================================*/
      
      return exitState;
      
    }
                
    /***************************************************************************
     * ParseArguments */
    /**
     * Parses argument array and returns a list of NameValue
     ***************************************************************************/  
    
    public static List<NameValue> ParseArguments(ref string[] args)
    {
    
      List<NameValue> arguments = new List<NameValue>();
      
      /*----------------------------
       * Get out if there is nothing
       * to parse
       *----------------------------*/
      
      if (!hasArgs(ref args))
        return arguments;
             
      /*----------------------------
       * Parse arguments
       *----------------------------*/
      
      foreach (string arg in args)
      {        
        /*----------------------------
         * Arguments are of the form
         * <name>:<value> no spaces
         *----------------------------*/
        
        string[] nva = arg.Split(new String[] {":"},StringSplitOptions.RemoveEmptyEntries);
        
        /*----------------------------
         * We have an argument
         *----------------------------*/

        if (nva != null)
        {

        /*----------------------------
         * And its the correct length
         *----------------------------*/

          if (nva.Length == 2)
          {
            string n = nva[0];
            string v = nva[1];
            NameValue nv = new NameValue(n,v);
            arguments.Add(nv);
          }
          else
          {
            throw new MBA.Critical("Unsupported argument");
          }
        }               
      }
      
      return arguments;
      
    }
    
    /***************************************************************************
     * fatalExit */
    /**
     * Call when you have no other choice
     ***************************************************************************/  
    
    public static void fatalExit()
    {
      throw new Fatal(appName + " cannot continue running.");
    }
    
    /***************************************************************************
     * callMethodView */
    /**
     * Helper function for calling view methods
     ***************************************************************************/     
    
    public static ReturnDB callMethodView (MethodCallback cb, bool useExistingDBConn, bool showNotifications)
    {
      return (ReturnDB) callMethod(typeof(ReturnDB), cb, useExistingDBConn, showNotifications);
    }
    
    /***************************************************************************
     * callMethodViewSel */
    /**
     * Helper function for calling viewSel methods
     ***************************************************************************/     
    
    public static ReturnSel callMethodViewSel (MethodCallback cb, bool useExistingDBConn, bool showNotifications)
    {
      return (ReturnSel) callMethod(typeof(ReturnSel), cb, useExistingDBConn, showNotifications);
    }
    
    /***************************************************************************
     * callMethodViewRptData */
    /**
     * Helper function for calling viewRptData methods
     ***************************************************************************/

    public static DataFileDistributable callMethodViewRptData(MethodCallback cb, bool useExistingDBConn, bool showNotifications)
    {
        return (DataFileDistributable)callMethod(typeof(ReturnRptData), cb, useExistingDBConn, showNotifications);
    }
   
    /***************************************************************************
     * callMethodViewDataTable */
    /**
     * Helper function for calling viewTbl methods
     ***************************************************************************/

    public static ReturnDataTable callMethodViewDataTable (MethodCallback cb, bool useExistingDBConn, bool showNotifications)
    {
      return (ReturnDataTable) callMethod (typeof(ReturnDataTable), cb, useExistingDBConn, showNotifications);
    }

    /***************************************************************************
     * callMethodSaveRecord */
    /**
     * Helper function for calling entity save methods
     ***************************************************************************/     
    
    public static ReturnSaveRecord callMethodSaveRecord(MethodCallback cb, bool useExistingDBConn, bool showNotifications)
    {
      return (ReturnSaveRecord) callMethod (typeof(ReturnSaveRecord), cb, useExistingDBConn, showNotifications);
    }
    
    /***************************************************************************
     * CallMethod */
    /**
     * Our main entry point for framework services.
     * 
     * Notes:
     * 
     *   This handles database connections if requested
     *   This is NOT thead safe.
     ***************************************************************************/  

    public static Object callMethod(Type rt, MethodCallback cb, bool useExistingDBConn, bool showNotifications)
    {
      return callMethod(ref dbConnUser, ref dbConnApp, ref log, rt, cb, useExistingDBConn, showNotifications);
    }            
    
    public static Object callMethod(ref SqlConnection dbConnUser, 
                                    ref SqlConnection dbConnApp, 
                                    ref DetailsLog log,
                                    Type rt, 
                                    MethodCallback cb,
                                    bool useExistingDBConn,
                                    bool showNotifications)
    {                 
      try
      {    

        /*-------------------------------
         * Create details log          
         *------------------------------*/
         
        log = new DetailsLog();                
       
       /*-------------------------------
        * Open our database connections
        * If this fails we want to
        * immediatly exit with an
        * exception.
        * 
        * Note: These connections are
        * NOT threadsafe.
        *------------------------------*/  
        
        if (!useExistingDBConn)
        {
          try
          {
            OpenDBConnections();
          }
          catch (Exception dbErr)
          {
            throw new Fatal(dbErr.Message);
          }
        }
                   
        /*-------------------------------
         * Pass control to the code in
         * the delegate/callback and
         * get the return object
         *------------------------------*/ 

        Object o = cb();                                

        return o;
       
      }

      /*-------------------------------
       * Catch the various types of
       * exception objects that can 
       * be thrown
       *------------------------------*/    
                   
      catch(Warning e)
      {
        
        if (!e.excludeMsgFromDetails)
          log.addDetail(e.Message,Return.RET_WARNING);
        e.Data.Add("details",log.details);
        Object[] v = new Object[] {e};                
        if (showNotifications)
          notice.Invoke(Return.RET_WARNING, e.Message);
        return Activator.CreateInstance(rt,v);
      }
      catch(Critical e)
      {
        // Update our request/response object (rd)
        
        if (!e.excludeMsgFromDetails)
          log.addDetail(e.Message,Return.RET_CRITICAL);
        e.Data.Add("details",log.details);
        Object[] v = new Object[] {e};
        if (showNotifications)
          notice.Invoke(Return.RET_CRITICAL, e.Message);
        return Activator.CreateInstance(rt,v);
      }
      catch(Fatal e)
      {
        
        if (!e.excludeMsgFromDetails)
          log.addDetail(e.Message,Return.RET_FATAL);
         
        e.Data.Add("details",log.details);
        Object[] v = new Object[] {e};
        if (showNotifications)
          notice.Invoke(Return.RET_FATAL, e.Message);
        return Activator.CreateInstance(rt,v);
      }
      catch(Exception e)
      {           
        log.addDetail(e.Message,Return.RET_ERROR);
        e.Data.Add("details",log.details);        
        Object[] v = new Object[] {e};       
        if (showNotifications)
          notice.Invoke(Return.RET_ERROR, e.Message);
        return Activator.CreateInstance(rt,v);
      }
      finally
      {
        if (!useExistingDBConn)
        {
          CloseDBConnections();
        }
      }      

    } // callMethod       
  }
}
