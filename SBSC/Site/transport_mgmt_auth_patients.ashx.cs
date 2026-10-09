using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * TranportMgmtAuthPatientsViw */
  /*
   ***************************************************************************/

  public class TranportMgmtAuthPatientsViw : WebReportDocument
  {    
    
    public const int REPT_NUM_VIEW = 1;
    public TranportMgmtAuthPatientsViw()
    {

       /*-------------------------------
        * Define permitted roles 
        * Refine access
        * Call framework method based
        * on report number
        *------------------------------*/


      this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
      this.cbReportData = delegate()
      {
        
        if (this._reportNumber == REPT_NUM_VIEW)
        {
          // Pass through to default
        }
        // TODO: Add more reports if needed 

        return Spedmon.TransportationMgmtAuthorizedPatients.viewTbl (
            dbConnApp
            , log
            , uInfo
            , _reportPaging
            , _reportPageNumber
            , _reportEditView
            , "Y" /*_active*/
            , clientid
            , transmgmtid            
          );

      };
    }
  }
}