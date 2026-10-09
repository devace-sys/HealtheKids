using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * PractitionerPreferenceSpedServicesRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class PractitionerPreferenceSpedServicesRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public PractitionerPreferenceSpedServicesRestApiHttpHandler() : this(null, false)
        {
        }

        public PractitionerPreferenceSpedServicesRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_ALL_PCAL_AND_CLIENT;
                                            // TODO: harden this

            this.viewMethodCb = delegate ()
            {

                return PractitionerPreferenceSpedServices.viewObjects(this.dbConnApp
                                              , this.log
                                              , this.uInfo
                                              , this.pageObjectList
                                              , this.pageorder
                                              , this.idx
                                              , this.active

                                              , this.clientid
                                              , this.pracid

                                              , MBA.HttpApplication.getParameter( "disciplineGroupID" )
                                              , MBA.HttpApplication.getParameter( "spEdServiceID"     )  // optional params; usually blank/null

                                              );
            };
        }

    }


}
