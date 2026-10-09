using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  
   
  /***************************************************************************
   * TeleHealthIepApiHttpHandler */
  /**
   *    
   ***************************************************************************/

   public class TeleIepSessionsRestApiHttpHander : EntitiesRestApiHttpHandler
   {    
    
    public TeleIepSessionsRestApiHttpHander (): this(null,false)
    {        
    }    
    public TeleIepSessionsRestApiHttpHander (RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */

      this.viewMethodPermittedRoles = Constants.ROLE_ADMIN_CONSULTANT_LEA_BO_PRAC;
      this.viewMethodCb = delegate()
      {
        
        return Spedmon.TeleIEPSessions.viewObjects (  this.dbConnApp
                                                                  , this.log
                                                                  , this.uInfo
                                                                  , this.pageObjectList
                                                                  , this.pageorder
                                                                  , this.idx
                                                                  , this.active
                                                                  , this.clientid
                                                                  , this.patid);
      };
    }

  }
}