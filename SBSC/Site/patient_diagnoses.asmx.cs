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

    public class PatientDiagnosesSvc : MBA.WebSvc
    {
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSel(string clientid, string patid)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate ()
            {
                return Spedmon.PatientDiagnoses.viewSel(dbConnApp
                                                            , log
                                                            , uInfo
                                                            , false
                                                            , ""
                                                            , "Y"
                                                            , clientid
                                                            , patid
                                                            );
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
        }


        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord saveinline(
                                                     string clientid
                                                   , string patid
                                                   , string diagnosisid
                                                   , string savetype
                                                   , string recid)
        {

            return (ReturnSaveRecord)callMethod(
           typeof(ReturnSaveRecord),
           delegate ()
           {
               return Spedmon.PatientDiagnoses.save(

                    this.dbConnApp
                  , this.log
                  , this.uInfo
                  , clientid
                  , patid
                  , diagnosisid
                  , ""
                  , "N"
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
                return Spedmon.PatientDiagnoses.delete(this.dbConnApp,
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
