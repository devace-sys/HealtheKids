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
using System.Collections.Generic;

namespace Spedmon
{
  /***************************************************************************
   * TeleCommPageTeleHealth */
  /**
   * 
   ***************************************************************************/   

  public class TeleCommPageTeleHealth: Spedmon.WebUITeleCommBase
  {

    protected bool _showServiceRecordOptions = false;
    protected  List<TeleCommParticipant> _patientParticipants;
    public bool                      showServiceRecordOptions { get { return _showServiceRecordOptions; }}
    public List<TeleCommParticipant> patientParticipants      { get { return _patientParticipants; }}
    public TeleCommPageTeleHealth() : base(TeleHealthSessions.SEL_LABEL) {}
  
   /***************************************************************************
     * Page_Load */
    /**
     ***************************************************************************/   
    protected new void Page_Load (object sender, EventArgs e)
    {
      base.Page_Load(sender, e);
      _showServiceRecordOptions = false;
      _patientParticipants = new List<TeleCommParticipant>();

      /*============================================================
       * If participant is the practitioner or sub
       *============================================================*/   
      
      if ( (_tsp.sessionOK == true) && (_tsp.renderWhatRoom == TeleCommRenderWhatRoom.INSIDE_ROOM) && (_tsp.participantIsFacilitator == true) ) {
        
        _showServiceRecordOptions = true;        
        
        uInfo = new UserInfo();
        uInfo.userid    = 0;
        uInfo.userGroup = 0;
        uInfo.userRank  = 0;

        _patientParticipants = Spedmon.TeleCommParticipantsTeleHealth.viewListPatients (  dbConnUser
                                                                                        , log
                                                                                        , uInfo
                                                                                        , _tsp.sessionID);
        if (_patientParticipants.Count == 0) _showServiceRecordOptions = false;

      }
    }  
  }

  
}