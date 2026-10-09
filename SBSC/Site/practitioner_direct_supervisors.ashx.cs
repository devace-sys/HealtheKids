using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * PractitionerDirectSupervisorsViw */
  /*
   ***************************************************************************/
   
  public class PractitionerDirectSupervisorsViw : WebReportDocument
  {
    public const int REPT_NUM_VIEW =  1;

    public PractitionerDirectSupervisorsViw()
    {

      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_PRAC_DIR_SUP_ADMINS;
      this.cbReportData = delegate()
      {
        return Spedmon.PractitionerDirectSupervisedSupervisors.viewTbl (dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, this.groupServiceClassNameID, this.rptgroupid, _reportEditView, active);
      };
    }
  }
}