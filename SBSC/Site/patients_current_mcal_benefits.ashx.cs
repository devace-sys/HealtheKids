using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * PatientsCurrentMcalBenefitsViw */
  /*
   ***************************************************************************/
   
  public class PatientsCurrentMcalBenefitsViw : WebReportDocument
  {
    public const int REPT_NUM_VIEW = 1;
    public PatientsCurrentMcalBenefitsViw()
    {
      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL_LEA_COORD;
      this.cbReportData = delegate()
      {
	    var currentBenefitStatusCode = MBA.HttpApplication.getParameter(Constants.PARM_CURRENT_BENEFIT_STATUS_CODE);
		
        return Spedmon.PatientsCurrentMcalBenefits.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView, active, clientid, currentBenefitStatusCode, patid, hasAltFormat);
      };
    }
  }
}