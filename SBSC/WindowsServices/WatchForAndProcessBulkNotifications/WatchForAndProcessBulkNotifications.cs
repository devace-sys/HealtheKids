using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Runtime.InteropServices;
using System.Configuration;
using System.Threading;
using System.Threading.Tasks;
using System.IO.Pipes;
using System.Timers;
using System.Data.SqlClient;


namespace Spedmon
{
    public class WatchForAndProcessBulkNotifications : ServiceBase
    {
        protected System.Diagnostics.EventLog _winEventLog;
        protected System.Timers.Timer         _mainTimer;               
        protected string[]                    _cmdArgs = null;
     
        public const string EVENT_SOURCE_NAME           = @"ProcessBulkNotifications";
        public const string EVENT_SOURCE_LOG_NAME       = @"ProcessBulkNotificationsLog";
        public const Double DEFAULT_MAIN_TIMER_INTERVAL = 15000d;

        public WatchForAndProcessBulkNotifications()
        {
          /* If the event log does not exist yet, create it.*/
          
          if (!System.Diagnostics.EventLog.SourceExists(EVENT_SOURCE_NAME))
          {
            System.Diagnostics.EventLog.CreateEventSource(EVENT_SOURCE_NAME, EVENT_SOURCE_LOG_NAME);
          }
          
          /* Then reference either the existing or newly created log */

          _winEventLog        = new System.Diagnostics.EventLog();
          _winEventLog.Source = EVENT_SOURCE_NAME;
          _winEventLog.Log    = EVENT_SOURCE_LOG_NAME;
        }

        public enum ServiceState
        {
             SERVICE_STOPPED          = 0x00000001
           , SERVICE_START_PENDING    = 0x00000002
           , SERVICE_STOP_PENDING     = 0x00000003
           , SERVICE_RUNNING          = 0x00000004
           , SERVICE_CONTINUE_PENDING = 0x00000005
           , SERVICE_PAUSE_PENDING    = 0x00000006
           , SERVICE_PAUSED           = 0x00000007
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct ServiceStatus
        {
            public int          dwServiceType;
            public ServiceState dwCurrentState;
            public int          dwControlsAccepted;
            public int          dwWin32ExitCode;
            public int          dwServiceSpecificExitCode;
            public int          dwCheckPoint;
            public int          dwWaitHint;
        };

        [DllImport("advapi32.dll", SetLastError = true)]
        private static extern bool SetServiceStatus(System.IntPtr handle, ref ServiceStatus serviceStatus);

        public string[] cmdArgs { get {  return _cmdArgs;} }
        
        protected void _mainTaskHandler(object sender, ElapsedEventArgs args) 
        {           
           _winEventLog.WriteEntry("Checking for and processing new bulk notifications " + DateTime.Now.ToString(), EventLogEntryType.Information);           
           
           try
           {
               _mainTimer.Stop(); /* Temp stop timer just in case*/
               
               ProcessBulkNotifications.StartProcessingBulkNotifications (this._cmdArgs);
           }
           catch (Exception exception)
           {
              string message = (string.IsNullOrEmpty(exception.Message) ? string.Empty : exception.Message + "\n")
                 + (string.IsNullOrEmpty(exception.InnerException.Message) ? string.Empty : exception.InnerException.Message + "\n")
                 + exception.StackTrace;
                _winEventLog.WriteEntry("Error caught on processing bulk notifications \n" + message, EventLogEntryType.Error);
           }
           finally
           {
               _mainTimer.Start(); /* Restart timer */
           }
        }

        protected override void OnStart(string[] args)
        {
            try
            {
                /*  Update the service state to Start Pending */

                ServiceStatus serviceStatus  = new ServiceStatus();
                serviceStatus.dwCurrentState = ServiceState.SERVICE_START_PENDING;
                serviceStatus.dwWaitHint     = 100000;
                SetServiceStatus(this.ServiceHandle, ref serviceStatus);

                /* Save command line args (if any) */

                this._cmdArgs = args;

                /* Init and start timer that calls/polls main task handler timer */

                _mainTimer = new System.Timers.Timer();
                _mainTimer.AutoReset = false; /* Make this a one shot that we will restart */
                _mainTimer.Elapsed   += new ElapsedEventHandler(this._mainTaskHandler);
                
                double _timerIntervalIn = DEFAULT_MAIN_TIMER_INTERVAL; 
                
                /* Set interval */

                if (!Double.TryParse(ConfigurationManager.AppSettings["MainTimerInterval"],out _timerIntervalIn))
                {
                    _timerIntervalIn = DEFAULT_MAIN_TIMER_INTERVAL;
                }
                else
                { 
                  if (_timerIntervalIn <= 0d)      _timerIntervalIn = DEFAULT_MAIN_TIMER_INTERVAL;
                  if (_timerIntervalIn >= 120000d) _timerIntervalIn = DEFAULT_MAIN_TIMER_INTERVAL;
                }
                
                _mainTimer.Interval = _timerIntervalIn;

                /* Update the service state to running */

                serviceStatus.dwCurrentState = ServiceState.SERVICE_RUNNING;
                SetServiceStatus(this.ServiceHandle, ref serviceStatus);
                _winEventLog.WriteEntry("Service started at " + DateTime.Now.ToString(), EventLogEntryType.Information);
                _winEventLog.WriteEntry("Polling interval is " + _timerIntervalIn.ToString() + " mS " + DateTime.Now.ToString(), EventLogEntryType.Information);
                
                /* Start polling */
                      
                _mainTimer.Start();                
               
            }
            catch (Exception exception)
            {
                string message = (string.IsNullOrEmpty(exception.Message) ? string.Empty : exception.Message + "\n")
                    + (string.IsNullOrEmpty(exception.InnerException.Message) ? string.Empty : exception.InnerException.Message + "\n")
                    + exception.StackTrace;
                _winEventLog.WriteEntry("Error caught on start up\n" + message, EventLogEntryType.Error);
            }
            finally
            {

            }
        }
        
        protected override void OnStop()
        {

            _mainTimer.Stop();

            /* update the service state to stop pending */

            ServiceStatus serviceStatus = new ServiceStatus();
            serviceStatus.dwCurrentState = ServiceState.SERVICE_STOP_PENDING;
            serviceStatus.dwWaitHint = 100000;
            SetServiceStatus(this.ServiceHandle, ref serviceStatus);

            /* Update the service state to stopped */

            serviceStatus.dwCurrentState = ServiceState.SERVICE_STOPPED;
            SetServiceStatus(this.ServiceHandle, ref serviceStatus);
            _winEventLog.WriteEntry("Service stopped at " + DateTime.Now.ToString(), EventLogEntryType.Information); 
                        
         }

        public void TestStartupAndStop(string[] args)  
        {  
          this.OnStart(args);  
          Console.ReadLine();  
          this.OnStop();  
        }  
    }
}
