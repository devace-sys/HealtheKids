using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * RmtsParticipantRostersViw */
  /*
   ***************************************************************************/
   
  public class RmtsParticipantRostersViw : WebReportDocument
  {
    
    public RmtsParticipantRostersViw()
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
        return Spedmon.RmtsParticipationRosters.viewTbl (dbConnApp, log, uInfo, _reportPaging, _reportPageNumber,clientid,_reportEditView, active);
      };
    }
  }
}