using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  
   
  /***************************************************************************
   * OrpDocumentsStandardSelectionNamesRestApiHttpHandler */
  /**
   *    
   ***************************************************************************/

   public class OrpDocumentsStandardSelectionNamesRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public OrpDocumentsStandardSelectionNamesRestApiHttpHandler (): this(null,false)
    {        
    }    
    public OrpDocumentsStandardSelectionNamesRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */

      this.viewMethodPermittedRoles = Constants.ROLE_SBS_ALL;
      this.viewMethodCb = delegate()
      {

        return Spedmon.ORPDocumentsStandardSelectionNames.viewObjects (  this.dbConnApp
                                                                       , this.log
                                                                       , this.uInfo
                                                                       , this.pageObjectList
                                                                       , this.pageorder
                                                                       , this.idx
                                                                       , this.active
                                                                       , this.clientid
                                                                       , this.groupserviceclassnameid
                                                                       , this.term
                                                                       );
      };
    }

  }
}