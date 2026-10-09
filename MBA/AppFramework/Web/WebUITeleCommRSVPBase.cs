using System;
using System.Web.UI;
using System.Collections;
using System.Collections.Generic;
 
namespace MBA
{
 
  public abstract class WebUITeleCommRSVPBase: WebApp
  {  
    public WebUITeleCommRSVPBase (string appname, string roomtitlepublic): base(roomtitlepublic)
    {
      this.appName = appname;
    }

    protected MBA.TeleCommSessionParticipant _tsp;
    protected MBA.TeleCommSessionRsvpInfo    _tsi;
    protected string                         _formRsvpControlID = @"formrsvp";
    protected MBA.TeleCommFormRSVP           ctrlFormRsvp;
    protected string                         _statusMessage = @"";
    public    MBA.TeleCommSessionParticipant tsp                { get { return _tsp;}}  /* Keep this read only */
    public    MBA.TeleCommSessionRsvpInfo    tsi                { get { return _tsi; }}  /* Keep this read only */
    public    string                         formRSVPControlID  { get { return _formRsvpControlID;} set { _formRsvpControlID  = value;}}
    public    string                         statusMessage      { get { return _statusMessage;}     set { _statusMessage      = value;}}

   /***************************************************************************
     * GetParms */
    /**
     ***************************************************************************/  
    protected void GetParms()
    {
      if (!_tsp.sessionOK) return;
      _tsp.roomID                 = MBA.HttpApplication.getParameter(Constants.PARM_ROOM_ID);   
      _tsp.participantEmail       = MBA.HttpApplication.getParameter(Constants.PARM_ROOM_PART_UID);   
      _tsp.participantPIN         = MBA.HttpApplication.getParameter(Constants.PARM_ROOM_PART_PIN);  
      _tsp.inviteRsvpToken        = MBA.HttpApplication.getParameter(Constants.PARM_ROOM_PART_RSVP_TOKEN);
      _tsp.inviteRsvpNotes        = MBA.HttpApplication.getParameter(Constants.PARM_ROOM_PART_RSVP_NOTES);
      _tsp.inviteRsvpWillAttend   = MBA.HttpApplication.getParameter(Constants.PARM_ROOM_PART_RSVP_WILL_ATTEND);
      _tsp.inviteRsvpReqResp      = MBA.HttpApplication.getParameter(Constants.PARM_ROOM_PART_RSVP_REQ_RSP);
      return;
    }

    /***************************************************************************
     * CheckIfAllRequiredParmsPassed */
    /**
     ***************************************************************************/  
    protected void CheckIfAllRequiredParmsPassed()
    {
      if (!_tsp.sessionOK) return;
      _tsp.allRequiredParticipantParametersPassed = false;
      _tsp.sessionOK                              = false;
      _statusMessage = "Invalid RSVP request.  Please make sure you have the correct URL.";
    
      if (String.IsNullOrWhiteSpace(_tsp.roomID))           return;
      if (String.IsNullOrWhiteSpace(_tsp.participantEmail)) return;
      if (String.IsNullOrWhiteSpace(_tsp.inviteRsvpToken))  return;
      _tsp.allRequiredParticipantParametersPassed = true;
      _tsp.sessionOK                              = true;
      _statusMessage = "";
      return;
    }
    protected void SaveRSVPResponse()
    {
      if (!_tsp.sessionOK) return;
      if ( _tsp.inviteRsvpReqResp != MBA.TeleCommSessionParticipants.SESSION_RSVP_RSP ) return; 

      var save_results = TeleCommSessions.saveRsvpAnswer (   this.dbConnUser
                                                           , this.log
                                                           , this.uInfo
                                                           , _tsp.roomID
                                                           , _tsp.inviteRsvpToken

                                // form submits empty checkbox as blank string in URL; can probably remove this
                                // once refactored as two-button form
                                                           , Util.IsNullOrEmpty( _tsp.inviteRsvpWillAttend ) ? "0" : _tsp.inviteRsvpWillAttend                                        
                                                           , "" //altDateRequested
                                                           , _tsp.inviteRsvpNotes );

      if (save_results.status != MBA.Return.RET_SUCCESS) { 
        _tsp.sessionOK = false;
        statusMessage  = "Meeting expired or non-existent. Could not save your response.";
      }
      return;
    }
    
    protected void loadTsiPopulateTsp() {
      
      if (!_tsp.sessionOK) return;  
      
      /* Load room info */

      _tsi = MBA.TeleCommSessionParticipants.getInfoForRsvp (  this.dbConnUser
                                                             , this.log
                                                             , this.uInfo 
                                                             , MBA.HttpApplication.retrieveRequestResponse()
                                                             , this.appName 
                                                             , _tsp.roomID
                                                             , _tsp.participantEmail
                                                             , _tsp.inviteRsvpToken );
      if (_tsi.retrieveInfoIsOK == false)
      {
        _tsp.sessionOK = false;
        _statusMessage = "Unable to retrieve meeting info.  Please try your request again";
        return;
      }

      _tsp.sessionOK = _tsi.sessionOK;
      
      ctrlFormRsvp.tsp = _tsp;

      if (_tsi.sessionOK == true) 
      { 
        _tsp.inviteRsvpNotes = _tsi.inviteRsvpNotes;
        ctrlFormRsvp.invite_text             = _tsi.formInviteText;
        ctrlFormRsvp.rsvpWillAttend          = _tsi.inviteRsvpWillAttend;
        ctrlFormRsvp.participants_html_table = _tsi.participantsHtmlTbl;      
      } 
      else
      { 
        _statusMessage = "Invalid or expired; no meeting found for this URL";
      }
    }

    protected void Page_Load (object sender, EventArgs e)
    {
     
      _tsp                = new TeleCommSessionParticipant();
      _tsi                = new TeleCommSessionRsvpInfo();
      _tsp.renderWhatRoom = TeleCommRenderWhatRoom.RSVP_FORM ;
      _tsp.sessionOK      = true; /* Assume OK until proven otherwise*/ 
      _statusMessage      = @"";

       if ( uInfo == null) { 
         uInfo = new UserInfo();
         uInfo.userid    = 0;
         uInfo.userGroup = 0;
         uInfo.userRank  = 0;
       }
      
       /* Find RSVP control */

       this.ctrlFormRsvp = findControlRecu(this.Page, this._formRsvpControlID) as MBA.TeleCommFormRSVP;

       GetParms();        
       CheckIfAllRequiredParmsPassed();
       SaveRSVPResponse();       
       loadTsiPopulateTsp();

    }
   
    /***************************************************************************
     * Render */
    /**
     ***************************************************************************/   
    protected override void Render(HtmlTextWriter writer)
    {                                                                     
      
    /*#############################################################################
      #                            Top of Document
      #############################################################################*/

      RenderDocumentStartHeadStartCommonMetaPageTitle (ref writer, ref rd, @"pagehead", subTitle);

    /*#############################################################################
      #                            CSS Includes
      #############################################################################*/

      /*=========================================================
        =                 Third Party Style Sheets
        =========================================================*/

      RenderCSSInclude (ref writer, @"web-ui-3/openvidu/css/fa/all.min.css",        false);
      RenderCSSInclude (ref writer, @"web-ui-3/openvidu/css/bootstrap.min.css",     false);
      RenderCSSInclude (ref writer, @"web-ui-3/openvidu/css/jquery-ui.min.css",     false);
      RenderCSSInclude (ref writer, @"web-ui-3/openvidu/css/animate.min.css",       false);  
      
      /*=========================================================
        =                     Our Style Sheets
        =========================================================*/

      /*+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
        +  Common 
        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+*/

      RenderCSSInclude (ref writer, @"web-ui-3/openvidu/css/page-common.css",       true);
      RenderCSSInclude (ref writer, @"web-ui-3/openvidu/css/telecomm-common.css",   true);
      RenderCSSInclude (ref writer, @"css/all.css",                                 true);
      
      /*#############################################################################
        #                               JS Includes
        #############################################################################*/

      /*=========================================================
        =                 Third Party Javascript
        =========================================================*/

      RenderJSInclude  (ref writer, @"web-ui-3/openvidu/js/jquery-3.5.1.min.js",            false);
      RenderJSInclude  (ref writer, @"web-ui-3/openvidu/js/jquery-ui.min.js",               false);
     
      /*=========================================================
        =                 Our Javascript
        =========================================================*/

     /*+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       +  Common 
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+*/

      RenderJSInclude  (ref writer, @"web-ui-3/openvidu/js/page-common.js",                 true);
      
     /*#############################################################################
       #                        Middle Of Document
       #############################################################################*/

      RenderHeadEndBodyStart (ref writer, ref rd, bodyID);

     /*=========================================================
       =                  Room Specific Content
       =========================================================*/
     
      base.Render(writer);         

     /*#############################################################################
       #                         Bottom Of Document
       #############################################################################*/

      RenderBodyEndDocumentEnd(ref writer, ref rd);


    }

  }
}     