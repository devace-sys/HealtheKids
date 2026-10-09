using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * PotentialLostReimbursementsRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class PotentialLostReimbursementsRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public PotentialLostReimbursementsRestApiHttpHandler() : this(null, false)
        {
        }

        public PotentialLostReimbursementsRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.viewMethodCb = delegate ()
            {

                return PotentialLostReimbursements.viewObjects(this.dbConnApp
                                                   , this.log
                                                   , this.uInfo
                                                   , this.pageObjectList
                                                   , this.pageorder
                                                   , this.idx
                                                   , this.active
                                                   , this.clientid
                                                   , this.pracid
                                                   , null
                                                   , this.groupserviceclassnameid
                                                   , this.patid
                                                   , MBA.HttpApplication.getParameter(MBA.Constants.PARM_PLR_CLASS_CODE)
                                                   , MBA.HttpApplication.getParameter(MBA.Constants.PARM_DEFERRED)
                                                   );
            };
        }

    }


}
