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

    public class claimProceduresRpt : WebReportDocument
    {

        public claimProceduresRpt()
        {

            /*-------------------------------
             * Define permitted roles 
             * Refine access
             * Call framework method
             *------------------------------*/

            this._permittedRoles = Spedmon.Constants.ROLE_SBS_MGMT;

            this.cbReportData = delegate()
            {

                return Spedmon.ClaimProcedures.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView,proccode,procmod1,procmod2,procmod3, active);

            };
        }
    }
}