using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * patient_persons.ashx.cs */
  /*
   ***************************************************************************/
   
  public class PatientPersonsViw : WebReportDocument
  {
    
    public PatientPersonsViw()
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
        return Spedmon.PatientPersons.viewTbl (
              dbConnApp
            , log
            , uInfo
            , _reportPaging
            , _reportPageNumber
            , _reportEditView
            , active
            , clientid
            , patid
            , personClassID1
            , personClassID2
            , term
            );
      };
    }
  }
}