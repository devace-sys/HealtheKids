using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * TeleCommSessionTeleIEPViw */
  /*
   ***************************************************************************/
   
  public class TeleCommSessionTeleIEPViw : WebReportDocument
  {
    public const int REPT_NUM_VIEW      = 1;
    
    public TeleCommSessionTeleIEPViw()
    {
      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_ADMIN_CONSULTANT_LEA_BO_PRAC;
      this.cbReportData = delegate()
      {
         if (this._reportNumber == REPT_NUM_VIEW) 
         {
           return Spedmon.TeleIEPSessions.viewTbl(dbConnApp,log,uInfo,clientid,patid,_reportPaging,_reportPageNumber,_reportEditView,active);
         }
         
         else return Spedmon.TeleIEPSessions.viewTbl(dbConnApp,log,uInfo,clientid,patid,_reportPaging,_reportPageNumber,_reportEditView,active);
      };
    }
  }
}