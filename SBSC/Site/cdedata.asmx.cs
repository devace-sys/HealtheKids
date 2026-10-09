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
   * CdeDataSvc */
  /*
   * Web services end point for CdeData methods
   *
   * Unless indicated, each of these methdos are for sbs users only
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

  public class CdeDataSvc : MBA.WebSvc
  {
    public CdeDataSvc() : base() { }

  
    /***************************************************************************
     * viewNamesValuesCounties */
    /**
     * Selection view of clients
     *
     * @param  term         Required, search term string (blank for all)
     ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnNamesValues viewNamesValuesCounties (string term)
    {
      return (ReturnNamesValues)
      callMethod(typeof(ReturnNamesValues), 
      delegate()
      {
        return Spedmon.CdeRecords.viewCountiesNamesValues(this.dbConnApp, this.log, this.uInfo, term);
      }); // Who can call this method 
    }


    /***************************************************************************
     * viewNamesValuesDistricts */
    /**
     * Selection view of clients
     *
     * @param  term         Required, search term string (blank for all)
     ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnNamesValues viewNamesValuesDistricts (string countycode, string term)
    {
      return (ReturnNamesValues)
      callMethod(typeof(ReturnNamesValues), 
      delegate()
      {
        return Spedmon.CdeRecords.viewDistrictsNamesValues(this.dbConnApp, this.log, this.uInfo, countycode, term);
      }); // Who can call this method 
    }
	
  }
}
