using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;


namespace Spedmon
{
    /***************************************************************************
     * PatientInfoRequestsResponsesRestApiHttpHandler
     * Provides RESTful endpoints for viewing patient info requests/responses.
     ***************************************************************************/
    public class PatientInfoRequestsResponsesRestApiHttpHandler : EntitiesRestApiHttpHandler
    {
        public PatientInfoRequestsResponsesRestApiHttpHandler() : this(null, false)
        {
        }

        public PatientInfoRequestsResponsesRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.viewMethodCb = delegate ()
            {
                return Spedmon.PatientInfoRequestsResponses.viewObjects(    this.dbConnApp
                                                                          , this.log
                                                                          , this.uInfo
                                                                          , this.pageObjectList
                                                                          , this.pageorder
                                                                          , this.idx
                                                                          , this.clientid
                                                                          , this.active
                                                                          , this.recid

                                       );
            };
        }
    }
}
