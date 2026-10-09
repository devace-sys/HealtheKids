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
   
  public class CaseLoadsViw : WebReportDocument
  {
    
    public CaseLoadsViw()
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
        return Spedmon.CaseLoads.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, pracid, patid,_reportEditView, active);
      };
    }
  }
}