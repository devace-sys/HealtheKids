using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * patients.ashx */
    /*
     ***************************************************************************/

    public class PatientsRpt : WebReportDocument
    {
        public const int REPT_NUM_VIEW          = 1;
        public const int VIEW_MERGE_TBL         = 21;
        public const int REPT_MERGES            = 33;
        public const int REPT_REDUNDANT_RECORDS = 50;
        public const int RPT_CYBHI_PATS_EXPORT  = 200;
        public const int RPT_CYBHI_PATS_AUDIT   = Constants.RPT_CYBHI_PATS_AUDIT;
        public const int RPT_CYBHI_PATS_EXPORT_FIXED = 220;

        public PatientsRpt()
        {
            /*-------------------------------
             * Define permitted roles 
             * Call framework method
             * _reportEditView;
             * _reportPageView;
             * _reportPageNumber;
             *------------------------------*/

            this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
            if (this._reportNumber == VIEW_MERGE_TBL)
            {
                string csis = MBA.HttpApplication.getParameter("csis");
                this.cbReportData = delegate ()
                {
                    return Spedmon.Patients.viewMergeTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, "0", clientid, _lastName, _firstName, dob, dos, _reportEditView, this.active, csis);
                };
            }
            else if (this._reportNumber == REPT_MERGES)
            {
                this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;

                this.cbReportData = delegate ()
                {
                    return Spedmon.Patients.rptPossiblePatMergesNeeded(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid);
                };
            }
            else if (this._reportNumber == REPT_REDUNDANT_RECORDS)
            {
                this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;

                this.cbReportData = delegate ()
                {
                    return Spedmon.Patients.rptFindRedundantPatientRecords(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid);
                };
            }
            else if (this._reportNumber == RPT_CYBHI_PATS_EXPORT)
            {
                this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL_LEA_COORD;

                this.cbReportData = delegate ()
                {
                    return Spedmon.Patients.rptCybhiPatsExport(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid);
                };
            }           
            else if (this._reportNumber == RPT_CYBHI_PATS_EXPORT_FIXED)
            {
                this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL_LEA_COORD;

                this.cbReportData = delegate ()
                {
                    return Spedmon.Patients.rptCybhiPatsExportFixed(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid);
                };
            }
            
            else if (this._reportNumber == RPT_CYBHI_PATS_AUDIT)
            {
                this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL_LEA_COORD_CYBHI_COORD;

                this.cbReportData = delegate ()
                {
                    return Spedmon.Patients.rptCybhiPatsAudit(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid);
                };
            }
            else
            {
                this.cbReportData = delegate ()
                {
                    return Spedmon.Patients.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, "0", clientid, _lastName, _firstName, dob, dos, _reportEditView, null);
                };
            }
        }
    }
}