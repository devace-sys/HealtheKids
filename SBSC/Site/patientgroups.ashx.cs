using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * patientgroups.ashx */
  /*
   ***************************************************************************/
   
  public class PatientGroupsViw : WebReportDocument
  {
    
    public PatientGroupsViw()
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
        return Spedmon.PatientGroups.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, pracid, _reportEditView, active);
      };
    }
  }
}