using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * ServiceRecordsApprovalRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class ServiceRecordsApprovalDetailsRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public ServiceRecordsApprovalDetailsRestApiHttpHandler() : this(null, false)
        {
        }

        public ServiceRecordsApprovalDetailsRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_APPROVE_SVC_RECS;
            this.viewMethodCb = delegate ()
            {

                if (!String.IsNullOrWhiteSpace(this.daterange))
                {
                    var sDate = @"";
                    var eDate = @"";
                    Util.parseDateRange(this.daterange, out sDate, out eDate);
                    this.startdate = sDate;
                    this.enddate = eDate;
                }

                return ServiceRecordsApprovalDetails.viewObjects(this.dbConnApp
                                                   , this.log
                                                   , this.uInfo
                                                   , this.pageObjectList
                                                   , this.pageorder
                                                   , this.idx
                                                   , this.active
                                                   , this.clientid
                                                   , this.pracid
                                                   , MBA.HttpApplication.getParameter("approvingpracid")
                                                   , this.patid
                                                   , MBA.HttpApplication.getParameter("journalid"));
            };
        }

    }


}


