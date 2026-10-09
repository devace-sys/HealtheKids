using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * PractitionerPatientCaseloadExpectedServicesViw */
  /*
   ***************************************************************************/

  public class PractitionerPatientCaseloadExpectedServicesViw : WebReportDocument
  {    
    
    public PractitionerPatientCaseloadExpectedServicesViw()
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

          return Spedmon.PractitionerPatientCaseloadExpectedServices.viewTbl( dbConnApp
                                               , log
                                               , uInfo
                                               , _reportPaging
                                               , _reportPageNumber
                                               , _reportEditView
                                               , _active
                                               , this.clientid
                                               , this.pracid
                                               , this.patid
                                               , this.useMinsPerFreqAssigned
                                               , "N" );

      };
    }
  }
}