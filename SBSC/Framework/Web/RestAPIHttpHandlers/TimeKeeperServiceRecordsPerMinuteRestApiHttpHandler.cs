using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  

   public class TimeKeeperServiceRecordsPerMinuteRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public TimeKeeperServiceRecordsPerMinuteRestApiHttpHandler (): this(null,false)
    {        
    }
    

    public TimeKeeperServiceRecordsPerMinuteRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {

      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */

      this.viewMethodPermittedRoles = Spedmon.Constants.ROLE_SBS_ALL; // THIS IS THE ROLE used for PayrollReport1.aspx;
                                                                      // following that pattern

      this.viewMethodCb = delegate()
      {    
        
        return TimekeeperAccountabilityRpt.viewObjectsRptServiceRecsPerMinute (   
                                             this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , this.pageObjectList
                                           , this.pageorder
                                           , this.idx
                                           , this.daterange);
      };
    }

  }       
}


