using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * PatientVitalsMeasurementView */
    /*
     ***************************************************************************/

    public class PatientVitalsMeasurementView : WebReportDocument
  {
        public const int REPT_NUM_VIEW = 1;
        public PatientVitalsMeasurementView()
        {
            /*-------------------------------
             * Define permitted roles 
             * Call framework method
             * _reportEditView;
             * _reportPageView;
             * _reportPageNumber;
             *------------------------------*/

            this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.cbReportData = delegate ()
            {
                return Spedmon.PatientVitalsMeasurements.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView, active, clientid, patid);
            };
        }
  }
}