using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * PatientGoalsRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class PatientGoalsRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public PatientGoalsRestApiHttpHandler() : this(null, false)
        {
        }

        public PatientGoalsRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.viewMethodCb = delegate ()
            {

                return PatientGoals.viewObjects (    this.dbConnApp
                                                   , this.log
                                                   , this.uInfo
                                                   , this.pageObjectList
                                                   , this.pageorder
                                                   , this.idx
                                                   , this.active
                                                   , this.clientid
                                                   , this.patid
                                                   , this.groupserviceclassnameid);
            };
        }

    }


}


