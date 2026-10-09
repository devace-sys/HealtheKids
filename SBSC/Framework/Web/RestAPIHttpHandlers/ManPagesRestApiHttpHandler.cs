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
   *    ManPagesRestApiHttpHandler
 */
    /**
     *    
     ***************************************************************************/

    public class ManPagesRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public ManPagesRestApiHttpHandler() : this(null, false)
        {
        }
        public ManPagesRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.viewMethodCb = delegate ()
            {


                return Spedmon.ManPages.viewObjects(
                                                  this.dbConnUser
                                                , this.log
                                                , this.uInfo
                                                , this.pageObjectList
                                                , this.pageorder
                                                , this.idx
                                                , "" //canEdit
                                                , "1") ;
            };
        }
    }
}
