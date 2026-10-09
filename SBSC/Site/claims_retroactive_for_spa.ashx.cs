using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * ClaimsRetroactiveForSpaViw */
  /*
   ***************************************************************************/

  public class ClaimsRetroactiveForSpaViw : WebReportDocument
  {    
    
    public const int REPT_NUM_VIEW  = 1;

    public ClaimsRetroactiveForSpaViw()
    {

            /*-------------------------------
             * Define permitted roles 
             * Refine access
             * Call framework method based
             * on report number
             *------------------------------*/


      this._permittedRoles = Spedmon.Constants.ROLE_ADMIN_CONSULANT_ONLY;
      this.cbReportData = delegate()
      {
        var _forspaid = MBA.HttpApplication.getParameter(ClaimsRetroactiveForSpa.PARM_FOR_SPA);
        var _fyid     = MBA.HttpApplication.getParameter(ClaimsRetroactiveForSpa.PARM_FOR_FY);
        var _authynu  = MBA.HttpApplication.getParameter(ClaimsRetroactiveForSpa.PARM_FOR_AUTH_YNU);
        
        if (this._reportNumber == REPT_NUM_VIEW)
        {
          // Pass through to default
        }
        
        // TODO: Add more reports if needed 

        return Spedmon.ClaimsRetroactiveForSpa.viewTblPossibleSelections(dbConnApp,log,uInfo,_reportPaging,_reportPageNumber,_reportEditView,_active,_forspaid,clientid,_fyid,_authynu);

      };
    }
  }
}