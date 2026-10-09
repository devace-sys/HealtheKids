using System;
using System.Text;


namespace Spedmon
{


  /***************************************************************************
   * SBSAllRmtsParticipationManage */
  /**
   * 
   ***************************************************************************/

  public class UserAllRmtsParticipationManage : WebUI
  {


    public string startDateChangeReasonsNvpString = "";
    public string endDateChangeReasonsNvpString = "";

    public long quarterID = 0;
    public string quarterDatesDesc = "";

    public long yearID;

    public UserAllRmtsParticipationManage() : base (   "rmts_participation_manage"
                                                     , RmtsParticipationRosters.SEL_LABEL_MANAGE
                                                     , "rmts_participation_rosters.css"
                                                     , ""
                                                     , Constants.ROLE_RMTS_ADMINS_AND_PRACS ) { }
    
    protected void Page_Load(object sender, EventArgs e)
    {

            var ctrlClientID  = findControlRecu(this.Page, "selectClient") as MBA.DataEntryRowSelectClient;

            var ctrlNav2WOSvc = findControlRecu(this.Page, "gotoViewWoSvcrecs")    as MBA.LinkInternal;

            
            
            string clientIDStr     = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID)
                 , fiscalYearIDStr = MBA.HttpApplication.getParameter(Constants.PARM_FISCAL_YEAR_ID)
                 , fiscalQtrNumStr = MBA.HttpApplication.getParameter(Constants.PARM_QUARTER_NUMBER);

            int parmClientID, ParmFyYearID, ParmQtrNumber;

            ctrlNav2WOSvc.url = RmtsParticipantsWoSvcRecs.URL_PAGE_VIEW;

            var parmClientIDPassed        = int.TryParse(clientIDStr, out parmClientID);

            var parmFyYearIDPassed        = int.TryParse(fiscalYearIDStr, out ParmFyYearID);
            var parmFiscalQtrNumberPassed = int.TryParse(fiscalQtrNumStr, out ParmQtrNumber);

            // if values provided, hide controls
            if (parmClientIDPassed && parmClientID != 0)
            {
                Object vClientID = Spedmon.Validate.optClientID(uInfo, parmClientID.ToString());
                ctrlClientID.selectValue = vClientID.ToString();
                ctrlClientID.entryInitiallyHidden = true;
                ctrlClientID.entryAllowed = false;
            }



            CompanyFiscalQuarter fiscalQuarter = null;
            CompanyFiscalYear    fiscalYear    = null;
            var selectFiscalYear = findControlRecu(this.Page, "selectFiscalYear") as MBA.DataEntryRowSelectEntity;

            if (   parmFiscalQtrNumberPassed && ParmQtrNumber > 0 && ParmQtrNumber < 5
                && parmFyYearIDPassed && ParmFyYearID != 0
            )
            {
                //yearID = ParmFyYearID;
                fiscalQuarter =
                    CompanyFiscalQuarters.load(
                      this.dbConnApp,
                      this.log,
                      this.uInfo,
                      "1",
                      null,
                      ParmFyYearID.ToString(),
                      ParmQtrNumber.ToString(),
                      null
                 );

                this.quarterID         = fiscalQuarter.id ;
                this.quarterDatesDesc  = fiscalQuarter.quarterStartDateStr + " to " + fiscalQuarter.quarterEndDateStr;             

                fiscalYear = CompanyFiscalYears.load(this.dbConnApp, this.log, this.uInfo, fiscalQuarter.fyID.ToString() );

                selectFiscalYear.selectValue = fiscalYear.ID.ToString();
                selectFiscalYear.selectName  = fiscalYear.name;

            }

            else  {
                fiscalYear = CompanyFiscalYears.loadCurrent(this.dbConnApp, this.log, this.uInfo);
            }

            selectFiscalYear.selectValue = fiscalYear.ID.ToString();
            selectFiscalYear.selectName = fiscalYear.name;
            yearID = fiscalYear.ID;

            var ctrlFiscalQtrSelection = findControlRecu(this.Page, "fiscalquarterselection") as MBA.RadioBox;

            //ctrlFiscalQtrSelection.AddSelection(@"All Codes", "", true);

            ctrlFiscalQtrSelection.AddSelection(@"Q1", "1", ( fiscalQuarter != null && fiscalQuarter.quarterNumber == 1 )  );
            ctrlFiscalQtrSelection.AddSelection(@"Q2", "2", ( fiscalQuarter != null && fiscalQuarter.quarterNumber == 2 )  );
            ctrlFiscalQtrSelection.AddSelection(@"Q3", "3", ( fiscalQuarter != null && fiscalQuarter.quarterNumber == 3 )  );
            ctrlFiscalQtrSelection.AddSelection(@"Q4", "4", ( fiscalQuarter != null && fiscalQuarter.quarterNumber == 4 )  );

            /* Get list of reasons that we will use to pass to field definition for selecting change reasons */

            var startDateChangeReasons = RmtsReasonsForStartDateChange.viewList(dbConnApp, log, uInfo);
            var sb = new StringBuilder();
            sb.Append(@"[{name:'',value:''}");
            foreach (var reason in startDateChangeReasons)
            {
                sb.AppendFormat(@",{{name:'{0}',value:'{1}'}}", reason.reason, reason.id);
            }
            sb.Append(@"]");
            startDateChangeReasonsNvpString = sb.ToString();

            var endDateChangeReasons = RmtsReasonsForEndDateChange.viewList(dbConnApp, log, uInfo);
            sb = new StringBuilder();
            sb.Append(@"[{name:'',value:''}");
            foreach (var reason in endDateChangeReasons)
            {
                sb.AppendFormat(@",{{name:'{0}',value:'{1}'}}", reason.reason, reason.id);
            }
            sb.Append(@"]");
            endDateChangeReasonsNvpString = sb.ToString();
    }
    
  }
}
