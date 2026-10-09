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
   * GroupsSvc */
  /*
   * Web services end point for Groups methods
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
  public class GroupsSvc : MBA.WebSvc
  {
    public GroupsSvc() : base() { }
        
    /***************************************************************************
     * viewSelDisp */
    /**
     * Selection view of practitioner allied discipline groups
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSelDisp(string term)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      {
        return Spedmon.Groups.viewSel(this.dbConnApp, this.log, this.uInfo,false,"", "", Groups.GROUP_SELECT_TYPE_DISP, term);
      },
      Constants.ROLE_SVC_SUP_PRAC); // Who can call this method
    }

    /***************************************************************************
     * viewSelDispSuper */
    /**
     * Selection view of practitioner allied discipline super groups
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSelDispSuper(string term)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      {
        return Spedmon.Groups.viewSel(this.dbConnApp, this.log, this.uInfo,false,"", "", Groups.GROUP_SELECT_TYPE_DISP_SUPER, term);
      },
      Constants.ROLE_SVC_PRAC); // Who can call this method
    }

    /***************************************************************************
     * viewSelRept */
    /**
     * Selection view of practitioner report groups
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSelRept (string term, string clientid)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      {
        return Spedmon.Groups.viewSel(this.dbConnApp, this.log, this.uInfo,false,"",clientid,Groups.GROUP_SELECT_TYPE_REPT, term);
      },
      Constants.ROLE_SVC_SUP_PRAC); // Who can call this method
    }

  }
}
