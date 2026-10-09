using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * claimexceptions.ashx */
    /*
     ***************************************************************************/

    public class claimProcedureFeesRpt : WebReportDocument
    {

        public claimProcedureFeesRpt()
        {

            /*-------------------------------
             * Define permitted roles 
             * Refine access
             * Call framework method
             *------------------------------*/

            this._permittedRoles = Spedmon.Constants.ROLE_SBS_MGMT;

            this.cbReportData = delegate()
            {

                return Spedmon.ClaimProcedureFees.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView, null,proccode, startDate, active);

            };
        }
    }
}
