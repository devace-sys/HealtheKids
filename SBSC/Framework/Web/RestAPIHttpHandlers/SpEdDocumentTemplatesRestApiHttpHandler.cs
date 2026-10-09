using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  
   
  /***************************************************************************
   * SpEdDocumentTemplatesRestApiHttpHandler */
  /**
   *    
   ***************************************************************************/

   public class SpEdDocumentTemplatesRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public SpEdDocumentTemplatesRestApiHttpHandler (): this(null,false)
    {        
    }    
    public SpEdDocumentTemplatesRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */

      this.viewMethodPermittedRoles = Constants.ROLE_SBS_ALL;
      this.viewMethodCb = delegate()
      {

        return Spedmon.SpEdDocumentTemplates.viewObjects (  this.dbConnApp
                                                           , this.log
                                                           , this.uInfo
                                                           , this.pageObjectList
                                                           , this.pageorder
                                                           , this.idx
                                                           , this.clientid                                                                                                                           
                                                           , this.term
                                                         );
      };
    }

  }
}