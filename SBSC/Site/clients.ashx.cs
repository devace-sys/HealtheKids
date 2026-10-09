using System;
using System.Collections.Generic;
using System.Web;
using MBA;


namespace Spedmon
{

    /***************************************************************************
     * clients.ashx */
    /*
     ***************************************************************************/

    public class ClientsRpt : WebReportDocument
    {
        public const int REPT_NUM_VIEW                  = 1;
        public const int RPT_SPEDCARE_WEEKLY            = 10;
        public const int RPT_SPEDCARE_WEEKLY_EXTENDED   = 11;
        public const int RPT_BATCHES_ASSIGNED_NOT_DONE  = 999; //we will remove this eventually - isn't really pertaining to clients
        public const int RPT_BATCHES_IN_PROCESS         = 998; // ditto

        public ClientsRpt()
        {
            /*-------------------------------
             * Define permitted roles 
             * Call framework method
             * _reportEditView;
             * _reportPageView;
             * _reportPageNumber;
             *------------------------------*/
           
            this._permittedRoles = Constants.ROLE_SBS_ALL;
            this.cbReportData = delegate()
            {

                if (this._reportNumber == RPT_SPEDCARE_WEEKLY)
                    return Spedmon.Clients.rptSpEdCareWeeklyReport(
                                          dbConnApp,
                                          log,
                                          uInfo,
                                          _reportPaging,
                                          _reportPageNumber,
                                          clientid,
                                          MBA.HttpApplication.getParameter("as-of-date"), // why  not do it like this?
                                          _reportEditView,
                                          clrepidLEA,
                                          activeLEA
                                          );

                if (this._reportNumber == RPT_SPEDCARE_WEEKLY_EXTENDED)
                    return Spedmon.Clients.rptSpEdCareWeeklyReportExtended(
                                          dbConnApp,
                                          log,
                                          uInfo,
                                          _reportPaging,
                                          _reportPageNumber,
                                          _reportEditView,
                                          @""
                                          );


                if (this._reportNumber == RPT_BATCHES_ASSIGNED_NOT_DONE) // will remove this eventually
                    return Spedmon.Clients.rptBatchesAssignedNotDone(
                                          dbConnApp,
                                          log,
                                          uInfo,
                                          _reportPaging,
                                          _reportPageNumber,
                                          clrepidLEA,
                                          recUserID
                                          );

                if (this._reportNumber == RPT_BATCHES_IN_PROCESS) // will remove this eventually
                    return Spedmon.Clients.rptBatchesInProcess(
                                          dbConnApp,
                                          log,
                                          uInfo,
                                          _reportPaging,
                                          _reportPageNumber,
                                          clientid,
                                          clrepidLEA,
                                          MBA.HttpApplication.getParameter(Constants.PARM_BATCH_STATUS_CODE),                                                                                    
                                          recUserID
                                          );
                
                return Spedmon.Clients.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _name, _reportEditView, _active, activeLEA, activeMAA,
                                              firstcheck,lastcheck, approved_837, approved_835,rvnsharectgLEA,rvnsharectgMAA, clrepidLEA,owndbycompidLEA, owndbycompidMAA, viewNotes);
            };
        }
    }
}

