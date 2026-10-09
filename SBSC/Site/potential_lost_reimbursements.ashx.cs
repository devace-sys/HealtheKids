using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  public class PotentialLostReimbursementsViw : WebReportDocument
  {
    public const int REPT_NUM_VIEW                                     =  1;

    public PotentialLostReimbursementsViw()
    {
      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/


      this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL_LEA_COORD;
      
      this.cbReportData = delegate() { return 
      
        Spedmon.PotentialLostReimbursements.viewTbl (  dbConnApp
                                      , log
                                      , uInfo
                                      , _reportPaging
                                      , _reportPageNumber
                                      , _reportEditView
                                      , active
                                      , clientid
                                      , pracid
                                      , null
                                      , MBA.HttpApplication.getParameter(Constants.PARM_GRP_SVC_CLS_NME_ID)
                                      , patid
                                      , MBA.HttpApplication.getParameter(MBA.Constants.PARM_PLR_CLASS_CODE)
                                      , MBA.HttpApplication.getParameter(MBA.Constants.PARM_DEFERRED)
        );
      };
    }
  }
}