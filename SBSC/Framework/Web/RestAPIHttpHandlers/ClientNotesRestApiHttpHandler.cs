using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  

   public class ClientNotesRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public ClientNotesRestApiHttpHandler (): this(null,false)
    {        
    }
    

    public ClientNotesRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {

      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */

      this.viewMethodPermittedRoles = Constants.ROLE_SBS_ALL_LEA_COORD;

      this.viewMethodCb = delegate()
      {    
        
        return ClientsNotes.viewObjects (   this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , this.pageObjectList
                                           , this.pageorder
                                           , this.idx
                                           , this.clientid
                                           , MBA.HttpApplication.getParameter("topicid")
                                           , MBA.HttpApplication.getParameter("clientsFilteredForConsultant"));


      };
    }

  }     
  

}


