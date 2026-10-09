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

    public class patientknownhealthproblemssvc : MBA.WebSvc
    {
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSel(string clientId, string patID)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate ()
            {
                return Spedmon.PatientKnownHealthProblems.viewSel(dbConnApp
                                                            , log
                                                            , uInfo
                                                            , false
                                                            , ""
                                                            , "Y"
                                                            , clientId
                                                            , patID
                                                            );
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord save(
                                                     string clientid
                                                   , string patid
                                                   , string knownhealthproblemid
                                                   , string ispriority
                                                   , string notes
                                                   , string editDelReason
                                                   , string validaterec 
                                                   , string savetype
                                                   , string recid)
        {

            return (ReturnSaveRecord)callMethod(
           typeof(ReturnSaveRecord),
           delegate ()
           {
               return Spedmon.PatientKnownHealthProblems.save(

                    this.dbConnApp
                  , this.log
                  , this.uInfo
                  , clientid
                  , patid
                  , knownhealthproblemid
                  , ispriority
                  , notes
                  , editDelReason
                  , validaterec
                  , savetype
                  , recid);
           },
           Constants.ROLE_ALL_PCAL_AND_CLIENT);
        }
        /***************************************************************************
     * deleteinline */
        /**
         * "delete" a patient record.
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
                return Spedmon.PatientKnownHealthProblems.delete(this.dbConnApp,
                                             this.log,
                                             this.uInfo,
                                             "",
                                             "N",
                                             recid);
            },
        Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

    }
}
