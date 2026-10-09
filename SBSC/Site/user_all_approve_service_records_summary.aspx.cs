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
   * UserAllApproveServiceRecordsSummary */
  /**
   * Batch edit/delete
   *
   * Note: Just delete right now
   *
   ***************************************************************************/   

  public class UserAllApproveServiceRecordsSummary: WebUI
  {
    public UserAllApproveServiceRecordsSummary() : base("approve_service_records_summary",
                                                   WebUI.CreatePageSubTitle(ServiceRecordsApproval.SEL_LABEL_PRAC_SUPERVISOR_REV_SVC,"Summary"),
                                                   "",
                                                   "",
                                                   Constants.ROLE_APPROVE_SVC_RECS){}
        
    public bool showSvcRecReviewShowNotificationsUserPrefSetting = false;
    public bool includeAllPractitionersSelection                 = true;
    public bool okToShowAddRemoveSupervisionRelationship         = true;

    protected void Page_Load(object sender, EventArgs e)
    {
        
        var ctrlshowSvcRecRevNot = findControlRecu (this.Page, @"showSvcRecRevNot") as MBA.SelectYesOrNo;
        var ctrlAssigned         = findControlRecu (this.Page, @"assigned")         as MBA.RadioBox;
        var ctrlApprovalStatus   = findControlRecu (this.Page, @"approvalstatus")   as MBA.RadioBox;
        var ctrlDateRange        = findControlRecu (this.Page, @"daterange")        as DateBoxRange;
        
         /*###########################################################################
           # Set default value for assigned and determine if we should show/hide
           # the show service records review notfications preference ctrls and get
           # the current preference value.
           #
           # Note: For radio boxes we have to do this before adding selections
           ###########################################################################*/

        /*--------------------------------
         * If user is a practitioner
         *-------------------------------*/

        if (rd.wu.usr.roleID == Constants.ROLE_LEA_PROVIDER_ID)
        {
          
          /* If this is not a supervising practitioner get out! */

          if (ServiceRecordsApproval.isSupervisorPrac(ref rd) == false) {
            throw new Warning(Messages.ACCESS_DENIED);
            return;
          }
         
         /* Determine if the supervising prac can have the add/remove supervision relationship controls */
         
         okToShowAddRemoveSupervisionRelationship = PractitionerDirectSupervisors.isPracSomeoneWhoCanManageDirectSupervisionTracking(ref rd);

         /* If supervising prac is allowed to opt out of review notifications */
          
         if (ServiceRecordsApproval.isSupervisorPracAllowedToOptOutOfServicesToReviewNotifications(ref rd))
         {
           /* Then its ok to show the ctrl */
           showSvcRecReviewShowNotificationsUserPrefSetting = true;                        

           /* Get preference value and set the ctrls value */
           bool _svcRecReviewShowNotificationUserPrefValue  = PractitionerDirectSupervisedSupervisors.okToShowServiceRecordReviewNotificationsGetUserPref(ref rd);                   
           ctrlshowSvcRecRevNot.setValue(_svcRecReviewShowNotificationUserPrefValue);
         }
         
         /* Determine if this supervising prac can see the all practioners selection */

         includeAllPractitionersSelection = ServiceRecordsApproval.isSupervisorPracAllowedToReviewUnassignedPracsServices (ref rd);
         
         /* If this is a supervising practitoner with assigned pracs or this is a supervising prac 
          * that is not allowed to have the allPracs selection then default to assigned to prac */
          
         if ((rd.wu.pr.pracsAssignedToSuperviseDirectlyCount > 0) || (!includeAllPractitionersSelection))
         {
            ctrlAssigned.value = @"Y";
         } 

         /* Otherwise no default */
          
         else
         {
            ctrlAssigned.value = @"";
         } 
        }

        /*--------------------------------
         * If user is other authorized user
         *-------------------------------*/
        else
        {
            ctrlAssigned.value = @"";
        }

        /*###########################################################################
          # Set initial value for date range
          ###########################################################################*/

        var dateRangeStr = Util.GenerateDateRange(9);
        ctrlDateRange.value = dateRangeStr;

        /*###########################################################################
          # Set possible values for assigned          
          ###########################################################################*/

        ctrlAssigned.AddSelection(@"Practitioners Assigned To Me", "Y");        
        if (includeAllPractitionersSelection) { ctrlAssigned.AddSelection(@"All Practitioners", ""); }

        /*###########################################################################
          # Set default value for status 
          # Note: For radio boxes we have to do this before adding selections
          ###########################################################################*/

        ctrlApprovalStatus.value = @"1";
          

        ctrlApprovalStatus.AddSelection(@"Not Reviewed",                    "1");
        ctrlApprovalStatus.AddSelection(@"Approved by Me",                  "2");
        ctrlApprovalStatus.AddSelection(@"Returned For Corrections by Me",  "3");

        }

    }
}
