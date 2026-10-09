using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
    /***************************************************************************
      * clientattendancedaytypes.ashx */
    /*
     ***************************************************************************/

    public class ClientAttendanceDayTypesRpt : WebReportDocument
    {

        public const int REPT_NUM_VIEW = 1;        

        public ClientAttendanceDayTypesRpt()
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
                return Spedmon.ClientAttendanceDayTypes.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, _reportEditView, active);
            };
        }
    }
}
