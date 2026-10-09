using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * InsuranceCarriersRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class InsuranceCarriersRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public InsuranceCarriersRestApiHttpHandler() : this(null, false)
        {
        }
        public InsuranceCarriersRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_SBS_ADMIN;
            this.viewMethodCb = delegate ()
            {

                return InsuranceCarriers.viewObjects(   this.dbConnApp
                                                      , this.log
                                                      , this.uInfo
                                                      , this.pageObjectList
                                                      , this.pageorder
                                                      , this.idx
                                                      , this.term );
            };
        }

    }
}