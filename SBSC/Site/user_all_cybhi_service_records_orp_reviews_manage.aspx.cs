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
     * UserAllCybhiServiceRecordsOrpReviewsManage */
    /**
     *
     ***************************************************************************/

    public class UserAllCybhiServiceRecordsOrpReviewsManage : WebUI
    {

        public UserAllCybhiServiceRecordsOrpReviewsManage() : base("user_all_cybhi_service_records_orp_reviews_manage"
                                                                     , CybhiServiceRecordsOrpReviews.SEL_LABEL_MANAGE
                                                                     , @""
                                                                     , @""
                                                                     , Constants.ROLE_CYBHI_ORP_REVIEW_SVC_RECS)
        { }


        public bool inDetailsEntryMode = false;
        public int detailsEntryModeVal = 0;
        public string detailsEntryModeLabel = "";
        public bool showRenderingPracCol = true;
        public bool showPatCol = true;

        protected void Page_Load(object sender, EventArgs e)
        {

            /*###########################################################################
              # Get passed in values
              ###########################################################################*/

            var clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
            var reviewingPracIDStr = MBA.HttpApplication.getParameter(Constants.PARM_REVIEWING_PRAC_ID);
            var siteIDStr = MBA.HttpApplication.getParameter(Constants.PARM_SITE_ID);
            var dateRangeStr = MBA.HttpApplication.getParameter(Constants.PARM_DATE_RANGE);
            var renderingPracIDStr = MBA.HttpApplication.getParameter(Constants.PARM_RENDERING_PRAC_ID);
            var patIDStr = MBA.HttpApplication.getParameter(Constants.PARM_PATIENT_ID);
            var demStr = MBA.HttpApplication.getParameter(Constants.PARM_PRAC_SUP_DETAILS_ENTRY_MODE);
            var approvalStatusStr = MBA.HttpApplication.getParameter(Constants.PARM_APPROVAL_STATUS);

            /*###########################################################################
              # Get control references
              ###########################################################################*/

            var ctrlSelectClient = findControlRecu(this.Page, @"selectClient") as MBA.DataEntryRowSelectClient;
            var ctrlSelectReviewingPrac = findControlRecu(this.Page, @"selectReviewingPrac") as MBA.DataEntryRowSelectPractitioner;
            var ctrlApprovalStatus = findControlRecu(this.Page, Constants.PARM_APPROVAL_STATUS) as MBA.RadioBox;
            var ctrlRenderingPrac = findControlRecu(this.Page, Constants.PARM_RENDERING_PRAC_ID) as MBA.HiddenInput;
            var ctrlPatID = findControlRecu(this.Page, Constants.PARM_PATIENT_ID) as MBA.HiddenInput;
            var ctrlSelectSite = findControlRecu(this.Page, @"selectSite") as MBA.DataEntryRowSelectSchoolSite;
            var ctrlDateRange = findControlRecu(this.Page, Constants.PARM_DATE_RANGE) as MBA.DateBoxRange;

            /*###########################################################################
              # Populate client and reviewing prac values if passed in and user is not
              # a practitioner.  Also hide controls.
              ###########################################################################*/

            if (uInfo.userRoleID != Constants.ROLE_LEA_PROVIDER_ID)
            {
                if (!String.IsNullOrWhiteSpace(clientIDStr))
                {    
                    ctrlSelectClient.selectValue = clientIDStr;                
                    ctrlSelectClient.entryInitiallyHidden = true;
                }
                if (!String.IsNullOrWhiteSpace(reviewingPracIDStr))
                {     
                    ctrlSelectReviewingPrac.selectValue = reviewingPracIDStr;
                    ctrlSelectReviewingPrac.entryInitiallyHidden = true;
                }               
            }

            /*###########################################################################
              # Populate site if passed in and make sure save selection as default is off
              # otherwise turn on option for saving as default.
              ###########################################################################*/

            if (!String.IsNullOrWhiteSpace(siteIDStr))
            {
                var site = Sites.load(dbConnApp, log, uInfo, siteIDStr);
                ctrlSelectSite.selectValue = site.id.ToString();
                ctrlSelectSite.selectName = site.name;
                ctrlSelectSite.showSaveSelectionAsDefault = false;
            }
            else
            {
                ctrlSelectSite.showSaveSelectionAsDefault = true;
            }

            /*###########################################################################
              # Populate date range if passed in otherwise use the default range
              ###########################################################################*/

            if (!String.IsNullOrEmpty(dateRangeStr))
            {
                ctrlDateRange.value = dateRangeStr;
            }
            else
            {
                ctrlDateRange.value = Util.GenerateDateRange(9);
            }

            /*###########################################################################
              # Populate rendering prac and patient hidden inputs if values are passed.
              ###########################################################################*/

            if (!String.IsNullOrWhiteSpace(renderingPracIDStr)) ctrlRenderingPrac.value = renderingPracIDStr;
            if (!String.IsNullOrWhiteSpace(patIDStr)) ctrlPatID.value = patIDStr;

            /*###########################################################################
              # Determine if we are in details entry (filter) mode and what
              ###########################################################################*/

            if (!String.IsNullOrWhiteSpace(demStr))
            {
                detailsEntryModeVal = MBA.Validate.reqInteger(demStr, @"Invalid details mode");
                inDetailsEntryMode = true;

                if (detailsEntryModeVal == Spedmon.Constants.PRAC_SUP_DETAILS_ENTRY_MODE_PRAC)
                {
                    var prac = Spedmon.Practitioners.load(dbConnApp, log, uInfo, renderingPracIDStr);
                    detailsEntryModeLabel = "Services rendered by " + prac.name + " - " + prac.groupName;
                    showRenderingPracCol = false;
                }
                else if (detailsEntryModeVal == Spedmon.Constants.PRAC_SUP_DETAILS_ENTRY_MODE_PAT)
                {
                    var pat = Spedmon.Patients.load(dbConnApp, log, uInfo, patIDStr);
                    detailsEntryModeLabel = "Services provided to " + pat.name + " - " + pat.CSIS;
                    showPatCol = false;
                }
                else
                {
                    detailsEntryModeLabel = "";
                }
            }
            else
            {
                inDetailsEntryMode = false;
            }

            /*###########################################################################
              # Set default value for status then set possible status selections
              # Note: For radio boxes we have to do this before adding selections
              ###########################################################################*/

            if (!String.IsNullOrWhiteSpace(approvalStatusStr))
            {
                MBA.Validate.reqInteger(approvalStatusStr, @"Invalid approval status");
                ctrlApprovalStatus.value = approvalStatusStr;
            }
            else
            {
                ctrlApprovalStatus.value = @"1";
            }

            ctrlApprovalStatus.AddSelection(@"Not Reviewed",            "1");
            ctrlApprovalStatus.AddSelection(@"Approved",                "2");
            ctrlApprovalStatus.AddSelection(@"Returned For Correction", "3");

        }
    }
}
