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
    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]

    public class PracticeOfficeVisitsSvc : MBA.WebSvc
    {
        
        /***************************************************************************
         * checkinfrompublickiosk */
        /**
         * Note: This is a public method.  Anyone who can access this end point can
         * call the method.
         ***************************************************************************/
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnActionRequest checkinfrompublickiosk (
              string ptkn
            , string studentid
            , string practiceofficevisitreasonid
            , string practiceofficevisitreasonnotes )
        {
          return (ReturnActionRequest)
          callMethod(typeof(ReturnActionRequest),    
          delegate()
          {    
             return Spedmon.PracticeOfficeVisits.checkInFromPublicKiosk (
                      this.dbConnApp 
                    , this.log
                    , this.rd
                    , ptkn
                    , studentid
                    , practiceofficevisitreasonid
                    , practiceofficevisitreasonnotes);                    
          });
        }

        /***************************************************************************
         * checkinfromwaitingroom */
        /**
         * 
         ***************************************************************************/
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord checkinfromwaitingroom (
              string clientid
            , string groupserviceclassnameid
            , string siteid
            , string patid
            , string practiceofficevisitreasonid
            , string practiceofficevisitreasonnotes
            , string pracid
            , string savetype
            , string recid )
        {

            return (ReturnSaveRecord)
            callMethod (
              typeof(ReturnSaveRecord)
            , delegate ()
            {                
                return Spedmon.PracticeOfficeVisits.checkInFromWaitingRoom (
                      this.dbConnApp 
                    , this.log
                    , this.uInfo
                    , this.rd
                    , clientid
                    , groupserviceclassnameid
                    , siteid
                    , patid                    
                    , practiceofficevisitreasonid
                    , practiceofficevisitreasonnotes
                    , pracid
                    , savetype
                    , recid
                );
            }
            , Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        
        /***************************************************************************
         * endvisit */
        /**
         * 
         ***************************************************************************/
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord endvisit (
              string clientid
            , string pracid
            , string checkindate
            , string checkintime
            , string visitstartdate
            , string visitstarttime
            , string visitenddate
            , string visitendtime
            , string practiceofficevisitresolutionid
            , string practiceofficevisitresolutionnotes
            , string practiceofficevisitresolutionfbquestionsjson
            , string practiceofficevisitresolutionfbanswersjson
            , string recid )
        {

            return (ReturnSaveRecord)
            callMethod (
              typeof(ReturnSaveRecord)
            , delegate ()
            {                
                return Spedmon.PracticeOfficeVisits.endVisit (
                      dbConnApp 
                    , log
                    , uInfo
                    , clientid
                    , pracid
                    , checkindate
                    , checkintime
                    , visitstartdate
                    , visitstarttime
                    , visitenddate
                    , visitendtime
                    , practiceofficevisitresolutionid
                    , practiceofficevisitresolutionnotes   
                    , practiceofficevisitresolutionfbquestionsjson
                    , practiceofficevisitresolutionfbanswersjson
                    , recid
                );
            }
            , Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        /***************************************************************************
         * savevisitinprogress */
        /**
         * 
         ***************************************************************************/
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord savevisitinprogress(
              string clientid
            , string pracid
            , string checkindate
            , string checkintime
            , string visitstartdate
            , string visitstarttime
            , string visitenddate
            , string visitendtime
            , string practiceofficevisitresolutionid
            , string practiceofficevisitresolutionnotes
            , string practiceofficevisitresolutionfbquestionsjson
            , string practiceofficevisitresolutionfbanswersjson
            , string recid)
        {

            return (ReturnSaveRecord)
            callMethod(
              typeof(ReturnSaveRecord)
            , delegate ()
            {
                return Spedmon.PracticeOfficeVisits.visitInProgress(
                      dbConnApp
                    , log
                    , uInfo
                    , clientid
                    , pracid
                    , checkindate
                    , checkintime
                    , visitstartdate
                    , visitstarttime
                    , visitenddate
                    , visitendtime
                    , practiceofficevisitresolutionid
                    , practiceofficevisitresolutionnotes
                    , practiceofficevisitresolutionfbquestionsjson
                    , practiceofficevisitresolutionfbanswersjson
                    , recid
                );
            }
            , Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }


        /***************************************************************************
         * deleteinline */
        /**
         * "delete" a record.
         * 
         * @param  recid         Record id to delete
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]        
        public ReturnSaveRecord deleteinline(string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.PracticeOfficeVisits.delete(this.dbConnApp,
                                             this.log,
                                             this.uInfo,
                                             "",
                                             "N",
                                             recid);
            },
        Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }


        /***************************************************************************
         * saveinline */
        /**
         * 
         ***************************************************************************/
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord editcompletedvisit (
              string clientid
            , string pracid
            , string visitstartdate
            , string visitstarttime
            , string visitenddate
            , string visitendtime
            , string practiceofficevisitresolutionid
            , string practiceofficevisitresolutionnotes
            , string practiceofficevisitresolutionfbquestionsjson
            , string practiceofficevisitresolutionfbanswersjson
            , string recid )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
              return Spedmon.PracticeOfficeVisits.editCompletedVisit(
              this.dbConnApp
            , this.log
            , this.uInfo
            , clientid
            , pracid
            , visitstartdate
            , visitstarttime
            , visitenddate
            , visitendtime
            , practiceofficevisitresolutionid
            , practiceofficevisitresolutionnotes
            , practiceofficevisitresolutionfbquestionsjson
            , practiceofficevisitresolutionfbanswersjson
            , recid);
            }
            , Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }
    }
}
