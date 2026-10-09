using MBA;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;

namespace Spedmon
{
    /***************************************************************************
     * PractitionerPatientCaseloadExpectedServicesStats */
    /**
     *
 	 ***************************************************************************/

    public class PractitionerPatientCaseloadExpectedServicesStats
    {
        public int numOfExpiredSchedules;
        public int numOfPlanUpdates;
        public int numOfPossibleNewPlans;
    }

    /***************************************************************************
     * PractitionerPatientCaseloadExpectedService */
    /**
     *
 	 ***************************************************************************/

    public class PractitionerPatientCaseloadExpectedService : Entity
    {
        public const string DEFAULT_PAGING_ORDER = @"patName asc, startDate desc";

        public long     caseloadEntryID;

        public long     clientID;
        public string   clientName;
	    public long     pracID;
	    public string   pracName;
        public string   pracLastName;
        public string   pracFirstName;
        public long     groupID;
        public string   groupName;
        public long     groupSvcClassNameID;
        public string   groupSvcClassName;   
        public long     patID;
        public string   patName;
        public string   patLastName;
        public string   patFirstName;
        public DateTime dob;
        public string   dobStr;
        public long     siteID;
        public string   siteName;
        public string   patSSID;

        public int      planType;
        public string   planTypeStr;
        public string   planTypeName;
        
        //public int      minsInd;              /* Used to prepopulate service record entry fields */
	    //public string   minsIndStr;           /* Used to prepopulate service record entry fields */        
        //public int      minsGrp;              /* Used to prepopulate service record entry fields */
	    //public string   minsGrpStr;           /* Used to prepopulate service record entry fields */
        //public string   weekdaysjson;         /* Used to prepopulate service record entry fields */
        
        public int      svcTrackingClass;     /* Used to identify what is being tracked.  100 = spEdSvcCode, 200 = orpDocID, 300 = 'User Provided' */
        public string   svcTrackingClassName;

        public string   svcTrackingName;      /* Displays promised service name, order name, or 'Any Treatment' depending on svcTrackingClass*/

        public int      spEdServiceCode;
        public string   spEdServiceName;

        public long     orpDocID;
        public string   orpDocName;

        public int      svcNamesListDataSourceID;        
	    public string   svcNamesListDataSourceName;
	    public bool     viaTeleHealth;	   
        public bool     includeAltModalityInTracking;
	    public long     nameID; 
	    public long     altModalityNameID;
        public string   svcName;
        
        public string   startDateStr;       /* Read only to user for all cases expect when svcTrackingClass = 300 */
        public string   startDateStrYMD;    /* Read only to user for all cases expect when svcTrackingClass = 300 */

        public string   endDateStr;         /* Read only to user for all cases expect when svcTrackingClass = 300 */
        public string   endDateStrYMD;      /* Read only to user for all cases expect when svcTrackingClass = 300 */

        public DateTime endDateOrCurrent;
        public string   endDateOrCurrentStr;
        public string   endDateOrCurrentYMD;

        public int      spEdFreqCode;       /* Read only to user for all cases expect when svcTrackingClass = 300 */
        public string   spEdFreqName;       /* Read only to user for all cases expect when svcTrackingClass = 300 */
        public int      minsPerFreq;        /* Read only to user for all cases expect when svcTrackingClass = 300 */

        public int      numMinsExpected;          /* Calculation output field */
	    public int      numMinsApplicable;        /* Calculation output field */
	    public int      numMinsDiff;              /* Calculation output field */
        
        public int      numMinsPlans;             /* Calculation output field */
        public int      numMinsBreaks;            /* Calculation output field */
        public int      numPlans;                 /* Calculation output field */
        public string   tmtDoseSummary;           /* Calculation output field */
                        
        public Double   pctExpectedApplicable;    /* Calculation output field */
	    public string   pctExpectedApplicableStr; /* Calculation output field */
        
        public string   spEdCaseManagerName;
        public string   altFormat;

        public DateTime startDateAssigned;
        public string   startDateAssignedStr;       
        public string   startDateAssignedStrYMD;    

        public int      minsPerFreqAssigned;
        public string   minsPerFreqAssignedStr;

        public bool     hasSvcDetails;
        public string   hasSvcDetailsStr;
        public string   svcDetailsJSON;
        public string   minsPerFreqAssignedStrAndSpEdFreqName;
        public long     planRanking;
        public int      numRelatedScheduledServices;
        public int      numRelatedScheduledServicesCurrentlyInEffect;
        public bool     schedulesExpired;

        public string   minsPerFreqStr;
        public bool     minsPerFreqIsCombinedMins;
        public bool     hasAssignedMin;
        public bool     hasAssignedStartDate;
        public string   minsPerFreqAndSpEdFreqName;
        public string   minsPerFreqIsCombinedMinsStr;
        public string   startDateAssignedStrMinsPerFreqAssignedStrAndSpEdFreqName;
        public bool     assignedEntirePlan;
        public string   assignedEntirePlanStr;
     
        public string   patGroupMembershipJSON;
    }

    /***************************************************************************
     * PractitionerPatientCaseloadExpectedServices */
    /**
     *
 	 ***************************************************************************/
    public class PractitionerPatientCaseloadExpectedServices : Entities
    {
        public const string SEL_LABEL                        = @"Caseload & Expected Services";        
        public const string SEL_LABEL_MANAGE                 = @"Manage " + SEL_LABEL;
        public const string SEL_LABEL_IMPORT                 = SEL_LABEL + @" - Import";
        public const string SEL_LABEL_UPDATE                 = SEL_LABEL + @" - Update";
        public const string SEL_LABEL_EXPECTED_SERVICE_NEW   = SEL_LABEL + @" - New Entry";
        public const string SEL_LABEL_EXPECTED_SERVICE_EDIT  = SEL_LABEL + @" - Edit Entry";

        public const string URL_WEB_REPORT             = @"practitioner_patient_caseload_expected_services.ashx";
        public const string URL_WEB_SERVICE            = @"practitioner_patient_caseload_expected_services.asmx";
        public const string URL_SAVE                   = URL_WEB_SERVICE + @"/save";
        public const string URL_SAVE_INLINE            = URL_WEB_SERVICE + @"/saveinline";

        public const string URL_DELETE                 = URL_WEB_SERVICE + @"/delete";
        public const string URL_DELETE_ALL             = URL_WEB_SERVICE + @"/deleteall";
        public const string URL_DELETE_BATCH           = URL_WEB_SERVICE + @"/deletebatch";

        public const string URL_UPDATE_PLAN_INFO_ALL   = URL_WEB_SERVICE + @"/updateplaninfoall";
        public const string URL_VIEW_ENTITY            = URL_WEB_SERVICE + @"/viewEntity"; 
        public const string URL_VIEW_SEL               = URL_WEB_SERVICE + @"/viewSel"; 
        
        public const string URL_GET_EXPECTED_SERVICE_STATS = URL_WEB_SERVICE + @"/getexpectedservicestatsforapractitioner";

        public const string URL_REST_VIEW              = @"api/v1/practitionerpatientcaseloadexpectedservices";
        public const string URL_PAGE_IMPORT_USER_ALL   = @"user_all_practitioner_caseload_data_import.aspx";
        public const string URL_PAGE_UPDATE_CASELOAD   = @"user_all_practitioner_caseload_data_update.aspx";
        public const string URL_USER_ALL_SAVE_OR_EDIT  = @"user_all_practitioner_patient_caseload_expected_service_save.aspx";
        
        public const string STRUCTURED_DATA_IMPORT_PROFILES_FILE = @"practitioner-caseload-data.json";

        public const string PLAN_TYPE_IEP_IFSP_NAME  = Services.SVC_NAMES_LIST_DATA_SOURCE_IEP_IFSP_NAME;
        public const string PLAN_TYPE_OTHER_NAME     = Services.SVC_NAMES_LIST_DATA_SOURCE_OTHER_PLAN_NAME;
        public const string PLAN_TYPE_CYBHI_NAME     = Services.SVC_NAMES_LIST_DATA_SOURCE_CYBHI_NAME;

        public const string PLAN_TYPE_IEP_IFSP_VALUE = @"1";
        public const string PLAN_TYPE_OTHER_VALUE    = @"2";
        public const string PLAN_TYPE_CYBHI_VALUE    = @"3";

        /* Note: Keep following in synch with database constants 
         * dbo.CONST_SVC_TRACKING_CLASS_SPED()
         * dbo.CONST_SVC_TRACKING_CLASS_NON_SPED()
         * dbo.CONST_SVC_TRACKING_CLASS_USER_PROVIDED()
         */
 
        public const string SVC_TRACKING_CLASS_SPED_NAME           = @"IEP/IFSP Plan";
        public const string SVC_TRACKING_CLASS_NON_SPED_NAME       = @"SpEdCare Order";
        public const string SVC_TRACKING_CLASS_USER_PROVIDED_NAME  = @"Selected Service";

        public const string SVC_TRACKING_CLASS_SPED_VALUE          = @"100";
        public const string SVC_TRACKING_CLASS_NON_SPED_VALUE      = @"200";
        public const string SVC_TRACKING_CLASS_USER_PROVIDED_VALUE = @"300";

        /***************************************************************************
         * URL_USER_ALL_SAVE_NEW_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_USER_ALL_SAVE_NEW_BASE()
        {
            return MBA.HttpApplication.createLink(URL_USER_ALL_SAVE_OR_EDIT
                                                , true
                                                , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW));
        }

        /***************************************************************************
         * URL_USER_ALL_EDIT_EXISTING_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_USER_ALL_EDIT_EXISTING_BASE()
        {
            return MBA.HttpApplication.createLink(URL_USER_ALL_SAVE_OR_EDIT
                                                , true
                                                , new NameValue(Constants.PARM_APP_MODE,  Constants.AMD_UI_DBS_SUB_PAGE)
                                                , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)                                                
                                                );
        }

        /***************************************************************************
         * URL_SAVE_NEW_IMPORT_SUB_PAGE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_SAVE_NEW_IMPORT_SUB_PAGE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_PAGE_IMPORT_USER_ALL
                                                , true
                                                , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW));
        }

        /***************************************************************************
         * URL_PAGE_UPDATE_CAESELOAD_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_PAGE_UPDATE_CASELOAD_BASE()
        {
            return MBA.HttpApplication.createLink(URL_PAGE_UPDATE_CASELOAD
                                                , true
                                                , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW));
        }

        /***************************************************************************
         * URL_REST_VIEW */
        /**
         * 
         **************************************************************************/

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(PractitionerPatientCaseloadExpectedServices.URL_REST_VIEW, true);
        }

        /***************************************************************************
         * URL_SAVE_INLINE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_SAVE_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(PractitionerPatientCaseloadExpectedServices.URL_SAVE_INLINE, true);
        }

        /***************************************************************************
         * URL_SAVE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_SAVE_BASE()
        {
            return MBA.HttpApplication.createLink(PractitionerPatientCaseloadExpectedServices.URL_SAVE, true);
        }

        /***************************************************************************
         * URL_DELETE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_DELETE_BASE()
        {
            return MBA.HttpApplication.createLink(PractitionerPatientCaseloadExpectedServices.URL_DELETE, true);
        }

        /***************************************************************************
         * URL_DELETE_ALL_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_DELETE_ALL_BASE()
        {            
          return MBA.HttpApplication.createLink(PractitionerPatientCaseloadExpectedServices.URL_DELETE_ALL, true);
        }

        /***************************************************************************
         * URL_DELETE_BATCH_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_DELETE_BATCH_BASE()
        {            
          return MBA.HttpApplication.createLink(PractitionerPatientCaseloadExpectedServices.URL_DELETE_BATCH, true);
        }

        /***************************************************************************
         * URL_UPDATE_PLAN_INFO_ALL_BASE
        /**
         * 
         **************************************************************************/

        public static string URL_UPDATE_PLAN_INFO_ALL_BASE()
        {            
          return MBA.HttpApplication.createLink(PractitionerPatientCaseloadExpectedServices.URL_UPDATE_PLAN_INFO_ALL, true);
        }

        /***************************************************************************
         * URL_VIEW_ENTITY_BASE
        /**
         * 
         **************************************************************************/
        public static string URL_VIEW_ENTITY_BASE()
        {
            return MBA.HttpApplication.createLink(PractitionerPatientCaseloadExpectedServices.URL_VIEW_ENTITY, true);
        }

        /***************************************************************************
         * URL_VIEW_SEL_BASE
        /**
         * 
         **************************************************************************/
        public static string URL_VIEW_SEL_BASE()
        {
            return MBA.HttpApplication.createLink(PractitionerPatientCaseloadExpectedServices.URL_VIEW_SEL, true);
        }
        
        /***************************************************************************
         * URL_GET_EXPECTED_SERVICE_STATS_BASE
        /**
         * 
         **************************************************************************/
        public static string URL_GET_EXPECTED_SERVICE_STATS_BASE()
        {
            return MBA.HttpApplication.createLink(PractitionerPatientCaseloadExpectedServices.URL_GET_EXPECTED_SERVICE_STATS, true);
        }
        
        /***************************************************************************
         * URL_WEB_REPORT_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_WEB_REPORT_BASE()
        {
            return MBA.HttpApplication.createLink(PractitionerPatientCaseloadExpectedServices.URL_WEB_REPORT, true);
        }

        /***************************************************************************
         * view */
        /**
         * 
         ***************************************************************************/

        public static ReturnDB view (  SqlConnection connSpedmon
                                     , DetailsLog log
                                     , UserInfo uInfo
                                     , int recViewType
                                     , bool pagedOrTop
                                     , string idx
                                     , string canEdit
                                     , string active
                                     , string clientID
                                     , string pracID
                                     , string patID
                                     , string useMinsPerFreqAssigned
                                     , string disableComplianceCalc
                                     , defineCols dc)
        {

            string viewUDF = "dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @patID, @useMinsPerFreqAssigned, @recID, @disableComplianceCalc)";

            /*----------------------------
            * Validate parameters specific
            * to this entity.view
            * and populate their
            * coresponding database
            * parameters
            *----------------------------*/

            var vClientID               = Validate.optClientID (uInfo , clientID);            
            var vPracID                 = Validate.optInteger  (pracID, Messages.INVALID_PRAC_ID);            
            var vPatID                  = Validate.optInteger  (patID , Messages.INVALID_PAT_ID);            
            var vUseMinsPerFreqAssigned = Validate.optFlag(useMinsPerFreqAssigned,@"Invalid filter for show just mins assigned",true);
            var vDisableComplianceCalc  = Validate.optFlag(disableComplianceCalc,@"Invalid disable compliance calc value",true);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"               , SqlDbType.BigInt, vClientID               , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID"                 , SqlDbType.BigInt, vPracID                 , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID"                  , SqlDbType.BigInt, vPatID                  , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@useMinsPerFreqAssigned" , SqlDbType.Bit   , vUseMinsPerFreqAssigned , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@disableComplianceCalc"  , SqlDbType.Bit   , vDisableComplianceCalc  , ParameterDirection.Input));
            
            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        /***************************************************************************
         * viewObjects 
         *
         * Returns a list of objects
         * 
         ***************************************************************************/

        public static ReturnObjects viewObjects( SqlConnection connSpedmon
                                                  , DetailsLog log
                                                  , UserInfo uInfo
                                                  , bool pageObjectList
                                                  , string pageOrder
                                                  , string idx
                                                  , string active
                                                  , string clientID
                                                  , string pracID
                                                  , string patID
                                                  , string useMinsPerFreqAssigned
                                                  , string disableComplianceCalc
        )
        {

            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PractitionerPatientCaseloadExpectedService.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(PractitionerPatientCaseloadExpectedService)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return PractitionerPatientCaseloadExpectedServices.view(
                                                                         connSpedmon
                                                                       , log
                                                                       , uInfo
                                                                       , Entities.REC_VIEW_OBJECTS
                                                                       , pageObjectList
                                                                       , idx
                                                                       , "" // canEdit
                                                                       , active
                                                                       , clientID
                                                                       , pracID
                                                                       , patID
                                                                       , useMinsPerFreqAssigned
                                                                       , disableComplianceCalc
                                                                       , dc
                                               );
                                          });
        }

        /***************************************************************************
         * viewTbl */
        /**
         * Returns a data table of records for preview or record selection.
         *
         * @return                 ReturnDataTable
         ***************************************************************************/

        public static ReturnDataTable viewTbl(SqlConnection connSpedmon
                                                   , DetailsLog log
                                                   , UserInfo uInfo
                                                   , bool paged
                                                   , string pageNumber
                                                   , string canEdit
                                                   , string active
                                                   , string clientID
                                                   , string pracID
                                                   , string patID 
                                                   , string useMinsPerFreqAssigned
                                                   , string disableComplianceCalc )
        {
            ReturnDataTable so = new ReturnDataTable();

            /*----------------------------
             * Define our columns and
             * set the page order for
             * paging
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("clientName       as [Client]", true);
                ss.addDisplayColumn("pracName         as [Practitioner]", true);
                ss.addDisplayColumn("patLastName      as [Student\nLast Name]", true);
                ss.addDisplayColumn("patFirstName     as [Student\nFirst Name]", true);
                ss.addDisplayColumn("dobStr           as [DOB]");
                ss.addDisplayColumn("patSSID          as [SSID]");
                ss.addDisplayColumn("siteName         as [Site]");                
                ss.addDisplayColumn("svcTrackingName  as [Service Delivery Tracking]");
                ss.addDisplayColumn("minsPerFreqAndSpEdFreqName  as [Mins & Frequency]");
                ss.addDisplayColumn("startDateStr     as [Plan\nStart\nDate]");
                ss.addDisplayColumn("endDateStr       as [Plan\nEnd\nDate]");
                ss.addDisplayColumn("numMinsExpected            as [Minutes\nExpected\nTo Date]");
                ss.addDisplayColumn("numMinsApplicable          as [Minutes\nSatisfied\nTo Date]");
                ss.addDisplayColumn("numMinsDiff                as [Minutes\nMissing \nTo Date]");
                ss.addDisplayColumn("pctExpectedApplicableStr   as [Percent\nSatisfied\nTo Date]");                
                ss.addDisplayColumn("spEdCaseManagerName   as [Case Manager]");                
                ss.addDisplayColumn("altFormat             as [Alternate Formats]");                
                ss.addDisplayColumn("startDateAssignedStr  as [Practitioner\nResponsible\nFor\nServices\nOn Or After\nDate]");
                ss.addDisplayColumn("minsPerFreqAssignedStrAndSpEdFreqName  as [Practitioner\nResponsible\nFor\nMins & Frequency]");
                ss.addDisplayColumn("assignedEntirePlanStr  as [Practitioner\nResponsible\nFor\nEntire Plan]");                               
                pageroworder = ss.pageRowOrder();
            };

            /*----------------------------
             * Call base method which
             * handles the rest
             *----------------------------*/

            so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
              delegate {
                  return PractitionerPatientCaseloadExpectedServices.view(connSpedmon
                                           , log
                                           , uInfo
                                           , Entities.REC_VIEW_TBL
                                           , paged
                                           , pageNumber
                                           , canEdit
                                           , active
                                           , clientID
                                           , pracID
                                           , patID
                                           , useMinsPerFreqAssigned
                                           , disableComplianceCalc
                                           , dc);
              });

            /*----------------------------
             * Add a title and footer
             *----------------------------*/

            so.tableName   = SEL_LABEL;
            so.tableFooter = Messages.CONFIDENTIAL;

            /*----------------------------
             * Done
             *----------------------------*/

            return so;
        }
        
        /***************************************************************************
         * viewSel */
        /**
         * @return                 ReturnSel
         ***************************************************************************/
        public static ReturnSel viewSel (  SqlConnection connSpedmon
                                          , DetailsLog  log
                                          , UserInfo    uInfo
                                          , bool        paged
                                          , string      pageNumber
                                          , string      clientID
                                          , string      pracID
                                          , string      patID
                                          , string      term
                                          , bool requirePatient = true)
        {

            string vTerm = Validate.optString(term);
            if (requirePatient == true)
            {
                Validate.reqPatID(uInfo,patID);
            }

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {
              ss.addDisplayColumn("startDateAssignedStrMinsPerFreqAssignedStrAndSpEdFreqName as context1");                
            };

            return Entities.viewSel(connSpedmon, log, uInfo, paged, pageNumber,
              delegate { return PractitionerPatientCaseloadExpectedServices.view(connSpedmon
                  , log
                  , uInfo
                  , Entities.REC_VIEW_SEL
                  , paged
                  , pageNumber
                  , ""
                  , "Y"
                  , clientID
                  , pracID
                  , patID
                  , "Y"
                  , "Y"
                  , dc); });
        }

        /***************************************************************************
         * save */
        /**
         * 
         ***************************************************************************/

        public static ReturnSaveRecord save (  SqlConnection dbConnSpedmon
                                             , DetailsLog log
                                             , UserInfo uInfo
                                             , string clientID				                                
                                             , string pracID				                                
                                             , string patID				                                                                             
                                             , string svcTrackingClass
                                             , string spEdServiceCode
                                             , string orpDocID
                                             , string svcNamesListDataSourceID
                                             , string viaTeleHealth
                                             , string nameID
                                             , string startDate
                                             , string endDate
                                             , string spEdFreqCode
                                             , string minsPerFreq
                                             , string startDateAssigned
                                             , string minsPerFreqAssigned
                                             , string hasSvcDetails
                                             , string svcDetailsJSON
                                             , string userProvidedSvcTerms
                                             , string editDelReason
                                             , string validateRec
                                             , string saveType
                                             , string recID )
        {
            string saveSproc = @"PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE";
            string dupRecMsg = @"Record already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vClientID                     = Validate.reqClientID (uInfo                        , clientID);
            var vPracID                       = Validate.reqInteger  (pracID                       , Messages.INVALID_PRAC_ID);            
            var vPatID                        = Validate.reqInteger  (patID                        , Messages.INVALID_PAT_ID);
            var vSvcTrackingClass             = Validate.reqInteger  (svcTrackingClass             , @"Invalid service tracking class");
            var vSpEdServiceCode              = Validate.optInteger  (spEdServiceCode              , @"Invalid service code");
            var vOrpDocID                     = Validate.optInteger  (orpDocID                     , @"Invalid order selection");
            var vSvcNamesListDataSourceID     = Validate.optInteger  (svcNamesListDataSourceID     , @"Invalid plan type");
            var vViaTeleHealth                = Validate.optFlag     (viaTeleHealth                , @"Invalid via telehealth flag value", true);
            var vNameID                       = Validate.optInteger  (nameID                       , @"Invalid service selection");
            var vStartDate                    = Validate.optDate     (startDate                    , Messages.INVALID_START_DATE);
            var vEndDate                      = Validate.optDate     (endDate                      , Messages.INVALID_END_DATE);
            var vSpEdFreqCode                 = Validate.optInteger  (spEdFreqCode                 , @"Invalid frequency");
            var vMinsPerFreq                  = Validate.optInteger  (minsPerFreq                  , Messages.INVALID_NUM_MINS, true);
            var vStartDateAssigned            = Validate.optDate     (startDateAssigned            , Messages.INVALID_START_DATE);
            var vMinsPerFreqAssigned          = Validate.optInteger  (minsPerFreqAssigned          , Messages.INVALID_NUM_MINS, true);
            var vHasSvcDetails                = Validate.reqFlag     (hasSvcDetails                , Messages.INVALID_FLAG,true);
            var vSvcDetailsJSON               = Validate.optString   (svcDetailsJSON               , @"Invalid svc details");
            var vUserProvidedSvcTerms         = Validate.reqFlag     (userProvidedSvcTerms         , @"Invalid value for user provided service terms", true);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"                      , SqlDbType.BigInt , vClientID                     , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID"                        , SqlDbType.BigInt , vPracID                       , ParameterDirection.Input));            
            parms.Add(Database.SqlParm("@patID"                         , SqlDbType.BigInt , vPatID                        , ParameterDirection.Input));                        
            parms.Add(Database.SqlParm("@svcTrackingClass"              , SqlDbType.Int    , vSvcTrackingClass             , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdServiceCode"               , SqlDbType.Int    , vSpEdServiceCode              , ParameterDirection.Input));            
            parms.Add(Database.SqlParm("@orpDocID"                      , SqlDbType.BigInt , vOrpDocID                     , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcNamesListDataSourceID"      , SqlDbType.BigInt , vSvcNamesListDataSourceID     , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@viaTeleHealth"                 , SqlDbType.Bit    , vViaTeleHealth                , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@nameID"                        , SqlDbType.BigInt , vNameID                       , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@startDate"                     , SqlDbType.Date   , vStartDate                    , ParameterDirection.Input));            
            parms.Add(Database.SqlParm("@endDate"                       , SqlDbType.Date   , vEndDate                      , ParameterDirection.Input));            
            parms.Add(Database.SqlParm("@spEdFreqCode"                  , SqlDbType.Int    , vSpEdFreqCode                 , ParameterDirection.Input));            
            parms.Add(Database.SqlParm("@minsPerFreq"                   , SqlDbType.Int    , vMinsPerFreq                  , ParameterDirection.Input));            
            parms.Add(Database.SqlParm("@startDateAssigned"             , SqlDbType.Date   , vStartDateAssigned            , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@minsPerFreqAssigned"           , SqlDbType.Int    , vMinsPerFreqAssigned          , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@hasSvcDetails"                 , SqlDbType.Bit    , vHasSvcDetails                , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetailsJSON"                , SqlDbType.VarChar, vSvcDetailsJSON               , ParameterDirection.Input, -1));            
            parms.Add(Database.SqlParm("@userProvidedSvcTerms"          , SqlDbType.Bit    , vUserProvidedSvcTerms         , ParameterDirection.Input));
            
            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.save(dbConnSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
        }

        /***************************************************************************
         * saveMultiple */
        /**
         * 
         ***************************************************************************/

        public static Return saveMultiple (   SqlConnection dbConnSpedmon
                                             , DetailsLog   log
                                             , UserInfo     uInfo
                                             , string       clientID				                                
                                             , string       pracID				                                                                   
                                             , string       saveSelectedOnly
                                             , string       newSvcsJSON
                                             , string       validateRec )
        {
            string saveType = Constants.SAVE_TYPE_NEW.ToString();
            string recID = "";

            string saveSproc = @"PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_MULTIPLE";
            string dupRecMsg = @"Record already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vClientID           = Validate.reqClientID (uInfo, clientID);
            var vPracID             = Validate.reqPracID   (uInfo, pracID);
            var vNewSvcsJSON        = Validate.reqString   (newSvcsJSON, @"Invalid svc details");
            var vSaveSelectedOnly   = Validate.reqFlag     (saveSelectedOnly,@"Invalid save selected only value");

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"                 , SqlDbType.BigInt , vClientID         , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID"                   , SqlDbType.BigInt , vPracID           , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@saveSelectedOnly"         , SqlDbType.BigInt , vSaveSelectedOnly , ParameterDirection.Input));            
            parms.Add(Database.SqlParm("@newSvcsJSON"              , SqlDbType.VarChar, vNewSvcsJSON      , ParameterDirection.Input, -1));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.save(dbConnSpedmon, log, uInfo, saveType, validateRec, "", recID, saveSproc, dupRecMsg, ref parms, null);
        }


        /***************************************************************************
         * delete */
        /**
         * 
         ***************************************************************************/

        public static ReturnSaveRecord delete (  SqlConnection connSpedmon
                                               , DetailsLog log
                                               , UserInfo uInfo
                                               , string clientID
                                               , string pracID
                                               , string editDelReason
                                               , string validateRec
                                               , string recID)
        {

            string deleteSproc = @"PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE";

            /*###########################################################################
              # Validate parameters specific to this entity delete and create their 
              # database parameters.
              ###########################################################################*/

            var vClientID = Validate.optClientID (uInfo, clientID);
            var vPracID   = Validate.optPracID   (uInfo, pracID);

            var parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID"  , SqlDbType.BigInt, vPracID  , ParameterDirection.Input));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, deleteSproc, ref parms);
        }
        
        /***************************************************************************
         * deleteAll */
        /**
         * 
         ***************************************************************************/

        public static ReturnSaveRecord deleteAll (  SqlConnection connSpedmon
                                                   , DetailsLog log
                                                   , UserInfo uInfo
                                                   , string clientID
                                                   , string pracID
                                                   , string editDelReason
                                                   , string validateRec )
        {

            string deleteAllSproc = @"PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE_ALL";

            /*###########################################################################
              # Validate parameters specific to this entity delete and create their 
              # database parameters.
              ###########################################################################*/

            var vClientID = Validate.reqClientID (uInfo, clientID);
            var vPracID   = Validate.reqPracID   (uInfo, pracID);

            var parms = new List<SqlParameter>();
            
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID"  , SqlDbType.BigInt, vPracID  , ParameterDirection.Input));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.deleteAll (connSpedmon, log, uInfo, editDelReason, validateRec, deleteAllSproc, ref parms);
        }
        
        /***************************************************************************
         * deleteBatch */
        /**
         * 
         ***************************************************************************/

        public static ReturnSaveRecord deleteBatch (  SqlConnection connSpedmon
                                                     , DetailsLog   log
                                                     , UserInfo     uInfo
                                                     , string       clientID
                                                     , string       pracID
                                                     , string       editDelReason
                                                     , string       validateRec
                                                     , string       recIDMulti )
        {

            string deleteBatchSproc = @"PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE_BATCH";

            /*###########################################################################
              # Validate parameters specific to this entity delete and create their 
              # database parameters.
              ###########################################################################*/

            var vClientID = Validate.reqClientID (uInfo, clientID);
            var vPracID   = Validate.reqPracID   (uInfo, pracID);

            var parms = new List<SqlParameter>();
            
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID"  , SqlDbType.BigInt, vPracID  , ParameterDirection.Input));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.deleteBatch (connSpedmon, log, uInfo, editDelReason, validateRec, recIDMulti, deleteBatchSproc,ref parms);
            
        }

        /***************************************************************************
         * updatePlanInfoAll */
        /**
         * 
         ***************************************************************************/
        public static ReturnSaveRecordWithJSONData updatePlanInfoAll (  SqlConnection connSpedmon
                                                          , DetailsLog log
                                                          , UserInfo uInfo
                                                          , string clientID
                                                          , string pracID
                                                          , string editDelReason
                                                          , string validateRec )
        {

            string saveSproc = @"PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_UPDATE_PLAN_INFO_ALL_AND_GET_NEW";

            /*###########################################################################
              # Validate parameters specific to this entity update and create their 
              # database parameters.
              ###########################################################################*/

            var vClientID = Validate.reqClientID (uInfo, clientID);
            var vPracID   = Validate.reqPracID   (uInfo, pracID);

            var parms = new List<SqlParameter>();
            
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID"  , SqlDbType.BigInt, vPracID  , ParameterDirection.Input));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.saveAndReturnJSONData( connSpedmon
                                                  , log
                                                  , uInfo
                                                  , Constants.SAVE_TYPE_NEW.ToString()
                                                  , validateRec
                                                  , editDelReason
                                                  , ""
                                                  , saveSproc
                                                  , @"Plan or service already on caseload"
                                                  , ref parms
                                                  , null);
            
        }

        /***************************************************************************
         * load */
        /**
         * Outputs data for a single caseload member
         ***************************************************************************/

        public static PractitionerPatientCaseloadExpectedService load(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                         string clientID, string pracID, string patID, string recID)
        {
            return (PractitionerPatientCaseloadExpectedService)Entities.load(connSpedmon, log, uInfo, "", typeof(PractitionerPatientCaseloadExpectedService),
            delegate { return PractitionerPatientCaseloadExpectedServices.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", clientID, pracID, patID, "", "Y", null); });
        }

        /***************************************************************************
         * viewEntity */
        /**
         * Outputs data for a single record
         ***************************************************************************/
        public static ReturnEntity viewEntity(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                         string clientID, string pracID, string patID, string recID)
        {
            ReturnEntity so = new ReturnEntity();
            PractitionerPatientCaseloadExpectedService c = PractitionerPatientCaseloadExpectedServices.load(connSpedmon, log, uInfo, clientID, pracID, patID, recID);
            so.entity = (Entity)c;
            return so;
        }

        /***************************************************************************
         * getCdeComplianceOverallSummaryForAPractitioner */
        /**
         * 
         ***************************************************************************/
        public static ReturnTotalNumAmts getCdeComplianceOverallSummaryForAPractitioner (  SqlConnection connSpedmon
                                                                                         , DetailsLog    log
                                                                                         , UserInfo      uInfo
                                                                                         , string        clientID
                                                                                         , string        pracID
                                                                                         , string        useMinsPerFreqAssigned )             
        {

          ReturnTotalNumAmts so = new ReturnTotalNumAmts();

          long   vClientID               = Validate.reqClientID (uInfo, clientID);
          long   vPracID                 = Validate.reqPracID   (uInfo, pracID);
          Object vUseMinsPerFreqAssigned = Validate.optFlag     (useMinsPerFreqAssigned, @"Invalid use mins per freq assigned flag", true);

          var parms = new List<SqlParameter>();   

          parms.Add(Database.SqlParm("@clientID",                  SqlDbType.BigInt,    vClientID,                 ParameterDirection.Input));
          parms.Add(Database.SqlParm("@pracID",                    SqlDbType.BigInt,    vPracID,                   ParameterDirection.Input));
          parms.Add(Database.SqlParm("@useMinsPerFreqAssigned",    SqlDbType.Bit,       vUseMinsPerFreqAssigned,   ParameterDirection.Input));
                      
          var viewUDF = @"dbo.RPT_CDE_COMPLIANCE_FOR_PRAC_CASELOAD_SUMMARY(null,null,null,@clientID,@pracID,@useMinsPerFreqAssigned)";
          var rd      = Entities.view (connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, "", "", "Y", viewUDF, ref parms, null, null);         
          var amts = new List<TotalNumAmt>();
          var slo = Database.convertRecordsToList(ref rd.records, typeof(CdeComplianceMetric));
          
          var actionUrlForThisPracsCaseload = MBA.HttpApplication.createLink ( PractitionerCaseloadMembers.URL_USER_ALL
                                                                              , true
                                                                              , new NameValue(Constants.PARM_CLIENT_ID,       vClientID)
                                                                              , new NameValue(Constants.PARM_PRACTITIONER_ID, vPracID));
          foreach (var o in slo) {
            var ccm = (CdeComplianceMetric) o ;
            var tna = new TotalNumAmt();
            tna.label           = ccm.spEdServiceCodeAndName;
            tna.totalNumVal     = (long) ccm.pctExpectedApplicable;
            tna.totalNumStr     = ccm.pctExpectedApplicable.ToString();
            tna.additionalData1 = ccm.totMinsExpected.ToString();
            tna.additionalData2 = ccm.totMinsApplicable.ToString();
            tna.actionURL       = actionUrlForThisPracsCaseload;
            amts.Add(tna);    
          }
          
          so.totalNumAmts = amts.ToArray();
          return so;
        }
        
        /***************************************************************************
         * getExpectedServiceStatsForAPractitioner */
        /**
         * Returns stats regarding possible updates and expired schedules.
         ***************************************************************************/
        public static ReturnObject getExpectedServiceStatsForAPractitioner (  SqlConnection connSpedmon
                                                                             , DetailsLog    log
                                                                             , UserInfo      uInfo
                                                                             , string        clientID
                                                                             , string        pracID )             
        {

          ReturnObject so = new ReturnObject();
          var _et = typeof(PractitionerPatientCaseloadExpectedServicesStats);
          so.hasRecord            = false;
          so.objectFullName       = _et.FullName;
          long vClientID = Validate.reqClientID (uInfo, clientID);
          long vPracID   = Validate.reqPracID   (uInfo, pracID);
          var parms = new List<SqlParameter>();             
          Entities.validateAndAddCommonUserInfoParameters(uInfo,ref parms);
          parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
          parms.Add(Database.SqlParm("@pracID",   SqlDbType.BigInt, vPracID,   ParameterDirection.Input));                              
          var sql = @"select * from dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_STATS_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID)";
          var rd = Database.execQuery(connSpedmon,log,sql,false,parms);
          if (rd.hasRecords == true) {
            so.hasRecord = true;
            PractitionerPatientCaseloadExpectedServicesStats ppcess = (PractitionerPatientCaseloadExpectedServicesStats) Database.convertRecord(rd.records,typeof(PractitionerPatientCaseloadExpectedServicesStats));
            so.data = ppcess;
          }        
          return so;
        }

        /***************************************************************************
         * importData */
        /**
         * 
         ***************************************************************************/
        public static ReturnSaveRecordWithJSONData importData ( SqlConnection connSpedmon
                                                                , DetailsLog log
                                                                , UserInfo uInfo
                                                                , string clientID
                                                                , string pracID
                                                                , string dataToImportJSON
                                                                , string validateRec
                                                              )
        {

            ReturnSaveRecordWithJSONData rd = new ReturnSaveRecordWithJSONData();

            /*----------------------------
             * Validate incoming data
             *----------------------------*/

            long vClientID = Validate.reqClientID (uInfo, clientID);
            long vPracID   = Validate.reqPracID   (uInfo, pracID);

            MBA.StructuredDataFieldAdditionalValidation _fnAdditionalFieldValidation = delegate (int rowNum, StructuredDataField field, string valueIn)
            {
                string valueOut = valueIn;
                return valueOut;
            };

            string vDataToImport = MBA.StructuredDataImportFiles.validate (   STRUCTURED_DATA_IMPORT_PROFILES_FILE
                                                                            , dataToImportJSON
                                                                            , @"Please select the type of file and a file"
                                                                            , @"Please select the type of file"
                                                                            , @"Please select a file that has records"
                                                                            , @"All of the records in this data file have data issues"
                                                                            , null
                                                                            , _fnAdditionalFieldValidation);
            /*----------------------------
             * Populate db parameters
             *----------------------------*/

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID",       SqlDbType.BigInt,   vClientID,     ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID",         SqlDbType.BigInt,   vPracID,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@importDataJSON", SqlDbType.VarChar,  vDataToImport, ParameterDirection.Input, -1));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            rd = Entities.saveAndReturnJSONData ( connSpedmon
                                                 , log
                                                 , uInfo
                                                 , Constants.SAVE_TYPE_NEW.ToString()
                                                 , validateRec
                                                 , ""
                                                 , ""
                                                 , "Practitioner_Patient_Caseload_Expected_Services_Data_Imports_Save"
                                                 , @"Duplicate file"
                                                 , ref parms
                                                 , null);

            return rd;

        }



    }
}
