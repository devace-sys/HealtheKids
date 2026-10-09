using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  
   
  /***************************************************************************
   * UsersRestApiHttpHandler */
  /**
   *    
   ***************************************************************************/

   public class UsersRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public UsersRestApiHttpHandler (): this(null,false)
    {        
    }
    
    public UsersRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */

      this.viewMethodPermittedRoles = Constants.ROLE_SVC_PRAC;
      this.viewMethodCb = delegate()
      {    
        
        return Spedmon.Users.viewObjects(  this.dbConnUser
                                         , this.log
                                         , this.uInfo
                                         , this.pageObjectList
                                         , this.pageorder
                                         , this.idx
                                         , this.active
                                         , this.clientid
                                         , this.lname
                                         , this.fname);
      };
    }

  }     
  

}


