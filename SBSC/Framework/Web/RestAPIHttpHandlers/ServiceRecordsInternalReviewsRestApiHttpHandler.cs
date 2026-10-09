using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * ServiceRecordsInternalReviewsRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class ServiceRecordsInternalReviewsRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public ServiceRecordsInternalReviewsRestApiHttpHandler() : this(null, false)
        {
        }

        public ServiceRecordsInternalReviewsRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_INTERNAL_REVIEW_SVC_RECS;
            this.viewMethodCb = delegate ()
            {

                return ServiceRecordsInternalReviews.viewObjects ( 
                      this.dbConnApp
                    , this.log
                    , this.uInfo
                    , this.pageObjectList
                    , this.pageorder
                    , this.idx
                    , this.active

                    , this.clientid
                    , this.reviewingpracid
                    , this.siteid
                    , this.renderingpracid                    
                    , this.patid
                    , this.daterange
                    , this.reviewed
                    , this.approved );
            };
        }

    }


}


