using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * announcements.ashx */
  /*
   ***************************************************************************/
   
  public class ManPagesViw : WebReportDocument
  {
    public const int REPT_NUM_VIEW      = 1;
    public const int REPT_NUM_REVIEW    = 2;
    
    public ManPagesViw()
    {
      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_ANNOUNCEMENT_ADMIN;
      this.cbReportData = delegate()
      {
         if (this._reportNumber == REPT_NUM_REVIEW) 
         {
         
           return Spedmon.ManPages.rptReviewUserResponses (
               dbConnUser
             , log
             , uInfo
             , _reportPaging
             , _reportPageNumber
             , _reportEditView
             , active
             , clientid
             , pageID
             , userHasBeenEmailedNoticeOfContent
             , userHasSeenContent
             , userWillReadContentLater
             , userHasReadContent
            );
         }
         
         else return Spedmon.ManPages.viewTbl ( dbConnUser, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView, active );
      };
    }
  }
}