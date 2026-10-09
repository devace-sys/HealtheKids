using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * PractitionersEfficiencyRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class PractitionersEfficiencyRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public PractitionersEfficiencyRestApiHttpHandler() : this(null, false)
        {
        }

        public PractitionersEfficiencyRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_PRAC_DIR_SUP_ADMINS;
            this.viewMethodCb = delegate ()
            {
                return PractitionersEfficiency.viewObjects(this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , this.pageObjectList
                                           , this.pageorder
                                           , this.idx
                                           , this.active
                                           , this.clientid
                                           , this.rptGroupID
                                           , this.pracid                                           
                                           , this.enddate                                                                                    
                                         );
            };
        }

    }


}
