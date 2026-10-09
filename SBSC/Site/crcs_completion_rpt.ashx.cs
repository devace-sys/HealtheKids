using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * CrcsCompletionRptViw */
    /*
     ***************************************************************************/

    public class CrcsCompletionRptViw : WebReportDocument
    {
        public const int REPT_NUM_VIEW = 1;

        public CrcsCompletionRptViw()
        {
          /*-------------------------------
           * Define permitted roles 
           * Call framework method
           * _reportEditView;
           * _reportPageView;
           * _reportPageNumber;
           *------------------------------*/
      
          this._permittedRoles = Constants.ROLE_CRCS_ADMIN;
          this.cbReportData = delegate()
          {        
            return Spedmon.CRCSCompletionReport.viewRpt (dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, fiscalyearid);
          };
        }
    }
}