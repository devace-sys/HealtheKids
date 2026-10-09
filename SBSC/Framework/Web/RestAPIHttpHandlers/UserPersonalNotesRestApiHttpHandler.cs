using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    /***************************************************************************
     * UserPersonalNotesRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class UserPersonalNotesRestApiHttpHandler : EntitiesRestApiHttpHandler
   {    
    
    public UserPersonalNotesRestApiHttpHandler(): this(null,false)
    {        
    }
    
    public UserPersonalNotesRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData                = routedata;
      this.localNetworkAccessOnly   = localnetworkaccessonly;     
     
      /* Wire up view method */

      this.viewMethodPermittedRoles = Constants.ROLE_ALL_PCAL_AND_CLIENT;
      this.viewMethodCb = delegate()
      {    
        
        return Spedmon.NoteLibrarySavedNotes.viewObjects(  this.dbConnApp
                                                          , this.log
                                                          , this.uInfo
                                                          , this.pageObjectList
                                                          , this.pageorder
                                                          , this.idx
                                                          , this.notenamespace
                                                          , this.notesource
                                                          , this.clientid
                                                          , this.pracid
                                                          , this.patid
                                                          , this.active
                                                          , this.term);
      };
    }

  }     
  

}


