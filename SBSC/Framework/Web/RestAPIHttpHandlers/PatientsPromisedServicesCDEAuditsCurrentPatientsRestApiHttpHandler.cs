using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;
 
namespace Spedmon
{
  
   
  /**************************************************************************************
   * PatientsPromisedServicesCDEAuditsCurrentPatientsRestApiHttpHandler */
  /**
   *    
   **************************************************************************************/
 
   public class PatientsPromisedServicesCDEAuditsCurrentPatientsRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public PatientsPromisedServicesCDEAuditsCurrentPatientsRestApiHttpHandler (): this(null,false)
    {        
    }
    
    public PatientsPromisedServicesCDEAuditsCurrentPatientsRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */
 
      this.viewMethodPermittedRoles = Constants.ROLE_CDE_COMPLIANCE_MANAGE;
      this.viewMethodCb = delegate()
      {
 
        return PatientsPromisedServicesCDEAuditsCurrentPatients.viewObjects (  this.dbConnApp
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