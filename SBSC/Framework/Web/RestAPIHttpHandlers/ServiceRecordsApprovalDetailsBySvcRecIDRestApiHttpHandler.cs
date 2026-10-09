using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * ServiceRecordsApprovalDetailsBySvcRecIDRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class ServiceRecordsApprovalDetailsBySvcRecIDRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public ServiceRecordsApprovalDetailsBySvcRecIDRestApiHttpHandler() : this(null, false)
        {
        }

        public ServiceRecordsApprovalDetailsBySvcRecIDRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_APPROVE_SVC_RECS;
            this.viewMethodCb = delegate ()
            {

                return ServiceRecordsApprovalDetails.viewObjectsBySvcRecID(this.dbConnApp
                                                   , this.log
                                                   , this.uInfo
                                                   , this.pageObjectList
                                                   , this.pageorder
                                                   , this.idx
                                                   , this.active
                                                   , this.clientid
                                                   , this.siteid
                                                   , this.pracid
                                                   , this.daterange                                                   
                                                   , MBA.HttpApplication.getParameter(Constants.PARM_APPROVING_PRACTITIONER_ID)
                                                   , this.patid
                                                   , MBA.HttpApplication.getParameter(Constants.PARM_SVC_REC_ID));
            };
        }

    }


}


