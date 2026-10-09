using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * PatientKnownHealthProblemsRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class PatientKnownHealthProblemsRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public PatientKnownHealthProblemsRestApiHttpHandler() : this(null, false)
        {
        }
        public PatientKnownHealthProblemsRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.viewMethodCb = delegate ()
            {

                return Spedmon.PatientKnownHealthProblems.viewObjects(this.dbConnApp
                                             , this.log
                                             , this.uInfo
                                             , this.pageObjectList
                                             , this.pageorder
                                             , this.idx
                                             , "1"
                                             , this.clientid
                                             , this.patid
                                           );
            };
        }

    }
}