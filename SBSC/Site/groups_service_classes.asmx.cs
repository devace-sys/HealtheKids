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
   * GroupsServiceClassesSvc */
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
  
  public class GroupsServiceClassesSvc : MBA.WebSvc
  {
    public GroupsServiceClassesSvc() : base() { }
        
    /***************************************************************************
     * viewSel */
    /**
     * Selection view of groups service classes
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSel (  string svcClassPartID
	                            , string term )
    {
      return (ReturnSel) callMethod (
	        typeof (ReturnSel)
		    , delegate()
          {
            return Spedmon.GroupsServiceClasses.viewSel ( this.dbConnApp
		                                                    , this.log
							  					       	                      , this.uInfo
								  					                            , false
									  				                            , ""													 
										  			                            , svcClassPartID
											  		                            , term );
          }
	      , Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

    /***************************************************************************
     * viewSelForPatExpdSvcs */
    /**
     * Selection view of groups service classes for patient expected services
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSel viewSelForPatExpdSvcs ( string term )
    {
      return (ReturnSel) callMethod (
	        typeof (ReturnSel)
		    , delegate()
          {
            return Spedmon.GroupsServiceClasses.viewSelForPatExpdSvcs ( this.dbConnApp
		                                                                   , this.log
							  					       	                                     , this.uInfo
								  					                                           , false
									  				                                           , ""													 										  			                            
											  		                                           , term );
          }
	      , Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

    /***************************************************************************
     * viewSelForPlanWriter */
    /**
     * Selection view of groups service classes for patient expected services
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSel viewSelForPlanWriter ( string term )
    {
      return (ReturnSel) callMethod (
	        typeof (ReturnSel)
		    , delegate()
          {
            return Spedmon.GroupsServiceClasses.viewSelForPlanWriter (  this.dbConnApp
		                                                                   , this.log
							  					       	                                     , this.uInfo
								  					                                           , false
									  				                                           , ""													 										  			                            
											  		                                           , term );
          }
	      , Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

    /***************************************************************************
     * viewSelForOrpDocs */
    /**
     * Selection view of groups service classes for patient expected services
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSel viewSelForOrpDocs ( string term )
    {
      return (ReturnSel) callMethod (
	        typeof (ReturnSel)
		    , delegate()
          {
            return Spedmon.GroupsServiceClasses.viewSelForOrpDocs (  this.dbConnApp
		                                                                , this.log
							  					       	                                  , this.uInfo
								  					                                        , false
									  				                                        , ""													 										  			                            
											  		                                        , term );
          }
	      , Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }


  }
}
