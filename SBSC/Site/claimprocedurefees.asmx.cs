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
     * ClaimProcedureFeesSvc */
    /*
     * Web services end point for ClaimProcedure methods
     *
     * Unless indicated, each of these methdos are for sbs users only
     *
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

    public class ClaimProcedureFeesSvc : MBA.WebSvc
    {
        public ClaimProcedureFeesSvc() : base() { }

       /***************************************************************************
        * delete */
       /**
        * "delete" a ClaimProcedureFee record.
        * 
        * @param  validaterec   Required, True=Yes, False=No
        * @param  editDelReason Reason for delete
        * @param  recid         Record id to delete
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord delete(
                                      string editDelReason,
                                      string validaterec,
                                      string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate()
            {
                return Spedmon.ClaimProcedureFees.delete(this.dbConnApp,
                                                   this.log,
                                                   this.uInfo,
                                                   editDelReason,
                                                   validaterec,
                                                   recid);
            },
              Constants.ROLE_SBS_MGMT);  // Who can call this method           
        }

        /***************************************************************************
         * save */
        /**
         * Save Claim Procedure fee records
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord save
          (string procID,           
           string startDate,
           string fee,          
           string editDelReason,
           string validaterec,
           string savetype,
           string recid)
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate()
            {
                return Spedmon.ClaimProcedureFees.save
                 (this.dbConnApp,
                  this.log,
                  this.uInfo,
                  procID,
                  startDate,
                  fee,
                  editDelReason,
                  validaterec,
                  savetype,
                  recid);
            },
            Constants.ROLE_SBS_MGMT);  // Who can call this method           
        }


        /***************************************************************************
         * save */
        /**
         * Save Claim Procedure fee records
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        /*
         *         public static ReturnSaveRecordWithJSONData updateServiceFees (  SqlConnection connSpedmon
                                                                       , DetailsLog    log
                                                                       , UserInfo      uInfo
                                                                       , string        procModCombosStr
                                                                       , string        serviceFee      
                                                                       , string        over17Fee       
                                                                       , string        under18Fee      
                                                                       , string        validate)

         */
        public ReturnSaveRecordWithJSONData updateservicefees (   string        procmodcombosstr
                                                                 , string       servicefee      
                                                                 , string       over17fee       
                                                                 , string       under18fee     
                                                                 , string       billingprogramid
                                                                 , string       validate)
        {
            return (ReturnSaveRecordWithJSONData)

            callMethod(typeof(ReturnSaveRecordWithJSONData),
            delegate()
            {
                return Spedmon.ClaimProcedureFees.updateServiceFees (
                    this.dbConnApp
                  , this.log
                  , this.uInfo
                  , procmodcombosstr
                  , servicefee
                  , over17fee
                  , under18fee
                  , billingprogramid
                  , validate );
            },
            Constants.ROLE_SBS_ALL);  // Who can call this method           
        }

    }
}
