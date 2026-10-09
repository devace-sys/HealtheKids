using System.Web.Routing;
using MBA;

namespace Spedmon
{



    /***************************************************************************
     * RmtsParticipantsWoSvcRecsRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class RmtsParticipantsWoSvcRecsRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public RmtsParticipantsWoSvcRecsRestApiHttpHandler() : this(null, false)
        {
        }

        public RmtsParticipantsWoSvcRecsRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.viewMethodCb = delegate ()
            {
                return RmtsParticipantsWoSvcRecs.viewObjects(this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , this.pageObjectList
                                           , this.pageorder
                                           , this.idx
                                           , this.clientid
                                           , MBA.HttpApplication.getParameter("deferralstatus")
                ) ;
            };
        }

    }


}
