using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * servicerecordsapproval.ashx.cs */
  /*
   ***************************************************************************/

  public class ServiceRecordsApprovalRpt : WebReportDocument 
  {    
    public const int REPT_NUM_VIEW_SUMMARY                                   = 1;
    public const int REPT_NUM_VIEW_DETAIL                                    = 2;
    public const int REPT_NUM_VIEW_SUPERVISORS                               = 3;
    public const int REPT_NUM_VIEW_UNREVIEWED_OR_HELD_BY_PRAC                = 4;
    public const int REPT_NUM_VIEW_SVC_RECS_REVIEW_FOR_DIRECT_ASSIGNED_PRACS = 5;
    
    public ServiceRecordsApprovalRpt()
    {

      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_APPROVE_SVC_RECS;
      this.cbReportData = delegate(){
        
        /* For filters used in the supervision screen */

        string _assigned = "";
        string _reviewed = "0";
        string _approved = "";
        
        var assignedVal = MBA.HttpApplication.getParameter(Constants.PARM_ASSIGNED);
        if (!String.IsNullOrWhiteSpace(assignedVal)) _assigned = assignedVal;

        var reviewedVal = MBA.HttpApplication.getParameter(Constants.PARM_REVIEWED);

        if (!String.IsNullOrEmpty(reviewedVal)) {
            _reviewed = reviewedVal;
        
          var approvedVal = MBA.HttpApplication.getParameter(Constants.PARM_APPROVED);
          if (!String.IsNullOrEmpty(approvedVal)) {
                  _approved = approvedVal;
          }
        }

        if      (this._reportNumber == REPT_NUM_VIEW_SUMMARY)
          return Spedmon.ServiceRecordsApprovalSummary.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView, _active, clientid, approvingpracid, _assigned, _reviewed, _approved, siteid, dateRange);

        else if (this._reportNumber == REPT_NUM_VIEW_DETAIL)
          return Spedmon.ServiceRecordsApprovalDetails.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView, _active, clientid, approvingpracid, pracid, journalid);
        
        else if (this._reportNumber == REPT_NUM_VIEW_SUPERVISORS)
          return Spedmon.ServiceRecordsApprovalSupervisors.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView, _active, clientid, pracid);
        
        else if (this._reportNumber == REPT_NUM_VIEW_UNREVIEWED_OR_HELD_BY_PRAC)           
          return Spedmon.ServiceRecordsApproval.viewTblUnreviewedOrPracHeldServiceRecords (dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView, _active, clientid);
        
        else if (this._reportNumber == REPT_NUM_VIEW_SVC_RECS_REVIEW_FOR_DIRECT_ASSIGNED_PRACS)
          return Spedmon.ServiceRecordsApproval.viewTblServiceRecordsReviewForDirectAssignedPracs (
              dbConnApp
            , log
            , uInfo
            , _reportPaging
            , _reportPageNumber
            , _reportEditView
            , _active
            , clientid
            , approvingpracid
            , pracid
            , patid
            , dateRange );
        
        return Spedmon.ServiceRecordsApprovalSummary.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView, _active, clientid, approvingpracid, _assigned, _reviewed, _approved, siteid, dateRange);
        
      };
    }
  }
}