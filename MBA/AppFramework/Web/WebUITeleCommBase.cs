using System;
using System.Web.UI;
using System.Collections;
using System.Collections.Generic;

namespace MBA
{

  /***************************************************************************
   * WebUITeleCommBase */
  /**
   * Base class for all web user interface (UI) pages that use OpenVIDU or other
   * WebRTC Telecomm libraries.
   *
   * This class generates a
   * standard framework of HTML markup, CSS includes, and Javascript includes
   * for every page that inherits from it.  It also renders any content that
   * the subclasses provide.  This provides a uniform "look and feel" for
   * all UI pages.
   *
   * @param  bodyid            The id you wish to give to the body tag.
   * @param  subtitle          The subtitle you wish to give to the page.  The page
   *                           title will be Application Name - Subtitle
   * @param  rmenuPublic       Delegate to render public menu
   * @param  rmenuPrivate      Delegate to render private menu
   * @param  rfooterPublic     Delegate to render public footer
   * @param  rfooterPrivate    Delegate to render private footer
   * @param  css               Additional external css files
   * @param  js                Additional external js files
   * @param  permittedRoles    User roles that are allowed to access the page
   *
   ****************************************************************************/

  public abstract class WebUITeleCommBase: WebApp
  {
    
    public WebUITeleCommBase(string appname, string roomtitlepublic): base(roomtitlepublic)
    {
      
      this.appName         = appname;
      this.roomTitlePublic = roomtitlepublic;
    }

    protected TeleCommSessionParticipant _tsp;
    
    protected string _roomTitlePublic                          = @"";
    protected string _customIncludeForAppCSS                   = @""; /* Future use.. Set in app specific telecommbase class constructor */
    protected string _customIncludeForAppJS                    = @""; /* Future use.. Set in app specific telecommbase class constructor */
    
    protected string _customIncludeForPageCSS                  = @"";
    protected string _customIncludeForPageJS                   = @"";

    protected string _formJoinControlID                        = "formjoin";
    protected string _formLeaveControlID                       = "formleave";
    protected string _systemStatusElementID                    = "telecommstatus";       
    protected string _browserNotSupportedElementID             = "connectioncounter";
    protected string _sessionLogElementID                      = "sessionlog";
    protected string _participantPublicationControlsElementID  = "participantpublicationcontrols";
    protected string _participantStreamsElementID              = "participantstreams";
    protected string _participantStreamsContainerID            = "participantsstreamscontainer";
    protected string _toggleParticipantsViewBtnID              = "toggleparticipantsviewbtn";
    protected string _whatIsMyPinBtnID                         = "whatismypinbtn";
    protected string _sendMeetingInvitesBtnID                  = "sendmeetinginvitesbtn";
    protected string _appendSharedFilesBtnID                   = "appendsharedfilesbtn";
    protected string _sessionFilesElementID                    = "sessionfiles";
    protected string _sessionPresentContentElementID           = "sessionpresentcontent";
    protected string _sessionPresentModalElementID             = "sessionpresentmodal";
    protected string _sessionPresentModalCloseButtonElementID  = "sessionpresentmodalclose";
    protected string _meetingTimerElementID                    = "meeting-timer";
    protected string _fullScreenContainerID                    = "fullscreencontainer";
    protected string _fullScreenModalElementID                 = "fullscreenmodal";
    protected string _fullScreenModalCloseButtonElementID      = "fullscreenmodalclose";
    protected string _headerElementSelector                    = "header";
    protected string _mainElementSelector                      = "main";
    protected string _footerElementSelector                    = "footer";
    protected string _baseLink                                 = "";
    
    protected string _urlGetSharedFileHtmlList                 = "";
    protected string _urlSaveFormWip                           = "";
    protected string _urlSignForm                              = "";
    protected string _urlGetFormSignaturesHtmlTable            = "";
    protected string _urlBanUser                               = "";
    protected string _urlSendMeetingInvites                    = "";
    protected string _urlAppendFileShare                       = "";
    protected bool   _autoRestoreFormAndSignatureData          = true;
    protected bool   _facilitatorRequiredInRoom                = false;

    public TeleCommSessionParticipant tsp                  { get { return _tsp;}}  /* Keep this read only */   
    public string roomTitlePublic                          { get { return _roomTitlePublic;}                          set { _roomTitlePublic = value;}}
    public string customIncludeForPageCSS                  { get { return _customIncludeForPageCSS;}                  set { _customIncludeForPageCSS = value;}}
    public string customIncludeForPageJS                   { get { return _customIncludeForPageJS;}                   set { _customIncludeForPageJS = value;}}
    public string formJoinControlID                        { get { return _formJoinControlID;}                        set { _formJoinControlID  = value;}}
    public string formLeaveControlID                       { get { return _formLeaveControlID;}                       set { _formLeaveControlID = value;}}
    public string browserNotSupportedElementID             { get { return _browserNotSupportedElementID;}             set { _browserNotSupportedElementID = value;}}
    public string sessionLogElementID                      { get { return _sessionLogElementID;}                      set { _sessionLogElementID = value;}}
    public string systemStatusElementID                    { get { return _systemStatusElementID ;}                   set { _systemStatusElementID = value;}}
    public string participantPublicationControlsElementID  { get { return _participantPublicationControlsElementID;}  set { _participantPublicationControlsElementID = value;}}
    public string participantStreamsElementID              { get { return _participantStreamsElementID;}              set { _participantStreamsElementID = value;}}
    public string participantStreamsContainerID            { get { return _participantStreamsContainerID; }           set { _participantStreamsContainerID = value;}}
    public string toggleParticipantsViewBtnID              { get { return _toggleParticipantsViewBtnID; }             set { _toggleParticipantsViewBtnID = value;}}
    public string whatIsMyPinBtnID                         { get { return _whatIsMyPinBtnID; }                        set { _whatIsMyPinBtnID = value;}}
    public string sendMeetingInvitesBtnID                  { get { return _sendMeetingInvitesBtnID; }                 set { _sendMeetingInvitesBtnID = value;}}
    public string appendSharedFilesBtnID                   { get { return _appendSharedFilesBtnID; }                  set { _appendSharedFilesBtnID = value; }}
    public string sessionFilesElementID                    { get { return _sessionFilesElementID ;}                   set { _sessionFilesElementID = value;}}
    public string sessionPresentContentElementID           { get { return _sessionPresentContentElementID;}           set { _sessionPresentContentElementID = value;}}
    public string meetingTimerElementID                    { get { return _meetingTimerElementID;}                    set {_meetingTimerElementID           = value;}}    
    public string fullScreenContainerID                    { get { return _fullScreenContainerID; }                   set { _fullScreenContainerID = value;}}
    public string headerElementSelector                    { get { return _headerElementSelector;} set { _headerElementSelector = value; }}
    public string mainElementSelector                      { get { return _mainElementSelector;}   set { _mainElementSelector = value; }}
    public string footerElementSelector                    { get { return _footerElementSelector;} set { _footerElementSelector = value; }}
    public bool autoRestoreFormAndSignatureData { get { return _autoRestoreFormAndSignatureData; } set { _autoRestoreFormAndSignatureData = value; } }
    public bool facilitatorRequiredInRoom { get { return _facilitatorRequiredInRoom; } set { _facilitatorRequiredInRoom = value; } }
    
    /* Read only properties */
    public string baseLink                 { get { return _baseLink;     }}             /* Keep read only*/
    public string urlGetSharedFileHtmlList { get { return _urlGetSharedFileHtmlList;}}  /* Keep read only */
    public string urlSaveFormWip           { get { return _urlSaveFormWip;  }}          /* Keep read only */
    public string urlSignForm              { get { return _urlSignForm;  }}             /* Keep read only */
    public string urlViewFormSignatures    { get { return _urlGetFormSignaturesHtmlTable;  }}   /* Keep read only */
    public string urlbanuser               { get { return _urlBanUser;  }}   /* Keep read only */
    public string urlSendMeetingInvites    { get { return _urlSendMeetingInvites;  }}   /* Keep read only */
    public string urlAppendFileShare       {  get { return _urlAppendFileShare; }}     /* Keep read only */
   
    /***************************************************************************
     * GetParms */
    /**
     ***************************************************************************/   
    protected void GetParms()
    {
      _tsp.roomID            = MBA.HttpApplication.getParameter(Constants.PARM_ROOM_ID);   
      _tsp.participantEmail  = MBA.HttpApplication.getParameter(Constants.PARM_ROOM_PART_UID);   
      _tsp.participantPIN    = MBA.HttpApplication.getParameter(Constants.PARM_ROOM_PART_PIN);  
      _tsp.roomEnterExit     = MBA.HttpApplication.getParameter(Constants.PARM_ROOM_PART_ENTER_OR_EXIT);  
      return;
    }
    
    /***************************************************************************
     * CheckIfAllRequiredParmsPassed */
    /**
     ***************************************************************************/      
    protected void CheckIfAllRequiredParmsPassed()
    {
      _tsp.allRequiredParticipantParametersPassed = false;

      if (String.IsNullOrWhiteSpace(_tsp.roomID))           return;
      if (String.IsNullOrWhiteSpace(_tsp.participantEmail)) return;
      if (String.IsNullOrWhiteSpace(_tsp.participantPIN))   return;
      if (String.IsNullOrWhiteSpace(_tsp.roomEnterExit))    return;
      
      _tsp.allRequiredParticipantParametersPassed = true;
      
      return;
    }
       
    /***************************************************************************
     * GenerateSystemStatusMessageMarkup */
    /**
     ***************************************************************************/      

    public static string GenerateSystemStatusMessageMarkup (string bsAlertClass, string message)
    {

      return String.Format(@"<div class=""alert alert-{0}"">{1}</div>"
                           ,bsAlertClass
                           ,message);
    }

    /***************************************************************************
     * showSessionJoinFailedMessage */
    /**
     * 
     * 
     ****************************************************************************/

    public static bool showSessionJoinFailedMessage (TeleCommSessionParticipant tsp)
    {
      if (tsp == null) return false;
      if (tsp.renderWhatRoom == MBA.TeleCommRenderWhatRoom.OUTSIDE_ROOM)
      {
        if ((!tsp.sessionOK) && (tsp.joinSessionFailed)) return true;
      }
      return false;
    }
    
    /***************************************************************************
     * generateSessionJoinedFailedStatusMessageIfNeeded */
    /**
     * 
     * 
     ****************************************************************************/

    public static string generateSessionJoinedFailedStatusMessageIfNeeded (TeleCommSessionParticipant tsp) 
    {
      if (showSessionJoinFailedMessage(tsp)) return WebUITeleCommBase.GenerateSystemStatusMessageMarkup(@"danger",tsp.sessionStatusMessage);
      return @"";
    }

    /***************************************************************************
     * Page_Load */
    /**
     ***************************************************************************/   
    protected void Page_Load (object sender, EventArgs e)
    {
      _tsp = new TeleCommSessionParticipant();
      GetParms();        
      CheckIfAllRequiredParmsPassed();
      
      if (_tsp.allRequiredParticipantParametersPassed)
      {
        if (_tsp.roomEnterExit == TeleCommSessionParticipants.SESSION_JOIN)
        {          
          TeleCommSessionParticipants.joinSession (dbConnUser, log, uInfo, rd, appName, ref _tsp);              
          if (_tsp.sessionOK) {
            _tsp.renderWhatRoom = TeleCommRenderWhatRoom.INSIDE_ROOM;                                                                       
          }                                                      
        }
        else if (_tsp.roomEnterExit == TeleCommSessionParticipants.SESSION_LEAVE)
        {
          // TODO: Put leave session call here
          _tsp.renderWhatRoom = TeleCommRenderWhatRoom.OUTSIDE_ROOM;  
        }
        else 
        {
          _tsp.renderWhatRoom = TeleCommRenderWhatRoom.OUTSIDE_ROOM;
        }
      }
      else
      {
        _tsp.renderWhatRoom = TeleCommRenderWhatRoom.OUTSIDE_ROOM;
      }              
    
      var formJoin  = findControlRecu(this.Page,  _formJoinControlID)  as MBA.TeleCommFormJoin;
      var formLeave = findControlRecu(this.Page,  _formLeaveControlID) as MBA.TeleCommFormLeave;
      formJoin.tsp  = _tsp;
      formLeave.tsp = _tsp;  
  
      _baseLink       = HttpApplication.currentServerApp();      

      _urlGetSharedFileHtmlList      = HttpApplication.createLink (TeleCommSessionParticipants.URL_GET_SHARED_FILE_HTML_LIST);       
      _urlSaveFormWip                = HttpApplication.createLink (TeleCommSessionParticipants.URL_SAVE_FORM_WIP); 
      _urlSignForm                   = HttpApplication.createLink (TeleCommSessionParticipants.URL_SIGN_FORM); 
      _urlGetFormSignaturesHtmlTable = HttpApplication.createLink (TeleCommSessionParticipants.URL_GET_FORM_SIGNATURES_HTML_TABLE);
      _urlBanUser                    = HttpApplication.createLink (TeleCommSessionParticipants.URL_BAN_USER);
      _urlSendMeetingInvites         = HttpApplication.createLink (TeleCommSessions.URL_SEND_MEETING_INVITES);
      _urlAppendFileShare            = HttpApplication.createLink (TeleCommSessionFileShares.FILE_APPEND_URL_BASE);
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
      RenderCSSInclude (ref writer, @"css/all.css",   true);
      
      /*+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
        +  Application Specific 
        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+*/

      if (!String.IsNullOrWhiteSpace(_customIncludeForAppCSS))
      {        
        RenderCSSInclude  (ref writer, @"web-ui-3/openvidu/css/custom/forapp/" + _customIncludeForAppCSS, true);
      }
      
      /*+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
        +  Page (Room) Specific 
        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+*/

      if (!String.IsNullOrWhiteSpace(_customIncludeForPageCSS))
      {
        RenderCSSInclude  (ref writer, @"web-ui-3/openvidu/css/custom/forpage/" + _customIncludeForPageCSS, true);
      }

      /*#############################################################################
        #                               JS Includes
        #############################################################################*/

      /*=========================================================
        =                 Third Party Javascript
        =========================================================*/

      RenderJSInclude  (ref writer, @"web-ui-3/openvidu/js/jquery-3.5.1.min.js",            false);
      RenderJSInclude  (ref writer, @"web-ui-3/openvidu/js/jquery-ui.min.js",               false);
      RenderJSInclude  (ref writer, @"web-ui-3/openvidu/js/popper.min.js",                  false);
      RenderJSInclude  (ref writer, @"web-ui-3/openvidu/js/bootstrap.min.js",               false);          
      RenderJSInclude  (ref writer, @"web-ui-3/openvidu/js/autosize.min.js",                false);
      RenderJSInclude  (ref writer, @"web-ui-3/openvidu/js/jquery.deserialize.min.js",      false);         
      RenderJSInclude  (ref writer, @"web-ui-3/openvidu/js/openvidu-browser-2.17.0.min.js", false);
      RenderJSInclude  (ref writer, @"third-party/signature-pad.min.js"                   , false);

      /*=========================================================
        =                 Our Javascript
        =========================================================*/

     /*+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       +  Common 
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+*/

      RenderJSInclude  (ref writer, @"web-ui-3/openvidu/js/mba-util.js",                    true);   
      RenderJSInclude  (ref writer, @"web-ui-3/openvidu/js/mba-ajax.js",                    true);
      RenderJSInclude  (ref writer, @"web-ui-3/openvidu/js/jquery-responsize-dialog.js",    true);   
      RenderJSInclude  (ref writer, @"web-ui-3/openvidu/js/mba-action-dialogs.js",          true);
      RenderJSInclude  (ref writer, @"web-ui-3/openvidu/js/mba-stored-file.js",             true);
      RenderJSInclude  (ref writer, @"web-ui-3/openvidu/js/page-common.js",                 true);
      
      /*----------------
       - Logged Into
       - Room Only
       ----------------*/
      
       if (_tsp.renderWhatRoom == TeleCommRenderWhatRoom.INSIDE_ROOM) {
        RenderJSInclude  (ref writer, @"web-ui-3/openvidu/js/timer-common.js",    true);
        RenderJSInclude  (ref writer, @"web-ui-3/openvidu/js/telecomm-common.js", true);             
        RenderJSInclude  (ref writer, @"js/components/jquery-spedmon-signature-pad.js", true);             
      }
      
      /*+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
        +  Application Specific 
        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+*/

      if (!String.IsNullOrWhiteSpace(_customIncludeForAppJS))
      {        
        RenderJSInclude  (ref writer, @"web-ui-3/openvidu/js/custom/forapp/" + _customIncludeForAppJS, true);
      }
      
      /*+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
        +  Page (Room) Specific 
        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+*/

      if (!String.IsNullOrWhiteSpace(_customIncludeForPageJS))
      {
        RenderJSInclude  (ref writer, @"web-ui-3/openvidu/js/custom/forpage/" + _customIncludeForPageJS, true);
      }
      
      /*#############################################################################
        #                          Document Ready Init 
        #############################################################################*/

      writer.Write(@"<script type=""text/javascript"">");
      writer.Write(@"$(function() {");
      
      writer.Write(@"setMainDivBottomMargin ('{0}', '{1}');", _mainElementSelector, _footerElementSelector);

      /*+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
        +  Logged into Room Specific Init
        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+*/
    
      if (_tsp.renderWhatRoom == TeleCommRenderWhatRoom.INSIDE_ROOM)
      {
       
        if (!String.IsNullOrWhiteSpace(_meetingTimerElementID)) {
          var _workerScript = "web-ui-3/openvidu/js/timer-worker.js";
          writer.Write(@"startTimer((new Date('{0}').valueOf()),'{1}','#{2}');",_tsp.meetingStartDate, _workerScript, _meetingTimerElementID);
        }

        writer.Write (@"var tspPcd = {0};",_tsp.participantConnectionData);
        
        if (_autoRestoreFormAndSignatureData) {
          writer.Write(@"var tspLrfdr = ""{0}"";",_tsp.latestRoomFormDataJSONRecorded);
        }
        else {
          writer.Write(@"var tspLrfdr = '{}';");
        }
      
                writer.Write(@"MBA.telecomm.initTelecomm ('{0}', '{1}', '{2}', '{3}', '{4}', '{5}', '{6}', '{7}', '{8}', '{9}', '{10}', '{11}', '{12}', '{13}', '{14}', '{15}', '{16}', '{17}', '{18}', '{19}', '{20}', '{21}', '{22}', '{23}', tspPcd, tspLrfdr);"
                     , _systemStatusElementID      
                     , _browserNotSupportedElementID
                     , _participantPublicationControlsElementID
                     , _participantStreamsElementID
                     , _participantStreamsContainerID
                     , _toggleParticipantsViewBtnID
                     , _whatIsMyPinBtnID
                     , _sendMeetingInvitesBtnID
                     , _appendSharedFilesBtnID
                     , _sessionFilesElementID
                     , _baseLink
                     , _urlGetSharedFileHtmlList
                     , _urlSaveFormWip
                     , _urlSignForm
                     , _urlGetFormSignaturesHtmlTable
                     , _urlBanUser
                     , _urlSendMeetingInvites
                     , _urlAppendFileShare
                     , Constants.PARM_ROOM_ID   
                     , Constants.PARM_ROOM_PART_UID
                     , Constants.PARM_ROOM_PART_PIN
                     , MBA.Util.netBoolToJSBool(_facilitatorRequiredInRoom)
                     , MBA.Util.netBoolToJSBool(_tsp.participantIsFacilitator)
                     , MBA.Util.netBoolToJSBool(_tsp.facilitatorIsPresent)
                     );
    
      }

      else 
      {
      
      }

      writer.Write(@"})");
      writer.Write(@"</script>");
      
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