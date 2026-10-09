using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * RmtsParticipantRosterQuarterViw */
  /*
   ***************************************************************************/
   
  public class RmtsParticipantRosterQuarterViw : WebReportDocument
  {

    public string recordid = MBA.HttpApplication.getParameter("recordid");

    public RmtsParticipantRosterQuarterViw()
    {
      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/


      this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
      
      this.cbReportData = delegate() { return 
      
        Spedmon.RmtsParticipationRosters.viewTblQuarterData (  dbConnApp
                                      , log
                                      , uInfo
                                      , _reportPaging
                                      , _reportPageNumber
                                      , clientid
                                      , recordid
                                      , _reportEditView
                                      , active );
      };
    }
  }
}