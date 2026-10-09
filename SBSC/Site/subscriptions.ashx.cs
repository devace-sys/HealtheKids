using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * subscriptions.ashx */
  /*
   ***************************************************************************/
   
  public class SubscriptionsViw : WebReportDocument
  {
    
    public SubscriptionsViw()
    {
      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_SVC_PRAC;
      this.cbReportData = delegate()
      {
        return Spedmon.Subscriptions.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, _reportEditView, active);
      };
    }
  }
}