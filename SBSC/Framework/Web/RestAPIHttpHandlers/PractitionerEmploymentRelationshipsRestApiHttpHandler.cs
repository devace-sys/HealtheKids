using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    /***************************************************************************
     * PractitionerEmploymentRelationshipsRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class PractitionerEmploymentRelationshipsRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public PractitionerEmploymentRelationshipsRestApiHttpHandler() : this(null, false)
        {
        }

        public PractitionerEmploymentRelationshipsRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_SBS_ALL;
            this.viewMethodCb = delegate ()
            {
                return PractitionerEmploymentRelationships.viewObjects (  this.dbConnApp
                                                                         , this.log
                                                                         , this.uInfo
                                                                         , this.pageObjectList
                                                                         , this.pageorder
                                                                         , this.idx
                                                                         , "Y" /*this.active*/
                                                                         , this.clientid 
																		 , this.pracid );
            };
        }

    }


}
