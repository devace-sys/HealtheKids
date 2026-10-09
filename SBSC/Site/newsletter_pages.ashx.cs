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
   
  public class NewsletterPagesHandler : WebReportDocument
  {
    public const int REPT_NUM_VIEW      = 1;
    public const int REPT_NUM_REVIEW_RECIPIENTS    = 2;
    
    public NewsletterPagesHandler()
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

          if ( this._reportNumber == REPT_NUM_REVIEW_RECIPIENTS)

            return Spedmon.NewsletterPages.viewTblRecipListReportAll(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView, this.recID, "1" /* active */ );           

          else
            
            return Spedmon.NewsletterPages.viewTbl( dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView, "1" /* active */ );

      };
    }
  }
}