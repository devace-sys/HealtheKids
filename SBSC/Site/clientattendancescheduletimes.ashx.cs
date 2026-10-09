using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * clientattendancescheduletimes.ashx.cs */
    /*
     ***************************************************************************/

    public class ClientAttendanceScheduleTimesRpt : WebReportDocument
    {

        public const int REPT_NUM_VIEW = 1;

        public ClientAttendanceScheduleTimesRpt()
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
                return Spedmon.ClientAttendanceScheduleTimes.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, fiscalyearid, scheduleid, _reportEditView, active);
            };
        }
    }
}

