using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * CRCSPracSalariesBefore1920FYRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class CRCSPracSalariesBefore1920FYRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public CRCSPracSalariesBefore1920FYRestApiHttpHandler() : this(null, false)
        {
        }

        public CRCSPracSalariesBefore1920FYRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_CRCS_ADMIN;
            this.viewMethodCb = delegate ()
            {
                return CrcsPracSalariesBefore1920FY.viewObjects(this.dbConnApp
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
