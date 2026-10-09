using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * ClaimsRetroactiveForSpaRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class ClaimsRetroactiveForSpaRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public ClaimsRetroactiveForSpaRestApiHttpHandler() : this(null, false)
        {
        }
        
        public ClaimsRetroactiveForSpaRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_ADMIN_CONSULTANT_LEA_COORD;
            this.viewMethodCb = delegate ()
            {
                var authYNU = MBA.HttpApplication.getParameter(ClaimsRetroactiveForSpa.PARM_FOR_AUTH_YNU);

                // PARM_FOR_AUTH_YNU

                return ClaimsRetroactiveForSpa.viewObjectsPossibleSelections ( this.dbConnApp
                                                   , this.log
                                                   , this.uInfo
                                                   , this.pageObjectList
                                                   , this.pageorder
                                                   , this.idx
                                                   , this.active
                                                   , ClaimsRetroactiveForSpa.FOR_SPA_2015  /*forSpaID*/                                                 
                                                   , this.clientid
                                                   , "" /* fyID */
                                                   , authYNU
                                                   );
            };
        }

    }


}


