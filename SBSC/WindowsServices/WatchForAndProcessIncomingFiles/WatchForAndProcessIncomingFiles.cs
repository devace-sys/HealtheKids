using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using System.Configuration;
using System.Threading;
using System.Timers;

namespace Spedmon
{
    public partial class WatchForAndProcessIncomingFiles : ServiceBase
    {
        protected string[]                    _cmdArgs = null;
        protected System.Timers.Timer         _backgroundCheckTimer;  

        public string[] cmdArgs { get {  return _cmdArgs;} }
        string watchPath;
        public WatchForAndProcessIncomingFiles()
        {
            InitializeComponent();
            if (!System.Diagnostics.EventLog.SourceExists("WatchForAndProcessIncomingFilesService"))
            {
                System.Diagnostics.EventLog.CreateEventSource(
                    "WatchForAndProcessIncomingFilesService", "WatchForAndProcessIncomingFilesLog");
            }
            eventLog1 = new System.Diagnostics.EventLog();
            eventLog1.Source = "WatchForAndProcessIncomingFilesService";
            eventLog1.Log = "WatchForAndProcessIncomingFilesLog";

        }

        public enum ServiceState
        {
            SERVICE_STOPPED = 0x00000001,
            SERVICE_START_PENDING = 0x00000002,
            SERVICE_STOP_PENDING = 0x00000003,
            SERVICE_RUNNING = 0x00000004,
            SERVICE_CONTINUE_PENDING = 0x00000005,
            SERVICE_PAUSE_PENDING = 0x00000006,
            SERVICE_PAUSED = 0x00000007,
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct ServiceStatus
        {
            public int dwServiceType;
            public ServiceState dwCurrentState;
            public int dwControlsAccepted;
            public int dwWin32ExitCode;
            public int dwServiceSpecificExitCode;
            public int dwCheckPoint;
            public int dwWaitHint;
        };

        [DllImport("advapi32.dll", SetLastError = true)]
        private static extern bool SetServiceStatus(System.IntPtr handle, ref ServiceStatus serviceStatus);
        

        private void _processFiles()
        {             
           try
           {
              /* Turn off the timer and watcher temporarily */               
              _backgroundCheckTimer.Stop();        
              fileSystemWatcher1.EnableRaisingEvents = false;
              ProcessUploadFile.StartProcessingFiles();        
           }
           finally
           {
             /* Turn on the timer and watcher again*/               
             _backgroundCheckTimer.Start();
             fileSystemWatcher1.EnableRaisingEvents = true;
           }
        }

        private void _backgroundCheckForFiles (object sender, ElapsedEventArgs args) 
        {
           try
           {    
               /* Process any unprocessed files */               
               eventLog1.WriteEntry("Running periodic background check for unprocessed files " + DateTime.Now.ToString(), EventLogEntryType.Information);                      
               _processFiles();                                              
           }
           catch(Exception exception)
           {
                string message = (string.IsNullOrEmpty(exception.Message) ? string.Empty : exception.Message + "\n")
                    + (string.IsNullOrEmpty(exception.InnerException.Message) ? string.Empty : exception.InnerException.Message + "\n")
                    + exception.StackTrace;
                eventLog1.WriteEntry("Error caught processing files\n" + message, EventLogEntryType.Error);
           }
           finally
           {
           }
        }

        private void fileSystemWatcher1_Created(object sender, System.IO.FileSystemEventArgs e)
        {
            /* A file was created*/

            try
            {                            
                eventLog1.WriteEntry("Detected a file upload " + DateTime.Now.ToString(), EventLogEntryType.Information);
                _processFiles();
            }
            catch(Exception exception)
            {
                string message = (string.IsNullOrEmpty(exception.Message) ? string.Empty : exception.Message + "\n")
                    + (string.IsNullOrEmpty(exception.InnerException.Message) ? string.Empty : exception.InnerException.Message + "\n")
                    + exception.StackTrace;
                eventLog1.WriteEntry("Error caught processing files\n" + message, EventLogEntryType.Error);
            }
            finally
            {
            
            }
        }
        protected override void OnStart(string[] args)
        {
            try
            {
                /* Update the service state to Start Pending. */
                
                ServiceStatus serviceStatus  = new ServiceStatus();
                serviceStatus.dwCurrentState = ServiceState.SERVICE_START_PENDING;
                serviceStatus.dwWaitHint     = 100000;
                SetServiceStatus(this.ServiceHandle, ref serviceStatus);

                /* Get path to watch but dont assign to the watcher yet */

                watchPath = ConfigurationManager.AppSettings["SendUsAFileUploadPath"];                

                 /* Save command line args (if any) */

                this._cmdArgs = args;
                 
                 /* Init background timer that periodically checks for unprocessed incoming files */

                _backgroundCheckTimer = new System.Timers.Timer();
                _backgroundCheckTimer.Interval  = 60000;  /* Wait 60 seconds */
                _backgroundCheckTimer.AutoReset = false; /* One shot */
                _backgroundCheckTimer.Elapsed   += new ElapsedEventHandler(this._backgroundCheckForFiles);
                                
                /* Update the service state to Running */

                serviceStatus.dwCurrentState = ServiceState.SERVICE_RUNNING;
                SetServiceStatus(this.ServiceHandle, ref serviceStatus);
                eventLog1.WriteEntry("Service started at " + DateTime.Now.ToString(), EventLogEntryType.Information);
                                
                /* Start background timer */

                _backgroundCheckTimer.Start();
                
                /* Start watcher */

                fileSystemWatcher1.Path = watchPath;
                fileSystemWatcher1.EnableRaisingEvents = true;

            }
            catch (Exception exception)
            {
                string message = (string.IsNullOrEmpty(exception.Message) ? string.Empty : exception.Message + "\n")
                    + (string.IsNullOrEmpty(exception.InnerException.Message) ? string.Empty : exception.InnerException.Message + "\n")
                    + exception.StackTrace;
                eventLog1.WriteEntry("Error caught on start up\n" + message, EventLogEntryType.Error);
            }
            finally
            {

            }
        }

        protected override void OnStop()
        {
            /* Turn off the timer and tell watcher to stop */
               
            _backgroundCheckTimer.Stop();    
            fileSystemWatcher1.EnableRaisingEvents = false;

            /* Update the service state to Stop Pending */

            ServiceStatus serviceStatus = new ServiceStatus();
            serviceStatus.dwCurrentState = ServiceState.SERVICE_STOP_PENDING;
            serviceStatus.dwWaitHint = 100000;
            SetServiceStatus(this.ServiceHandle, ref serviceStatus);

            /* Update the service state to Stopped. */

            serviceStatus.dwCurrentState = ServiceState.SERVICE_STOPPED;
            SetServiceStatus(this.ServiceHandle, ref serviceStatus);
            eventLog1.WriteEntry("Service stopped at " + DateTime.Now.ToString(), EventLogEntryType.Information);
        }

        public void TestStartupAndStop(string[] args)  
        {  
          this.OnStart(args);  
          Console.ReadLine();  
          this.OnStop();  
        }  
    }
}
