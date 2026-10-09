using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{

  public class ServicesByPracRptSvc : WebReportDocument
  {
  
    public const int REPT_SERVICES_BY_PRAC = 1; 
           
    public ServicesByPracRptSvc()
    {
      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/
       
       this._permittedRoles = Spedmon.Constants.ROLE_PRAC_DIR_SUP_ADMINS;
       this.cbReportData = delegate()
       {         
         
         return ServicesByPracRpt.viewRpt( dbConnApp
                                         , log
                                         , uInfo
                                         , _reportPaging
                                         , _reportPageNumber
                                         , _reportEditView
                                         , reportNumber 
                                         , clientid 
                                         , rptgroupid
                                         , pracid 
                                         , endDate);

       };
    }
  }
}