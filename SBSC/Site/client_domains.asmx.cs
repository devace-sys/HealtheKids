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
     * ClientDomainsSvc */
    /*
     * 
     ***************************************************************************/

    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]
    public class ClientDomainsSvc : MBA.WebSvc
    {
        public ClientDomainsSvc() : base() { }

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
           , string domain
           /*, string notes           */
           , string recid
           , string savetype
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.ClientDomains.save(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , domain
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
        public ReturnSaveRecord deleteinline (
             string clientid
           , string recid
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.ClientDomains.delete (
                  this.dbConnApp
                , this.log
                , this.uInfo
                , ""
                , "0"
                , clientid
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
        public ReturnSel viewSel(string clientid,  string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate ()
            {
                return Spedmon.ClientDomains.viewSel(  this.dbConnApp
                                                      , this.log
                                                      , this.uInfo
                                                      , true
                                                      , ""
                                                      , clientid
                                                      , term );
            },
            Constants.ROLE_SBS_ALL); // Who can call this method            
        }
    }
}
