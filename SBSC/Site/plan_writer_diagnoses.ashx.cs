using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * RmtsParticipantRostersViw */
  /*
   ***************************************************************************/
   
  public class PlanWriterDiagnosesViw : WebReportDocument
  {
    
    public PlanWriterDiagnosesViw()
    {
      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/
      
      this._permittedRoles = Constants.ROLE_SBS_ALL;
      this.cbReportData = delegate()
      {
        string templatetype = String.IsNullOrEmpty(clientid) ? 1.ToString() : 2.ToString();
        
        return Spedmon.PlanWriterDiagnoses.viewTbl (dbConnApp, log, uInfo, _reportPaging, _reportPageNumber,clientid, templatetype, _reportEditView, active);
      };
    }
  }
}