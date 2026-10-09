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
   * ClientGroupServiceClassNameSpecificPracticeRuleSetsSvc */
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
  public class ClientGroupServiceClassNameSpecificPracticeRuleSetsSvc : MBA.WebSvc
  {
    public ClientGroupServiceClassNameSpecificPracticeRuleSetsSvc() : base() { }
    
    /***************************************************************************
     * updateruleset */
    /**
     * 
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord updateruleset (
        string clientid
      , string departmentheadscanviewsupervisedpracsprivatenotes
      , string departmentheadscanviewsupervisedpracsstoredfiles
      , string departmentheadscanviewsupervisedpracssvcrecs
      , string onlydepartmentheadscanmanagedirectsupervisionassignments
      , string departmentheadscanonlyviewsupervisedpracsdataintheirreportinggroup
      , string departmentheadscanonlymanagedirectsupervisionassignmentsintheirreportinggroup
      , string supervisingandsupervisedpracsmustbeinsamereportinggroup
      , string departmentheadscanviewallpracdataintheirreportinggroup
	  , string recid )
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {
          return Spedmon.ClientGroupServiceClassNameSpecificPracticeRuleSets.updateRuleSet (
            this.dbConnApp
          , this.log
          , this.uInfo
          , clientid
          , departmentheadscanviewsupervisedpracsprivatenotes
          , departmentheadscanviewsupervisedpracsstoredfiles
          , departmentheadscanviewsupervisedpracssvcrecs
          , onlydepartmentheadscanmanagedirectsupervisionassignments
          , departmentheadscanonlyviewsupervisedpracsdataintheirreportinggroup
          , departmentheadscanonlymanagedirectsupervisionassignmentsintheirreportinggroup
          , supervisingandsupervisedpracsmustbeinsamereportinggroup
          , departmentheadscanviewallpracdataintheirreportinggroup
          , recid);
      },
      Constants.ROLE_SBS_MGMT_ANI);  // Who can call this method           
    }        	

  }
}
