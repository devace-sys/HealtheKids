using System;
using System.Threading;
using MBA;


namespace Spedmon
{
  /***************************************************************************
   * Constants */
  /**
   * Contains various constants
   ***************************************************************************/   

  public class Constants:MBA.Constants
  {
    
        
    public static string  SEND_US_A_FILE_UPLOAD_PATH      { get {return getAppSetting (@"SendUsAFileUploadPath");}}
    public static string  SERVICE_NOTES_FILE_UPLOAD_PATH  { get {return getAppSetting (@"ServiceNotesFileUploadPath");}}

    public static string  REQUEST_OPR_DOC_STD_NAME_MENU_ID = @"requestorpdocstdnamelink";
    public static string  REQUEST_ORP_DOC_STD_NAME_LBL     = @"Request A New Service Name";
    public static string  REQUEST_ORP_DOC_STD_NAME_URL     = @"https://app.smartsheet.com/b/form/8923cb42c778435dad628bb67f13ff2a";
    
    public new const string  APP_VERSION      =  @"415.2";    // Version of Spedcare (change with each new release)

    public new const string  APP_THEME        =  @"south-street";

    public new const string  LOG_FILE_NAME    =  @"Spedmon";
    
    /* TODO: Refactor NEW_ACCOUNT_MESSAGE_TEMPLATE_TITLE if neccessary and remove */
    public static readonly string NEW_ACCOUNT_MESSAGE_TEMPLATE_TITLE = @"Your new {0} account has been setup";
    /* TODO: Refactor  NEW_ACCOUNT_MESSAGE_TEMPLATE_BODY if neccessary and remove */
    public static readonly string NEW_ACCOUNT_MESSAGE_TEMPLATE_BODY  = @"<p>Hello,<p>"
                                                                     + @"<p>Your new {0} account has been setup with the username and temporary password shown below.</p>"
                                                                     + @"<p>{1}<br/>{2}</p>"
                                                                     + @"<p>To complete the account setup process you must change your password.  We recommend you keep this email open so you can copy/paste the temporary password into the required field.</p>"
                                                                     + @"<p>Please click <a href=""{3}"">here</a> and follow the instructions on the screen to complete your account setup.</p>"
                                                                     + Messages.DID_NOT_REQUEST
                                                                     + @"<p>When you first log in to SpEdCare, you will see several announcements that need to be reviewed. This is a one time action and once you select �I have Reviewed This One� the announcement or resource will then be accessible in your help library. You can access your help library anytime, by clicking on the �Teach Me� button at the top of your screen. Your Help Library has all the resources you need to successfully participate in the LEA Billing Option Program.</p>"
                                                                     + @"<p>Thank you for your valuable participation in the LEA Billing Program. If you need to contact your assigned Practi-Cal consultant, you can find their contact information in the upper right corner of your SpEdCare browser page, once you have logged in.</p>"
                                                                     + Messages.DO_NOT_REPLY
                                                                     + @"<p>Sincerely,<br/>The Practi-Cal Team</p>"
                                                                     + @"<hr/>"
                                                                     + @"<p>"
                                                                     + Messages.CONFIDENTIAL_EMAIL
                                                                     + @"</p>";

    

    // Entity types
    
    //public const int    PROC_ENT_TYPE_GROUP     = 0;
    //public const int    PROC_ENT_TYPE_PRAC      = 1;
    
    // Record types
    
    public const int    PROC_REC_TYPE_NONE      = 0;
    public const int    PROC_REC_TYPE_NAME_ID   = 1;

    // Service types
    
    public const int    SERVICES_ASSESS         = 1;
    public const int    SERVICES_TREATMENT      = 2;
    public const int    SERVICES_TRANSPORT      = 3;
    public const int    SERVICES_TCM            = 4;

    public const int    SVC_REC_TYPE_TIME       = 1;
    public const int    SVC_REC_TYPE_TRANS      = 2;
    
    // Standard group family 
    
    public const long   GROUP_SERVICE_CLASS_NAME_ID_SPEECH                 = 9;
    public const long   GROUP_SERVICE_CLASS_NAME_ID_HEARING                = 8;
    public const long   GROUP_SERVICE_CLASS_NAME_ID_PT                     = 6;
    public const long   GROUP_SERVICE_CLASS_NAME_ID_VISION                 = 5;
    public const long   GROUP_SERVICE_CLASS_NAME_ID_OT                     = 4;
    public const long   GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES        = 3;
    public const long   GROUP_SERVICE_CLASS_NAME_ID_MENTAL_HEALTH_SERVICES = 2;
    public const long   GROUP_SERVICE_CLASS_NAME_ID_TEACHERS_PROG_SPECS    = 1;

    // Plan writer groups
    
    public const long   PLAN_WRITER_GROUP_ID_HS =   GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES;

    // Date range default for service record edit
    
    public const int    SVC_REC_EDIT_DATE_RANGE_CONST = 8; /* Last 90 days */

    // Default date for earliest date of service

    public const string DEFAULT_EARLIEST_DOS = "7/1/2015";
    
    
    /***************************************************************************
     * Report numbers defined for use with Report Subscribability feature*/
    /*
     ***************************************************************************/
         
    public const int REPT_NUM_CLAIMS_PAID_BY_DOW_1P             = 1;   // Claims paid by check date 1P
    public const int REPT_NUM_CLAIMS_PAID_BY_DOW_2P             = 2;   // 2P
    public const int REPT_NUM_CLAIMS_PAID_BY_DOS_1P             = 3;   // Claims paid by date of service 1P
    public const int REPT_NUM_CLAIMS_PAID_BY_DOS_2P             = 4;   // 2P
    public const int REPT_NUM_CLAIMS_PAID_BY_DOS_BY_ELIG_PAT_2P = 6;   // Claims paid by date by eligible patient 2P
    
    public const int REPT_SPEDCARE_WEEKLY_RPT = 10;
    public const int REPT_TATTLETALE = 11;

    public const int REPT_BATCHES_NEEDING_PRIORITY_REVIEW       = 13;
	public const int REPT_CLAIMS_TRANSMISSION_SUMMARY           = 14;

   /***************************************************************************
    * Export numbers defined for use with file export subscribability feature*/
   /*
    ***************************************************************************/
    
    public const int FILE_EXPORT_ORDERS_CURRENT_AND_EXPIRING = 1000;

    /***************************************************************************
    * All in one service record entry screen for practitioner use */
   /*
    ***************************************************************************/

    public const string PARM_SVCETRMDE                          = "svcetrmde";

    public const int    SVCETRMDE_RECORD_SERVICES                      = 1;
    public const int    SVCETRMDE_RECORD_SCHEDULED_SERVICES            = 2;
    public const int    SVCETRMDE_RECORD_MISSING_ASSMTS_ALL_PATS       = 3;
    public const int    SVCETEMDE_RECORD_MISSING_TMT_FOR_PAT           = 4;
    public const int    SVCETRMDE_RECORD_MISSING_ASSMTS_CASELOAD_ONLY  = 5;
        
    public const int    PLANTYPE_IEP_IFSP                       = 1;
    public const int    PLANTYPE_OTHER                          = 2;


   /***************************************************************************
    * The following variables correspond to the entry modes for practitioner
    * supervision details screen                                              
    ***************************************************************************/
     
     public const string PARM_PRAC_SUP_DETAILS_ENTRY_MODE    = "pracsupdetentrymode";
                                                           
     public const int PRAC_SUP_DETAILS_ENTRY_MODE_JOURNAL    = 1;
     public const int PRAC_SUP_DETAILS_ENTRY_MODE_PRAC       = 2;
     public const int PRAC_SUP_DETAILS_ENTRY_MODE_PAT        = 3;
     public const int PRAC_SUP_DETAILS_ENTRY_MODE_SVC_REC    = 4;

     //public const int NOTIF_PROMPT_INCL_FILELIST_BTN      = 1;

     public const int RMTS_NOTIF_PROMPT_INCL_MANAGE_SVCRECS      = 2;
     public const int RMTS_NOTIF_PROMPT_INCL_ADD_SVCREC          = 4;
     public const int RMTS_NOTIF_PROMPT_INCL_FILEUPBOX_RMTSMOMNT = 8;    // bitwise arithmetic

     public const int RPT_CYBHI_PRACS_AUDIT        = 210;
     public const int RPT_CYBHI_PATS_AUDIT         = 210;

    }
}