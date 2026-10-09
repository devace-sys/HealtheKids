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
   * PersonsSvc */
  /*
   * Web services end point for person data
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
  
  public class PersonsSvc : MBA.WebSvc
  {    

    /***************************************************************************
     * load */
    /**
     * Load data
     *
     * @param  email    Persons email 
     * @param  source   Source of person data
     ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnPerson load (string email, string source)
    {
      return (ReturnPerson)
      callMethod(typeof(ReturnPerson), 
      delegate()
      {
        ReturnPerson so = new ReturnPerson();
        so.person = Persons.load(dbConnUser, log, uInfo, "", email, source);
        return so; 
      },
      Constants.ROLE_SBS_ALL); // Who can call this method
    }

    }
}
