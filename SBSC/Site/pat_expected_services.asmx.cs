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
     * patExpectedServicesSvc */
    /*
     * Web services end point for patExpectedServices methods.
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

    public class patExpectedServicesSvc : MBA.WebSvc
    {

        /***************************************************************************
         * loadLatestPatData */
        /**
         * Returns the latest data for the selected patient
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnEntity loadLatestPatData(string clientID,
                                                string pracID,
                                                string patID)
        {
            return (ReturnEntity)
            callMethod(typeof(ReturnEntity),
            delegate ()
            {
                ReturnEntity so = Spedmon.PatExpectedServices.loadLatestPatData(this.dbConnApp,
                                                   this.log,
                                                   this.uInfo,
                                                   clientID,
                                                   pracID,
                                                   patID);
                return so;
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
        }
    }
}
