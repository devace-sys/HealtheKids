// ASHX urls in lowercase_underscore format are still passing code review, as of late.

using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * TimekeeperAccountabilityRptSvc */
  /*
   ***************************************************************************/
   
  public class TimekeeperAccountabilityRptSvc : WebReportDocument
  {

    //public const int REPT_NUM_VIEW      = 1;  //TODO: change this if we need more ASHX reports later
    
    public TimekeeperAccountabilityRptSvc()
    {
      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL; // THIS IS THE ROLE used for PayrollReport1.aspx;
                                                             // following that pattern
      this.cbReportData = delegate()
      {
         //if (this._reportNumber == REPT_NUM_VIEW) 
         //{
           return Spedmon.TimekeeperAccountabilityRpt.viewTblRptServiceRecsPerMinute(
                    dbConnApp,log,uInfo,_reportPaging,_reportPageNumber,

                    dateRange
                                                      

                    ,_reportEditView,active);
         //}
         
      };
    }
  }
}