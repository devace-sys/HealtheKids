using System;
using System.Threading;
using System.Web;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.IO;

namespace MBA
{
  /***************************************************************************
   * Rules */
  /**
   * Business rules for the application.
   ***************************************************************************/    
  
  public class Rules
  {
    public static readonly int      MAX_NUM_LOGIN_ATTEMPTS                  = 5;
    public static readonly int      MAX_IDLE_SESSION_MIN                    = 60;   /* Keep in synch with MAX_IDLE_SESSION_SECS  60 min*/ 
    public static readonly int      MAX_IDLE_SESSION_SECS                   = 3600; /* Keep in synch with MAX_IDLE_SESSION_MINS  3600 sec */
    public static readonly int      USER_IS_CONSIDERED_IDLE_AFTER_N_SECONDS = 600;  /* After this time elapses the keep alive requests stop.  600 = 10 mins*/
    public static readonly int      MAX_TOKEN_VALID_HRS                     = 12;    

    public static readonly bool     PASSWORDS_EXPIRE            = false;
    public static readonly int      MAX_PASSWORD_VALID_DAYS     = 180;
    public static readonly int      PASSWORD_CHANGE_WARN        = 10;
    public static readonly int      VIEW_SEL_PAGE_SIZE          = 500;
    public static readonly int      VIEW_TBL_PAGE_SIZE          = 50;
    public static readonly int      VIEW_OBJ_PAGE_SIZE          = 100;
    public static readonly int      MIN_PAGE_SIZE               = 1;
    public static readonly int      MAX_PAGE_SIZE               = 1000;
    public static readonly int      MAX_EXCEL_ROWS              = 65535;
    public static readonly int      PWD_MIN_LENGTH              = 8;
    public static readonly int      PWD_MAX_LENGTH              = 50;
    public static readonly int      WEB_REQ_TIMEOUT             = 3600;                         /* in seconds (3600 = 1hr) */
    public static readonly int      DB_CMD_TIMEOUT              = MBA.Constants.DB_CMD_TIMEOUT; /* In seconds */
    public static readonly bool     RESPONSE_REMOVE_WHITE_SPACE = true;
    public static readonly bool     RESPONSE_COMPRESS           = true;
    public static readonly TimeSpan CACHE_DURATION              = TimeSpan.FromDays(10);
    public static readonly bool     SECURE_CONNECTION_REQ       = true;
    
    public static readonly DateTime  MIN_DATE                   = new DateTime(1753,1,1);       /* SQL Server min date is 1/1/1753 */
    
    public static bool LOG_REQUEST_RESPONSE {get{return Convert.ToBoolean(System.Configuration.ConfigurationManager.AppSettings.Get("rrLog"));}}
  }
}
