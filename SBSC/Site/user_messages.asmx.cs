using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.Services.Protocols;
using System.Web.Script.Serialization;
using System.ComponentModel;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * UserMessagesSvc */
    /*
     * Web services end point for Caseload methods.
     *
     * Unless indicated, each of these methods require that the caller is 
     * logged in.
     * 
     * Each end point method provides a wrapper for a coresponding framework
     * method that is not accessible from the outside.
     * 
     * These wrappers handle access control and parameter replacement.
     * 
     * The method is restricted to calls for given user groups
     * 
     * Parameter replacement is used to enforce additional access control within
     * the user group but this is limited.
     *
     * The final line of defense for access control are the database udfs or 
     * sprocs that return or save data
     ***************************************************************************/

    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]

    public class UserMessagesSvc : MBA.WebSvc
    {

        /***************************************************************************
         * viewList */
        /**
        * Get list of records
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnObjects viewList(
                                         string viewSentOnly
                                       , string okToShow
                                       , string hasRead
                                       , string active)
        {
            return (ReturnObjects)

            callMethod(typeof(ReturnObjects),
            delegate ()
            {
                ReturnObjects so = new ReturnObjects(); 
                so.data = Spedmon.UserMessages.viewList
                (  this.dbConnUser
                 , this.log
                 , this.uInfo
                 , viewSentOnly
                 , okToShow
                 , hasRead
                 , @""
                 , @""
                 , active
                ).ToArray();

                return so;
            },
            Constants.ROLE_ALL);  // Who can call this method           
        }
 
        /***************************************************************************
         * save */
        /**
        * Save records
        ***************************************************************************/


        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord save(
                                         string recipientuseridsstr
                                       , string subject
                                       , string body
                                       , string sendEmail
                                       , string isreply
                                       , string previousmsgid
                                       , string oktoshow
                                       , string hasread
                                       , string active
                                       , string savetype
                                       , string recid
                                       //, string respPromptOptions="" // int; bitwise arith
                                       //, string respPromptOptionsJSON=""
                                       )
        {

            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.UserMessages.save
                (  this.dbConnUser
                 , this.log
                 , this.uInfo
                 , recipientuseridsstr
                 , subject
                 , body
                 , sendEmail
                 , isreply
                 , previousmsgid
                 , oktoshow
                 , hasread
                 , null //respPromptOptions
                 , null //respPromptOptionsJSON
                 , active
                 , savetype
                 , recid
                );

            },
            Constants.ROLE_ALL);  // Who can call this method 
          
        }
        
        /***************************************************************************
         * delete */
        /**
        * delete records
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord delete(string recid)
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.UserMessages.delete
                (  this.dbConnUser
                 , this.log
                 , this.uInfo
                 , recid
                );
            },
            Constants.ROLE_ALL);  // Who can call this method           
        }

        /***************************************************************************
        * viewContactsSel */
        /**
        * Selection view of users
        *
        * @param  clientID     Client ID (forced set for client users)
        * @param  term         Required, search term string (blank for all)
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelContacts (string clientid, string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate ()
            {
                return Spedmon.UserMessages.viewSelContacts ( this.dbConnApp
                                                              , this.dbConnUser
                                                              , this.log
                                                              , this.uInfo
                                                              , true
                                                              , ""
                                                              , clientid
                                                              , term );
            },
            Constants.ROLE_SVC_SUP_PRAC); // Who can call this method    
        }

    }
}
