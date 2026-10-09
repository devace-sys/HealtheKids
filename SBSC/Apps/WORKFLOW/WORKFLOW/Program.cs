using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using MBA;
using System.Configuration;
using System.Net.Configuration;

namespace WORKFLOW
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
                
        [STAThread]
        static void Main(string[] args)
        {
            int exitCode = 0;  // Assume success
            
            try
            {
               /*-------------------------------
                * Replace app config with our
                * own
                *------------------------------*/ 

                //AppDomain.CurrentDomain.SetData("APP_CONFIG_FILE", "WORKFLOW.config");
                
                
                Application.EnableVisualStyles();
                Application.SetCompatibleTextRenderingDefault(false);

                



                Application.Run(new SBSCParent());
            }
            
            catch (Exception e)
            {
              /*-------------------------------
               * Don't display warning messages
               * if this is being run in
               * "report mode"
               *------------------------------*/ 
            
              if (args.Length == 0)
              {
                WinFormsApplication.DisplayNotice(Return.RET_FATAL, e.Message);
              }
              
             /*-------------------------------
              * Return failure to OS
              *------------------------------*/ 
              
              exitCode = 1; // Failure
            
            }
            
            Environment.Exit(exitCode);
                  
        }
    }
}
