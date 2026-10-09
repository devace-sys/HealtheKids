using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * ServiceRecordsApprovalSummaryByPracRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class ServiceRecordsApprovalSummaryByPracRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public ServiceRecordsApprovalSummaryByPracRestApiHttpHandler() : this(null, false)
        {
        }

        public ServiceRecordsApprovalSummaryByPracRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_APPROVE_SVC_RECS;
            this.viewMethodCb = delegate ()
            {

                return ServiceRecordsApprovalSummary.viewObjects(this.dbConnApp
                                                   , this.log
                                                   , this.uInfo
                                                   , this.pageObjectList
                                                   , this.pageorder
                                                   , this.idx
                                                   , this.active
                                                   , this.clientid
                                                   , MBA.HttpApplication.getParameter(Constants.PARM_APPROVING_PRACTITIONER_ID)
                                                   , MBA.HttpApplication.getParameter(Constants.PARM_ASSIGNED)
                                                   , MBA.HttpApplication.getParameter(Constants.PARM_REVIEWED)
                                                   , MBA.HttpApplication.getParameter(Constants.PARM_APPROVED)
                                                   , this.siteid
                                                   , this.daterange);
            };
        }

    }


}


