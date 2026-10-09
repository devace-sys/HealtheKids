using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * CRCSTransportationEquipmentDepreciationCostsRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class CRCSTransportationEquipmentDepreciationCostsRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public CRCSTransportationEquipmentDepreciationCostsRestApiHttpHandler() : this(null, false)
        {
        }

        public CRCSTransportationEquipmentDepreciationCostsRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_CRCS_ADMIN;
            this.viewMethodCb = delegate ()
            {
                return CrcsTransportationEquipmentDepreciationCosts.viewObjects(this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , this.pageObjectList
                                           , this.pageorder
                                           , this.idx
                                           , this.active
                                           , this.clientid
                                           , MBA.HttpApplication.getParameter(Constants.PARM_FISCAL_YEAR_ID)
                                           );
            };
        }

    }


}
