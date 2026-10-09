using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * InputBatchesInProcessRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class InputBatchesInProcessRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public InputBatchesInProcessRestApiHttpHandler() : this(null, false)
        {
        }

        public InputBatchesInProcessRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_SBS_ALL;
            this.viewMethodCb = delegate ()
            {
                string assignedUserID = "";

                if (this.uInfo.userRole.ToLower() == Constants.ROLE_INPUT_STAFF)
                {
                    // Input staff always see only their own batches
                    assignedUserID = this.uInfo.userid.ToString();
                }
                else
                {
                    // Work leaders / others: respect the optional staff filter from the UI
                    assignedUserID = MBA.HttpApplication.getParameter("recuserid");
                }

                return InputBatchesInProcess.viewObjects(this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , this.pageObjectList
                                           , this.pageorder
                                           , this.idx
                                           , this.active
                                           , this.clientid
                                           , MBA.HttpApplication.getParameter(Constants.PARM_BATCH_STATUS_CODE)
                                           , assignedUserID
                                           , MBA.HttpApplication.getParameter(Constants.PARM_BATCH_ID)
                                           , MBA.HttpApplication.getParameter("worktypeid")
                                           , MBA.HttpApplication.getParameter(Constants.PARM_SEARCH_TERM)
                                           , MBA.HttpApplication.getParameter("showjustbatchesinprocess")
                                           );;
            };
        }

    }


}
