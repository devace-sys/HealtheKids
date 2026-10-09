using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;

namespace Spedmon
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        static void Main(string[] args)
        {   
            WatchForAndProcessUserNotifications ServiceToRun = new WatchForAndProcessUserNotifications();                        
            
            if (!Environment.UserInteractive)
            {   
              ServiceBase.Run(ServiceToRun);
            }  
            else
            { 
              ServiceToRun.TestStartupAndStop(args);  
            }
        }
    }
}
