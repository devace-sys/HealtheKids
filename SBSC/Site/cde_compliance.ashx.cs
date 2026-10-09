using System;
using System.Collections.Generic;
using System.Web;
using MBA;


namespace Spedmon
{
  public class CdeComplianceViw : WebReportDocument
  {
    public const int REPT_NUM_VIEW_SUMMARY                                      = 1;
	public const int REPT_NUM_VIEW_DETAILS_BY_PATIENT                           = 2;
    public const int REPT_NUM_VIEW_DETAILS_BY_SERVICE                           = 3;
    public const int REPT_NUM_VIEW_PATIENTS_CDE_AUDIT_CURRENT                   = 4;
    public const int REPT_NUM_VIEW_PATIENTS_PROMISED_SERVICES_CDE_AUDIT_CURRENT = 5;
    public const int REPT_NUM_VIEW_PERFORMANCE_BY_SITE_SERVICE_SUMMARY          = 6;
    public const int REPT_NUM_VIEW_PERFORMANCE_BY_SITE_BUCKET_SUMMARY           = 7;
    public const int REPT_NUM_VIEW_PERFORMANCE_SERVICE_SUMMARY                  = 8;
    public const int REPT_NUM_VIEW_PERFORMANCE_BUCKET_SUMMARY                   = 9;

    public const int REPT_NUM_VIEW_FY_PERFORMANCE_BY_SITE_SERVICE_SUMMARY       =  10;
    public const int REPT_NUM_VIEW_FY_PERFORMANCE_SERVICE_SUMMARY               =  11;
    public const int REPT_NUM_VIEW_BY_PCAL_COMP_RATING_AND_PAT_DETAILS          =  12;
    public CdeComplianceViw()
    {
      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_CDE_COMPLIANCE_MANAGE;
      
      this.cbReportData = delegate() { 
         
        if (this._reportNumber ==  REPT_NUM_VIEW_SUMMARY)
        {
          /* TODO: Slot for future use*/
          return new ReturnDataTable();
        }
        if (this._reportNumber ==  REPT_NUM_VIEW_DETAILS_BY_PATIENT)
        {
          /* TODO: Slot for future use*/
           return new ReturnDataTable();
        }
        if (this._reportNumber ==  REPT_NUM_VIEW_DETAILS_BY_SERVICE) 
        { 
          return Spedmon.CdeComplianceBucketDetailsByService.viewTbl ( dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView, active, clientid, siteid, patid, spEdServiceCode, pcalComplianceRatingForPat, svcOverDelivery);
        }
        if (this._reportNumber == REPT_NUM_VIEW_PATIENTS_CDE_AUDIT_CURRENT)
        {
          return Spedmon.PatientsPromisedServicesCDEAuditsCurrentPatients.viewTbl ( dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView, active, clientid, patid);
        }
        if (this._reportNumber == REPT_NUM_VIEW_PATIENTS_PROMISED_SERVICES_CDE_AUDIT_CURRENT)
        {
          return Spedmon.PatientsPromisedServicesCDEAuditsCurrentPatientsExpectedServices.viewTbl ( dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView, active, clientid, patid);
        }

        if (this._reportNumber == REPT_NUM_VIEW_PERFORMANCE_BY_SITE_SERVICE_SUMMARY)
        {
          return Spedmon.PatientsPromisedServicesCDEAuditsCurrent.rptPerformanceBySiteServiceSummary ( dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid);              
        }

        if (this._reportNumber == REPT_NUM_VIEW_FY_PERFORMANCE_SERVICE_SUMMARY )
        {
            return Spedmon.PatientsPromisedServicesComplianceCurrentFY.rptAnnualPerformanceByServiceSummary (
                dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid
            );              
        }

        if (this._reportNumber == REPT_NUM_VIEW_FY_PERFORMANCE_BY_SITE_SERVICE_SUMMARY )
        {
            return Spedmon.PatientsPromisedServicesComplianceCurrentFY.rptAnnualPerformanceBySiteServiceSummary(
                dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid 
            );
        }

        if (this._reportNumber == REPT_NUM_VIEW_PERFORMANCE_BY_SITE_BUCKET_SUMMARY )
        {
          return Spedmon.PatientsPromisedServicesCDEAuditsCurrent.rptPerformanceBySiteBucketSummary ( dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid);              
        }

        if (this._reportNumber == REPT_NUM_VIEW_PERFORMANCE_SERVICE_SUMMARY)
        {
          return Spedmon.PatientsPromisedServicesCDEAuditsCurrent.rptPerformanceByServiceSummary ( dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid);              
        }

        if (this._reportNumber == REPT_NUM_VIEW_PERFORMANCE_BUCKET_SUMMARY)
        {
          return Spedmon.PatientsPromisedServicesCDEAuditsCurrent.rptPerformanceByBucketSummary ( dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid);              
        }

        if (this._reportNumber == REPT_NUM_VIEW_BY_PCAL_COMP_RATING_AND_PAT_DETAILS)
        {
          return Spedmon.CdeComplianceBucketDetailsByPcalComplianceRatingAndPatients.viewTbl ( dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView, active, clientid, siteid, pcalComplianceRatingForPat);              
        }
                
        /* Fallback */
        return new ReturnDataTable();
                
      }; 
    }
  }
}