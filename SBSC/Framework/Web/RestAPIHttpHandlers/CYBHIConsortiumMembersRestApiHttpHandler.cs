using System;
using System.Web;
using System.Web.Routing;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * CYBHIConsortiumMembersRestApiHttpHandler
     ***************************************************************************/
    public class CYBHIConsortiumMembersRestApiHttpHandler : EntitiesRestApiHttpHandler
    {
        public CYBHIConsortiumMembersRestApiHttpHandler() : this(null, false)
        {
        }

        public CYBHIConsortiumMembersRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */
            
            this.viewMethodPermittedRoles = Spedmon.Constants.ROLE_ADMIN_CONSULTANT_LEA_COORD_CYBHI_COORD;

            this.viewMethodCb = delegate ()
            {
                return CYBHIConsortiumMembers.viewObjects (
                      this.dbConnApp
                    , this.log
                    , this.uInfo
                    , this.pageObjectList
                    , this.pageorder
                    , this.consortiumLeadClientID
                    , this.idx
                    , this.active
                    , this.term
                );
            };
        }
    }
}