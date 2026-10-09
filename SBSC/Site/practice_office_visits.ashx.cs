using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Spedmon
{
    /***************************************************************************
     * PracticeOfficeVisitsView */
    /*
     ***************************************************************************/
    public class PracticeOfficeVisitsView : WebReportDocument
    {

        public const int REPT_NUM_VIEW = 1;
        public PracticeOfficeVisitsView()
        {
            /*-------------------------------
             * Define permitted roles 
             * Call framework method
             * _reportEditView;
             * _reportPageView;
             * _reportPageNumber;
             *------------------------------*/

            this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.cbReportData = delegate ()
            {
                return Spedmon.PracticeOfficeVisits.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView, active, groupServiceClassNameID, clientid, completed);
            };
        }
    }
}