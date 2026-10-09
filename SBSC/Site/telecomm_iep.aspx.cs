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
   * TeleCommPageIEP */
  /**
   * 
   ***************************************************************************/   

  public class TeleCommPageIEP: Spedmon.WebUITeleCommBase
  {
    public TeleCommPageIEP() : base(TeleIEPSessions.SEL_LABEL) {
    }
    

    /***************************************************************************
     * Page_Load */
    /**
     ***************************************************************************/   
    protected new void Page_Load (object sender, EventArgs e)
    {
      base.Page_Load(sender, e);
                
      if ((_tsp.sessionOK == true) && (_tsp.renderWhatRoom == TeleCommRenderWhatRoom.INSIDE_ROOM)) {
      
        uInfo = new UserInfo();
        uInfo.userid    = 0;
        uInfo.userGroup = 0;
        uInfo.userRank  = 0;
        
       /*###########################################################################
         # Get participant list
         ###########################################################################*/    

        var participants = TeleCommParticipants.viewList(dbConnUser,log,uInfo,Constants.APP_NAME,Constants.TELECOMM_PURPOSE_IEP, _tsp.sessionID, null);

       /*###########################################################################
         # Get control references for select participant controls
         ###########################################################################*/    

        var ctrlSignAttendanceRoster   = findControlRecu(this.Page,  "signattendrosteruid")      as MBA.TeleCommFormSelectParticipant;        
        var ctrlSignIepPgPrimary       = findControlRecu(this.Page,  "parentprimaryuid")         as MBA.TeleCommFormSelectParticipant;
        var ctrlSignIepPgSecondary     = findControlRecu(this.Page,  "parentsecondaryuid")       as MBA.TeleCommFormSelectParticipant;
        var ctrlSignLeaBopConsent      = findControlRecu(this.Page,  "parentleabopconsentuid")   as MBA.TeleCommFormSelectParticipant;
        var ctrlParentPrimaryPin       = findControlRecu(this.Page,  "parentprimarypin")         as MBA.TeleCommFormEnterPIN;
        var ctrlParentSecondaryPin     = findControlRecu(this.Page,  "parentsecondarypin")       as MBA.TeleCommFormEnterPIN;
        var ctrlParentLeaBopConsentPin = findControlRecu(this.Page,  "parentleabopconsentpin")   as MBA.TeleCommFormEnterPIN;
        var ctrlSignAttendRosterPin    = findControlRecu(this.Page,  "signattendrosterpin")      as MBA.TeleCommFormEnterPIN;
   
       /*###########################################################################
         # Add telecomm session participant object to select participant controls
         ###########################################################################*/    

        ctrlSignAttendanceRoster.tsp  = _tsp;
        ctrlSignIepPgPrimary.tsp      = _tsp;
        ctrlSignIepPgSecondary.tsp    = _tsp;
        ctrlSignLeaBopConsent.tsp     = _tsp;

       /*###########################################################################
        # Preload pin
        ###########################################################################*/
        
        ctrlParentLeaBopConsentPin.value = ctrlParentPrimaryPin.value = ctrlParentSecondaryPin.value = ctrlSignAttendRosterPin.value = _tsp.participantPIN;                                     
       
       /*###########################################################################
         # Add participants list to select participant controls
         ###########################################################################*/    

        ctrlSignAttendanceRoster.participants = participants;
        ctrlSignIepPgPrimary.participants     = participants;
        ctrlSignIepPgSecondary.participants   = participants;
        ctrlSignLeaBopConsent.participants    = participants;


                       
      }            
    }   
  }
}