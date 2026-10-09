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
     * CrcsPracSalariesSvc */
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
    public class CrcsPracSalariesSvc : MBA.WebSvc
    {
        public CrcsPracSalariesSvc() : base() { }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord save(
             string clientid
           , string pracid
           , string fiscalyearid
           , string quarternumber
           , string employeerelationshipid
           //, string hoursworkedthisquarter
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
                return Spedmon.CrcsPracSalaries.save(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , pracid
                , fiscalyearid
                , quarternumber
                , employeerelationshipid
                //, hoursworkedthisquarter
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


        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord saveHoursWorked_FY(
                 string clientid
               , string pracid
               , string fiscalyearid
               , string hoursWorked

               , string recid
            )
            {
                return (ReturnSaveRecord)

                callMethod(typeof(ReturnSaveRecord),
                delegate ()
                {
                    return Spedmon.CrcsPracSalaries.saveHoursWorked_FY(
                      this.dbConnApp
                    , this.log
                    , this.uInfo
                    , clientid
                    , pracid
                    , fiscalyearid

                    , hoursWorked

                    //, string editDelReason
                    //, string validateRec

                    , recid);
                },
                Constants.ROLE_CRCS_ADMIN);
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveOrReplaceRecord saveorreplacecompletedflag(
             string clientid
           , string fiscalyearid
           , string quarternumber
           , string completed
        )
        {
            return (ReturnSaveOrReplaceRecord)

            callMethod(typeof(ReturnSaveOrReplaceRecord),
            delegate ()
            {
                return Spedmon.CrcsCategoriesCompleted.saveOrReplace(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , fiscalyearid
                , quarternumber
                , CrcsCommon.SALARY_BENEFITS_TAB_ID
                , completed);
            },
            Constants.ROLE_SBS_ALL);
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnEntity loadcompletedflag(string clientid
                                            , string fiscalyearid
                                            , string quarternumber )
        {
            return (ReturnEntity)
            callMethod(typeof(ReturnEntity),
            delegate ()
            {
                ReturnEntity re = new ReturnEntity();
                re.entity = Spedmon.CrcsCategoriesCompleted.load(
                    this.dbConnApp
                  , this.log
                  , this.uInfo
                  , clientid
                  , fiscalyearid
                  , quarternumber
                  , CrcsCommon.SALARY_BENEFITS_TAB_ID);

                return re;
            },
            Constants.ROLE_SBS_ALL); // Who can call this method    
        }
    }
}
