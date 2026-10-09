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

namespace Spedmon
{

    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]

    /***************************************************************************
     * PatientInfoRequestPubInsuranceFormResponsesSvc  */
    /**
     * 
     *************************************************************************/

    public class PatientInfoRequestPubInsuranceFormResponsesSvc : MBA.WebSvc
    {


        public PatientInfoRequestPubInsuranceFormResponsesSvc() : base() { }



        /***************************************************************************
         * saveinline */
        /**
         * 
         * Save or edit
         ***************************************************************************/


        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord saveinline(
          string clientid
        , string patid
        , string insurancecarrierid
        , string memberid
        , string ferpaconsent
        , string savetype
        , string recid)
        {
            return (ReturnSaveRecord)callMethod(
                typeof(ReturnSaveRecord),
                delegate ()
                {
                    return Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.save(

                    this.dbConnApp
                  , this.log
                  , this.uInfo
                  , clientid
                  , patid
                  , insurancecarrierid
                  , memberid
                  , ferpaconsent
                  , ""
                  , "N"
                  , savetype
                  , recid);
                },
                Constants.ROLE_ALL_PCAL_AND_CLIENT);  // TODO ???
        }

        /***************************************************************************
             * acceptresponse */
        /**
         * 
         * Accept the response
         ***************************************************************************/


        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord acceptresponse(
            string clientid
          , string recid)
        {
            return (ReturnSaveRecord)callMethod(
                typeof(ReturnSaveRecord),
                delegate ()
                {
                    return Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.acceptResponse(
                    this.dbConnApp
                  , this.log
                  , this.uInfo
                  , clientid
                  , ""
                  , "N"
                  , recid);
                },
                Constants.ROLE_ALL_PCAL_AND_CLIENT);  // TODO ???
        }

        /***************************************************************************
         * rejectresponse */
        /**
         * 
         * Reject the response
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord rejectresponse(
          string clientid
        , string recid)
        {
            return (ReturnSaveRecord)callMethod(
                typeof(ReturnSaveRecord),
                delegate ()
                {
                    return Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.rejectResponse(

                    this.dbConnApp
                  , this.log
                  , this.uInfo
                  , clientid
                  , ""
                  , "N"
                  , recid);
                },
                Constants.ROLE_ALL_PCAL_AND_CLIENT);  // TODO ???
        }

        /***************************************************************************
         * saveresponsefromportal */
        /**
         * 
         * Save
         ***************************************************************************/


        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord saveresponsefromportal(
          string clientid
        , string patid
        , string patperid
        , string ferpaconsent
        , string respondersignatureimgdata

        , string primaryinsurancecarrierid
        , string primarymemberid
        , string primarypolicygroupid
        , string primarypolicyholdername
        , string primaryinsurancecarrierothername
        , string primarybeneficiaryfirstname
        , string primarybeneficiarylastname

        , string secondaryinsurancecarrierid
        , string secondarymemberid
        , string secondarypolicygroupid
        , string secondarypolicyholdername
        , string secondaryinsurancecarrierothername
        , string secondarybeneficiaryfirstname
        , string secondarybeneficiarylastname
        , string savetype
        , string recid)
        {
            return (ReturnSaveRecord)callMethod(
                typeof(ReturnSaveRecord),
                delegate ()
                {
                    return Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.saveresponsefromportal(
                    this.dbConnApp
                  , this.log
                  , this.uInfo
                  , clientid
                  , patid
                  , patperid
                  , ferpaconsent
                  , respondersignatureimgdata
                  , primaryinsurancecarrierid
                  , primarymemberid
                  , primarypolicygroupid
                  , primarypolicyholdername
                  , primaryinsurancecarrierothername
                  , primarybeneficiaryfirstname
                  , primarybeneficiarylastname
                  , secondaryinsurancecarrierid
                  , secondarymemberid
                  , secondarypolicygroupid
                  , secondarypolicyholdername
                  , secondaryinsurancecarrierothername
                  , secondarybeneficiaryfirstname
                  , secondarybeneficiarylastname
                  , ""
                  , "N"
                  , savetype
                  , recid);
                },
                Constants.ROLE_ALL_PCAL_AND_CLIENT);  // TODO ???
        }

    }
}
