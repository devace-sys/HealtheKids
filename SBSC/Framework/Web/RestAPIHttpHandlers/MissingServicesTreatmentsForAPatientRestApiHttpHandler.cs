using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * MissingServicesTreatmentsDetailsForAPatientRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class MissingServicesTreatmentsDetailsForAPatientRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public MissingServicesTreatmentsDetailsForAPatientRestApiHttpHandler() : this(null, false)
        {
        }

        public MissingServicesTreatmentsDetailsForAPatientRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_MISSING_SERVICES_MANAGE;
            this.viewMethodCb = delegate ()
            {
                return MissingServicesTreatmentsForAPatient.viewObjects(this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , this.pageObjectList
                                           , this.pageorder
                                           , this.idx
                                           , this.active
                                           , this.clientid
                                           , this.groupserviceclassnameid  
                                           , this.spEdServiceCode
                                           , this.orpDocID
                                           , this.svcTrackingClass
                                           , this.leaBopOnlyOrAllSped
                                           , this.patid
                                           , this.startdate
                                           , this.enddate
                                         );
            };
        }

    }


}
