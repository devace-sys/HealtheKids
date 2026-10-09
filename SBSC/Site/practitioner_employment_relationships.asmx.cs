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
     * PractitionerEmploymentRelationshipsSvc */
    /*
     * 
     ***************************************************************************/

    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]
    public class PractitionerEmploymentRelationshipsSvc : MBA.WebSvc
    {
        public PractitionerEmploymentRelationshipsSvc() : base() { }

        /***************************************************************************
         * saveinline */
        /**
         * Inline save
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord saveinline (
             string clientid
           , string pracid
           , string employmentrelationshipid
           , string startdate
           , string enddate
           , string notes
           , string recid
           , string savetype
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.PractitionerEmploymentRelationships.save (
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , pracid
                , employmentrelationshipid
                , startdate
                , enddate
                , notes
                , ""
                , "0"
                , savetype
                , recid );
            },
            Constants.ROLE_SBS_ALL);
        }

        /***************************************************************************
         * deleteinline */
        /**
         * Inline delete
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord deleteinline (
             string clientid
           , string pracid
           , string recid
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.PractitionerEmploymentRelationships.delete (
                  this.dbConnApp
                , this.log
                , this.uInfo
                , ""
                , "0"
                , clientid
                , pracid
                , recid );
            },
            Constants.ROLE_SBS_ALL);
        }

       
    }
}
