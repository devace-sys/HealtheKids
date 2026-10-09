using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * PractitionerPatientScheduledServicesViw */
  /*
   ***************************************************************************/

  public class PractitionerPatientScheduledServicesViw : WebReportDocument
  {    
    
    public PractitionerPatientScheduledServicesViw()
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

          return Spedmon.PractitionerPatientScheduledServices.viewTbl( dbConnApp
                                               , log
                                               , uInfo
                                               , _reportPaging
                                               , _reportPageNumber
                                               , _reportEditView
                                               , _active
                                               , this.clientid
                                               , this.pracid
                                               , this.patid
                                               , this.practitionerPatientCaseloadExpectedServiceID );

      };
    }
  }
}