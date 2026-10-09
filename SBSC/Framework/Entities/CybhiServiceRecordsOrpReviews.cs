using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * CybhiServiceRecordsOrpReview */
    /**
     *
     ***************************************************************************/

    public class CybhiServiceRecordsOrpReview
    {
        public const string DEFAULT_PAGING_ORDER = "assignedOn asc";

        public long id;
        public long clientID;
        public long siteID;
        public long renderingPracID;
        public long renderingGroupID;
        public long renderingGroupSvcClassNameID;
        public long svcRecID;
        public long patID;
        public DateTime dos;
        public int numMins;
        public long attendanceSelectionID;
        public string svcNotes;

        public long assignedToPracID;
        public DateTime assignedOn;
        public bool reviewed;

        public DateTime? reviewedOn;
        public long? reviewedByPracID;
        public string reviewedByName;
        public string reviewedByTitle;
        public bool? approved;
        public string notes;

        public string clientName;
        public string siteName;
        public string patName;
        public string ssid;
        public string renderingPracName;
        public string renderingGroupName;
        public string attendanceSelectionName;
        public string svcName;
        public string dosStr;
        public string assignedOnStr;
        public string reviewedOnStr;
        public string assignedPracName;
        public string reviewedStr;
        public string approvedStr;
    }

    /***************************************************************************
     * CybhiServiceRecordsOrpReviews */
    /**
     * Methods to manage CybhiServiceRecordsOrpReviews
     ***************************************************************************/

    public class CybhiServiceRecordsOrpReviews : Entities
    {
        public const string NOTIFICATION_LABEL_REVIEW = @"CYBHI ORP Service Records Review";
        public const string SEL_LABEL_MANAGE          = @"CYBHI ORP Service Records Review";

        public const string URL_REST_VIEW_BASE = @"api/v1/cybhiservicerecordsorpreviews";
        public const string URL_MANAGE_BASE = @"user_all_cybhi_service_records_orp_reviews_manage.aspx";
        public const string MENU_ID_MANAGE = @"managecybhiorpservicerecordsreviewlnk";

        /***************************************************************************
         * URL_MANAGE */
        /**
         *
         **************************************************************************/
        public static string URL_MANAGE()
        {
            return MBA.HttpApplication.createLink(URL_MANAGE_BASE, true);
        }

        /***************************************************************************
         * URL_MANAGE_DETAILS_BY_RENDERING_PRAC */
        /**
         *
         **************************************************************************/
        public static string URL_MANAGE(bool newWindow)
        {
            return MBA.HttpApplication.createLink(URL_MANAGE_BASE
                , true
                , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE));
        }

        public const string URL_SVC_BASE = @"cybhi_service_records_orp_reviews.asmx";
        public const string URL_SVC_ACCEPT_BASE = URL_SVC_BASE + @"/acceptrecinline";
        public const string URL_SVC_ACCEPT_WITH_NOTES_BASE = URL_SVC_BASE + @"/acceptrecwithnotesinline";
        public const string URL_SVC_REJECT_BASE = URL_SVC_BASE + @"/rejectrecinline";
        public const string URL_SVC_ACCEPT_MULTI_BASE = URL_SVC_BASE + @"/acceptrecsinline";

        /***************************************************************************
         * URL_REST_VIEW */
        /**
         *
         **************************************************************************/

        public static string URL_REST_VIEW()
        {
            return MBA.HttpApplication.createLink(URL_REST_VIEW_BASE, true);
        }

        /***************************************************************************
         * URL_SVC_ACCEPT */
        /**
         *
         **************************************************************************/

        public static string URL_SVC_ACCEPT()
        {
            return MBA.HttpApplication.createLink(URL_SVC_ACCEPT_BASE, true);
        }

        /***************************************************************************
         * URL_SVC_ACCEPT_WITH_NOTES */
        /**
         *
         **************************************************************************/

        public static string URL_SVC_ACCEPT_WITH_NOTES()
        {
            return MBA.HttpApplication.createLink(URL_SVC_ACCEPT_WITH_NOTES_BASE, true);
        }

        /***************************************************************************
         * URL_SVC_REJECT */
        /**
         *
         **************************************************************************/

        public static string URL_SVC_REJECT()
        {
            return MBA.HttpApplication.createLink(URL_SVC_REJECT_BASE, true);
        }

        /***************************************************************************
         * URL_SVC_ACCEPT_MULTI */
        /**
         *
         **************************************************************************/

        public static string URL_SVC_ACCEPT_MULTI()
        {
            return MBA.HttpApplication.createLink(URL_SVC_ACCEPT_MULTI_BASE, true);
        }

        /***************************************************************************
         * acceptOrRejectRec */
        /**
         * Not meant to be called directly.
         * Shared method for the various ops
         *
         * @return             ReturnSaveRecord
         ***************************************************************************/

        private static ReturnSaveRecord acceptOrRejectRec(SqlConnection connSpedmon
                                                            , DetailsLog log
                                                            , UserInfo uInfo
                                                            , string clientID
                                                            , string reviewingPracID
                                                            , string notes
                                                            , string sendMessageToRenderingPrac
                                                            , string reviewRecID
                                                            , string validateRec
                                                            , bool approved)
        {

            string opSproc = "CYBHI_SERVICE_RECORDS_ORP_REVIEWS_ACCEPT_OR_REJECT_REC";

            /*----------------------------
             * Validate parameters
             *----------------------------*/

            var vClientID = Validate.reqClientID(uInfo, clientID);
            var vReviewingPracID = Validate.optPracID(uInfo, reviewingPracID);
            var vNotes = Validate.optString(notes, @"Invalid notes");
            var vSendMessageToRenderingPrac = Validate.reqFlag(sendMessageToRenderingPrac, @"Invalid send message option", true);

            /*----------------------------
             * If rejecting and no notes
             * provided dont allow
             *----------------------------*/

            if ((approved == false) && (String.IsNullOrWhiteSpace(vNotes) == true))
            {
                throw new Warning(@"If you are returning for correction, review notes are required");
            }

            /*----------------------------
             * If approving and sending
             * notes and no notes provided
             * dont allow
             *----------------------------*/

            if ((approved == true) && (vSendMessageToRenderingPrac == true) && (String.IsNullOrWhiteSpace(vNotes) == true))
            {
                throw new Warning(@"If you are approving with review notes and sending notes to rendering practitioner, review notes are required");
            }

            /*----------------------------
             * Setup and call op sproc
             *----------------------------*/

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@reviewingPracID", SqlDbType.BigInt, vReviewingPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@sendMessageToRenderingPrac", SqlDbType.Bit, vSendMessageToRenderingPrac, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@notes", SqlDbType.VarChar, vNotes, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@approved", SqlDbType.Bit, approved, ParameterDirection.Input));

            return Entities.recordOp(connSpedmon, log, uInfo, "", validateRec, reviewRecID, opSproc, ref parms);
        }

        /***************************************************************************
         * acceptRec */
        /**
         * @return             ReturnSaveRecord
         ***************************************************************************/

        public static ReturnSaveRecord acceptRec(SqlConnection connSpedmon
                                                    , DetailsLog log
                                                    , UserInfo uInfo
                                                    , string clientID
                                                    , string reviewingPracID
                                                    , string reviewRecID
                                                    , string validateRec)
        {
            return acceptOrRejectRec(connSpedmon, log, uInfo, clientID, reviewingPracID, "", "N", reviewRecID, validateRec, true);
        }

        /***************************************************************************
         * acceptRecWithNotes */
        /**
         * @return             ReturnSaveRecord
         ***************************************************************************/

        public static ReturnSaveRecord acceptRecWithNotes(SqlConnection connSpedmon
                                                            , DetailsLog log
                                                            , UserInfo uInfo
                                                            , string clientID
                                                            , string reviewingPracID
                                                            , string notes
                                                            , string sendMessageToRenderingPrac
                                                            , string reviewRecID
                                                            , string validateRec)
        {
            return acceptOrRejectRec(connSpedmon, log, uInfo, clientID, reviewingPracID, notes, sendMessageToRenderingPrac, reviewRecID, validateRec, true);
        }

        /***************************************************************************
         * rejectRec */
        /**
         * @return             ReturnSaveRecord
         ***************************************************************************/
        public static ReturnSaveRecord rejectRec(SqlConnection connSpedmon
                                                  , DetailsLog log
                                                  , UserInfo uInfo
                                                  , string clientID
                                                  , string reviewingPracID
                                                  , string notes
                                                  , string reviewRecID
                                                  , string validateRec)
        {
            return acceptOrRejectRec(connSpedmon, log, uInfo, clientID, reviewingPracID, notes, "Y", reviewRecID, validateRec, false);
        }

        /***************************************************************************
         * acceptRecs */
        /**
         * @return             ReturnSaveRecord
         ***************************************************************************/

        public static ReturnSaveRecord acceptRecs(SqlConnection connSpedmon
                                                    , DetailsLog log
                                                    , UserInfo uInfo
                                                    , string clientID
                                                    , string reviewingPracID
                                                    , string reviewRecIDs
                                                    , string validateRec)
        {
            var so = new ReturnSaveRecord();
            var vReviewRecIDs = Validate.reqRecIDMulti(reviewRecIDs, Messages.INVALID_RECORD_IDS);
            foreach (var vReviewRecID in vReviewRecIDs)
            {
                string reviewRecID = vReviewRecID.ToString();
                acceptRec(connSpedmon, log, uInfo, clientID, reviewingPracID, reviewRecID, validateRec);
            }
            so.recordID = vReviewRecIDs.Length;
            return so;
        }

        /***************************************************************************
         * doesPracHaveSuperviseeAssignments */
        /**
         *
         * @param  rd              Current request response object
         * @return                 bool
         ***************************************************************************/
        public static bool doesPracHaveSuperviseeAssignments(RequestResponse rd)
        {
            /* User has to be a prac */
            if (rd.wu.pr != null)
            {
                /* If prac has assignments */
                if (rd.wu.pr.pracsAssignedForCybhiOrpSvcRecReview > 0) return true;
                /* Otherwise exit*/
                return false;
            }
            /* Not a prac exit */
            return false;
        }

        /***************************************************************************
         * doesPracHaveServiceRecordsToReview */
        /**
         *
         * @param  rd              Current request response object
         * @return                 bool
         ***************************************************************************/
        public static bool doesPracHaveServiceRecordsToReview(RequestResponse rd)
        {
            /* User has to be a prac with supervisee assignments */
            if (doesPracHaveSuperviseeAssignments(rd))
            {
                /* Services waiting for review */
                if (rd.wu.pr.svcRecsWaitingForReviewCybhiOrp > 0) return true;
                /* Otherwise exit*/
                return false;
            }
            /* Not the case, exit*/
            return false;
        }

        /***************************************************************************
         * userHasAccess */
        /**
         *
         * @param  rd              Current request response object
         * @return                 bool
         ***************************************************************************/
        public static bool userHasAccess(RequestResponse rd)
        {
            if (rd.wu.usr.pcalStaff == true) return true;
            if (doesPracHaveSuperviseeAssignments(rd) == true) return true;
            return false;
        }

        /***************************************************************************
         * view */
        /**
         * @param  clientID    Client ID record (if any)
         * @return             ReturnDB
         ***************************************************************************/

        public static ReturnDB view(SqlConnection connSpedmon
                                     , DetailsLog log
                                     , UserInfo uInfo
                                     , int recViewType
                                     , bool pagedOrTop
                                     , string idx
                                     , string canEdit
                                     , string active
                                     , string clientID
                                     , string siteID
                                     , string reviewingPracID
                                     , string renderingPracID
                                     , string patID
                                     , string dateRange
                                     , string reviewed
                                     , string approved
                                     , defineCols dc)
        {

            /*-------------------------------
             * Validate required and
             * optional parameters
             *------------------------------*/

            var vClientID = Validate.reqClientID(uInfo, clientID);
            var vSiteID = Validate.optInteger(siteID, Messages.INVALID_SITE_ID);
            var vReviewingPracID = Validate.optPracID(uInfo, reviewingPracID);
            var vRenderingPracID = Validate.optInteger(renderingPracID, @"Invalid rendering practitioner");
            var vReviewed = Validate.reqFlag(reviewed, @"Reviewed flag required");
            var vApproved = Validate.optFlag(approved, @"Invalid approval flag", false);
            var vPatID = Validate.optPatID(uInfo, patID);

            /*-------------------------------
             * Split out date range
             *------------------------------*/

            string startDate = "";
            string endDate = "";
            Util.parseDateRange(dateRange, out startDate, out endDate);
            Validate.optStartAndEndDate(startDate, endDate, Messages.INVALID_DATE_RANGE);
            var vStartDate = Validate.optDate(startDate, Messages.INVALID_START_DATE);
            var vEndDate = Validate.optDate(endDate, Messages.INVALID_END_DATE);

            /*-------------------------------
             * Setup database command
             *------------------------------*/

            var parms = new List<SqlParameter>();

            string viewUDF = "dbo.CYBHI_SERVICE_RECORDS_ORP_REVIEWS_VIEW (@userID, @userGroup, @userRank, @clientID, @siteID, @reviewingPracID, @renderingPracID, @patID, @startDate, @endDate, @reviewed, @approved)";

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@siteID", SqlDbType.BigInt, vSiteID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@reviewingPracID", SqlDbType.BigInt, vReviewingPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@renderingPracID", SqlDbType.BigInt, vRenderingPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID", SqlDbType.BigInt, vPatID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@startDate", SqlDbType.DateTime, vStartDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@endDate", SqlDbType.DateTime, vEndDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@reviewed", SqlDbType.Bit, vReviewed, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@approved", SqlDbType.Bit, vApproved, ParameterDirection.Input));

            /*-------------------------------
            * Execute database command
            * and return results in our
            * intermediate structure
            *------------------------------*/

            ReturnDB rd = Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

            return rd;

        }


        /***********************************************************************
          * viewObjects */
        /**
          ***************************************************************************/
        public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                 , DetailsLog log
                                                 , UserInfo uInfo
                                                 , bool pageObjectList
                                                 , string pageOrder
                                                 , string idx
                                                 , string active
                                                 , string clientID
                                                 , string reviewingPracID
                                                 , string siteID
                                                 , string renderingPracID
                                                 , string patID
                                                 , string dateRange
                                                 , string reviewed
                                                 , string approved)
        {
            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = CybhiServiceRecordsOrpReview.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            var rd = Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(CybhiServiceRecordsOrpReview)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate {
                                              return CybhiServiceRecordsOrpReviews.view(
                                                             connSpedmon
                                                           , log
                                                           , uInfo
                                                           , Entities.REC_VIEW_OBJECTS
                                                           , pageObjectList
                                                           , idx
                                                           , "" /* Can Edit */
                                                           , active
                                                           , clientID
                                                           , siteID
                                                           , reviewingPracID
                                                           , renderingPracID
                                                           , patID
                                                           , dateRange
                                                           , reviewed
                                                           , approved
                                                           , dc);
                                          });

            return rd;
        }

    }
}
