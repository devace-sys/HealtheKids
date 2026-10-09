using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * TeleCommSessionTeleHealthViw */
  /*
   ***************************************************************************/
   
  public class TeleCommSessionTeleHealthViw : WebReportDocument
  {
    public const int REPT_NUM_VIEW      = 1;
    
    public TeleCommSessionTeleHealthViw()
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
           return Spedmon.TeleHealthSessions.viewTbl(dbConnApp,log,uInfo,clientid,pracid,_reportPaging,_reportPageNumber,_reportEditView,active);
         }
         
         else return Spedmon.TeleHealthSessions.viewTbl(dbConnApp,log,uInfo,clientid,pracid,_reportPaging,_reportPageNumber,_reportEditView,active);
      };
    }
  }
}