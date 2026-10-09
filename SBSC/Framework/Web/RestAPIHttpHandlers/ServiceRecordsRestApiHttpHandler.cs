using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  
   
  /***************************************************************************
   * ServiceRecordsRestApiHttpHandler */
  /**
   *    
   ***************************************************************************/

   public class ServiceRecordsRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public ServiceRecordsRestApiHttpHandler (): this(null,false)
    {        
    }
    
    public ServiceRecordsRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */

      this.viewMethodPermittedRoles = Constants.ROLE_SVC_SUP_PRAC;
      this.viewMethodCb = delegate()
      {
          
        if (!String.IsNullOrWhiteSpace(this.daterange)) {
            var sDate = @"";
            var eDate = @"";
            Util.parseDateRange (this.daterange, out sDate, out eDate);
            this.startdate = sDate;
            this.enddate   = eDate;
        }

        return ServiceRecords.viewObjects (  this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , this.pageObjectList
                                           , this.pageorder
                                           , this.idx
                                           , this.active                                           
                                           , this.clientid
                                           , this.groupserviceclassnameid
                                           , this.pracid
                                           , this.patid
                                           , this.svctypeid
                                           , this.startdate
                                           , this.enddate );
      };
    }

  }     
  

}


