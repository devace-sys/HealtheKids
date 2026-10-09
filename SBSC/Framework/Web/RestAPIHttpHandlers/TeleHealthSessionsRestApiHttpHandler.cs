using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  
   
  /***************************************************************************
   * TeleHealthSessionsRestApiHttpHandler */
  /**
   *    
   ***************************************************************************/

   public class TeleHealthSessionsRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public TeleHealthSessionsRestApiHttpHandler (): this(null,false)
    {        
    }    
	
    public TeleHealthSessionsRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */

      this.viewMethodPermittedRoles = Constants.ROLE_ADMIN_CONSULTANT_LEA_BO_PRAC;
      this.viewMethodCb = delegate()
      {
        
        return Spedmon.TeleHealthSessions.viewObjects (  this.dbConnApp
                                                                  , this.log
                                                                  , this.uInfo
                                                                  , this.pageObjectList
                                                                  , this.pageorder
                                                                  , this.idx
                                                                  , "1" /*this.active*/
                                                                  , this.clientid
                                                                  , this.pracid
                                                                  );
      };
    }

  }
}