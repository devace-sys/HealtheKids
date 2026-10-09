using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{


  public class ClientComplianceClientItemsViw : WebReportDocument
  {    
    
    public ClientComplianceClientItemsViw()
    {


      this._permittedRoles = Spedmon.Constants.ROLE_ALL;
      this.cbReportData = delegate()
      {

          return  Spedmon.ClientComplianceClientItems.viewTbl(
                this.dbConnApp,
                log,
                uInfo,

              _reportPaging , 
              _reportPageNumber, 

              // , _reportEditView
              // , _active

              this.clientid
            , MBA.HttpApplication.getParameter(Constants.PARM_TASK_ID)

            , MBA.HttpApplication.getParameter(Constants.PARM_IS_PENDING)
            , MBA.HttpApplication.getParameter(Constants.PARM_IS_NOT_COMPLETED)
            , MBA.HttpApplication.getParameter(Constants.PARM_IS_COMPLETED)

            , MBA.HttpApplication.getParameter( Constants.PARM_FISCAL_YEAR_ID )


            );


      };
    }
  }
}