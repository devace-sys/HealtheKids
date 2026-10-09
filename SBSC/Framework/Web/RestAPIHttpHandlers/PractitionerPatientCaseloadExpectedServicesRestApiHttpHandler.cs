using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * PractitionerPatientCaseloadExpectedServicesRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class PractitionerPatientCaseloadExpectedServicesRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public PractitionerPatientCaseloadExpectedServicesRestApiHttpHandler() : this(null, false)
        {
        }

        public PractitionerPatientCaseloadExpectedServicesRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.viewMethodCb = delegate ()
            {

                var disableComplianceCalc = MBA.HttpApplication.getParameter(Constants.PARM_DISABLE_COMPLIANCE_CALC);

                return PractitionerPatientCaseloadExpectedServices.viewObjects(this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , this.pageObjectList
                                           , this.pageorder
                                           , this.idx
                                           , this.active
                                           , this.clientid
                                           , this.pracid
                                           , this.patid
                                           , this.useMinsPerFreqAssigned
                                           , disableComplianceCalc);
            };
        }

    }


}
