using System.Web.Routing;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * RmtsParticipantRostersRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class RmtsParticipantRostersRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public RmtsParticipantRostersRestApiHttpHandler() : this(null, false)
        {
        }

        public RmtsParticipantRostersRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_SBS_ALL_LEA_COORD;
            this.viewMethodCb = delegate ()
            {
                return RmtsParticipationRosters.viewObjects(this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , this.pageObjectList
                                           , this.pageorder
                                           , this.idx
                                           , this.active
                                           , this.clientid
                                           );
            };
        }

    }


}
