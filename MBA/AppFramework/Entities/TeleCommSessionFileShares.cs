using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Mail;
using System.IO;
using System.Web;
using System.Data;
using System.Data.SqlClient;

namespace MBA
{  
  
  /***************************************************************************
   * TeleCommSessionFileShare */
  /**
   * 
   ***************************************************************************/
  public class TeleCommSessionFileShare
  {
    public TeleCommSessionFileShare(){}
    
    public long   id;    
    public string name;
    public string description;
    public long   uploadID;  
  }
  
  /***************************************************************************
   * TeleCommSessionFileShares */
  /**
   * 
   ****************************************************************************/
  public class TeleCommSessionFileShares:Entities
  {        
    
    public static string FILE_SHARE_URL_BASE   = @"storedfiletelecommdownload.ashx";
    public static string FILE_APPEND_URL_BASE  = @"storedfiletelecommupload.ashx";

   /***************************************************************************
    * appendFileShare */
   /**
    * Adds a file to share to the session whos record id is in @recID
    * 
    ****************************************************************************/

    public static ReturnSaveRecord appendFileShare  (  SqlConnection  connUsers
                                                     , DetailsLog    log
                                                     , UserInfo      uInfo
                                                     , string        uploadID
                                                     , string        validateRec
                                                     , string        editDelReason
                                                     , string        recID )
    {
      
      ReturnSaveRecord so = new ReturnSaveRecord();      

      List<SqlParameter> parms = new List<SqlParameter>();
      
      long vUploadID = Validate.reqInteger(uploadID,@"Upload id is required");
      parms.Add(Database.SqlParm("@uploadID",  SqlDbType.BigInt, vUploadID, ParameterDirection.Input));

      so = Entities.save (  connUsers
                           , log
                           , uInfo
                           , Constants.SAVE_TYPE_EDIT.ToString()
                           , validateRec
                           , editDelReason
                           , recID
                           , @"TELECOMM_SESSION_APPEND_FILE_SHARE"
                           , @"Duplicate share"
                           , ref parms
                           , delegate(){});
       
      return so;
 
    }

 
    /***************************************************************************
     * view */
    /**
     * View 
     * 
     * @param  appName    Application name (from web.config or app.config)
     * @param  clientID   Client record id (if any)
     * @return            ReturnDB
     ***************************************************************************/   
    public static ReturnDB view (  SqlConnection connUsers
                                 , DetailsLog    log
                                 , UserInfo      uInfo
                                 , string        appName
                                 , long          sessionID
                                 , int           recViewType
                                 , bool          pagedOrTop
                                 , string        idx
                                 , string        canEdit
                                 , string        active                                      
                                 , defineCols    dc )
    {
      
      
      if (uInfo == null) {     
        uInfo = new UserInfo();
        uInfo.userid    = 0;
        uInfo.userGroup = 0;
        uInfo.userRank  = 0;
      }
      
      string viewUDF = "dbo.TELECOMM_SESSION_FILE_SHARES_VIEW (@userID, @userGroup, @userRank, @appName, @sessionID)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
       List<SqlParameter> parms = new List<SqlParameter>();   
      
       parms.Add(Database.SqlParm("@appName",      SqlDbType.VarChar, appName,     ParameterDirection.Input, 50));
       parms.Add(Database.SqlParm("@sessionID",    SqlDbType.BigInt,  sessionID,   ParameterDirection.Input));

       /*----------------------------
        * Call base method which 
        * handles the rest and return
        * results
        *----------------------------*/

       return Entities.view (connUsers, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
     }
   
     /***************************************************************************
      * viewList */
     /**
      * View list 
      * 
      * @param  appName    Application name (from web.config or app.config)
      * @param  sessionID  Telecomm session id
      * @return            ReturnDB
      ***************************************************************************/   

     public static List<TeleCommSessionFileShare> viewList (  SqlConnection connUsers
                                                            , DetailsLog    log
                                                            , UserInfo      uInfo
                                                            , string        appName
                                                            , long          sessionID )
     {
       List<TeleCommSessionFileShare> recs = new List<TeleCommSessionFileShare>();

       ReturnDB rd = view(connUsers,log,uInfo,appName, sessionID, Entities.REC_VIEW_RAW,false,null,null,null,null);
       List<Object> slo = Database.convertRecordsToList (ref rd.records, typeof(TeleCommSessionFileShare));
       
       foreach (var o in slo) {
         recs.Add((TeleCommSessionFileShare) o);
       }
       
       return recs;
     }
  
     /***************************************************************************
      * generateSharedFileUploadUrl */
     /**
      * Generates the complete url needed to upload a file
      ****************************************************************************/
     public static string generateSharedFileUploadUrl (  string roomID
                                                       , string participantEmail
                                                       , string participantPIN ) 
     {
           
        return HttpApplication.createLink (   FILE_APPEND_URL_BASE
                                            , new NameValue(Constants.PARM_ROOM_ID,        roomID)   
                                            , new NameValue(Constants.PARM_ROOM_PART_UID,  participantEmail)   
                                            , new NameValue(Constants.PARM_ROOM_PART_PIN,  participantPIN)                                             
                                          );
     }
  
     /***************************************************************************
      * canParticipantAccessSharedFile */
     /**
      * Used by handler for file downloads
      * 
      ****************************************************************************/

    public static ReturnStoredFileAccessStatus canParticipantAccessSharedFile  (  SqlConnection    connUsers
                                                                                 , DetailsLog      log
                                                                                 , UserInfo        uInfo
                                                                                 , RequestResponse rr
                                                                                 , string          appName
                                                                                 , string          roomID
                                                                                 , string          participantEmail
                                                                                 , string          participantPIN
                                                                                 , string          storedFileID )
    {
      
      if (uInfo == null) {     
        uInfo = new UserInfo();
        uInfo.userid    = 0;
        uInfo.userGroup = 0;
        uInfo.userRank  = 0;
      }

      var so = new ReturnStoredFileAccessStatus();
      so.accessGranted = false;
      so.clientID = -1;
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      TeleCommSessionParticipants.validateAndAddCommonSessionParticipantParms (roomID, participantEmail, participantPIN, rr, ref parms); 
      
      var storedFileIDVal = Validate.reqInteger(storedFileID, @"Invalid file id");

      parms.Add(Database.SqlParm("@storedFileID",         SqlDbType.BigInt, storedFileIDVal, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@accessGranted",        SqlDbType.Bit,   false, ParameterDirection.Output));
      parms.Add(Database.SqlParm("@participantClientID",  SqlDbType.BigInt, -1,   ParameterDirection.Output));

      /*============================================================
       * Call sproc
       *============================================================*/  

      var sp = @"TELECOMM_SESSION_VALIDATE_SHARED_FILE_ACCESS";
      ReturnDB rd = Database.execSproc(connUsers,log,sp,parms);
     
      so.accessGranted = (bool) Database.getParameterValue("accessGranted",       ref parms);    
      so.clientID      = (long) Database.getParameterValue("participantClientID", ref parms);     
      return so;
    }

     /***************************************************************************
      * canParticipantAppendASharedFile */
     /**
      * Used by handler for file uploads
      * 
      ****************************************************************************/

      public static ReturnStoredFileAppendInfo canParticipantAppendASharedFile (   ref SqlConnection connUsers
                                                                                 , ref DetailsLog log
                                                                                 , ref UserInfo uInfo
                                                                                 , ref RequestResponse rr
                                                                                 , string appName
                                                                                 , string roomID
                                                                                 , string participantEmail
                                                                                 , string participantPIN )
      {

        ReturnStoredFileAppendInfo so = new ReturnStoredFileAppendInfo();
        so.accessGranted = false;
        so.clientID = -1;

        bool noUserInfo = false;

        /*============================================================
         * If there is no user info passed 
         * we will later retrieve and use the userinfo of who last
         * created or modified the room
         *============================================================*/

        if (uInfo == null)
        {
          uInfo = new UserInfo();
          uInfo.userid = 0;
          uInfo.userGroup = 0;
          uInfo.userRank = 0;
          noUserInfo = true;
         }

         /* Preload user info data... we will replace if needed */

         so.noUserInfoPassed = noUserInfo;
         so.uInfo            = uInfo;
         so.userID           = uInfo.userid;
         so.userGroup        = uInfo.userGroup;
         so.userRank         = uInfo.userRank;

         List<SqlParameter> parms = new List<SqlParameter>();

         TeleCommSessionParticipants.validateAndAddCommonSessionParticipantParms (roomID, participantEmail, participantPIN, rr, ref parms);

         parms.Add(Database.SqlParm("@accessGranted",           SqlDbType.Bit, false,   ParameterDirection.Output));
         parms.Add(Database.SqlParm("@participantClientID",     SqlDbType.BigInt, -1,   ParameterDirection.Output));           
         parms.Add(Database.SqlParm("@teleCommSessionID",       SqlDbType.BigInt, -1,   ParameterDirection.Output));
         parms.Add(Database.SqlParm("@teleCommServerSessionID", SqlDbType.VarChar, "",  ParameterDirection.Output,256));
         parms.Add(Database.SqlParm("@appName",                 SqlDbType.VarChar, "",  ParameterDirection.Output,50));
         parms.Add(Database.SqlParm("@userID",                  SqlDbType.BigInt,  -1,  ParameterDirection.Output));
         parms.Add(Database.SqlParm("@userGroup",               SqlDbType.Int,     -1,  ParameterDirection.Output));
         parms.Add(Database.SqlParm("@userRank",                SqlDbType.Int,     -1,  ParameterDirection.Output));
         parms.Add(Database.SqlParm("@fileClassStr",            SqlDbType.VarChar, "",  ParameterDirection.Output,1000));
         parms.Add(Database.SqlParm("@fileNameSpace",           SqlDbType.VarChar, "",  ParameterDirection.Output,500));
         parms.Add(Database.SqlParm("@fileSource",              SqlDbType.VarChar, "",  ParameterDirection.Output,500));
         parms.Add(Database.SqlParm("@clientIDStr",             SqlDbType.VarChar, "",  ParameterDirection.Output,1000));
         parms.Add(Database.SqlParm("@pracIDStr",               SqlDbType.VarChar, "",  ParameterDirection.Output,1000));
         parms.Add(Database.SqlParm("@patIDStr",                SqlDbType.VarChar, "",  ParameterDirection.Output,1000));

         /*============================================================
          * Call sproc
          *============================================================*/

         var sp = @"TELECOMM_SESSION_VALIDATE_SHARED_FILE_ADD";
         var rd = Database.execSproc(connUsers, log, sp, parms);

         /*============================================================
          * Extract results
          *============================================================*/

         so.accessGranted           = (bool)   Database.getParameterValue ("accessGranted",           ref parms);
         so.clientID                = (long)   Database.getParameterValue ("participantClientID",     ref parms);
         so.teleCommSessionID       = (long)   Database.getParameterValue ("teleCommSessionID",       ref parms);
         so.teleCommServerSessionID = (String) Database.getParameterValue ("teleCommServerSessionID", ref parms);
         
         if (noUserInfo == true)
         {
            so.userID    = (long) Database.getParameterValue("userID", ref parms);
            so.userGroup = (int)  Database.getParameterValue("userGroup", ref parms);
            so.userRank  = (int)  Database.getParameterValue("userRank", ref parms);
            uInfo = new UserInfo();
            uInfo.userid    = so.userID;
            uInfo.userGroup = so.userGroup;
            uInfo.userRank  = so.userRank;             
         }
         
         so.appName       = (String) Database.getParameterValue("appName", ref parms);
         so.fileClassStr  = (String) Database.getParameterValue("fileClassStr", ref parms);
         so.fileNameSpace = (String) Database.getParameterValue("fileNameSpace", ref parms);
         so.fileSource    = (String) Database.getParameterValue("fileSource", ref parms);
         so.clientIDStr   = (String) Database.getParameterValue("clientIDStr", ref parms);
         so.pracIDStr     = (String) Database.getParameterValue("pracIDStr", ref parms);
         so.patIDStr      = (String) Database.getParameterValue("patIDStr", ref parms);
         return so;
      }

      /***************************************************************************
       * generateSharedFileViewPdfUrl */
       /**
        * Generates the complete url needed for the pdf viewer 
        * File url itself is URL encoded so it will work with pdf.js
        ****************************************************************************/
       public static string generateSharedFileViewPdfUrl (  string roomID
                                                       , string participantEmail
                                                       , string participantPIN
                                                       , string storedFileID ) 
       {
     
        var pdfFileValue = HttpApplication.createLinkNonUrlEncoded (  FILE_SHARE_URL_BASE
                                                                    , new NameValue(Constants.PARM_ROOM_ID,        roomID)   
                                                                    , new NameValue(Constants.PARM_ROOM_PART_UID,  participantEmail)   
                                                                    , new NameValue(Constants.PARM_ROOM_PART_PIN,  participantPIN)  
                                                                    , new NameValue(MBA.StoredFiles.PARAM_FILE_ID, storedFileID)
                                                                    );
                           
        return HttpApplication.createLink (MBA.StoredFiles.PDF_VIEWER_URL_BASE, new NameValue(@"file",pdfFileValue));
    }

    /***************************************************************************
     * generateSharedFileDownloadPdfUrl */
    /**
     * Generates the complete url needed to download the file
     * The handler sets the content dispositon appropriately to force a download
     ****************************************************************************/
    public static string generateSharedFileDownloadPdfUrl (  string roomID
                                                           , string participantEmail
                                                           , string participantPIN
                                                           , string storedFileID ) 
    {
           
        return HttpApplication.createLink (  FILE_SHARE_URL_BASE
                                           , new NameValue(Constants.PARM_ROOM_ID,        roomID)   
                                           , new NameValue(Constants.PARM_ROOM_PART_UID,  participantEmail)   
                                           , new NameValue(Constants.PARM_ROOM_PART_PIN,  participantPIN)  
                                           , new NameValue(MBA.StoredFiles.PARAM_FILE_ID, storedFileID)
                                           );
    }
  
    /***************************************************************************
     * generateSharedFileContent */
    /**
     * Generates the list of shared files (if any)
     ****************************************************************************/
    public static string generateSharedFileContent (  SqlConnection connUsers
                                                    , DetailsLog    log
                                                    , UserInfo      uInfo
                                                    , string        appName
                                                    , ref TeleCommSessionParticipant tsp ) 
    {

      if (uInfo == null) {     
        uInfo = new UserInfo();
        uInfo.userid    = 0;
        uInfo.userGroup = 0;
        uInfo.userRank  = 0;
      }
     
     var sharedFiles = viewList (  connUsers
                                 , log
                                 , uInfo
                                 , appName
                                 , tsp.sessionID );
     
     if (sharedFiles.Count == 0) return @"";
     
      var sb = new StringBuilder();
           
      sb.Append(@"<ul class=""telecomm-meeting-files row"">");

      foreach (var sharedFile in sharedFiles) 
      {
        var crossSessionfileID = @"file" + sharedFile.id.ToString();
    
        var fileViewUrl = generateSharedFileViewPdfUrl     (tsp.roomID,tsp.participantEmail,tsp.participantPIN,sharedFile.uploadID.ToString());
        var fileDownUrl = generateSharedFileDownloadPdfUrl (tsp.roomID,tsp.participantEmail,tsp.participantPIN,sharedFile.uploadID.ToString());

        sb.AppendFormat(@"<li class=""telecomm-meeting-file col"">");
        sb.AppendFormat(@"<span class=""telecomm-meeting-file-name"">");
        sb.AppendFormat(@"<a id=""{0}"" class=""telecomm-meeting-file-view"" title=""{3}"" href=""{1}"">{2}</a>",crossSessionfileID, fileViewUrl, sharedFile.name,sharedFile.description);
        sb.AppendFormat(@"</span>");

        if (tsp.participantIsFacilitator == true) {
          sb.AppendFormat(@"<button type=""button"" class=""telecomm-meeting-file-share btn btn-success btn-sm"">Show</button>",crossSessionfileID);
        }
        
        sb.AppendFormat(@"<a class=""telecomm-meeting-file-download btn btn-primary btn-sm"" target=""_blank"" href=""{0}"">Download</a>", fileDownUrl);
        sb.AppendFormat(@"</li>");       
      }

      sb.Append(@"</ul>");                  
      return sb.ToString();

    }
    


   } 
}