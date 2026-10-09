using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Mail;
using System.IO;
using System.Data;
using System.Data.SqlClient;

namespace MBA
{

    /***************************************************************************
     * UserNotification */
    /**
     *
     ***************************************************************************/

    public class UserNotification : Entity
    {
        public string   subject;
        public string   body;
        public long     senderUserID;
        public string   senderName;
        public long     recipientUserID;
        public string   recipientName;
        public string   recipientsJSON;
        public DateTime created;
        public string   createdStr;
        public bool     hasRead;
        public bool     okToShow;

        public int      respPromptOptionsBitwise;
        public string   respPromptOptionsJSON;

        public UserNotification() {}
        public UserNotification(string Subject, string Body, long SenderUserID, string SenderName)
        {
            this.subject      = Subject;
            this.body         = Body;
            this.senderUserID = SenderUserID;
            this.senderName   = SenderName;
        }
    }

    /***************************************************************************
     * UserNotifications */
    /**
     *
     ***************************************************************************/

    public class UserNotifications : Entities
    {
        public const string URL_ASMX          = "user_notifications.asmx";
        public const string URL_ASMX_SAVE     = URL_ASMX + "/save";
        public const string URL_ASMX_DELETE   = URL_ASMX + "/delete";
        public const string URL_ASMX_VIEWLIST = URL_ASMX + "/viewList";
        public const string URL_ASMX_VIEW_SEL_CONTACTS = URL_ASMX + "/viewSelContacts";

        /***************************************************************************
         * view */
        /**
         *
         **************************************************************************/

        public static ReturnDB view(SqlConnection connUser
                                      , DetailsLog log
                                      , UserInfo uInfo
                                      , int recViewType
                                      , bool pagedOrTop
                                      , string idx
                                      , string appName
                                      , string viewSentOnly
                                      , string okToShow
                                      , string hasRead
                                      , string canEdit
                                      , string active
                                      , defineCols dc)
        {

            string viewUDF = @"dbo.USER_MESSAGES_VIEW(@userID, @userGroup, @userRank, @appName, @viewSentOnly, @okToShow, @hasRead, @active, @recID)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

            Object vAppName      = Validate.reqString(appName     , Messages.INVALID_APP_NAME);
            Object vViewSentOnly = Validate.reqFlag  (viewSentOnly, Messages.INVALID_FLAG);
            Object vOkToShow     = Validate.optFlag  (okToShow    , Messages.INVALID_FLAG);
            Object vHasRead      = Validate.optFlag  (hasRead     , Messages.INVALID_FLAG);

            parms.Add(Database.SqlParm("@appName"     , SqlDbType.VarChar, vAppName     , ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@viewSentOnly", SqlDbType.Bit    , vViewSentOnly, ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@okToShow"    , SqlDbType.Bit    , vOkToShow    , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@hasRead"     , SqlDbType.Bit    , vHasRead     , ParameterDirection.Input    ));

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connUser
                                  , log
                                  , uInfo
                                  , recViewType
                                  , pagedOrTop
                                  , idx
                                  , canEdit
                                  , active
                                  , viewUDF
                                  , ref parms
                                  , null
                                  , dc);
        }

       /*************************************************************************
        * viewList */
       /**
        * Return a list of Objects
        *
        ***************************************************************************/

        public static List<UserMessage> viewList( SqlConnection connUser
                                                             , DetailsLog    log
                                                             , UserInfo      uInfo
                                                             , string        appName
                                                             , string        viewSentOnly
                                                             , string        okToShow
                                                             , string        hasRead
                                                             , string        active)

         {
            var recs = new List<UserMessage>();
            ReturnDB rd = view(connUser, log, uInfo, Entities.REC_VIEW_RAW, false, null, appName, viewSentOnly, okToShow, hasRead, null, active, null);
            List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(UserMessage));
            foreach (var o in slo) {
                recs.Add((UserMessage) o);
            }
            return recs;
        }

        /***************************************************************************
         * save */
        /**
         *
         **************************************************************************/

        public static ReturnSaveRecord save(SqlConnection connUsers
                                  , DetailsLog    log
                                  , UserInfo      uInfo
                                  , string        appName
                                  , string        recipientUserIDsStr
                                  , string        subject
                                  , string        body
                                  , string        isReply
                                  , string        previousMsgID
                                  , string        okToShow
                                  , string        hasRead
                                  , string        respPromptOptions // int; bitwise arith
                                  , string        respPromptOptionsJSON

                                  //, string        promptUserToGotoURL
                                  //, string        gotoURL

                                  , string        active
                                  , string        saveType
                                  , string        validateRec
                                  , string        editDelReason
                                  , string        recID)
          {

                /*----------------------------
                 * Validate parameters specific
                 * to this entity.save
                 * and populate their
                 * coresponding database
                 * parameters
                 *----------------------------*/

                string saveSproc = "USERS_MESSAGES_SAVE";

                object vAppName;
                object vSubject;
                object vBody;
                object vRecipientUserIDsStr;
                object vActive;
                object vIsReply;
                object vPreviousMsgID;

                object vOkToShow = Validate.optFlag (okToShow, @"Invalid okToShow flag");
                object vHasRead  = Validate.optFlag (hasRead,  @"Invalid hasRead flag");

                object vRespPromptOptions = Validate.optInteger (respPromptOptions, "invalid URL parameter for respPromptOptions");
                object vrespPromptOptionsJSON = Validate.optString(respPromptOptionsJSON, "invalid URL parameter for respPromptOptionsJSON");

                //object vPromptUserToGotoURL    = Validate.optFlag   (promptUserToGotoURL, "invalid promptUserToGotoURL flag");
                //object vGotoURL                 = Validate.optString (gotoURL, "invalid GotoURL");

                if (saveType == Constants.SAVE_TYPE_NEW.ToString()) {
                    vAppName             = Validate.reqString        (appName,             Messages.NO_APP_NAME);
                    vSubject             = Validate.reqString        (subject,             @"Invalid Subject");
                    vBody                = Validate.reqString        (body,                @"Invalid message body");
                    vRecipientUserIDsStr = Validate.reqRecIDMultiStr (recipientUserIDsStr, @"Invalid user recipients");
                    vActive              = Validate.reqFlag          (active,              Messages.INVALID_FLAG_ACTIVE);
                    vIsReply             = Validate.reqFlag          (isReply,             Messages.INVALID_FLAG);
                    vPreviousMsgID       = Validate.optInteger       (previousMsgID,       Messages.INVALID_ENTITY_ID);
                }
                else {
                    vAppName             = Validate.optString        (appName,             Messages.NO_APP_NAME);
                    vSubject             = Validate.optString        (subject,             @"Invalid Subject");
                    vBody                = Validate.optString        (body,                @"Invalid message body");
                    vRecipientUserIDsStr = Validate.optRecIDMultiStr (recipientUserIDsStr, @"Invalid user recipients");
                    vActive              = Validate.optFlag          (active,              Messages.INVALID_FLAG_ACTIVE);
                    vIsReply             = Validate.optFlag          (isReply,             Messages.INVALID_FLAG);
                    vPreviousMsgID       = Validate.optInteger       (previousMsgID,       Messages.INVALID_ENTITY_ID);
                }

                List<SqlParameter> parms = new List<SqlParameter>();

                parms.Add(Database.SqlParm("@appName"            , SqlDbType.VarChar, vAppName             , ParameterDirection.Input, 50));
                parms.Add(Database.SqlParm("@subject"            , SqlDbType.VarChar, vSubject             , ParameterDirection.Input, -1));
                parms.Add(Database.SqlParm("@body"               , SqlDbType.VarChar, vBody                , ParameterDirection.Input, -1));
                parms.Add(Database.SqlParm("@recipientUserIDsStr", SqlDbType.VarChar, vRecipientUserIDsStr , ParameterDirection.Input, -1));
                parms.Add(Database.SqlParm("@okToShow"           , SqlDbType.Bit,     vOkToShow            , ParameterDirection.Input));
                parms.Add(Database.SqlParm("@hasRead"            , SqlDbType.Bit,     vHasRead             , ParameterDirection.Input));
                parms.Add(Database.SqlParm("@active"             , SqlDbType.Bit,     vActive              , ParameterDirection.Input));
                parms.Add(Database.SqlParm("@isReply"            , SqlDbType.Bit,     vIsReply             , ParameterDirection.Input));
                parms.Add(Database.SqlParm("@previousMsgID"      , SqlDbType.BigInt,  vPreviousMsgID       , ParameterDirection.Input));

                parms.Add(Database.SqlParm("@respPromptOptionsBitwise", SqlDbType.Int, vRespPromptOptions, ParameterDirection.Input));

                parms.Add(Database.SqlParm("@respPromptOptionsJSON", SqlDbType.VarChar, vrespPromptOptionsJSON, ParameterDirection.Input, -1));

                parms.Add(Database.SqlParm("@promptUserToGotoURL", SqlDbType.Bit,  false,     ParameterDirection.Input));
                parms.Add(Database.SqlParm("@gotoURL",    SqlDbType.VarChar, "", ParameterDirection.Input));

                /*----------------------------
                 * Call base method which
                 * handles the rest and return
                 * results
                 *----------------------------*/



                return  Entities.save(connUsers
                                   , log
                                   , uInfo
                                   , saveType
                                   , validateRec
                                   , editDelReason
                                   , recID
                                   , saveSproc
                                   , @"Duplicate content"
                                   , ref parms
                                   , delegate () { }); ;

            }

        /***************************************************************************
         * delete */
        /**
         *
         **************************************************************************/

        public static ReturnSaveRecord delete(SqlConnection connUsers
                                  , DetailsLog    log
                                  , UserInfo      uInfo
                                  , string        appName
                                  , string        validateRec
                                  , string        editDelReason
                                  , string        recID)
          {

                /*----------------------------
                 * Validate parameters specific
                 * to this entity.save
                 * and populate their
                 * coresponding database
                 * parameters
                 *----------------------------*/

                string deleteSproc = "USER_MESSAGES_DELETE";

                string vAppName             = Validate.reqString        (appName,             Messages.NO_APP_NAME);

                List<SqlParameter> parms = new List<SqlParameter>();

                parms.Add(Database.SqlParm("@appName"            , SqlDbType.VarChar, vAppName             , ParameterDirection.Input, 50));

                /*----------------------------
                 * Call base method which
                 * handles the rest and return
                 * results
                 *----------------------------*/



                return Entities.delete(connUsers
                                   , log
                                   , uInfo
                                   , editDelReason
                                   , validateRec
                                   , recID
                                   , deleteSproc
                                   , ref parms); ;

            }

        }
}
