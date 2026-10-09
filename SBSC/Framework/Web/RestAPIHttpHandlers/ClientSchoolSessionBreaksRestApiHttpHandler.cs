using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;
 
namespace Spedmon
{
  
   
  /***************************************************************************
   * ClientSchoolSessionBreaksRestApiHttpHandler */
  /**
   *    
   ***************************************************************************/
 
   public class ClientSchoolSessionBreaksRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public ClientSchoolSessionBreaksRestApiHttpHandler (): this(null,false)
    {        
    }
    
    public ClientSchoolSessionBreaksRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */
 
      this.viewMethodPermittedRoles = Constants.ROLE_SCHOOL_SESSIONS_ACADEMIC_YEARS_MANAGE;
      this.viewMethodCb = delegate()
      {
 
        return ClientSchoolSessionBreaks.viewObjects (  this.dbConnApp
                                                       , this.log
                                                       , this.uInfo
                                                       , this.pageObjectList
                                                       , this.pageorder
                                                       , this.idx
                                                       , this.active                                           
                                                       , this.clientid );
      };
    }
 
  }     
  
 
}