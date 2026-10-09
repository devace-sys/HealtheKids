using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * patient_places.ashx.cs */
  /*
   ***************************************************************************/
   
  public class PatientPlacesViw : WebReportDocument
  {
    
    public PatientPlacesViw()
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
        return Spedmon.PatientPlaces.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView, active, clientid, patid);
      };
    }
  }
}