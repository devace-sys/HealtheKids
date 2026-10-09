using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;
 
namespace Spedmon
{
  
   
  /*********************************************************************************
   * CdeComplianceBucketDetailsByPcalComplianceRatingAndPatientsRestApiHttpHandler */
  /**
   *    
   *********************************************************************************/
 
   public class CdeComplianceBucketDetailsByPcalComplianceRatingAndPatientsRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public CdeComplianceBucketDetailsByPcalComplianceRatingAndPatientsRestApiHttpHandler (): this(null,false)
    {        
    }
    
    public CdeComplianceBucketDetailsByPcalComplianceRatingAndPatientsRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */
 
      this.viewMethodPermittedRoles = Constants.ROLE_CDE_COMPLIANCE_MANAGE;
      this.viewMethodCb = delegate()
      {
 
        return CdeComplianceBucketDetailsByPcalComplianceRatingAndPatients.viewObjects (  
            this.dbConnApp
          , this.log
          , this.uInfo
          , this.pageObjectList
          , this.pageorder
          , this.idx
          , this.active                                           
          , this.clientid
          , this.siteid                                                                                                                                
          , this.pcalComplianceRatingForPat );
      };
    }
 
  }     
  
 
}