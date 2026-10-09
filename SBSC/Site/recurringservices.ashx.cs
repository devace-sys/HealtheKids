using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * caseload.ashx */
  /*
   ***************************************************************************/
   
  public class RecurringServicesViw : WebReportDocument
  {
    
    public RecurringServicesViw()
    {
      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
      this.cbReportData = delegate()
      {
        return Spedmon.RecurringServices.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, patid, fiscalyearid, startDate, endDate, _reportEditView, active);
      };
    }
  }
}