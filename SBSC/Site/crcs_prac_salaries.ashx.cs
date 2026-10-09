using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * CrcsPracSalariesViw */
  /*
   ***************************************************************************/
   
  public class CrcsPracSalariesViw : WebReportDocument
  {
    public const int REPT_NUM_VIEW =  1;

    public CrcsPracSalariesViw()
    {

      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_CRCS_ADMIN;
      this.cbReportData = delegate()
      {
        var quarter = MBA.HttpApplication.getParameter(Constants.PARM_QUARTER);

        if ( !(Util.IsNullOrEmpty(quarter) ))
          return Spedmon.CrcsPracSalaries.viewTbl (dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, fiscalyearid, quarter, _reportEditView, active);

        return  Spedmon.CrcsPracSalaries.viewTblRateRebasing  (dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, fiscalyearid, _reportEditView, active);


      };
    }
  }
}