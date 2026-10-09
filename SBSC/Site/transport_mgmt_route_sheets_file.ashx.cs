using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * transport_mgmt_route_sheets_file.ashx.cs */
  /*
   ***************************************************************************/
   
  public class TransportMgmtRouteSheetsFileViw : MBA.WebCustomFile
  {
    
    public TransportMgmtRouteSheetsFileViw()
    {
      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
      
	    string clientID    = MBA.HttpApplication.getParameter(@"organizationid");	    
      string transMgmtID = MBA.HttpApplication.getParameter(@"ownerid");                                           
      string routeID     = MBA.HttpApplication.getParameter(@"groupid");
      string startDate   = MBA.HttpApplication.getParameter(@"startdate");
	  
	    this._cbGenerateFileBytes = delegate()
      {
        return TransportationMgmtRouteSheetProcessing.generateOutgoingRouteSheetsFile (  dbConnApp
                                                                                       , log
                                                                                       , uInfo
                                                                                       , clientID
                                                                                       , transMgmtID 
                                                                                       , routeID
                                                                                       , startDate );
      };
    }
  }
}