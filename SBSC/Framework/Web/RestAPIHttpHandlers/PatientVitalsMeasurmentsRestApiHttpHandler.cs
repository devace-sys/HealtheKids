using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * PatientVitalsMeasurmentsRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class PatientVitalsMeasurmentsRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public PatientVitalsMeasurmentsRestApiHttpHandler() : this(null, false)
        {
        }

        public PatientVitalsMeasurmentsRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.viewMethodCb = delegate ()
            {

                return PatientVitalsMeasurements.viewObjects(   this.dbConnApp
                                                              , this.log
                                                              , this.uInfo
                                                              , this.pageObjectList
                                                              , this.pageorder
                                                              , this.idx
                                                              , this.active
                                                              , this.clientid
                                                              , this.patid);
            };
        }

    }


}