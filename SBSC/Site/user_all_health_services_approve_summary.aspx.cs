using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * UserAllHealthServicesApproveSummary */
  /**
   * Batch edit/delete
   *
   * Note: Just delete right now
   *
   ***************************************************************************/   

  public class UserAllHealthServicesApproveSummary: WebUI
  {
    public UserAllHealthServicesApproveSummary() : base(  "service_records_batch_approve_summary",
                                                   WebUI.CreatePageSubTitle(ServiceRecordsApproval.SEL_LABEL_PRAC_SUPERVISOR_REV_SVC,"Summary"),
                                                   "",
                                                   "",
                                                   Constants.ROLE_SVC_JOURNALS){}
        
    protected void Page_Load(object sender, EventArgs e)
    {
        var ctrlAssigned  = findControlRecu (this.Page, @"assigned")  as MBA.RadioBox;
        var ctrlDateRange = findControlRecu (this.Page, @"daterange") as DateBoxRange;

        /*###########################################################################
          # Set default value for assigned 
          # Note: For radio boxes we have to do this before adding selections
          ###########################################################################*/

        if (rd.wu.usr.roleID == Constants.ROLE_LEA_PROVIDER_ID)
        {
          /* If this is a practitoner with assigned pracs then default to assigned to prac*/
          if (rd.wu.pr.pracsAssignedToSuperviseDirectlyCount > 0)
          {
            ctrlAssigned.value = @"Y";
          } 
          else
          {
            ctrlAssigned.value = @"";
          }
        }
        else
        {
            ctrlAssigned.value = @"";
        }
        
        /*###########################################################################
          # Set initial value for date range
          ###########################################################################*/

        var dateRangeStr = Util.GenerateDateRange(9);
        ctrlDateRange.value = dateRangeStr;

        ctrlAssigned.AddSelection(@"Practitioners Assigned To Me",     "Y");
        //ctrlAssigned.AddSelection(@"Practitioners Not Assigned To Me", "N");
        ctrlAssigned.AddSelection(@"All Practitioners",    "");

        }

    }
}
