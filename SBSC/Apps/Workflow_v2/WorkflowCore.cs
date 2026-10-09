using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using System.Configuration;
using System.Net.Configuration;


using System.Data.SqlClient;

using MBA;

namespace Workflow_v2
{

    static class WorkflowCore
    {

        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            int exitCode = 0;  // Assume success
            
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new WorkflowInstance());

            Environment.Exit(exitCode);
        }

        
    }
}
