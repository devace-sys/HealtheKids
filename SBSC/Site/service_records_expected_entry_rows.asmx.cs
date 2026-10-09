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
     * ServiceRecordsExpectedEntryRowsSvc*/
    /*
     * Web services end point 
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

    public class ServiceRecordsExpectedEntryRowsSvc : MBA.WebSvc
    {

    /***************************************************************************
     * viewListExpectedTmtSvcsOnDos */
    /**
     * 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnObjects viewListExpectedTmtSvcsOnDos (string clientid, string pracid, string dos, string pracpatgroupid)
    {
      return (ReturnObjects) 
      callMethod(typeof(ReturnObjects),
      delegate()
      {
          
        var returnData = ServiceRecordsExpectedEntryRows.viewListFromExpectedTmtSvcsOnDos (
            this.dbConnApp
          , this.log
          , this.uInfo
          , clientid
          , pracid
          , ""
          , dos
          , pracpatgroupid );

         var retObjs = new ReturnObjects();
         retObjs.data = returnData.ToArray();        
         return retObjs;
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    } 
    
    /***************************************************************************
     * viewListExpectedTmtSvcsOnDosForPat */
    /**
     * 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnObjects viewListExpectedTmtSvcsOnDosForPat (
          string clientid 
        , string pracid
        , string patid
        , string dos )
    {
      return (ReturnObjects) 
      callMethod(typeof(ReturnObjects),
      delegate()
      {
          
        var returnData = ServiceRecordsExpectedEntryRows.viewListFromExpectedTmtSvcsOnDos (
            this.dbConnApp
          , this.log
          , this.uInfo
          , clientid
          , pracid
          , patid
          , dos
          , "" );
         
         var arrayOfObjects = returnData.ToArray();
         var retObjs = Entities.generatePartialReturnObjects(typeof(ServiceRecordsExpectedEntryRow),"");
         if (arrayOfObjects is null) return retObjs;
         long numRecs = arrayOfObjects.Length;
         if (numRecs == 0) return retObjs;
         retObjs.hasRecords = true;
         retObjs.data = arrayOfObjects;
         retObjs.recordsReturned = numRecs;
         retObjs.recordsTotal = numRecs;
         return retObjs;
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }
    }
}
