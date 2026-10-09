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

  public class ContactMethodsSvc : MBA.WebSvc
  {
    public ContactMethodsSvc() : base() { }
    
    
  
  /***************************************************************************
    * viewSel */
    /**
    * Selection view of clients
    * 
    * @param  term         Required, search term string (blank for all)
    ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSel viewSel(string term)
    {
        return (ReturnSel)
        callMethod(typeof(ReturnSel),
        delegate ()
        {
            return Spedmon.ContactMethods.viewSel(this.dbConnApp, this.log, this.uInfo, true, "", term);
        },
       Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method    
    }
  }
}
  
