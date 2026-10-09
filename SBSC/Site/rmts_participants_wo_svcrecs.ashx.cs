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
   
  public class RmtsParticipantsWoSvcrecsViw : WebReportDocument
  {
    
    public RmtsParticipantsWoSvcrecsViw()
    {
      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;

      this.cbReportData = delegate()
      {
        //return Spedmon.RmtsParticipationRosters.viewTbl (dbConnApp, log, uInfo, _reportPaging, _reportPageNumber,clientid,_reportEditView, active);

        return Spedmon.RmtsParticipantsWoSvcRecs.viewTbl(
          dbConnApp, log, uInfo, _reportPaging,
          _reportPageNumber,clientid,
          MBA.HttpApplication.getParameter("deferralstatus")
        );


      };


    }
  }
}