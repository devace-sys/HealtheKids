using System.Web.Routing;
using MBA;

namespace Spedmon
{
    public class PlanWriterPlansRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public PlanWriterPlansRestApiHttpHandler() : this(null, false)
        {
        }

        public PlanWriterPlansRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_CARE_PLAN_WRITER;
            this.viewMethodCb = delegate ()
            {
                return PlanWriterPlans.viewObjects(this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , this.pageObjectList
                                           , this.pageorder
                                           , this.idx
                                           , this.active
                                           , this.clientid
                                           , this.patid
                                           , this.pracid
                                           , MBA.HttpApplication.getParameter(Constants.PARM_SITE_ID)
                                           , MBA.HttpApplication.getParameter(Constants.PARM_FISCAL_YEAR_ID)
                                           , MBA.HttpApplication.getParameter(Constants.PARM_IS_CREATED_BY_CALLER)
                                           , MBA.HttpApplication.getParameter(Constants.PARM_IS_EXPIRING)      
                                           , MBA.HttpApplication.getParameter(Constants.PARM_IS_EXPIRED)
                                           , this.term
                                           );
            };
        }

    }


}
