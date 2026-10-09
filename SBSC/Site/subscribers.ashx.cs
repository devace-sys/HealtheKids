using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * subscribers.ashx */
  /*
   ***************************************************************************/
   
  public class SubscribersViw : WebReportDocument
  {
    
    public SubscribersViw()
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
        return Spedmon.Subscribers.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, _reportEditView, active);
      };
    }
  }
}