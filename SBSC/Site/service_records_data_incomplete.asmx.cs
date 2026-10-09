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
     * ServiceRecordsDataIncompleteSvc */
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
    public class ServiceRecordsDataIncompleteSvc : MBA.WebSvc
    {
        public ServiceRecordsDataIncompleteSvc() : base() { }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord save (
             string reference
           , string dos
           , string clientid
           , string pracid
           , string patid
           , string isiep
           , string nameid
           , string hasorpdocid
           , string orpdocid
           , string hassvcdetflags
           , string svcdetflag1
           , string svcdetflag2
           , string svcdetflag3
           , string svcdetflag4           
           , string nummins
           , string recid
           , string savetype
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.ServiceRecordsDataIncomplete.save (
                    this.dbConnApp
                  , this.log
                  , this.uInfo
                  , reference                
                  , dos
                  , clientid
                  , pracid
                  , patid
                  , isiep
                  , nameid
                  , hasorpdocid
                  , orpdocid
                  , hassvcdetflags
                  , svcdetflag1
                  , svcdetflag2
                  , svcdetflag3
                  , svcdetflag4
                  , nummins                  
                  , ""
                  , "0"
                  , savetype
                  , recid );
            },
            Constants.ROLE_SBS_ALL_LEA_COORD_AND_ASSIST);
        }

        /***************************************************************************
        * deleteinline */
        /**
         * Deactivates a question form record.
         *
         * @param  recid         Record id to deactivate
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord deleteinline(string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.ServiceRecordsDataIncomplete.delete(
                    this.dbConnApp,
                    this.log,
                    this.uInfo,
                    @"",
                    "0",
                    recid);
            },
            Constants.ROLE_SBS_ALL_LEA_COORD_AND_ASSIST);
        }
    }
}
