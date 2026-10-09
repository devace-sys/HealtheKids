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
     * CrcsTransportationEquipmentDepreciationCostsSvc */
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
    public class CrcsTransportationEquipmentDepreciationCostsSvc : MBA.WebSvc
    {
        public CrcsTransportationEquipmentDepreciationCostsSvc() : base() { }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord save(
             string clientid
           , string fiscalyearid
           , string assetid
           , string assettype
           , string placedinserviceon
           , string yearsuseful
           , string depreciablecost
           , string fedresourceorgrant
           , string annualdepreciation
           , string retiredduringcostperiod
           , string placedoutofserviceon
           , string accumulateddepreciation
           , string depreciationforreportperiod
           , string recid
           , string savetype
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.CrcsTransportationEquipmentDepreciationCosts.save(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , fiscalyearid
                , assetid
                , assettype
                , placedinserviceon
                , yearsuseful
                , depreciablecost
                , fedresourceorgrant
                , annualdepreciation
                , retiredduringcostperiod
                , placedoutofserviceon
                , accumulateddepreciation
                , depreciationforreportperiod
                , ""
                , "0"
                , savetype
                , recid);
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
                return Spedmon.CrcsTransportationEquipmentDepreciationCosts.delete(this.dbConnApp,
                                           this.log,
                                           this.uInfo,
                                           "",
                                           "0",
                                           recid);
            },
            Constants.ROLE_CRCS_ADMIN);  // Who can call this method           
        }


        /***************************************************************************
        * defer */
        /**
        *
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord defer(
            string clientid
          , string fiscalyearid
          , string deferred
        )
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return CrcsDeferralCommon.defer(this.dbConnApp
                                               , this.log
                                               , this.uInfo
                                               , clientid
                                               , fiscalyearid
                                               , CrcsCommon.TRANSPORTATION_EQUIPMENT_DEPRECIATION_COSTS_TAB_ID
                                               , deferred
                                               , ""
                                               , "0"
                                           );
            },
            Constants.ROLE_CRCS_ADMIN);  // Who can call this method           
        }

        /***************************************************************************
        * getDeferralStatus */
        /**
        *
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnCRCSDeferralStatus getDeferralStatus(
            string clientid
          , string fiscalyearid

        )
        {
            return (ReturnCRCSDeferralStatus)
            callMethod(typeof(ReturnCRCSDeferralStatus),
            delegate ()
            {
                return CrcsDeferralCommon.getDeferralStatus(this.dbConnApp
                                               , this.log
                                               , this.uInfo
                                               , clientid
                                               , fiscalyearid
                                               , CrcsCommon.TRANSPORTATION_EQUIPMENT_DEPRECIATION_COSTS_TAB_ID
                                           );
            },
            Constants.ROLE_CRCS_ADMIN);  // Who can call this method           
        }
    }
}