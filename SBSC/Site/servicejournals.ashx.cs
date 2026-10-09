using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * servicejournals.ashx.cs */
  /*
   ***************************************************************************/
   
  public class ServiceJournalsViw : WebReportDocument
  {
    
    public ServiceJournalsViw()
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
        return Spedmon.ServiceJournals.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView, active, clientid, pracid, patid, dateRange, completed);
      };
    }
  }
}