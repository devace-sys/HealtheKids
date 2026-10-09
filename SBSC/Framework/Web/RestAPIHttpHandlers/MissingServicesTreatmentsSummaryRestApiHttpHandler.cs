using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * MissingServicesTreatmentsSummaryRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class MissingServicesTreatmentsSummaryRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public MissingServicesTreatmentsSummaryRestApiHttpHandler() : this(null, false)
        {
        }

        public MissingServicesTreatmentsSummaryRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_MISSING_SERVICES_MANAGE;
            this.viewMethodCb = delegate ()
            {
                return MissingServicesTreatmentsSummary.viewObjects(this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , this.pageObjectList
                                           , this.pageorder
                                           , this.idx
                                           , this.active
                                           , this.clientid
                                           , this.groupserviceclassnameid 
                                           , this.spEdServiceCode
                                           , this.svcTrackingClass
                                           , this.leaBopOnlyOrAllSped
                                           , this.daterange                                                                                    
                                         );
            };
        }

    }


}
