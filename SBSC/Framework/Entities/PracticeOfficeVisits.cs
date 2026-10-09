using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA.Reporting;
using MBA;


namespace Spedmon
{
   /**************************************************************************
    * PracticeOfficeVisit */
   /**
    * 
    * 
    ***************************************************************************/
    public class PracticeOfficeVisit : Entity
    {
       public const string DEFAULT_PAGING_ORDER = "patName asc, id desc";		
	   public long      clientID;
       public long      groupSvcClassNameID;
	   public string    groupSvcClassName;
	   public long      siteID; 
       public string    siteName;
	   public string    studentID;
       public string    grade;
	   public long      patID;
       public string    patName;
       public string    patLastName;
       public string    patFirstName;
       public long      practiceOfficeVisitReasonID;
       public string    practiceOfficeVisitReasonName;
	   public string    practiceOfficeVisitReasonNotes;
       public bool      hasVisitReasonNotes;
       public DateTime  checkInDate;
	   public TimeSpan  checkInTime; 
       public string    checkInDateStr;
       public string    checkInTimeStr;
       public string    checkInDateYYMMDDStr;
       public string    checkInTimeHHMMStr;
       public string    waitingTimeStr;
       public string    visitingTimeStr;
	   public long      pracID;
       public string    pracName;
       public string    pracTitle;
       public string    pracLastName;
       public string    pracFirstName;
       public long      groupID;

	   public DateTime? visitStartDate;
	   public TimeSpan? visitStartTime;
       public string    visitStartDateStr;
       public string    visitStartTimeStr;
       public string    visitStartDateYYMMDDStr;
	   public string    visitStartTimeHHMMStr;

       public long      practiceOfficeVisitResolutionID;
       public string    practiceOfficeVisitResolutionName;                        
       public string    practiceOfficeVisitResolutionNotes;
       public string    practiceOfficeVisitResolutionFBQuestionsJSON;
       public string    practiceOfficeVisitResolutionFBAnswersJSON;

	   public DateTime? visitEndDate;  
	   public TimeSpan? visitEndTime; 
       public string    visitEndDateStr;
       public string    visitEndTimeStr;
       public string    visitEndDateYYMMDDStr;
	   public string    visitEndTimeHHMMStr;

       public int       currentVisitStatusCodeValue;
       public string    currentVisitStatusCodeName;

       public bool      checkInComplete;
       public bool      waiting;
       public bool      pracAssigned;
       public bool      visiting;
	   public bool      completed;   
       public string    assignedPracSig;
    }

   /**************************************************************************
    * PracticeOfficeVisits */
   /**
    * 
    * 
    ***************************************************************************/
    public class PracticeOfficeVisits : Entities
    {

        public const string URL_WEB_SVC                        = @"practice_office_visits.asmx";
        public const string URL_SVC_DELETE_INLINE              = URL_WEB_SVC + @"/deleteinline";
        public const string URL_SVC_CHECK_IN_FROM_KIOSK        = URL_WEB_SVC + @"/checkinfromkiosk";
        public const string URL_SVC_CHECK_IN_FROM_WAITING_ROOM = URL_WEB_SVC + @"/checkinfromwaitingroom";        
        public const string URL_SVC_END_VISIT                  = URL_WEB_SVC + @"/endvisit";
        public const string URL_SVC_VISIT_IN_PROGRESS_SAVE     = URL_WEB_SVC + @"/savevisitinprogress";
        public const string URL_SVC_CHECK_IN_FROM_PUBLIC_KIOSK = URL_WEB_SVC + @"/checkinfrompublickiosk";
        public const string URL_SVC_EDIT_COMPLETED_VISIT       = URL_WEB_SVC + @"/editcompletedvisit";
        public const string URL_SVC_LOAD_VISIT                 = URL_WEB_SVC + @"/loadpracticeofficevisit";

        public const string URL_PAGE_PUBLIC_KISOK              = @"practice_office_public_check_in.aspx";
        public const string URL_REST_VIEW                      = @"api/v1/practiceofficevisits";
        public const string URL_WEB_REPORT                     = @"practice_office_visits.ashx";

        /***************************************************************************
         * URL_SVC_CHECK_IN_FROM_KIOSK_BASE */
        /**
         * 
         **************************************************************************/
         public static string URL_SVC_CHECK_IN_FROM_KIOSK_BASE()
         {
           return MBA.HttpApplication.createLink(PracticeOfficeVisits.URL_SVC_CHECK_IN_FROM_KIOSK, true);
         }

        /***************************************************************************
         * URL_SVC_CHECK_IN_FROM_PUBLIC_KIOSK_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SVC_CHECK_IN_FROM_PUBLIC_KISOK_BASE ()
        {
            return MBA.HttpApplication.createLink (  PracticeOfficeVisits.URL_SVC_CHECK_IN_FROM_PUBLIC_KIOSK
                                                   , false
                                                  );
        }
        /***************************************************************************
         * URL_SVC_CHECK_IN_FROM_WAITING_ROOM_BASE */
        /**
         * 
         **************************************************************************/
		 public static string URL_SVC_CHECK_IN_FROM_WAITING_ROOM_BASE()
         {
           return MBA.HttpApplication.createLink(PracticeOfficeVisits.URL_SVC_CHECK_IN_FROM_WAITING_ROOM, true);
         }

        /***************************************************************************
         * URL_SVC_END_VISIT_BASE */
        /**
         * 
         **************************************************************************/
		 public static string URL_SVC_END_VISIT_BASE()
         {
           return MBA.HttpApplication.createLink(PracticeOfficeVisits.URL_SVC_END_VISIT, true);
         }

        /***************************************************************************
         * URL_SVC_VISIT_IN_PROGRESS_SAVE_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SVC_VISIT_IN_PROGRESS_SAVE_BASE()
        {
            return MBA.HttpApplication.createLink(PracticeOfficeVisits.URL_SVC_VISIT_IN_PROGRESS_SAVE, true);
        }


        /***************************************************************************
         * URL_SVC_EDIT_COMPLETED_VISIT_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SVC_EDIT_COMPLETED_VISIT_BASE()
         {
            return MBA.HttpApplication.createLink(PracticeOfficeVisits.URL_SVC_EDIT_COMPLETED_VISIT, true);
         }

        /***************************************************************************
         * URL_SVC_DELETE_INLINE_BASE */
        /**
         * 
         **************************************************************************/
		 public static string URL_SVC_DELETE_INLINE_BASE()
         {
           return MBA.HttpApplication.createLink(PracticeOfficeVisits.URL_SVC_DELETE_INLINE, true);
         }

        /***************************************************************************
         * URL_REST_VIEW_BASE */
        /**
         * 
         **************************************************************************/

		public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(PracticeOfficeVisits.URL_REST_VIEW, true);
        }

        /***************************************************************************
         * URL_WEB_REPORT_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_WEB_REPORT_BASE()
        {
            return MBA.HttpApplication.createLink(PracticeOfficeVisits.URL_WEB_REPORT, true);
        }

        /***************************************************************************
         * URL_SVC_LOAD_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SVC_LOAD_BASE()
        {
            return MBA.HttpApplication.createLink(PracticeOfficeVisits.URL_SVC_LOAD_VISIT, true);
        }

        /***************************************************************************
         * checkInFromPublicKiosk */
        /**
         * 
         **************************************************************************/
        public static ReturnActionRequest checkInFromPublicKiosk (   SqlConnection    connSpedmon
                                                                   , DetailsLog       log 
                                                                   , RequestResponse  rr
                                                                   , string           ptkn
                                                                   , string           studentID
                                                                   , string           practiceOfficeVisitReasonID
											                       , string           practiceOfficeVisitReasonNotes )

        {
            ReturnActionRequest so = new ReturnActionRequest();

            string actionRequestSproc = "PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_PUBLIC_KIOSK";
            
            string   vPtkn                            = Validate.reqString  (ptkn,@"Invalid token");            
			string   vStudentID                       = Validate.reqString  (studentID, Messages.INVALID_STUDENT_ID);
            long     vPracticeOfficeVisitReasonID     = Validate.reqInteger (practiceOfficeVisitReasonID,    @"Invalid visit reason");
            string   vPracticeOfficeVisitReasonNotes  = Validate.optString  (practiceOfficeVisitReasonNotes, @"Invalid notes");            
            
            
            try
            { 
              /* Since this is a public facing method we want to take the extra step of additional sanitization 
               * of student id and reason notes.   The req and opt String methods already remove <script> tags
               * 
               * See : https://learn.microsoft.com/en-us/archive/msdn-magazine/2012/january/asp-net-security-securing-your-asp-net-applications
               * Note: HtmlEncoding will not prevent the scripting or markup SOURCE from being shown BUT it will prevent
               * it from being executed or rendered. 
               */

              vStudentID                      = System.Net.WebUtility.HtmlEncode(vStudentID);
              vPracticeOfficeVisitReasonNotes = System.Net.WebUtility.HtmlEncode(vPracticeOfficeVisitReasonNotes);

              var parms = new List<SqlParameter>();

              parms.Add(Database.SqlParm("@userIP",                          SqlDbType.VarChar,  rr.userIP,    ParameterDirection.Input, 500));
              parms.Add(Database.SqlParm("@userAgent",                       SqlDbType.VarChar,  rr.userAgent, ParameterDirection.Input, 8000));
              parms.Add(Database.SqlParm("@ptkn",                            SqlDbType.VarChar,  vPtkn,                           ParameterDirection.Input, 500));
              parms.Add(Database.SqlParm("@studentID",                       SqlDbType.NVarChar, vStudentID,                      ParameterDirection.Input, 50));
              parms.Add(Database.SqlParm("@practiceOfficeVisitReasonID",     SqlDbType.BigInt,   vPracticeOfficeVisitReasonID,    ParameterDirection.Input));
              parms.Add(Database.SqlParm("@practiceOfficeVisitReasonNotes",  SqlDbType.VarChar,  vPracticeOfficeVisitReasonNotes, ParameterDirection.Input, 2000));
            
              ReturnDB rd = Database.execSproc(connSpedmon, log, actionRequestSproc, parms);     
              so = (ReturnActionRequest) Database.convertParameters(rd,typeof(ReturnActionRequest));

                
            }

            /* We dont want non users seeing internal details so return a very generic message */

            catch
            {
                so.message = @"A problem has occurred please try your request again";
                so.status = Return.RET_WARNING;
            }
            return so;
        } 
        

        /***************************************************************************
         * checkInFromWaitingRoom */
        /**
         * 
         **************************************************************************/
        public static ReturnSaveRecord checkInFromWaitingRoom (   SqlConnection   connSpedmon
                                                                , DetailsLog      log
                                                                , UserInfo        uInfo
                                                                , RequestResponse rr
                                                                , string      clientID
                                                                , string      groupSvcClassNameID
											                    , string      siteID
                                                                , string      patID
                                                                , string      practiceOfficeVisitReasonID
											                    , string      practiceOfficeVisitReasonNotes
                                                                , string      pracID 
                                                                , string      saveType                                                                                                                                
                                                                , string      recID)
        {
            
            var parms = new List<SqlParameter>();

            string saveSproc = "PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_WAITING_ROOM";
           
			long     vClientID                        = Validate.reqClientID                (uInfo, clientID);
            long     vGroupSvcClassNameID             = Validate.reqStdGroupSvcClassNameID  (uInfo, groupSvcClassNameID);
            long     vSiteID                          = Validate.reqInteger                 (siteID,                         @"Invalid site");            
            long     vPatID                           = Validate.reqPatID                   (uInfo, patID);
            long     vPracticeOfficeVisitReasonID     = Validate.reqInteger                 (practiceOfficeVisitReasonID,    @"Invalid visit reason");
            string   vPracticeOfficeVisitReasonNotes  = Validate.optString                  (practiceOfficeVisitReasonNotes, @"Invalid notes");            
            Object   vPracID                          = Validate.optInteger                 (pracID, Messages.INVALID_PRAC_ID, true); 
            
            parms.Add(Database.SqlParm("@userIP",                          SqlDbType.VarChar,  rr.userIP,                       ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@userAgent",                       SqlDbType.VarChar,  rr.userAgent,                    ParameterDirection.Input, 8000));
            parms.Add(Database.SqlParm("@clientID",                        SqlDbType.BigInt,   vClientID,                       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@groupSvcClassNameID",             SqlDbType.BigInt,   vGroupSvcClassNameID,            ParameterDirection.Input));
            parms.Add(Database.SqlParm("@siteID",                          SqlDbType.BigInt,   vSiteID,                         ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID",                           SqlDbType.BigInt,   vPatID,                          ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID",                          SqlDbType.BigInt,   vPracID,                         ParameterDirection.Input));
            parms.Add(Database.SqlParm("@practiceOfficeVisitReasonID",     SqlDbType.BigInt,   vPracticeOfficeVisitReasonID,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@practiceOfficeVisitReasonNotes",  SqlDbType.VarChar,  vPracticeOfficeVisitReasonNotes, ParameterDirection.Input, -1));
            
            return Entities.save ( connSpedmon
                                   , log
                                   , uInfo
                                   , saveType
                                   , "N"
                                   , ""
                                   , recID
                                   , saveSproc
                                   , @"Duplicate visit"
                                   , ref parms
                                   , delegate () { });

        }

        /***************************************************************************
         * startVisit */
        /**
         * 
         **************************************************************************/
        public static ReturnSaveRecord startVisit (  SqlConnection connSpedmon
                                                    , DetailsLog  log
                                                    , UserInfo    uInfo
                                                    , string      clientID
                                                    , string      pracID
                                                    , string      recID )
        {
            
            var parms = new List<SqlParameter>();

            string opSproc = "PRACTICE_OFFICE_VISITS_START_VISIT";
           
			long     vClientID  = Validate.reqClientID (uInfo, clientID);
		    long     vPracID    = Validate.reqPracID   (uInfo, pracID);

            parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,   vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID",    SqlDbType.BigInt,   vPracID,   ParameterDirection.Input));
            
            return Entities.recordOp (  connSpedmon
                                      , log
                                      , uInfo
                                      , ""
                                      , "N"
                                      , recID
                                      , opSproc
                                      , ref parms);

            
        }

        /***************************************************************************
         * endVisit */
        /**
         * 
         **************************************************************************/
        public static ReturnSaveRecord endVisit (  SqlConnection connSpedmon
                                                   , DetailsLog  log
                                                   , UserInfo    uInfo
                                                   , string      clientID
                                                   , string      pracID
                                                   , string      checkInDate
                                                   , string      checkInTime
                                                   , string      visitStartDate
                                                   , string      visitStartTime
                                                   , string      visitEndDate
                                                   , string      visitEndTime
                                                   , string      practiceOfficeVisitResolutionID
                                                   , string      practiceOfficeVisitResolutionNotes
                                                   , string      practiceOfficeVisitResolutionFBQuestionsJSON
                                                   , string      practiceOfficeVisitResolutionFBAnswersJSON
                                                   , string      recID )
        {
            
            var parms = new List<SqlParameter>();

            string opSproc = "PRACTICE_OFFICE_VISITS_END_VISIT";
           
			long     vClientID                            = Validate.reqClientID  (uInfo, clientID);
		    long     vPracID                              = Validate.reqPracID    (uInfo, pracID);
            DateTime vCheckInDate                         = Validate.reqDate      (checkInDate,                        @"Invalid check-in date");
            TimeSpan vCheckInTime                         = Validate.reqTime      (checkInTime,                        @"Invalid check-in time");
            DateTime vVisitStartDate                      = Validate.reqDate      (visitStartDate,                     @"Invalid visit start date");
            TimeSpan vVisitStartTime                      = Validate.reqTime      (visitStartTime,                     @"Invalid visit start time");
            object   vVisitEndDate                        = Validate.optDate      (visitEndDate,                       @"Invalid visit end date");
            object   vVisitEndTime                        = Validate.optTime      (visitEndTime,                       @"Invalid visit end time");
            long     vPracticeOfficeVisitResolutionID     = Validate.reqInteger   (practiceOfficeVisitResolutionID,    @"Invalid visit resolution");
            string   vPracticeOfficeVisitResolutionNotes  = Validate.optString    (practiceOfficeVisitResolutionNotes, @"Invalid notes");
 
            string   vPracticeOfficeVisitResolutionFBQuestionsJSON = Validate.optString    (practiceOfficeVisitResolutionFBQuestionsJSON, @"Invalid form questions");
            string   vPracticeOfficeVisitResolutionFBAnswersJSON   = Validate.optString    (practiceOfficeVisitResolutionFBAnswersJSON,   @"Invalid form answers");
            
            parms.Add(Database.SqlParm("@clientID",                                      SqlDbType.BigInt,   vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID",                                        SqlDbType.BigInt,   vPracID,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@checkInDate",                                   SqlDbType.Date,     vCheckInDate,                                  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@checkInTime",                                   SqlDbType.Time,     vCheckInTime,                                  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@visitStartDate",                                SqlDbType.Date,     vVisitStartDate,                               ParameterDirection.Input));
            parms.Add(Database.SqlParm("@visitStartTime",                                SqlDbType.Time,     vVisitStartTime,                               ParameterDirection.Input));
            parms.Add(Database.SqlParm("@visitEndDate",                                  SqlDbType.Date,     vVisitEndDate,                                 ParameterDirection.Input));
            parms.Add(Database.SqlParm("@visitEndTime",                                  SqlDbType.Time,     vVisitEndTime,                                 ParameterDirection.Input));
            parms.Add(Database.SqlParm("@practiceOfficeVisitResolutionID",               SqlDbType.BigInt,   vPracticeOfficeVisitResolutionID,              ParameterDirection.Input));
            parms.Add(Database.SqlParm("@practiceOfficeVisitResolutionNotes",            SqlDbType.VarChar,  vPracticeOfficeVisitResolutionNotes,           ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@practiceOfficeVisitResolutionFBQuestionsJSON",  SqlDbType.VarChar,  vPracticeOfficeVisitResolutionFBQuestionsJSON, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@practiceOfficeVisitResolutionFBAnswersJSON",    SqlDbType.VarChar,  vPracticeOfficeVisitResolutionFBAnswersJSON,   ParameterDirection.Input, -1));
            
            return Entities.recordOp (  connSpedmon
                                      , log
                                      , uInfo
                                      , ""
                                      , "N"
                                      , recID
                                      , opSproc
                                      , ref parms);
            
        }

        /***************************************************************************
         * Saving the Visit Data from an Unexpected Closure
         * visitInProgress */
        /**
         * 
         **************************************************************************/
        public static ReturnSaveRecord visitInProgress(SqlConnection connSpedmon
                                                       , DetailsLog log
                                                       , UserInfo uInfo
                                                       , string clientID
                                                       , string pracID
                                                       , string checkInDate
                                                       , string checkInTime
                                                       , string visitStartDate
                                                       , string visitStartTime
                                                       , string visitEndDate
                                                       , string visitEndTime
                                                       , string practiceOfficeVisitResolutionID
                                                       , string practiceOfficeVisitResolutionNotes
                                                       , string practiceOfficeVisitResolutionFBQuestionsJSON
                                                       , string practiceOfficeVisitResolutionFBAnswersJSON
                                                       , string recID)
        {

            var parms = new List<SqlParameter>();

            string opSproc = "PRACTICE_OFFICE_VISITS_SAVE_VISIT_IN_PROGRESS";

            long vClientID                              = Validate.reqClientID  (uInfo, clientID);
            long vPracID                                = Validate.reqPracID    (uInfo, pracID);
            DateTime vCheckInDate                       = Validate.reqDate      (checkInDate,                           @"Invalid check-in date");
            TimeSpan vCheckInTime                       = Validate.reqTime      (checkInTime,                           @"Invalid check-in time");
            DateTime vVisitStartDate                    = Validate.reqDate      (visitStartDate,                        @"Invalid visit start date");
            TimeSpan vVisitStartTime                    = Validate.reqTime      (visitStartTime,                        @"Invalid visit start time");
            object vVisitEndDate                        = Validate.optDate      (visitEndDate,                          @"Invalid visit end date");
            object vVisitEndTime                        = Validate.optTime      (visitEndTime,                          @"Invalid visit end time");
            object vPracticeOfficeVisitResolutionID     = Validate.optInteger   (practiceOfficeVisitResolutionID,       @"Invalid visit resolution");
            string vPracticeOfficeVisitResolutionNotes  = Validate.optString    (practiceOfficeVisitResolutionNotes,    @"Invalid notes");

            string vPracticeOfficeVisitResolutionFBQuestionsJSON = Validate.optString(practiceOfficeVisitResolutionFBQuestionsJSON, @"Invalid form questions");
            string vPracticeOfficeVisitResolutionFBAnswersJSON = Validate.optString(practiceOfficeVisitResolutionFBAnswersJSON, @"Invalid form answers");

            parms.Add(Database.SqlParm("@clientID",                                     SqlDbType.BigInt,   vClientID,                                      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID",                                       SqlDbType.BigInt,   vPracID,                                        ParameterDirection.Input));
            parms.Add(Database.SqlParm("@checkInDate",                                  SqlDbType.Date,     vCheckInDate,                                   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@checkInTime",                                  SqlDbType.Time,     vCheckInTime,                                   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@visitStartDate",                               SqlDbType.Date,     vVisitStartDate,                                ParameterDirection.Input));
            parms.Add(Database.SqlParm("@visitStartTime",                               SqlDbType.Time,     vVisitStartTime,                                ParameterDirection.Input));
            parms.Add(Database.SqlParm("@visitEndDate",                                 SqlDbType.Date,     vVisitEndDate,                                  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@visitEndTime",                                 SqlDbType.Time,     vVisitEndTime,                                  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@practiceOfficeVisitResolutionID",              SqlDbType.BigInt,   vPracticeOfficeVisitResolutionID,               ParameterDirection.Input));
            parms.Add(Database.SqlParm("@practiceOfficeVisitResolutionNotes",           SqlDbType.VarChar,  vPracticeOfficeVisitResolutionNotes,            ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@practiceOfficeVisitResolutionFBQuestionsJSON", SqlDbType.VarChar,  vPracticeOfficeVisitResolutionFBQuestionsJSON,  ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@practiceOfficeVisitResolutionFBAnswersJSON",   SqlDbType.VarChar,  vPracticeOfficeVisitResolutionFBAnswersJSON,    ParameterDirection.Input, -1));

            return Entities.recordOp(connSpedmon
                                      , log
                                      , uInfo
                                      , ""
                                      , "N"
                                      , recID
                                      , opSproc
                                      , ref parms);

        }

        /***************************************************************************
         * editCompletedVisit */
        /**
         * 
         **************************************************************************/
        public static ReturnSaveRecord editCompletedVisit( SqlConnection connSpedmon
                                                          , DetailsLog log
                                                          , UserInfo uInfo
                                                          , string clientID
                                                          , string pracID
                                                          , string visitStartDate
                                                          , string visitStartTime
                                                          , string visitEndDate
                                                          , string visitEndTime
                                                          , string practiceOfficeVisitResolutionID
                                                          , string practiceOfficeVisitResolutionNotes
                                                          , string practiceOfficeVisitResolutionFBQuestionsJSON
                                                          , string practiceOfficeVisitResolutionFBAnswersJSON
                                                          , string recID )
        {

            var parms = new List<SqlParameter>();

            string opSproc = "PRACTICE_OFFICE_VISITS_EDIT_COMPLETED_VISIT";

            long     vClientID                                      = Validate.reqClientID  (uInfo, clientID);
            long     vPracID                                        = Validate.reqPracID    (uInfo, pracID);
            DateTime vVisitStartDate                                = Validate.reqDate      (visitStartDate,                                @"Invalid visit start date"); 
            TimeSpan vVisitStartTime                                = Validate.reqTime      (visitStartTime,                                @"Invalid visit start time");
            DateTime vVisitEndDate                                  = Validate.reqDate      (visitEndDate,                                  @"Invalid visit end date");
            TimeSpan vVisitEndTime                                  = Validate.reqTime      (visitEndTime,                                  @"Invalid visit end time");
            long     vPracticeOfficeVisitResolutionID               = Validate.reqInteger   (practiceOfficeVisitResolutionID,               @"Invalid visit resolution");
            string   vPracticeOfficeVisitResolutionNotes            = Validate.optString    (practiceOfficeVisitResolutionNotes,            @"Invalid visit resolution note");
            string   vPracticeOfficeVisitResolutionFBQuestionsJSON  = Validate.optString    (practiceOfficeVisitResolutionFBQuestionsJSON,  @"Invalid visit notes question ");
            string   vPracticeOfficeVisitResolutionFBAnswersJSON    = Validate.optString    (practiceOfficeVisitResolutionFBAnswersJSON,    @"Invalid visit notes answer");

            parms.Add(Database.SqlParm("@clientID",                                     SqlDbType.BigInt,  vClientID,                                       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID",                                       SqlDbType.BigInt,  vPracID,                                         ParameterDirection.Input));
            parms.Add(Database.SqlParm("@visitStartDate",                               SqlDbType.Date,    vVisitStartDate,                                 ParameterDirection.Input));
            parms.Add(Database.SqlParm("@visitStartTime",                               SqlDbType.Time,    vVisitStartTime,                                 ParameterDirection.Input));
            parms.Add(Database.SqlParm("@visitEndDate",                                 SqlDbType.Date,    vVisitEndDate,                                   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@visitEndTime",                                 SqlDbType.Time,    vVisitEndTime,                                   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@practiceOfficeVisitResolutionID",              SqlDbType.BigInt,  vPracticeOfficeVisitResolutionID,                ParameterDirection.Input));
            parms.Add(Database.SqlParm("@practiceOfficeVisitResolutionNotes",           SqlDbType.VarChar, vPracticeOfficeVisitResolutionNotes,             ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@practiceOfficeVisitResolutionFBQuestionsJSON", SqlDbType.VarChar, vPracticeOfficeVisitResolutionFBQuestionsJSON,   ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@practiceOfficeVisitResolutionFBAnswersJSON",   SqlDbType.VarChar, vPracticeOfficeVisitResolutionFBAnswersJSON,     ParameterDirection.Input, -1));

            return Entities.recordOp(connSpedmon
                                      , log
                                      , uInfo
                                      , ""
                                      , "N"
                                      , recID
                                      , opSproc
                                      , ref parms);

        }


        /***************************************************************************
         * load */
        /**
         * 
         **************************************************************************/
        public static PracticeOfficeVisit load (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string clientID, string recID)
        { 
          return (PracticeOfficeVisit) Entities.load (connSpedmon, log, uInfo , recID, typeof(PracticeOfficeVisit),
            delegate {
                return PracticeOfficeVisits.view (  connSpedmon
                                                   , log
                                                   , uInfo
                                                   , clientID                                  
                                                   , "" /*groupSvcClassNameID*/
                                                   , "" /*siteID*/
                                                   , "" /*pracID*/
                                                   , "" /*patID*/
                                                   , "" /*completed*/
                                                   , Entities.REC_VIEW_LOAD
                                                   , false /*pageOrTop*/
                                                   , recID
                                                   , null
                                                   , "Y" /* Active */
                                                   , "1" /* Pull from all records */
                                                   , null);
             });
         }
       
        
        /***************************************************************************
         * view */
        /**
         * 
         **************************************************************************/
        protected static ReturnDB view (  SqlConnection connSpedmon
                                        , DetailsLog    log
                                        , UserInfo      uInfo                                        
                                        , string        clientID                                   
                                        , string        groupSvcClassNameID
                                        , string        siteID
                                        , string        pracID
                                        , string        patID
                                        , string        completed
                                        , int           recViewType
                                        , bool          pagedOrTop
                                        , string        idx
                                        , string        canEdit
                                        , string        active
                                        , string        dataSource
                                        , defineCols    dc)
        {
            
            long     vClientID                       = Validate.reqClientID                (uInfo, clientID);
            Object   vGroupSvcClassNameID            = Validate.optStdGroupSvcClassNameID  (uInfo, groupSvcClassNameID);
			Object   vSiteID                         = Validate.optInteger                 (siteID,                         @"Invalid site");
            Object   vPatID                          = Validate.optPatID                   (uInfo, patID);
            Object   vPracID                         = Validate.optInteger                 (pracID,  Messages.INVALID_PRAC_ID); 
            Object   vCompleted                      = Validate.optFlag                    (completed,                      @"Invalid completed value");
            
            string viewUDF = "PRACTICE_OFFICE_VISITS_VIEW (@userID, @userGroup, @userRank, @clientID, @groupSvcClassNameID, @siteID, @patID, @pracID, @completed, @active, @recID)";

            var parms = new List<SqlParameter>();
            
            parms.Add(Database.SqlParm("@clientID",              SqlDbType.BigInt,  vClientID,              ParameterDirection.Input));
            parms.Add(Database.SqlParm("@groupSvcClassNameID",   SqlDbType.BigInt,  vGroupSvcClassNameID,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@siteID",                SqlDbType.BigInt,  vSiteID,                ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID",                 SqlDbType.BigInt,  vPatID,                 ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID",                SqlDbType.BigInt,  vPracID,                ParameterDirection.Input));
            parms.Add(Database.SqlParm("@completed",             SqlDbType.Bit,     vCompleted,             ParameterDirection.Input)); 
                            
            var so = Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
            return so;

        }


        /***************************************************************************
         * viewObjects */
        /**
         ***************************************************************************/
        
        public static ReturnObjects viewObjects (   SqlConnection connSpedmon
                                                   , DetailsLog   log
                                                   , UserInfo     uInfo
                                                   , bool         pageObjectList
                                                   , string       pageOrder
                                                   , string       idx
                                                   , string       clientID                                   
                                                   , string       groupSvcClassNameID
                                                   , string       siteID
                                                   , string       pracID
                                                   , string       patID
                                                   , string       completed
                                                   , string       dataSource )
        {
            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PracticeOfficeVisit.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            var rd = Entities.viewObjects ( connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(PracticeOfficeVisit)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return PracticeOfficeVisits.view (  connSpedmon
                                                                              , log
                                                                              , uInfo
                                                                              , clientID                                   
                                                                              , groupSvcClassNameID
                                                                              , siteID
                                                                              , pracID
                                                                              , patID
                                                                              , completed                                                                              
                                                                              , Entities.REC_VIEW_OBJECTS
                                                                              , pageObjectList
                                                                              , idx
                                                                              , null
                                                                              , "Y" /* Active */
                                                                              , dataSource
                                                                              , dc);
                                          });

            return rd;
        }
        
        /***************************************************************************
         * delete */
        /**
         * 
         **************************************************************************/
        public static ReturnSaveRecord delete(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                          string editDelReason, string validateRec, string recID)
        {

            /*----------------------------
             * Check for required and 
             * optional parameters
             * and validate data integrity
             * of all supplied parameters
             *----------------------------*/

            Object vClientID = Validate.optClientID(uInfo, "");

            /*----------------------------
             * Collect all of the parameters
             * that are specific to this
             * delete method.
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

            /*----------------------------
             * Call base method 
             *----------------------------*/

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "PRACTICE_OFFICE_VISITS_DELETE", ref parms);
        }

        /***************************************************************************
         * viewTbl 
         * 
         * 
         **************************************************************************/
        public static Return viewTbl( SqlConnection connSpedmon
                                    , DetailsLog log
                                    , UserInfo uInfo
                                    , bool pageObjectList
                                    , string pageNumber
                                    , string idx
                                    , string active
                                    , string groupSvcClassNameID
                                    , string clientID
                                    , string completed)
        {
            ReturnDataTable so = new ReturnDataTable();

            /*----------------------------
             * Define our columns and
             * set the page order for
             * paging
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("id");
                ss.addDisplayColumnIfParmValueIsNull("clientName as [Client Name]", "@clientID", true, ref parms);

                ss.addDisplayColumn("patName                             as [Patient]");
                ss.addDisplayColumn("studentID                           as [Student ID]");
                ss.addDisplayColumn("grade                               as [Grade]");
                ss.addDisplayColumn("siteName                            as [Site]");
                ss.addDisplayColumn("practiceOfficeVisitReasonName       as [Reason\nfor\nVisit]");
                ss.addDisplayColumn("patName                             as [Practitioner\nAssigned]");
                ss.addDisplayColumn("checkInDateStr                      as [Check\nIn\nDate]");
                ss.addDisplayColumn("checkInTimeStr                      as [Check\nIn\nTime]");
                ss.addDisplayColumn("visitStartDateStr                   as [Visit\n Start\nDate]");
                ss.addDisplayColumn("visitStartTimeStr                   as [Visit\nStart\nTime]");
                ss.addDisplayColumn("visitEndDateStr                     as [Visit\nEnd\nDate]");
                ss.addDisplayColumn("visitEndTimeStr                     as [Visit\nEnd\nTime]");
                ss.addDisplayColumn("practiceOfficeVisitResolutionName   as [Resolution]");
                ss.addDisplayColumn("visitingTimeStr                     as [Visting\nTime]");
                ss.addDisplayColumn("assignedPracSig                     as [Electronic\nSignature]");

                pageroworder = ss.pageRowOrder();
            };

            /*----------------------------
             * Call base method which
             * handles the rest
             *----------------------------*/

            so = Entities.viewTbl(connSpedmon, log, uInfo, pageObjectList, pageNumber,
              delegate {
                  return PracticeOfficeVisits.view( connSpedmon
                                                    , log
                                                    , uInfo
                                                    , clientID                                   
                                                    , groupSvcClassNameID
                                                    , "" //siteid
                                                    , "" //pracid
                                                    , "" //patid
                                                    , completed
                                                    , Entities.REC_VIEW_TBL
                                                    , pageObjectList
                                                    , idx
                                                    , null
                                                    , "Y" /* Active */
                                                    , "1" //all data
                                                    , dc);
              });

            /*----------------------------
             * Add a title and footer
             *----------------------------*/

            so.tableName = @"Practice Office Visits";
            so.tableFooter = Messages.CONFIDENTIAL;

            /*----------------------------
             * Done
             *----------------------------*/

            return so;
        }

        /***************************************************************************
        * getpracticeofficevisit */
        /**
         * Get Practice Office Entity
         **************************************************************************/

        public static ReturnEntity getpracticeofficevisit(SqlConnection connSpedmon
                                          , DetailsLog log
                                          , UserInfo uInfo
                                          , string clientID
                                          , string recID)
        {
            var so = new ReturnEntity();
            so.entity = PracticeOfficeVisits.load(connSpedmon, log, uInfo, clientID, recID);
            return so;
        }
    }
}