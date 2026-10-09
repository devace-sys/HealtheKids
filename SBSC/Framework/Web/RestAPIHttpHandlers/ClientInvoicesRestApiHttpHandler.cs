using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * ClientInvoicesRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class ClientInvoicesRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public ClientInvoicesRestApiHttpHandler() : this(null, false)
        {
        }

        public ClientInvoicesRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_SBS_ALL_LEA_COORD;
            this.viewMethodCb = delegate ()
            {
                this.startdate = @"";
                this.enddate   = @"";

                if (!String.IsNullOrWhiteSpace(this.daterange))
                {
                    var sDate = @"";
                    var eDate = @"";
                    Util.parseDateRange(this.daterange, out sDate, out eDate);
                    this.startdate = sDate;
                    this.enddate = eDate;
                }

                var invoicePaid = MBA.HttpApplication.getParameter(Constants.PARM_INVOICE_PAID);
                //var disbPaid = MBA.HttpApplication.getParameter(Constants.PARM_DISTRIBUTION_PAID);


                return ClientInvoices.viewObjects(this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , this.pageObjectList
                                           , this.pageorder
                                           , this.idx
                                           , this.active
                                           , this.clientid
                                           , this.startdate
                                           , this.enddate
                                           , invoicePaid

                                           , MBA.HttpApplication.getParameter("calcshares")

                                           , MBA.HttpApplication.getParameter( Constants.PARM_DISTRIBUTION_PAID )

                                          //  , MBA.HttpApplication.getParameter("distbpaiddaterange")

                                          , MBA.HttpApplication.getParameter("invcolldaterange")

                                          , MBA.HttpApplication.getParameter("inclpartner1col")
                                          , MBA.HttpApplication.getParameter("inclretentioncol")
                                          , MBA.HttpApplication.getParameter("inclcybhirows")
                                          , MBA.HttpApplication.getParameter("inclcybhirowsonly")
                                           );
            };
        }

    }


}
