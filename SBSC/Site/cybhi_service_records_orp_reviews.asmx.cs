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
     * CybhiServiceRecordsOrpReviewsSvc */
    /*
     * Web services end point.
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

    public class CybhiServiceRecordsOrpReviewsSvc : MBA.WebSvc
    {

        /***************************************************************************
         * acceptrecsinline */
        /**
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord acceptrecsinline(string clientid
                                                , string reviewingpracid
                                                , string reviewrecids)
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.CybhiServiceRecordsOrpReviews.acceptRecs(
              this.dbConnApp
            , this.log
            , this.uInfo
            , clientid
            , reviewingpracid
            , reviewrecids
            , "N");
            },
            Constants.ROLE_CYBHI_ORP_REVIEW_SVC_RECS);  // Who can call this method
        }

        /***************************************************************************
          * acceptrecinline */
        /**
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord acceptrecinline(string clientid
                                                , string reviewingpracid
                                                , string reviewrecid)
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.CybhiServiceRecordsOrpReviews.acceptRec(
              this.dbConnApp
            , this.log
            , this.uInfo
            , clientid
            , reviewingpracid
            , reviewrecid
            , "N");
            },
            Constants.ROLE_CYBHI_ORP_REVIEW_SVC_RECS);  // Who can call this method
        }

        /***************************************************************************
         * acceptrecwithnotesinline */
        /**
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord acceptrecwithnotesinline(string clientid
                                                         , string reviewingpracid
                                                         , string notes
                                                         , string sendreviewnotestorenderingprac
                                                         , string reviewrecid)
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.CybhiServiceRecordsOrpReviews.acceptRecWithNotes(
              this.dbConnApp
            , this.log
            , this.uInfo
            , clientid
            , reviewingpracid
            , notes
            , sendreviewnotestorenderingprac
            , reviewrecid
            , "N");
            },
            Constants.ROLE_CYBHI_ORP_REVIEW_SVC_RECS);  // Who can call this method
        }

        /***************************************************************************
         * rejectrecinline */
        /**
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord rejectrecinline(string clientid
                                                  , string reviewingpracid
                                                  , string notes
                                                  , string reviewrecid)
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.CybhiServiceRecordsOrpReviews.rejectRec(
              this.dbConnApp
            , this.log
            , this.uInfo
            , clientid
            , reviewingpracid
            , notes
            , reviewrecid
            , "N");
            },
            Constants.ROLE_CYBHI_ORP_REVIEW_SVC_RECS);  // Who can call this method
        }


    }
}
