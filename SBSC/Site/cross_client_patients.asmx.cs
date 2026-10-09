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
     * CrossClientPatientsSvc */
    /*
     ***************************************************************************/

    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]

    public class CrossClientPatientsSvc : MBA.WebSvc
    {

        /***************************************************************************
         * viewsel */
        /**
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewselfornewrecords(
          string clientid
        , string ssid)

        {
            return (ReturnSel)

            callMethod(typeof(ReturnSel),
            delegate ()
            {
                return CrossClientPatients.viewSelForNewRecs(
                                        this.dbConnApp
                                      , this.log
                                      , this.uInfo
                                      , false     /* paged */
                                      , "1"       /* pageNumber */
                                      , "y"       /* active */
                                      , clientid
                                      , ssid);
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }
    }
}