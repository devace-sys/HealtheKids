using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * ClientGroupServiceClassNameSpecificPracticeRuleSetsRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class ClientGroupServiceClassNameSpecificPracticeRuleSetsRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public ClientGroupServiceClassNameSpecificPracticeRuleSetsRestApiHttpHandler() : this(null, false)
        {
        }

        public ClientGroupServiceClassNameSpecificPracticeRuleSetsRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_SBS_MGMT_ANI;
            this.viewMethodCb = delegate ()
            {

                return ClientGroupServiceClassNameSpecificPracticeRuleSets.viewObjects(this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , this.pageObjectList
                                           , this.pageorder
                                           , this.idx
                                           , this.active
                                           , this.clientid
                                           , this.groupserviceclassnameid);
            };
        }

    }


}
