using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
    /***************************************************************************
      * practitioners.ashx */
    /*
     ***************************************************************************/

    public class ClientAttendanceCalendarsDatesRpt : WebReportDocument
    {

        public const int REPT_NUM_VIEW = 1;        

        public ClientAttendanceCalendarsDatesRpt()
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
              return Spedmon.ClientAttendanceCalendarDates.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, fiscalyearid, calendarid, _reportEditView, active);
            };
        }
    }
}
