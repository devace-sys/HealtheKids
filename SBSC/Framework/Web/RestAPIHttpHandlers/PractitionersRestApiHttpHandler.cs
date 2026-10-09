using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  
   
  /***************************************************************************
   * PractitionersRestApiHttpHandler */
  /**
   *    
   ***************************************************************************/

   public class PractitionersRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public PractitionersRestApiHttpHandler (): this(null,false)
    {        
    }
    
    public PractitionersRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */

      this.viewMethodPermittedRoles = Constants.ROLE_SVC_SUP_PRAC;
      this.viewMethodCb = delegate()
      {    
        
        return Practitioners.viewObjects (   this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , this.pageObjectList
                                           , this.pageorder
                                           , this.idx
                                           , this.active
                                           , this.clientid
                                           , this.lname
                                           , this.fname
                                           , MBA.HttpApplication.getParameter( Constants.PARM_CURRENTLY_W_CLIENT )
                                           , MBA.HttpApplication.getParameter(Constants.PARM_GROUP_ID));
      };
    }

  }     
  

}


