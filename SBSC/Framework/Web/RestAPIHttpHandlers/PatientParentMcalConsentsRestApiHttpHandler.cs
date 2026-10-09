using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  
   
  /***************************************************************************
   * PatientParentMcalConsentsRestApiHttpHandler */
  /**
   *    
   ***************************************************************************/

   public class PatientParentMcalConsentsRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public PatientParentMcalConsentsRestApiHttpHandler (): this(null,false)
    {        
    }    
    public PatientParentMcalConsentsRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */

      this.viewMethodPermittedRoles = Constants.ROLE_SBS_ALL_LEA_COORD;
      this.viewMethodCb = delegate()
      {
        var parentconsent     = MBA.HttpApplication.getParameter("parentconsent");
        var hasunknownconsent = MBA.HttpApplication.getParameter("hasunknownconsent");
        var hasheldclaims     = MBA.HttpApplication.getParameter("hasheldclaims");

        return Spedmon.PatientParentMcalConsents.viewObjects(   this.dbConnApp
                                                              , this.log
                                                              , this.uInfo
                                                              , this.pageObjectList
                                                              , this.pageorder
                                                              , this.idx
                                                              , this.active
                                                              , clientid
                                                              , patid
                                                              , parentconsent
                                                              , hasunknownconsent
                                                              , hasheldclaims
                                                             );
      };
    }

  }

}