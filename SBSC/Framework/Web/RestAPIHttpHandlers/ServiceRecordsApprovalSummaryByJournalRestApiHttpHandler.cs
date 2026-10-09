using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * ServiceRecordsApprovalSummaryRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class ServiceRecordsApprovalSummaryByJournalRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public ServiceRecordsApprovalSummaryByJournalRestApiHttpHandler() : this(null, false)
        {
        }

        public ServiceRecordsApprovalSummaryByJournalRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
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

                return ServiceRecordsApproval.viewObjectsUnreviewedServicesByJournal(this.dbConnApp
                                                   , this.log
                                                   , this.uInfo
                                                   , this.pageObjectList
                                                   , this.pageorder
                                                   , this.idx
                                                   , this.active
                                                   , this.clientid
                                                   , this.siteid
                                                   , this.pracid
                                                   , MBA.HttpApplication.getParameter("approvingpracid")
                                                   , MBA.HttpApplication.getParameter("assigned")
                                                   , MBA.HttpApplication.getParameter("journalid")
                                                   , this.daterange
                                                   );
            };
        }

    }


}


