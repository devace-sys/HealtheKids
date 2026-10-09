using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * ServiceJournalRecentProcedureEntriesRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class ServiceJournalRecentProcedureEntriesRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public ServiceJournalRecentProcedureEntriesRestApiHttpHandler() : this(null, false)
        {
        }

        public ServiceJournalRecentProcedureEntriesRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_SVC_JOURNALS;
            this.viewMethodCb = delegate ()
            {
                return ServiceJournalRecentProcedureEntries.viewObjects( this.dbConnApp
                                                                        , this.log
                                                                        , this.uInfo
                                                                        , this.pageObjectList
                                                                        , this.pageorder
                                                                        , this.idx                                                                        
                                                                        , this.clientid
                                                                        , this.patid
                                                                        , this.dos
                                                                        , this.active
                                                                    );
            };
        }

    }
}
