using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * workflow.ashx */
  /*
   ***************************************************************************/

  public class WorkflowRpt : WebReportDocument
  {    
    
    public const int REPT_NUM_VIEW_RECENT_ANI_FILES = 1;

    public WorkflowRpt()
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
        if (this._reportNumber == REPT_NUM_VIEW_RECENT_ANI_FILES)
        {
          /* Only sbsc users can see recent A&I files */
          this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;
          return Workflow.viewRecentANIFiles(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber);           
        }
        else
        {
          return null;
        }
      };
    }
  }
}