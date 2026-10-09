using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * ServiceAuthorizationRequestsRpt */
  /*
   ***************************************************************************/

  public class ServiceAuthorizationRequestsRpt : WebReportDocument 
  {    
    public const int REPT_NUM_VIEW_ACTIVE = 1;
    
    public ServiceAuthorizationRequestsRpt()
    {

      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_SVC_AUTH_RESPONDERS;
      this.cbReportData = delegate(){
        
       if (this._reportNumber == REPT_NUM_VIEW_ACTIVE )
       { 
         
         return Spedmon.ServiceAuthorizationRequests.viewTbl  (
           dbConnApp
           , log
           , uInfo
           , _reportPaging
           , _reportPageNumber
           , "1"
           , "1"
           , this.clientid
           , this.startDate
           , this.endDate
           , this.responseCode
           , this.closed
           , this.requestID
         );
       }

       /* TODO: Return some sort of default */
       return null; 

      };
    }
  }
}