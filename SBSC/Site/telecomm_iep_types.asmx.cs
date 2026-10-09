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
    * TelecommIEPTypes */
    /*
     * Web services end point for entity methods
     *
     * Unless indicated, each of these methods require that the caller is
     * logged in.
     *
     * Each end point method provides a wrapper for a corresponding framework
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

    public class TelecommIEPTypesSvc : MBA.WebSvc
    {
        public TelecommIEPTypesSvc() : base() { }

        /***************************************************************************
         * delete */
        /**
         * "delete" a entity record record.
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
            delegate ()
            {
                return Spedmon.TeleCommIEPTypes.delete(this.dbConnApp,
                                           this.log,
                                           this.uInfo,
                                           editDelReason,
                                           validaterec,
                                           recid);
            },
            Constants.ROLE_SBS_ALL);  // Who can call this method          
        }


        /***************************************************************************
         * save */
        /**
         * Save entity records
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord save
        (
           string name,
           string formData,
           string formsJSON,
           string editDelReason,
           string validaterec,
           string savetype,
           string recid
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.TeleCommIEPTypes.save
                   (this.dbConnApp,
                    this.log,
                    this.uInfo,
                    name,
                    formData,
                    formsJSON,
                    editDelReason,
                    validaterec,
                    savetype,
                    recid);
            },
                Constants.ROLE_SBS_ALL);  // Who can call this method          
        }

        /***************************************************************************
        * viewSel */
        /**
        * Selection Telecomm IEP types
        *
        * @param  term         Required, search term string (blank for all)
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSel viewSel (string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate ()
            {
                return Spedmon.TeleCommIEPTypes.viewSel(this.dbConnApp, this.log, this.uInfo, false, "", term);
            },
            Constants.ROLE_ADMIN_CONSULTANT_LEA_BO_PRAC); // Who can call this method    
        }

    }
}