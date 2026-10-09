using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;
 
namespace Spedmon
{
  
   
  /***************************************************************************
   * CdeComplianceBucketsDetailsByServiceRestApiHttpHandler */
  /**
   *    
   ***************************************************************************/
 
   public class CdeComplianceBucketsDetailsByServiceRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public CdeComplianceBucketsDetailsByServiceRestApiHttpHandler (): this(null,false)
    {        
    }
    
    public CdeComplianceBucketsDetailsByServiceRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */
 
      this.viewMethodPermittedRoles = Constants.ROLE_CDE_COMPLIANCE_MANAGE;
      this.viewMethodCb = delegate()
      {
 
        return CdeComplianceBucketDetailsByService.viewObjects (  this.dbConnApp
                                                                , this.log
                                                                , this.uInfo
                                                                , this.pageObjectList
                                                                , this.pageorder
                                                                , this.idx
                                                                , this.active                                           
                                                                , this.clientid
                                                                , this.siteid
                                                                , this.patid
                                                                , this.spEdServiceCode
                                                                , this.pcalComplianceRatingForPat
                                                                , this.svcOverDelivery );
      };
    }
 
  }     
  
 
}