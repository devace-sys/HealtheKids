using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * CrcsCompletionRptForAllClientsViw */
    /*
     ***************************************************************************/

    public class CrcsCompletionRptForAllClientsViw : WebReportDocument
    {
        public const int REPT_NUM_VIEW = 1;

        public CrcsCompletionRptForAllClientsViw()
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
            return Spedmon.CRCSCompletionReportForAllClients.viewRpt (dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, fiscalyearid);
          };
        }
    }
}