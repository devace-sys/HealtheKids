using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * PatientParentMcalConsentsViw */
  /*
   ***************************************************************************/
   
  public class PatientParentMcalConsentsViw : WebReportDocument
  {
    
    public PatientParentMcalConsentsViw()
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
	    var parentconsent     = MBA.HttpApplication.getParameter("parentconsent");
        var hasunknownconsent = MBA.HttpApplication.getParameter("hasunknownconsent");
        var hasheldclaims     = MBA.HttpApplication.getParameter("hasheldclaims");
		
        return Spedmon.PatientParentMcalConsents.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView, active, clientid, patid,parentconsent,hasunknownconsent,hasheldclaims);
      };
    }
  }
}