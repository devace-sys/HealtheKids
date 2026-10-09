using System;
using System.Web;
using System.Web.Routing;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * PatientsWithMissingInfoRestApiHttpHandler
     ***************************************************************************/
	 
    public class PatientsWithMissingInfoRestApiHttpHandler : EntitiesRestApiHttpHandler
    {
        public PatientsWithMissingInfoRestApiHttpHandler() : this(null, false)
        {
        }

        public PatientsWithMissingInfoRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */
			
            this.viewMethodPermittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.viewMethodCb = delegate ()
            {
                return PatientsWithMissingInfo.viewObjects (
                      this.dbConnApp
                    , this.log
                    , this.uInfo
                    , this.pageObjectList
                    , this.pageorder
                    , this.idx
                    , this.active
                    , this.clientid
                    , this.patid
					, this.datasource                    
                    , MBA.HttpApplication.getParameter(Constants.PARM_MISSING_INSURANCE_INFO)
                    , MBA.HttpApplication.getParameter(Constants.PARM_MISSING_ADDRESS_INFO)
                    , MBA.HttpApplication.getParameter(Constants.PARM_MISSING_FERPA_CONSENT)
                    , MBA.HttpApplication.getParameter(Constants.PARM_MISSING_PG_EMAILS)
                    , MBA.HttpApplication.getParameter(Constants.PARM_MISSING_PG_MCAL_CONSENT)
                    , MBA.HttpApplication.getParameter(Constants.PARM_HAS_CURR_INFO_REQUEST)
                    , MBA.HttpApplication.getParameter(Constants.PARM_HAS_CURR_INFO_REQUEST_THAT_REQUIRES_REVIEW)
                    , MBA.HttpApplication.getParameter(Constants.PARM_HAS_PREV_INFO_REQUEST_THAT_REQUIRED_REVIEW)
                );
            };
        }
    }
}