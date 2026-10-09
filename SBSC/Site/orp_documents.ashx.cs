using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * ORPDocumentsViw */
  /*
   ***************************************************************************/
   
  public class ORPDocumentsViw : WebReportDocument
  {
    public const int REPT_NUM_VIEW                      = 1;
    public const int REPT_NUM_VIEW_ORDERS_AND_PROFILES  = 2;

    public ORPDocumentsViw()
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
          var orpApprovalState = MBA.HttpApplication.getParameter(Constants.PARM_ORP_APPROVAL_STATE);

          if (this._reportNumber == REPT_NUM_VIEW_ORDERS_AND_PROFILES)
          {
              return Spedmon.ORPDocuments.viewTblOrdersAndProfiles(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, patid, groupServiceClassNameID, dateRange, orpApprovalState, _reportEditView, active);
          }
          else
          {
              return Spedmon.ORPDocuments.viewTbl(dbConnApp
                                      , log
                                      , uInfo
                                      , _reportPaging
                                      , _reportPageNumber
                                      , clientid
                                      , patid
                                      , dos
                                      , _reportEditView
                                      , active);
          }
      
        };
    }
  }
}