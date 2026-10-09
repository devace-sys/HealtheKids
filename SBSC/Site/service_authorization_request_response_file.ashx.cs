using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * service_authorization_request_response_file */
  /*
   ***************************************************************************/
   
  public class service_authorization_request_response_file : MBA.WebCustomFile
  {
    
    public service_authorization_request_response_file ()
    {
      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/

      this._permittedRoles =  Spedmon.Constants.ROLE_SVC_AUTH_RESPONDERS;
      string requestID     =  MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
	  	  
	  this._cbGenerateFileBytes = delegate()
      {
        ReturnFileBytes rrf = ServiceAuthorizationCommon.generateRequestResponseFile (  dbConnApp
                                                                                      , log
                                                                                      , uInfo
                                                                                      , requestID );
        return rrf;
      };
    }
  }
}