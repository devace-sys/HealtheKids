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
   * TransportationMgmtTripCalculationsSvc */
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
  
  public class TransportationMgmtTripCalculationsSvc : MBA.WebSvc
  {

   
   /***************************************************************************
    * loadRefreshOrNew */
    /**
    * 
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnTransportationMgmtTripCalculation loadRefreshOrNew (  string organizationid
                                                                     , string entityid
                                                                     , string origplaceid
                                                                     , string destplaceid ) 
    {
      return (ReturnTransportationMgmtTripCalculation) 
     
      callMethod(
        typeof (ReturnTransportationMgmtTripCalculation)
      , delegate ()
      {    
        
	      return TransportationMgmtTripCalculations.loadRefreshOrNew (  dbConnApp
                                                                   , log
                                                                   , uInfo
                                                                   , organizationid
                                                                   , entityid
										                                               , origplaceid
										                                               , destplaceid
										                                               );

	  },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }
         
  }
}
