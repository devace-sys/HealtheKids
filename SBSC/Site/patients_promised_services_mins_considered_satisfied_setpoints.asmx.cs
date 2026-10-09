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
   * PatientsPromisedServicesMinsConsideredSatisfiedSetpointsSvc */
  /*
   * Web services end points 
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
  
  public class PatientsPromisedServicesMinsConsideredSatisfiedSetpointsSvc : MBA.WebSvc
  {
    public PatientsPromisedServicesMinsConsideredSatisfiedSetpointsSvc() : base() { }
        
    /***************************************************************************
     * get */
    /**
     * Load current record and put in a ReturnEntity class for easy transport.
     * 
     * TODO: This is a temporary method until we can expand the management of
     * this data.  Until then there is only one record per client.
     **************************************************************************/
    
	[WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnEntity get (string clientid)
    {
      return (ReturnEntity)
        callMethod(typeof(ReturnEntity),
        delegate ()
        {
           return Spedmon.PatientsPromisedServicesMinsConsideredSatisfiedSetPoints.get (dbConnApp, log, uInfo, clientid);
        }, Constants.ROLE_CDE_COMPLIANCE_MANAGE_LOCAL); // Who can call this method
    }

	/***************************************************************************
     * save */
    /**      
     * Saves new or replaces existing record based on clientID.
     * 
     * @parm minminsperfreqdaily   The min num of minutes for daily plans
     * @parm minminsperfreqweekly  The min num of minutes for weekly plans
     * @parm minminsperfreqmonthly The min num of minutes for monthly plans
     *
     * TODO: Convert this from a saveOrReplace style procedure to a normal 
     * save procedure once we are able to expand the management of this data.
     * Until then there is only one record per client.
     ***************************************************************************/   

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSaveOrReplaceRecord save (
          string    clientid
        , string    minminsperfreqdaily
        , string    minminsperfreqweekly
        , string    minminsperfreqmonthly
        , string    notes )
    {
      return (ReturnSaveOrReplaceRecord)
        callMethod(typeof(ReturnSaveOrReplaceRecord),
        delegate ()
        {
           return Spedmon.PatientsPromisedServicesMinsConsideredSatisfiedSetPoints.save (
                 dbConnApp
               , log
               , uInfo
               , clientid
               , minminsperfreqdaily
               , minminsperfreqweekly
               , minminsperfreqmonthly
               , notes
               , @"N");
        }, Constants.ROLE_CDE_COMPLIANCE_MANAGE_LOCAL); // Who can call this method
    }          
  }
}
