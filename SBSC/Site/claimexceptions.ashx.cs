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

    public class claimexceptionsRpt : WebReportDocument
    {

        public claimexceptionsRpt()
    {
    
      /*-------------------------------
       * Define permitted roles 
       * Refine access
       * Call framework method
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;

      this.cbReportData = delegate()
      {    
        
            return Spedmon.ClaimsProcessingExceptions.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, pracid,startDate,endDate, _reportEditView, active);
      
      };
    }
  }
}