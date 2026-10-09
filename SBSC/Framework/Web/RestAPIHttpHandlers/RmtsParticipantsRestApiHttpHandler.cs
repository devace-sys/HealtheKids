using System.Web.Routing;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * RmtsParticipantsRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class RmtsParticipantsRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public RmtsParticipantsRestApiHttpHandler() : this(null, false)
        {
        }

        public RmtsParticipantsRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_SBS_ALL_LEA_COORD;
            this.viewMethodCb = delegate ()
            {
                return RmtsParticipants.viewObjects(this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , this.pageObjectList
                                           , this.pageorder
                                           , this.idx
                                           , this.active
                                           , this.clientid
                                           , MBA.HttpApplication.getParameter(Constants.PARM_ROSTER_ID)
                                           );
            };
        }

    }


}
