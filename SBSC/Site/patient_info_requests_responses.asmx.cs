using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using MBA; 

namespace Spedmon
{
    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]
    public class PatientInfoRequestsResponsesSvc : MBA.WebSvc
    {
        /***************************************************************************
         * savenewrequestinline *
        /**
         **************************************************************************/
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecordWithJSONData savenewrequestinline (
              string clientid
            , string patid
            , string msgtxt
            , string patperids
            , string sendemail
            , string sendtext )
        {
            return (ReturnSaveRecordWithJSONData) callMethod(typeof(ReturnSaveRecordWithJSONData),
                delegate ()
                {
                    return Spedmon.PatientInfoRequestsResponses.saveNewIndividualRequest (
                        this.dbConnApp
                      , this.dbConnUser
                      , this.log
                      , this.uInfo
                      , clientid
                      , patid
                      , msgtxt
                      , patperids
                      , sendemail
                      , sendtext);
                },
                Constants.ROLE_ALL_PCAL_AND_CLIENT
            );
        }

        /***************************************************************************
         * savenewmassrequestinline *
        /**
         **************************************************************************/
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord savenewmassrequestinline (
              string clientid
            , string datasource
            , string requestername
            , string requesteremail
            , string requesterphone )
        {
            return (ReturnSaveRecord) callMethod(typeof(ReturnSaveRecord),
                delegate ()
                {
                    return Spedmon.PatientInfoRequestsResponses.saveNewMassRequest (
                        this.dbConnApp
                      , this.log
                      , this.uInfo
                      , clientid
                      , datasource
                      , requestername
                      , requesteremail
                      , requesterphone);
                },
                Constants.ROLE_ALL_PCAL_AND_CLIENT
            );
        }
       
        /***************************************************************************
         * completereviewresponseinline *
        /**
         **************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord completereviewresponseinline (
              string clientid            
            , string recid
        )
        {
            return (ReturnSaveRecord) callMethod(typeof(ReturnSaveRecord),
                delegate ()
                {
                    return Spedmon.PatientInfoRequestsResponses.completeReviewOfResponse (
                        this.dbConnApp
                      , this.log
                      , this.uInfo
                      , clientid                      
                      , recid );
                },
                Constants.ROLE_ALL_PCAL_AND_CLIENT
            );
        }

        /***************************************************************************
         * cancelrequestinline *
        /**
         **************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord cancelrequestinline (
              string clientid            
            , string recid )
        {
            return (ReturnSaveRecord) callMethod(typeof(ReturnSaveRecord),
                delegate ()
                {
                    return Spedmon.PatientInfoRequestsResponses.cancelRequest (
                        this.dbConnApp
                      , this.log
                      , this.uInfo
                      , clientid                      
                      , recid );
                },
                Constants.ROLE_ALL_PCAL_AND_CLIENT
            );
        }

        
        /***************************************************************************
         * cancelallrequestsinline *
        /**
         **************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord cancelallrequestsinline (
              string clientid            
            , string ageindays )
        {
            return (ReturnSaveRecord) callMethod(typeof(ReturnSaveRecord),
                delegate ()
                {
                    return Spedmon.PatientInfoRequestsResponses.cancellAllRequests (
                        this.dbConnApp
                      , this.log
                      , this.uInfo
                      , clientid                      
                      , ageindays );
                },
                Constants.ROLE_ALL_PCAL_AND_CLIENT
            );
        }        

    }
}