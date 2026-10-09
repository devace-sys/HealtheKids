using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * AllergiesRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class AllergiesRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public AllergiesRestApiHttpHandler() : this(null, false)
        {
        }
        public AllergiesRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.viewMethodCb = delegate ()
            {

                return Spedmon.Allergies.viewObjects(
                      this.dbConnApp
                    , this.log
                    , this.uInfo
                    , this.pageObjectList
                    , this.pageorder
                    , this.idx
                    , this.active
                    , this.term                                                                                          
                );
            };
        }

    }
}