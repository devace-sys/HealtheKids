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

    /***************************************************************************
     * SpEdAccommodationLookupsSvc */
    /**
     * Web services end point for SpEd Accommodation Lookups
     ***************************************************************************/

    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]

    public class SpEdAccommodationLookupsSvc : MBA.WebSvc
    {

        /***************************************************************************
         * viewSel */
        /**
         * View selection list - active lookup values for a given lookup type
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSel(string lookuptype, string domaincode, string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdAccommodationLookups.viewSel(dbConnApp, log, uInfo, false, "", "1", lookuptype, domaincode, term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelCategoryAccommodation */
        /**
         * Accommodation categories
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelCategoryAccommodation(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdAccommodationLookups.viewSel(dbConnApp, log, uInfo, false, "", "1", "CATEGORY", "ACCOMMODATION", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelCategoryModification */
        /**
         * Modification categories
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelCategoryModification(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdAccommodationLookups.viewSel(dbConnApp, log, uInfo, false, "", "1", "CATEGORY", "MODIFICATION", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelCategoryPersonnel */
        /**
         * Personnel support categories
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelCategoryPersonnel(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdAccommodationLookups.viewSel(dbConnApp, log, uInfo, false, "", "1", "CATEGORY", "PERSONNEL", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelAppliesTo */
        /**
         * Applies to values
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelAppliesTo(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdAccommodationLookups.viewSel(dbConnApp, log, uInfo, false, "", "1", "APPLIESTO", "", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelFrequency */
        /**
         * Frequency values
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelFrequency(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdAccommodationLookups.viewSel(dbConnApp, log, uInfo, false, "", "1", "FREQUENCY", "", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelLocation */
        /**
         * Location values
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelLocation(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdAccommodationLookups.viewSel(dbConnApp, log, uInfo, false, "", "1", "LOCATION", "", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelAreaOfNeed */
        /**
         * Area of need values
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelAreaOfNeed(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdAccommodationLookups.viewSel(dbConnApp, log, uInfo, false, "", "1", "AREAOFNEED", "", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelStaffRole */
        /**
         * Staff role values
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelStaffRole(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdAccommodationLookups.viewSel(dbConnApp, log, uInfo, false, "", "1", "STAFFROLE", "", term); },
            Constants.ROLE_ALL);
        }

    }
}