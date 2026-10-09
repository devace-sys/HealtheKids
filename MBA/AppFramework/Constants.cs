using System;
using System.Threading;
using System.Configuration;



namespace MBA
{
    /***************************************************************************
     * Constants */
    /**
     * Contains various constants and methods for retrieving constants from
     * the application settings.
     ***************************************************************************/

    public class Constants
    {
        /***************************************************************************
         * getAppSetting */
        /**
         * Returns setting from app settings (settings are stored as strings)
         * 
         * @param    setting        Setting value (case sensitive)
         * @param    defaultvalue   Default to use if setting is null or empty
         * @return                  Value of setting
         ***************************************************************************/

        public static string getAppSetting(string setting)
        {
            return getAppSetting(setting, null);
        }

        public static string getAppSetting(string setting, string defaultvalue)
        {
            string value = "";
            string dvalue = Util.IsNullOrEmpty(defaultvalue) ? null : defaultvalue;
            try
            {
                value = ConfigurationManager.AppSettings[setting];
            }
            catch
            {
                value = null;
            }

            if (Util.IsNullOrEmpty(value))
                return dvalue;
            else
                return value;

        }

        /***************************************************************************
         * getAppSettingInt */
        /**
         * Returns setting from app settings and converts to an integer
         * 
         * @param    setting    Setting value (case sensitive)
         * @return              Value of setting as an integer 
         ***************************************************************************/

        public static int? getAppSettingInt(string setting, string defaultvalue)
        {
            string value = getAppSetting(setting, defaultvalue);
            if (!Util.IsNullOrEmpty(value))
                return Convert.ToInt32(getAppSetting(setting));
            else
                return null;
        }

        /***************************************************************************
         * getAppSettingBool */
        /**
         * Returns setting from app settings and converts to a boolean
         * 
         * @param    setting    Setting value (case sensitive)
         * @return              Value of setting as a bool
         ***************************************************************************/

        public static bool? getAppSettingBool(string setting, string defaultvalue)
        {
            string value = getAppSetting(setting, defaultvalue);
            if (!Util.IsNullOrEmpty(value))
                return Util.evaluateFlag(value, false);
            else
                return null;
        }

        /***************************************************************************
         * getAppSettingJSONObject */
        /**
         * Returns setting from app settings stored as a JSON string as object of type.
         * 
         * @param    setting    Setting value (case sensitive)
         * @param    type       Expected type of deserialized object [use typeof()]
         * @return              Value of setting as Object [cast to the type]
         ***************************************************************************/

        public static Object getAppSettingJSONObject(string setting, Type type)
        {
            string value = getAppSetting(setting);
            if (!Util.IsNullOrEmpty(value))
                return JSON.fromJSONString(value, type);
            else
                return null;
        }

        /*-------------------------------
         * Database connection strings
         * for user and application
         * databases
         *------------------------------*/

        public static string DB_CONN_USERS_SETTING = "dbConnUsers";
        public static string DB_CONN_APP_SETTING = "dbConnApp";

        public static string DB_CONN_USERS { get { return getAppSetting(DB_CONN_USERS_SETTING); } }
        public static string DB_CONN_APP { get { return getAppSetting(DB_CONN_APP_SETTING); } }

        /*-------------------------------
         * Database commmand time out
         * (in seconds, 0 = no timeout
         *------------------------------*/
        public static int DB_CMD_TIMEOUT { get { return (int)getAppSettingInt("dbCmdTimeOut", "3600"); } }

        /*-------------------------------
         * Log file path
         *------------------------------*/
        public static string LOG_FILE_PATH { get { return getAppSetting("logFilePath"); } }

        /*-------------------------------
         * Log file name
         *------------------------------*/

        public static string LOG_FILE_NAME { get { return getAppSetting("logFileName", @"MBA"); } }


        /*-------------------------------
         * USPS API Values
         *
         * (USPS HAS RETIRED AS OF 1/25/2026)
         * 
         * Replace with new API URL and key
         *
         * 1. Here
         * 2. in web.config app settings
         * (look for uspsShippingApiUrl, uspsShippingApiKey
         *------------------------------*/

        public static string USPS_SHIPPING_API_URL { get { return getAppSetting("uspsShippingApiUrl", @"http://production.shippingapis.com/ShippingAPI.dll"); } }
        public static string USPS_SHIPPING_API_KEY { get { return getAppSetting("uspsShippingApiKey", @"541SBSC08082"); } }

        /*-------------------------------
         * USPS Address Standardization 
         * API(v3) with OAuth2
         * 
         * Replace with new API URL and key
         * as needed:
         * 
         * 1. Here
         * 2. in web.config app settings
         * ---------------------------------*/

        public static string USPS_ADDRESS_STANDARDIZATION_API_URL       { get { return getAppSetting("uspsAddressStandarizationApiURL",@"https://apis.usps.com/addresses/v3/address"); } }
        public static string USPS_ADDRESS_STANDARDIZATION_OAUTH_URL     { get { return getAppSetting("uspsAddressStandarizationOathURL",@"https://apis.usps.com/oauth2/v3/token"); } }
        public static string USPS_ADDRESS_STANDARDIZATION_CLIENT_ID     { get { return getAppSetting("uspsAddressStandarizationClientID",@"jcmOaOGhJtwWUc4wPutJ4VZXlH5Gg6AuQKMeLWu3GhFskGup"); } }
        public static string USPS_ADDRESS_STANDARDIZATION_CLIENT_SECRET { get { return getAppSetting("uspsAddressStandarizationClientSecret",@"PATA134cNmNWjg1Imhtbn1EBjSr4JjqKoy5FXS0oFTLNirypG2Wvs7WDIbIiZM6t"); } }


        /*-------------------------------
         * Google API Values
         *------------------------------*/

        public static string GOOG_DIST_MATRIX_API_URL { get { return getAppSetting ("googDistMatrixApiUrl", @"https://maps.googleapis.com/maps/api/distancematrix/json");}} 
   public static string GOOG_DIST_MATRIX_API_KEY { get { return getAppSetting ("googDistMatrixApiKey", @"AIzaSyAixyBd_FxzVZHkZjvYFrO1Zo-0AnBoXGE");}} 
      
   public static int    GOOG_DIST_MATRIX_REFRESH_MAX_AGE_IN_DAYS    { get {return (int)  getAppSettingInt  ("googeDistMatrixRefreshMaxAgeInDays",    "180");   }}
   public static bool   GOOG_DIST_MATRIX_REFRESH_FOR_ALL_REQUESTS   { get {return (bool) getAppSettingBool ("googeDistMatrixRefreshForAllRequests",  "false"); }}
   
   /*-------------------------------
    * CDE Urls (for scraping)
    *------------------------------*/ 

   public static string CDE_SCHOOL_DIR_URL       { get { return getAppSetting ("cdeSchoolDirUrl", @"http://www.cde.ca.gov/SchoolDirectory/details");}} 
         
   public static string CMS_API_URL              { get { return getAppSetting ("cmsApiUrl",     @"https://npiregistry.cms.hhs.gov/api/");}} 
   public static string CMS_API_VERSION          { get { return getAppSetting ("cmsApiVersion", @"2.1");}} 

   /*-------------------------------
    * OpenVidu
    *------------------------------*/ 
   public static int    OPEN_VIDU_APP_ENVIRONMENT { get { return (int) getAppSettingInt  ("openViduAppEnvironment", "1");   }}
   public static string OPEN_VIDU_SERVER          { get { return getAppSetting ("openViduServer"  , @"https://ter.help4schools.com:4443");}} 
   public static string OPEN_VIDU_USER_NAME       { get { return getAppSetting ("openViduUserName", @"OPENVIDUAPP");}} 
   public static string OPEN_VIDU_PASSWORD        { get { return getAppSetting ("openViduPassword", @"MAYARITA");}}    
   public static int OPEN_VIDU_CLIENT_MIN_RECV_BANDWIDTH  { get { return (int) getAppSettingInt  ("openViduClientMinRecvBandwidth", "0");   }}
   public static int OPEN_VIDU_CLIENT_MAX_RECV_BANDWIDTH  { get { return (int) getAppSettingInt  ("openViduClientMaxRecvBandwidth", "1000"); }}
   public static int OPEN_VIDU_CLIENT_MIN_SEND_BANDWIDTH  { get { return (int) getAppSettingInt  ("openViduClientMinSendBandwidth", "0"); }}
   public static int OPEN_VIDU_CLIENT_MAX_SEND_BANDWIDTH  { get { return (int) getAppSettingInt  ("openViduClientMaxSendBandwidth", "1000");}} 

   /*-------------------------------
    * TAWK TO
    *------------------------------*/ 

   public static string TAWK_TO_JS_API_KEY = @"f0ef37f4baace7ae11fdffaf748d0c19a62b8310";

   /*-------------------------------
    * File upload path
    *------------------------------*/ 
   public static string  FILE_UPLOAD_PATH       { get {return getAppSetting (@"SendUsAFileUploadPath");}}
   public static string  REPORT_TEMPLATES_PATH  { get {return getAppSetting (@"ReportTemplatesPath");}}
   public static string  STRUCTURED_DATA_IMPORT_PROFILES_PATH  { get {return getAppSetting (@"StructuredDataImportProfilesPath");}}

   /*-------------------------------
    * ARIES Exports
    *------------------------------*/    
   public static string ARIES_EXPORTS_FILE_PATH { get { return getAppSetting ("ariesExportsFilePath", @"C:\spedmon\data\import-export\patient\");}} 
        
   /*-------------------------------
    * Third Party Data Updates
    *------------------------------*/    
   public static string BATCH_UPDATE_TRIP_CALCS_ENABLED    { get { return getAppSetting ("batchUpdateTripCalcsEnabled","1");}} 
   public static string BATCH_UPDATE_ARIES_EXPORTS_ENABLED { get { return getAppSetting ("batchAriesExportsEnabled","1");}} 


  /*-------------------------------
    * Application 
    * 
    *   - Virtual directory
    *   - Name
    *   - Version
    *   - SMTP settings
    *   - Contact information    
    *   - Desktop jQuery UI Theme   
    *------------------------------*/ 
    public static string  APP_HTTP_HOST   { get {return getAppSetting ("appHTTPHost",  ""); }} /* Default must be empty string */
    public static string  APP_VDIR        { get {return getAppSetting ("appVdir");}}
    public static string  APP_NAME        { get {return getAppSetting ("appName");}}
    public static string  APP_TITLE        { get {return getAppSetting ("appTitle", @"Health e Kids - LEA BOP Billing, CYBHI Billing, School Based Medical and Mental Health Services Record Keeping");}}
    public static string  APPLICATION_NAME { get {return getAppSetting ("applicationName", @"Health e Kids");}}
    public static string  APP_DESCRIPTION  { get {return getAppSetting ("appDescription",  @"");}}
    public static string  APP_KEYWORDS     { get {return getAppSetting ("appKeywords",     @"");}}
    public static string  APP_EMAIL_FROM  { get {return getAppSetting ("appEmailFrom", "noreply@localhost"); }}
    public static string  APP_SMTP_HOST   { get {return getAppSetting ("appSMTPHost",  "localhost"); }}
    
    public static int     APP_SMTP_PORT   { get {return (int) getAppSettingInt ("appSMTPPort", "25"); }}
    public static Contact APP_CONTACT     { get {return (Contact) getAppSettingJSONObject("appContact",typeof(Contact)); }}
    public static string  APP_NOTICE      { get {return getAppSetting ("appNotice","");}}
    public static bool?   SHOW_TER_MESSAGE  { get {return getAppSettingBool ("showTerMessage","false");}}
    public static bool?   APP_OFFLINE     { get {return getAppSettingBool ("appOffline","false");}}
    public static bool?   APP_SE_CRAWL            { get {return getAppSettingBool ("appSeCrawl","true");}}
    public static string  APP_NOTICE_STYLE_PUBLIC { get {return getAppSetting(@"appNoticeStylePublic",@"danger");}}
    public static int    APP_ENVIRONMENT          { get {return (int) getAppSettingInt ("appEnvironment", "1"); }}

    public const string   APP_VERSION    = @"Major.Minor";        // Set in inherited contacts
    public const string   APP_THEME      =  @"south-street";       // Set in inherited contacts

    public static int    STORED_FILES_APP_ENVIRONMENT          { get {return (int) getAppSettingInt ("storedFilesAppEnvironment", "3"); }}



   /*-------------------------------
    * Application Paths
    *------------------------------*/ 

    public const string PATH_CSS         = "css/";
    public const string PATH_JS          = "js/";
    public const string REL_PATH_CSS     = "~/css/";
    public const string REL_PATH_JS      = "~/js/";
    public const string REL_PATH_IMG     = "~/images/";
    public const string REL_PATH_SWF     = "~/flash/";
    public const string REL_PATH_HTML    = "~/html/";
    public const string REL_PATH_DATA    = "~/data/";
    
    public const string PHYS_PATH_HELP   = @"C:\spedmon\data\help";
    

    //public const string REL_PATH_DATA_MENUS = REL_PATH_DATA + "menus.json";
    
    public const string FILE_JS_JQUERY         = "jquery-1.8.0.min";
    public const string FILE_JS_JQUERY_1_11    = "jquery-1.11.1.min";
    public const string FILE_JS_JQUERY_UI      = "jquery-ui-1.8.23.custom.min";
    public const string FILE_JS_JQUERY_MOBILE  = "jquery.mobile-1.4.2.min";
    
    public const string FILE_CSS_RESET         = "reset";
    public const string FILE_CSS_JQUERY_UI     = APP_THEME + "/jquery-ui-1.8.23.custom";
    public const string FILE_CSS_JQUERY_UI_THEME_BASE = @"/base/jquery-ui.min";
    public const string FILE_CSS_JQUERY_MOBILE = @"themes/default/jquery.mobile-1.4.2.min";
    public const string FILE_CSS_REPORT_ALL    = "rpt_all";
    public const string FILE_CSS_REPORT_PRINT  = "rpt_print";

    public const string PARM_UJLI         = "ujli";  /* user just logged in */
    //public const string PARM_DNSUTD      = "dnsutd";
    public const string PARM_TOKEN        = "tkn";
    public const string PARM_PUBLIC_TOKEN = "ptkn";
    public const string PARM_UID          = "uid";
    public const string PARM_PWD          = "pwd";
    public const string PARM_GOTO_PAGE    = "gtp";
    public const string PARM_OLD_PWD      = "oldpwd";
    public const string PARM_NEW_PWD_1    = "newpwd1";
    public const string PARM_NEW_PWD_2    = "newpwd2";

    public const string PARM_CMD         = "cmd";
    public const string PARM_MSG         = "msg";
    public const string PARM_APP_MODE    = "amd";
    public const string PARM_PAGE_MODE   = "pagemode";
    public const string PARM_APP_TRANSFER = "axfer";
    public const string PARM_TAB_TO_OPEN  = "tabtoopn";
    public const string PARM_ENT_ID_1        = "entid1";         // Entity ID
    public const string PARM_ENT_ID_2        = "entid2";
    public const string PARM_ENT_ID_3        = "entid3";
    public const string PARM_ENT_DT_1        = "entdt1";         // Entity date
    public const string PARM_ENT_DT_2        = "entdt2";
    public const string PARM_ENT_NM_1        = "entnm1";         // Entity name
    public const string PARM_ENT_NM_2        = "entnm2";
    public const string PARM_OPT_FLAG_1      = "optflg1";
    public const string PARM_REP_FORM        = "reptform";       // Report format
    public const string PARM_REP_PAGING      = "reptpaging";     // Page view
    public const string PARM_REP_START_ROW   = "iDisplayStart";  // Start row
    public const string PARM_REP_NUMBER      = "reptnumber";     // Optional number
    public const string PARM_REP_REQUEST_UID = "reptreqguid";    // Client generated tracking id for downloads

    public const string PARM_REP_COLS_ONLY           = "reptcolsonly";
    public const string PARM_REP_EDIT_VIEW           = "repteditview";
    public const string PARM_REP_S_ECHO              = "sEcho";
    public const string PARM_SAVE_TYPE               = "savetype";
    public const string PARM_VALIDATE_REC            = "validaterec";    
    public const string PARM_EDIT_DEL_REASON         = "editDelReason";
    public const string PARM_VALIDATE_LIST           = "validatelist";
    public const string PARM_REC_ID                  = "recid";              // Record id
    public const string PARM_REC_ID_MULTI            = "recidmulti";
    public const string PARM_START_DATE              = "startdate";
    public const string PARM_END_DATE                = "enddate";
    public const string PARM_CREATED_OR_MODIFIED_ON  = "createdormodifiedon";
    public const string PARM_DATE_RANGE              = "daterange";
    public const string PARM_ENTRY_DATE_RANGE        = "entrydaterange";
    public const string PARM_LNAME                   = "lname";
    public const string PARM_FNAME                   = "fname";
    public const string PARM_NAME                    = "name";
    public const string PARM_ACTIVE                  = "active";
    public const string PARM_CONTENT_ONLY            = "content_only";
    public const string PARM_PREVIEW_ONLY            = "preview_only";
    public const string PARM_CLIENT_ID               = "clientid";
    public const string PARM_CLIENT_CONTACT_ID       = "clientcontactid";


    public const string PARM_TOPIC_ID                = "topicid";

    public const string PARM_PAGE_RESULT_SET         = "pageresultset";
    public const string PARM_PAGE_SIZE               = "pagesize";
    public const string PARM_PAGE_NUMBER             = "pagenumber";
    public const string PARM_PAGE_ORDER              = "pageorder";
    public const string PARM_PATIENT_ID              = "patid";
    public const string PARM_PATIENT_GOAL_ID         = "goalid";
    public const string PARM_PRACTITIONER_ID         = "pracid";
    public const string PARM_RMTS_MOMENT_ID          = "rmtsmomentid";
    public const string PARM_SEARCH_TERM             = "term";
    public const string PARM_DATA_SOURCE             = "datasource";
    public const string PARM_EDIT_DEL_MANAGE_LINK    = "editdelmanagelink";
    public const string PARM_SAVE_FORM               = "save";
    public const string PARM_VIEW_FORM               = "view";
    public const string PARM_MANAGE_FORM             = "manage";
    public const string PARM_RECS_VIEW               = "recs";
    public const string PARM_PAT_CLIENT_ID           = "patclientid";
    public const string PARM_PAT_PAT_ID              = "patpatientid";
    public const string PARM_PAT_GRP_SVC_CLS_NME_ID  = "patgrpsvcclsnmeid";
    public const string PARM_PAT_PRAC_ID             = "patpracid";
    public const string PARM_DOS                     = "dos";
    public const string PARM_DOB                     = "dob";
    public const string PARM_PLAN_TYPE               = "plantype";
    public const string PARM_ORP_DOC_TYPE            = "orpdoctype";
    public const string PARM_ORP_DOC_ID              = "orpDocID";
    public const string PARM_ORP_DOC_STD_SEL_NAME_ID  = "orpdocstdselnameid";
    public const string PARM_GRP_SVC_CLS_NME_ID       = "groupserviceclassnameid";
    public const string PARM_ORP_APPROVAL_STATE       = "orpapprovalstate";
    public const string PARM_SVC_TYPE_ID              = "svctypeid";
    public const string PARM_ROOM_ID                  = "rmid";
    public const string PARM_ROOM_PART_UID            = "rmprtuid";
    public const string PARM_ROOM_PART_PIN            = "rmprtpin";
    public const string PARM_ROOM_PART_ENTER_OR_EXIT  = "rmprtee";
    
    public const string PARM_ROOM_PART_RSVP_REQ_RSP      = "rmprtrsvpreqrsp";
    public const string PARM_ROOM_PART_RSVP_TOKEN        = "rmprtrsvptoken";
    public const string PARM_ROOM_PART_RSVP_WILL_ATTEND  = "rmprtrsvpwillattend";
    public const string PARM_ROOM_PART_RSVP_ALT_DATE     = "rmprtrsvpaltdate";
    public const string PARM_ROOM_PART_RSVP_NOTES        = "rmprtrsvpnotes";

    public const string PARM_JOURNAL_ID               = "journalid";
    public const string PARM_SVCREC_TO_CORRECT_ID     = "svcrectocorrectid";

    public const string PARM_GROUP_ID                 = "groupid";
    public const string PARM_GROUP_NAME                 = "groupName";

    public const string PARM_CURRENTLY_W_CLIENT                 = "currentlywclient";

    public const string PARM_REVIEWING_PRAC_ID           = "reviewingpracid";
    public const string PARM_RENDERING_PRAC_ID           = "renderingpracid";

    public const string PARM_APPROVING_PRACTITIONER_ID   = "approvingpracid";
    public const string PARM_INCLUDE_ALL_CLIENT_JOURNALS = "getallclientjournalsifpracallowed";
    
    public const string PARM_CASELOAD_GROUP_ID           = "caseloadgroupid";
    public const string PARM_IEP                         = "iep";
    public const string PARM_IS_IEP                      = "isiep";
    public const string PARM_NAME_ID                     = "nameid";
    public const string PARM_REF_DATE                    = "refdate";
    public const string PARM_REF_SCREEN                  = "refscreen";
    public const string PARM_PRAC_PAT_GROUP_ID           = "pracpatgroupid";
    public const string PARM_PLR_CLASS_CODE              = "plrclasscode";
    public const string PARM_DEFERRED                    = "deferred";
    public const string PARM_QUARTER                     = "quarter";

    public const string PARM_FISCAL_YEAR_ID              = "fiscalyearid";
    public const string PARM_FISCAL_QUARTER_ID           = "quarterid";
    public const string PARM_FY_QUARTER_ID               = "fyquarterid";

    public const string PARM_QUARTER_NUMBER              = "quarternumber";
    public const string PARM_LEC_OR_LGA_ID               = "lecorlgaid";
    public const string PARM_ROSTER_ID                   = "rosterid";
    public const string PARM_SPED_SERVICE_CODE           = "spedservicecode";
    public const string PARM_USE_MINS_PER_FREQ_ASSIGNED  = "useminsperfreqassigned";
    public const string PARM_INCLUDE_CONTENT             = "includecontent";
    public const string PARM_HAS_ALT_FORMAT              = "hasaltformat";
    public const string PARM_LEA_BOP_ONLY_OR_ALL_SPED    = "leaboponlyorallsped";
    public const string RMTS_DATA_IMPORT_ID              = "rmtsdataimportid";
    public const string PARM_RMTS_DATA_IMPORT_ID         = "rmtsdataimportid";
    public const string PARM_TASK_ID                     = "taskid";
    public const string PARM_IS_COMPLETE                 = "iscomplete";
    public const string PARM_COMPLETED                   = "completed";
    public const string PARM_IS_PENDING                  = "ispending";
    public const string PARM_IS_NOT_COMPLETED            = "isnotcompleted";
    public const string PARM_IS_COMPLETED                = "iscompleted";

    public const string PARM_SITE_ID                     = "siteid";
    public const string PARM_IS_CREATED_BY_CALLER        = "iscreatedbycaller";
    public const string PARM_IS_EXPIRING                 = "isexpiring";
    public const string PARM_IS_EXPIRED                  = "isexpired";
    public const string PARM_CURRENT_BENEFIT_STATUS_CODE = "currentbenefitstatuscode";
    public const string PARM_INVOICE_PAID                = "invoicepaid";


    public const string PARM_DISTRIBUTION_PAID           = "distbpaid";
    public const string PARM_MANAGE_INVOICE_INDEX        = "manageinvoiceindex";
                                 // NOTE: no idea what this parm was added for.
                                 // Consider removing (later) if possible.


    public const string PARM_REP_ID                      = "repid";
    public const string PARM_SVC_REC_ID                  = "svcrecid";
    public const string PARM_SELPA_CODE                  = "selpacode";
    public const string PARM_APPROVAL_STATUS             = "approvalstatus";
    public const string PARM_ASSIGNED                    = "assigned";
    public const string PARM_REVIEWED                    = "reviewed";
    public const string PARM_REFERENCED_ENTITY_ID        = "referencedentityid";
    public const string PARM_FILE_CLASS                  = "fileclass";      
    public const string PARM_FILE_NAMESPACE              = @"filenamespace";
    public const string PARM_FILE_SOURCE                 = @"filesource";
    public const string PARM_APPROVED                    = "approved";    
    public const string PARM_SVC_TRACKING_CLASS          = "svctrackingclass";
    public const string PARM_BATCH_STATUS_CODE           = "batch_status_code";
    public const string PARM_BATCH_ID                    = "batchid";
    public const string PARM_BATCH_FILE_REFERENCE        = "filereference";
    public const string PARM_ROUTE_ID                    = "routeid";
    public const string PARM_TRANS_MGMT_ID               = "transmgmtid";
    public const string PARM_TRANS_BUS_DRIVER_ID         = "transbusdriverid";
    public const string PARM_RPT_GROUP_ID                = "rptgroupid";
    public const string PARM_SPED_LANGUAGE_ID            = "spedlanguageid";
    public const string PARM_PERSON_ROLE_ID              = "personroleid";
    public const string PARM_MIDDLE_NAME                 = "middlename";
    public const string PARM_SPED_REFERRING_PARTY_CODE   = "spedreferringpartycode";
    public const string PARM_SPED_PLAN_TYPE_CODE         = "spedplantypecode";
    public const string PARM_SPED_DISABILITY_CODE        = "speddisabilitycode";
    public const string PARM_PPS_CDE_AUDIT_CUR_PAT_ID    = "ppscdeauditcurpatid";
    public const string PARM_PRAC_DATA_SOURCE            = "pracdatasource";
    public const string PARM_VIA_TELEHEALTH              = "viatelehealth";

    //Referral Params
    public const string PARM_REF_TO_PARENT               = "referraltoparent";
    public const string PARM_REF_TO_PRAC                 = "referraltoprac";
    public const string PARM_FILTER_IS_COMPLETED         = "filterascomplete"; /* TODO: Refactor this to use the existing completed parameter */
    public const string PARM_ENABLED                     = "enabled";        
    public const string PARM_REFERRING_BY_USER_ID        = "referringbyuserid";

    public const string PARM_PAT_ABSENT_MINS_ARE_SATISFIED_MINS = @"patabsentminsaresatisfiedmins";
    public const string PARM_SVC_NAMES_LIST_DATA_SOURCE_ID      = @"svcnameslistdatasourceid";
    public const string PARM_PRAC_PAT_CASELOAD_EXPECTED_SVC_ID  = @"practitionerpatientcaseloadexpectedserviceid";
    public const string PARM_SHOW_ONLY_COPY_DOWN_SELECTIONS     = @"showonlycopydownselections";

    public const string CTRL_DIAG_SAVE_NEW_OR_EDIT              = "diagsaveneworedit";
    public const string CTRL_DIAG_SAVE_NEW_OR_EDIT_INSTRUCTIONS = "diagsaveneworedit-instructions";

    public const string PARM_RMTS_ACTIVITY_CODE          = "activity_code";   
        
    public const string PARM_WIP_SP_REQUEST_RESOURCE  = @"requestresource";
    public const string PARM_WIP_SP_NAME              = @"savepointname";
    public const string PARM_WIP_SP_SAVED_DATA_JSON   = @"saveddatajson";    
    public const string PARM_SVC_REC_FOR_DOS_JSON     = @"svcrecForDOSJSON";
        
    public const string PARM_STUDENT_ID                             = @"studentid";
    public const string PARM_PRACTICE_OFFICE_VISIT_REASON_ID        = "practiceofficevisitreasonid";
    public const string PARM_PRACTICE_OFFICE_VISIT_REASON_NOTES     = "practiceofficevisitreasonnotes";
    public const string PARM_PRACTICE_OFFICE_VISIT_RESOLUTION_ID    = "practiceofficevisitresolutionid";       
    public const string PARM_PRACTICE_OFFICE_VISIT_RESOLUTION_NOTES = "practiceofficevisitresolutionnotes";
    public const string PARM_PRACTICE_OFFICE_VISIT_RESOLUTION_FBQJ  = "practiceofficevisitresolutionfbquestionsjson";
    public const string PARM_PRACTICE_OFFICE_VISIT_RESOLUTION_FBAJ  = "practiceofficevisitresolutionfbanswersjson";
    
    public const string PARM_CHECK_IN_DATE         = "checkindate";
    public const string PARM_CHECK_IN_TIME         = "checkintime";
    public const string PARM_VISIT_START_DATE      = "visitstartdate";
    public const string PARM_VISIT_START_TIME      = "visitstarttime";
    public const string PARM_VISIT_END_DATE        = "visitenddate";
    public const string PARM_VISIT_END_TIME        = "visitendtime";

    public const string PARM_PRACTICE_OFFICE_VISIT_SOURCE = "pracoffvissrc";


    public const string PARM_SVC_NOTES_FB_QUESTIONS     = @"svcNotesFormBuilderQuestionsJSON";
    public const string PARM_SVC_NOTES_FB_ANSWERS       = @"svcNotesFormBuilderAnswersJSON";
    public const string PARM_HAS_PAT_GOAL_TRACKING_DATA = @"hasPatientGoalTrackingData";
    public const string PARM_PAT_GOAL_PROGRESS          = @"patientGoalProgressJSON";
    public const string PARM_SVC_NAME                   = @"svcname";
    public const string PARM_NOTES                      = @"notes";
    public const string PARM_STORED_FILE_ID             = MBA.StoredFiles.PARAM_FILE_ID;
    public const string PARM_SVC_NAME_FORM_DATA_ID      = @"snfdid";
    public const string PARM_MSG_CHANNEL                = @"msgchannel";
    public const string PARM_WDW_NME                    = @"wdwnme";
    public const string PARM_START_TIME                 = @"starttime";
    public const string PARM_END_TIME                   = @"endtime";
    public const string PARM_NUM_MINS                   = @"nummins";
    public const string PARM_FORM_REQUEST_OR_RESPONSE   = @"frmreqorrsp";    
    public const string FRM_REQ                         = @"req";
    public const string FRM_RSP                         = @"rsp";
    public const string PARM_LANGUAGE                   = @"lang";
    public const string PARM_PERSON_CLASS_ID_1  = @"personclassid1";
    public const string PARM_PERSON_CLASS_ID_2  = @"personclassid2";
    public const string PARM_PAT_PER_ID         = @"patperid";

    public const string PARM_NOTE_NAMESPACE         = @"notenamespace";
    public const string PARM_NOTE_SOURCE            = @"notesource";

    public const string PARM_PCAL_COMPLIANCE_RATING_FOR_PAT = @"pcrfp";
    public const string PARM_SVC_OVER_DELIVERY              = @"svcovrdlv";

    public const string PARM_SVC_FRM_AGENDA                 = @"svcfromagenda";

    /* Missing data */
	
    public const string PARM_MISSING_INSURANCE_INFO      = "missinginsuranceinfo";
    public const string PARM_MISSING_ADDRESS_INFO        = "missingaddressinfo";
    public const string PARM_MISSING_FERPA_CONSENT       = "missingferpaconsent";
    public const string PARM_MISSING_CONSENT_TO_TREAT    = "missingconsenttotreat";
    public const string PARM_MISSING_PG_EMAILS           = "missingpgemails";
    public const string PARM_MISSING_PG_MCAL_CONSENT     = "missingpgmcalconsent";

    public const string PARM_HAS_CURR_INFO_REQUEST                       = "hascurrinforqst";
    public const string PARM_HAS_CURR_INFO_REQUEST_THAT_REQUIRES_REVIEW  = "hascurrinforqstreqrvw";                                                         
    public const string PARM_HAS_PREV_INFO_REQUEST_THAT_REQUIRED_REVIEW  = "hasprevinforqstthatreqrvw";
    public const string PARM_DISABLE_COMPLIANCE_CALC                     = "disablecompliancecalc";

    public const string PARM_REVIEW_REC_ID  = "reviewrecid";
    public const string PARM_REVIEW_REC_IDS = "reviewrecids";

    /* Consortium data */

    public const string PARM_CONSORTIUM_CLIENT_ID = "consortiumleadclientid";

    /* Generalized API params */

    public const string PARM_API_URL         = "apiurl";
    public const string PARM_API_TOKEN       = "apitoken";

    public const string CMD_LOGIN            = "login";
    public const string CMD_LOGOUT           = "logout";
    public const string CMD_RPT              = "rept";
    public const string CMD_ADD              = "add";
    public const string CMD_EDIT             = "edit";
    
    public const string REQUEST_METHOD_VIEW    = "view";
    public const string REQUEST_METHOD_SAVE    = "save";
    public const string REQUEST_METHOD_DELETE  = "delete";

    public const string AMD_UI_DBS           = "uidbs";
    public const string AMD_UI_DBS_SUB_PAGE  = "uidbssub";
    
    public const string SPED_LEA_BOP_ONLY    = "leaboponly";
    public const string SPED_ALL_SPED        = "allsped";
     
    public const string SPED_LEA_BOP_ONLY_LABEL = @"Medi-Cal Billable Services";
    public const string SPED_ALL_SPED_LABEL     = @"All Services";
    
    public const string DATA_ATTR_ANIMATE_CONTROL = "data-mba-animate-ctrl";
    public const int    DETAIL_LEVEL_SIMPLE   = 0;
    public const int    DETAIL_LEVEL_ADVANCED = 1;
    
    // Service Plan types

    public const int    PLAN_IFSP               = 1;
    public const int    PLAN_IEP                = 2;
    public const int    PLAN_NONE               = 3;
    public const int    PLAN_CYBHI              = 4;
    public const int    PLAN_RU_HEALTH          = 5;

    public const string OFFLINE_PUBLIC             = "offline.aspx";
    public const string HOME_PUBLIC                = "index.aspx";
    public const string HOME_PRIVATE               = "home.aspx";
    public const string PARENT_PORTAL_PRIVATE      = "parent_portal.aspx";
    public const string PATIENT_PORTAL_PRIVATE     = "patient_portal.aspx";
    public const string HELP_PRIVATE               = "help.aspx";
    public const string MAN_PAGES_PRIVATE          = "man_pages_private.aspx";
    public const string MAN_PAGES_PRIVATE_NEW      = "man_pages_private_new.aspx";    
    public const string UPLOAD_PRIVATE             = "user_all_stored_files_upload_files.aspx"; /* Was "fileuploadsprivate.ashx"; */
    public const string FILE_UPLOAD_SMARTSHEET     = @"https://app.smartsheet.com/b/form/7002754fb3124140894ab4c247796a3b";
    public const string REQUEST_FILE_UPLOAD_PUBLIC = FILE_UPLOAD_SMARTSHEET;
    public const string DOWNLOAD_PRIVATE_PCAL      = "user_all_stored_files_manage.aspx"; /* sbs_all_stored_files_view.aspx*/
    public const string DOWNLOAD_PRIVATE_CLIENT    = "user_all_stored_files_manage.aspx"; /* client_all_stored_files_view.aspx*/
    public const string CHANGE_MY_PASSWORD         = "change_my_password.aspx"; 
    
    public const string ACTIVATE_NEW_ACCOUNT       = "activate_new_account.aspx";
    public const string COMPLETE_PASSWORD_RESET    = "complete_reset_password.aspx";
    
    public const string FORGOT_MY_PASSWORD         = "forgot_my_password.aspx";
    public const string REQUEST_ACCOUNT            = "https://app.smartsheet.com/b/form?EQBCT=bdd8ef47d64e4b7bb97d421a15e85245";
    public const string ABOUT_US                   = "about_us.aspx";   /* TODO: Build page*/
    public static string APP_MARKETING_PUBLIC    { get {return getAppSetting(@"appMarketingPublic",REQUEST_ACCOUNT);}}

    /* Password change types (keep in synch with db constants) */

    public const int PWD_CHANGE_TYPE_USER      = 1;
    public const int PWD_CHANGE_TYPE_ADMIN     = 2;
    public const int PWD_CHANGE_TYPE_PUBLIC    = 3;

    /* Typical fiscal year start and end for most public organizations */
    
    public const int FY_START_MONTH_DEFAULT    = 7;
    public const int FY_START_DAY_DEFAULT      = 1;
    public const int FY_END_MONTH_DEFAULT      = 6;
    public const int FY_END_DAY_DEFAULT        = 30;
    
    /* Person sources (keep in synch with db constants */
 
    public const int PERSON_SOURCE_SPEDMON     = 1;
    public const int PERSON_SOURCE_USERS       = 2;

    /* Static user ids (keep in synch with db) */
    
    public const string USER_NAME_SYSTEM       = "Batch";
    public const int    USER_ID_SYSTEM         = 0;
    
    /* User groups (keep in synch with db) */

    public const int USER_GROUP_CLIENT             = 1;
    public const int USER_GROUP_SBSC               = 2;
    public const int USER_GROUP_THIRD_PARTY_PERSON = 3;
    public const int USER_GROUP_PCAL_HYQUEUE = 5;

   /* Added for Hyqueue */

    public const string ROLE_HYQUEUE_ADMIN = "hyqueue administrator";
    public const int ROLE_HYQUEUE_ADMIN_ROLE_ID = 15;
    public static readonly string[] ROLE_HYQUEUE_ALL = new string[] { ROLE_HYQUEUE_ADMIN };

    /* User roles ids : Keep in synch with db table users.RoleData */
    
    public const int ROLE_ADMIN_ID                  = 2;
    public const int ROLE_WORK_LEADER_ID            = 3;
    public const int ROLE_INPUT_STAFF_ID            = 4;    
    public const int ROLE_LEA_COORDINATOR_ID        = 5;
    public const int ROLE_LEA_FILE_MANAGER_ID       = 6;
    public const int ROLE_LEA_PROVIDER_ID           = 7;
    public const int ROLE_CLIENT_CONSULTANT_ID      = 9;    
    public const int ROLE_LEA_INPUT_STAFF_ID        = 10;
    public const int ROLE_ORP_PROFESSIONAL_ID       = 11; 
    public const int ROLE_PARENT_GUARDIAN_ID        = 12;
    public const int ROLE_PATIENT_ID                = 18;  /* was 99 and was commented as reserved */
    public const int ROLE_TRANSPORTATION_MANAGER_ID = 13;
    public const int ROLE_LEA_CRCS_STAFF_ID         = 15;
    public const int ROLE_SELPA_USER_ID             = 16;
    public const int ROLE_CYBHI_CORDINATOR_ID       = 17;
       
    public const int ROLE_TELECOM_PARTICIPANT_OTHER = 88; /* Reserved */

    /* User roles (keep in synch with db */

    public const string ROLE_ADMIN                  = "administrator";
    public const string ROLE_WORK_LEADER            = "work leader";
    public const string ROLE_CLIENT_CONSULTANT      = "client consultant";
    public const string ROLE_INPUT_STAFF            = "input staff";
    
    public const string ROLE_LEA_CORDINATOR         = "lea coordinator";
    public const string ROLE_CYBHI_CORDINATOR       = "cybhi coordinator";
    public const string ROLE_LEA_INPUT_STAFF        = "lea input staff";
    public const string ROLE_LEA_FILE_MANAGER       = "file manager";
    public const string ROLE_LEA_CRCS_STAFF         = "crcs staff";

    public const string ROLE_TRANSPORTATION_MANAGER = "transportation manager";
    public const string ROLE_LEA_PROVIDER           = "provider";

    public const string ROLE_ORP_PROFFESIONAL       = "orp professional";
    public const string ROLE_PARENT_GUARDIAN        = "parent or guardian";
    public const string ROLE_SELPA_USER             = "selpa user";      
    public const string ROLE_PATIENT                = "patient";
    public const string ROLE_DEACTIVATED            = "deactivated";
    
    public static readonly string[] ROLE_CLIENT_ALL    = new string[] { ROLE_LEA_CORDINATOR,
                                                                        ROLE_CYBHI_CORDINATOR,
                                                                        ROLE_LEA_INPUT_STAFF,
                                                                        ROLE_LEA_FILE_MANAGER,
                                                                        ROLE_LEA_CRCS_STAFF,
                                                                        ROLE_TRANSPORTATION_MANAGER,
                                                                        ROLE_LEA_PROVIDER };

    public static readonly string[] ROLE_CLIENT_BO     = new string[] { ROLE_LEA_CORDINATOR,
                                                                        ROLE_CYBHI_CORDINATOR,
                                                                        ROLE_TRANSPORTATION_MANAGER,
                                                                        ROLE_LEA_INPUT_STAFF };
    
    public static readonly string[] ROLE_CLIENT_BO_OR_PRAC = new string[] { ROLE_LEA_CORDINATOR,
                                                                            ROLE_CYBHI_CORDINATOR,
                                                                            ROLE_LEA_INPUT_STAFF,                                                                       
                                                                             ROLE_TRANSPORTATION_MANAGER,
                                                                             ROLE_LEA_PROVIDER };

                                                                        
    public static readonly string[] ROLE_SBS_STAFF     = new string[] { ROLE_ADMIN, 
                                                                        ROLE_WORK_LEADER,
                                                                        ROLE_INPUT_STAFF };
                                                                      
    public static readonly string[] ROLE_SBS_ALL       = new string[] { ROLE_ADMIN, 
                                                                        ROLE_WORK_LEADER,
                                                                        ROLE_CLIENT_CONSULTANT,
                                                                        ROLE_INPUT_STAFF };                                                                              

    public static readonly string[] ROLE_SBS_MGMT      = new string[] { ROLE_ADMIN, 
                                                                        ROLE_WORK_LEADER };

    public static readonly string[] ROLE_SBS_MGMT_ANI  = new string[] { ROLE_ADMIN, 
                                                                        ROLE_WORK_LEADER,
                                                                        ROLE_CLIENT_CONSULTANT };
                                                                      
    public static readonly string[] ROLE_SBS_ADMIN     = new string[] { ROLE_ADMIN };

                                                                       
    public static readonly string[] ROLE_SVC_SUP_PRAC  = new string[] { ROLE_LEA_CORDINATOR,
                                                                        ROLE_CYBHI_CORDINATOR,
                                                                        ROLE_LEA_INPUT_STAFF,
                                                                        ROLE_TRANSPORTATION_MANAGER,
                                                                        ROLE_LEA_PROVIDER,                                                                       
                                                                        ROLE_ADMIN, 
                                                                        ROLE_WORK_LEADER,
                                                                        ROLE_CLIENT_CONSULTANT,
                                                                        ROLE_INPUT_STAFF,
                                                                        ROLE_PARENT_GUARDIAN,
                                                                        ROLE_PATIENT
                                                                       };

    public static readonly string[] ROLE_INTERNAL_REVIEW_SVC_RECS = new string[] { 
                                                                          ROLE_LEA_PROVIDER
                                                                        , ROLE_ADMIN                                                                         
                                                                        , ROLE_CLIENT_CONSULTANT
                                                                        , ROLE_WORK_LEADER
                                                                        };

    public static readonly string[] ROLE_CYBHI_ORP_REVIEW_SVC_RECS = new string[] { 
                                                                          ROLE_LEA_PROVIDER
                                                                        , ROLE_ADMIN                                                                         
                                                                        , ROLE_CLIENT_CONSULTANT                                                                        
                                                                        , ROLE_WORK_LEADER
                                                                       };

    public static readonly string[] ROLE_APPROVE_SVC_RECS  = new string[] { ROLE_LEA_CORDINATOR,                                                                      
                                                                        ROLE_LEA_INPUT_STAFF,
                                                                        ROLE_LEA_PROVIDER,                                                                       
                                                                        ROLE_ADMIN, 
                                                                        ROLE_WORK_LEADER,
                                                                        ROLE_CLIENT_CONSULTANT,
                                                                        ROLE_INPUT_STAFF
                                                                       };

    public static readonly string[] ROLE_SVC_PRAC      = new string[] { ROLE_LEA_CORDINATOR,                                                                        
                                                                        ROLE_LEA_INPUT_STAFF,
                                                                        ROLE_TRANSPORTATION_MANAGER,
                                                                        ROLE_ADMIN, 
                                                                        ROLE_WORK_LEADER,
                                                                        ROLE_CLIENT_CONSULTANT,
                                                                        ROLE_INPUT_STAFF
                                                                       };

    public static readonly string[] ROLE_ALL_PCAL_AND_CLIENT = new string[] { ROLE_LEA_CORDINATOR,
                                                                              ROLE_CYBHI_CORDINATOR,
                                                                              ROLE_LEA_INPUT_STAFF,
                                                                              ROLE_LEA_FILE_MANAGER,
                                                                              ROLE_LEA_CRCS_STAFF,
                                                                              ROLE_TRANSPORTATION_MANAGER,
                                                                              ROLE_LEA_PROVIDER,
                                                                              ROLE_ADMIN, 
                                                                              ROLE_WORK_LEADER,
                                                                              ROLE_CLIENT_CONSULTANT,
                                                                              ROLE_INPUT_STAFF,
                                                                              ROLE_PARENT_GUARDIAN,
                                                                              ROLE_PATIENT
                                                                       };
        
    public static readonly string[] ROLE_ALL_PCAL_CLIENT_SELPA = new string[] { ROLE_LEA_CORDINATOR,
                                                                              ROLE_CYBHI_CORDINATOR,
                                                                              ROLE_LEA_INPUT_STAFF,
                                                                              ROLE_LEA_FILE_MANAGER,
                                                                              ROLE_LEA_CRCS_STAFF,
                                                                              ROLE_TRANSPORTATION_MANAGER,
                                                                              ROLE_LEA_PROVIDER,
                                                                              ROLE_ADMIN, 
                                                                              ROLE_WORK_LEADER,
                                                                              ROLE_CLIENT_CONSULTANT,
                                                                              ROLE_INPUT_STAFF,
                                                                              ROLE_SELPA_USER
                                                                       };
       
   public static readonly string[] ROLE_ALL_PCAL_CLIENT_ALL_THIRD_PARTY_ORP_PG = new string[] { 
                                                                                 ROLE_LEA_CORDINATOR
                                                                                ,ROLE_CYBHI_CORDINATOR
                                                                                ,ROLE_LEA_INPUT_STAFF
                                                                                ,ROLE_LEA_FILE_MANAGER
                                                                                ,ROLE_LEA_CRCS_STAFF
                                                                                ,ROLE_TRANSPORTATION_MANAGER
                                                                                ,ROLE_LEA_PROVIDER
                                                                                ,ROLE_ADMIN 
                                                                                ,ROLE_WORK_LEADER
                                                                                ,ROLE_CLIENT_CONSULTANT
                                                                                ,ROLE_INPUT_STAFF
                                                                                ,ROLE_ORP_PROFFESIONAL
                                                                                ,ROLE_PARENT_GUARDIAN };
    
    public static readonly string[] ROLE_SVC_AUTH_RESPONDERS   = new string[] {  ROLE_ADMIN
                                                                              , ROLE_CLIENT_CONSULTANT
                                                                              , ROLE_LEA_PROVIDER
                                                                              , ROLE_LEA_CORDINATOR
                                                                              , ROLE_LEA_INPUT_STAFF
                                                                              , ROLE_PARENT_GUARDIAN
                                                                              , ROLE_ORP_PROFFESIONAL};  
        
    public static readonly string[] ROLE_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC = new string[] {  ROLE_ADMIN
                                                                              , ROLE_CLIENT_CONSULTANT                                                                              
                                                                              , ROLE_WORK_LEADER
                                                                              , ROLE_INPUT_STAFF
                                                                              , ROLE_LEA_INPUT_STAFF
                                                                              , ROLE_LEA_CORDINATOR                                                                              
                                                                              , ROLE_LEA_PROVIDER
                                                                              , ROLE_CYBHI_CORDINATOR };

    /* NOTE: Only use ROLE_ALL for pages that are common to ANY role */

    public static readonly string[] ROLE_ALL = new string[] { ROLE_LEA_CORDINATOR,
                                                             ROLE_LEA_INPUT_STAFF,
                                                             ROLE_LEA_FILE_MANAGER,
                                                             ROLE_LEA_CRCS_STAFF,
                                                             ROLE_TRANSPORTATION_MANAGER,
                                                             ROLE_LEA_PROVIDER,
                                                             ROLE_ADMIN, 
                                                             ROLE_WORK_LEADER,
                                                             ROLE_CLIENT_CONSULTANT,
                                                             ROLE_INPUT_STAFF,
                                                             ROLE_ORP_PROFFESIONAL,
                                                             ROLE_PARENT_GUARDIAN,
                                                             ROLE_SELPA_USER,
                                                             ROLE_CYBHI_CORDINATOR,
                                                             ROLE_PATIENT
                                                            };
    
    public static readonly string[] ROLE_ANNOUNCEMENT_ADMIN = new string[] {  ROLE_ADMIN
                                                                           , ROLE_CLIENT_CONSULTANT
                                                                           , ROLE_WORK_LEADER };

    public static readonly string[] ROLE_CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_ADMIN = new string[] {  ROLE_ADMIN
                                                                           , ROLE_CLIENT_CONSULTANT
                                                                           , ROLE_WORK_LEADER };

    public static readonly string[] ROLE_ADMIN_CONSULANT_ONLY = new string[] {
                                                                           ROLE_ADMIN
                                                                         , ROLE_CLIENT_CONSULTANT };

    public static readonly string[] ROLE_ADMIN_WORKLEADER_ONLY = new string[] {
                                                                           ROLE_ADMIN
                                                                         , ROLE_WORK_LEADER};

    public static readonly string[] ROLE_ADMIN_CONSULTANT_LEA_COORD = new string[] {
                                                                               ROLE_ADMIN
                                                                             , ROLE_CLIENT_CONSULTANT
                                                                             , ROLE_LEA_CORDINATOR };

    public static readonly string[] ROLE_ADMIN_CONSULTANT_LEA_COORD_CYBHI_COORD = new string[] {
                                                                                     ROLE_ADMIN
                                                                                   , ROLE_CLIENT_CONSULTANT
                                                                                   , ROLE_LEA_CORDINATOR
                                                                                   , ROLE_CYBHI_CORDINATOR };

    public static readonly string[] ROLE_SBS_ALL_LEA_COORD = new string[] {   ROLE_ADMIN
                                                                            , ROLE_WORK_LEADER
                                                                            , ROLE_CLIENT_CONSULTANT
                                                                            , ROLE_INPUT_STAFF 
                                                                            , ROLE_LEA_CORDINATOR };
     
    public static readonly string[] ROLE_SBS_ALL_LEA_COORD_CYBHI_COORD = new string[] {   ROLE_ADMIN
                                                                            , ROLE_WORK_LEADER
                                                                            , ROLE_CLIENT_CONSULTANT
                                                                            , ROLE_INPUT_STAFF 
                                                                            , ROLE_LEA_CORDINATOR
                                                                            , ROLE_CYBHI_CORDINATOR};

    public static readonly string[] ROLE_SBS_ALL_LEA_COORD_AND_ASSIST = new string[] {   ROLE_ADMIN
                                                                            , ROLE_WORK_LEADER
                                                                            , ROLE_CLIENT_CONSULTANT
                                                                            , ROLE_INPUT_STAFF 
                                                                            , ROLE_LEA_CORDINATOR
                                                                            , ROLE_LEA_INPUT_STAFF};
 
   public static readonly string[] ROLE_LEA_COORD_AND_ASSIST = new string[] {
                                                                               ROLE_LEA_CORDINATOR
                                                                             , ROLE_LEA_INPUT_STAFF
                                                                             };

    public static readonly string[] ROLE_ADMIN_CONSULTANT_LEA_BO_PRAC = new string[] {
                                                                               ROLE_ADMIN
                                                                             , ROLE_CLIENT_CONSULTANT
                                                                             , ROLE_LEA_CORDINATOR
                                                                             , ROLE_LEA_INPUT_STAFF
                                                                             , ROLE_LEA_PROVIDER
                                                                             , ROLE_PARENT_GUARDIAN};

    public static readonly string[] ROLE_RMTS_ADMINS = new string[] {  ROLE_ADMIN
                                                                     , ROLE_CLIENT_CONSULTANT                                                                     
                                                                     , ROLE_LEA_CORDINATOR
                                                                     , ROLE_WORK_LEADER };

    public static readonly string[] ROLE_RMTS_ADMINS_AND_PRACS = new string[] {  ROLE_ADMIN
                                                                     , ROLE_CLIENT_CONSULTANT                                                                     
                                                                     , ROLE_LEA_CORDINATOR
                                                                     , ROLE_WORK_LEADER
                                                                     , ROLE_LEA_PROVIDER };
   
    public static readonly string[] ROLE_PRAC_DIR_SUP_ADMINS = new string[] {  ROLE_ADMIN
                                                                             , ROLE_CLIENT_CONSULTANT                                                                     
                                                                             , ROLE_WORK_LEADER
                                                                             , ROLE_INPUT_STAFF
                                                                             , ROLE_LEA_CORDINATOR
                                                                             , ROLE_CYBHI_CORDINATOR
                                                                             , ROLE_LEA_INPUT_STAFF
                                                                             , ROLE_LEA_PROVIDER };
   

    
  public static readonly string[] ROLE_SVC_REC_VISION_HEARING_MASS_SCREEN  = new string[] {  ROLE_LEA_CORDINATOR
                                                                                           , ROLE_LEA_INPUT_STAFF
                                                                                           , ROLE_LEA_PROVIDER
                                                                                           , ROLE_ADMIN 
                                                                                           , ROLE_WORK_LEADER                                                                        
                                                                                           , ROLE_INPUT_STAFF };                                                                             
   
    
  public static readonly string[] ROLE_SVC_REC_CASELOAD_FOR_DOS  = new string[] {  ROLE_LEA_CORDINATOR
                                                                                 , ROLE_CYBHI_CORDINATOR
                                                                                 , ROLE_LEA_INPUT_STAFF
                                                                                 , ROLE_LEA_PROVIDER };
        
   public static readonly string[] ROLE_CARE_PLAN_WRITER  = new string[] {  ROLE_ADMIN, 
                                                                            ROLE_WORK_LEADER,
                                                                            ROLE_CLIENT_CONSULTANT,
                                                                            ROLE_INPUT_STAFF,
                                                                            ROLE_LEA_PROVIDER,
                                                                            ROLE_LEA_CORDINATOR };

    public static readonly string[] ROLE_SVC_JOURNALS  = new string[] {     ROLE_ADMIN
                                                                          , ROLE_WORK_LEADER
                                                                          , ROLE_CLIENT_CONSULTANT
                                                                          , ROLE_INPUT_STAFF
                                                                          , ROLE_LEA_CORDINATOR
                                                                          , ROLE_LEA_INPUT_STAFF
                                                                          , ROLE_LEA_PROVIDER 
                                                                          , ROLE_PARENT_GUARDIAN };

    public static readonly string[] ROLE_ACTION_ITEM_PLR_ALL = new string[] {  ROLE_LEA_CORDINATOR
                                                                             , ROLE_LEA_INPUT_STAFF                                                                                                                                          
                                                                             , ROLE_LEA_PROVIDER
                                                                             , ROLE_ADMIN
                                                                             , ROLE_WORK_LEADER
                                                                             , ROLE_CLIENT_CONSULTANT
                                                                             , ROLE_INPUT_STAFF                                                            
                                                                            };

    public static readonly string[] ROLE_CRCS_ADMIN = new string[] {
                                                                      ROLE_ADMIN
                                                                    , ROLE_CLIENT_CONSULTANT
                                                                    , ROLE_WORK_LEADER
                                                                    , ROLE_LEA_CORDINATOR
                                                                    , ROLE_LEA_CRCS_STAFF
                                                                };

    public static readonly string[] ROLE_MISSING_SERVICES_MANAGE = new string[] {
                                                                      ROLE_ADMIN
                                                                    , ROLE_CLIENT_CONSULTANT
                                                                    , ROLE_WORK_LEADER
                                                                    , ROLE_INPUT_STAFF
                                                                    , ROLE_LEA_CORDINATOR
                                                                    , ROLE_LEA_INPUT_STAFF
                                                                    , ROLE_LEA_PROVIDER
                                                                    , ROLE_SELPA_USER
                                                                };

    public static readonly string[] ROLE_LEA_BOP_HEALTH_MANAGE = new string[] {
                                                                      ROLE_ADMIN
                                                                    , ROLE_CLIENT_CONSULTANT
                                                                    , ROLE_WORK_LEADER
                                                                    , ROLE_INPUT_STAFF
                                                                    , ROLE_LEA_CORDINATOR                                                                                                                           
                                                                };

    public static readonly string[] ROLE_CDE_COMPLIANCE_MANAGE = new string[] {
                                                                      ROLE_ADMIN
                                                                    , ROLE_CLIENT_CONSULTANT
                                                                    , ROLE_WORK_LEADER
                                                                    , ROLE_INPUT_STAFF
                                                                    , ROLE_LEA_CORDINATOR
                                                                    , ROLE_SELPA_USER
                                                                };

    public static readonly string[] ROLE_CDE_COMPLIANCE_MANAGE_LOCAL = new string[] {
                                                                      ROLE_ADMIN
                                                                    , ROLE_CLIENT_CONSULTANT
                                                                    , ROLE_WORK_LEADER
                                                                    , ROLE_INPUT_STAFF
                                                                    , ROLE_LEA_CORDINATOR                                                                    
                                                                };

     public static readonly string[] ROLE_CDE_COMPLIANCE_MANAGE_FOR_SELPA = new string[] {
                                                                      ROLE_ADMIN
                                                                    , ROLE_CLIENT_CONSULTANT
                                                                    , ROLE_WORK_LEADER
                                                                    , ROLE_INPUT_STAFF
                                                                    , ROLE_SELPA_USER
                                                                };

    public static readonly string[] ROLE_BULK_PATIENT_IMPORT = new string[] {
                                                                      ROLE_ADMIN
                                                                    , ROLE_CLIENT_CONSULTANT
                                                                    , ROLE_WORK_LEADER
                                                                    , ROLE_INPUT_STAFF
                                                                };

    public static readonly string[] ROLE_SVC_REC_IMPORT = new string[] {
                                                                      ROLE_ADMIN
                                                                    , ROLE_CLIENT_CONSULTANT
                                                                    , ROLE_WORK_LEADER
                                                                    , ROLE_INPUT_STAFF
                                                                };

    public static readonly string[] ROLE_SCHOOL_SESSIONS_ACADEMIC_YEARS_MANAGE = new string[] {
                                                                                       ROLE_ADMIN
                                                                                     , ROLE_CLIENT_CONSULTANT
                                                                                     , ROLE_WORK_LEADER
                                                                                     , ROLE_INPUT_STAFF
                                                                                     , ROLE_LEA_CORDINATOR
                                                                                     , ROLE_CYBHI_CORDINATOR
                                                                                     , ROLE_LEA_INPUT_STAFF
                                                                                     , ROLE_LEA_PROVIDER
                                                                                };

    public static readonly string[] ROLE_PATIENT_GOALS = new string[] { ROLE_LEA_CORDINATOR,
                                                                        ROLE_CYBHI_CORDINATOR,
                                                                        ROLE_LEA_INPUT_STAFF,
                                                                        ROLE_LEA_PROVIDER,
                                                                        ROLE_ADMIN, 
                                                                        ROLE_WORK_LEADER,
                                                                        ROLE_CLIENT_CONSULTANT,
                                                                        ROLE_INPUT_STAFF,
                                                                        ROLE_PARENT_GUARDIAN
                                                                       };
    /* Note: Keep the ROLE_MANAGE_INVOICES and ROLE_MANAGE_PARTNER_SHARES in synch with ClientInvoices.userCanSeePartnerData(uInfo) */

    public static readonly string[] ROLE_MANAGE_INVOICES       = new string[] { ROLE_ADMIN, ROLE_CLIENT_CONSULTANT, ROLE_LEA_CORDINATOR };    
    public static readonly string[] ROLE_MANAGE_PARTNER_SHARES = new string[] { ROLE_ADMIN };

    public static readonly string[] ROLE_MANAGE_PATIENT_INFO_REQUEST_OPTIONS = new string[] {
                                                                                     ROLE_ADMIN
                                                                                   , ROLE_CLIENT_CONSULTANT
                                                                                   , ROLE_LEA_CORDINATOR
                                                                                   , ROLE_CYBHI_CORDINATOR };

        /* Ranks (keep in synch with db) */

        public const int    RANK_ADMIN              = 3009;
    
    // Credentials provided

    public const int    CREDENTIAL_NONE         = 0;
    public const int    CREDENTIAL_UID_PWD      = 1;
    public const int    CREDENTIAL_TOKEN        = 2;
    public const int    CREDENTIAL_LOGOUT       = 3;
        
    // Early Exit Reasons

    public const int EARLY_EXIT_LOGIN                    = 1;
    public const int EARLY_EXIT_LOGOUT                   = 2;
    public const int EARLY_EXIT_CHANGE_PASSWORD          = 3;
    
    // Validate options
    
    public const int    VAL_OPT_DATE_NONE       = 0;
    public const int    VAL_OPT_DATE_NO_FUTURE  = 1;

    // Conversion options
    
    public const int    CONV_OPT_DATE_NONE      = 0;
    public const int    CONV_OPT_DATE_START     = 1;
    public const int    CONV_OPT_DATE_END       = 2;

    // Data parameter types
    
    public const string DATA_PARM_TYPE_DOM    = "DOM";        // One or more ids of input fields in the dom
    public const string DATA_PARM_TYPE_NVP    = "NVP";        // Name value pair string
    public const string DATA_PARM_TYPE_JSON   = "JSON";       // JSON string

    // Save Types

    public const int    SAVE_TYPE_NEW                 = 1;
    public const int    SAVE_TYPE_EDIT                = 2;
    public const int    SAVE_TYPE_DELETE              = 3;
    public const int    SAVE_TYPE_COPY                = 4;
    public const int    SAVE_TYPE_DEACTIVATE          = 5;
    public const int    SAVE_TYPE_REACTIVATE          = 6;
    public const int    SAVE_TYPE_ACCEPT              = 7;
    public const int    SAVE_TYPE_REJECT              = 8;   
    public const int    SAVE_TYPE_CLOSE               = 9;
    
    public const int    SAVE_TYPE_CLOSE_AND_SAVE_NEW  = 91;
    public const int    SAVE_TYPE_DELETE_AND_SAVE_NEW = 31;

    public enum SAVE_TYPE {
      
        NEW                    = SAVE_TYPE_NEW
      , EDIT                   = SAVE_TYPE_EDIT
      , DELETE                 = SAVE_TYPE_DELETE
      , COPY                   = SAVE_TYPE_COPY
      , DEACTIVATE             = SAVE_TYPE_DEACTIVATE
      , REACTIVATE             = SAVE_TYPE_REACTIVATE
      , ACCEPT                 = SAVE_TYPE_ACCEPT
      , REJECT                 = SAVE_TYPE_REJECT
      , CLOSE                  = SAVE_TYPE_CLOSE
      , CLOSE_AND_SAVE_NEW     = SAVE_TYPE_CLOSE_AND_SAVE_NEW
      , DELETE_AND_SAVE_NEW    = SAVE_TYPE_DELETE_AND_SAVE_NEW
    }
    
    // Report format

    public const int    REPT_FORMAT_PREVIEW     = 1;
    public const int    REPT_FORMAT_HTML        = 2;
    public const int    REPT_FORMAT_XLS         = 3;
    public const int    REPT_FORMAT_PDF         = 4;
    public const int    REPT_FORMAT_JSON        = 5;
    public const int    REPT_FORMAT_CSV         = 9;
    public const int    REPT_FORMAT_PSV         = 10;
    public const int    REPT_FORMAT_FIXED       = 11;
    
    public const int    REPT_FORMAT_HTML_REPORT = 6;
    public const int    REPT_FORMAT_XLS_REPORT  = 7;
    public const int    REPT_FORMAT_PDF_REPORT  = 8;
        
    public const int    REPT_DELIVER_FULL_SCREEN  = 0;
    public const int    REPT_DELIVER_WINDOW       = 1;
    public const int    REPT_DELIVER_FILE         = 2;
    public const int    REPT_DELIVER_DYNAMIC_FILE = 3;

    public const int    RPT_ROW_TYPE_DETAIL     = 1;
    public const int    RPT_ROW_TYPE_AGR        = 2;
    public const string RPT_COL_NAME_ROW_TYPE   = "RPT_ROW_TYPE";
    public const string RPT_COL_NAME_GROUP_ID   = "RPT_GROUP_ID";
    
    // Record view type

    public const int    REC_VIEW_RAW                   = 1;
    public const int    REC_VIEW_DATA_TABLE            = 2;
    public const int    REC_VIEW_SEL                   = 3;
    public const int    REC_VIEW_ENTITY                = 4;
    public const int    REC_VIEW_DATA_TABLE_PVW_OR_SEL = 5;
    
    // Step types

    public const int    STEP_TYPE_DATA          = 0;
    public const int    STEP_TYPE_SUBMIT        = 1;
    public const int    STEP_TYPE_REPORT        = 2;
    public const int    STEP_TYPE_SELECT        = 3;

    // Images

    public static readonly string IMG_LINK_BASE    = MBA.HttpApplication.createLink("images/");
    public static readonly string IMG_STATUS_BASE  = MBA.HttpApplication.createLink("images/msg/");

    // Logo
    
    public static readonly string IMG_LOGO         = IMG_LINK_BASE + "logo-pcal-sbs.png";

    // Status and detail list images

    public static readonly string IMG_GOOD     = IMG_STATUS_BASE + "good.png";
    public static readonly string IMG_INFO     = IMG_STATUS_BASE + "info.png";
    public static readonly string IMG_ALERT    = IMG_STATUS_BASE + "alert.png";
    public static readonly string IMG_ERROR    = IMG_STATUS_BASE + "error.png";
    public static readonly string IMG_WAIT     = IMG_STATUS_BASE + "roller.gif";
    public static readonly string IMG_CALENDAR = IMG_LINK_BASE   + "calendar.jpg";

    public static readonly string IMG_GOOD_16  = IMG_STATUS_BASE + "good_16.png";
    public static readonly string IMG_INFO_16  = IMG_STATUS_BASE + "info_16.png";
    public static readonly string IMG_ALERT_16 = IMG_STATUS_BASE + "alert_16.png";
    public static readonly string IMG_ERROR_16 = IMG_STATUS_BASE + "error_16.png";

    // Status and detail list CSS

    public const string CSS_STAT_CRIT   = "status_crit";
    public const string CSS_STAT_WARN   = "status_warn";
    public const string CSS_STAT_INFO   = "status_info";
    public const string CSS_STAT_GOOD   = "status_good";
    public const string CSS_STAT_NONE   = "status_none";
    public const string CSS_STAT_WAIT   = "status_wait";

    //public const string PREFIX_CSS_CLASSNAME_EMAIL_60PCT = "cssclass-60pct-mba-email-";
    public const string PREFIX_CSS_CLASSNAME_EMAIL_60PCT = "mba-email-";

    public const string DOT_PREFIX_CSS_CLASSNAME_EMAIL_60PCT = "." + PREFIX_CSS_CLASSNAME_EMAIL_60PCT;
    
    public const string CSS_DETAIL      = "detail";
    public const string CSS_DETAIL_CRIT = "detail_crit";
    public const string CSS_DETAIL_WARN = "detail_warn";
    public const string CSS_DETAIL_INFO = "detail_info";
    public const string CSS_DETAIL_GOOD = "detail_good";

    // Qfrom project
    public const string PARM_QFTOKEN          = "qftkn";
    public const string PARM_QFORMMODE        = "qformmode";
    public const string QFORM_STATE_NEW       = "1";
    public const string QFORM_STATE_SENT      = "10";
    public const string QFORM_STATE_OPENED    = "20";
    public const string QFORM_STATE_RESPONDED = "30";
    public const string QFORM_STATE_ANSWERED  = "40";
    public const string QFORM_STATE_DELETED   = "99";
    
    
   public enum EntityQualificationType
   {
       LICENSE        = 1
     , CREDENTIAL     = 2
     , REGISTRATION   = 3
     , APPROVAL       = 4
   }

   public static readonly string[] TRUSTED_LOCAL_IPS = new string[] {"::1","127.0.0.1"};
   
   public const string PARM_REQUESTED_METHOD  = "requestedmethod";
   public const string PARM_DT_VIEW_MODE      = "dtviewmode";
   public const string PARM_DT_DRAW           = "draw";
   public const string PARM_DT_START          = "start";

   public const long TELECOMM_PURPOSE_GENERAL_MEETING = 1;
   public const long TELECOMM_PURPOSE_TELEHEALH       = 2;
   public const long TELECOMM_PURPOSE_IEP             = 3;
  
   public const long TELECOM_PARTICIPANT_AUTH_METHOD_EMAIL_PIN = 1;
   public const long TELECOM_PARTICIPANT_AUTH_METHOD_APP_LOGIN = 2;
  
   /* Gender/sex - X12 Standard Values for 837/835 */
   
   public const string GENDER_MALE    = @"M";
   public const string GENDER_FEMALE  = @"F";
   public const string GENDER_UNKNOWN = @"U";

   /* Language codes - */

   public const string LANG_ENGLISH = @"en";
   public const string LANG_SPANISH = @"es";

   }
}
