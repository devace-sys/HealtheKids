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
     * ClaimProceduresSvc */
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

    public class ClaimProceduresSvc : MBA.WebSvc
    {
        public ClaimProceduresSvc() : base() { }

        /***************************************************************************
       * delete */
        /**
        * "delete" a ClaimProcedure record.
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
                return Spedmon.ClaimProcedures.delete(this.dbConnApp,
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
         * Save client records
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord save
          (string   noPlanNameID,
           string   IEP_IFSPNameID,
           string   proccode,
           string   procmod1,
           string   procmod2,
           string   procmod3,
           string   name,
           string   dateEffective,
           string   dateExpires,
           string   IEPRequired,
           string   svcFee,
           string   maxUnits,
           string   maxSvcUnits,
           string   TCMlowRate,
           string   TCMmedRate,
           string   TCMhighRate,
           string   over17Fee,
           string   under18Fee,
           string   pageNum,
           string   diagnosisCode,
           string   yearlyFlag,
           string   putIn837,
           string   combIntoProxy,
           string   linkToSvc,
           string   editDelReason,
           string   validaterec,
           string   savetype,
           string   recid)
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate()
            {
                return Spedmon.ClaimProcedures.save
                 (this.dbConnApp,
                  this.log,
                  this.uInfo,
                  noPlanNameID,
                  IEP_IFSPNameID,
                  proccode,
                  procmod1,
                  procmod2,
                  procmod3,
                  name,
                  dateEffective,
                  dateExpires,
                  IEPRequired,
                  svcFee,
                  maxUnits,
                  maxSvcUnits,
                  TCMlowRate,
                  TCMmedRate,
                  TCMhighRate,
                  over17Fee,
                  under18Fee,
                  pageNum,
                  diagnosisCode,
                  yearlyFlag,
                  putIn837,
                  combIntoProxy,
                  linkToSvc,
                  editDelReason,
                  validaterec,
                  savetype,
                  recid);
            },
            Constants.ROLE_SBS_MGMT);  // Who can call this method           
        }

        /***************************************************************************
         * viewSelNoPlanNamesList */
        /**
         * Selection view of NoPlanNamesList
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelNoPlanNamesList(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate()
            {
                return Spedmon.ClaimProcedures.NoPlanNamesviewSel(this.dbConnApp, this.log, this.uInfo, false, "",term);
            },
            Constants.ROLE_SBS_MGMT); // Who can call this method
        }

        /***************************************************************************
        * viewSelIEPandIFSPNamesList */
        /**
         * Selection view of IEPandIFSPNamesList
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelIEPandIFSPNamesList(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate()
            {
                return Spedmon.ClaimProcedures.IEPandIFSPNamesviewSel(this.dbConnApp, this.log, this.uInfo, false, "",term);
            },
            Constants.ROLE_SBS_MGMT); // Who can call this method
        }

        /***************************************************************************
         * viewSel */
        /**
         * Selection view of claimprocedures
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSel(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate()
            {
                return Spedmon.ClaimProcedures.viewSel(this.dbConnApp, this.log, this.uInfo, false,"",term); 
            },
            Constants.ROLE_SBS_MGMT); // Who can call this method
        }

        /***************************************************************************
        * viewSelProcedureModifiersList */
        /**
         * Selection view of ProcedureModifiersList
         ***************************************************************************/

        //[WebMethod]
        //[ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        //public ReturnSel viewSelProcedureModifiersList()
        //{
        //    return (ReturnSel)
        //    callMethod(typeof(ReturnSel),
        //    delegate()
        //    {
        //        return Spedmon.ClaimProcedures.procedureModifiersviewSel(this.dbConnApp, this.log, this.uInfo, false, "");
        //    },
        //    Constants.ROLE_SBS_MGMT); // Who can call this method
        //}


    }
}
