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
  /***************************************************************************
   * RolesSvc */
  /*
   * Web services end point for user roles.
   *
   * Unless indicated, each of these methods require that the caller is 
   * logged in.
   * 
   * Each end point method provides a wrapper for a coresponding framework
   * method that is not accessible from the outside.
   * 
   * These wrappers handle access control and parameter replacement.
   * 
   * The method is restricted to calls for given user groups
   * 
   * Parameter replacement is used to enforce additional access control within
   * the user group but this is limited.
   *
   * The final line of defense for access control are the database udfs or 
   * sprocs that return or save data
   ***************************************************************************/

  [WebService(Namespace = "http://spedcare.com/")]
  [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
  [ScriptService]
  
  public class RolesSvc : MBA.WebSvc
  {    
  
    /***************************************************************************
     * viewSel */
    /**
     * View roles selection
     * 
     * @return      ReturnSel
     ***************************************************************************/  
              
    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSel (string term)
    {
    return (ReturnSel)
    callMethod(typeof(ReturnSel),    
    delegate()
    {    
      return Roles.viewSel(dbConnUser, log, uInfo, false,"", Constants.APP_NAME, term);},
      Constants.ROLE_SVC_PRAC);  // Who can call this method           
    }
  }
}
