using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * PractitionerSitesRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class PractitionerSitesRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public PractitionerSitesRestApiHttpHandler() : this(null, false)
        {
        }

        public PractitionerSitesRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.viewMethodCb = delegate ()
            {

                return PractitionerSites.viewObjects ( this.dbConnApp
                                                            , this.log
                                                            , this.uInfo
                                                            , this.pageObjectList
                                                            , this.pageorder
                                                            , this.idx
                                                            , this.active
                                                            , this.clientid
                                                            , this.pracid
															);
            };
        }

    }

}


