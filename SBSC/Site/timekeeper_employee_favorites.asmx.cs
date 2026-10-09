using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.Services.Protocols;
using System.Web.Script.Serialization;
using System.ComponentModel;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

  [WebService(Namespace = "http://spedcare.com/")]
  [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
  [ScriptService]
  
  public class TimekeeperEmployeeFavoritesSvc : MBA.WebSvc
  {

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSel viewSelDTKOrganizations(string term)
    {
      return (ReturnSel)
      callMethod(typeof(ReturnSel), 
      delegate()
      {
        return TimekeeperEmployeeFavorites.viewSelDTKOrganizations(this.dbConnApp, this.log, this.uInfo, true, "", ""); 
      },
      Constants.ROLE_SBS_ALL); // Who can call this method    
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
   
    public ReturnSel viewSelTasks (string term)
    {
      return (ReturnSel)
      callMethod(typeof(ReturnSel),
      delegate()
      {
        return TimekeeperEmployeeFavorites.allAvailableTasksViewSel(this.dbConnApp, this.log, this.uInfo, term);
      },
      Constants.ROLE_ADMIN_WORKLEADER_ONLY); // Who can call this method    
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSelTasksForEmployee (  string empid )
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      {
        return Spedmon.TimekeeperEmployees.viewSelTasksForEmployee( dbConnApp 
                                                                     , log
                                                                     , uInfo
                                                                     , empid
                                                                     );
                                             
      },
      Constants.ROLE_ADMIN_WORKLEADER_ONLY); // Who can call this method
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord saveTaskForEmployee
      (string organizationID,  // comes in as empty-string; idk how to make the browser AJAX stop submitting this
       string ownerID,   // comes in as empty-string; idk how to make the browser AJAX stop submitting this      
       string groupID, // employee ID; idk how to make the browser submit this as { empID: 10 } instead of { groupID: 10 }
       string entityID, // task ID
       string saveType,  // comes in as "1" every time; idk how to make the browser JS stop submitting this
       string recID      // comes in as empty quotes each time; idk how to make the browser stop submitting this
        )
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.TimekeeperEmployees.saveFavTaskForEmployee
         (this.dbConnApp,
          this.log,
          this.uInfo,
          entityID,
          groupID);
      },
      Constants.ROLE_ADMIN_WORKLEADER_ONLY);  // Who can call this method           
    }  

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSaveRecord deleteTaskForEmployee
      (string organizationID,  // comes in as empty-string; idk how to make the browser AJAX stop submitting this
       string ownerID,   // comes in as empty-string; idk how to make the browser AJAX stop submitting this      
       string groupID, // employee ID; idk how to make the browser submit this as { empID: 10 } instead of { groupID: 10 }
       string entityID // task ID
        )
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.TimekeeperEmployees.deleteFavTaskForEmployee
         (this.dbConnApp,
          this.log,
          this.uInfo,
          entityID,
          groupID);
      },
      Constants.ROLE_ADMIN_WORKLEADER_ONLY);  // Who can call this method           
    } 

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord saveClientForEmployee
      (string organizationID,  // comes in as empty-string; idk how to make the browser AJAX stop submitting this
       string ownerID,   // comes in as empty-string; idk how to make the browser AJAX stop submitting this      
       string groupID, // employee ID; idk how to make the browser submit this as { empID: 10 } instead of { groupID: 10 }
       string entityID, // task ID
       string saveType,  // comes in as "1" every time; idk how to make the browser JS stop submitting this
       string recID      // comes in as empty quotes each time; idk how to make the browser stop submitting this
        )
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.TimekeeperEmployees.saveFavClientForEmployee
         (this.dbConnApp,
          this.log,
          this.uInfo,
          entityID,
          groupID);
      },
      Constants.ROLE_ADMIN_WORKLEADER_ONLY);  // Who can call this method           
    }  

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSaveRecord deleteClientForEmployee
      (string organizationID,  // comes in as empty-string; idk how to make the browser AJAX stop submitting this
       string ownerID,   // comes in as empty-string; idk how to make the browser AJAX stop submitting this      
       string groupID, // employee ID; idk how to make the browser submit this as { empID: 10 } instead of { groupID: 10 }
       string entityID // task ID
        )
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.TimekeeperEmployees.deleteFavClientForEmployee
         (this.dbConnApp,
          this.log,
          this.uInfo,
          entityID,
          groupID);
      },
      Constants.ROLE_ADMIN_WORKLEADER_ONLY);  // Who can call this method           
    } 


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSel viewSelFavoriteClients (string empid)
    {
      return (ReturnSel)
      callMethod(typeof(ReturnSel), 
      delegate()
      {
        return Spedmon.TimekeeperEmployees.favoriteClientsViewSel(dbConnApp
                                                                     , log
                                                                     , uInfo
                                                                     , empid
                                                                     );
      },
      Constants.ROLE_ADMIN_WORKLEADER_ONLY); // Who can call this method    
    }


  }
}
