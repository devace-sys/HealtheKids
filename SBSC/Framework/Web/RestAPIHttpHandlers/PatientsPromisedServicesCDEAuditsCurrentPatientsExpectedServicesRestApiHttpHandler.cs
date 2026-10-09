using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;
 
namespace Spedmon
{
  
   
  /**************************************************************************************
   * PatientsPromisedServicesCDEAuditsCurrentPatientsExpectedServicesRestApiHttpHandler */
  /**
   *    
   **************************************************************************************/
 
   public class PatientsPromisedServicesCDEAuditsCurrentPatientsExpectedServicesRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public PatientsPromisedServicesCDEAuditsCurrentPatientsExpectedServicesRestApiHttpHandler (): this(null,false)
    {        
    }
    
    public PatientsPromisedServicesCDEAuditsCurrentPatientsExpectedServicesRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */
 
      this.viewMethodPermittedRoles = Constants.ROLE_CDE_COMPLIANCE_MANAGE;
      this.viewMethodCb = delegate()
      {
 
        return PatientsPromisedServicesCDEAuditsCurrentPatientsExpectedServices.viewObjects (  this.dbConnApp
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