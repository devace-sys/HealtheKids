using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using MBA;
using System.Data.SqlClient;


namespace Spedmon
{
  /***************************************************************************
   * sites.ashx */
  /*
   ***************************************************************************/
   
  public class SitesViw : WebReportDocument
  {
    
    public const int REPT_NUM_VIEW           = 1;
    public const int RPT_CYBHI_SITES_AUDIT   = 210;

    public SitesViw()
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
          if (this._reportNumber == RPT_CYBHI_SITES_AUDIT) {

            return Spedmon.Sites.rptCybhiSitesAudit (dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid);

          }
          else {
              
            return Spedmon.Sites.viewTbl( dbConnApp
                                         , log
                                         , uInfo
                                         , _reportPaging
                                         , _reportPageNumber
                                         , clientid
                                         , name
                                         , _reportEditView
                                         , active );
          }
          
      };
    }
  }
}