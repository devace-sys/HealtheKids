using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;



namespace Spedmon
{


    public class ClientComplianceClientItemsRestApiHttpHandler : EntitiesRestApiHttpHandler
    {


        public ClientComplianceClientItemsRestApiHttpHandler() : this(null, false)
        {
        }


        public ClientComplianceClientItemsRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_SBS_ALL_LEA_COORD_AND_ASSIST;
            this.viewMethodCb = delegate ()
            {

                return ClientComplianceClientItems.viewObjects(this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , this.pageObjectList
                                           , this.pageorder
                                           , this.idx
                                           , this.active
                                           , this.clientid
                                           , MBA.HttpApplication.getParameter(Constants.PARM_TASK_ID)
                                           , MBA.HttpApplication.getParameter(Constants.PARM_IS_PENDING)
                                           , MBA.HttpApplication.getParameter(Constants.PARM_IS_NOT_COMPLETED)
                                           , MBA.HttpApplication.getParameter(Constants.PARM_IS_COMPLETED)

                                           , MBA.HttpApplication.getParameter( Constants.PARM_FISCAL_YEAR_ID )
                                          
                                           ) ;

            };
        }



    }


}
