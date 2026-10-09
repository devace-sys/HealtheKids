using System;
using System.Collections.Generic;
using System.Web;
using MBA;



namespace Spedmon
{
  /***************************************************************************
   * servicerecords.ashx */
  /*
   ***************************************************************************/

  public class ServiceRecordsRpt : WebReportDocument 
  {    
    public const int REPT_NUM_VIEW                                      =  1;
    public const int REPT_NUM_TATTLE                                    =  2;
    public const int REPT_NUM_WORK_NOT_RECEIVED                         =  3;
    public const int REPT_NUM_COMBINED_1ON1_BY_PMT_DATE                 =  4;
    public const int REPT_NUM_COMBINED_1ON1_BY_SVC_DATE                 =  5;
    public const int REPT_NUM_SVC_RECS_SVC_NOTES                        =  6;
    public const int REPT_NUM_SVCS_REND_COMP_STAT_FOR_ONE_PAT           =  7;
    public const int REPT_BATCHES_ABOUT_TO_AGEOUT                       =  8;
    public const int REPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS         =  9;
    public const int REPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK = 10;

    public const int REPT_INPUT_STAFF_TRAINING_IN_PROCESS               = 12;
    public const int REPT_BATCHES_NEEDING_PRIORITY_REVIEW               = 13;
    
    public const int REPT_SELPA_EXPORT_SYNCH                            = 50;
    public const int REPT_SELPA_EXPORT                                  = 51;
    public const int REPT_SELPA_EXPORT_FOR_SELPA                        = 52;

    public const int REPT_NUM_VIEW_FOR_RMTS                             =  71;

    public ServiceRecordsRpt()
    {

      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;

      if (this._reportNumber == REPT_BATCHES_ABOUT_TO_AGEOUT)
      {
          this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;
      }
      else if (this._reportNumber == REPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS)
      {
          this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;
      }
      else if (this._reportNumber == REPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK)
      {
          this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;
      }
      else if (this._reportNumber == REPT_BATCHES_NEEDING_PRIORITY_REVIEW)
      {
          this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;
      }
      else if (this._reportNumber == REPT_INPUT_STAFF_TRAINING_IN_PROCESS)
      {
          this._permittedRoles = Spedmon.Constants.ROLE_SBS_MGMT;
      }
      else if (this._reportNumber == REPT_SELPA_EXPORT_SYNCH)
      {
         this._permittedRoles = Spedmon.Constants.ROLE_CDE_COMPLIANCE_MANAGE;              
      }
      else if (this._reportNumber == REPT_SELPA_EXPORT)
      {
         this._permittedRoles = Spedmon.Constants.ROLE_CDE_COMPLIANCE_MANAGE;              
      }
      else if (this._reportNumber == REPT_SELPA_EXPORT_FOR_SELPA)
      {
         this._permittedRoles = Spedmon.Constants.ROLE_CDE_COMPLIANCE_MANAGE_FOR_SELPA;              
      }
      else
      {
        this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
      }
      
      this.cbReportData = delegate(){

          if (this._reportNumber == REPT_NUM_TATTLE)
              return Spedmon.ServiceRecords.rptTattle(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, groupid, pracid, dateRange, _reportEditView, active);

          else if (this._reportNumber == REPT_NUM_WORK_NOT_RECEIVED)
              return Spedmon.ServiceRecords.rptWorkNotSub(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, startDate);

          else if (this._reportNumber == REPT_NUM_COMBINED_1ON1_BY_PMT_DATE)
              return Spedmon.ServiceRecords.rptCombined1on1ByPmtDate(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, pracid, dateRange);

          else if (this._reportNumber == REPT_NUM_COMBINED_1ON1_BY_SVC_DATE)
              return Spedmon.ServiceRecords.rptCombined1on1BySvcDate(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, pracid, dateRange);

          else if (this._reportNumber == REPT_NUM_SVC_RECS_SVC_NOTES)
              return Spedmon.ServiceRecords.rptSvcRecordsSvcNotes(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, dateRange, pracid, patid, _reportEditView, active);

          else if (this._reportNumber == REPT_NUM_SVCS_REND_COMP_STAT_FOR_ONE_PAT)
              return Spedmon.ServiceRecords.rptSvcsRenderedComplianceStatsByPracGroupForPat(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, patid, dateRange, svcclass, pracid, _reportEditView, active);

          else if (this._reportNumber == REPT_BATCHES_ABOUT_TO_AGEOUT)
          {
              return Spedmon.InputBatchesStatus.RPT_Batches_About_To_AGE_OUT(
                  dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, clrepidLEA,
                  MBA.HttpApplication.getParameter("type_of_work"));
          }
          else if (this._reportNumber == REPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS)
          {
              return Spedmon.InputBatchesStatus.RPT_Count_OfBatchesInProcessbyStatus(
                  dbConnApp, log, uInfo, _reportPaging, _reportPageNumber);
          }
          else if (this._reportNumber == REPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK)
          {
              return Spedmon.InputBatchesStatus.RPT_CountBatchesReadyToAssignByTypeOfWork(
                  dbConnApp, log, uInfo, _reportPaging, _reportPageNumber);
          }
          else if (this._reportNumber == REPT_BATCHES_NEEDING_PRIORITY_REVIEW)
          {
              return Spedmon.InputBatchesStatus.RPT_BatchesNeedingPriorityReview(
                  dbConnApp, log, uInfo, _reportPaging, _reportPageNumber);

             // return Spedmon.InputBatchesStatus.RPT_BatchesNeedingPriorityReview(
            // dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clrepidLEA,
           //  MBA.HttpApplication.getParameter("type_of_work"));

          }


          else if (this._reportNumber == REPT_INPUT_STAFF_TRAINING_IN_PROCESS)
          {
              return Spedmon.InputBatchesStatus.RPT_Input_Staff_Training_In_Process(
                  dbConnApp, log, uInfo, _reportPaging, _reportPageNumber,
                        MBA.HttpApplication.getParameter("staffID")
                  );            
          }
          else if (this._reportNumber == REPT_SELPA_EXPORT_SYNCH)
          {
              return Spedmon.ServiceRecords.rptSpEdServicesForSelpaExportSynch (dbConnApp, dbConnUser, log, uInfo, _reportPaging, _reportPageNumber, clientid, entryDateRange);
          }
          else if (this._reportNumber == REPT_SELPA_EXPORT)
          {
              return Spedmon.ServiceRecords.rptSpEdServicesForSelpaExport (dbConnApp, dbConnUser, log, uInfo, _reportPaging, _reportPageNumber, clientid, dateRange);
          }
          else if (this._reportNumber == REPT_SELPA_EXPORT_FOR_SELPA)
          {
              return Spedmon.ServiceRecords.rptSpEdServicesForSelpaExportAllRelatedClients (dbConnApp, dbConnUser, log, uInfo, _reportPaging, _reportPageNumber, selpacode, dateRange);
          }

          else if ( this._reportNumber == REPT_NUM_VIEW_FOR_RMTS )
          {
              return Spedmon.ServiceRecords.viewTblSvcrecsForRmtsMatchScreen(
                  dbConnApp, log, uInfo, _reportPaging, _reportPageNumber
                  
                , clientid, pracid

                , dateRange

                , _reportEditView, null);

          }

           return Spedmon.ServiceRecords.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, groupServiceClassNameID, pracid, patid, svctypeid, reference, dateRange, entryDateRange, _reportEditView, null);
        
      };
    }
  }
}