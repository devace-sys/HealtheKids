using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  
   
  /***************************************************************************
   * ClaimServiceNameXrefAndFormDataRecordsRestApiHttpHandler */
  /**
   *    
   ***************************************************************************/

   public class ClaimServiceNameXrefAndFormDataRecordsRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public ClaimServiceNameXrefAndFormDataRecordsRestApiHttpHandler (): this(null,false)
    {        
    }    
    public ClaimServiceNameXrefAndFormDataRecordsRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */

      this.viewMethodPermittedRoles = Constants.ROLE_CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_ADMIN;
      this.viewMethodCb = delegate()
      {

        return Spedmon.ClaimServiceNameXrefAndFormDataRecords.viewObjects (   
                                                                this.dbConnApp
                                                              , this.log
                                                              , this.uInfo
                                                              , this.pageObjectList
                                                              , this.pageorder
                                                              , this.idx

                                                              , "1"  //this.active
                                                                // note: the existing restview isn't passing in active=1.
                                                                // I've never understood why we so often pass in active=1
                                                                // from requestData instead of securing it in middleware

                                                              , this.clientid  
                                                              , this.plantype
                                                              , this.groupid
                                                              , this.nameid
                                                              , this.groupserviceclassnameid
                                                              , this.svctypeid

                                                              , MBA.HttpApplication.getParameter(
                                                                "excludeClientBlank"
                                                                )

                                                              , this.term
                                                             );
      };
    }

  }

}