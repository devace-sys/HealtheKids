using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;
 
namespace Spedmon
{
  
   
  /***************************************************************************
   * PatientPromisedServicesDeliveryExceptionsRestApiHttpHandler */
  /**
   *    
   ***************************************************************************/
 
   public class PatientPromisedServicesDeliveryExceptionsRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public PatientPromisedServicesDeliveryExceptionsRestApiHttpHandler (): this(null,false)
    {        
    }
    
    public PatientPromisedServicesDeliveryExceptionsRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */
 
      this.viewMethodPermittedRoles = Constants.ROLE_MISSING_SERVICES_MANAGE;
      this.viewMethodCb = delegate()
      {
        
        return PatientPromisedServicesDeliveryExceptions.viewObjects (  this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , this.pageObjectList
                                           , this.pageorder
                                           , this.idx
                                           , @"Y" /*this.active*/                                           
                                           , this.datasource
                                           , this.clientid
                                           , this.patid
										   , this.svcTrackingClass
										   , this.spEdServiceCode
										   , this.orpDocStandardSelectionNameID
                                           , this.startdate
                                           , this.enddate
                                           , this.reviewed
                                           );
      };
    }
 
  }     
  
 
}