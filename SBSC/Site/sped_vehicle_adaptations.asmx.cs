
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
     * SpEdVehicleAdaptationsSvc */
    /**
     * Web services end point for SpEd Vehicle Adaptations
     ***************************************************************************/

    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]

    public class SpEdVehicleAdaptationsSvc : MBA.WebSvc
    {

        /***************************************************************************
         * viewSel */
        /**
         * View selection list - all active vehicle adaptations
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSel(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdVehicleAdaptations.viewSel(dbConnApp, log, uInfo, false, "", "1", term); },
            Constants.ROLE_ALL);
        }

    }
}