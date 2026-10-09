using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
   
  /***************************************************************************
   * PatientPersonsRestApiHttpHandler */
  /**
   *    
   ***************************************************************************/

   public class PatientPersonsRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public PatientPersonsRestApiHttpHandler (): this(null,false)
    {        
    }
    
    public PatientPersonsRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */

      this.viewMethodPermittedRoles = Constants.ROLE_ALL_PCAL_AND_CLIENT;
      this.viewMethodCb = delegate()
      {    
        
        return Spedmon.PatientPersons.viewObjects(  this.dbConnApp
                                                  , this.log
                                                  , this.uInfo
                                                  , this.pageObjectList
                                                  , this.pageorder
                                                  , this.idx
                                                  , this.active
                                                  , this.clientid
										          , this.patid
                                                  , this.personClassID1
                                                  , this.personClassID2
										          , this.term );
      };
    }

  }     
  

}


