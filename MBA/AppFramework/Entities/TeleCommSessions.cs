using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Mail;
using System.IO;
using System.Data;
using System.Data.SqlClient;

namespace MBA
{


    /***************************************************************************
     * TeleCommParticipantDetails */
    /**
     * 
     **************************************************************************/
    public class TeleCommParticipantsDetails
    {
        public List<TeleCommParticipant> participantdetails;
    }

    /***************************************************************************
     * TeleCommSession */
    /**
     * 
     ****************************************************************************/

    public class TeleCommSession : Entity
    //we're can't make this abstract because we are fetching and loading TeleCommSession objs
    //in WebUITeleCommRSVPBase.Page_Load()
    {
        public long authorizationMethodID;
        public long clientID;
        public bool hasFacilitator;
        public bool facilitatorIsParticipant;
        public string facilitatorName;
        public string facilitatorTitle;
        public string facilitatorEmail;
        public string facilitatorPhone;
        public long facilitatorUserID;
        public long facilitatorRoleID;
        public long facilitatorEntityID;
        public DateTime meetingDate;
        public TimeSpan meetingTime;
        public int meetingDurationInMins;
        public string title;
        public string content;
        public string formsHTML;
        public string formsJSON;
        public string purposeSpecificData;
        public string filesToShareUploadIds;
        public string filesToShareUploadNames;
        public string participantDetailsJSON;
        public string participantDetailsEnteredJSON;
        public string meetingDateStr;
        public string meetingTimeStr;
        public string meetingDurationInMinsStr;

    }

    /***************************************************************************
     * TelecommSessionSaveReturnData */
    /**
     * Keep in synch with the returnJSON data returned from the save method
     **************************************************************************/
    public class TelecommSessionSaveReturnData
    {
        public string roomID = @"";
        public string meetingDateTime = @"";
        public string meetingTitle = @"";
        public string meetingDate = @"";
        public string meetingTime = @"";
        public int meetingDurationInMins = 0;
        public bool hasFacilitator = false;
        public bool facilitatorIsParticipant = false;
        public string facilitatorName = @"";
        public string facilitatorTitle = @"";
        public string facilitatorEmail = @"";
        public int    purposeID = 0;
        public string roomBaseURL;
        public string inviteEmailBodyTemplateText;
        public string inviteEmailBodyTemplateHtml;
        public string serverSessionID;
        public List<TeleCommParticipant> participants;
    }

    /***************************************************************************
     * TeleCommSessions */
    /**
     * 
     ****************************************************************************/
    public abstract class TeleCommSessions : Entities
    {

        public delegate string tmpl_func(bool b1);
        public static string URL_SEND_MEETING_INVITES = @"telecomm.asmx/sendmeetinginvites";


        /***************************************************************************
         * createInviteURL */
        /**
         * 
         * 
         ****************************************************************************/
        public static string createInviteURL(string pageURL, string roomID, string uid) {

            var roomURL = MBA.HttpApplication.createLink(pageURL
                                                          , new NameValue(Constants.PARM_ROOM_ID, roomID)
                                                          , new NameValue(Constants.PARM_ROOM_PART_UID, uid)
                                                         );

            return roomURL;
        }

        /***************************************************************************
         * createRsvpRequestURL */
        /**
         *
         *
         ****************************************************************************/

        public static string createRsvpRequestURL(string roomID, string email_uid, string rsvpToken)
        {

            var reqURL = MBA.HttpApplication.createLink(TeleCommSessionParticipants.URL_RSVP_FORM
                                                          , new NameValue(Constants.PARM_ROOM_ID, roomID)
                                                          , new NameValue(Constants.PARM_ROOM_PART_RSVP_TOKEN, rsvpToken)

                                                          , new NameValue(Constants.PARM_ROOM_PART_RSVP_REQ_RSP,
                                                            TeleCommSessionParticipants.SESSION_RSVP_REQ
                                                            )

                                                          , new NameValue(Constants.PARM_ROOM_PART_UID, email_uid)
                                                          );

            return reqURL;
        }

        /*
        public static string createRsvpRequestPvtURL( string roomID, string email_uid, string rsvpToken)
        {

            var reqURL = MBA.HttpApplication.createLink(TeleCommSessionParticipants.URL_RSVP_FORM,
                                                            true //pvt
                                                          , new NameValue(Constants.PARM_ROOM_ID, roomID)
                                                          , new NameValue(Constants.PARM_ROOM_PART_RSVP_TOKEN, rsvpToken)
                                                          , new NameValue(Constants.PARM_ROOM_PART_RSVP_REQ_RSP,
                                                            "0"
                                                            //TeleCommSessionParticipants.SESSION_RSVP_REQ
                                                            ),
                                                            new NameValue(Constants.PARM_ROOM_PART_UID, email_uid)
                                                          );

            return reqURL;
        }
        */

        /***************************************************************************
         * createRsvpRequestURL */
        /**
         *
         *
         ****************************************************************************/

        /*
        public static string createRsvpResponseURL(string pageURL, string roomID, string rsvpToken)
        {

            var rspURL = MBA.HttpApplication.createLink(pageURL
                                                          , new NameValue(Constants.PARM_ROOM_ID, roomID)
                                                          , new NameValue(Constants.PARM_ROOM_PART_RSVP_TOKEN, rsvpToken)
                                                          , new NameValue(Constants.PARM_ROOM_PART_RSVP_REQ_RSP, TeleCommSessionParticipants.SESSION_RSVP_RSP)
                                                          );

            return rspURL;
        }
        */
        // idk what the idea was behind this method


        /***************************************************************************
         * createSignInURL */
        /**
         * 
         * 
         ****************************************************************************/
        public static string createSignInURL(string pageURL, string roomID, string uid, string pin)
        {

            var roomURL = MBA.HttpApplication.createLink(pageURL
                                                          , new NameValue(Constants.PARM_ROOM_ID, roomID)
                                                          , new NameValue(Constants.PARM_ROOM_PART_UID, uid)
                                                          , new NameValue(Constants.PARM_ROOM_PART_PIN, pin)
                                                          , new NameValue(Constants.PARM_ROOM_PART_ENTER_OR_EXIT, TeleCommSessionParticipants.SESSION_JOIN)
                                                          );

            return roomURL;
        }

        /***************************************************************************
         * getTelecommSessionParticipantForUserID */
        /**
         * Outputs partial data for a single meeting is user is a participant
         * 
         * @return TeleIEPSession 
         *************************************************************************/

        public static ReturnTeleCommSessionParticipant getTelecommSessionParticipantForUserID(
            SqlConnection connUser
          , DetailsLog log
          , UserInfo uInfo
          , string roomID
          , string urlTeleCommPage)
        {

            var so = new ReturnTeleCommSessionParticipant();
            so.hasRecord = false;

            string vRoomID = Validate.reqInteger(roomID, Messages.INVALID_NUMBER).ToString();

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@roomID", SqlDbType.BigInt, vRoomID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userID", SqlDbType.BigInt, uInfo.userid, ParameterDirection.Input));

            string sql = "select top 1 * from dbo.TELECOMM_SESSION_VIEW_IF_USER_IS_PARTICIPANT ( @roomID, @userID)";

            ReturnDB rd = Database.execQuery(connUser, log, sql, false, parms);

            so.hasRecord = rd.hasRecords;

            if (rd.hasRecords)
            {
                so.tsp = (TeleCommSessionParticipant)Database.convertRecord(rd.records, typeof(TeleCommSessionParticipant));
                so.directSignInUrl = createSignInURL(urlTeleCommPage, so.tsp.roomID, so.tsp.participantEmail, so.tsp.participantPIN);
            }

            return so;

        }

        /***************************************************************************
         * view */
        /**
         * View Sessions
         * 
         * @param  appName    Application name (from web.config or app.config)
         * @param  clientID   Client record id (if any)
         * @param  userName   Username
         * @param  email      User's email
         * @param  token      Security token (if any)
         * @return            ReturnDB
         ***************************************************************************/

        public static ReturnDB view(SqlConnection connUsers
                                        , DetailsLog log
                                        , UserInfo uInfo
                                        , string appName
                                        //, string roomID
                                        , long purpose
                                        , Object clientID
                                        , Object facilitatorEntityID
                                        , int recViewType
                                        , bool pagedOrTop
                                        , string idx
                                        , string canEdit
                                        , string active
                                        , defineCols dc)
        {

            string viewUDF = "dbo.TELECOMM_SESSIONS_VIEW (@userID, @userGroup, @userRank, @appName, @clientID, @purposeID, @facilitatorEntityID, @active, @recID)";
            
            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/


            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@appName", SqlDbType.VarChar, appName, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, clientID, ParameterDirection.Input));
            //parms.Add(Database.SqlParm("@roomID", SqlDbType.VarChar, roomID, ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@purposeID", SqlDbType.BigInt, purpose, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@facilitatorEntityID", SqlDbType.BigInt, facilitatorEntityID, ParameterDirection.Input));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connUsers, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        /***************************************************************************
         * sendSignalSessionInvitesSentOut */
        /**
         * Sends a signal for when meeting invites have been sent out
         ****************************************************************************/    
        public static bool sendSignalSessionInvitesSentOut(string serverSessionID)
        {
          var signal         = new Geo.OpenVidu.Signal (serverSessionID, "meeting_invites_sent_out", null);
          var response       = "";
 
          var retState = Geo.OpenVidu.Signals.Send (  Constants.OPEN_VIDU_SERVER
                                                    , Constants.OPEN_VIDU_USER_NAME
                                                    , Constants.OPEN_VIDU_PASSWORD
                                                    , signal
                                                    , out response);
          return retState;                        
        }

        /***************************************************************************
         * sendInvitesForMeeting */
        /**
         * Save 
         * 
         * @param  appName    Application name (from web.config or app.config)
         * @return            ReturnSaveRecordWithJSONData
         ***************************************************************************/
        public static ReturnSaveRecord sendInvitesForMeeting(
             SqlConnection connUsers
           , DetailsLog log
           , UserInfo uInfo
           , RequestResponse rr
           , string appName
           , string roomID
           , string participantEmail
           , string participantPIN)
        {
            // reset uInfo if it is null
            if (uInfo == null)
            {
                uInfo = new UserInfo();
                uInfo.userid = 0;
                uInfo.userGroup = 0;
                uInfo.userRank = 0;
            }

            /*----------------------------
             * Validate parameters specific
             * to this entity.save
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            string saveSproc = "TELECOMM_SESSION_GET_PARTICIPANT_INVITATION_DATA";

            Object vRoomID = Validate.reqString(roomID, @"Invalid room ID");
            Object vParticipantEmail = Validate.reqString(participantEmail, @"Invalid participant email");
            Object vParticipantPIN = Validate.reqString(participantPIN, @"Invalid participant pin");
            Object vAppName = Validate.reqString(appName, Messages.NO_APP_NAME);



            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@roomID", SqlDbType.VarChar, vRoomID, ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@email", SqlDbType.VarChar, vParticipantEmail, ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@pin", SqlDbType.VarChar, vParticipantPIN, ParameterDirection.Input, 50));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

             ReturnSaveRecordWithJSONData so = Entities.saveAndReturnJSONData(connUsers
                                                                               , log
                                                                               , uInfo
                                                                               , "1"
                                                                               , "0"
                                                                               , ""
                                                                               , null
                                                                               , saveSproc
                                                                               , @"Duplicate meeting"
                                                                               , ref parms
                                                                               , delegate () { }); ;

            /*----------------------------
             * Handle meeting invites
             *----------------------------*/
            
            if ((so.status == Return.RET_SUCCESS))
            {
                TelecommSessionSaveReturnData jsonData = (TelecommSessionSaveReturnData)JSON.fromJSONString(so.jsonData, typeof(TelecommSessionSaveReturnData), JsonLibrary.NEWTONSOFT);
                sendSessionParticipantInvites(jsonData);
                sendSignalSessionInvitesSentOut(jsonData.serverSessionID);
            }
            return so;

        }

        public static ReturnSaveRecord saveRsvpAnswer(
             SqlConnection connUsers
           , DetailsLog log
           , UserInfo uInfo

          //, RequestResponse rr          
          //, string          appName

          , string roomID            
          , string rsvpToken
          , string willAttendSession
          , string altDateRequested
          , string rsvpNotes )
        {

		    if (uInfo == null) {    
		        uInfo = new UserInfo();
		        uInfo.userid    = 0;
		        uInfo.userGroup = 0;
		        uInfo.userRank  = 0;
		      }

		    /*============================================================
		     * Validate datatypes of parameters
		     *============================================================*/ 
		  
		    //var vAppName           = Validate.reqString (appName, @"App name is required");     
		    var vRoomID            = Validate.reqString (roomID,  @"RoomID is required");
		    var vRsvpToken         = Validate.reqString (rsvpToken,  @"Token is required");
		    var vWillAttendSession = Validate.reqFlag (willAttendSession,  @"RSVP is required");
		    var vAltDateRequested  = Validate.optDate (altDateRequested,  @"Invalid date");
		    var vRSVPNotes         = Validate.optString (rsvpNotes,  @"Invalid notes");
		    

            //Object vRmtsReqID = Validate.reqInteger(tspID, "requires tspID");

            List<SqlParameter> parms = new List<SqlParameter>();

            //Object vAnswer = Validate.reqFlag(answer, @"requires yes or no answer");

            parms.Add(
              Database.SqlParm("@roomID", SqlDbType.VarChar, vRoomID, ParameterDirection.Input, 256));

            parms.Add(
              Database.SqlParm("@inviteRsvpWillAttend", SqlDbType.Bit, vWillAttendSession, ParameterDirection.Input));

            parms.Add(
              Database.SqlParm("@inviteRsvpToken", SqlDbType.NVarChar, vRsvpToken, ParameterDirection.Input, 128));

            parms.Add(
              Database.SqlParm("@inviteRsvpAlternateDatetimeRequested", SqlDbType.DateTime, vAltDateRequested, ParameterDirection.Input));

            parms.Add(
              Database.SqlParm("@inviteRsvpNotes", SqlDbType.VarChar, vRSVPNotes, ParameterDirection.Input, 512));
            try
            {
                return Entities.save(connUsers
                                    , log
                                    , uInfo
                                    , "1" // saveType
                                    , @"N"
                                    , @""
                                    , "1" //recID; ignored
                                    , "TELECOMM_RSVP_SAVE_FLAG"
                                    , Messages.DUP_SVC_REC
                                    , ref parms,
                  delegate ()
                  { });
            } catch (Exception e)
            {
                return new MBA.ReturnSaveRecord(e);
            }

        }

        /***************************************************************************
         * sendSessionParticipantInvites */
        /**
         * sendSessionParticipantInvites 
         * 
         * @param  appName    Application name (from web.config or app.config)
         * @return            ReturnSaveRecordWithJSONData
         ***************************************************************************/
        public static void sendSessionParticipantInvites (TelecommSessionSaveReturnData srd)
        {
  
  
           foreach (var participant in srd.participants) {
  
             if (Util.IsNullOrEmpty(participant.email) || Util.IsNullOrEmpty(srd.roomID) || Util.IsNullOrEmpty(srd.roomBaseURL)) { continue; }
             //loop would otherwise crash as soon as we encounter somebody without an email address.
  
             var invite = new InvitableContent();
  
             invite.invitee_name       = participant.name;
             invite.created_date       = DateTime.Now;
             invite.attend_date        = DateTime.Parse(srd.meetingDateTime);
             invite.session_end        = invite.attend_date.AddMinutes(srd.meetingDurationInMins);
             invite.title              = srd.meetingTitle;
         
             /* Create unique meeting URL for participant */
  
             var teleCommUrl = createInviteURL (srd.roomBaseURL, srd.roomID,participant.email);
       
             /* Create email body */
  
             /* Body template placeholders 
                {0} Meeting title
                {1} Meeting date
                {2} Meeting time
                {3} Duration in Minutes
                {4} Meeting link
                {5} Participant email
                {6} Participant pin
                {7} Facilitator name
                {8} Faciliator email
                {9} Confidential email message
             */
  
             var body = String.Format (  srd.inviteEmailBodyTemplateHtml
                                       , srd.meetingTitle
                                       , srd.meetingDate           /* This is returned in human friendly format*/
                                       , srd.meetingTime           /* This is returned in human friendly format*/
                                       , srd.meetingDurationInMins
                                       , teleCommUrl
                                       , participant.email
                                       , participant.pin
                                       , srd.facilitatorName
                                       , srd.facilitatorEmail
                                       , createRsvpRequestURL(srd.roomID, participant.email, participant.inviteRsvpToken)
                                       , "" // Messages.CONFIDENTIAL_EMAIL
                                      );

  
             invite.description_body = String.Format(srd.inviteEmailBodyTemplateText
                                       , srd.meetingTitle
                                       , srd.meetingDate           /* This is returned in human friendly format*/
                                       , srd.meetingTime           /* This is returned in human friendly format*/
                                       , srd.meetingDurationInMins
                                       , teleCommUrl
                                       , participant.email
                                       , participant.pin
                                       , srd.facilitatorName
                                       , srd.facilitatorEmail
                                       , createRsvpRequestURL(srd.roomID, participant.email, participant.inviteRsvpToken)
                                       , Messages.CONFIDENTIAL_EMAIL
                                      );

                                        // NOTE: not sure why we're including the CONFIDENTIAL footer in
                                        // invite.description_body but not var body
  
             /* Send invite email */
  
             var retStatus = @"";
  
             Email.SendInvitation (  !(Util.IsNullOrEmpty(srd.facilitatorEmail)) ? srd.facilitatorEmail : "no-reply@help4schools.com"
                                    , participant.email
                                    , srd.meetingTitle
                                    , body
                                    , false
                                    , true
                                    , invite
                                    , out retStatus);
  
           }
        }

        /***************************************************************************
         * save */
        /**
         * Save 
         * 
         * @param  appName    Application name (from web.config or app.config)
         * @return            ReturnSaveRecordWithJSONData
         ***************************************************************************/   
  
          public static ReturnSaveRecordWithJSONData save (   SqlConnection connUsers
                                                            , DetailsLog    log
                                                            , UserInfo      uInfo
                                                            , string        appName
                                                            , long          environmentID
											                                      , long          purposeID
                                                            , long          authorizationMethodID
                                                            , long          clientID
                                                            , bool          hasFacilitator
                                                            , bool          facilitatorIsParticipant
                                                            , string        facilitatorName
                                                            , string        facilitatorTitle
                                                            , string        facilitatorEmail                                                       
                                                            , string        facilitatorPhone 
                                                            , long          facilitatorUserID 
                                                            , long          facilitatorRoleID  
                                                            , long          facilitatorEntityID
 										                    , string        meetingDate
                                                            , string        meetingTime
											                , string        meetingDurationInMins
                                                            , string        title  
                                                            , string        content                                          
                                                            , string        formsHTML
                                                            , string        formsJSON
                                                            , string        purposeSpecificData
                                                            , string        participantDetails
                                                            , string        filesToShareUploadIDs
                                                            , string        saveType
                                                            , string        validateRec
                                                            , string        editDelReason
                                                            , string        recID )
          {           
    
            /*----------------------------
             * Validate parameters specific
             * to this entity.save
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/
        
           string    saveSproc               = "TELECOMM_SESSION_SAVE";                

           string    vAppName                = Validate.reqString        ( appName,                   Messages.NO_APP_NAME );
		   string    vTitle                  = Validate.reqString        ( title,                     @"Invalid title" );      
           string    vContent                = Validate.optString        ( content,                   @"Invalid content" );
           string    vFormsHTML              = Validate.optString        ( formsHTML,                 @"Invalid forms HTML data" );
           string    vFormsJSON              = Validate.optString        ( formsJSON,                 @"Invalid forms JSON data" );
           DateTime  vMeetingDate            = Validate.reqDate          ( meetingDate,               @"Invalid meeting date", Constants.VAL_OPT_DATE_NONE);
           TimeSpan  vMeetingTime            = Validate.reqTime          ( meetingTime,               @"Invalid meeting time");
		       int       vMeetingDurationInMins  = Validate.reqInteger       ( meetingDurationInMins,     @"Invalid duration",false);
		       string    vParticipantDetailsJSON = Validate.optString        ( participantDetails,        @"Invalid participant details");
           Object    vFilesToShareUploadIDs  = Validate.optRecIDMultiStr ( filesToShareUploadIDs,     @"Invalid file share records");
           Object    vPurposeSpecificData    = Validate.optString        ( purposeSpecificData,       @"Invalid purpose data");
        
              
           // Note: Validate flag is needed to determine if we are sending meeting invites
        
           bool  vValidateRec = Validate.reqFlag (validateRec,  Messages.INVALID_VALIDATE_FLAG);

           AdditionalValidation av = delegate(Object o) {
         
             TeleCommParticipantsDetails vDetails = (TeleCommParticipantsDetails) o;
             foreach (TeleCommParticipant vDetail in vDetails.participantdetails) 
             {
               Validate.optString      (vDetail.name,    @"Invalid name");  
               Validate.optString      (vDetail.title,   @"Invalid title");  
               Validate.optEmail       (vDetail.email,   @"Invalid email");
               Validate.optPhoneNumber (vDetail.phone,   @"Invalid phone number");                                
             }         
           };    
              
           TeleCommParticipantsDetails vParticipantDetails = (TeleCommParticipantsDetails) Validate.optObject (  participantDetails
                                                                                                               , @"Invalid participant data" 
                                                                                                               , "AppFramework"
                                                                                                               , "MBA.TeleCommParticipantsDetails"
                                                                                                               , av
                                                                                                              );

           List<SqlParameter> parms = new List<SqlParameter>();  

           parms.Add(Database.SqlParm( "@appName",                  SqlDbType.VarChar,   vAppName,                 ParameterDirection.Input, 50) );
 		       parms.Add(Database.SqlParm( "@environmentID",            SqlDbType.BigInt,    environmentID,            ParameterDirection.Input) );
 		       parms.Add(Database.SqlParm( "@purposeID",                SqlDbType.BigInt,    purposeID,                ParameterDirection.Input) );
 		       parms.Add(Database.SqlParm( "@authorizationMethodID",    SqlDbType.BigInt,    authorizationMethodID,    ParameterDirection.Input) );
 		       parms.Add(Database.SqlParm( "@clientID",                 SqlDbType.BigInt,    clientID,                 ParameterDirection.Input) );
 		       parms.Add(Database.SqlParm( "@hasFacilitator",           SqlDbType.Bit,       hasFacilitator,           ParameterDirection.Input) );
           parms.Add(Database.SqlParm( "@facilitatorIsParticipant", SqlDbType.Bit,       facilitatorIsParticipant, ParameterDirection.Input) );        
           parms.Add(Database.SqlParm( "@facilitatorName",          SqlDbType.VarChar,   facilitatorName,          ParameterDirection.Input, 256) );
           parms.Add(Database.SqlParm( "@facilitatorTitle",         SqlDbType.VarChar,   facilitatorTitle,         ParameterDirection.Input, 256) );
           parms.Add(Database.SqlParm( "@facilitatorEmail",         SqlDbType.VarChar,   facilitatorEmail,         ParameterDirection.Input, 256) );
           parms.Add(Database.SqlParm( "@facilitatorPhone",         SqlDbType.VarChar,   facilitatorPhone,         ParameterDirection.Input, 256) );
           parms.Add(Database.SqlParm( "@facilitatorUserID",        SqlDbType.BigInt,    facilitatorUserID,        ParameterDirection.Input) );
           parms.Add(Database.SqlParm( "@facilitatorRoleID",        SqlDbType.BigInt,    facilitatorRoleID,        ParameterDirection.Input) );
           parms.Add(Database.SqlParm( "@facilitatorEntityID",      SqlDbType.BigInt,    facilitatorEntityID,      ParameterDirection.Input) );
 		       parms.Add(Database.SqlParm( "@title",                    SqlDbType.VarChar,   vTitle,                   ParameterDirection.Input, 512)  );
           parms.Add(Database.SqlParm( "@content",                  SqlDbType.NVarChar,  vContent,                 ParameterDirection.Input, -1) );
           parms.Add(Database.SqlParm( "@formsHTML",                SqlDbType.NVarChar,  vFormsHTML,               ParameterDirection.Input, -1) );
           parms.Add(Database.SqlParm( "@formsJSON",                SqlDbType.NVarChar,  vFormsJSON,               ParameterDirection.Input, -1) );
           parms.Add(Database.SqlParm( "@meetingDate",              SqlDbType.VarChar,   vMeetingDate,             ParameterDirection.Input) );
           parms.Add(Database.SqlParm( "@meetingTime",              SqlDbType.Time,      vMeetingTime,             ParameterDirection.Input) );
           parms.Add(Database.SqlParm( "@meetingDurationInMins",    SqlDbType.Int,       vMeetingDurationInMins,   ParameterDirection.Input) );
           parms.Add(Database.SqlParm( "@participantDetailsJSON",   SqlDbType.VarChar,   vParticipantDetailsJSON,  ParameterDirection.Input, -1) ); 		                 
           parms.Add(Database.SqlParm( "@filesToShareUploadIDs",    SqlDbType.VarChar,   vFilesToShareUploadIDs,   ParameterDirection.Input, 8000) ); 		          
           parms.Add(Database.SqlParm( "@purposeSpecificData",      SqlDbType.VarChar,   vPurposeSpecificData,     ParameterDirection.Input, -1) );
       
       
           parms.Add(Database.SqlParmDataTable <TeleCommParticipant> (  "@participantDetails"
                                                                      , vParticipantDetails.participantdetails
                                                                      , @"TelecommParticipantDetails"));         
         
           /*----------------------------
            * Call base method which 
            * handles the rest and return
            * results
            *----------------------------*/  

           ReturnSaveRecordWithJSONData so = Entities.saveAndReturnJSONData (  connUsers
                                                                             , log
                                                                             , uInfo
                                                                             , saveType
                                                                             , validateRec
                                                                             , editDelReason
                                                                             , recID
                                                                             , saveSproc
                                                                             , @"Duplicate meeting"
                                                                             , ref parms
                                                                             , delegate(){});
                                                                                       
       
           /*----------------------------
            * Handle meeting invites
            *----------------------------*/  

           if ((!vValidateRec) && (so.status == Return.RET_SUCCESS))
           {  
         
                sendSessionParticipantInvites((TelecommSessionSaveReturnData)JSON.fromJSONString(so.jsonData, typeof(TelecommSessionSaveReturnData), JsonLibrary.NEWTONSOFT));
       
           }
           return so;

        }

        /***************************************************************************
         * delete */
        /**
         * "Deletes" session
         * 
         * @param  editDelReason   Reason for edit/delete 
         * @param  validateRec     Perform validation for this record?
         * @param  recID           Record id reference for edit and delete
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/   

        protected static ReturnSaveRecord delete (  SqlConnection connUsers
                                                   , DetailsLog   log
                                                   , UserInfo     uInfo
                                                   , string       appName
                                                   , Object       clientID
                                                   , string       editDelReason
                                                   , string       validateRec
                                                   , string       recID )
        {           
                
          /*----------------------------
           * Collect all of the parameters
           * that are specific to this
           * delete method.
           *----------------------------*/

          List<SqlParameter> parms  = new List<SqlParameter>();

          parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt,   clientID, ParameterDirection.Input));
          parms.Add(Database.SqlParm("@appName",  SqlDbType.VarChar,  appName,  ParameterDirection.Input,50));  
      
          /* TODO: Create cancel notification for participants */

          /*----------------------------
           * Call base method 
           *----------------------------*/

          return Entities.delete(  connUsers
                                 , log
                                 , uInfo
                                 , editDelReason
                                 , validateRec
                                 , recID
                                 , "TELECOMM_SESSION_DELETE"
                                 , ref parms );

        }

        public static List<ReturnTeleCommSessionParticipant> getUpcomingTelecommSessionsForUserID(
                    SqlConnection connUser
                  , DetailsLog log
                  , UserInfo uInfo
                  , long purpose
                  , string urlTeleCommPage)
        {


            string appName   = Constants.APP_NAME;
            var so = new List<ReturnTeleCommSessionParticipant>();

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@userID", SqlDbType.BigInt, uInfo.userid, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@appname", SqlDbType.VarChar, appName, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@purposeID", SqlDbType.BigInt, purpose, ParameterDirection.Input));

            string sql = "select * from dbo.TELECOMM_SESSIONS_VIEW_UPCOMING_FOR_USER (@userID, @appname, @purposeID)";

            ReturnDB rd = Database.execQuery(connUser, log, sql, false, parms);

            List<Object> slo = Database.convertRecordsToList(ref rd.records, typeof(TeleCommSessionParticipant));
            foreach (var o in slo) {
              ReturnTeleCommSessionParticipant rtsp = new ReturnTeleCommSessionParticipant();

              rtsp.tsp             = (TeleCommSessionParticipant) o;
              rtsp.directSignInUrl = createSignInURL(urlTeleCommPage, rtsp.tsp.roomID, rtsp.tsp.participantEmail, rtsp.tsp.participantPIN);

              //rtsp.spedPvtRsvpPageUrl     = createRsvpRequestPvtURL(rtsp.tsp.roomID, rtsp.tsp.participantEmail, rtsp.tsp.inviteRsvpToken);

              rtsp.rsvpPageUrl     = createRsvpRequestURL(rtsp.tsp.roomID, rtsp.tsp.participantEmail, rtsp.tsp.inviteRsvpToken);
              so.Add(rtsp);

            }
          
            return so;
 
        }



    }
}
