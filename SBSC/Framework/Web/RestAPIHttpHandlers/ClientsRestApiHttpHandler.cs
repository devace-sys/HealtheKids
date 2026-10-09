using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  
   
  /***************************************************************************
   * ClientsRestApiHttpHandler */
  /**
   *    
   ***************************************************************************/

   public class ClientsRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public ClientsRestApiHttpHandler (): this(null,false)
    {        
    }
    
    public ClientsRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */

      this.viewMethodPermittedRoles = Constants.ROLE_SBS_ALL;
      this.viewMethodCb = delegate()
      {    
        
        return Clients.viewObjects (   this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , this.pageObjectList
                                           , this.pageorder
                                           , this.idx
                                           , this.name);
      };
    }

  }     
  

}


