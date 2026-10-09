﻿using System;
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
     * CrcsTransportationPersonnelCostsSvc */
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
    public class CrcsTransportationPersonnelCostsSvc : MBA.WebSvc
    {
        public CrcsTransportationPersonnelCostsSvc() : base() { }
 
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord save(
             string clientid
           , string fiscalyearid
           , string totalsalaries
           , string totalbenefits
           , string fedresourceorgrant
           , string recid
           , string savetype
        )
        {
            return (ReturnSaveRecord)
 
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.CrcsTransportationPersonnelCosts.save(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , fiscalyearid
                , totalsalaries
                , totalbenefits
                , fedresourceorgrant
                , ""
                , "0"
                , savetype
                , recid);
            },
            Constants.ROLE_CRCS_ADMIN);
        } 

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord defer(
              string deferred
            , string recid
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.CrcsTransportationPersonnelCosts.defer (
                  this.dbConnApp
                , this.log
                , this.uInfo
                , deferred
                , recid
                );
            },
            Constants.ROLE_CRCS_ADMIN);
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
                return Spedmon.CrcsTransportationPersonnelCosts.delete(this.dbConnApp,
                                           this.log,
                                           this.uInfo,
                                           "",
                                           "0",
                                           recid);
            },
            Constants.ROLE_CRCS_ADMIN);  // Who can call this method           
        }
    }
}