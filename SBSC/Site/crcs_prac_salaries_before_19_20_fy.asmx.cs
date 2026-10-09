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
     * CrcsPracSalariesBefore1920FYSvc */
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
    public class CrcsPracSalariesBefore1920FYSvc : MBA.WebSvc
    {
        public CrcsPracSalariesBefore1920FYSvc() : base() { }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord save(
             string clientid
           , string pracid
           , string fiscalyearid
           , string employeerelationshipid
           , string salary
           , string federalsalary
           , string federalsalaryresourcecode
           , string benefits
           , string federalbenefits
           , string federalbenefitsresourcecode
           , string clientemployeeid
           , string recid
           , string savetype
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.CrcsPracSalariesBefore1920FY.save(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , pracid
                , fiscalyearid
                , employeerelationshipid
                , salary                     
                , federalsalary				
                , federalsalaryresourcecode 
                , benefits                  
                , federalbenefits
                , federalbenefitsresourcecode
                , clientemployeeid
                , ""
                , "0"
                , savetype
                , recid);
            },
            Constants.ROLE_CRCS_ADMIN);
        }
    }
}
