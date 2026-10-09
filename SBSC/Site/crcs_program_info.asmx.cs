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
     * CrcsProgramInfoSvc */
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
    public class CrcsProgramInfoSvc : MBA.WebSvc
    {
        public CrcsProgramInfoSvc() : base() { }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord save(
             string clientid
           , string fiscalyearid
           , string indirectcostrate
           , string studentcensuspopulation
           , string medicaleligiblestudents
           , string mer
           , string fmaptitlexix
           , string fmaptitlexixenhanced
           , string fmaptitlexxi
           , string fmaptitlexxienhanced
           , string rmtscode2apercentage
           , string contactid
           , string contacttitle
           , string contactemail
           , string providerphone
           , string providerfax
           , string smaa
           , string pracswithzeroreimbursementcosts
           , string crcsbusinessofficialid
           , string crcsbusinessofficialtitle
           , string leabopconsortium
           , string contactinfoverified
           , string personsigninginfoverified
           , string consortiumbillinginfoverified
           , string programinfoverified
           , string lecorlgaid
           , string editDelReason
           , string validaterec
           , string savetype
           , string recid
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.CrcsProgramInfo.save(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , fiscalyearid
                , indirectcostrate
                , studentcensuspopulation
                , medicaleligiblestudents
                , mer
                , fmaptitlexix
                , fmaptitlexixenhanced
                , fmaptitlexxi
                , fmaptitlexxienhanced
                , rmtscode2apercentage
                , contactid
                , contacttitle
                , contactemail
                , providerphone
                , providerfax
                , smaa
                , pracswithzeroreimbursementcosts
                , crcsbusinessofficialid
                , crcsbusinessofficialtitle
                , leabopconsortium
                , contactinfoverified
                , personsigninginfoverified
                , consortiumbillinginfoverified
                , programinfoverified
                , lecorlgaid
                , editDelReason
                , validaterec
                , savetype
                , recid);
            },
            Constants.ROLE_CRCS_ADMIN);
        }

    }
}
