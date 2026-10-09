using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * oneononeaideassignments.ashx.cs */
  /*
   ***************************************************************************/
   
  public class OneOnOneAideAssignmentsViw : WebReportDocument
  {
    
    public OneOnOneAideAssignmentsViw()
    {
      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;
      this.cbReportData = delegate()
      {
        return Spedmon.OneOnOneAideAssignments.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, patid, pracid, _reportEditView, active);
      };
    }
  }
}