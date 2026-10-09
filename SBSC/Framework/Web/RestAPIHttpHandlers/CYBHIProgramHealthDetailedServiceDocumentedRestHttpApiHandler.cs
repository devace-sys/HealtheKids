using System;
using System.Web;
using System.Web.Routing;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * CYBHIProgramHealthDetailedServiceDocumentedRestHttpApiHandler
     ***************************************************************************/

    public class CYBHIProgramHealthDetailedServiceDocumentedRestHttpApiHandler : EntitiesRestApiHttpHandler 
    {
        public CYBHIProgramHealthDetailedServiceDocumentedRestHttpApiHandler() : this(null, false)
        {
        }
        // TODO: this classname isn't pluralized as ServiceS Documented.  Consider fixing later

        public CYBHIProgramHealthDetailedServiceDocumentedRestHttpApiHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */
            this.viewMethodPermittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.viewMethodCb = delegate ()
            {
                return CYBHIProgramHealthDetailedServicesDocumented.viewObjects( this.dbConnApp    //  SqlConnection connSpedmon
                                                   , this.log                   //  DetailsLog log
                                                   , this.uInfo                 //  UserInfo uInfo
                                                   , this.pageObjectList        //  bool pageObjectList
                                                   , this.pageorder             //  string pageOrder
                                                   , this.idx                   //  string idx

                                                //, string active

                                                , this.clientid //  string clientID
                                                , this.groupid  //  string groupID
                                                , this.pracid   //  string pracID
                                                , this.patid    //  string patID
                                                , this.nameid   // string nameID
                                                , this.startdate   // string startDOS
                                                , this.enddate // string endDOS
                                                , MBA.HttpApplication.getParameter("ispaid"));

            };
        }
    }
}