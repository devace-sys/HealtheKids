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
  /***************************************************************************
   * DataDrivenFormPageSvc */
  /*
   * Web services end point for formpages methods
   *
   * Unless indicated, each of these methods are for sbs users only
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

  public class DataDrivenFormPageSvc : MBA.WebSvc
  {
    public DataDrivenFormPageSvc() : base() { }

  
    /***************************************************************************
     * viewSelections */
    /**
     * Selection view of a given entity
     *
     * @param  term         Required, search term string (blank for all)
     ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSelections viewSelections (string selectfrom, string selectwhat, string reqentval1, string reqentval2, string term)
    {
      return (ReturnSelections)
      callMethod(typeof(ReturnSelections), 
      delegate()
      {
        return Spedmon.DataDrivenWebForms.viewFormPagePartSelections(this.dbConnApp, this.log, this.uInfo, selectfrom, selectwhat, reqentval1, reqentval2, term);
      },Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method 
    }
	
  }
}
