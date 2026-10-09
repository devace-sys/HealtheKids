using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;



using System.Text;


using System.Linq;
using System.Collections.ObjectModel;
using System.Web.UI.WebControls;
using System.Collections;
using System.Collections.Specialized;
using System.Web.Script.Serialization;


using MBA;

namespace Spedmon
{

    enum RmtsMomentPcalReviewStatus
    {
        NOT_REVIEWED = 100
      , REVIEWED = 200
      , POSSIBLE_APPEAL = 300
    }

    public class RmtsMoment : Entity
    {
        public const string DEFAULT_PAGING_ORDER                     = @"clientName asc, QTR_DEFINITION desc, mustCorrectThisMistake DESC, svcrecIsAutoMatched DESC, isMatchedGreen desc, LastName asc, FirstName asc, SampledMoment asc";

        public const string DEFAULT_PAGING_ORDER_2A_ACTIONREQUIRED   = @"rmtsReqState desc, clientName asc, QTR_DEFINITION desc, mustCorrectThisMistake DESC, svcrecIsAutoMatched DESC, isMatchedGreen desc, LastName asc, FirstName asc, SampledMoment asc";


        public long rmtsMomentDataImportID;

        public long clientID;
        public long quarterID;

        public string QTR_DEFINITION;
                      // NOTE: the udf pulls a field named "Quarter" from the [dbo].[RMTS_Moments] table;
                      //       that field is sometimes foreign key, sometimes a descriptive label, and sometimes blank.
                      //       a bit glitchy; pulling the descriptive text from the joined table works better.

        public string Quarter { get { return this.QTR_DEFINITION; } }


        public string Date;

        public DateTime momentDatetime;
        public DateTime momentDate;
        public TimeSpan momentTime;
        public DateTime momentSubmittedDatetime;

        public string clientName;

        public string LEA;
        public string LastName;
        public string FirstName;
        public string JobTitle;
        public string JobClassification;
        public string ActivityCode;
        public string SMAACode16AuditRequired;

        public string LEABOPCode2AAuditRequired;
        public string RelatedToStudentAssessmentIEP_IFSP_CarePlan;

        public string WhoWereYouWith;
        public string WhatWereYouDoing;
        public string WhyWereYouPerformingThisActivity;

        public string ClarifyingQuestion1;
        public string ClarifyingQuestionAnswer1;

        public string ClarifyingQuestion2;
        public string ClarifyingQuestionAnswer2;

        public string CodingComments;

        public long svcRecID;

        public string Patient;

        public bool isComplete;

        public long PracID;
        public long pracUserID;

        public bool respReqNotifSent;

        public bool isMatchedGreen;

        public bool isPreComplete;

        public bool mustCorrectThisMistake;

        public bool hasFiles;

        public int rmtsReqState;

        public int rmtsReqNextStep;

        public bool svcrecIsAutoMatched;


        public long lastModifiedBy;
        public DateTime lastModified;
        public long createdBy;
        public DateTime created;

        public bool matched;
        public DateTime matchedOn;
        public long matchedBy;
        public int matchedToWhat; // matchedToWhat

        public int    pcalReviewStatusCode;
        public string pcalReviewStatusName;
        public string pcalReviewSuggestedActivityCode;
        public string pcalReviewReason;
        public string pcalReviewNotes;

        public string matchingTooltipAction;

        public  string   deferralReason;
        public  string   deferralReasonNotes;

        public  string   deferralDateStrYMD;
        public  string   deferralDateStr;

        public string lastModifiedByStr ;
        public string deferredByStr ;

        public string matchedPracName;
        public string pracUserName;

    }


    public class RmtsMoments : Entities
    {

        public const string SEL_LABEL_MANAGE = "RMTS Moment Service Records";
        public const string URL_MANAGE = "user_all_rmts_moment_service_records_manage.aspx";




        public const string URL_DEFERRALS_MANAGE = "user_all_rmts_moments_manage_deferrals.aspx";

        public const string SEL_LABEL_REVIEW = "RMTS Coding Review";
        public const string URL_REVIEW = "user_all_rmts_moment_pcal_review.aspx";
        public const string MENU_LINK_RMTS_REVIEW = "userallrmtsmomentpcalreview";

        public const string URL_REST_VIEW_RMTS_MOMENTS_BASE = @"api/v1/rmtsmomentsvcrecs";

        public const string URL_REST_VIEW_RMTS_MOMENTS_REQ = @"api/v1/rmtsmomentsreq";

        public const string MENU_LINK_RPT_RMTS_MOMENT_SERVICE_RECORDS = "rptrmtsmomentservicerecords";

        public const string URL_REST_VIEW = @"api/v1/servicerecords";
        public const string URL_SVC_BASE = @"rmts_moments.asmx";
        public const string URL_WEB_REPORT = @"rmts_moments.ashx";

        public const string REPT_NUM_REVIEWS = "2";
        // const string report number used in page-rendered JS on user_all_rmts_moment_pcal_review.aspx;
        // not used in the ASHX codebehind in this deliverable.
        // in the ASHX we are using  if (num == 3){}  else {}  logic.


        public const string REPT_NUM_REVIEWS_FOR_MATCH = "3";

        public const string URL_SVC_SAVE_INLINE = URL_SVC_BASE + @"/saveinline";
        public const string URL_FLAG_UPDATED_RMTS_MATCH = URL_SVC_BASE + @"/sendUpdatedMatch";
        public const string URL_USERMSG_RMTS_REQ = URL_SVC_BASE + @"/msgSave"; 

        public const string URL_SEND_UPDATED_PRAC_ID = URL_SVC_BASE + @"/sendupdatedpracid"; 

        public const string URL_FLAG_COMPLETE = URL_SVC_BASE + @"/sendFlaggedComplete";  

        public const string URL_SEND_UNDO_MATCH = URL_SVC_BASE + @"/sendUndoMatch";


        public const string URL_STATS_MISSING_FOR_CLIENT = URL_SVC_BASE + @"/statsmissingforclient";

        public const string URL_FLAG_DEFERRAL_REASON = URL_SVC_BASE + @"/flagdeferralreason";

        //public const string MSG_RMTS_MOMENT_DOCUMENTED = @"An RMTS moment has been documented";

        public const string MSG_RMTS_MOMENT_DOCUMENTED_COMPLETE = @"An RMTS moment has been documented and marked as complete.";
        // the "marked as complete" option is available only from the RMTS restview scren (for coordinators)
        // where they can fill-in the solid green handshake icon.

        public const string MSG_RMTS_MOMENT_DOCUMENTED_PRAC_RSVP = @"An RMTS moment has been finished and returned by the practitioner for final approval.";

        /***************************************************************************
         * URL_REST_VIEW_RMTS_MOMENTS */
        /**
         *
         **************************************************************************/
        public static string URL_REST_VIEW_RMTS_MOMENTS()
        {
            return MBA.HttpApplication.createLink(RmtsMoments.URL_REST_VIEW_RMTS_MOMENTS_BASE, true);
        }
        public static string URL_REST_VIEW_RMTS_REQS()
        {
            return MBA.HttpApplication.createLink(RmtsMoments.URL_REST_VIEW_RMTS_MOMENTS_REQ, true);
        }

        public static string URL_FLAG_UPDATED_RMTS_MATCH_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(RmtsMoments.URL_FLAG_UPDATED_RMTS_MATCH, true);
        }

        public static string URL_USERMSG_RMTS_REQ_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(RmtsMoments.URL_USERMSG_RMTS_REQ, true);
        }

        public static string URL_SEND_UNDO_MATCH_BASE()
        {
            return MBA.HttpApplication.createLink(URL_SEND_UNDO_MATCH, true);
        }

        public static string URL_FLAG_COMPLETE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_FLAG_COMPLETE, true);
        }

        public static string URL_SEND_UPDATED_PRACID_BASE()
        {
            return MBA.HttpApplication.createLink(URL_SEND_UPDATED_PRAC_ID, true);
        }

        //  TODO: I should have named this const string a little more appropriately;
        //        this "saves" the review, not the original rmts moment record
        public const string URL_SERVICE_SAVE = URL_SVC_BASE + @"/rmtsmomentpcalreview";

        public static string URL_SERVICE_REVIEW_BASE()
        {
          return MBA.HttpApplication.createLink(RmtsMoments.URL_SERVICE_SAVE, true);  // TODO: idk why there's inconsistent naming here.  Not sure where this link is actually rendered, investigate later.
        }



        public static string URL_DEFERRALS_MANAGE_BASE()
        {
            return MBA.HttpApplication.createLink(RmtsMoments.URL_DEFERRALS_MANAGE, true);
        }

        public static string URL_MANAGE_BASE()
        {
            return MBA.HttpApplication.createLink(RmtsMoments.URL_MANAGE, true);
        }

        ///


        public static string URL_FLAG_DEFERRAL_REASON_BASE() 
        {
            return MBA.HttpApplication.createLink(RmtsMoments.URL_FLAG_DEFERRAL_REASON, true);
        }

        //
        public static string URL_REVIEW_BASE()
        {
            return MBA.HttpApplication.createLink(RmtsMoments.URL_REVIEW, true);
        }

        /***************************************************************************
         * URL_WEB_REPORT_BASE */
        /**
         *
         **************************************************************************/
        public static string URL_WEB_REPORT_BASE()
        {
            return MBA.HttpApplication.createLink(RmtsMoments.URL_WEB_REPORT, true);
        }


        /*************************************************************************
         * triStateToBoolStrs */
        /**
         * Converts the incoming tri-state filter value to two bool filters, parsed_deferred
         * and parsed_complete
         * @param  dblfilter_deferred_complete         string 
         * @param  parsed_deferred                     string  out
         * @param  parsed_complete                     string  out
         *
         ***************************************************************************/
        public static void triStateToBoolStrs(string dblfilter_deferred_complete, out string parsed_deferred, out string parsed_complete)
        {
            parsed_deferred = "0";
            parsed_complete = "0";

            // a bit spaghetti-ish; the filter is a tri-state radio,
            // but the underlying UDF requires two params for two bitflags
            // in the WHERE clause.
            // E impossibile non mangiare spaghetti
            if (dblfilter_deferred_complete == "2")
            {

                parsed_deferred = "";

                parsed_complete = "1";
            }
            else if (dblfilter_deferred_complete == "3")
            {

                parsed_complete = "";

                parsed_deferred = "1";
            }

        }
        /*************************************************************************
         * flagDeferralReason */
        /**
         * Flags a record as Deferred.
         * @param  recID                  string - the numeric ID of the RMTS request object
         * @param  deferralReason         string - from prepopulated dropdown
         * @param  deferralReasonNotes    string - from freeform text on web-dialog submission
         * @param  isdeferred             string - "1" or "0"; defer or undefer.  0 blanks-out the existing
         *                                reason, reasonnotes, deferralDate in the database record

         *
         ***************************************************************************/
        public static ReturnSaveRecord flagDeferralReason(SqlConnection connSpedmon
                                                   , DetailsLog log
                                                   , UserInfo uInfo

                                                   , string recid

                                                   , string deferralReason
                                                   , string deferralReasonNotes

                                                   , string clientid
                                                   , string isdeferred
                                                   )
        {

            long       vClientID        =     Validate.reqClientID        (uInfo, clientid);

            //var vDefDate    = Validate.optDate   (deferralDate, "requires valid deferral date");

            var vIsDeferred = Validate.reqFlag(isdeferred, "is deferred?");

            string vDefReason = null, vDefReasonNotes = null;

            if ( vIsDeferred ) {
              vDefReason  = Validate.reqString(deferralReason, "select a reason");

              vDefReasonNotes = Validate.reqString(deferralReasonNotes, "enter a reason");
            }


            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID",    SqlDbType.BigInt,      vClientID,    ParameterDirection.Input));

            parms.Add(Database.SqlParm("@deferralReason",    SqlDbType.VarChar, vDefReason,             ParameterDirection.Input, 200));
            //parms.Add(Database.SqlParm("@deferralDate",             SqlDbType.Date, vDefDate,          ParameterDirection.Input));

            parms.Add(Database.SqlParm("@deferralReasonNotes", SqlDbType.VarChar, vDefReasonNotes, ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@flagDeferred", SqlDbType.Bit, vIsDeferred, ParameterDirection.Input));

            return Entities.save(connSpedmon
                                , log
                                , uInfo
                                , "2" // saveType
                                , @"N"
                                , @""
                                , recid
                                , "RMTS_MOMENT_FLAG_DEFERRALREASON"
                                , Messages.DUP_SVC_REC
                                , ref parms,
              delegate ()
              { });
        }



        /*************************************************************************
         * generateLEACoordFollowupMsg */
        /**
         * Populates a notification with a finger navlink into the notification widget;
         * looks up and from the database, and includes a description of matched service record,
         * and a list of all uploaded files.
         * Optionally sends an email to the recipients' email address(es) on file.
         *
         * @param  recID             string - the numeric ID of the RMTS request object
         * @param  statusInfo        string - message string to be prepended.

         *
         ***************************************************************************/
        public static string generateLEACoordFollowupMsg(SqlConnection connSpedmon
                                           , DetailsLog log
                                           , UserInfo uInfo
                                           , string recID
                                           , string clientID
                                           , string statusInfo )
        {
            //var clientID = Validate.reqClientID(  uInfo , "");


            var sb = new StringBuilder(statusInfo);


            var moment = RmtsMoments.load(connSpedmon
                                           , log
                                           , uInfo
                                           , recID);

            sb.Append("\n--------------\n");

            sb.Append( moment.momentDatetime.ToString() );

            sb.Append("\nWhat Were You Doing?\n");

            sb.Append(moment.WhatWereYouDoing);

            sb.Append("\nWhy Were You Doing This?\n");

            sb.Append(moment.WhyWereYouPerformingThisActivity);


            //long matchedID;
            if (
                (  moment.svcRecID > 0 )
            )
            {

                try
                {
                    var match = ServiceRecords.load(connSpedmon
                                             , log
                                             , uInfo
                                             , moment.svcRecID.ToString() );

                    sb.Append("\n--------------\n");

                    sb.Append("Matched Service Record Information:\n");

                    sb.Append(match.svcName);
                    sb.Append("\n  Patient Name: " + match.patName + '\n');

                    if ( !(Util.IsNullOrEmpty(match.startTimeStrHHMM))  && !(Util.IsNullOrEmpty(match.endTimeStrHHMM)))
                      sb.Append("  Start / End:" + match.startTimeStrHHMM + " - " + match.endTimeStrHHMM + '\n');

                    sb.Append("  Num Minutes: " + match.numMins + '\n');
                    sb.Append("  For IEP/IFSP? " + match.isIFSPorIEPStr + '\n');
                    sb.Append("  Plan Type: " + match.planTypeSelectionName + '\n');
                    sb.Append("  Via Telehealth? " + match.viaTelehealthStr + '\n');
                }
                catch (Exception e) { }

            }

            try
            {
                var files = StoredFiles.viewList(connSpedmon
                                               , log
                                               , uInfo
                                               , clientID.ToString()
                                               , "" //pracID
                                               , "" //patID
                                               , recID // referencedEntityID
                                               , "1" // active
                                               );
                if (files.Count() > 0)
                {
                    sb.Append("\n--------------\n");

                    sb.Append("Uploaded Files:\n");

                    foreach (var f_i in files)
                    {
                        sb.Append("  " + f_i.fileName + ' ' + f_i.ourFileName + " - " + f_i.fileSizeHuman + '\n');
                    }
                }
            }
            catch (Exception e) { }

            return sb.ToString();

        }

        /***************************************************************************
         * load */
        /**
         * Loads a single RMTS moment
         *
         * Note: The view is responsible for enforcing clientID
         *
         * @param  connSpedmon     Spedmon database connection object
         * @param  log             Logging object
         * @param  recID           Moment record id
         * @return                 ReturnEntity
         ***************************************************************************/

        public static RmtsMoment load(SqlConnection connSpedmon
                                           , DetailsLog log
                                           , UserInfo uInfo
                                           , string recID)
        {
            return (RmtsMoment)Entities.load(connSpedmon
                                                  , log
                                                  , uInfo
                                                  , recID
                                                  , typeof(RmtsMoment)
                                                  , delegate
                                                  {
                                                      return RmtsMoments.view(
                                         connSpedmon
                                       , log
                                       , uInfo
                                       , Entities.REC_VIEW_LOAD
                                       , false
                                       , recID
                                       , ""
                                       , ""
                                       , ""
                                       , ""
                                       , ""
                                       , ""
                                       , ""
                                       , ""
                                       , ""
                                       , ""
                                       , ""

                                       , "" //

                                       , null);
                                                  });

        }

        public static ReturnSaveRecord RMTS_UploadXLSJson(SqlConnection connSpedmon
                                                   , DetailsLog log
                                                   , UserInfo uInfo
                                                   , string clientID
                                                   , string notes
                                                   //, string saveType
                                                   , string fyquarterid2
                                                   )
        {

            long vClientID = Validate.reqClientID(uInfo, clientID);
            string vNotes = Validate.reqString(notes, "no data received");

            Object vQuarterID = Validate.optInteger(fyquarterid2, "invalid quarter selected");

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@notes", SqlDbType.VarChar, vNotes, ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@quarterID", SqlDbType.Int, vQuarterID, ParameterDirection.Input));

            return Entities.save(connSpedmon
                                , log
                                , uInfo
                                , "1" // saveType
                                , @"N"
                                , @""
                                , "" //recID
                                , "RMTS_UploadXLSJson"
                                , Messages.DUP_SVC_REC
                                , ref parms,
              delegate ()
              { });
        }


        public static ReturnSaveRecord RMTS_LaunchAutoMatch(SqlConnection connSpedmon
                                                   , DetailsLog log
                                                   , UserInfo uInfo
                                                   , string clientID
                                                   //, string saveType
                                                   )
        {

            long vClientID = Validate.reqClientID(uInfo, clientID);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@quarterID", SqlDbType.Int, null, ParameterDirection.Input));


            return Entities.save(connSpedmon
                                , log
                                , uInfo
                                , "1" // saveType
                                , @"N"
                                , @""
                                , "" //recID
                                , "RMTS_LaunchAutoMatch"
                                , Messages.DUP_SVC_REC
                                , ref parms,
              delegate ()
              { });
        }

        public static ReturnSaveRecord sendUpdatedMatch(SqlConnection connSpedmon
                                                   , SqlConnection connUsers
                                                   , DetailsLog log
                                                   , UserInfo uInfo

                                                   , string clientID

                                                   , string rmtsReqID
                                                   , string svcrecID
                                                   //,string uploadedRptType
                                                   )
        {

            long vClientID = Validate.reqClientID        (uInfo, clientID);

            Object vRmtsReqID = Validate.reqInteger(rmtsReqID, "requires RMTS reqID");

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@rmtsReqID", SqlDbType.BigInt, vRmtsReqID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@uploadedRptType", SqlDbType.BigInt, "15", ParameterDirection.Input));

            if (uInfo.userPracID == 0)
                parms.Add(Database.SqlParm("@isPrac", SqlDbType.Bit, 0, ParameterDirection.Input));
            else
                parms.Add(Database.SqlParm("@isPrac", SqlDbType.Bit, 1, ParameterDirection.Input));

            var r = Entities.save(connSpedmon
                                , log
                                , uInfo
                                , "1" // saveType
                                , @"N"
                                , @""
                                , svcrecID //recID
                                , "RMTS_MOMENT_MATCH_SERVICE_RECORD"
                                , Messages.DUP_SVC_REC
                                , ref parms,
              delegate ()
              { });

            // a notification will no longer be sent when a practitioner selects a service
            // record with a clock icon, because a "Finish and Send" button has been added.
            // a notification will be sent when that button is clicked.

            //if (uInfo.userRoleID == 5)  return r; // no need to notify an LEA coordinator if the action was performed by an LEA coordinator
            /*
            if (r.message == "Success")
            {
                var uV = Users.view(
                  connUsers, log, uInfo, Entities.REC_VIEW_ALL, true, "", "", "", uInfo.userClientIDStr // FIX
                  , "5", null, null, null, "", null);
                if (uV.hasRecords)
                {
                    var u_i = Database.convertRecords(uV.records, typeof(User));
                    foreach (User u_ix in u_i)
                    {

                        MBA.UserMessages.saveWNav(
                          connUsers, log, uInfo,
                          Constants.APP_NAME,
                          u_ix.userIDInt.ToString(),
                          MSG_RMTS_MOMENT_DOCUMENTED,

                          generateLEACoordFollowupMsg(connSpedmon
                                           , log
                                           , uInfo
                                           , rmtsReqID
                                           , MSG_RMTS_MOMENT_DOCUMENTED)
                          ,

                          "0", //sendEmail

                          "0","",

                          "1",
                          RmtsMoments.URL_MANAGE,
                          ""

                       );
                    }
                }
                else
                {
                    throw new Exception("problem");  // handle error condition if we cannot find the coordinator to notify
                }
            }
            */

            return r;

        }

        public static ReturnSaveRecord sendUndoMatch(SqlConnection connSpedmon
                                                   , DetailsLog log
                                                   , UserInfo uInfo

                                                   , string rmtsReqID
                                                   //,string uploadedRptType
                                                   , string clientID
                                                   )
        {

            long       vClientID        = Validate.reqClientID(uInfo, clientID);

            Object vRmtsReqID = Validate.reqInteger(rmtsReqID, "requires RMTS reqID");

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID",          SqlDbType.Int,      vClientID,    ParameterDirection.Input));

            //parms.Add(Database.SqlParm("@rmtsReqID",             SqlDbType.BigInt, vRmtsReqID,             ParameterDirection.Input));
            //parms.Add(Database.SqlParm("@uploadedRptType",             SqlDbType.BigInt,  "15",             ParameterDirection.Input));

            return Entities.save(connSpedmon
                                , log
                                , uInfo
                                , "1" // saveType
                                , @"N"
                                , @""
                                , rmtsReqID //recID
                                , "RMTS_UNDO_AUDITMATCH_SVCREC"
                                , Messages.DUP_SVC_REC
                                , ref parms,
              delegate ()
              { });
        }

        public static ReturnSaveRecord sendFlaggedIncomplete(SqlConnection connSpedmon
                                                   , DetailsLog log
                                                   , UserInfo uInfo

                                                   , string rmtsReqID
                                                   //,string uploadedRptType
                                                   )
        {

            Object vRmtsReqID = Validate.reqInteger(rmtsReqID, "requires RMTS reqID");

            List<SqlParameter> parms = new List<SqlParameter>();

            return Entities.save(connSpedmon
                                , log
                                , uInfo
                                , "1" // saveType
                                , @"N"
                                , @""
                                , rmtsReqID //recID
                                , "RMTS_MOMENT_FLAG_INCOMPLETE"
                                , Messages.DUP_SVC_REC
                                , ref parms,
              delegate ()
              { });
        }


        /*************************************************************************
         * sendUpdatedPracID */
        /**
         * Updates the pracID assocd with an RMTS moment; useful if an uploaded row
         * fails to automatch to a practitioner, such as, with extra notes added in the name
         * fields
         ***************************************************************************/
        public static ReturnSaveRecord sendUpdatedPracID(SqlConnection connSpedmon
                                                   , DetailsLog log
                                                   , UserInfo uInfo

                                                   , string rmts_mmt_id
                                                   , string clientid
                                                   , string pracid
                                                   )
        {

            Object vRmtsReqID = Validate.reqInteger(rmts_mmt_id, "requires RMTS reqID");

            Object vClientID =  Validate.reqClientID(uInfo, clientid );
            Object vPracID   =  Validate.reqPracID (uInfo, pracid);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID" ,  SqlDbType.Int,  vClientID,  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID"   ,  SqlDbType.Int,  vPracID,    ParameterDirection.Input));


            return Entities.save(connSpedmon
                                , log
                                , uInfo
                                , "1" // saveType
                                , @"N"
                                , @""
                                , rmts_mmt_id //recID
                                , "RMTS_MOMENT_EDIT_PRAC_SEL"
                                , Messages.DUP_SVC_REC
                                , ref parms,
              delegate ()
              { });
        }

        public static ReturnSaveRecord sendFlaggedPcalReview(
                                              SqlConnection dbConnApp
                                            , DetailsLog log
                                            , UserInfo uInfo

                                            , string rmtsMomentID
                                            , string pcalReviewSstatus
                                            , string suggestedActivityCode
                                            , string reason
                                            , string notes)
        {

            List<SqlParameter> parms = new List<SqlParameter>();

            Object vPcalReviewSstatus = MBA.Validate.reqInteger(pcalReviewSstatus, "review status code?");

            parms.Add(Database.SqlParm("@pcalReviewStatus",                SqlDbType.Int, vPcalReviewSstatus, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pcalReviewSuggestedActivityCode", SqlDbType.VarChar, suggestedActivityCode, ParameterDirection.Input, -1) );

            parms.Add(Database.SqlParm("@pcalReviewReason", SqlDbType.VarChar, reason, ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@pcalReviewNotes",                 SqlDbType.VarChar, notes, ParameterDirection.Input, -1) );

            return Entities.save(dbConnApp
                                , log
                                , uInfo
                                , "1" // saveType
                                , @"N"
                                , @""
                                , rmtsMomentID //recID
                                , "RMTS_MOMENT_REVIEW"
                                , Messages.DUP_SVC_REC
                                , ref parms,
              delegate ()
              { });
        }

        public static ReturnSaveRecord sendFlaggedComplete(SqlConnection connSpedmon, SqlConnection connUsers
                                                   , DetailsLog log
                                                   , UserInfo uInfo

                                                   , string rmtsReqID
                                                   , string clientid
                                                   //,string uploadedRptType
                                                   )
        {

            //long       vClientID        = uInfo.userClientID; //Validate.reqClientID        (uInfo, clientID);

            Object vRmtsReqID = Validate.reqInteger(rmtsReqID, "requires RMTS reqID");

            var vCliID = Validate.reqClientID(uInfo, clientid);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(
                Database.SqlParm("@environmentID", SqlDbType.Int, Constants.STORED_FILES_APP_ENVIRONMENT, ParameterDirection.Input)
            );

            parms.Add(
                Database.SqlParm("@clientID", SqlDbType.BigInt, vCliID, ParameterDirection.Input)
            );

            //parms.Add(Database.SqlParm("@clientID",          SqlDbType.Int,      vClientID,    ParameterDirection.Input));

            //parms.Add(Database.SqlParm("@rmtsReqID",             SqlDbType.BigInt, vRmtsReqID,             ParameterDirection.Input));
            //parms.Add(Database.SqlParm("@uploadedRptType",             SqlDbType.BigInt,  "15",             ParameterDirection.Input));

            var r = Entities.save(connSpedmon
                                , log
                                , uInfo
                                , "1" // saveType
                                , @"N"
                                , @""
                                , rmtsReqID //recID
                                , "RMTS_MOMENT_FLAG_COMPLETE"
                                , Messages.DUP_SVC_REC
                                , ref parms,
              delegate ()
              { });

            //if (uInfo.userRoleID == 5)  return r; // no need to notify an LEA coordinator if the action was performed by an LEA coordinator

            if (r.message == "Success")
            {
                var uV = Users.view(connUsers, log, uInfo, Entities.REC_VIEW_ALL, true, "", "", "", vCliID.ToString() , "5", null, null, null, "", null);
                if (uV.hasRecords)
                {
                    var u_i = Database.convertRecords(uV.records, typeof(User));
                    foreach (User u_ix in u_i)
                    {

                        MBA.UserMessages.saveWNav(
                          connUsers, log, uInfo,
                          Constants.APP_NAME,
                          u_ix.userIDInt.ToString(),
                         MSG_RMTS_MOMENT_DOCUMENTED_COMPLETE,

                         generateLEACoordFollowupMsg(connSpedmon
                                           , log
                                           , uInfo
                                           , rmtsReqID
                                           , vCliID.ToString()
                                           , MSG_RMTS_MOMENT_DOCUMENTED_COMPLETE)
                          ,

                          "0" , //sendEmail

                          "0","",

                          "1",
                          RmtsMoments.URL_MANAGE,
                          ""


                       );
                    }
                }
                else
                {
                    var e = new Exception("problem sending notification to LEA Coordinator; contact server admin for diagnostics if problem continues");  // handle error condition if we cannot find the coordinator to notify
                    throw e;
                }
            }

            return r;
        }

        /*************************************************************************
         * sendPracRsvpComplete */
        /**
         * Creates automated, pre-filled comfirmation (completed) notification for LEA coordinators
         * sent from prac user account; triggered by green button in prac's notification widget
         *
         * @param  rmtsReqID               string - the numeric id of the RMTS request, as a string

         *
         ***************************************************************************/

        public static ReturnSaveRecord sendPracRsvpComplete(SqlConnection connSpedmon, SqlConnection connUsers
                                                   , DetailsLog log
                                                   , UserInfo uInfo

                                                   , string rmtsReqID
                                                   //,string uploadedRptType
                                                   )
        {

            var r = new ReturnSaveRecord();
            var uV = Users.view(connUsers, log, uInfo, Entities.REC_VIEW_ALL, true, "", "", "", uInfo.userClientIDStr /* FIX */ , "5", null, null, null, "", null);
            if (uV.hasRecords)
            {
                var u_i = Database.convertRecords(uV.records, typeof(User));
                foreach (User u_ix in u_i)
                {

                    MBA.UserMessages.saveWNav(
                        connUsers, log, uInfo,
                        Constants.APP_NAME,
                        u_ix.userIDInt.ToString(),
                        MSG_RMTS_MOMENT_DOCUMENTED_PRAC_RSVP ,

                        generateLEACoordFollowupMsg( connSpedmon
                                           , log
                                           , uInfo
                                           , rmtsReqID
                                           , uInfo.userClientIDStr
                                           , MSG_RMTS_MOMENT_DOCUMENTED_PRAC_RSVP)
                         ,

                        "0" , //sendEmail

                        "0","",

                        "1",
                        RmtsMoments.URL_MANAGE,
                        "" // "pracid=" + uInfo.userPracIDStr   //TODO

                    );
                }
            }
            else
            {
                throw new Exception("problem");  // handle error condition if we cannot find the coordinator to notify
            }
            return r;

        }

        public static ReturnSaveRecord flagMsgSent(SqlConnection connSpedmon //SqlConnection connUsers
                                                       , DetailsLog log
                                                       , UserInfo uInfo

                                                       , string rmtsReqID
                                                       //,string uploadedRptType
                                                       )
        {

            Object vRmtsReqID = Validate.reqInteger(rmtsReqID, "requires RMTS reqID");

            List<SqlParameter> parms = new List<SqlParameter>();

            var r = Entities.save(connSpedmon
                                , log
                                , uInfo
                                , "1" // saveType
                                , @"N"
                                , @""
                                , rmtsReqID //recID
                                , "RMTS_MOMENT_FLAG_MSGSENT"
                                , Messages.DUP_SVC_REC
                                , ref parms,
              delegate ()
              { });

            //if (uInfo.userRoleID == 5)  return r; // no need to notify an LEA coordinator if the action was performed by an LEA coordinator

            return r;
        }

        // NOTE: the orig view() method was called from RmtsMoments.load() and nowhere else.


        /***************************************************************************
         * view */
        /**
         *
         **************************************************************************/
        public static ReturnDB view(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo
                                        , int recViewType
                                        , bool paged
                                        , string pageNumber
                                        , string pagesize
                                        , string canEdit
                                        , string active
                                        , string clientid

                                        , string pracid  //


                                        , string quarterID

									    , string  fyID
									    , string  quarterNum

                                        , string activity_code
                                        , string matched
                                        , string isComplete
                                        , string pcalReviewStatusCode


                                        , defineCols dc
                                        //
                                        , string isDeferred = null  
                                                                   
         )
        {

            Object vClientID = Validate.optClientID(uInfo, clientid);
            Object vQuarterID = Validate.optInteger(quarterID, "error: quarter ID");

            //
            Object vPracID = Validate.optInteger(pracid, "error: prac ID");  // TODO: does this need a different/better validate function?
            //

            Object vFyID = Validate.optInteger(fyID, "error: quarter ID");
            Object vQuarterNum = Validate.optInteger(quarterNum, "error: quarter ID");


            Object vActivityCode = Validate.optString(activity_code);

            Object vMatched = Validate.optFlag(matched, "matched?");

            Object vIsComplete = Validate.optFlag(isComplete, "is complete?");

            Object vPcalReviewStatusCode = Validate.optInteger(pcalReviewStatusCode, "search by status code?");

            Object vIsDeferred = Validate.optFlag( isDeferred, "is deferred?");


            List<SqlParameter> prms = new List<SqlParameter>();

            prms.Add(
              Database.SqlParm("@environmentID", SqlDbType.Int, Constants.STORED_FILES_APP_ENVIRONMENT, ParameterDirection.Input)
            );

            prms.Add(Database.SqlParm("@fyquarterid", SqlDbType.BigInt, vQuarterID, ParameterDirection.Input));

            prms.Add(Database.SqlParm("@fyID", SqlDbType.BigInt, vFyID, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@quarterNum", SqlDbType.BigInt, vQuarterNum, ParameterDirection.Input));


            prms.Add(Database.SqlParm("@activityCode", SqlDbType.VarChar, vActivityCode, ParameterDirection.Input));

            prms.Add(Database.SqlParm("@matched", SqlDbType.Bit, vMatched, ParameterDirection.Input));

            prms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));

            //
            prms.Add(Database.SqlParm("@pracID", SqlDbType.BigInt, vPracID, ParameterDirection.Input));
            //


            prms.Add(Database.SqlParm("@isComplete", SqlDbType.Bit, vIsComplete, ParameterDirection.Input));

            prms.Add(Database.SqlParm("@pcalReviewStatusCode", SqlDbType.Int, vPcalReviewStatusCode, ParameterDirection.Input));

            prms.Add(Database.SqlParm("@isDeferred", SqlDbType.Bit, vIsDeferred, ParameterDirection.Input));

            //
            string viewUDF = "dbo.RPT_RMTS_MOMENTS_VIEW (@userID, @userGroup, @userRank, @recid, @environmentID, @fyquarterid, @fyID, @quarterNum, @activityCode, @matched, @clientID, @pracID, @isComplete, @pcalReviewStatusCode, @isDeferred)";
            //

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/
            return Entities.view(connSpedmon, log, uInfo, recViewType, paged, pagesize, pageNumber, canEdit, active, viewUDF, ref prms, null, dc);
        }

        /***************************************************************************
         * viewObjects
         *
         * Returns a list of service record RMTS moment objects
         *
         ***************************************************************************/

        public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                  , DetailsLog log
                                                  , UserInfo uInfo
                                                  , bool pageObjectList
                                                  , string pageOrder
                                                  , string idx
                                                  , string pagesize
                                                  , string active
                                                  , string clientid

                                                  //
                                                  , string pracid  //
                                                  //

                                                  , string quarterid

                                                  , string fyID
                                                  , string quarterNum

                                                  , string activity_code
                                                  , string matched
                                                  , string isComplete
                                                  , string reviewstatuscodeselection

                                                  , string filter_for_deferred  ///

            )

        {

            /* Default page order */

            /* Define columns delegate is used to specify columns and page order
             * We pass in the desired page row order here */
            if (String.IsNullOrWhiteSpace(pageOrder))
                pageOrder = RmtsMoment.DEFAULT_PAGING_ORDER;

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(RmtsMoment)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return RmtsMoments.view(connSpedmon
                                                                           , log
                                                                           , uInfo
                                                                           , Entities.REC_VIEW_OBJECTS
                                                                           , pageObjectList
                                                                           , idx
                                                                           , pagesize
                                                                           , "" /* Can edit */
                                                                           , active
                                                                           , clientid

                                                                           //
                                                                           , pracid   //
                                                                           //


                                                                           , quarterid

                                                                           , fyID
                                                                           , quarterNum

                                                                           , activity_code
                                                                           , matched
                                                                           , isComplete
                                                                           , reviewstatuscodeselection
                                                                           , dc
                                                                           , filter_for_deferred);
                                          });

        }

        public static ReturnDataTable viewTbl(
             SqlConnection connSpedmon
            , DetailsLog log
            , UserInfo uInfo
            , bool paged
            , string pageNumber
            , string clientid

            //
            , string pracid  //
            //


            , string quarterID

            , string fyID
            , string quarterNum

            , string activity_code
            , string matched
            , string isComplete
            , string pcalReviewStatusCode
            , string canEdit
            , string active
            , defineCols dc = null
            , string filter_for_deferred = null)
        {


            /*----------------------------
             * Define our columns and
             * set the page order for
             * paging
             *----------------------------*/
            if (dc == null)
              dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
              {


                ss.addDisplayColumn("clientName as LEA", true);

                ss.addDisplayColumn("QTR_DEFINITION as Quarter", true);

                // NOTE: the udf pulls a field named "Quarter" from the [dbo].[RMTS_Moments] table;
                //       that field is sometimes foreign key, sometimes a descriptive label, and sometimes blank.
                //       a bit glitchy; pulling the descriptive text from the joined table works better.

                ss.addDisplayColumn("[pcalReviewStatusName] as [RMTS Coding Entry Reviewed?]");
                ss.addDisplayColumn("[pcalReviewSuggestedActivityCode] as [Suggested Activity Code]");
                ss.addDisplayColumn("[pcalReviewReason] as [Review Reason]");
                ss.addDisplayColumn("[pcalReviewNotes] as [Additional Notes]");

                ss.addDisplayColumn("LastName as [Last Name]");
                ss.addDisplayColumn("FirstName as [First Name]");
                ss.addDisplayColumn("JobTitle  as [Job Title]");
                ss.addDisplayColumn("JobClassification");
                ss.addDisplayColumn("pracUserID");

                ss.addDisplayColumn("[momentDatetime]");

                ss.addDisplayColumn("[WhatWereYouDoing] as [What Were You Doing?]");
                ss.addDisplayColumn("[WhoWereYouWith] as [Who Were You With?]");
                ss.addDisplayColumn("[RelatedToStudentAssessmentIEP_IFSP_CarePlan] as [Related To Student Assessment IEP/IFSP Care Plan?]");

                ss.addDisplayColumn("[ClarifyingQuestion1] as [Clarifying Question 1]");
                ss.addDisplayColumn("ClarifyingQuestionAnswer1 as [Clarifying Question 1 Answer]");

                ss.addDisplayColumn("[ClarifyingQuestion2] as [Clarifying Question 2]");
                ss.addDisplayColumn("ClarifyingQuestionAnswer2 as [Clarifying Question 2 Answer]");

                ss.addDisplayColumn("[ActivityCode] as [Activity Code]");
                ss.addDisplayColumn("[CodingComments] as [Coding Comments]");

                ss.addDisplayColumn("[SMAACode16AuditRequired] as [SMAA Code16 Audit Required?]");
                ss.addDisplayColumn("[LEABOPCode2AAuditRequired] as [LEA BOP Code2A Audit Required?]");

                ss.addDisplayColumn("[svcRecID]");
                ss.addDisplayColumn("[Patient] as [Patient From Service Record]");

                ss.addDisplayColumn("svcrecIsAutoMatched as [RMTS Service Record Automatically Matched?]");
                ss.addDisplayColumn("mustCorrectThisMistake as [RMTS Service Record Matching Flagged as Mistaken?]");
                ss.addDisplayColumn("respReqNotifSent as [Notification Requesting Supported Documentation Sent To Practitioner?]");
                ss.addDisplayColumn("[hasFiles] as [Supporting Documentation Files Uploaded for Moment?]");

                pageroworder = ss.pageRowOrder();

              };


            string tableName = "";

            tableName += @"RMTS Moments";


            if (!Util.IsNullOrEmpty(clientid))
            {
                Client c = Clients.load(connSpedmon, log, uInfo, clientid);
                tableName += " - " + c.name ;
            }

            if (!Util.IsNullOrEmpty(quarterNum)  && !Util.IsNullOrEmpty(fyID))
            {
                CompanyFiscalQuarter cfq = CompanyFiscalQuarters.load(connSpedmon, log, uInfo, "1", null, fyID, quarterNum, null);
                tableName = tableName + " - " + cfq.quarterStartDateStrYMD + " to " + cfq.quarterEndDateStrYMD;
            }

            if ( !Util.IsNullOrEmpty(quarterID))
            {
                CompanyFiscalQuarter cfq  =  CompanyFiscalQuarters.loadByFqID(connSpedmon, log, uInfo, "1", quarterID);
                tableName = tableName + " - " + cfq.quarterStartDateStrYMD + " to " + cfq.quarterEndDateStrYMD;
            }

            if (!Util.IsNullOrEmpty( pcalReviewStatusCode))
            {
                var fReview = Validate.reqInteger(pcalReviewStatusCode, "review status?");
                string strReview = "";
                switch (fReview) {
                  case (int) RmtsMomentPcalReviewStatus.NOT_REVIEWED:
                    strReview = " - not reviewed";
                    break;
                  case (int)RmtsMomentPcalReviewStatus.REVIEWED:
                        strReview = " - reviewed";
                        break;
                  case (int)RmtsMomentPcalReviewStatus.POSSIBLE_APPEAL:
                        strReview = " - possible appeal";
                        break;
                }
                tableName = tableName + strReview;
            }

            if (!Util.IsNullOrEmpty( activity_code ))
            {
                tableName = tableName + " - " + activity_code;
            }

            if (!Util.IsNullOrEmpty( matched ))
            {
                var fMatched = Validate.reqFlag( matched, "matched?" ) ;
                tableName = tableName + " - " + ( fMatched ? "matched" : "not matched" ) ;
            }

            if (!Util.IsNullOrEmpty( isComplete ))
            {
                var fComplete = Validate.reqFlag(isComplete, "is complete?");
                tableName = tableName + " - " + ( fComplete ? "complete" : "not complete");
            }


            string tableFooter = Messages.CONFIDENTIAL;

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.viewTbl(connSpedmon
                , log
                , uInfo
                , paged
                , pageNumber
                , delegate
                {
              return RmtsMoments.view(connSpedmon
                                    , log
                                    , uInfo
                                    , Entities.REC_VIEW_RPT //Entities.REC_VIEW_OBJECTS
                                    , paged
                                    , pageNumber
                                    , Rules.VIEW_TBL_PAGE_SIZE.ToString()
                                    , canEdit
                                    , active
                                    , clientid

                                    //
                                    , pracid  //
                                    //

                                    , quarterID

                                    , fyID
                                    , quarterNum

                                    , activity_code
                                    , matched
                                    , isComplete
                                    , pcalReviewStatusCode
                                    , dc
                                    , filter_for_deferred);

                }
              , tableName
              , tableFooter
              );
        }

        public static ReturnSaveRecord msgSave(SqlConnection connUser
                                       , DetailsLog log
                                       , UserInfo uInfo
                                       , string recipientUserIDsStr
                                       , string subject
                                       , string body
                                       , string sendEmail
                                       , string isReply
                                       , string previousMsgID
                                       , string okToShow
                                       , string hasRead
                                       , string respPromptOptions // int; bitwise arith
                                       , string respPromptOptionsJSON

                                       //, string promptUserToGotoURL
                                       //, string gotoURL

                                       // TODO: implement the RMTS closed-loop notifications and callbacks
                                       // using these params instead of bitwise logic, 8 and 4

                                       , string active
                                       , string saveType
                                       , string recID
                                       , SqlConnection connSpedmon = null
            )

        {
            // NOTE: validating against a wrong/malicious recID for the user's clientID is not a priority here,
            //       because even if somebody got a "wrong" email they would be locked-out and unable to nav the link
            var rrr = MBA.UserMessages.save(
                connUser, log, uInfo, Constants.APP_NAME, recipientUserIDsStr,
                subject, body, sendEmail, isReply, previousMsgID, okToShow, hasRead,
                respPromptOptions, respPromptOptionsJSON,
                //promptUserToGotoURL, gotoURL,
                active, saveType, "0", "", recID
            );
            //TODO: later on, implement the sendEmail checkbox on the RMTS thumbs-up match screen

            if (rrr.message == "Success")
            {
                if (!(Util.IsNullOrEmpty(respPromptOptionsJSON)))
                {  // TODO: rename to rmtsrespPromptOptionsJSON, all the way up the call stack
                    var p = JSON.dictFromJSONString(respPromptOptionsJSON);
                    string momentID = "";
                    p.TryGetValue("referencedentityid", out momentID);
                    //ServiceRecords.
                    Spedmon.RmtsMoments.flagMsgSent(connSpedmon, log, uInfo, momentID);
                }
            }

            return rrr;
        }


        public static ReturnDataTable viewTblReportForMatchScreen(
             SqlConnection connSpedmon
            , DetailsLog log
            , UserInfo uInfo
            , bool paged
            , string pageNumber
            , string clientid

            , string quarterID

            , string fyID
            , string quarterNum

            , string activity_code
            , string matched
            , string isComplete
            , string pcalReviewStatusCode
            , string canEdit
            , string active
            , string filter_for_deferred )
    {


            /*----------------------------
             * Define our columns and
             * set the page order for
             * paging
             *----------------------------*/
            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {


                ss.addDisplayColumn("clientName as LEA", true);

                ss.addDisplayColumn("QTR_DEFINITION as Quarter", true);

                // NOTE: the udf pulls a field named "Quarter" from the [dbo].[RMTS_Moments] table;
                //       that field is sometimes foreign key, sometimes a descriptive label, and sometimes blank.
                //       a bit glitchy; pulling the descriptive text from the joined table works better.

                ss.addDisplayColumn("[Patient] as [Patient From Service Record]");
                ss.addDisplayColumn("[matchingTooltipAction] as [Action Required?]");

                ss.addDisplayColumn("[hasFiles] as [Supporting Documentation Files Uploaded for Moment?]");
                ss.addDisplayColumn("respReqNotifSent as [Notification Requesting Supported Documentation Sent To Practitioner?]");


                ss.addDisplayColumn("[pcalReviewStatusName] as [RMTS Coding Entry Reviewed?]");
                ss.addDisplayColumn("[pcalReviewSuggestedActivityCode] as [Suggested Activity Code]");
                ss.addDisplayColumn("[pcalReviewReason] as [Review Reason]");
                ss.addDisplayColumn("[pcalReviewNotes] as [Additional Notes]");

                ss.addDisplayColumn("LastName as [Last Name]");
                ss.addDisplayColumn("FirstName as [First Name]");
                ss.addDisplayColumn("JobTitle  as [Job Title]");
                ss.addDisplayColumn("JobClassification as [Job Classification]");
                ss.addDisplayColumn("pracUserID");

                ss.addDisplayColumn("momentDate as [Moment Date]");

                //ss.addDisplayColumn("[momentTime]"); // NOTE: the existing middleware framework seems to lack the ability to render a pure time field

                ss.addDisplayColumn("momentTimeStr as [Moment Time]"); // NOTE: the existing middleware framework seems to lack the ability to render a pure time field


                ss.addDisplayColumn("[WhatWereYouDoing] as [What Were You Doing?]");
                ss.addDisplayColumn("[WhoWereYouWith] as [Who Were You With?]");
                ss.addDisplayColumn("[RelatedToStudentAssessmentIEP_IFSP_CarePlan] as [Related To Student Assessment IEP/IFSP Care Plan?]");

                ss.addDisplayColumn("[ClarifyingQuestion1] as [Clarifying Question 1]");
                ss.addDisplayColumn("ClarifyingQuestionAnswer1 as [Clarifying Question 1 Answer]");

                ss.addDisplayColumn("[ClarifyingQuestion2] as [Clarifying Question 2]");
                ss.addDisplayColumn("ClarifyingQuestionAnswer2 as [Clarifying Question 2 Answer]");

                ss.addDisplayColumn("[ActivityCode] as [Activity Code]");
                ss.addDisplayColumn("[CodingComments] as [Coding Comments]");

                ss.addDisplayColumn("[SMAACode16AuditRequired] as [SMAA Code16 Audit Required?]");
                ss.addDisplayColumn("[LEABOPCode2AAuditRequired] as [LEA BOP Code2A Audit Required?]");

                ss.addDisplayColumn("svcrecIsAutoMatched as [RMTS Service Record Automatically Matched?]");
                ss.addDisplayColumn("mustCorrectThisMistake as [RMTS Service Record Matching Flagged as Mistaken?]");


                pageroworder = ss.pageRowOrder();

            };

        return RmtsMoments.viewTbl(connSpedmon
                              , log
                              , uInfo

                              , paged
                              , pageNumber


                              , clientid

                              //
                              , "" // pracid
                              //

                              , quarterID

                              , fyID
                              , quarterNum

                              , activity_code
                              , matched
                              , isComplete
                              , pcalReviewStatusCode
                              , canEdit
                              , active
                              , dc
                              , filter_for_deferred);

        }

    }

}
