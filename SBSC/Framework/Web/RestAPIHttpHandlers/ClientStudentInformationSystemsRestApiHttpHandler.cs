using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * ClientStudentInformationSystemsRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/
    public class ClientStudentInformationSystemsRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public ClientStudentInformationSystemsRestApiHttpHandler() : this(null, false)
        {
        }
        public ClientStudentInformationSystemsRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_SBS_ALL;
            this.viewMethodCb = delegate ()
            {
                var studentinfosystemid = MBA.HttpApplication.getParameter("studentinfosystemid");
                
                return Spedmon.ClientStudentInformationSystems.viewObjects(
                                               this.dbConnApp
                                             , this.log
                                             , this.uInfo
                                             , this.pageObjectList
                                             , this.pageorder
                                             , this.idx
                                             , @"Y"
                                             , this.clientid
                                             , studentinfosystemid
                                             , this.enabled
                                           );
            };
        }

    }
}