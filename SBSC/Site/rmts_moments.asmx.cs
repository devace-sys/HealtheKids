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
using System.IO;




namespace Spedmon
{

    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]

    public class RmtsMatchingSvc : MBA.WebSvc
    {



        public RmtsMatchingSvc() : base() { }




        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord flagdeferralreason (
                                             string recid
                                           //, string deferraldate
                                           , string deferralreason
                                           , string deferralreasonnotes
                                           , string clientid
                                           , string isdeferred
                                           )
        {

            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {

                return Spedmon.RmtsMoments.flagDeferralReason( 
                                              this.dbConnApp
                                            , this.log
                                            , this.uInfo

                                            , recid
                                           //, deferraldate
                                           , deferralreason
                                           , deferralreasonnotes

                                           , clientid
                                           , isdeferred
                                            );
            },
              Constants.ROLE_RMTS_ADMINS_AND_PRACS );  // Who can call this method           
        }



        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnObject statsmissingforclient
		(
           string clientid
        )
        {
            return (ReturnObject)

            callMethod(typeof(ReturnObject),
            delegate ()
            {
                return Spedmon.RmtsMomentMissingOrUndocumentedStatsObjs.viewStatsMissingOrUndocumented(
		            this.dbConnApp,
		            this.log,
		            this.uInfo,
	                clientid
                );

            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }




        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord saveinline(
                                           string clientid,
                                           string notes,
                                           string fyquarterid2
                                           )
        {

            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {

                return Spedmon.RmtsMoments.RMTS_UploadXLSJson(
                                              this.dbConnApp
                                            , this.log
                                            , this.uInfo
                                            , clientid
                                            , notes
                                            , fyquarterid2
                                            );
            },
              Constants.ROLE_ALL);  // Who can call this method           
        }


        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord launch_automatch(
                                   string clientid
                                   )
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {

                return Spedmon.RmtsMoments.RMTS_LaunchAutoMatch(
                                              this.dbConnApp
                                            , this.log
                                            , this.uInfo
                                            , clientid
                                            );
            },
              Constants.ROLE_ALL);  // TODO: let's audit everywhere we're using ROLE_ALL in the webmethod handlers
                                    // for RMTS / TSP functionality.  We're probably mostly okay with permissions further
                                    // down the stack, but using ROLE_ALL at the url level should still give us pause.

                                    // Let's avail ourselves to the newly-created roleset, ROLE_RMTS_ADMINS_AND_PRACS
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord sendUpdatedMatch(
                                           string clientid,
                                            string matching_audit_req
                                          , string matching_rmtssvcrec
                                           )
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {

                return Spedmon.RmtsMoments.sendUpdatedMatch(
                                              this.dbConnApp
                                            , this.dbConnUser
                                            , this.log
                                            , this.uInfo
                                            , clientid
                                            , matching_audit_req
                                            , matching_rmtssvcrec
                                            );
            },

            Constants.ROLE_RMTS_ADMINS_AND_PRACS);
            //  the handshake icon and option renders when a prac receives a messages prompting them to document an RMTS... big if true
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord sendUndoMatch(
                                               //string clientid,
                                                string  matching_audit_req
                                              , string  clientid
                                               )
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {

                return Spedmon.RmtsMoments.sendUndoMatch(
                                              this.dbConnApp
                                            , this.log
                                            , this.uInfo

                                            , matching_audit_req
                                            , clientid
                                            );
            },
              Constants.ROLE_RMTS_ADMINS);  // Who can call this method           
        }


        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord sendupdatedpracid(
                                                //string clientid,
                                                string rmts_mmt_id
                                              , string clientid
                                              , string pracid
                                               )
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {

                return Spedmon.RmtsMoments.sendUpdatedPracID(
                                              this.dbConnApp
                                            , this.log
                                            , this.uInfo

                                            , rmts_mmt_id
                                            , clientid
                                            , pracid
                                            );
            },
              Constants.ROLE_RMTS_ADMINS);  // Who can call this method           
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord sendFlaggedComplete(
                                               //string clientid,
                                               string matching_audit_req
                                             , string clientid
                                               )
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {

                return Spedmon.RmtsMoments.sendFlaggedComplete(
                                              this.dbConnApp,
                                              this.dbConnUser
                                            , this.log
                                            , this.uInfo
                                            //, clientid
                                            , matching_audit_req
                                            , clientid
                                            );
            },
            Constants.ROLE_RMTS_ADMINS_AND_PRACS);  // NOTE: this method is called invisibly after closing the fileUp dialog, from
                                                    // the Requires Action tab (not called when the fileUp is viewed from the Matched/Done tab).

                                                    // Renders a visible error dialog if one opens and closes the fileup, without upping a file,
                                                    // on the Required Action tab.  A bit of a nag, but a useful nag.
        }


        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord sendpracrsvpcomplete(
                                               //string clientid,
                                               string recid
                                               )
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {

                return Spedmon.RmtsMoments.sendPracRsvpComplete(
                                              this.dbConnApp,
                                              this.dbConnUser
                                            , this.log
                                            , this.uInfo
                                            //, clientid
                                            , recid
                                            );
            },
            Constants.ROLE_CLIENT_ALL);  // Who can call this method           
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        // TODO: only known spot this handler is called from is the under-construction management screen, not implemented.
        //       we are using the sendUndoMatch() handler instead.
        public ReturnSaveRecord sendFlaggedIncomplete(
                                               //string clientid,
                                               string matching_audit_req
                                               )
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {

                return Spedmon.RmtsMoments.sendFlaggedIncomplete(
                                              this.dbConnApp
                                            , this.log
                                            , this.uInfo
                                            //, clientid
                                            , matching_audit_req
                                            );
            },
            Constants.ROLE_RMTS_ADMINS);  // Who can call this method
        }


        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord rmtsmomentpcalreview(
            string rmtsMomentID,
            string pcalReviewSstatus,
            string suggestedActivityCode,
            string reason,
            string notes
        )
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                // TODO: i dont remember if this is being used anywhere
                return Spedmon.RmtsMoments.sendFlaggedPcalReview(
                                              this.dbConnApp
                                            , this.log
                                            , this.uInfo


                                            , rmtsMomentID
                                            , pcalReviewSstatus
                                            , suggestedActivityCode
                                            , reason
                                            , notes

                );

            },
            Constants.ROLE_RMTS_ADMINS);  // Who can call this method           
        }



        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord msgSave(
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
                                       )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.RmtsMoments.msgSave
                (this.dbConnUser
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
                 , MBA.HttpApplication.getParameter("respPromptOptions")
                 , MBA.HttpApplication.getParameter("respPromptOptionsJSON")
                     // TODO: these have to be URL string params, which we can only get with getParameter().
                     //       The messagesWidget(opts) constructor doesn't allow us to specific arbitrary fields in the JSON request payload.

                 //, ""
                 //, ""

                 , active
                 , savetype
                 , recid
                 , this.dbConnApp
                );
            },
            Constants.ROLE_RMTS_ADMINS_AND_PRACS);  // Who can call this method           
        }


    }
}
