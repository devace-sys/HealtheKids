using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * MissingServicesTreatmentViw */
  /*
   ***************************************************************************/

  public class MissingServicesTreatmentViw : WebReportDocument
  {    
    
    public const int REPT_NUM_VIEW_SUMMARY                 = 1;
    public const int REPT_NUM_VIEW_DETAILS                 = 2;
    public const int REPT_NUM_VIEW_FOR_PATIENT             = 3;
    public const int REPT_NUM_VIEW_SVC_DELIVERY_EXCEPTIONS = 4;
    public MissingServicesTreatmentViw()
    {

       /*-------------------------------
        * Define permitted roles 
        * Refine access
        * Call framework method based
        * on report number
        *------------------------------*/


      this._permittedRoles = Spedmon.Constants.ROLE_MISSING_SERVICES_MANAGE;
      this.cbReportData = delegate()
      {
        
        if (this._reportNumber == REPT_NUM_VIEW_SUMMARY)
        {
          // Pass through to default
        }
        else if (this._reportNumber == REPT_NUM_VIEW_DETAILS)
        {
          return Spedmon.MissingServicesTreatmentDetails.viewTbl(dbConnApp, log, uInfo, rd, _reportPaging, _reportPageNumber, _reportEditView, _active, clientid, groupServiceClassNameID, spEdServiceCode, svcTrackingClass, leaBopOnlyOrAllSped);
        }
        else if (this._reportNumber == REPT_NUM_VIEW_FOR_PATIENT)
        {
          return Spedmon.MissingServicesTreatmentsForAPatient.viewTbl(dbConnApp, log, uInfo, rd, _reportPaging, _reportPageNumber, _reportEditView, _active, clientid, groupServiceClassNameID, spEdServiceCode, orpDocID, svcTrackingClass, leaBopOnlyOrAllSped, patid, startDate, endDate);
        }
        else if (this._reportNumber == REPT_NUM_VIEW_SVC_DELIVERY_EXCEPTIONS)
        {
          return Spedmon.PatientPromisedServicesDeliveryExceptions.viewTbl(dbConnApp, log, uInfo, rd, _reportPaging, _reportPageNumber, _reportEditView, _active,datasource, clientid, patid, svcTrackingClass, spEdServiceCode, orpDocStandardSelectionNameID, startDate, endDate, reviewed);
        }
        // TODO: Add more reports if needed 

        return Spedmon.MissingServicesTreatmentsSummary.viewTbl(dbConnApp,log,uInfo,_reportPaging,_reportPageNumber,_reportEditView,_active,clientid,groupServiceClassNameID, spEdServiceCode, svcTrackingClass, leaBopOnlyOrAllSped);

      };
    }
  }
}