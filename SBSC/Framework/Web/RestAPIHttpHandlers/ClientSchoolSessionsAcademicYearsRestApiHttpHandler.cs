using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;
 
namespace Spedmon
{
  
   
  /***************************************************************************
   * ClientSchoolSessionsAcademicYearsRestApiHttpHandler */
  /**
   *    
   ***************************************************************************/
 
   public class ClientSchoolSessionsAcademicYearsRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public ClientSchoolSessionsAcademicYearsRestApiHttpHandler (): this(null,false)
    {        
    }
    
    public ClientSchoolSessionsAcademicYearsRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */
 
      this.viewMethodPermittedRoles = Constants.ROLE_SCHOOL_SESSIONS_ACADEMIC_YEARS_MANAGE;
      this.viewMethodCb = delegate()
      {
 
        return ClientSchoolSessionAcademicYears.viewObjects (  this.dbConnApp
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