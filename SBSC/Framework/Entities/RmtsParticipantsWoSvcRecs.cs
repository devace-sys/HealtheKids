using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;



namespace Spedmon
{

    /***************************************************************************
     * RmtsParticipantWoSvcRecs */
    /**
     * 
     **************************************************************************/
    public class RmtsParticipantWoSvcRecs : Entity
    {
        public const string DEFAULT_PAGING_ORDER = "pracTitle asc, pracName asc";

        public long rp_id;
        public long rosterID;

        public long pracID;
        public string pracName;

        public long pracUid;

        public string pracEmail;

        public string pracTitle;
        public string reportingGroup;

        //public string QTR_DEFINITION;

        public long FY_ID;

        //public long FYQ_ID;

        public string FY_DEFINITION;

        // public int QtrNum;

        public string q1_rosterID;

        public string q1_quarterID;

        public long clientID;

        public string submitClaimsStr;

        public string deferralReason;
        public string deferralReasonNotes;

        public string deferralDateStrYMD;
        public string deferralDateStr;

        public string lastModifiedByStr;
        public string deferredByStr;

        public int numSvcsLt3;



    }



    /***************************************************************************
     * RmtsParticipantsWoSvcRecs */
    /**
     * 
     **************************************************************************/
    public class RmtsParticipantsWoSvcRecs : Entities
    {

        public const string URL_ASHX      = @"rmts_participants_wo_svcrecs.ashx";
        public const string URL_ASMX      = @"rmts_participants.asmx";
        public const string URL_SAVE      = URL_ASMX + @"/save";


        public const string URL_REST_VIEW = @"api/v1/rmtsparticipantswosvcrecs";

        public const string URL_PAGE_VIEW = @"user_all_rmts_participants_wo_svcrecs_viewall.aspx";

        public const string URL_FLAG_DEFERRAL_REASON = URL_ASMX + @"/flagdeferralreason";

        /***************************************************************************
         * URL_REST_VIEW_BASE
         * 
         ***************************************************************************/ 
        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(RmtsParticipantsWoSvcRecs.URL_REST_VIEW, true);
        }

        /***************************************************************************
         * URL_PAGE_VIEW_BASE
         * 
         ***************************************************************************/ 
        public static string URL_PAGE_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(RmtsParticipantsWoSvcRecs.URL_PAGE_VIEW, true);
        }

        /***************************************************************************
         * URL_ASHX_BASE
         * 
         ***************************************************************************/
        public static string URL_ASHX_BASE()
        {
            return MBA.HttpApplication.createLink(RmtsParticipantsWoSvcRecs.URL_ASHX, true);
        }


        /***************************************************************************
         * URL_FLAG_DEFERRAL_REASON_BASE 
         * 
         ***************************************************************************/
        public static string URL_FLAG_DEFERRAL_REASON_BASE()
        {
            return MBA.HttpApplication.createLink(RmtsParticipantsWoSvcRecs.URL_FLAG_DEFERRAL_REASON, true);
        }

        /***************************************************************************
         * view 
         * 
         ***************************************************************************/
        public static ReturnDB view(SqlConnection connSpedmon
                                      , DetailsLog log
                                      , UserInfo uInfo
                                      , int recViewType
                                      , bool pagedOrTop
                                      , string idx
                                      , string clientID
                                      , string filter_for_deferred
                                      , defineCols dc)
        {

            string viewUDF = "dbo.RMTS_PARTICIPANTS_WO_SVCRECS_VIEW (@userID, @userGroup, @userRank, @clientID, @filterfordeferred)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            var vClientID = Validate.reqClientID(uInfo, clientID);
            var vIsDeferred = Validate.optFlag(filter_for_deferred, "is deferred?");


            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@filterfordeferred", SqlDbType.Bit, vIsDeferred, ParameterDirection.Input));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, "", "", viewUDF, ref parms, null, dc);

        }



        /***************************************************************************
         * viewObjects 
         *
         * Returns a list of objects
         * 
         ***************************************************************************/
        public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                    , DetailsLog log
                                                    , UserInfo uInfo
                                                    , bool pageObjectList
                                                    , string pageOrder
                                                    , string idx
                                                    , string clientID
                                                    , string filter_for_deferred
        )
        {

            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = RmtsParticipant.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
                * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                            , log
                                            , uInfo
                                            , typeof(RmtsParticipantWoSvcRecs)
                                            , pageObjectList
                                            , pageOrder
                                            , delegate
                                            {
                                                return RmtsParticipantsWoSvcRecs.view(
                                                                          connSpedmon
                                                                        , log
                                                                        , uInfo
                                                                        , Entities.REC_VIEW_OBJECTS
                                                                        , pageObjectList
                                                                        , idx
                                                                        , clientID
                                                                        , filter_for_deferred
                                                                        , dc
                                                );
                                            });
        }

        /***************************************************************************
         * viewTbl 
         *
         * Returns data table
         * 
         ***************************************************************************/
        public static ReturnDataTable viewTbl(SqlConnection connSpedmon
                                               , DetailsLog log
                                               , UserInfo uInfo
                                               , bool paged
                                               , string pageNumber

                                               , string clientID
                                               , string filter_for_deferred

                                               )
        {
            ReturnDataTable so = new ReturnDataTable();

            /*###########################################################################
              # Define our display columns and set the page order.  Page order needs to
              # be in the same sort order as the udf called in the view.
              ###########################################################################*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                // ss.addDisplayColumn("id");

                ss.addDisplayColumn("pracName                    as [Practitioner Name]", true);

                ss.addDisplayColumn("pracTitle                   as [Practitioner Title]");
                ss.addDisplayColumn("deferralDateStrYMD          as [Deferral Date]");

                ss.addDisplayColumn("deferralReason                   as [Deferral Reason]");
                ss.addDisplayColumn("deferralReasonNotes              as [Deferral Reason Notes]");

                ss.addDisplayColumn("reportingGroup             as [Reporting Group]");

                //ss.addDisplayColumn("QTR_DEFINITION             as [QTR]");
                ss.addDisplayColumn("FY_DEFINITION               as [FY]");

                ss.addDisplayColumn("numSvcsLt3                 as [Number of Svcs]");

                ss.addDisplayColumn("rosterID                   as [rosterID]");

                ss.addDisplayColumn("submitClaimsStr            as [Submit Claims?]");

                pageroworder = ss.pageRowOrder();
            };

            /*###########################################################################
              # Call the base method which handles the rest and returns a ReturnDataTable
              ###########################################################################*/

            so = Entities.viewTbl(connSpedmon
                                  , log
                                  , uInfo
                                  , paged
                                  , pageNumber
                                  , delegate {
                                      return  RmtsParticipantsWoSvcRecs.view(
                                                                          connSpedmon
                                                                        , log
                                                                        , uInfo
                                                                        , Entities.REC_VIEW_TBL
                                                                        , paged
                                                                        , pageNumber
                                                                        , clientID
                                                                        , filter_for_deferred
                                                                        , dc);  });

            /*###########################################################################
              # Add a title and footer to ReturnDataTable then return
              ###########################################################################*/

            // so.tableName = SEL_LABEL;
            so.tableName = "RMTS Participants Without Service Records";

            so.tableFooter = Messages.CONFIDENTIAL;

            return so;

        }

      /*************************************************************************
       * flagDeferralReason */
      /**
       * Flags a record as Deferred.
       *
       * @param  recID                  string - the numeric ID of the participant
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

            long vClientID = Validate.reqClientID(uInfo, clientid);

            var vIsDeferred = Validate.reqFlag(isdeferred, "is deferred?");

            string vDefReason = null, vDefReasonNotes = null;

            if (vIsDeferred)
            {
                vDefReason = Validate.reqString(deferralReason, "select a reason");

                vDefReasonNotes = Validate.reqString(deferralReasonNotes, "enter a reason");
            }

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@deferralReason", SqlDbType.VarChar, vDefReason, ParameterDirection.Input, 200));
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
                                , "RMTS_PARTICIPANT_FLAG_DEFERRALREASON"
                                , Messages.DUP_SVC_REC
                                , ref parms,
              delegate ()
              { });
        }



    }
}


