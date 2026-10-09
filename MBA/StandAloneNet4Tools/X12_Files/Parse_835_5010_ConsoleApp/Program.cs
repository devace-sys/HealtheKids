using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using MBA.X12.XDOC;
using MBA.X12.X835;
using MBA.X12.X835_5010;

namespace MBA.X12
{
   
  /// <summary>
  /// The starting object for this app
  /// <remarks>
  /// TODO: Refactor when MBA libraries are ported.
  /// This is a temporary solution until we can port the rest of the MBA libraries to .NET 4
  /// or higher.  It would be better to use the ConsoleApp framework we have in the MBA libraries.
  /// </remarks>
  /// </summary>
  
  class MainClass
  {
       
    const string ARG_KEY_FILE                   = @"file";
    const string ARG_KEY_PWD                    = @"pwd";
    const string ARG_KEY_NO_CSV_FILE            = @"nocsvfile";
    const string ARG_KEY_NO_REPORT_FILE         = @"noreportfile";
    const string ARG_KEY_NO_REPORT_FILE_DETAILS = @"noreportfiledetais";
    const string ARG_KEY_YES_XML_FILE           = @"yesxmlfile";

    private static void DisplayMessage (string message)
    {      
      Console.WriteLine(message);
    }
    
    
    private static void HandleProcessingStatusEvent (object sender, ProcessingStatusEventArgs e)
    {
      DisplayMessage(e.Message);
    }
   
    private static void DisplayUsageLine (string argument, string usage)
    {
      Console.WriteLine(@"-{0} <{1}>",argument,usage);      
    }
    
    private static void DisplayUsage()
    {
      DisplayUsageLine(ARG_KEY_PWD,             @"Password for password protected zip files containing 835 file");
      DisplayUsageLine(ARG_KEY_FILE,            @"Full path and filename of 835 file to parse");
      DisplayUsageLine(ARG_KEY_NO_CSV_FILE,     @"Dont generate CSV file");
      DisplayUsageLine(ARG_KEY_NO_REPORT_FILE,  @"Dont generate report file");
      DisplayUsageLine(ARG_KEY_NO_REPORT_FILE_DETAILS,  @"Dont generate report file detail sheets");
      DisplayUsageLine(ARG_KEY_YES_XML_FILE,            @"Do generate XML file");      
    }
    
    /// <summary>
    /// Main entry point
    /// </summary>
    /// <param name="args">One or more parameters from command line</param>
    /// <returns>Return <see cref="ExitCodes"/> to the operating system.</returns>
    
    public static int Main (string[] args)
    {      

      Console.WriteLine(@"Parse X12 835 (5010)");
   
      try
      {             
      
        /********************************************************************************
         * Get out if no arguments passed
         ********************************************************************************/

        if (args.Length == 0)
        {
          DisplayUsage();
          return (int) ExitCodes.NoArgumentsProvided;
        }

        /********************************************************************************
         * Setup 
         ********************************************************************************/

        var parser = new SimpleCommandLineParser();
        var pwf    = new MBA.X12.ParsingWorkflow.ParseX835_5010();      
        pwf.ProcessingStatusEvent += HandleProcessingStatusEvent;
        
        /********************************************************************************
         * Parse arguments
         ********************************************************************************/
      
        parser.Parse(args);
              
        /********************************************************************************
         * File name 
         ********************************************************************************/

        if (parser.Arguments.ContainsKey(ARG_KEY_FILE))
        {
          pwf.X12FileIn = parser.Arguments[ARG_KEY_FILE][0];
        }
        else
        {        
          DisplayUsage();     
          return (int) ExitCodes.NoFileNameProvided;
        }

        /********************************************************************************
         * Archive file (zip) password
         ********************************************************************************/

        if (parser.Arguments.ContainsKey(ARG_KEY_PWD)) 
          pwf.ZipFilePassword = parser.Arguments[ARG_KEY_PWD][0];
                    
        /********************************************************************************
         * Options
         ********************************************************************************/
        
        if (parser.Arguments.ContainsKey(ARG_KEY_NO_CSV_FILE))    pwf.GenerateCSVImportFile      = false;
        else                                                      pwf.GenerateCSVImportFile      = true;
        
        if (parser.Arguments.ContainsKey(ARG_KEY_NO_REPORT_FILE)) pwf.GenerateContentReportFile  = false;
        else                                                      pwf.GenerateContentReportFile  = true;
        
        if (parser.Arguments.ContainsKey(ARG_KEY_YES_XML_FILE))   pwf.GenerateXMLImportFile      = true;
        else                                                      pwf.GenerateXMLImportFile      = false;
                
       /********************************************************************************
        * Run parser 
        ********************************************************************************/
    
        return pwf.RunParser();
        
      }
      
      /********************************************************************************
       * Unexpected error 
       ********************************************************************************/
        
      catch (Exception e)
      {
        DisplayMessage(e.Message);
        return (int) ExitCodes.UnknownError;
      }

      /********************************************************************************
       * Clean up and get ready to exit 
       ********************************************************************************/

      finally
      {        
        DisplayMessage(@"Exiting application");        
      }
      
    }
  }
}
