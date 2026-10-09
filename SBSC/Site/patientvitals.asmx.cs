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
     * PatientVitalsSvc */
    /*
     * Web services end point for Patient Vitals Measurements methods
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
    public class PatientVitalsSvc : MBA.WebSvc
    {
        public PatientVitalsSvc() : base() { }
       

        /***************************************************************************
         * deleteinline */
        /**
         * "delete" a patient vitals measurements record.
         * 
         * @param  recid         Record id to delete
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord deleteinline(string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.PatientVitalsMeasurements.delete(this.dbConnApp,
                                                             this.log,
                                                             this.uInfo,
                                                             @"",
                                                             "0",
                                                             recid);
            },
              Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        /***************************************************************************
            * saveinline */
        /**
        * Save patient vitals measurements records
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord saveinline(string clientid
                                            , string patid
                                            , string temp
                                            , string pulserate
                                            , string respiratoryrate
                                            , string bloodpressuresys
                                            , string bloodpressuredia
                                            , string o2saturation
                                            , string bloodglucose
                                            , string heightft
                                            , string heightinch
                                            , string weightlb
                                            , string savetype
                                            , string recid
            )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.PatientVitalsMeasurements.save(this.dbConnApp
                                                            , this.log
                                                            , this.uInfo
                                                            , clientid
                                                            , patid
                                                            , temp
                                                            , pulserate
                                                            , respiratoryrate
                                                            , bloodpressuresys
                                                            , bloodpressuredia
                                                            , o2saturation
                                                            , bloodglucose
                                                            , heightft
                                                            , heightinch
                                                            , weightlb
                                                            , ""
                                                            , "0"
                                                            , savetype
                                                            , recid
            );
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

    }
}
