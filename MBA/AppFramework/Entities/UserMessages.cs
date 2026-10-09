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
     * userMessage */
    /**
     * IMPORTANT: NO PERSONAL INFO, ESPECIALLY PATIENT DATA SHOULD BE SENT IN
     * AN EMAIL.
     ***************************************************************************/


    public class UserMessage : Entity
    {
        
        public long    senderClientID;
        public string  senderClientName;

        public long     recipientClientID;
        public string   recipientClientName;

        public long    messageID;
        public string   subject;
        public string   body;
        public long     senderUserID;
        public string   senderName;
        public long     recipientUserID;
        public int      recipientUserGroup;
        public int      recipientUserRank;
        public string   recipientName;
        public string   recipientEmail;

        public string   senderEmail;

        public string   recipientsJSON;

        public bool promptUserToGotoURL;
        public string gotoURL;
        public string gotoURLAdditionalParams;
        public string recipientUserName;

        public DateTime created;
        public string   createdStr;

        public bool     hasRead;
        public bool     okToShow;
        public bool     systemGenerated;
        public bool     allowReply;
        public bool     sendEmail;
        public bool     emailSent;
        public int      respPromptOptionsBitwise;
        public string   respPromptOptionsJSON;

        public bool     recipIsPcalStaff;



        public UserMessage() {}
        public UserMessage(string Subject, string Body, long SenderUserID, string SenderName)
        {
            this.subject      = Subject;
            this.body         = Body;
            this.senderUserID = SenderUserID;
            this.senderName   = SenderName;
        }
    }

    /***************************************************************************
     * userMessages */
    /**
     *
     ***************************************************************************/

    public class UserMessages : Entities
    {
        public const string URL_ASMX          = "user_messages.asmx";
        public const string URL_ASMX_SAVE     = URL_ASMX + "/save";
        public const string URL_ASMX_DELETE   = URL_ASMX + "/delete";
        public const string URL_ASMX_VIEWLIST = URL_ASMX + "/viewList";
        public const string URL_ASMX_VIEW_SEL_CONTACTS = URL_ASMX + "/viewSelContacts";

        /***************************************************************************
         * view */
        /**
         *
         **************************************************************************/

        public static ReturnDB view (   SqlConnection connUser
                                      , DetailsLog log
                                      , UserInfo uInfo
                                      , int recViewType
                                      , bool pagedOrTop
                                      , string idx
                                      , string appName
                                      , string viewSentOnly
                                      , string okToShow
                                      , string hasRead
                                      , string sendEmail
                                      , string emailSent
                                      , string canEdit
                                      , string active
                                      , defineCols dc)
        {

            ///
            string viewUDF = @"dbo.USER_MESSAGES_VIEW (@userID, @userGroup, @userRank, @appName, @viewSentOnly, @okToShow, @hasRead, @sendEmail, @emailSent, @active, @recID)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

            Object vAppName      = Validate.reqString (appName     , Messages.INVALID_APP_NAME);
            Object vViewSentOnly = Validate.reqFlag   (viewSentOnly, Messages.INVALID_FLAG);
            Object vOkToShow     = Validate.optFlag   (okToShow    , Messages.INVALID_FLAG);
            Object vHasRead      = Validate.optFlag   (hasRead     , Messages.INVALID_FLAG);
            Object vSendEmail    = Validate.optFlag   (sendEmail   , Messages.INVALID_FLAG);
            Object vEmailSent    = Validate.optFlag   (emailSent   , Messages.INVALID_FLAG);

            parms.Add(Database.SqlParm("@appName"     , SqlDbType.VarChar, vAppName      , ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@viewSentOnly", SqlDbType.Bit    , vViewSentOnly , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@okToShow"    , SqlDbType.Bit    , vOkToShow     , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@hasRead"     , SqlDbType.Bit    , vHasRead      , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@sendEmail"   , SqlDbType.Bit    , vSendEmail    , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@emailSent"   , SqlDbType.Bit    , vEmailSent    , ParameterDirection.Input    ));

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view (  connUser
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

        public static List<UserMessage> viewList (  SqlConnection connUser
                                                   , DetailsLog    log
                                                   , UserInfo      uInfo
                                                   , string        appName
                                                   , string        viewSentOnly
                                                   , string        okToShow
                                                   , string        hasRead
                                                   , string        sendEmail
                                                   , string        emailSent
                                                   , string        active)

         {
            var recs = new List<UserMessage>();
            ReturnDB rd = view (connUser, log, uInfo, Entities.REC_VIEW_RAW, false, null, appName, viewSentOnly, okToShow, hasRead, sendEmail, emailSent, null, active, null);
            List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(UserMessage));
            foreach (var o in slo) {
                recs.Add((UserMessage) o);
            }
            return recs;
        }


        /***************************************************************************
         * viewWaitingToEmail */
        /**
         *
         **************************************************************************/

        public static ReturnDB viewWaitingToEmail (   SqlConnection connUser
                                                     , DetailsLog log
                                                     , UserInfo uInfo
                                                     , int recViewType
                                                     , bool pagedOrTop
                                                     , string idx
                                                     , string appName
                                                     , string canEdit
                                                     , string active
                                                     , defineCols dc)
        {


            string viewUDF = @"dbo.USER_MESSAGES_VIEW_WAITING_TO_EMAIL (@appName)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

            Object vAppName      = Validate.reqString (appName     , Messages.INVALID_APP_NAME);
            parms.Add(Database.SqlParm("@appName"     , SqlDbType.VarChar, vAppName      , ParameterDirection.Input, 50));

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view (  connUser
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
        * viewWaitingToEmailList */
       /**
        * Return a list of Objects
        *
        ***************************************************************************/

        public static List<UserMessage> viewWaitingToEmailList (  SqlConnection connUser
                                                                , DetailsLog    log
                                                                , UserInfo      uInfo
                                                                , string        appName)

         {
            var recs = new List<UserMessage>();
            ReturnDB rd = viewWaitingToEmail (connUser, log, uInfo, Entities.REC_VIEW_RAW, false, null, appName, null, null, null);
            List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(UserMessage));
            foreach (var o in slo) {
                recs.Add((UserMessage) o);
            }
            return recs;
        }

        /***************************************************************************
         * recordOpFlagAsEmailed */
        /**
         *
         **************************************************************************/

        public static ReturnSaveRecord recordOpFlagAsEmailed (  SqlConnection connUsers
                                                                , DetailsLog    log
                                                                , UserInfo      uInfo
                                                                , string        appName
                                                                , string        validateRec
                                                                , string        editDelReason
                                                                , string        recID)
          {

             string opSproc    = @"USERS_MESSAGES_RECORD_OP_FLAG_AS_EMAILED";
             string vAppName   = Validate.reqString (appName, Messages.NO_APP_NAME);
             var parms = new List<SqlParameter>();
             parms.Add(Database.SqlParm("@appName", SqlDbType.VarChar, vAppName, ParameterDirection.Input, 50));
             return Entities.recordOp(connUsers,log,uInfo,editDelReason,validateRec,recID,opSproc,ref parms);
         }

        /***************************************************************************
         * save */
        /**
         *
         **************************************************************************/

        public static ReturnSaveRecord save (  SqlConnection connUsers
                                             , DetailsLog    log
                                             , UserInfo      uInfo
                                             , string        appName
                                             , string        recipientUserIDsStr
                                             , string        subject
                                             , string        body
                                             , string        sendEmail
                                             , string        isReply
                                             , string        previousMsgID
                                             , string        okToShow
                                             , string        hasRead
                                             , string        respPromptOptions // int; bitwise arith
                                             , string        respPromptOptionsJSON

                                             // TODO -
                                             //, string        promptUserToGotoURL
                                             //, string        gotoURL
                                             //, string        gotoURLAdditionalParams

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

                // TODO: not sure why this save sproc is implemented for both UserMessages.cs and UserNotifications.cs

                object vAppName;
                object vSubject;
                object vBody;
                object vRecipientUserIDsStr;
                object vActive;
                object vIsReply;
                object vPreviousMsgID;

                object vOkToShow              = Validate.optFlag    (okToShow, @"Invalid okToShow flag");
                object vHasRead               = Validate.optFlag    (hasRead,  @"Invalid hasRead flag");
                object vRespPromptOptions     = Validate.optInteger (respPromptOptions, "invalid URL parameter for respPromptOptions");
                object vrespPromptOptionsJSON = Validate.optString  (respPromptOptionsJSON, "invalid URL parameter for respPromptOptionsJSON");

                //object vPromptUserToGotoURL      = Validate.optFlag   (promptUserToGotoURL, "invalid promptUserToGotoURL flag");
                //object vGotoURL                  = Validate.optString (gotoURL, "invalid GotoURL");
                //object vGotoURLAdditionalParams  = Validate.optString (gotoURL, "invalid GotoURL params");

                List<SqlParameter> parms = new List<SqlParameter>();

                if (saveType == Constants.SAVE_TYPE_NEW.ToString()) {
                    vAppName             = Validate.reqString        (appName,             Messages.NO_APP_NAME);
                    vSubject             = Validate.reqString        (subject,             @"Invalid Subject");
                    vBody                = Validate.reqString        (body,                @"Invalid message body");
                    vRecipientUserIDsStr = Validate.reqRecIDMultiStr (recipientUserIDsStr, @"Invalid user recipients");
                    vActive              = Validate.reqFlag          (active,              Messages.INVALID_FLAG_ACTIVE);
                    vIsReply             = Validate.reqFlag          (isReply,             Messages.INVALID_FLAG);
                    vPreviousMsgID       = Validate.optInteger       (previousMsgID,       Messages.INVALID_ENTITY_ID);

                    parms.Add(
                        Database.SqlParm(
                            "@sendEmail",
                            SqlDbType.Bit,
                             Validate.reqFlag(sendEmail,
                             "send email?"),
                            ParameterDirection.Input
                        )
                    );
            }
                else {
                    vAppName             = Validate.optString        (appName,             Messages.NO_APP_NAME);
                    vSubject             = Validate.optString        (subject,             @"Invalid Subject");
                    vBody                = Validate.optString        (body,                @"Invalid message body");
                    vRecipientUserIDsStr = Validate.optRecIDMultiStr (recipientUserIDsStr, @"Invalid user recipients");
                    vActive              = Validate.optFlag          (active,              Messages.INVALID_FLAG_ACTIVE);
                    vIsReply             = Validate.optFlag          (isReply,             Messages.INVALID_FLAG);
                    vPreviousMsgID       = Validate.optInteger       (previousMsgID,       Messages.INVALID_ENTITY_ID);

                    parms.Add(Database.SqlParm("@sendEmail", SqlDbType.Bit, false, ParameterDirection.Input));

            }



                parms.Add(Database.SqlParm("@appName"            , SqlDbType.VarChar, vAppName             , ParameterDirection.Input, 50));
                parms.Add(Database.SqlParm("@subject"            , SqlDbType.VarChar, vSubject             , ParameterDirection.Input, -1));
                parms.Add(Database.SqlParm("@body"               , SqlDbType.VarChar, vBody                , ParameterDirection.Input, -1));
                parms.Add(Database.SqlParm("@recipientUserIDsStr", SqlDbType.VarChar, vRecipientUserIDsStr , ParameterDirection.Input, -1));
                parms.Add(Database.SqlParm("@okToShow"           , SqlDbType.Bit,     vOkToShow            , ParameterDirection.Input));
                parms.Add(Database.SqlParm("@hasRead"            , SqlDbType.Bit,     vHasRead             , ParameterDirection.Input));
                parms.Add(Database.SqlParm("@active"             , SqlDbType.Bit,     vActive              , ParameterDirection.Input));
                parms.Add(Database.SqlParm("@isReply"            , SqlDbType.Bit,     vIsReply             , ParameterDirection.Input));
                parms.Add(Database.SqlParm("@previousMsgID"      , SqlDbType.BigInt,  vPreviousMsgID       , ParameterDirection.Input));

                parms.Add(Database.SqlParm("@respPromptOptionsBitwise", SqlDbType.Int,     vRespPromptOptions,     ParameterDirection.Input));
                parms.Add(Database.SqlParm("@respPromptOptionsJSON",    SqlDbType.VarChar, vrespPromptOptionsJSON, ParameterDirection.Input, -1));

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


        /*************************************************************************
         * saveWNav */
        /**
         * Populates a notification with a finger navlink into the notification widget;
         * optionally sends an email to the recipients' email address(es) on file
         * 
         * @param   userID                    The userid of who saved the record
         * @param   userGroup                 Users group
         * @param   userRank                  User rank


         * @param   @appName                  app name from MBA.Constants
         * @param   @recipientUserIDsStr      numeric UserIDs of recipient users, as comma-separated string
         * @param   @subject                  subject
         * @param   @body                     message body
         * @param   @sendEmail                send email?

         * @param   @respPromptOptionsBitwise respPromptOptionsBitwise
         *                                     TODO: document all valid bitwise options, here
         * @param   @respPromptOptionsJSON    respPromptOptionsJSON
         *                                     TODO: document all valid JSON properties, here
         *                                     TODO: also make a validate function that throws error w/ invalid, undefined JSON options

         * @param   @promptUserToGotoURL      promptUserToGotoURL
         * @param   @gotoURL                  gotoURL
         * @param   @gotoURLAdditionalParams  gotoURLAdditionalParams

         *
         ***************************************************************************/

        public static ReturnDB saveWNav (  SqlConnection connUsers
                                             , DetailsLog    log
                                             , UserInfo      uInfo
                                             , string        appName
                                             , string        recipientUserIDsStr
                                             , string        subject
                                             , string        body
                                             , string        sendEmail

                                             //, string        isReply
                                             //, string        previousMsgID
                                             //, string        okToShow
                                             //, string        hasRead

                                             , string        respPromptOptions // int; bitwise arith
                                             , string        respPromptOptionsJSON

                                             
                                             , string        promptUserToGotoURL
                                             , string        gotoURL
                                             , string        gotoURLAdditionalParams

                                             
                                             )
          {

                /*----------------------------
                 * Validate parameters specific
                 * to this entity.save
                 * and populate their
                 * coresponding database
                 * parameters
                 *----------------------------*/

                string saveSproc = "USERS_MESSAGES_SAVE_SIMPLE_W_NAV";
                //UserNotifications

                // TODO: not sure why this save sproc is implemented for both UserMessages.cs and UserNotifications.cs

                string        saveType = "1";

                object vAppName;
                object vSubject;
                object vBody;
                object vRecipientUserIDsStr;
                //object vActive;
                //object vIsReply;
                //object vPreviousMsgID;

                //object vOkToShow              = Validate.optFlag    (okToShow, @"Invalid okToShow flag");
                //object vHasRead               = Validate.optFlag    (hasRead,  @"Invalid hasRead flag");
                object vRespPromptOptions     = Validate.optInteger (respPromptOptions, "invalid URL parameter for respPromptOptions", true);
                object vrespPromptOptionsJSON = Validate.optString  (respPromptOptionsJSON, "invalid URL parameter for respPromptOptionsJSON");

                object vPromptUserToGotoURL      = Validate.optFlag   (promptUserToGotoURL, "invalid promptUserToGotoURL flag");
                object vGotoURL                  = Validate.optString (gotoURL, "invalid GotoURL");
                object vGotoURLAdditionalParams  = Validate.optString (gotoURLAdditionalParams, "invalid GotoURL params");


                // TODO: Some of the EXISTING notif messages with navs are problematic, for some users.
                //  Broken links are being sent out, requiring a sign-in for already-signed-in users.

                //  Needs more testing and diagnostics; no client has complained about this issue thus far.

                List<SqlParameter> parms = new List<SqlParameter>();

                if (saveType == Constants.SAVE_TYPE_NEW.ToString()) {
                    vAppName             = Validate.reqString        (appName,             Messages.NO_APP_NAME);
                    vSubject             = Validate.reqString        (subject,             @"Invalid Subject");
                    vBody                = Validate.reqString        (body,                @"Invalid message body");
                    vRecipientUserIDsStr = Validate.reqRecIDMultiStr (recipientUserIDsStr, @"Invalid user recipients");
                    //vActive              = Validate.reqFlag          (active,              Messages.INVALID_FLAG_ACTIVE);
                    //vIsReply             = Validate.reqFlag          (isReply,             Messages.INVALID_FLAG);
                    //vPreviousMsgID       = Validate.optInteger       (previousMsgID,       Messages.INVALID_ENTITY_ID);

                    parms.Add(
                        Database.SqlParm(
                            "@sendEmail",
                            SqlDbType.Bit,
                             Validate.reqFlag(sendEmail,
                             "send email?"),
                            ParameterDirection.Input
                        )
                    );
            }
                else {
                    vAppName             = Validate.optString        (appName,             Messages.NO_APP_NAME);
                    vSubject             = Validate.optString        (subject,             @"Invalid Subject");
                    vBody                = Validate.optString        (body,                @"Invalid message body");
                    vRecipientUserIDsStr = Validate.optRecIDMultiStr (recipientUserIDsStr, @"Invalid user recipients");
                    //vActive              = Validate.optFlag          (active,              Messages.INVALID_FLAG_ACTIVE);
                    //vIsReply             = Validate.optFlag          (isReply,             Messages.INVALID_FLAG);
                    //vPreviousMsgID       = Validate.optInteger       (previousMsgID,       Messages.INVALID_ENTITY_ID);

                    parms.Add(Database.SqlParm("@sendEmail", SqlDbType.Bit, false, ParameterDirection.Input));

            }



                parms.Add(Database.SqlParm("@appName"            , SqlDbType.VarChar, vAppName             , ParameterDirection.Input, 50));
                parms.Add(Database.SqlParm("@subject"            , SqlDbType.VarChar, vSubject             , ParameterDirection.Input, -1));
                parms.Add(Database.SqlParm("@body"               , SqlDbType.VarChar, vBody                , ParameterDirection.Input, -1));
                parms.Add(Database.SqlParm("@recipientUserIDsStr", SqlDbType.VarChar, vRecipientUserIDsStr , ParameterDirection.Input, -1));
                //parms.Add(Database.SqlParm("@okToShow"           , SqlDbType.Bit,     vOkToShow            , ParameterDirection.Input));
                //parms.Add(Database.SqlParm("@hasRead"            , SqlDbType.Bit,     vHasRead             , ParameterDirection.Input));
                //parms.Add(Database.SqlParm("@active"             , SqlDbType.Bit,     vActive              , ParameterDirection.Input));
                //parms.Add(Database.SqlParm("@isReply"            , SqlDbType.Bit,     vIsReply             , ParameterDirection.Input));
                //parms.Add(Database.SqlParm("@previousMsgID"      , SqlDbType.BigInt,  vPreviousMsgID       , ParameterDirection.Input));

                parms.Add(Database.SqlParm("@respPromptOptionsBitwise", SqlDbType.Int,     vRespPromptOptions,     ParameterDirection.Input));
                parms.Add(Database.SqlParm("@respPromptOptionsJSON",    SqlDbType.VarChar, vrespPromptOptionsJSON, ParameterDirection.Input, -1));

                parms.Add(Database.SqlParm("@promptUserToGotoURL", SqlDbType.Bit, vPromptUserToGotoURL,     ParameterDirection.Input));
                parms.Add(Database.SqlParm("@gotoURL",    SqlDbType.VarChar, vGotoURL, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@gotoURLAdditionalParams", SqlDbType.VarChar, vGotoURLAdditionalParams, ParameterDirection.Input));


            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/
            Entities.validateAndAddCommonUserInfoParameters(uInfo, ref parms);
            parms.Add(Database.SqlParm("@saveType", SqlDbType.Int, "1", ParameterDirection.Input));
            parms.Add(Database.SqlParm("@recID", SqlDbType.BigInt, "0", ParameterDirection.Input));

            parms.Add(Database.SqlParm("@recordID", SqlDbType.BigInt, null, ParameterDirection.Output));
            parms.Add(Database.SqlParm("@spDetails", SqlDbType.VarChar, null, ParameterDirection.Output, 8000));

            return MBA.Database.execSproc(connUsers, log, saveSproc, parms);
            

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
