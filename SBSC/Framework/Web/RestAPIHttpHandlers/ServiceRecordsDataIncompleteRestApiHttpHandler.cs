using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * ServiceRecordsDataIncompleteRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class ServiceRecordsDataIncompleteRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public ServiceRecordsDataIncompleteRestApiHttpHandler() : this(null, false)
        {
        }

        public ServiceRecordsDataIncompleteRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Spedmon.Constants.ROLE_SBS_ALL_LEA_COORD_AND_ASSIST;
            this.viewMethodCb = delegate ()
            {
                var currentBenefitStatusCode = MBA.HttpApplication.getParameter(Constants.PARM_CURRENT_BENEFIT_STATUS_CODE);

                return ServiceRecordsDataIncomplete.viewObjects (    this.dbConnApp
                                                   , this.log
                                                   , this.uInfo
                                                   , this.pageObjectList
                                                   , this.pageorder
                                                   , this.idx
                                                   , this.active
                                                   , this.clientid);
            };
        }

    }


}


