
﻿using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    public class CRCSPracSalariesRateRebasingRestApiHttpHandler : EntitiesRestApiHttpHandler
    {
 
        public CRCSPracSalariesRateRebasingRestApiHttpHandler() : this(null, false)
        {
        }
 
        public CRCSPracSalariesRateRebasingRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;
 
            /* Wire up view method */
 
            this.viewMethodPermittedRoles = Constants.ROLE_CRCS_ADMIN;
            this.viewMethodCb = delegate ()
            {
                return CrcsPracSalaries.viewObjectsRateRebasing(this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , this.pageObjectList
                                           , this.pageorder
                                           , this.idx
                                           , this.active
                                           , this.clientid
                                           , MBA.HttpApplication.getParameter(Constants.PARM_FISCAL_YEAR_ID)
                                           //, MBA.HttpApplication.getParameter(Constants.PARM_QUARTER)
                                           );
            };
        }
 
    }

}