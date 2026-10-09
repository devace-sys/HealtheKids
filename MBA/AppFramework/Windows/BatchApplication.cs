using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace MBA
{
  /***************************************************************************
   * BatchApplication */
  /**
   * Base class for batch applications.  Batch applications run unattended.
   ***************************************************************************/ 
  
  public abstract class BatchApplication:WindowsApplication
  {
    /***************************************************************************
     * existingColorBack */
    /**
     * Existing console background color
     ***************************************************************************/     
    
    protected static ConsoleColor existingColorBack = Console.BackgroundColor;

    /***************************************************************************
     * existingColorFore */
    /**
     * Existing console foreground color
     ***************************************************************************/     

    protected static ConsoleColor existingColorFore = Console.ForegroundColor;
    
        
    /***************************************************************************
     * SetToExistingDisplayColors */
    /**
     * Set console to colors that were set before the batch app ran
     ***************************************************************************/     
    
    protected static void SetToExistingDisplayColors()
    {
      if (Environment.UserInteractive)
      {
        Console.BackgroundColor = existingColorBack;
        Console.ForegroundColor = existingColorFore;
      }
    }
    
    /***************************************************************************
     * SetDefaultDisplayColors */
    /**
     * Set console to default colors we want to use for batch applications
     ***************************************************************************/       
    
    protected static void SetDefaultDisplayColors()
    {
       if (Environment.UserInteractive)
       {
         Console.BackgroundColor = ConsoleColor.Black;
         Console.ForegroundColor = ConsoleColor.White;
       }
    }
    
    /***************************************************************************
     * DisplayNotice */
    /**
     * Records a notice in the log and displays notice on the screen 
     ***************************************************************************/   
    
    protected static void DisplayNotice (int severity, string messagePattern, params string[] p)
    {
      string msg = Util.createMessageString(messagePattern, p);
      DisplayNotice(severity, msg);
    }

    protected static void DisplayNotice (int severity, string message)
    {              
      
     /*============================================================
      * Write notice to log if the log file exists
      *============================================================*/
      
     LogNotice(severity,message);

     /*============================================================
      * Displays notice on screen
      *============================================================*/

     /*-------------------------------
      * Display in console if 
      * applicable
      *------------------------------*/

     if (Environment.UserInteractive)
     {
        /*-------------------------------
          * Set color
          *------------------------------*/

         SetDefaultDisplayColors();
     
              if (severity == Return.RET_SUCCESS)         Console.ForegroundColor = ConsoleColor.Green;
         else if (severity == Return.RET_INFO)            Console.ForegroundColor = ConsoleColor.White;
         else if (severity == Return.RET_WARNING)         Console.ForegroundColor = ConsoleColor.Yellow;
         else if (severity == Return.RET_ERROR)           Console.ForegroundColor = ConsoleColor.Red;
         else if (severity == Return.RET_CRITICAL)        Console.ForegroundColor = ConsoleColor.Red;
         else if (severity == Return.RET_FATAL)           Console.ForegroundColor = ConsoleColor.Red;
         else if (severity == Return.RET_ABORT_OR_CANCEL) Console.ForegroundColor = ConsoleColor.Blue;
         else                                             Console.ForegroundColor = ConsoleColor.Gray;

         /*-------------------------------
          * Display notice
          *------------------------------*/

         Console.WriteLine("[{0}] [{1}] {2}", exitState.ToString(), severity.ToString(), message);

         /*-------------------------------
          * Set default color again
          *------------------------------*/

         SetDefaultDisplayColors();
     }

    }               

    /***************************************************************************
     * retryDate */
    /**
     * If a batch app or a component of it has to be repeated, when should it
     * repeat.
     ***************************************************************************/        

    protected static DateTime retryDate;
        
    /***************************************************************************
     * cancelApp */
    /**
     * Indicates user wanted to cancel app
     ***************************************************************************/ 

    protected static bool cancelApp = false;

    /***************************************************************************
     * doCancel */
    /**
     * 
     ***************************************************************************/ 
        
   public static void doCancel()
    {
     /*============================================================
       * Set flag in an attempt to close down any processing loops
       *============================================================*/
      
      cancelApp = true;

      /*============================================================
       * Notify user
       *============================================================*/
               
      DisplayNotice(Return.RET_ABORT_OR_CANCEL, "Cancelling");  
                                                         
      /*============================================================
       * Set exit state to an appropriate value
       *============================================================*/
      
      exitState = Return.RET_ABORT_OR_CANCEL;
      
      /*============================================================
       * Reset console colors
       *============================================================*/

      SetToExistingDisplayColors();
      
      /*============================================================
       * Exit
       *============================================================*/

      exit();
    }
    
    /***************************************************************************
     * cancelHandler */
    /**
     * If the user control-c's out of the app this helps close it down cleanly.
     * Control-C will bypass finally blocks.
     ***************************************************************************/ 
    
    protected static void cancelHandler (object sender, ConsoleCancelEventArgs args)
    {
      doCancel();      
    }
    
    /***************************************************************************
     * enter */
    /**
     * Entry point for batch applications
     * Applications must call this to start the application
     ***************************************************************************/        
     
     public static int enter (  string appname
                              , string apptitle
                              , string version
                              , ref string[] args
                              , ref GenericCallBack main
                              , bool openDatabaseConnections = true)
     {
                      
       /*============================================================
        * Setup handler to trap Control-C in batch applications
        * This is managed here using cancelHandler()
        *============================================================*/
      
       if (Environment.UserInteractive)
       {       
         Console.TreatControlCAsInput = false;
         Console.CancelKeyPress += new ConsoleCancelEventHandler(cancelHandler);
       }
      
       /*============================================================
        * Define start delegate for batch applications
        * This is passed to WindowsApplication.enter()
        *============================================================*/
       
       GenericCallBack start = delegate()
       {                  
               
         /*============================================================
          * Setup console (if applicable)
          *============================================================*/

         if (Environment.UserInteractive) Console.WriteLine();
         SetDefaultDisplayColors();
         
         /*----------------------------
          * Open db connections
          * if requested (default is
          * true)
          *----------------------------*/
         
         if (openDatabaseConnections) OpenDBConnections();
         
         /*----------------------------
          * Notify user
          *----------------------------*/
         
         DisplayNotice(Return.RET_INFO, appName);                                              
         DisplayNotice(Return.RET_INFO, "Starting");
         
       };
              
       /*============================================================
        * Define end delegate for batch applications
        * This is passed to WindowsApplication.enter()
        *============================================================*/
  
       GenericCallBack end = delegate()
       {         
         /*----------------------------
          * Let user know we are 
          * finished
          *----------------------------*/

         DisplayNotice(Return.RET_INFO, "Finished");
       
       };
       
       /*============================================================
        * Define notice handler for batch applications
        * This is passed to WindowsApplication.enter()
        *============================================================*/
  
       NoticeHandler noticehdlr = delegate(int severity, string message)       
       {
         DisplayNotice(severity, message);                  
       };
                    
       /*============================================================
        * Define exception delegate for batch applications
        * This is passed to WindowsApplication.enter()
        *============================================================*/

       ExceptionCallBack except = delegate(Exception e)
       {
         DisplayNotice(Return.RET_ERROR, e.Message);                  
       };

       /*============================================================
        * Define final delegate for batch applications
        * This is passed to WindowsApplication.enter()
        *============================================================*/

       GenericCallBack final = delegate()
       {         
         
        /*============================================================
         * Show total run time
         *============================================================*/
                                 
        DisplayNotice(Return.RET_INFO, "Total run time : {0}", elapsedTime.ToString()); 
       
        /*============================================================
         * Cleanup (Close db connections, log)
         *============================================================*/

        cleanup();
        
        /*============================================================
         * Reset console colors
         *============================================================*/

        SetToExistingDisplayColors();
                  
       };

       /*============================================================
        * Execute WindowsApplication.enter() and return exitState
        * passing in the delegates and handlers defined here
        *============================================================*/       

       return WindowsApplication.enter( appname
                                      , apptitle
                                      , version
                                      , ref args
                                      , true
                                      , ref start
                                      , ref main
                                      , ref end
                                      , ref noticehdlr
                                      , ref except
                                      , ref final);
       
     }
     
  }
}

