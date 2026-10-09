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
     * RmtsParticipantsNotInSpEdCareSvc */
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
    public class RmtsParticipantsNotInSpEdCareSvc : MBA.WebSvc
    {
        public RmtsParticipantsNotInSpEdCareSvc() : base() { }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord save(
             string pracid
           , string recid
           , string savetype
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.save(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , pracid                
                , ""
                , "1" // validateRec is 1 so we validate start and end date
                , savetype
                , recid);
            },
            Constants.ROLE_SBS_ALL_LEA_COORD);
        }
        
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnRmtsParticipantNotInSpEdCare viewAll(
                                        string clientid
                                      , string fyquarterid
                                      , string rmtsdataimportid
        )
        {
            return (ReturnRmtsParticipantNotInSpEdCare)

            callMethod(typeof(ReturnRmtsParticipantNotInSpEdCare),
            delegate ()
            {
                return Spedmon.StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.viewAll(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , fyquarterid
                , rmtsdataimportid);
            },
            Constants.ROLE_SBS_ALL);
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord delete(string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.delete(this.dbConnApp,
                                           this.log,
                                           this.uInfo,
                                           "",
                                           "0",
                                           recid);
            },
              Constants.ROLE_SBS_ALL_LEA_COORD);  // Who can call this method           
        }
    }
}
