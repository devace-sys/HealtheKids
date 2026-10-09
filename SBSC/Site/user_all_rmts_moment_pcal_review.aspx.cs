using MBA;
using System;


namespace Spedmon
{
    public class UserAllRmtsMomentPcalReview : WebUI
    {

        public string startDateChangeReasonsNvpString = "";
        public string endDateChangeReasonsNvpString = "";
        public bool   showClientName = false;

        public UserAllRmtsMomentPcalReview() : base("rmts_moments_review"
                                                         , RmtsMoments.SEL_LABEL_REVIEW
                                                         , ""
                                                         , ""
                                                         , Constants.ROLE_RMTS_ADMINS )
        { }
 
        public string dataListIDForChangeReasonsCode2A   = @"";
        public string dataListIDForChangeReasonsCode2Z   = @"";
        public string dataListIDForChangeReasonsCode8    = @"";

        public string dataListHtmlForChangeReasonsCode2A = @"";
        public string dataListHtmlForChangeReasonsCode2Z = @"";
        public string dataListHtmlForChangeReasonsCode8  = @"";

        protected void Page_Load(object sender, EventArgs e)
        {
            var ctrlActivityCodeSelection = findControlRecu(this.Page, "activitycodeselection") as MBA.RadioBox;

            var ctrlClientID   = findControlRecu (this.Page, "selectClient") as MBA.DataEntryRowSelectClient;
            var clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
        
            /* preselect clientid if passed */

            if (!String.IsNullOrEmpty(clientIDStr))
            {
              var _clt = Clients.load(dbConnApp,log,uInfo,clientIDStr);
              ctrlClientID.selectName  = _clt.name;
              ctrlClientID.selectValue = clientIDStr;

              //ctrlClientID.Visible = false;
            }

            ctrlActivityCodeSelection.AddSelection(@"All Codes", "", true);
            ctrlActivityCodeSelection.AddSelection(@"2A", "2A");
            ctrlActivityCodeSelection.AddSelection(@"2Z", "2Z");
            ctrlActivityCodeSelection.AddSelection(@"8",  "8");

            ctrlActivityCodeSelection.value = ""; /* Shows all codes */

            dataListIDForChangeReasonsCode2A = @"changereasonsforcode2a";
            dataListIDForChangeReasonsCode2Z = @"changereasonsforcode2z";
            dataListIDForChangeReasonsCode8  = @"changereasonsforcode8";

            dataListHtmlForChangeReasonsCode2A = RMTSActivityCodeChangeReasons.generateDataListHTMLForActivityCode(dbConnApp, log, uInfo, dataListIDForChangeReasonsCode2A, @"2A");
            dataListHtmlForChangeReasonsCode2Z = RMTSActivityCodeChangeReasons.generateDataListHTMLForActivityCode(dbConnApp, log, uInfo, dataListIDForChangeReasonsCode2Z, @"2Z");
            dataListHtmlForChangeReasonsCode8  = RMTSActivityCodeChangeReasons.generateDataListHTMLForActivityCode(dbConnApp, log, uInfo, dataListIDForChangeReasonsCode8, @"8");

            // initial value for date range

            //string dateRangeStr = Util.GenerateDateRange(Constants.SVC_REC_EDIT_DATE_RANGE_CONST);
            //ctrlDateRange.value = dateRangeStr;

            var ctrlReviewStatusCodeSelection = findControlRecu(this.Page, "reviewstatuscodeselection") as MBA.RadioBox;

            //var ctrlDateRange             = findControlRecu(this.Page, "daterange")             as DateBoxRange;

            bool possible_appeal;
            possible_appeal = (MBA.HttpApplication.getParameter("possible_appeal") == "1");

            //ctrlReviewStatusCodeSelection.AddSelection(@"All Codes", "");
            ctrlReviewStatusCodeSelection.AddSelection(@"Not Reviewed"   , "100", !possible_appeal );
            ctrlReviewStatusCodeSelection.AddSelection("Reviewed"        , "200");
            ctrlReviewStatusCodeSelection.AddSelection("Possible Appeal" , "300", possible_appeal);

            ctrlReviewStatusCodeSelection.value = possible_appeal ? "300" : "100";

            var ctrlFiscalQtrSelection = findControlRecu(this.Page, "fiscalquarterselection") as MBA.RadioBox;

            ctrlFiscalQtrSelection.AddSelection(@"Q1", "1", false);
            ctrlFiscalQtrSelection.AddSelection(@"Q2", "2", false);
            ctrlFiscalQtrSelection.AddSelection(@"Q3", "3", false);
            ctrlFiscalQtrSelection.AddSelection(@"Q4", "4", false);


            showClientName = uInfo.pcalStaff;


        }

    }
}
