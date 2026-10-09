using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * PatientInsuranceCarriersRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class PatientInsuranceCarriersRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public PatientInsuranceCarriersRestApiHttpHandler() : this(null, false)
        {
        }

        public PatientInsuranceCarriersRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.viewMethodCb = delegate ()
            {

                return PatientInsuranceCarriers.viewObjects ( this.dbConnApp
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


