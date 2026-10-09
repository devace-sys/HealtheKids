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
     * InputBatchesInProcessSvc */
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
    public class InputBatchesInProcessSvc : MBA.WebSvc
    {
        public InputBatchesInProcessSvc() : base() { }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord save(
             string filename
           , string clientid
           , string datesent
           , string daterecieved
           , string fileloc
           , string partial
           , string parentid
           , string typeofwork
           , string oldestdos
           , string estinputhrs
           , string userid1
           , string userid2
           , string prtnum
           , string degofdiff
           , string statuscode
           , string notes
           , string recid
           , string savetype
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.InputBatchesInProcess.save(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , filename
                , clientid
                , datesent
                , daterecieved
                , fileloc
                , partial
                , parentid
                , typeofwork
                , oldestdos
                , estinputhrs
                , userid1
                , userid2
                , prtnum
                , degofdiff
                , statuscode
                , notes
                , ""
                , "0"
                , savetype
                , recid);
            },
            Constants.ROLE_SBS_ALL);
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
                return Spedmon.InputBatchesInProcess.delete(this.dbConnApp,
                                           this.log,
                                           this.uInfo,
                                           "",
                                           "0",
                                           recid);
            },
            Constants.ROLE_SBS_ALL);  // Who can call this method           
        }

        /***************************************************************************
        * viewSel */
        /**
        * 
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSel(string clientid, string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate ()
            {
                return Spedmon.InputBatchesInProcess.viewSel(this.dbConnApp, this.log, this.uInfo, false, "", clientid, term);
            },
            Constants.ROLE_SBS_ALL); // Who can call this method    
        }
    }
}
