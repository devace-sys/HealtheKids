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
     * CrcsCommonSvc */
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
    public class CrcsCommonSvc : MBA.WebSvc
    {
        public CrcsCommonSvc() : base() { }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnCRCSCompletionStatus getCompletionStatus(
             string clientid
           , string fiscalyearid
        )
        {
            return (ReturnCRCSCompletionStatus)

            callMethod(typeof(ReturnCRCSCompletionStatus),
            delegate ()
            {
                return Spedmon.CrcsCommon.getCompletionStatus(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , fiscalyearid);
            },
            Constants.ROLE_CRCS_ADMIN);
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveOrReplaceRecord sendcompletednotification(string clientid)
        {
            return (ReturnSaveOrReplaceRecord)

            callMethod(typeof(ReturnSaveOrReplaceRecord),
            delegate ()
            {
                return Spedmon.CrcsCommon.sendCompletedNotification(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid);
            },
            Constants.ROLE_CRCS_ADMIN);
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveOrReplaceRecord savetransportationvehicledata(
             string clientid
           , string fiscalyearid
           , string vehicleratetype
           , string numvehiclesinfleet
           , string numspeciallyadapted
        )
        {
            return (ReturnSaveOrReplaceRecord)

            callMethod(typeof(ReturnSaveOrReplaceRecord),
            delegate ()
            {
                return Spedmon.CrcsCommon.saveTransportationVehicleData(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , fiscalyearid
                , vehicleratetype
                , numvehiclesinfleet
                , numspeciallyadapted);
            },
            Constants.ROLE_CRCS_ADMIN);
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnEntity loadtransportationvehicledata(string clientid
                                            , string fiscalyearid)
        {
            return (ReturnEntity)
            callMethod(typeof(ReturnEntity),
            delegate ()
            {
                ReturnEntity re = new ReturnEntity();
                re.entity = Spedmon.CrcsCommon.loadTransportationVehicleData(
                    this.dbConnApp
                  , this.log
                  , this.uInfo
                  , clientid
                  , fiscalyearid);

                return re;
            },
            Constants.ROLE_CRCS_ADMIN); // Who can call this method    
        }


        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecordWithJSONData importpayrolldataforcalculatedbreakdown(
            string clientid

          , string fiscalyearid
          , string fiscalquarterselection_radiobox_name

          , string datatoimportjson
          , string validaterec)
        {
            var retval = (ReturnSaveRecordWithJSONData)

                callMethod(typeof(ReturnSaveRecordWithJSONData),
                delegate ()
                {

                    return Spedmon.CrcsCommon.importPayrollDataForCalculatedBreakdown(
                      this.dbConnApp
                    , this.log
                    , this.uInfo
                    , clientid

                    , fiscalyearid
                    , fiscalquarterselection_radiobox_name

                    , datatoimportjson
                    , validaterec
                    );
                },

                Constants.ROLE_CDE_COMPLIANCE_MANAGE);  // Who can call this method

            return retval;
        }


    }

}
