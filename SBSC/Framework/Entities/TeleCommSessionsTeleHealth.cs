using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Mail;
using System.IO;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using MBA;

namespace Spedmon
{  
  
  /**************************************************************************
   * TeleCommTeleHealthSvcDetail */
  /**
   * 
   * 
   ****************************************************************************/
  
  public class TeleCommTeleHealthSvcDetail 
  {
    public string     patAbsent = "";
    public string     patID     = "";
    public string     iep       = "";
    public string     startTime = "";
    public string     numMins   = "";
    public string     notes     = "";
  }

  public class TeleCommTeleHealthSvcDetails {
     public TeleCommTeleHealthSvcDetail[] svcDetails; 
  }

  /**************************************************************************
   * TeleCommPurposeSpecificDataTeleHealth */
  /**
   * 
   * 
   ****************************************************************************/
  
  public class TeleCommPurposeSpecificDataTeleHealth
  { 
    public TeleCommPurposeSpecificDataTeleHealth():this("","","","")
    {
    }
    
    public TeleCommPurposeSpecificDataTeleHealth (  string servicetype
                                                  , string servicesubtype
                                                  , string patid
                                                  , string patgroupid)
    {
      this.serviceType    = servicetype;
      this.serviceSubType = servicesubtype;
      this.patID          = patid;
      this.patGroupID     = patgroupid;
    }

    public string  serviceType;
    public string  serviceSubType;
    public string  patID;
    public string  patGroupID;
    public override string ToString()
    {
      return TeleCommPurposeSpecificDataTeleHealth.ToJSONString(this);
      //return base.ToString();
    }
    public static String ToJSONString (TeleCommPurposeSpecificDataTeleHealth purposeSpecificData)
    {
      return MBA.JSON.toJSONString(purposeSpecificData,JsonLibrary.NEWTONSOFT);
    }
    public static TeleCommPurposeSpecificDataTeleHealth FromJSONString (string purposeSpecificData)
    {    
      return (TeleCommPurposeSpecificDataTeleHealth) MBA.JSON.fromJSONString(purposeSpecificData,typeof(TeleCommPurposeSpecificDataTeleHealth),JsonLibrary.NEWTONSOFT);
    }
  }
  
  /**************************************************************************
   * TeleHealthSession */
  /**
   * 
   * 
   ****************************************************************************/

  public class TeleHealthSession: MBA.TeleCommSession
  {
    public TeleCommPurposeSpecificDataTeleHealth purposeSpecificDataObj;
    public const string DEFAULT_PAGING_ORDER = @"meetingDate asc, meetingTime asc";
  }

    /**************************************************************************
     * TeleCommSessionsTeleHealth */
    /**
     * 
     * 
     ****************************************************************************/

    public class TeleHealthSessions : MBA.TeleCommSessions
    {
    
        public const string SEL_LABEL               = @"HYQueue Telehealth Sessions";
        public const string SEL_LABEL_MANAGE        = SEL_LABEL;
        public const string SEL_LABEL_VIEW_UPCOMING = @"Upcoming " + SEL_LABEL;
        public const string SEL_LABEL_ADD_NEW       = @"Add New";
        public const string SEL_LABEL_EDIT          = @"Edit";
        public const string MENU_LINK_MANAGE        = @"telecommtelehealthmanagelink";
        public const string URL_USER_ALL_MANAGE     = @"user_all_tele_health_manage.aspx";
        public const string URL_USER_ALL_SAVE       = @"user_all_telecomm_tele_health_save.aspx";
        public const string URL_SBS_MANAGE          = @"user_all_tele_health_manage.aspx";
        public const string URL_CLIENT_COOR_MANAGE  = URL_USER_ALL_MANAGE;

        public const string URL_CLIENT_PROV_MANAGE  = URL_USER_ALL_MANAGE;
        public const string URL_TELECOMM_PAGE       = @"telecomm_health.aspx";
        
        public static string VAL_FILE_CLASS        = MBA.StoredFiles.FILE_CLASS_TELECOMM_TELE_HEALTH;
        public static string VAL_FILE_NAMESPACE    = "telecomm";
        public static string VAL_FILE_SOURCE       = "telehealth";

        public const string URL_HEALTH_ALL_SAVE = @"user_all_telecomm_tele_health_save.aspx";

        public const string URL_SERVICE_BASE = @"telecomm_sessions_tele_health.asmx";
        public const string URL_HEALTH_ALL_DELETE_BASE = URL_SERVICE_BASE + @"/delete";
        public const string URL_REST_VIEW_BASE = @"api/v1/telehealthsessions";

        public const string URL_DELETE_INLINE_BASE = URL_SERVICE_BASE + @"/deleteinline";
        public const string URL_JOIN_MEETING_BASE = URL_SERVICE_BASE + @"/gettelecommsessionparticipantforuserid";
        /***************************************************************************
         * clientHasAccess */
        /**
         *  
         *
         ***************************************************************************/

        public static bool clientHasAccess (ReturnWebUser wu) {
          return wu.usr.teleCommTeleHealthAccessGranted;
        }

        /***************************************************************************
         * URL_ADD_NEW_HEALTH */
        /**
         * 
         **************************************************************************/
        public static string URL_ADD_NEW_HEALTH()
        {
            return MBA.HttpApplication.createLink(TeleHealthSessions.URL_HEALTH_ALL_SAVE
                                                  , true
                                                  , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                  , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW)
                                                  );
        }

        /***************************************************************************
         * URL_EDIT_HEALTH */
        /**
         * 
         **************************************************************************/
        public static string URL_EDIT_HEALTH()
        {
            return MBA.HttpApplication.createLink(TeleHealthSessions.URL_HEALTH_ALL_SAVE
                                                  , true
                                                  , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                  , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)
                                                  , new NameValue(Constants.PARM_REC_ID, "")
                                                  );
        }

        /***************************************************************************
         * URL_DELETE_HEALTH */
        /**
         * 
         **************************************************************************/
        public static string URL_DELETE_HEALTH()
        {
            return MBA.HttpApplication.createLink(TeleHealthSessions.URL_HEALTH_ALL_DELETE_BASE
                                                   , true
                                                 );
        }

        /***************************************************************************
         * URL_REST_VIEW_HEALTH */
        /**
         * 
         **************************************************************************/
        public static string URL_REST_VIEW_HEALTH()
        {
            return MBA.HttpApplication.createLink(TeleHealthSessions.URL_REST_VIEW_BASE, true);
        }

        /***************************************************************************
         * URL_JOIN_MEETING */
        /**
         * 
         **************************************************************************/

        public static string URL_JOIN_MEETING()
        {
            return MBA.HttpApplication.createLink(TeleHealthSessions.URL_JOIN_MEETING_BASE, true);
        }

        /***************************************************************************
         * clientHasAccess */
        /**
         *  
         * Looks up directly
         ***************************************************************************/

        public static bool clientHasAccess (  SqlConnection   connSpedmon
                                            , DetailsLog      log
                                            , UserInfo        uInfo
                                            , string          clientID)
        {
        
            Client c = Clients.load(connSpedmon,log,uInfo,clientID);            
            var accessGranted = c.teleCommTeleHealthAccessGranted;
            /* TODO: Access grant date check */
            return accessGranted;
         }

        /***************************************************************************
        * viewObjects
        *
        * Returns 
        * 
        ***************************************************************************/

        public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                    , DetailsLog log
                                                    , UserInfo uInfo
                                                    , bool pageObjectList
                                                    , string pageOrder
                                                    , string idx
                                                    , string active
                                                    , string clientID
                                                    , string pracID)

        {
            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = TeleHealthSession.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
                * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            var rd = Entities.viewObjects(connSpedmon
                                            , log
                                            , uInfo
                                            , typeof(TeleHealthSession)
                                            , pageObjectList
                                            , pageOrder
                                            , delegate {
                                                return TeleHealthSessions.view(connSpedmon
                                                                                , log
                                                                                , uInfo
                                                                                , clientID
                                                                                , pracID
                                                                                , Entities.REC_VIEW_OBJECTS
                                                                                , pageObjectList
                                                                                , idx
                                                                                , ""
                                                                                , active
                                                                                , dc);
                                            });


            return rd;
        }


        /***************************************************************************
         * validateClientAccessForMethodOrHandler */
        /**
         * 
         *
         ***************************************************************************/

        public static bool validateClientAccessForMethodOrHandler (   SqlConnection   connSpedmon
                                                                , DetailsLog      log
                                                                , UserInfo        uInfo
                                                                , string          clientID)
        {
          bool hasAccess = clientHasAccess (connSpedmon,log,uInfo,clientID);
          if (hasAccess == false) throw new MBA.Critical(@"Subscription required");
          return hasAccess;
        }
    
        /***************************************************************************
         * validateClientAccessForPage */
        /**
         *  
         *
         ***************************************************************************/
        
        public static void validateClientAccessForPage (   SqlConnection   connSpedmon
                                                         , DetailsLog      log
                                                         , UserInfo        uInfo
                                                         , string          clientID
                                                         , HttpResponse    Response
                                                         , HttpContext     Context )
        {           	     
          
          bool hasAccess = clientHasAccess (connSpedmon,log,uInfo,clientID);     
          if (hasAccess == false)
          {
            throw new MBA.Critical(@"Subscription required");
            //string url = MBA.HttpApplication.createLink(PlanWriterRecords.URL_USER_ALL_SUBSCRIPTION_NOTICE,true);
            //Response.Redirect(url,false);
            //Context.ApplicationInstance.CompleteRequest();
          }   
        }

        /***************************************************************************
         * getTeleCommSessionParticipantForUserID */
        /**
         * 
         * 
         ****************************************************************************/    
        public static ReturnTeleCommSessionParticipant getTeleCommSessionParticipantForUserID (   SqlConnection connUsers
                                                                                                , DetailsLog    log
                                                                                                , UserInfo      uInfo
                                                                                                , string        roomID)       
        {
          return TeleCommSessions.getTelecommSessionParticipantForUserID (connUsers, log, uInfo, roomID, URL_TELECOMM_PAGE);
        }

    /***************************************************************************
     * save */
    /**
     * 
     * 
     ****************************************************************************/    
    public static ReturnSaveRecordWithJSONData save (   SqlConnection connUsers
                                                      , SqlConnection connSpedmon
                                                      , DetailsLog    log
                                                      , UserInfo      uInfo
                                                      , string        clientID
                                                      , string        pracID
                                                      , string        serviceType
                                                      , string        serviceSubType
                                                      , string        patID
                                                      , string        patGroupID
 										                                  , string        meetingDate
                                                      , string        meetingTime
											                                , string        meetingDurationInMins
                                                      , string        title  
                                                      , string        content
                                                      , string        participantDetails
                                                      , string        filesToShareUploadIDs
                                                      , string        saveType
                                                      , string        validateRec
                                                      , string        editDelReason
                                                      , string        recID )
    {           
                       
      
      /*============================================================
       * Validate required fields
       *============================================================*/  

      long vClientID = Validate.reqClientID (uInfo,clientID);
      long vPracID   = Validate.reqPracID   (uInfo,pracID);

      /*============================================================
       * Practitioner is the faciliator (only facilitator in this
       * meeting).  Load their data.
       *============================================================*/  

      Practitioner p = Practitioners.load ( connSpedmon
                                          , log
                                          , uInfo
                                          , vPracID.ToString());      
   
      
                                          
      /* TODO: Exit if practitoner does not have a user id */
            
      /*============================================================
       * Generate telehealth specific data to save with this session
       *============================================================*/ 
      
      string vPurposeSpecificData = new TeleCommPurposeSpecificDataTeleHealth (serviceType,serviceSubType,patID,patGroupID).ToString();

      /*============================================================
       * Call the general purpose save method
       * TODO: Replace with a specific method
       *============================================================*/  

      return MBA.TeleCommSessions.save (  connUsers
                                        , log
                                        , uInfo
                                        , Constants.APP_NAME
                                        , Constants.OPEN_VIDU_APP_ENVIRONMENT
                                        , Constants.TELECOMM_PURPOSE_TELEHEALH
                                        , Constants.TELECOM_PARTICIPANT_AUTH_METHOD_EMAIL_PIN
                                        , vClientID
                                        , true
                                        , true
                                        , p.name
                                        , p.groupName
                                        , p.email
                                        , p.phone
                                        , (p.userIDInt.HasValue ? p.userIDInt.Value : 0)
                                        , Constants.ROLE_LEA_PROVIDER_ID
                                        , p.id
                                        , meetingDate
                                        , meetingTime
                                        , meetingDurationInMins
                                        , title
                                        , content
                                        , @""
                                        , @"{}"
                                        , vPurposeSpecificData
                                        , participantDetails
                                        , filesToShareUploadIDs
                                        , saveType
                                        , validateRec
                                        , editDelReason
                                        , recID);
    }
  
    /***************************************************************************
     * delete */
    /**
     * "Deletes" a session
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
    
    public static ReturnSaveRecord delete (  SqlConnection connUsers
                                           , DetailsLog    log
                                           , UserInfo      uInfo
                                           , string        editDelReason
                                           , string        validateRec
                                           , string        recID)
    {           
     
      /*----------------------------
       * Check for required and 
       * optional parameters
       * and validate data integrity
       * of all supplied parameters
       *----------------------------*/

      Object vClientID = Validate.optClientID(uInfo, ""); /*Ensures that clients can only deactivate their records */
      string appName   = Constants.APP_NAME;
       
     /*----------------------------
      * Call base method 
      *----------------------------*/
    
     return MBA.TeleCommSessions.delete (   connUsers
                                          , log
                                          , uInfo
                                          , appName
                                          , vClientID
                                          , editDelReason
                                          , validateRec
                                          , recID );
    
    }

    /***************************************************************************
     * saveServiceRecords */
    /**
     * Called by practitioner only from the telecomm telehealth session
     * 
     ****************************************************************************/    
    public static ReturnSaveRecord saveServiceRecords (   SqlConnection   connUsers
                                                        , SqlConnection   connSpedmon
                                                        , DetailsLog      log
                                                        , UserInfo        uInfo
                                                        , RequestResponse rr
                                                        , string          roomID
                                                        , string          participantEmail
                                                        , string          participantPIN
                                                        , string          formID
                                                        , string          formData
                                                        , string          validateRec )
    {           
      var so = new ReturnSaveRecord();
      
      if (uInfo == null) {     
        uInfo = new UserInfo();
        uInfo.userid    = 0;
        uInfo.userGroup = 0;
        uInfo.userRank  = 0;
      }
      
      List<SqlParameter> parms = new List<SqlParameter>();     
      
      MBA.TeleCommSessionParticipants.validateAndAddCommonSaveSessionFormDataParms (   roomID
                                                                                     , participantEmail
                                                                                     , participantPIN
                                                                                     , rr
                                                                                     , formID
                                                                                     , formData                                                                                    
                                                                                     , ref parms);

      parms.Add(Database.SqlParm("@MsgInvCombo",     SqlDbType.VarChar,  Messages.INVALID_PPN_COMBO,      ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgMinReq",       SqlDbType.VarChar,  Messages.MIN_REQ,                ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgMinDef",       SqlDbType.VarChar,  Messages.MIN_DEF,                ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgMilReq",       SqlDbType.VarChar,  Messages.MIL_REQ,                ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgPatElg",       SqlDbType.VarChar,  Messages.PAT_ELG,                ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgPatDOBGteDOS", SqlDbType.VarChar,  Messages.PAT_DOB_GTE_DOS,        ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgPatAbsent",    SqlDbType.VarChar,  Messages.PAT_ABSENT_NO_CLAIM,    ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgFutureDOS",    SqlDbType.VarChar,  Messages.VAL_SVC_REC_DOS_FUTURE, ParameterDirection.Input, 1000));

      so = Entities.save (   connSpedmon
                           , log
                           , uInfo
                           , "1"
                           , validateRec
                           , ""
                           , ""
                           , "TELECOMM_HEALTH_SAVE_SERVICE_RECORDS"
                           , "These services have already been saved"
                           , ref parms
                           , null );
      return so;                                                                               

    }
  

    /***************************************************************************
     * view */
    /**
     * View Sessions
     * 
     * @return            ReturnDB
     ***************************************************************************/   

    public static ReturnDB view (  SqlConnection connSpedmon
                                  , DetailsLog    log
                                  , UserInfo      uInfo
                                  , string        clientID
                                  , string        pracID
                                  , int           recViewType
                                  , bool          pagedOrTop
                                  , string        idx
                                  , string        canEdit
                                  , string        active                                      
                                  , defineCols    dc )
    {
      
      Object vClientID  = Validate.optClientID (uInfo, clientID);
      Object vPracID    = Validate.optPracID   (uInfo, pracID);

      string viewUDF = @"dbo.TELECOMM_SESSIONS_HEALTH_VIEW (@userID,@userGroup,@userRank,@clientID,@pracID,@active,@recID)";
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@clientID",   SqlDbType.BigInt,   vClientID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",     SqlDbType.BigInt,   vPracID,    ParameterDirection.Input));
                                         
      /*###########################################################################
        # Call base method which handles the rest and return the results
        ###########################################################################*/  
      
      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

   }

   /***************************************************************************
    * viewTbl */
   /**
    * View Table * 
    * @param  appName     Application name (from web.config or app.config) 
    * @param  clientID    Client ID record (if any)
    * @return             ReturnDataTable
    ***************************************************************************/   
    
    public static ReturnDataTable viewTbl (   SqlConnection connSpedmon
                                            , DetailsLog    log
                                            , UserInfo      uInfo
                                            , string        clientID
                                            , string        pracID
                                            , bool          paged
                                            , string        pageNumber
                                            , string        canEdit
                                            , string        active ) 
    {
      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        ss.addDisplayColumn ("id as [id]", true);
        ss.addDisplayColumn ("facilitatorName as [Practitioner]");
        ss.addDisplayColumn ("title as [Session Title]");
        ss.addDisplayColumn ("meetingDateStr as [Session Date]");
        ss.addDisplayColumn ("meetingTimeStr as [Session Time]");
        ss.addDisplayColumn ("roomID as [Room ID]");
        pageroworder = ss.pageRowOrder();     
      };
      
      return Entities.viewTbl( connSpedmon
                             , log
                             , uInfo
                             , paged
                             , pageNumber
                             , delegate{
                                 return TeleHealthSessions.view (  connSpedmon
                                                                       , log
                                                                       , uInfo  
                                                                       , clientID
                                                                       , pracID
                                                                       , Entities.REC_VIEW_TBL
                                                                       , paged
                                                                       , pageNumber
                                                                       , canEdit
                                                                       , active
                                                                       , dc);}
                            , TeleHealthSessions.SEL_LABEL_VIEW_UPCOMING
                            , Messages.CONFIDENTIAL
        );
    }

    /***************************************************************************
     * load */
    /**
     * Outputs data for a single record
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing the client id and the pracid
     * 
     * @return TeleHealthSession
     ***************************************************************************/

    public static TeleHealthSession load (   SqlConnection connSpedmon
                                            , DetailsLog    log
                                            , UserInfo      uInfo
                                            , string        recID)
                                        
    {      
      TeleHealthSession so = new TeleHealthSession();

      so = (TeleHealthSession) Entities.load (  connSpedmon
                                              , log
                                              , uInfo
                                              , recID
                                              , typeof(TeleHealthSession)
                                              , delegate { 
                                                return TeleHealthSessions.view ( connSpedmon
                                                                                ,log
                                                                                ,uInfo
                                                                                ,""
                                                                                ,""
                                                                                ,Entities.REC_VIEW_LOAD,false
                                                                                ,recID
                                                                                ,""
                                                                                ,""
                                                                                ,null);
                                                });
    
      so.purposeSpecificDataObj = TeleCommPurposeSpecificDataTeleHealth.FromJSONString(so.purposeSpecificData);
      return so;
    } 

    public static List <ReturnTeleCommSessionParticipant> getUpcomingTelecommSessionsForUserID (   SqlConnection connUsers
                                                                                            , DetailsLog    log
                                                                                            , UserInfo      uInfo
                                                                                            )      
    {
      return TeleCommSessions.getUpcomingTelecommSessionsForUserID (
          connUsers,
          log,
          uInfo,
          //roomID,
          Constants.TELECOMM_PURPOSE_TELEHEALH ,
          URL_TELECOMM_PAGE
          );
    }
                 
  }
}
