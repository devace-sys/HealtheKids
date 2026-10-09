using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * PracticeOfficeVisitResolutionsRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class PracticeOfficeVisitResolutionsRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public PracticeOfficeVisitResolutionsRestApiHttpHandler() : this(null, false)
        {
        }
        public PracticeOfficeVisitResolutionsRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_SBS_ALL;
            this.viewMethodCb = delegate ()
            {

                return Spedmon.PracticeOfficeVisitResolutions.viewObjects(this.dbConnApp
                                                                        , this.log
                                                                        , this.uInfo
                                                                        , this.pageObjectList
                                                                        , this.pageorder
                                                                        , this.idx
                                                                        , this.active
                                                                        , this.term);
            };
        }

    }
}