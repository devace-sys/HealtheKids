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
using System.IO;

namespace Spedmon
{


  [WebService(Namespace = "http://spedcare.com/")]
  [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
  [ScriptService]

  public class TimekeeperTasksSvc : MBA.WebSvc
  {
    public TimekeeperTasksSvc() : base() { }
   
   /***************************************************************************
    * viewSel */
    /**
    * Selection view of schedules
    *
    * @param    clientid    Optional
    * @param    term        Optional
    ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSel viewSel (string term)
    {
      return (ReturnSel)
      callMethod(typeof(ReturnSel), 
      delegate()
      {
        return Spedmon.TimeKeeperTasks.allAvailableTasksViewSel(this.dbConnApp, this.log, this.uInfo, term); 
      },
      Constants.ROLE_SBS_ALL); // Who can call this method    
    }

  }
}
