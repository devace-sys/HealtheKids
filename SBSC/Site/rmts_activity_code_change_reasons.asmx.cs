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
     * RMTSAcivityCodeChangeReasonsSvc */
    /*
     * 
     ***************************************************************************/

    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]
    public class RMTSActivityCodeChangeReasonsSvc : MBA.WebSvc
    {
        public RMTSActivityCodeChangeReasonsSvc() : base() { }

        /***************************************************************************
         * saveinline */
        /**
         * Inline save
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord saveinline(
             string rmtsActivityCode
           , string name
           , string recid
           , string savetype
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.RMTSActivityCodeChangeReasons.save(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , rmtsActivityCode
                , name
                , ""
                /*, notes                */
                , ""
                , "0"
                , savetype
                , recid);
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
        public ReturnSaveRecord deleteinline(
            string recid
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.RMTSActivityCodeChangeReasons.delete(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , ""
                , "0"
                , recid);
            },
            Constants.ROLE_SBS_ALL);
        }

        /***************************************************************************
         * viewSel */
        /**
         * Selection view 
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSel viewSel (string rmtsActivityCode, string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate ()
            {
                return Spedmon.RMTSActivityCodeChangeReasons.viewSel(  this.dbConnApp
                                                                     , this.log
                                                                     , this.uInfo
                                                                     , true
                                                                     , ""
                                                                     , rmtsActivityCode
                                                                     , term);
            },
            Constants.ROLE_SBS_ALL); // Who can call this method            
        }

       


    }
}
