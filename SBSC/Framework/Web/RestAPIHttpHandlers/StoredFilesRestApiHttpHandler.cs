using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    /***************************************************************************
     * StoredFilesRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class StoredFilesRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public StoredFilesRestApiHttpHandler() : this(null, false)
        {
        }

        public StoredFilesRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.viewMethodCb = delegate ()
            {

                return StoredFiles.viewObjects (   this.dbConnApp
                                                 , this.log
                                                 , this.uInfo
                                                 , this.pageObjectList
                                                 , this.pageorder
                                                 , this.idx
                                                 , this.active
                                                 , this.clientid
                                                 , this.pracid
                                                 , this.patid
                                                 , this.referencedentityid
                                                 , this.fileclass
                                                 , this.daterange
                                                 , this.filenamespace
                                                 , this.filesource );
            };
        }

    }


}
