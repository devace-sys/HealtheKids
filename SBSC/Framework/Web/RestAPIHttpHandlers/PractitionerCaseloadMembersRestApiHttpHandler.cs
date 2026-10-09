using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * PractitionerCaseloadMembersRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class PractitionerCaseloadMembersRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public PractitionerCaseloadMembersRestApiHttpHandler() : this(null, false)
        {
        }

        public PractitionerCaseloadMembersRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.viewMethodCb = delegate ()
            {

                return PractitionerCaseloadMembers.viewObjects(this.dbConnApp
                                              , this.log
                                              , this.uInfo
                                              , this.pageObjectList
                                              , this.pageorder
                                              , this.idx
                                              , this.active
                                              , this.clientid
                                              , this.pracid
                                              , MBA.HttpApplication.getParameter(Constants.PARM_CASELOAD_GROUP_ID)
                                              , MBA.HttpApplication.getParameter(Constants.PARM_SEARCH_TERM)
                                              , MBA.HttpApplication.getParameter(Constants.PARM_IEP)
                                              , MBA.HttpApplication.getParameter(Constants.PARM_NAME_ID)
                                              , MBA.HttpApplication.getParameter(Constants.PARM_REF_DATE)
                                              );
            };
        }

    }


}
