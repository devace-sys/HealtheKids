using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * RMTSActivityCodeChangeReasonsViw */
  /*
   ***************************************************************************/

  public class RMTSActivityCodeChangeReasonsViw : WebReportDocument
  {    
    public const int REPT_NUM_VIEW = 1;
	
    public RMTSActivityCodeChangeReasonsViw()
    {


       /*-------------------------------
        * Define permitted roles 
        * Refine access
        * Call framework method based
        * on report number
        *------------------------------*/


      this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;
      this.cbReportData = delegate()
      {

          return Spedmon.RMTSActivityCodeChangeReasons.viewTbl( dbConnApp
                                               , log
                                               , uInfo
                                               , _reportPaging
                                               , _reportPageNumber
                                               , _reportEditView
                                               , _active
                                               , this.rmtsActivityCode );

      };
    }
  }
}