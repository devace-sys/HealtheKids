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

  public class ClientsNotesTopicsSvc : MBA.WebSvc
  {

    public ClientsNotesTopicsSvc() : base() { }
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

     /* Please remember viewSel is one of the few exceptions for web method names as someone named the first set of these methods viewSel
      * so it order to maintain the standard that was set, viewSel can be mixed case.
      * Parameters are still all lowercase.  Just the method name is set.
      */
    public ReturnSel viewSel (string term )
    {

      return (ReturnSel)
      callMethod(typeof(ReturnSel), 
      (MethodCallback)delegate()
      {

        return Spedmon.ClientsNotesTopics.viewSel(this.dbConnApp, this.log, this.uInfo, true, "", term); 

      },
      Constants.ROLE_ALL); // Who can call this method    

    }



  }
}
