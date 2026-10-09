using System;
using System.Text;


namespace Spedmon
{




  /***************************************************************************
   * UserAllRmtsParticipantsWoSvcRecs */
  /**
   * 
   ***************************************************************************/

  public class UserAllRmtsParticipantsWoSvcRecs : WebUI
  {


    public string deferredValIn ;


    public UserAllRmtsParticipantsWoSvcRecs() : base (   "rmts_participants_wo_svcrecs"
                                                     , RmtsParticipationRosters.SEL_LABEL_MANAGE + " No Svc Recs"
                                                     , ""
                                                     , ""
                                                     , Constants.ROLE_ALL_PCAL_AND_CLIENT) {

      // deferredValIn = ( MBA.HttpApplication.getParameter("deferred") == "1" ? "1" : "0");
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {


            var ctrldeferralstatus = findControlRecu(this.Page, "deferralstatus") as MBA.RadioBox;

            deferredValIn = ( MBA.HttpApplication.getParameter("deferred") == "1" ? "1" : "0");

            ctrldeferralstatus.AddSelection(
              @"Deferred",
               "1",
               ( deferredValIn == "1" ? true : false )
            );

            ctrldeferralstatus.AddSelection(
              @"Pending & Resolved",
               "0",
               ( deferredValIn == "1" ? false : true )
            );


            // allow clientID and quarter ID to be passed in from URL
            var ctrlClientID  = findControlRecu(this.Page, "selectClient") as MBA.DataEntryRowSelectClient;

            var ctrlNav2Rosters = findControlRecu(this.Page, "Gotomanagerosters")    as MBA.LinkInternal;
            var ctrlFingerNav2Rosters = findControlRecu(this.Page, "fingernavGotomanagerosters")    as MBA.LinkInternal;


            ctrlNav2Rosters.url         = "user_all_rmts_participation_roster_manage.aspx";
            ctrlFingerNav2Rosters.url   = "user_all_rmts_participation_roster_manage.aspx";


            string clientIDStr     = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID) ;

            int parmClientID; //, ParmFyYearID, ParmQtrNumber;

            var parmClientIDPassed        = int.TryParse(clientIDStr, out parmClientID);


            // if values provided, hide controls
            if (parmClientIDPassed && parmClientID != 0)
            {
                Object vClientID = Spedmon.Validate.optClientID(uInfo, parmClientID.ToString());
                ctrlClientID.selectValue = vClientID.ToString();
                ctrlClientID.entryInitiallyHidden = true;
                ctrlClientID.entryAllowed = false;
            }

            var ctrlExceptionAddReason    = findControlRecu(this.Page, "deferralreason")     as MBA.DataEntryBoxSelect;
            ctrlExceptionAddReason.addSelection(new MBA.NameValue( "Practitioner Refused Information", "Practitioner Refused Information", @"") );
            ctrlExceptionAddReason.addSelection(new MBA.NameValue( "Practitioner No Longer With District", "Practitioner No Longer With District", @"") );
            ctrlExceptionAddReason.addSelection(new MBA.NameValue( "Website/Technical Difficulty", "Website/Technical Difficulty", @"") );
            ctrlExceptionAddReason.addSelection(new MBA.NameValue( "Other (Please Specify)", "Other (Please Specify)", @"") );

    }
    
  }
}
