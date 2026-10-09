using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    /***************************************************************************
     * PractitionerPatientReferralRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class PractitionerPatientReferralRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public PractitionerPatientReferralRestApiHttpHandler(): this(null,false)
    {        
    }
    
    public PractitionerPatientReferralRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */

      this.viewMethodPermittedRoles = Constants.ROLE_ALL_PCAL_AND_CLIENT;
      this.viewMethodCb = delegate()
      {    
        
        return Spedmon.PractitionerPatientReferrals.viewObjects(  this.dbConnApp
                                                  , this.log
                                                  , this.uInfo
                                                  , this.pageObjectList
                                                  , this.pageorder
                                                  , this.idx
                                                  , this.active
                                                  , this.clientid
                                                  , this.pracid
                                                  , this.referringbyuserid
                                                  , this.patid
                                                  , this.filterascomplete);
      };
    }

  }     
  

}


