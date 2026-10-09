using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * PatientGoalsProgressIndividualGoalsRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class PatientGoalsProgressIndividualGoalsRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public PatientGoalsProgressIndividualGoalsRestApiHttpHandler() : this(null, false)
        {
        }

        public PatientGoalsProgressIndividualGoalsRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.viewMethodCb = delegate ()
            {
                var goalid = MBA.HttpApplication.getParameter(Constants.PARM_PATIENT_GOAL_ID);

                return PatientGoalsProgressIndividualGoals.viewObjects (   this.dbConnApp
                                                                         , this.log
                                                                         , this.uInfo
                                                                         , this.pageObjectList
                                                                         , this.pageorder
                                                                         , this.idx
                                                                         , this.active
                                                                         , this.clientid
                                                                         , this.patid                                                                         
																	     , goalid);
            };
        }
    }


}


