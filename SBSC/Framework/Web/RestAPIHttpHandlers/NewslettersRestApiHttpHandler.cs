using System;
using System.Collections.Generic;
using System.Web.Routing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MBA;

namespace Spedmon
{
    /***************************************************************************
   * NewslettersRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class NewslettersRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public NewslettersRestApiHttpHandler() : this(null, false)
        {
        }
        public NewslettersRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.viewMethodCb = delegate ()
            {


                return Spedmon.NewsletterPages.viewObjects(this.dbConnApp
                                                   , this.log
                                                   , this.uInfo
                                                   , this.pageObjectList
                                                   , this.pageorder
                                                   , this.idx
                                                   , this.active
                                                   , this.term
                                                   , this.includeContent
                                                 );
            };
        }
    }
}
