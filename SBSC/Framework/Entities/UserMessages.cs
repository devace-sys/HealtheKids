using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;


namespace Spedmon
{

    /***************************************************************************
     * UserMessages */
    /**
     *
     ***************************************************************************/

    public class UserMessages : Entities
    {

        /*************************************************************************
         * viewList */
        /**
         * Return a list of Objects
         * 
         ***************************************************************************/

        public static List<UserMessage> viewList( SqlConnection connUser
                                                             , DetailsLog log
                                                             , UserInfo uInfo
                                                             , string   viewSentOnly
                                                             , string   okToShow
                                                             , string   hasRead
                                                             , string   sendEmail
                                                             , string   emailSent
                                                             , string   active)
        {
            return MBA.UserMessages.viewList(connUser, log, uInfo, Constants.APP_NAME, viewSentOnly, okToShow, hasRead, sendEmail, emailSent, active);
        }

        /*************************************************************************
         * viewListForUserID */
        /**
         * Return a list of Objects
         * 
         ***************************************************************************/
        public static List<UserMessage> viewListForUserID( SqlConnection connUser
                                                                        , DetailsLog log
                                                                        , UserInfo uInfo
                                                                        , string targetUserID
                                                                        , string appName
                                                                        , string viewSentOnly
                                                                        , string okToShow
                                                                        , string hasRead
                                                                        , string sendEmail
                                                                        , string emailSent
                                                                        , string active)
        {
            var recs = new List<UserMessage>();
            ReturnDB rd = MBA.UserMessages.viewForUserID( connUser, log, uInfo, Entities.REC_VIEW_RAW, false, null, targetUserID, appName, viewSentOnly, okToShow, hasRead, sendEmail, emailSent, null, active, null);
            List<Object> slo = Database.convertRecordsToList(ref rd.records, typeof(UserMessage));

            foreach (var o in slo)
            {
                recs.Add((UserMessage)o);
            }

            return recs;
        }

        /*************************************************************************
         * viewWaitingToEmailList */
        /**
         * Return a list of Objects
         * 
         ***************************************************************************/

        public static List<UserMessage> viewWaitingToEmailList( SqlConnection connUser
                                                               , DetailsLog log
                                                               , UserInfo uInfo )
        {
            return MBA.UserMessages.viewWaitingToEmailList (connUser, log, uInfo, Constants.APP_NAME);
        }
        
        /*************************************************************************
         * recordOpFlagAsEmailed */
        /**
         * Return a list of Objects
         * 
         ***************************************************************************/

        public static ReturnSaveRecord recordOpFlagAsEmailed (  SqlConnection connUsers
                                                               , DetailsLog    log
                                                               , UserInfo      uInfo                                                               
                                                               , string        validateRec
                                                               , string        editDelReason
                                                               , string        recID)
        {
            return MBA.UserMessages.recordOpFlagAsEmailed(connUsers,log,uInfo,Constants.APP_NAME,validateRec,editDelReason,recID);
        }

        /***************************************************************************
         * save */
        /**
         * Saves data for a single record
         *
         * Note: This calls the save method
         *
         * @param  connSpedmon     Spedmon database connection object
         * @param  log             Logging object
         * @return                 ReturnEntity
         ***************************************************************************/

        public static ReturnSaveRecord save(SqlConnection connUser
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
                                       , string active
                                       , string saveType
                                       , string recID
            )
        {
            return MBA.UserMessages.save(
                connUser, log, uInfo, Constants.APP_NAME, recipientUserIDsStr,
                subject, body, sendEmail, isReply, previousMsgID, okToShow, hasRead,
                respPromptOptions, respPromptOptionsJSON,
                //"", "",
                active, saveType, "0", "", recID
            );
        }
        
        /***************************************************************************
         * delete */
        /**
         * deletes data for a single record
         *
         * Note: This calls the save method
         *
         * @param  connSpedmon     Spedmon database connection object
         * @param  log             Logging object
         * @return                 ReturnEntity
         ***************************************************************************/

        public static ReturnSaveRecord delete(SqlConnection connUser
                                       , DetailsLog log
                                       , UserInfo uInfo
                                       , string recID)
        {
            return MBA.UserMessages.delete(connUser, log, uInfo, Constants.APP_NAME, "0", "", recID);
        }

        /**************************************************************************
         * viewContactsSel */
        /**
         * For client users we want to return what users.ViewSel normally returns
         * and the clients current client rep
         * 
         * For PCAl users we want to return all available contacts 
         ***************************************************************************/

        public static ReturnSel viewSelContacts ( SqlConnection connSpedmon
                                                , SqlConnection connUsers
                                                , DetailsLog log
                                                , UserInfo uInfo
                                                , bool top
                                                , string topSize
                                                , string clientID
                                                , string term)
        {
            string appName = Constants.APP_NAME;
            Object vClientID = Validate.optClientID (uInfo, clientID);
            long? vRepUserID1 = null;
            long? vRepUserID2 = null;
            
            if (!uInfo.pcalStaff) {
                var currUser = Users.load(connUsers, log, uInfo, uInfo.useridStr);
                vRepUserID1 = currUser.clientRepUserId;


                 //vRepUserID2 = 22; /* cmuirhead */
                 ///ommitted cmuirhead from contact result set, as per his request


            }
            return MBA.Users.viewUserMessageContactsSel (connUsers, log, uInfo, appName, top, topSize, vClientID, term, vRepUserID1, vRepUserID2);
        }

    }
}
