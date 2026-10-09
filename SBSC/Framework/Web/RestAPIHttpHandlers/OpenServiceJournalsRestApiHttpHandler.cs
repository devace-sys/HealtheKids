using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * OpenServiceJournalsRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class OpenServiceJournalsRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public OpenServiceJournalsRestApiHttpHandler() : this(null, false)
        {
        }

        public OpenServiceJournalsRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_SVC_JOURNALS;
            this.viewMethodCb = delegate ()
            {
                return ServiceJournalsJournals.viewObjectsOpenJournals(this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , this.pageObjectList
                                           , this.pageorder
                                           , this.idx
                                           , this.active
                                           , this.clientid
                                           , this.pracid
                                           , this.patid
                                           , MBA.HttpApplication.getParameter(Constants.PARM_DOS)
                                           , MBA.HttpApplication.getParameter(Constants.PARM_INCLUDE_ALL_CLIENT_JOURNALS)
                                           );
            };
        }

    }


}
