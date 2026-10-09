using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using MBA;


namespace Spedmon
{
    /***************************************************************************
     * PractitionerDirectSupervisedSupervisor */
    /**
     * 
     *
     * 
     **************************************************************************/
    public class PractitionerDirectSupervisedSupervisor : Entity
    {
        public const string DEFAULT_PAGING_ORDER = @"name asc, id desc";

        public long clientID;
        public string clientName;

        public long groupServiceClassNameID;
        public string groupServiceClassName;

        public long supervisingPracID;
        public string supervisingPracName;
        public string supervisingPracDispGroupName;
        public long supervisingPracDispGroupID;
        public string supervisingPracNameAndTitle;
        public long supervisingPracReptGroupID;
        public string supervisingPracReptGroupName;

        public long supervisedPracID;
        public string supervisedPracName;
        public string supervisedPracDispGroupName;
        public long supervisedPracDispGroupID;
        public string supervisedPracNameAndTitle;
        public long supervisedPracReptGroupID;
        public string supervisedPracReptGroupName;

        public string startDateStrYMD;
        public string endDateStrYMD;
        public bool   shareNotes;
        public byte   relationshipTypeID;
        public bool   requireSvcRecApprovalForNonProgCompRels;
        public string relationshipTypeName;

        public bool supervisionRelationshipIsCurrentlyValid;
        public bool supervisedAndSupervisorAreInDifferentReportingGroups;

        /* Temp hack to get automcomplete for prac selection working in restview */

        public string patid = "";
        public string dos = "";
        public string groupserviceclassnameid = "";
        public string pracdatasource = MBA.PractitionerDataSource.WITHIN_PRACTICE_FAMILY_ONLY.GetValueAsString(); /* 8*/

    }

    /***************************************************************************
     * PractitionerDirectSupervisedSupervisors */
    /**
     ***************************************************************************/

    public class PractitionerDirectSupervisedSupervisors : Entities
    {

        public const string SEL_LABEL         = @"Manage Practitioner Supervision Relationships";
        public const string SEL_LABEL_MANAGE  = SEL_LABEL;
        public const string SEL_LABEL_ADD_NEW = @"Add New";
        public const string SEL_LABEL_EDIT    = @"Edit";
        public const string MENU_LINK_MANAGE  = @"pracdirectsupmanagelink";

        public const string URL_USER_ALL_MANAGE = @"user_all_practitioner_direct_supervision_manage.aspx";

        public static string VAL_FILE_CLASS_PROOF_OF_QUALIFICATIONS = MBA.StoredFiles.FILE_CLASS_PROOF_OF_QUALIFICATIONS;
        public static string VAL_FILE_NAMESPACE = "direct_supervision_tracking";
        public static string VAL_FILE_SOURCE = "direct_supervision_save";

        public const string URL_SVC_BASE = @"practitioner_direct_supervisors.asmx";
        public const string URL_REST_SAVE_INLINE = URL_SVC_BASE + @"/save";
        public const string URL_REST_DELETE_INLINE = URL_SVC_BASE + @"/delete";
        public const string URL_REST_UNDELETE_INLINE = URL_SVC_BASE + @"/undelete";
        public const string URL_REST_VIEW = @"api/v1/practitionerdirectsupervision";
        public const string URL_REPORT = @"practitioner_direct_supervisors.ashx";

        public const string URL_SVC_OK_TO_SHOW_SVC_RECS_RVW_NOTIFICATIONS_USER_PREF_SET = URL_SVC_BASE + @"/oktoshowservicerecordreviewnotificationssetuserpref";
        public const string USER_PREF_SUPERVISING_PRAC_NON_HS_PENDING_SVC_REC_REVIEWS_SELECTOR = @"supervising_prac_non_hs_pending_svc_rec_reviews";
        public const string USER_PREF_SUPERVISING_PRAC_NON_HS_PENDING_SVC_REC_REVIEWS_NOTIFICATIONS_NOUN = @"Notifications";
        public const string USER_PREF_SUPERVISING_PRAC_NON_HS_PENDING_SVC_REC_REVIEWS_VIEW_VERB = @"view";
        public const string USER_PREF_SUPERVISING_PRAC_NON_HS_PENDING_SVC_REC_REVIEWS_OK_TO_SHOW_NAME = @"oktoshow";


        /***************************************************************************
         * URL_REST_VIEW */
        /**
         * 
         **************************************************************************/

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(PractitionerDirectSupervisedSupervisors.URL_REST_VIEW, true);
        }

        public static string URL_REST_VIEW_REPORT()
        {
            return MBA.HttpApplication.createLink(PractitionerDirectSupervisedSupervisors.URL_REPORT, true);
        }

        public static string URL_REST_SAVE_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(PractitionerDirectSupervisedSupervisors.URL_REST_SAVE_INLINE, true);
        }

        public static string URL_REST_DELETE_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(PractitionerDirectSupervisedSupervisors.URL_REST_DELETE_INLINE, true);
        }

        public static string URL_REST_UNDELETE_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(PractitionerDirectSupervisedSupervisors.URL_REST_UNDELETE_INLINE, true);
        }

        public static string URL_MANAGE_BASE()
        {
            return MBA.HttpApplication.createLink(PractitionerDirectSupervisedSupervisors.URL_USER_ALL_MANAGE, true);
        }

        public static string URL_SVC_OK_TO_SHOW_SVC_RECS_RVW_NOTIFICATIONS_USER_PREF_SET_BASE()
        {
            return MBA.HttpApplication.createLink(PractitionerDirectSupervisedSupervisors.URL_SVC_OK_TO_SHOW_SVC_RECS_RVW_NOTIFICATIONS_USER_PREF_SET, true);
        }

        /*************************************************************************
         * okToShowServiceRecordReviewNotificationsSetUserPref */
        /**
         * 
         **************************************************************************/
        public static ReturnSaveOrReplaceRecord okToShowServiceRecordReviewNotificationsSetUserPref(SqlConnection connUsers
                                                                                                      , DetailsLog log
                                                                                                      , UserInfo uInfo
                                                                                                      , string value)
        {
            bool vValue = Validate.reqFlag(value, @"Invalid opt out value", false);
            string sValue = Util.boolTo1or0Str(vValue);

            return MBA.UserPreferences.saveOrReplaceRecord(connUsers
                                                             , log
                                                             , uInfo
                                                             , Constants.APP_NAME
                                                             , Constants.APP_NAME
                                                             , uInfo.useridStr
                                                             , USER_PREF_SUPERVISING_PRAC_NON_HS_PENDING_SVC_REC_REVIEWS_SELECTOR
                                                             , MBA.NounVerbNameValueLists.SELECTOR_TYPE_CONSTANT_NAME
                                                             , USER_PREF_SUPERVISING_PRAC_NON_HS_PENDING_SVC_REC_REVIEWS_NOTIFICATIONS_NOUN
                                                             , USER_PREF_SUPERVISING_PRAC_NON_HS_PENDING_SVC_REC_REVIEWS_VIEW_VERB
                                                             , USER_PREF_SUPERVISING_PRAC_NON_HS_PENDING_SVC_REC_REVIEWS_OK_TO_SHOW_NAME
                                                             , sValue);
        }

        /*************************************************************************
         * okToShowServiceRecordReviewNotificationsGetUserPref */
        /**
         * 
         **************************************************************************/

        public static bool okToShowServiceRecordReviewNotificationsGetUserPref(ref RequestResponse rd)
        {
            string _sValue = null;

            if (MBA.UserPreferences.getPreferenceValue(USER_PREF_SUPERVISING_PRAC_NON_HS_PENDING_SVC_REC_REVIEWS_SELECTOR
                                                        , MBA.NounVerbNameValueLists.SELECTOR_TYPE_CONSTANT_NAME
                                                        , USER_PREF_SUPERVISING_PRAC_NON_HS_PENDING_SVC_REC_REVIEWS_NOTIFICATIONS_NOUN
                                                        , USER_PREF_SUPERVISING_PRAC_NON_HS_PENDING_SVC_REC_REVIEWS_VIEW_VERB
                                                        , USER_PREF_SUPERVISING_PRAC_NON_HS_PENDING_SVC_REC_REVIEWS_OK_TO_SHOW_NAME
                                                        , ref rd.wu.preferences
                                                        , out _sValue))
            {
                bool? _vValue = Util.evaluateFlag(_sValue, false);
                if (_vValue.HasValue) return _vValue.Value;
                return true;
            }
            return true;
        }
    
        /*************************************************************************
         * save */
        /**
         *
         * 
         **************************************************************************/

        public static ReturnSaveRecord save(SqlConnection connSpedmon
                                             , DetailsLog log
                                             , UserInfo uInfo
                                             , string clientID
                                             , string supervisingPracID
                                             , string supervisedPracID
                                             , string startDate
                                             , string endDate
                                             , string shareNotes
                                             , string relationshipTypeID
                                             , string requireSvcRecApprovalForNonProgCompRels
                                             , string editDelReason
                                             , string validateRec
                                             , string saveType
                                             , string recID)
        {
            /* Perform additional access verification */

            PractitionerDirectSupervisors.verifyIfUserIsSomeoneWhoCanManageDirectSupervisionTracking(uInfo);

            string saveSproc = @"PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_SAVE";
            string dupRecMsg = @"Record already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            long vClientID = Validate.reqClientID(uInfo, clientID);
            long vSupervisingPracID = Validate.reqInteger(supervisingPracID, @"Invalid supervising prac id");
            long vSupervisedPracID = Validate.reqInteger(supervisedPracID, @"Invalid supervised prac id");
            Object vStartDate = Validate.optDate(startDate, Messages.INVALID_START_DATE);
            Object vEndDate = Validate.optDate(endDate, Messages.INVALID_END_DATE);
            bool vShareNotes = Validate.reqFlag(shareNotes, @"Invalid share notes flag");
            byte vRelationshipTypeID = Validate.reqTinyInt(relationshipTypeID, @"Invalid relationship type id");
            bool vRequireSvcRecApprovalForNonProgCompRels = Validate.reqFlag(requireSvcRecApprovalForNonProgCompRels, @"Invalid require service record approval flag");

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@supervisingPracID", SqlDbType.BigInt, vSupervisingPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@supervisedPracID", SqlDbType.BigInt, vSupervisedPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@startDate", SqlDbType.DateTime, vStartDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@endDate", SqlDbType.DateTime, vEndDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@shareNotes", SqlDbType.Bit, vShareNotes, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@relationshipTypeID", SqlDbType.TinyInt, vRelationshipTypeID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@requireSvcRecApprovalForNonProgCompRels", SqlDbType.Bit, vRequireSvcRecApprovalForNonProgCompRels, ParameterDirection.Input));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
        }

        /*************************************************************************
         * view */
        /**
         *
         * 
         **************************************************************************/

        public static ReturnDB view(SqlConnection connSpedmon
                                      , DetailsLog log
                                      , UserInfo uInfo
                                      , int recViewType
                                      , bool pagedOrTop
                                      , string idx
                                      , string canEdit
                                      , string active
                                      , string clientID
                                      , string grpSvcClassNameID
                                      , string rptGroupID
                                      , string supervisingPracID
                                      , string supervisedPracID
                                      , defineCols dc)
        {
            /* Perform additional access verification.  Note: This will take care of the viewTbl, viewObjects, etc methods */

            PractitionerDirectSupervisors.verifyIfUserIsSomeoneWhoCanManageDirectSupervisionTracking(uInfo);

            /* Define udf */

            string viewUDF = "dbo.PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_VIEW (@userID, @userGroup, @userRank, @clientID, @groupSvcClassNameID, @rptGroupID, @supervisingPracID, @supervisedPracID, @active, @recID)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            var vClientID = Validate.reqClientID(uInfo, clientID);
            var vGroupSvcClassNameID = Validate.optStdGroupSvcClassNameID(uInfo, grpSvcClassNameID);
            var vSupervisingPracID = Validate.optInteger(supervisingPracID, Messages.INVALID_PRAC_ID);
            var vSupervisedPracID = Validate.optInteger(supervisedPracID, Messages.INVALID_PRAC_ID);

            /* Custom validation for reporting group */

            Object vRptGroupID = null;

            /* If the user is a practitioner (Note: If they are a prac not allowed to use this functionality they would not get to this point) */

            if (uInfo.userRoleID == Constants.ROLE_LEA_PROVIDER_ID)
            {

                /* If they are limited to their reporting group for direct supervision tracking then force the value */

                if (uInfo.userPracPracIsLimitedToTheirReportingGroupForManagingDirectSupervisionTracking == true)
                {
                    vRptGroupID = uInfo.userPracReptGroupID;
                }

                /* Otherwise validate */

                else
                {
                    vRptGroupID = Validate.optInteger(rptGroupID, Messages.INVALID_REPT_GROUP_ID);
                }
            }

            /* All other users we validate */

            else
            {
                vRptGroupID = Validate.optInteger(rptGroupID, Messages.INVALID_REPT_GROUP_ID);
            }

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@groupSvcClassNameID", SqlDbType.BigInt, vGroupSvcClassNameID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@rptGroupID", SqlDbType.BigInt, vRptGroupID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@supervisingPracID", SqlDbType.BigInt, vSupervisingPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@supervisedPracID", SqlDbType.BigInt, vSupervisedPracID, ParameterDirection.Input));

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

        public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                  , DetailsLog log
                                                  , UserInfo uInfo
                                                  , bool pageObjectList
                                                  , string pageOrder
                                                  , string idx
                                                  , string active
                                                  , string clientID
                                                  , string grpSvcClassNameID
                                                  , string rptGroupID
        )
        {

            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PractitionerDirectSupervisedSupervisor.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(PractitionerDirectSupervisedSupervisor)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return PractitionerDirectSupervisedSupervisors.view(connSpedmon
                                                                       , log
                                                                       , uInfo
                                                                       , Entities.REC_VIEW_TBL
                                                                       , pageObjectList
                                                                       , idx
                                                                       , "" // canEdit
                                                                       , active
                                                                       , clientID
                                                                       , grpSvcClassNameID
                                                                       , rptGroupID
                                                                       , null
                                                                       , null
                                                                       , dc);
                                          });


        }

        /*************************************************************************
         * delete */
        /**
         *
         * 
         **************************************************************************/

        public static ReturnSaveRecord delete(SqlConnection connSpedmon
                                               , DetailsLog log
                                               , UserInfo uInfo
                                               , string editDelReason
                                               , string validateRec
                                               , string recID)
        {
            /* Perform additional access verification */

            PractitionerDirectSupervisors.verifyIfUserIsSomeoneWhoCanManageDirectSupervisionTracking(uInfo);

            string deleteSproc = @"PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_DELETE";

            /*###########################################################################
              # Validate parameters specific to this entity delete and create their 
              # database parameters.
              ###########################################################################*/

            Object vClientID = Validate.optClientID(uInfo, "");

            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, deleteSproc, ref parms);
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
                                               , string clientID
                                               , string grpSvcClassNameID
                                               , string rptGroupID
                                               , string canEdit
                                               , string active)
        {
            ReturnDataTable so = new ReturnDataTable();

            /*###########################################################################
              # We need to get the client id for client users because we call the client
              # load method.  Practi-cal users pass the client ID (which is required)
              # so this helps validate that.
              ###########################################################################*/

            var vClientID = Validate.reqClientID(uInfo, clientID);
            clientID = vClientID.ToString();

            /*###########################################################################
              # Define our display columns and set the page order.  Page order needs to
              # be in the same sort order as the udf called in the view.
              ###########################################################################*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("id");
                ss.addDisplayColumn("groupServiceClassName         as [Practice Family]");
                ss.addDisplayColumn("supervisedPracNameAndTitle    as [Staff Being Supervised]", true);
                ss.addDisplayColumn("supervisingPracNameAndTitle   as [Supervisor]");
                ss.addDisplayColumn("startDateStrYMD               as [Start Date]");
                ss.addDisplayColumn("endDateStrYMD                 as [End Date]");
                ss.addDisplayColumn("relationshipTypeName          as [Relationship]");
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
                                      return
                        PractitionerDirectSupervisedSupervisors.view(connSpedmon
                                                                       , log
                                                                       , uInfo
                                                                       , Entities.REC_VIEW_TBL
                                                                       , paged
                                                                       , pageNumber
                                                                       , canEdit
                                                                       , active
                                                                       , clientID
                                                                       , grpSvcClassNameID
                                                                       , rptGroupID
                                                                       , null
                                                                       , null
                                                                       , dc);
                                  });

            /*###########################################################################
              # Add a title and footer to ReturnDataTable then return
              ###########################################################################*/

            var clc = Clients.load(connSpedmon, log, uInfo, clientID);

            so.tableName = clc.name + @" - " + SEL_LABEL;
            so.tableFooter = Messages.CONFIDENTIAL;

            return so;

        }

        /*************************************************************************
         * unDelete */
        /**
         *
         * 
         **************************************************************************/

        public static ReturnSaveRecord unDelete(SqlConnection connSpedmon
                                               , DetailsLog log
                                               , UserInfo uInfo
                                               , string editDelReason
                                               , string validateRec
                                               , string recID)
        {
            /* Perform additional access verification */

            PractitionerDirectSupervisors.verifyIfUserIsSomeoneWhoCanManageDirectSupervisionTracking(uInfo);

            string unDeleteSproc = @"PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_UNDELETE";

            /*###########################################################################
              # Validate parameters specific to this entity delete and create their 
              # database parameters.
              ###########################################################################*/

            Object vClientID = Validate.optClientID(uInfo, "");

            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.unDelete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, unDeleteSproc, ref parms);
        }


    }
}
