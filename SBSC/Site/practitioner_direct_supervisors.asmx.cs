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
     * PractitionerDirectSupervisorsSvc */
    /*
     * Web services end point 
     *
     * Unless indicated, each of these methdos are for all users
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

    public class PractitionerDirectSupervisorsSvc : MBA.WebSvc
    {
        public PractitionerDirectSupervisorsSvc() : base() { }

        /***************************************************************************
          * oktoshowservicerecordreviewnotificationssetuserpref */
        /**
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveOrReplaceRecord oktoshowservicerecordreviewnotificationssetuserpref(string value)
        {
            return (ReturnSaveOrReplaceRecord)

            callMethod(typeof(ReturnSaveOrReplaceRecord),
            delegate ()
            {

                return Spedmon.PractitionerDirectSupervisedSupervisors.okToShowServiceRecordReviewNotificationsSetUserPref(this.dbConnUser, log, uInfo, value);
            },
            Constants.ROLE_LEA_PROVIDER);  // Who can call this method           
        }

        /***************************************************************************
         * save */
        /**
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord save(string clientid
                                      , string supervisingpracid
                                      , string supervisedpracid
                                      , string startdate
                                      , string enddate
                                      , string sharenotes
                                      , string relationshiptypeid
                                      , string requiresvcrecapprovalfornonprogcomprels
                                      , string savetype
                                      , string recid)
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {

                return Spedmon.PractitionerDirectSupervisedSupervisors.save(
             this.dbConnApp
           , log
           , uInfo
           , clientid
           , supervisingpracid
           , supervisedpracid
           , startdate
           , enddate
           , sharenotes
           , relationshiptypeid
           , requiresvcrecapprovalfornonprogcomprels
           , ""
           , "0"
           , savetype
           , recid);
            },
            Constants.ROLE_PRAC_DIR_SUP_ADMINS);  // Who can call this method           
        }

        /***************************************************************************
         * delete */
        /**
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord delete(string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.PractitionerDirectSupervisedSupervisors.delete(this.dbConnApp,
                                           this.log,
                                           this.uInfo,
                                           "",
                                           "0",
                                           recid);
            },
              Constants.ROLE_PRAC_DIR_SUP_ADMINS);  // Who can call this method           
        }

        /***************************************************************************
         * delete */
        /**
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord undelete(string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.PractitionerDirectSupervisedSupervisors.unDelete(this.dbConnApp,
                                           this.log,
                                           this.uInfo,
                                           "",
                                           "0",
                                           recid);
            },
              Constants.ROLE_PRAC_DIR_SUP_ADMINS);  // Who can call this method           
        }

    }
}
