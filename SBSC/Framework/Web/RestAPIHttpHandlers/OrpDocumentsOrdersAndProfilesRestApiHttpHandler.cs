using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  
   
  /***************************************************************************
   * OrpDocumentsOrdersAndProfilesRestApiHttpHandler */
  /**
   *    
   ***************************************************************************/

   public class OrpDocumentsOrdersAndProfilesRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public OrpDocumentsOrdersAndProfilesRestApiHttpHandler (): this(null,false)
    {        
    }    
    public OrpDocumentsOrdersAndProfilesRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */

      this.viewMethodPermittedRoles = Constants.ROLE_SVC_SUP_PRAC;
      this.viewMethodCb = delegate()
      {
        
        var orpApprovalState = MBA.HttpApplication.getParameter(Constants.PARM_ORP_APPROVAL_STATE);

        return Spedmon.ORPDocuments.viewObjectsOrdersAndProfiles (  this.dbConnApp
                                                                  , this.log
                                                                  , this.uInfo
                                                                  , this.pageObjectList
                                                                  , this.pageorder
                                                                  , this.idx
                                                                  , this.active
                                                                  , this.clientid
                                                                  , this.groupserviceclassnameid
                                                                  , this.patid
                                                                  , orpApprovalState);
      };
    }

  }
}