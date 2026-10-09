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
   * ConsoleApplication */
  /**
   * Base class for console applications
   ***************************************************************************/ 
  
  public abstract class ConsoleApplication:WindowsApplication
  {        
     
     protected static readonly ConsoleColor COLOR_BACKGROUND_TITLE   = ConsoleColor.DarkBlue;
     protected static readonly ConsoleColor COLOR_FOREGROUND_TITLE   = ConsoleColor.White;
     protected static readonly ConsoleColor COLOR_BACKGROUND_DEFAULT = ConsoleColor.Black;     
     protected static readonly ConsoleColor COLOR_FOREGROUND_DEFAULT = ConsoleColor.Gray;
     protected static readonly ConsoleColor COLOR_BACKGROUND_SUCCESS = ConsoleColor.Green;     
     protected static readonly ConsoleColor COLOR_FOREGROUND_SUCCESS = ConsoleColor.White;
     protected static readonly ConsoleColor COLOR_BACKGROUND_INFO    = ConsoleColor.Blue;     
     protected static readonly ConsoleColor COLOR_FOREGROUND_INFO    = ConsoleColor.White;
     protected static readonly ConsoleColor COLOR_BACKGROUND_WARNING = ConsoleColor.Yellow;     
     protected static readonly ConsoleColor COLOR_FOREGROUND_WARNING = ConsoleColor.Black;
     protected static readonly ConsoleColor COLOR_BACKGROUND_ERROR   = ConsoleColor.Red;     
     protected static readonly ConsoleColor COLOR_FOREGROUND_ERROR   = ConsoleColor.White;
     protected static readonly ConsoleColor COLOR_BACKGROUND_FATAL   = ConsoleColor.Magenta;
     protected static readonly ConsoleColor COLOR_FOREGROUND_FATAL   = ConsoleColor.White;

    /***************************************************************************
     * SetConsoleColorDefault */
    /**
     * Set console screen colors to our application default (not system default)
     ***************************************************************************/        
    
     protected static void SetConsoleColorDefault ()
     {
       Console.BackgroundColor = COLOR_BACKGROUND_DEFAULT;
       Console.ForegroundColor = COLOR_FOREGROUND_DEFAULT;
     }

    /***************************************************************************
     * DisplayNotice */
    /**
     * Displays a notice on the console
     ***************************************************************************/        
     
     protected static void DisplayNotice (int severity, string message)
     {
       
       Console.ResetColor();              
       
       if (severity == Return.RET_SUCCESS)
       {
         Console.BackgroundColor = COLOR_BACKGROUND_SUCCESS;
         Console.ForegroundColor = COLOR_FOREGROUND_SUCCESS;
       }
       else if (severity == Return.RET_INFO)  
       {
         Console.BackgroundColor = COLOR_BACKGROUND_INFO;
         Console.ForegroundColor = COLOR_FOREGROUND_INFO;
       }
       else if (severity == Return.RET_WARNING)
       {
         Console.BackgroundColor = COLOR_BACKGROUND_WARNING;
         Console.ForegroundColor = COLOR_FOREGROUND_WARNING;
       }
       else if (severity == Return.RET_ERROR)
       {
         Console.BackgroundColor = COLOR_BACKGROUND_ERROR;
         Console.ForegroundColor = COLOR_FOREGROUND_ERROR;     
       }
       else if (severity == Return.RET_CRITICAL)
       {
         Console.BackgroundColor = COLOR_BACKGROUND_ERROR;
         Console.ForegroundColor = COLOR_FOREGROUND_ERROR;     
       }
       else if (severity == Return.RET_FATAL)
       {
         Console.BackgroundColor = COLOR_BACKGROUND_FATAL;
         Console.ForegroundColor = COLOR_FOREGROUND_FATAL;             
       }
       else
       {
         SetConsoleColorDefault();
       }
       
       Console.WriteLine(message);
       SetConsoleColorDefault();
     
     }               

    /***************************************************************************
     * enter */
    /**
     * Entry point for console applications
     ***************************************************************************/        

     public static int enter (string appname,
                               string apptitle,
                               string version,
                               ref string[] args,                               
                               ref GenericCallBack main)
     {
       return enter(appname, apptitle, version, ref args, false, ref main);
     }
     
     public static int enter (string appname,
                               string apptitle,
                               string version,
                               ref string[] args,
                               bool batchapp,
                               ref GenericCallBack main)
     {
       
       GenericCallBack start = delegate()
       {
         //Console.Title = appName;
         Console.ResetColor();
         Console.BackgroundColor = COLOR_BACKGROUND_TITLE;
         Console.ForegroundColor = COLOR_FOREGROUND_TITLE;
         Console.WriteLine(appName);
         SetConsoleColorDefault();
         Console.WriteLine();
       };
       
       GenericCallBack end = delegate()
       {         
         Console.WriteLine();
         DisplayNotice(Return.RET_INFO, "Done");
         Console.WriteLine();
       };
       
       NoticeHandler noticehdlr = delegate(int severity, string message)       
       {
         DisplayNotice(severity, message);                  
       };
       
              
       ExceptionCallBack except = delegate(Exception e)
       {
         DisplayNotice(Return.RET_ERROR, e.Message);                  
       };

       GenericCallBack final = delegate()
       {
         Console.ResetColor();
         #if DEBUG
           Console.WriteLine("Debug mode.  Press any key to continue.");
           Console.ReadKey();
         #endif
       };
        
       /*----------------------------
        * Run application logic
        * provided in delegates
        * and return exit code
        *----------------------------*/       
       
       return WindowsApplication.enter(appname,
                                 apptitle,
                                 version,
                                 ref args,
                                 batchapp,
                                 ref start,
                                 ref main,
                                 ref end,
                                 ref noticehdlr,
                                 ref except,
                                 ref final);
       
     }                              
  }
}
