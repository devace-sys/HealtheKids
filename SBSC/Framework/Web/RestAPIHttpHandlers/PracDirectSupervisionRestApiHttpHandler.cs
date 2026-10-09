using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * PracDirectSupervisionRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class PracDirectSupervisionRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public PracDirectSupervisionRestApiHttpHandler() : this(null, false)
        {
        }

        public PracDirectSupervisionRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Spedmon.Constants.ROLE_PRAC_DIR_SUP_ADMINS;
            this.viewMethodCb = delegate ()
            {

                return PractitionerDirectSupervisedSupervisors.viewObjects(this.dbConnApp
                                                   , this.log
                                                   , this.uInfo
                                                   , this.pageObjectList
                                                   , this.pageorder
                                                   , this.idx
                                                   , this.active
                                                   , this.clientid
                                                   , this.groupserviceclassnameid
                                                   , this.rptGroupID);
            };
        }

    }


}


