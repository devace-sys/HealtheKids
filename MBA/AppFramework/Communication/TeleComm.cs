using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Mail;
using System.IO;
using System.Data;
using System.Data.SqlClient;
using System.Web;

using Geo;

namespace MBA
{  

  public class TeleCommSessionRsvpInfo
  {
    public TeleCommSessionRsvpInfo ()
    {
    }

    public bool     retrieveInfoIsOK = false;
    public string   roomTitle;

    public string   participantsHtmlTbl;
    public string   formInviteText;
    public int      numMinutes;
    public DateTime startTime;
    public DateTime endTime;

    public bool?     inviteRsvpWillAttend;

    //public DateTime inviteRsvpAlternateDatetimeRequested;

    public string   inviteRsvpNotes;

    public string   clientName;
    public string   participantName;
    public string   patName;
    public long?     patId;

    public bool     sessionOK;
    public long     sessionID;
  
  }

  /***************************************************************************
   * TeleCommRenderWhatRoom */
  /**
   * 
   * 
   ****************************************************************************/

  public enum TeleCommRenderWhatRoom
  {
      OUTSIDE_ROOM
    , WAITING_ROOM
    , INSIDE_ROOM
    , RSVP_FORM
  }


  /***************************************************************************
   * TeleCommSessionParticipant */
  /**
   * Who is logged into the session
   * 
   ****************************************************************************/

  public class TeleCommSessionParticipant
  {
    public TeleCommSessionParticipant ()
    {
    }
    
    public bool     allRequiredParticipantParametersPassed = false;

    public string   roomID                   = "";    
    public string   participantEmail         = "";
    public string   participantPIN           = "";

    public string     inviteRsvpWillAttend;
                                           
    public string   inviteRsvpToken;
    public DateTime inviteRsvpAlternateDatetimeRequested;
    public string   inviteRsvpNotes;

    public string   inviteRsvpReqResp;

    public string   roomEnterExit            = "";
    public bool     sessionOK                = false;
    public long     sessionID                = -1;
    public string   serverSessionID          = "";
    public string   roomTitle                = "";
    public string   roomContent              = "";
    public string   roomFormHTML             = "";
    public string   roomFormJSON             = @"{}";
    public string   fileShareContent         = "";
    public long     participantID            = -1;
    public string   participantName          = "";
    public string   participantTitle         = "";  
    public long     participantUserID        = -1;
    public long     participantRoleID        = -1;
    public long     participantEntityID      = -1;
    public bool     participantIsFacilitator = false;
    public bool     facilitatorIsPresent     = false;
    public DateTime today;
    public DateTime meetingStartDate;
    public DateTime meetingEndDate;
    public string   meetingStartTime24HrStr   = "";
    public int      meetingDurationInMins     = -1;
    public string   sessionData               = "";
    public string   participantConnectionData = "";    
    public long     clientID                  = -1;
    public string   clientName                = "";
    public string   latestRoomFormDataJSONRecorded = "";
    public bool     joinSessionFailed        = false;
    public string   sessionStatusMessage     = "";

    public TeleCommRenderWhatRoom renderWhatRoom = TeleCommRenderWhatRoom.OUTSIDE_ROOM;
   
   public override string ToString()
    {
      return TeleCommSessionParticipant.ToJSONString(this);
      //return base.ToString();
    }
    public static String ToJSONString (TeleCommSessionParticipant value)
    {
      return MBA.JSON.toJSONString(value,JsonLibrary.NEWTONSOFT);
    }
    public static TeleCommSessionParticipant FromJSONString (string value)
    {    
      return (TeleCommSessionParticipant) MBA.JSON.fromJSONString(value,typeof(TeleCommSessionParticipant),JsonLibrary.NEWTONSOFT);
    }
  }
  
  /***************************************************************************
   * TelecommSessionSignFormSignalData */
  /**
   * 
   * 
   ****************************************************************************/

  public class TelecommSessionSignFormSignalData 
  {
    public TelecommSessionSignFormSignalData(){}
    public TelecommSessionSignFormSignalData(TelecommSessionSignFormReturnData rd)
    {
      this.sigForFormID            = rd.sigForFormID;
      this.sigControlID            = rd.sigControlID;
      this.sigClassName            = rd.sigClassName;
      this.sigAdditionalData       = rd.sigAdditionalData;
      this.ctrlAdditionalDataID    = rd.ctrlAdditionalDataID;
    }

    public string sigForFormID            = "";
    public string sigControlID            = "";
    public string sigClassName            = "";
    public string sigAdditionalData       = "";
    public string ctrlAdditionalDataID    = "";

    public static String ToJSONString (TelecommSessionSignFormSignalData value)
    {
      return MBA.JSON.toJSONString(value,JsonLibrary.NEWTONSOFT);
    }
  }

  /***************************************************************************
   * TelecommSessionSignFormReturnData */
  /**
   * 
   * 
   ****************************************************************************/
  public class TelecommSessionSignFormReturnData : TelecommSessionSignFormSignalData 
  {
    /* Note: We dont want to return this value to the client so its defined here */
    public string teleCommServerSessionID = "";
  }

  /***************************************************************************
   * TeleCommSessionParticipants */
  /**
   * 
   * 
   ****************************************************************************/

  public class TeleCommSessionParticipants:Entities
  {        
    
    public static string SESSION_JOIN                        = "j";
    public static string SESSION_LEAVE                       = "l";
    public static string URL_SAVE_FORM_WIP                   = @"telecomm.asmx/saveformwipdata";
    public static string URL_SIGN_FORM                       = @"telecomm.asmx/signform";
    public static string URL_GET_FORM_SIGNATURES_HTML_TABLE  = @"telecomm.asmx/getformsignatureshtmltable";
    public static string URL_GET_SHARED_FILE_HTML_LIST       = @"telecomm.asmx/getsharedfilehtmllist";
    public static string URL_BAN_USER                        = @"telecomm.asmx/banuser";
    public static string URL_RSVP_FORM                       = @"telecomm_invite_rsvp.aspx";
    public static string SESSION_RSVP_REQ                    = "req";
    public static string SESSION_RSVP_RSP                    = "rsp";

    public static void validateAndAddCommonParticipantParms  (  string          roomID
                                                               , string          participantEmail
                                                               , RequestResponse rr
                                                               , ref List<SqlParameter> parms
                                                             )
    {
      var vRoomID   = Validate.reqString (roomID,             @"Room number is required");
      var vEmail    = Validate.reqEmail  (participantEmail,   @"Participant email is required");
          
      parms.Add(Database.SqlParm("@roomID",    SqlDbType.VarChar,  vRoomID,      ParameterDirection.Input,256));
      parms.Add(Database.SqlParm("@email",     SqlDbType.VarChar,  vEmail,       ParameterDirection.Input,256));
      parms.Add(Database.SqlParm("@userIP",    SqlDbType.VarChar,  rr.userIP,    ParameterDirection.Input, 500));
      parms.Add(Database.SqlParm("@userAgent", SqlDbType.VarChar,  rr.userAgent, ParameterDirection.Input, 8000));
    
    }

    /***************************************************************************
     * validateAndAddCommonSessionParticipantParms */
    /**
     * Validates common parameters used to identify a unique participant
     * 
     ****************************************************************************/

    public static void validateAndAddCommonSessionParticipantParms  (  string          roomID
                                                                     , string          participantEmail
                                                                     , string          participantPIN
                                                                     , RequestResponse rr
                                                                     , ref List<SqlParameter> parms
                                                                    ) 
    {
      validateAndAddCommonParticipantParms(roomID,participantEmail,rr,ref parms);
  
      var vPIN      = Validate.reqString (participantPIN,     @"Participant PIN is required");     
          
      parms.Add(Database.SqlParm("@pin",       SqlDbType.VarChar,  vPIN,         ParameterDirection.Input,50));     
    
    }

    //TODO: use this is the rsvp "flag" save method... also rename the "flag" method in database in middleware
    public static void validateAndAddCommonSessionRSVPParms  (  string          roomID
                                                                     , string          participantEmail
                                                                     , string          rsvpToken
                                                                     , RequestResponse rr
                                                                     , ref List<SqlParameter> parms
                                                                    )
    {

      validateAndAddCommonParticipantParms(roomID,participantEmail,rr,ref parms);  
      var vRsvpToken      = Validate.reqString (rsvpToken,     @"RSVP token is required");             
      parms.Add(Database.SqlParm("@inviteRsvpToken",       SqlDbType.VarChar,  vRsvpToken,         ParameterDirection.Input,50));     
    
    }
    
    /***************************************************************************
     * validateAndAddCommonSaveSessionFormDataParms */
    /**
     * Validates common parameters used to identify a unique participant and save
     * form data
     ****************************************************************************/

    public static void validateAndAddCommonSaveSessionFormDataParms (  string                 roomID
                                                                     , string                 participantEmail
                                                                     , string                 participantPIN
                                                                     , RequestResponse        rr
                                                                     , string                 formID
                                                                     , string                 formData
                                                                     , ref List<SqlParameter> parms
                                                                    )
    {
      
      validateAndAddCommonSessionParticipantParms (roomID, participantEmail, participantPIN, rr, ref parms); 
  
      var vFormID   = Validate.reqString (formID,     @"Form ID is required");
      var vFormData = Validate.reqString (formData,   @"Form data is required");
            
      parms.Add(Database.SqlParm("@formID",    SqlDbType.VarChar,    vFormID,      ParameterDirection.Input,256));
      parms.Add(Database.SqlParm("@formData",  SqlDbType.VarChar,    vFormData,    ParameterDirection.Input, -1));
      
    }

   /***************************************************************************
     * getInfoForRsvp */
    /**
     * Get info needed to display in RSVP room for participant
     *
     ****************************************************************************/
 
    public static TeleCommSessionRsvpInfo getInfoForRsvp (   SqlConnection    connUsers
                                          , DetailsLog      log                                     
                                          , UserInfo        uInfo
                                          , RequestResponse rr          
                                          , string          appName
                                          , string roomID
                                          , string participantEmail           
                                          , string rsvpToken
                                      )
    {
   
      TeleCommSessionRsvpInfo so = new TeleCommSessionRsvpInfo();

      /*
      if (uInfo == null) {    
        uInfo = new UserInfo();
        uInfo.userid    = 0;
        uInfo.userGroup = 0;
        uInfo.userRank  = 0;
      }
      */

      List<SqlParameter> parms  = new List<SqlParameter>();
        
      try
      {
   
          validateAndAddCommonSessionRSVPParms(
          roomID, participantEmail, rsvpToken,
          rr,          ref parms
          );
 
       /*============================================================
        * Validate datatypes of remaining parameters
        *============================================================*/ 
  
       var vAppName           = Validate.reqString (appName, "App name is required");     
 
             
 
       /*============================================================
        * Setup remaining sproc parameters and pass in values
        *============================================================*/ 
      
        //parms.Add(Database.SqlParm("@appName",            SqlDbType.VarChar,    vAppName,     ParameterDirection.Input,50));
 
       /* Add the following as output paramers */
      //, @willAttendSession  bit
      //, @altDateRequested   date
      //, @rsvpNotes          varchar(512)

        parms.Add(Database.SqlParm("@roomTitle", SqlDbType.VarChar, null, ParameterDirection.Output, 512));
        parms.Add(Database.SqlParm("@inviteRsvpWillAttend", SqlDbType.Bit, null, ParameterDirection.Output));
        parms.Add(Database.SqlParm("@inviteRsvpNotes",      SqlDbType.VarChar, null, ParameterDirection.Output, 512));

        parms.Add(Database.SqlParm("@participantsHtmlTbl",   SqlDbType.VarChar, null, ParameterDirection.Output, -1));
        // don't recall what varchar(max) is, but -1 is syntactic sugar for that

        parms.Add(Database.SqlParm("@formInviteText",   SqlDbType.VarChar, null, ParameterDirection.Output, -1));
        parms.Add(Database.SqlParm("@numMinutes",   SqlDbType.Int, null, ParameterDirection.Output));
        parms.Add(Database.SqlParm("@startTime",   SqlDbType.DateTime, null, ParameterDirection.Output));
        parms.Add(Database.SqlParm("@endTime",   SqlDbType.DateTime, null, ParameterDirection.Output));

        parms.Add(Database.SqlParm("@clientName",          SqlDbType.VarChar, null, ParameterDirection.Output, 1000));
        parms.Add(Database.SqlParm("@participantName",     SqlDbType.VarChar, null, ParameterDirection.Output, 256));
        parms.Add(Database.SqlParm("@patId",     SqlDbType.BigInt, null, ParameterDirection.Output));
        parms.Add(Database.SqlParm("@patName",     SqlDbType.VarChar, null, ParameterDirection.Output, 256));

        parms.Add(Database.SqlParm("@sessionOK",     SqlDbType.Bit, null, ParameterDirection.Output));
        parms.Add(Database.SqlParm("@sessionID",     SqlDbType.BigInt, null, ParameterDirection.Output));


      }
      catch (Exception ve)
      {
        so.retrieveInfoIsOK = false;
        return so;
      }
     
      /*============================================================
       * Call sproc
       *============================================================*/ 
 
      var sp = @"TELECOMM_SESSION_GET_INFO_FOR_RSVP";
      ReturnDB rd;
      try
      {
        rd = Database.execSproc(connUsers,log,sp,parms);
      }
      catch (Exception e)
      {
        so.retrieveInfoIsOK = false;
        return so;
      }
    
      so.retrieveInfoIsOK          = true;
      so.roomTitle                 = (String)   Database.getParameterValue("roomTitle",                ref parms);
      //so.rsvpMessageHtml         = (String)   Database.getParameterValue("rsvpMessageHtml",          ref parms);
      so.inviteRsvpWillAttend      = (bool?)      Database.getParameterValue("inviteRsvpWillAttend",    ref parms);
      //so.altDateRequested        = (DateTime)     Database.getParameterValue("altDateRequested",     ref parms);
      so.inviteRsvpNotes           = (string)   Database.getParameterValue("inviteRsvpNotes",          ref parms);

      so.participantsHtmlTbl       = (string)   Database.getParameterValue("participantsHtmlTbl",    ref parms);
      so.formInviteText            = (string)   Database.getParameterValue("formInviteText",         ref parms);
      so.numMinutes                = (int)   Database.getParameterValue("numMinutes",                ref parms);
      so.startTime                 = (DateTime)   Database.getParameterValue("startTime",            ref parms);
      so.endTime                   = (DateTime)   Database.getParameterValue("endTime",              ref parms);

      so.clientName                = (string)   Database.getParameterValue("clientName",           ref parms);
      so.participantName           = (string)   Database.getParameterValue("participantName",      ref parms);
      so.patId                     = (long?)     Database.getParameterValue("patId",                ref parms);
      so.patName                   = (string)   Database.getParameterValue("patName",              ref parms);

      so.sessionOK                 = (bool)     Database.getParameterValue("sessionOK",                ref parms);
      so.sessionID                 = (long)   Database.getParameterValue("sessionID",              ref parms);


      return so;
 
    }


    /***************************************************************************
     * getServerActiveConfig */
    /**
     * Get active config data for server
     * 
     ****************************************************************************/
    public static string getServerActiveConfig () {
     
      var dataJSON = @"{}";

      Geo.OpenVidu.Server.GetActiveConfig (  Constants.OPEN_VIDU_SERVER
                                           , Constants.OPEN_VIDU_USER_NAME
                                           , Constants.OPEN_VIDU_PASSWORD
                                           , out dataJSON );
      return dataJSON;

    }


    /***************************************************************************
     * getSessions */
    /**
     * Get all active sessions
     * 
     ****************************************************************************/
    public static string getSessions () {
     
      var sessionsJSON = @"{}";

      Geo.OpenVidu.Sessions.GetSessions (   Constants.OPEN_VIDU_SERVER
                                           , Constants.OPEN_VIDU_USER_NAME
                                           , Constants.OPEN_VIDU_PASSWORD
                                           , out sessionsJSON
                                        );
     return sessionsJSON;

    }
    
    /***************************************************************************
     * joinSession */
    /**
     * Log into a session
     * 
     ****************************************************************************/
    public static void joinSession (   SqlConnection    connUsers
                                      , DetailsLog      log                                      
                                      , UserInfo        uInfo
                                      , RequestResponse rr
                                      , string          appName
                                      , ref TeleCommSessionParticipant ts )
    {
    
      if (uInfo == null) {     
        uInfo = new UserInfo();
        uInfo.userid    = 0;
        uInfo.userGroup = 0;
        uInfo.userRank  = 0;
      }
     
      List<SqlParameter> parms  = new List<SqlParameter>();
      
      /*============================================================
       * Validate datatypes of parameters
       *============================================================*/  

      ts.sessionOK         = false;
      ts.joinSessionFailed = false;

      var vAppName = Validate.reqString (appName, @"App name is required");
      
      try
      { 
        validateAndAddCommonSessionParticipantParms (ts.roomID, ts.participantEmail, ts.participantPIN, rr, ref parms); 
      }
      catch (Exception ve)
      {
        ts.sessionOK            = false;
        ts.joinSessionFailed    = true;
        ts.sessionStatusMessage = ve.Message;
        return;
      }
      
      /*============================================================
       * If we reach this point the parameters passed in are valid
       * datatypes.
       *============================================================*/  
      
      ts.sessionOK         = false;
      ts.joinSessionFailed = false;

      /*============================================================
       * Setup remaining sproc parameters and pass in values
       *============================================================*/  
  
      /*----------------------------
       * Input parameters
       *----------------------------*/  

      parms.Add(Database.SqlParm("@appName",            SqlDbType.VarChar,    vAppName,     ParameterDirection.Input,50));
      
      /*----------------------------
       * Output parameters
       *----------------------------*/  

      parms.Add(Database.SqlParm("@sessionOK",                SqlDbType.Bit,        false, ParameterDirection.Output));
      parms.Add(Database.SqlParm("@sessionID",                SqlDbType.BigInt,     -1,    ParameterDirection.Output));
      parms.Add(Database.SqlParm("@serverSessionID",          SqlDbType.VarChar,    "",    ParameterDirection.Output,256));
      parms.Add(Database.SqlParm("@roomTitle",                SqlDbType.VarChar,    "",    ParameterDirection.Output,512));
      parms.Add(Database.SqlParm("@roomContent",              SqlDbType.NVarChar,   "",    ParameterDirection.Output,-1));
      parms.Add(Database.SqlParm("@roomFormHTML",             SqlDbType.NVarChar,   "",    ParameterDirection.Output,-1));
      parms.Add(Database.SqlParm("@roomFormJSON",             SqlDbType.NVarChar,   "",    ParameterDirection.Output,-1));
      parms.Add(Database.SqlParm("@participantID",            SqlDbType.BigInt,     -1,    ParameterDirection.Output));
      parms.Add(Database.SqlParm("@participantName",          SqlDbType.VarChar,    "",    ParameterDirection.Output,256));
      parms.Add(Database.SqlParm("@participantTitle",         SqlDbType.VarChar,    "",    ParameterDirection.Output,256));
      parms.Add(Database.SqlParm("@participantUserID",        SqlDbType.BigInt,     -1,    ParameterDirection.Output));
      parms.Add(Database.SqlParm("@participantRoleID",        SqlDbType.BigInt,     -1,    ParameterDirection.Output));
      parms.Add(Database.SqlParm("@participantEntityID",      SqlDbType.BigInt,     -1,    ParameterDirection.Output));
      parms.Add(Database.SqlParm("@participantIsFacilitator", SqlDbType.Bit,        false, ParameterDirection.Output));
      parms.Add(Database.SqlParm("@facilitatorIsPresent",     SqlDbType.Bit,        false, ParameterDirection.Output));
      parms.Add(Database.SqlParm("@today",                    SqlDbType.DateTime,   null,  ParameterDirection.Output));
      parms.Add(Database.SqlParm("@meetingStartDate",         SqlDbType.DateTime,   null,  ParameterDirection.Output));
      parms.Add(Database.SqlParm("@meetingEndDate",           SqlDbType.DateTime,   null,  ParameterDirection.Output));
      parms.Add(Database.SqlParm("@meetingDurationInMins",    SqlDbType.Int,        null,  ParameterDirection.Output));
      parms.Add(Database.SqlParm("@clientID",                 SqlDbType.BigInt,     -1,    ParameterDirection.Output));
      parms.Add(Database.SqlParm("@clientName",               SqlDbType.VarChar,    "",    ParameterDirection.Output,1000));
      parms.Add(Database.SqlParm("@latestRoomFormDataJSONRecorded",  SqlDbType.VarChar,    "",    ParameterDirection.Output,-1));
      
      /*============================================================
       * Call sproc
       *============================================================*/  

      var sp = @"TELECOMM_SESSION_JOIN";
      ReturnDB rd;
      try
      { 
        rd = Database.execSproc(connUsers,log,sp,parms);
      }
      catch (Exception je)
      {
        ts.sessionOK            = false;
        ts.joinSessionFailed    = true;
        ts.sessionStatusMessage = je.Message;
        return;
      }

      /*============================================================
       * If we reach this point the sproc call returned OK.
       * Extract one parameter (sessionOK) so we can see if
       * the user turned out to be valid, if not exit.
       *============================================================*/  

      ts.sessionOK = (bool) Database.getParameterValue("sessionOK", ref parms);

      if (!ts.sessionOK)       
      { 
        ts.joinSessionFailed = true;
        return;
      }

      /*============================================================
       * If we reach this point user is valid so extract the 
       * rest of the output parameters.
       *============================================================*/  
      
      ts.joinSessionFailed = false;

      ts.sessionID                = (long)     Database.getParameterValue("sessionID",                ref parms);
      ts.serverSessionID          = (String)   Database.getParameterValue("serverSessionID",          ref parms);
      ts.roomTitle                = (String)   Database.getParameterValue("roomTitle",                ref parms);
      ts.roomContent              = (String)   Database.getParameterValue("roomContent",              ref parms);
      ts.roomFormHTML             = (String)   Database.getParameterValue("roomFormHTML",             ref parms);
      ts.roomFormJSON             = (String)   Database.getParameterValue("roomFormJSON",             ref parms);
      ts.participantID            = (long)     Database.getParameterValue("participantID",            ref parms);
      ts.participantName          = (String)   Database.getParameterValue("participantName",          ref parms);
      ts.participantTitle         = (String)   Database.getParameterValue("participantTitle",         ref parms);
      ts.participantUserID        = (long)     Database.getParameterValue("participantUserID",        ref parms);
      ts.participantRoleID        = (long)     Database.getParameterValue("participantRoleID",        ref parms);
      ts.participantEntityID      = (long)     Database.getParameterValue("participantEntityID",      ref parms);
      ts.participantIsFacilitator = (bool)     Database.getParameterValue("participantIsFacilitator", ref parms);
      ts.facilitatorIsPresent     = (bool)     Database.getParameterValue("facilitatorIsPresent",     ref parms);
      ts.today                    = (DateTime) Database.getParameterValue("today",                    ref parms);
      ts.meetingStartDate         = (DateTime) Database.getParameterValue("meetingStartDate",         ref parms);
      ts.meetingEndDate           = (DateTime) Database.getParameterValue("meetingEndDate",           ref parms);
      ts.meetingDurationInMins    = (int)      Database.getParameterValue("meetingDurationInMins",    ref parms);
      ts.clientID                 = (long)     Database.getParameterValue("clientID",                 ref parms);
      ts.clientName               = (String)   Database.getParameterValue("clientName",               ref parms);
      
      ts.latestRoomFormDataJSONRecorded = (String) Database.getParameterValue("latestRoomFormDataJSONRecorded", ref parms);

      /*============================================================
       * Get start time in 24 hr format
       *============================================================*/  

      ts.meetingStartTime24HrStr = ts.meetingStartDate.ToString("HH:mm");

      /*============================================================
       * Create or get existing OpenVIDU session
       *============================================================*/  

      Geo.OpenVidu.Sessions.CreateSession (  Constants.OPEN_VIDU_SERVER
                                           , Constants.OPEN_VIDU_USER_NAME
                                           , Constants.OPEN_VIDU_PASSWORD
                                           , ts.serverSessionID
                                           , out ts.sessionData);
        
      /*============================================================
       * Create OpenVidu connection for user (includes token)
       *============================================================*/  

      Geo.OpenVidu.Connections.CreateConnectionForUser (   Constants.OPEN_VIDU_SERVER
                                                         , Constants.OPEN_VIDU_USER_NAME
                                                         , Constants.OPEN_VIDU_PASSWORD
                                                         , ts.serverSessionID
                                                         , ts.participantName
                                                         , ts.participantIsFacilitator
                                                         , out ts.participantConnectionData);
      
      /*============================================================
        * Get file shares
        *============================================================*/  
                                        
      ts.fileShareContent = TeleCommSessionFileShares.generateSharedFileContent (  connUsers
                                                                                 , log
                                                                                 , uInfo
                                                                                 , appName
                                                                                 , ref ts); 
                                  
      /*============================================================
        * If the participant is a faciliator send a signal that
        * they have entered the room.
        *============================================================*/  
      
      if (ts.participantIsFacilitator == true)
      {
        sendSignalFacilitatorEnteredRoom(ts.serverSessionID);
      }

      return;
    
    }  
    
    /***************************************************************************
     * leaveSession */
    /**
     * Used by 
     * 
     ****************************************************************************/

    public static void leaveSession (string roomID, string participantUID, string participantPIN)
    {
      // Lookup session data, log particpant exit 
    }

    /***************************************************************************
     * sendSignalRefreshFileShares */
    /**
     * Requests al participant client side code to refresh their file lists
     * NOTE: This is for end point internal use only
     ****************************************************************************/    

    public static bool sendSignalRefreshFileShares (string serverSessionID, string why)
    {
      var signal = new Geo.OpenVidu.Signal (serverSessionID,"refresh_file_shares",why);
      var response = "";
      var retState = Geo.OpenVidu.Signals.Send (  Constants.OPEN_VIDU_SERVER
                                                , Constants.OPEN_VIDU_USER_NAME
                                                , Constants.OPEN_VIDU_PASSWORD
                                                , signal
                                                , out response);
      return retState;                        
    }

    /***************************************************************************
     * sendSignalFormSigned */
    /**
     * Requests all participant client side code to refresh form  signed data
     * NOTE: This is for end point internal use only
     ****************************************************************************/    

    public static bool sendSignalFormSigned (string serverSessionID, TelecommSessionSignFormSignalData signalDataObj)
    {
      var signalDataJson = TelecommSessionSignFormSignalData.ToJSONString(signalDataObj);
      var signal         = new Geo.OpenVidu.Signal (serverSessionID,"form_signed",signalDataJson);
      var response       = "";

      var retState = Geo.OpenVidu.Signals.Send (  Constants.OPEN_VIDU_SERVER
                                                , Constants.OPEN_VIDU_USER_NAME
                                                , Constants.OPEN_VIDU_PASSWORD
                                                , signal
                                                , out response);
      return retState;                        
    }

    /***************************************************************************
     * sendSignalFacilitatorEnteredRoom */
    /**
     * Sends a signal for when a facilitator enteres a session
     ****************************************************************************/    
 
    public static bool sendSignalFacilitatorEnteredRoom (string serverSessionID)
    {
      var signal         = new Geo.OpenVidu.Signal (serverSessionID, "facilitator_entered_room", null);
      var response       = "";
 
      var retState = Geo.OpenVidu.Signals.Send (  Constants.OPEN_VIDU_SERVER
                                                , Constants.OPEN_VIDU_USER_NAME
                                                , Constants.OPEN_VIDU_PASSWORD
                                                , signal
                                                , out response);
      return retState;                        
    }
 
    /***************************************************************************
     * saveFormWipData */
    /**
     * Saves work in progress data
     * This is a "dirty" save. 
     ****************************************************************************/    
    public static ReturnSaveRecord saveFormWipData (  SqlConnection connUsers
                                                    , DetailsLog      log
                                                    , UserInfo        uInfo
                                                    , RequestResponse rr
                                                    , string          roomID
                                                    , string          participantEmail
                                                    , string          participantPIN
                                                    , string          formID
                                                    , string          formData )
    {           
      var so = new ReturnSaveRecord();
      
      if (uInfo == null) {     
        uInfo = new UserInfo();
        uInfo.userid    = 0;
        uInfo.userGroup = 0;
        uInfo.userRank  = 0;
      }

      List<SqlParameter> parms = new List<SqlParameter>();     
      
      validateAndAddCommonSaveSessionFormDataParms ( roomID, participantEmail, participantPIN, rr, formID, formData, ref parms);

      so = Entities.save (  connUsers
                          , log
                          , uInfo
                          , "1"
                          , "0"
                          , ""
                          , ""
                          , "TELECOMM_SESSION_SAVE_FORM_WIP_DATA"
                          , "Form data already saved"
                          , ref parms
                          , null);
      
      return so;
      
    }
  

    /***************************************************************************
     * signForm */
    /**
     * Signs form.  This is a final operation.
     ****************************************************************************/    
    public static ReturnSaveRecord signForm (   SqlConnection connUsers
                                              , DetailsLog    log
                                              , UserInfo      uInfo
                                              , RequestResponse rr
                                              , string        roomID
                                              , string        participantEmail
                                              , string        participantPIN
                                              , string        sigForFormID
                                              , string        sigControlID
                                              , string        sigClassName
                                              , string        fieldNameSign
                                              , string        sigAdditonalData
                                              , string        ctrlAdditionalDataID
                                              , string        shareDataWhenSigned)
    {           


      var so = new ReturnSaveRecord();
      
      if (uInfo == null) {     
        uInfo = new UserInfo();
        uInfo.userid    = 0;
        uInfo.userGroup = 0;
        uInfo.userRank  = 0;
      }

      List<SqlParameter> parms = new List<SqlParameter>();     
      
      validateAndAddCommonSessionParticipantParms (roomID, participantEmail, participantPIN, rr, ref parms); 
              
      var vSigForFormID         = Validate.optString (sigForFormID,         @"Form ID is invalid");
      var vSigControlID         = Validate.reqString (sigControlID,         @"Signature control id is required");
      var vSigClassName         = Validate.reqString (sigClassName,         @"Signature class name is required");
      var vFieldNameSign        = Validate.reqString (fieldNameSign,        @"Signature control field name is required");
      var vSigAdditionalData    = Validate.reqString (sigAdditonalData,     @"Invalid data");
      var vCtrlAdditionalDataID = Validate.reqString (ctrlAdditionalDataID, @"Invalid signature form id");
      var vShareDataWhenSigned  = Validate.reqFlag   (shareDataWhenSigned,  @"Invalid share data flag value");

      parms.Add(Database.SqlParm("@sigForFormID",         SqlDbType.VarChar,  vSigForFormID,          ParameterDirection.Input,256));
      parms.Add(Database.SqlParm("@sigControlID",         SqlDbType.VarChar,  vSigControlID,          ParameterDirection.Input,256));
      parms.Add(Database.SqlParm("@sigClassName",         SqlDbType.VarChar,  vSigClassName,          ParameterDirection.Input,512));
      parms.Add(Database.SqlParm("@sigAdditionalData",    SqlDbType.VarChar,  vSigAdditionalData,     ParameterDirection.Input,-1));
      parms.Add(Database.SqlParm("@ctrlAdditionalDataID", SqlDbType.VarChar,  vCtrlAdditionalDataID,  ParameterDirection.Input,256));
     
      ReturnSaveRecordWithJSONData ssf = Entities.saveAndReturnJSONData (  connUsers
                                                                         , log
                                                                         , uInfo
                                                                         , "1"
                                                                         , "0"
                                                                         , ""
                                                                         , ""
                                                                         , "TELECOMM_SESSION_SIGN_FORM"
                                                                         , "Form already signed by this participant"
                                                                         , ref parms
                                                                         , null);
      
     if ((ssf.status == Return.RET_SUCCESS)) {       
       TelecommSessionSignFormReturnData sfrd  = (TelecommSessionSignFormReturnData) JSON.fromJSONString(ssf.jsonData,typeof(TelecommSessionSignFormReturnData),JsonLibrary.NEWTONSOFT);
       TelecommSessionSignFormSignalData sfsd  = new TelecommSessionSignFormSignalData(sfrd);       
       if (vShareDataWhenSigned) sendSignalFormSigned (sfrd.teleCommServerSessionID, sfsd);                          
       so = ssf;
     }
     
     return so;
      
    }

    

    /***************************************************************************
     * validateUser */
    /**
     * 
     * 
     ****************************************************************************/    
    public static void validateUser (  SqlConnection   connUsers
                                     , DetailsLog      log
                                     , UserInfo        uInfo
                                     , RequestResponse rr
                                     , string          roomID
                                     , string          participantEmail
                                     , string          participantPIN
                                     , string          action
                                     , ref TeleCommSessionParticipant ts )
    {
      
      List<SqlParameter> parms  = new List<SqlParameter>();
      ts.sessionOK = false; 
      
      /*============================================================
       * Validate and add common session participant parameters
       *============================================================*/  

      validateAndAddCommonSessionParticipantParms (roomID, participantEmail, participantPIN, rr, ref parms); 

      ts.roomID           = roomID;
      ts.participantEmail = participantEmail;
      ts.participantPIN   = participantPIN;
      
      /*============================================================
       * Add additional parameters
       *============================================================*/  

      parms.Add(Database.SqlParm("@action", SqlDbType.VarChar, action, ParameterDirection.Input,255));
      
      /*============================================================
       * Add output parameters
       *============================================================*/  

      parms.Add(Database.SqlParm("@sessionOK",                SqlDbType.Bit,        false, ParameterDirection.Output));
      parms.Add(Database.SqlParm("@sessionID",                SqlDbType.BigInt,     -1,    ParameterDirection.Output));
      parms.Add(Database.SqlParm("@participantClientID",      SqlDbType.BigInt,     -1,    ParameterDirection.Output));
      parms.Add(Database.SqlParm("@participantID",            SqlDbType.BigInt,     -1,    ParameterDirection.Output));
      parms.Add(Database.SqlParm("@isSessionFacilitator",     SqlDbType.Bit,        false, ParameterDirection.Output));
      
      /*============================================================
       * Call sproc
       *============================================================*/  

      var sp = @"TELECOMM_SESSION_VALIDATE";
      ReturnDB rd = Database.execSproc(connUsers,log,sp,parms);
      
      /*============================================================
       * If we reach this point the sproc call returned OK.
       * Extract one parameter (sessionOK) so we can see if
       * the user turned out to be valid, if not exit.
       *============================================================*/  

      ts.sessionOK = (bool) Database.getParameterValue("sessionOK", ref parms);
      if (!ts.sessionOK) return;
      
      /*============================================================
       * If we reach this point user is valid so extract the 
       * rest of the output parameters.
       *============================================================*/  

      ts.sessionID                = (long)  Database.getParameterValue("sessionID",              ref parms);
      ts.clientID                 = (long)  Database.getParameterValue("participantClientID",    ref parms);
      ts.participantID            = (long)  Database.getParameterValue("participantID",          ref parms);
      ts.participantIsFacilitator = (bool)  Database.getParameterValue("isSessionFacilitator",   ref parms);    
    
     return;
  }

  /***************************************************************************
   * getSharedFileHTMLList */
  /**
   * Generate the HTML list for shared files.  This is used in the web methods.
   * 
   ****************************************************************************/    
  public static ReturnHTMLContent getSharedFileHTMLList (  SqlConnection   connUsers
                                                         , DetailsLog      log
                                                         , UserInfo        uInfo
                                                         , RequestResponse rr
                                                         , string          roomID
                                                         , string          participantEmail
                                                         , string          participantPIN )
    {           
      var so  = new ReturnHTMLContent();
      var tsp = new TeleCommSessionParticipant();
      
      tsp.sessionOK = false;

      if (uInfo == null) {     
        uInfo = new UserInfo();
        uInfo.userid    = 0;
        uInfo.userGroup = 0;
        uInfo.userRank  = 0;
      }     
      
      validateUser ( connUsers, log, uInfo, rr, roomID, participantEmail, participantPIN, "Get File Shares List", ref tsp);                   
      if (tsp.sessionOK == true) {so.content = TeleCommSessionFileShares.generateSharedFileContent ( connUsers, log, uInfo, @"", ref tsp); }              
      tsp.fileShareContent = so.content;      
      return so;      
    }

    /***************************************************************************
     * getFormSignaturesHtmlTable
    /**
     * Generate the HTML table that shows what participants signed
     * 
     ****************************************************************************/    
    public static ReturnHTMLContent getFormSignaturesHtmlTable (   SqlConnection connUsers
                                                                  , DetailsLog    log
                                                                  , UserInfo      uInfo
                                                                  , RequestResponse rr
                                                                  , string        roomID
                                                                  , string        participantEmail
                                                                  , string        participantPIN
                                                                  , string        signatureClassName)
    {           
      var so  = new ReturnHTMLContent();
      var tsp = new TeleCommSessionParticipant();
      
      tsp.sessionOK = false;

      if (uInfo == null) {     
        uInfo = new UserInfo();
        uInfo.userid    = 0;
        uInfo.userGroup = 0;
        uInfo.userRank  = 0;
      }     
      
      string vSignatureClassName = Validate.reqString(signatureClassName,@"Signature class name required");
      string vAction = @"Get Form Signatures - " + vSignatureClassName;
      validateUser (connUsers, log, uInfo, rr, roomID, participantEmail, participantPIN, vAction, ref tsp);                   

      if (tsp.sessionOK == true) {      
        
        List<SqlParameter> parms = new List<SqlParameter>();
        parms.Add(Database.SqlParm("@sessionID",   SqlDbType.BigInt,   tsp.sessionID, ParameterDirection.Input));  
        parms.Add(Database.SqlParm("@sigClassName", SqlDbType.VarChar,  vSignatureClassName, ParameterDirection.Input, 512));  

        string         sql  = "select * from dbo.TELECOMM_SESSION_FORM_SIGNATURES_VIEW_INFO (@sessionID,@sigClassName)";
        ReturnDB        rd  = Database.execQuery(connUsers,log,sql,false,parms);
        ReturnInfoTable rit = Database.convertReturnDBToReturnInfoTable(ref rd);
        
        so.content = ReturnInfoTable.ToHTMLTableString(ref rit,@"table table-bordered table-sm","",false,false,null);               
      }
      return so;
    }

    /***************************************************************************
     * banUser
    /**
     * Bans user
     * 
     ****************************************************************************/    
    public static ReturnSaveRecord banUser (  SqlConnection   connUsers
                                             , DetailsLog      log
                                             , UserInfo        uInfo
                                             , RequestResponse rr
                                             , string          roomID
                                             , string          participantEmail
                                             , string          participantPIN                              
                                             , string          rmpartuidtoban )
    {
        ReturnSaveRecord so = new ReturnSaveRecord();
        List<SqlParameter> parms = new List<SqlParameter>();
        validateAndAddCommonSessionParticipantParms (roomID, participantEmail, participantPIN, rr, ref parms); 

        /*============================================================
         * Add additional parameters
         *============================================================*/

        var vParticipantEmailToBan = Validate.reqEmail (rmpartuidtoban,Messages.INVALID_EMAIL);
                    
        parms.Add(Database.SqlParm("@participantEmailToBan", SqlDbType.VarChar, vParticipantEmailToBan , ParameterDirection.Input, 256));

        /*============================================================
         * Call sproc
         *============================================================*/

        var sp = @"TELECOMM_SESSION_BAN";
        try
        {
          ReturnDB rd = Database.execSproc(connUsers, log, sp, parms);          
        }
        catch (Exception e)
        {
          return so;
        }
            

        return so;
      }
  }
}
