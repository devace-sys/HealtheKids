using MBA;
using System;


namespace Spedmon
{


    public class UserAllRmtsMomentServiceRecordsManage : WebUI
    {

        public string startDateChangeReasonsNvpString = "";
        public string endDateChangeReasonsNvpString = "";
        public bool   okToPreload                   = false;

        public string deferredValIn;

        public string showNavBackToAllWO;

        public string dateRangePrefill = "";


        public UserAllRmtsMomentServiceRecordsManage() : base("rmts_moment_service_records_manage"
                                                         , RmtsMoments.SEL_LABEL_MANAGE
                                                         , "user_all_rmts_moment_service_records_manage.css"
                                                         , ""
                                                         , Constants.ROLE_SBS_ALL_LEA_COORD)
        { }

        protected void Page_Load(object sender, EventArgs e)
        {
            
            okToPreload = false;
            if (uInfo.pcalStaff == false) okToPreload = true;

            
            var ctrldeferredcomplete = findControlRecu(this.Page, "deferredcomplete") as MBA.RadioBox;

            var ctrlDateBoxRange = findControlRecu(this.Page, "daterange") as MBA.DateBoxRange;

            deferredValIn = ( MBA.HttpApplication.getParameter("deferred") == "1" ? "3" : "1");  // E impossibile non mangiare spaghetti

            showNavBackToAllWO = MBA.HttpApplication.getParameter("showNavBackToAllWO");

            ctrldeferredcomplete.AddSelection(
              @"Requires Action",
               "1",
               ( deferredValIn == "3" ? false : true )
            );

            ctrldeferredcomplete.AddSelection(
              @"Matched",
               "2",
               //( deferredValIn == "1" ? false : true )
               false
            );

            ctrldeferredcomplete.AddSelection(
              @"Deferred",
               "3",
               ( deferredValIn == "3" ? true : false )
            );


            var ctrlDateRange             = findControlRecu(this.Page, "daterange")             as DateBoxRange;

            string dateRangeStr = Util.GenerateDateRange(Constants.SVC_REC_EDIT_DATE_RANGE_CONST);
            ctrlDateRange.value = dateRangeStr;

            int parmClientID;
            string clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
            var ctrlClientID  = findControlRecu(this.Page, "selectClient") as MBA.DataEntryRowSelectClient;
            var parmClientIDPassed        = int.TryParse(clientIDStr, out parmClientID);

            var ctrlNav2WOSvc = findControlRecu(this.Page, "gotoViewWoSvcrecs") as MBA.LinkInternal;

            //ctrlNav2WOSvc.urlPrivate = false;

            if (showNavBackToAllWO == "1") {
              ctrlNav2WOSvc.url = RmtsParticipantsWoSvcRecs.URL_PAGE_VIEW;
            } else {

              // an Easter egg present for whatever dev is unlucky enough to work on this.
              // misnamed local variable, oh well

              ctrlNav2WOSvc = findControlRecu(this.Page, "gotoViewAllRosters") as MBA.LinkInternal;
                // the elem ID is correct for this usecase, but the local variable name is wrong-ish 

              ctrlNav2WOSvc.url = RmtsParticipationRosters.URL_MANAGE;
            }
            ctrlNav2WOSvc.addParameter( new NameValue( "clientid" , clientIDStr));


            //
            int pracID;
            string pracIDStr         =   MBA.HttpApplication.getParameter("pracid");  // Constants ???
            var ctrlPracID           =   findControlRecu(this.Page, "selectPractitioner")  as MBA.DataEntryRowSelectPractitioner;
            var pracIDPassed         =   int.TryParse(pracIDStr, out pracID);
            //

            int fyqID;
            string fyqIDStr         =   MBA.HttpApplication.getParameter( 
              MBA.Constants.PARM_FISCAL_QUARTER_ID
            );
            var ctrlFyqID           =   findControlRecu(this.Page, "selectQuarter")  as MBA.DataEntryRowSelectRmtsFiscalQuarter;
            var fyqIDPassed         =   int.TryParse( fyqIDStr, out fyqID );

            // if values provided, hide controls
            if (parmClientIDPassed && parmClientID != 0)
            {
                Object vClientID = Spedmon.Validate.optClientID(uInfo, parmClientID.ToString());
                ctrlClientID.selectValue = vClientID.ToString();
                ctrlClientID.entryInitiallyHidden = true;
                ctrlClientID.entryAllowed = false;

                okToPreload = true;
            }

            //
            if (pracIDPassed && pracID != 0)
            {
                //Object vPracID = Spedmon.Validate.optPracID(uInfo, parmClientID.ToString());

                var p = Spedmon.Practitioners.load(this.dbConnApp, this.log, this.uInfo, pracIDStr );


                ctrlPracID.selectValue = pracID.ToString();
                ctrlPracID.selectName = p.name;

            }

            if ( fyqIDPassed && fyqID != 0)
            {

                var cfq = Spedmon.CompanyFiscalQuarters.loadByFqID(this.dbConnApp, this.log, this.uInfo, "", fyqIDStr);

                ctrlFyqID.selectValue = fyqIDStr ;
                ctrlFyqID.selectName = cfq.name;

                dateRangePrefill =
                    cfq.quarterStartDateStr + " - " + cfq.quarterEndDateStr;

            }

            var ctrlExceptionAddReason    = findControlRecu(this.Page, "deferralreason")     as MBA.DataEntryBoxSelect;
            ctrlExceptionAddReason.addSelection(new MBA.NameValue( "Practitioner Refused Information", "Practitioner Refused Information", @"") );
            ctrlExceptionAddReason.addSelection(new MBA.NameValue( "Practitioner No Longer With District", "Practitioner No Longer With District", @"") );
            ctrlExceptionAddReason.addSelection(new MBA.NameValue( "Website/Technical Difficulty", "Website/Technical Difficulty", @"") );
            ctrlExceptionAddReason.addSelection(new MBA.NameValue( "Other (Please Specify)", "Other (Please Specify)", @"") );

        }

    }
}
