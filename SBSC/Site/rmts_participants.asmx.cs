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

    /***************************************************************************
     * RmtsParticipantsSvc */
    /*
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
    public class RmtsParticipantsSvc : MBA.WebSvc
    {
        public RmtsParticipantsSvc() : base() { }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord save(
             string clientid
           , string pracid
           , string rosterid
           , string startdate
           , string enddate
           , string reasonforstartdatechangecode
           , string reasonforenddatechangecode  
           , string hasservicerecords
           , string hasreimbursement
           , string employeerelationshipid
           , string recid
           , string savetype
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.RmtsParticipants.save(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , pracid 
                , rosterid
                , startdate
                , enddate
                , reasonforstartdatechangecode
                , reasonforenddatechangecode  
                , hasservicerecords	
                , hasreimbursement
                , employeerelationshipid
                , ""
                , "1" // validateRec is 1 so we validate start and end date
                , savetype
                , recid);
            },
            Constants.ROLE_CRCS_ADMIN);
        }



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
                // note: this is the only webhandler method that calls an Entities method in RmtsParticipantsWoSvcRecs.
                // that's why I didn't create a separate .asmx filepair for this
                return Spedmon.RmtsParticipantsWoSvcRecs.flagDeferralReason( 
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


    }
}
