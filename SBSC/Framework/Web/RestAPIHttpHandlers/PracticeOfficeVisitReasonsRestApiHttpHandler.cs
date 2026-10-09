using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  
   
  /***************************************************************************
   * PracticeOfficeVisitReasonsRestApiHttpHandler */
  /**
   *    
   ***************************************************************************/

   public class PracticeOfficeVisitReasonsRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public PracticeOfficeVisitReasonsRestApiHttpHandler (): this(null,false)
    {        
    }    
    public PracticeOfficeVisitReasonsRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */

      this.viewMethodPermittedRoles = Constants.ROLE_SBS_ALL;
      this.viewMethodCb = delegate()
      {

        return Spedmon.PracticeOfficeVisitReasons.viewObjects (  this.dbConnApp
                                                                , this.log
                                                                , this.uInfo
                                                                , this.pageObjectList
                                                                , this.pageorder
                                                                , this.idx
                                                                , this.active                                                                
                                                                , this.groupserviceclassnameid
                                                                , this.term );
      };
    }

  }
}