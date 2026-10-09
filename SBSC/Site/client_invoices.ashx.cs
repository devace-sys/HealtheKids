using System;
using System.Collections.Generic;
using System.Web;
using MBA;



namespace Spedmon
{

  /***************************************************************************
   * ClientInvoicesViw */
  /*
   ***************************************************************************/

  public class ClientInvoicesViw : WebReportDocument
  {    
    
    public ClientInvoicesViw()
    {

       /*-------------------------------
        * Define permitted roles 
        * Refine access
        * Call framework method based
        * on report number
        *------------------------------*/


      this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL_LEA_COORD;
      this.cbReportData = delegate()
      {
          this.startDate = @"";
          this.endDate = @"";

          if (!String.IsNullOrWhiteSpace(this.dateRange))
          {
              var sDate = @"";
              var eDate = @"";
              Util.parseDateRange(this.dateRange, out sDate, out eDate);
              this.startDate = sDate;
              this.endDate = eDate;
          }

          var invoicePaid = MBA.HttpApplication.getParameter(Constants.PARM_INVOICE_PAID);

          //var distributionPaid = MBA.HttpApplication.getParameter(Constants.PARM_DISTRIBUTION_PAID);
          //var manageInoiceIndex = MBA.HttpApplication.getParameter(Constants.PARM_MANAGE_INVOICE_INDEX);
             // NOTE: no idea what PARM_MANAGE_INVOICE_INDEX was intended for


          return Spedmon.ClientInvoices.viewTbl( dbConnApp
                                               , log
                                               , uInfo
                                               , _reportPaging
                                               , _reportPageNumber
                                               , _reportEditView
                                               , _active
                                               , this.clientid
                                               , this.startDate   // NOTE: existing param names are not in lowercase
                                               , this.endDate
                                               , invoicePaid

                                               ,  MBA.HttpApplication.getParameter("showclientname")
                                               ,  MBA.HttpApplication.getParameter("showconsultantname")

                                               ,  MBA.HttpApplication.getParameter("showbasicinvoicedata")
                                               ,  MBA.HttpApplication.getParameter("showdistbreakdownsdollaramounts")

                                               ,  MBA.HttpApplication.getParameter("calcshares")

                                               ,  MBA.HttpApplication.getParameter(Constants.PARM_DISTRIBUTION_PAID)

                                               // ,  MBA.HttpApplication.getParameter("distbpaiddaterange")

                                               ,  MBA.HttpApplication.getParameter("invcolldaterange")

                                               , MBA.HttpApplication.getParameter("inclpartner1col")
                                               , MBA.HttpApplication.getParameter("inclretentioncol")
                                               , MBA.HttpApplication.getParameter("inclcybhirows")
                                               , MBA.HttpApplication.getParameter("inclcybhirowsonly")

                                               , MBA.HttpApplication.getParameter("iscybhidistscreen")
                                               );

      };
    }
  }
}