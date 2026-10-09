using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * servicerecords.ashx */
  /*
   ***************************************************************************/

  public class ClaimDenialsResubmissionsViw : WebReportDocument 
  {    

        public ClaimDenialsResubmissionsViw()
    {

      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/
     
      this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;

      this.cbReportData = delegate()
      {
        return Spedmon.ClaimDenialResubmissions.viewTbl(dbConnApp,log,uInfo,_reportPaging,_reportPageNumber,clientid,"","");      
      };
    }
  }
}