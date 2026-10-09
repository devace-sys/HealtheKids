using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace MBA
{
	
  /***************************************************************************
   * Credentials */
  /**
   * Methods to manage user credentials or sessions.
   ***************************************************************************/
 
  public class Credential
  {
    
    /***************************************************************************
     * generateDirectLoginLink */
    /**
     * Generates link that instructs login page to just prompt for password
     * 
     * @param    userName     The username
     * @return   ReturnWebUser
     ***************************************************************************/   

    public static string generateDirectLoginLink (string userName = @"")
    {
      return HttpApplication.createLink(  MBA.Constants.HOME_PUBLIC
                                        , new NameValue(Constants.PARM_UID,userName));    
    }

    /***************************************************************************
     * generateDirectLoginToPageLink */
    /**
     * Generates link that instructs login page to just prompt for password and
     * takes user straight to gotoPage on login
     * 
     * @param    userName     The username
     * @parm     gotoPage     The private page to goto
     * @return   ReturnWebUser
     ***************************************************************************/
    public static string generateDirectLoginToPageLink (string gotoPage = @"")
    {
      return generateDirectLoginToPageLink(String.Empty,gotoPage);
    }

    public static string generateDirectLoginToPageLink (string userName = @"", string gotoPage = @"")
    {
      return HttpApplication.createLink (  MBA.Constants.HOME_PUBLIC
                                         , new NameValue(Constants.PARM_UID,      userName)
                                         , new NameValue(Constants.PARM_GOTO_PAGE,gotoPage));
            
                                           // TODO: a lot of existing email notifs (it seems) are failing silently in the for loop
                                           // because the page destination here is null/empty;
                                           // we need a catch{} block to create the default login page link when the JSON is empty
    }

   /***************************************************************************
    * generateSessionExpiredLink */
   /**
    * @return   string
    ***************************************************************************/   
    public static string generateSessionExpiredLink() {
      var msg = Return.RET_INFO + "|" + Messages.SESSION_EXPIRED;          
      return HttpApplication.createLink(Constants.HOME_PUBLIC, new NameValue(Constants.PARM_MSG, msg));         
    }

    /***************************************************************************
     * webLogin */
    /**
     * Log a web user in
     * 
     * @param    username     The username
     * @param    password     The password
     * @param    ipAddress    The users IP address
     * @param    appName      The application name
     * @return   ReturnWebUser
     ***************************************************************************/   

    public static ReturnWebUser webLogin (  SqlConnection   connUsers
                                          , SqlConnection   connMBA
                                          , DetailsLog      log
                                          , string          username
                                          , string          password
                                          , RequestResponse rr
                                          , string          appName )
    {
      /*----------------------------
       * Validate incoming parameters
       *----------------------------*/

      string valUsername   = Validate.reqString (username,     Messages.BAD_UID_PWD);  // TODO: Check for valid email when all non email accounts are cleaned up
      string valPassword   = Validate.reqString (password,     Messages.BAD_UID_PWD);
      string valUserIP     = Validate.reqString (rr.userIP,    Messages.MISSING_USER_IP);      
      string valUserAgent  = Validate.optString (rr.userAgent, Messages.MISSING_USER_AGENT);
      string valAppName    = Validate.reqString (appName,      Messages.NO_APP_NAME);
      
      /*----------------------------
       * Generate token
       *----------------------------*/

      string valToken = generateNewToken (valUsername, valUserIP);
      
      /*----------------------------
       * Setup databse command
       * for login attempt
       *----------------------------*/
      
      List<SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@Username",                  SqlDbType.NVarChar, valUsername,                   ParameterDirection.Input,256));
      parms.Add(Database.SqlParm("@Password",                  SqlDbType.NVarChar, valPassword,                   ParameterDirection.Input,128));
      parms.Add(Database.SqlParm("@Token",                     SqlDbType.VarChar,  valToken,                      ParameterDirection.Input,100));
      parms.Add(Database.SqlParm("@UserIP",                    SqlDbType.VarChar,  valUserIP,                     ParameterDirection.Input,500));
      parms.Add(Database.SqlParm("@UserAgent",                 SqlDbType.VarChar,  valUserAgent,                  ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@AppName",                   SqlDbType.VarChar,  valAppName,                    ParameterDirection.Input,50));
      parms.Add(Database.SqlParm("@NumPwdAttemptsAllowed",     SqlDbType.SmallInt, Rules.MAX_NUM_LOGIN_ATTEMPTS,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@RulSessionExpiresInMins",   SqlDbType.SmallInt, Rules.MAX_IDLE_SESSION_MIN,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@RulTokenExpiresInHours",    SqlDbType.SmallInt, Rules.MAX_TOKEN_VALID_HRS,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@RulPasswordExpires",        SqlDbType.Bit,      Rules.PASSWORDS_EXPIRE,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@RulPasswordExpiresInDays",  SqlDbType.SmallInt, Rules.MAX_PASSWORD_VALID_DAYS, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@MsgAccountLocked",          SqlDbType.VarChar,  Messages.ACCOUNT_LOCKED,       ParameterDirection.Input,1000));
      parms.Add(Database.SqlParm("@MsgAccountNotFound",        SqlDbType.VarChar,  Messages.BAD_UID_PWD,          ParameterDirection.Input,1000));
      
      /*----------------------------
       * Execute command
       * Attempt login
       *----------------------------*/
      
      try
      {
        ReturnDB rd = Database.execSproc(connUsers, log, "Web_Login", parms);      
      }
      catch (Exception e)
      {

        /*----------------------------
         * Check the exception type
         *----------------------------*/

        if (e.GetType() == typeof(PasswordLock))
        {
          
          /*----------------------------
           * Its a password lock !
           *
           * Retrieve the users email
           * It should be their username
           * and it should have been passed
           * back in the exception message
           * from the email column 
           *----------------------------*/

          string em = "";
          
          if (PatternMatch.REGEX_EMAIL.IsMatch(e.Message))
          {
            em = e.Message;
          }
          
          /*----------------------------
           * No email on file
           *----------------------------*/
          
          else
          {
            em = "";          
          }
          
          /*----------------------------
           * If we have an email
           * address send the user a message
           * letting them know what to do
           * next and throw a new exception
           * with an appropriate warning
           *----------------------------*/

          if (!Util.IsNullOrEmpty(em))
          {
            
            string lnk = HttpApplication.createLink(Constants.FORGOT_MY_PASSWORD,false);
            string app = Util.nameCase(Constants.APP_NAME);
            string ttl = Util.createMessageString(Messages.PASSWORD_LOCKED_TITLE, app);
            string msg = Util.createMessageString(Messages.PASSWORD_LOCKED_BODY,  app, lnk);
            string retStatus = "";
            Email.sendMail(em, ttl, msg, true, out retStatus);          
            throw new Warning(Messages.PASSWORD_LOCKED);
          }

          /*----------------------------
           * We don't have an email
           * ask the user to contact us
           *----------------------------*/

          else
          {
            throw new Warning(Messages.PASSWORD_LOCKED_NO_EMAIL);
          }
        }
        else
        {
          /*----------------------------
           * It is some other issue
           * pass the exception along
           *----------------------------*/
          
          throw e;
        }
      }

      /*----------------------------
       * If we reach this point
       * the login attempt was 
       * succesful.  Retrieve the
       * users data using their newly
       * issued token and exit.
       *----------------------------*/
      
      ReturnWebUser wu = retrieveUserData (connUsers, connMBA, log, valToken, Constants.CREDENTIAL_UID_PWD, appName, rr);
      return wu;
    } 

    /***************************************************************************
     * webLogout */
    /**
     * Log a web user out
     * 
     * @param    tokenPassed  The security token
     * @param    tokenClient  The token client
     * @return   ReturnWebUser
     ***************************************************************************/   

    public static ReturnWebUser webLogout(  SqlConnection connUsers
                                          , DetailsLog log
                                          , string tokenPassed
                                          , string tokenClient)
    {
      string valTokenPassed = Validate.reqString(tokenPassed,Messages.LOGOUT_FAIL);
      string valTokenClient = Validate.reqString(tokenClient,Messages.LOGOUT_FAIL);

      if (String.Compare(valTokenPassed,valTokenClient) != 0) {throw new Exception(Messages.LOGOUT_FAIL);}
      
      // Setup sproc parameters for our login      
      
      List<SqlParameter> parms = new List<SqlParameter>();
      parms.Add(Database.SqlParm("@Token", SqlDbType.VarChar, valTokenPassed, ParameterDirection.Input,100));      
      
      // Attempt logout.      
      
      Database.execSproc(connUsers,log,"Web_Logout", parms);      
      ReturnWebUser so      = new ReturnWebUser();
      so.CredentialProvided = Constants.CREDENTIAL_LOGOUT;
      
      return so;
    }

    /***************************************************************************
     * webSessionValidate */
    /**
     * Used to validate a session via security token
     * 
     * @param    token        The security token
     * @param    appName      The application name
     * @return   ReturnWebUser
     ***************************************************************************/   

    public static ReturnWebUser webSessionValidate (  SqlConnection connUsers
                                                    , SqlConnection connMBA
                                                    , DetailsLog log
                                                    , string token
                                                    , RequestResponse rr
                                                    , string appName )
    {
      
      string valToken      = Validate.reqString (token,        Messages.BAD_SESSION);
      string valAppName    = Validate.reqString (appName,      Messages.NO_APP_NAME);
      string valUserIP     = Validate.reqString (rr.userIP,    Messages.MISSING_USER_IP);      
      string valUserAgent  = Validate.optString (rr.userAgent, Messages.MISSING_USER_AGENT);

      // Setup sproc parameters for our session validation
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@Token",                   SqlDbType.VarChar,  valToken,                   ParameterDirection.Input,100));      
      parms.Add(Database.SqlParm("@AppName",                 SqlDbType.VarChar,  valAppName,                 ParameterDirection.Input,50));      
      parms.Add(Database.SqlParm("@UserIP",                  SqlDbType.VarChar,  valUserIP,                  ParameterDirection.Input,500));
      parms.Add(Database.SqlParm("@UserAgent",               SqlDbType.VarChar,  valUserAgent,               ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@RulSessionExpiresInMins", SqlDbType.SmallInt, Rules.MAX_IDLE_SESSION_MIN, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@MsgAccountLocked",        SqlDbType.VarChar,  Messages.ACCOUNT_LOCKED,    ParameterDirection.Input,1000));
      parms.Add(Database.SqlParm("@MsgSessionExpire",        SqlDbType.VarChar,  Messages.SESSION_EXPIRED,   ParameterDirection.Input,1000));

      // Attempt session validation, exception will be thrown if unsuccesfull

      Database.execSproc(connUsers,log,"Web_Validate", parms);
      
      // Retrieve user data.  Exception will be thrown if unsuccesful
      
      ReturnWebUser wu = retrieveUserData(connUsers, connMBA, log, valToken, Constants.CREDENTIAL_TOKEN, appName, rr);

      return wu;
    }
    
    /***************************************************************************
     * webAppTransfer*/
    /**
     * Used from app to app transfers
     * 
     * @param    token        The security token
     * @param    appName      The application name
     * @return   ReturnWebUser
     ***************************************************************************/   

    public static ReturnWebUser webAppTransfer (  SqlConnection connUsers
                                                 , SqlConnection connMBA
                                                 , DetailsLog log
                                                 , string username
                                                 , string token
                                                 , RequestResponse rr
                                                 , string appName )
    { 
      
     
      //rr.wu.usr.userName

      string valUsername   = Validate.reqString (username,     Messages.BAD_UID_PWD);  // TODO: Check for valid email when all non email accounts are cleaned up
      string valToken      = Validate.reqString (token,        Messages.BAD_SESSION);
      string valAppName    = Validate.reqString (appName,      Messages.NO_APP_NAME);
      string valUserIP     = Validate.reqString (rr.userIP,    Messages.MISSING_USER_IP);      
      string valUserAgent  = Validate.optString (rr.userAgent, Messages.MISSING_USER_AGENT);

      // Setup sproc parameters for our app transfer request
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@Username",                  SqlDbType.NVarChar, valUsername,                ParameterDirection.Input,256));
      parms.Add(Database.SqlParm("@Token",                     SqlDbType.VarChar,  valToken,                   ParameterDirection.Input,100));      
      parms.Add(Database.SqlParm("@AppName",                   SqlDbType.VarChar,  valAppName,                 ParameterDirection.Input,50));      
      parms.Add(Database.SqlParm("@UserIP",                    SqlDbType.VarChar,  valUserIP,                  ParameterDirection.Input,500));
      parms.Add(Database.SqlParm("@UserAgent",                 SqlDbType.VarChar,  valUserAgent,               ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@MsgSubscriptionRequired",   SqlDbType.VarChar,  Messages.SUBSCRIPTION_REQUIRED,   ParameterDirection.Input,1000));
      parms.Add(Database.SqlParm("@MsgSessionExpire",          SqlDbType.VarChar,  Messages.SESSION_EXPIRED,          ParameterDirection.Input,1000));

      // Verify user has access to app.  Subscription required exception will be thrown if user does not

      Database.execSproc(connUsers,log,"Web_App_Transfer", parms);
      
      // Retrieve user data.  Exception will be thrown if unsuccesful
      
      ReturnWebUser wu = retrieveUserData(connUsers, connMBA, log, valToken, Constants.CREDENTIAL_TOKEN, appName, rr);

      return wu;
    }

    /***************************************************************************
     * webChangePassword */
    /**
     * User changes their own password or requests a new password
     * 
     * @param    appName        The application name
     * @param    changeType     Change type
     * @param    email          Users login
     * @param    token          The security token
     * @param    oldPassword    Users old password
     * @param    newPassword1   New password
     * @param    newPasswod2    New password
     *
     * @return   ReturnActionRequest
     ***************************************************************************/   
    
    public static ReturnActionRequest webChangePassword (SqlConnection connUsers, DetailsLog log, 
                                                      string appName, 
                                                      int    changeType,
                                                      string email,
                                                      string token,
                                                      string oldPassword,
                                                      string newPassword1,
                                                      string newPassword2,
                                                      string validateRec)
    {
       
      string vToken        = null;      
      string vOldPassword  = null; 
      string vNewPassword  = null;
      string vEmail        = null;
      
      /*-------------------------------
       * Validate required and 
       * optional parameters
       *------------------------------*/   

      string  vAppName   = Validate.reqString (appName,      Messages.NO_APP_NAME);     
      bool    vValidate  = Validate.reqFlag   (validateRec,  Messages.INVALID_VALIDATE_FLAG);

      /*-------------------------------
       * Logged in user requesting
       * their own password change
       *------------------------------*/   

      if (changeType == Constants.PWD_CHANGE_TYPE_USER)
      {
        /*-------------------------------
         * Validate token and old password
         *------------------------------*/   
        
        vToken        = Validate.reqString (token,       Messages.BAD_SESSION);
        vOldPassword  = Validate.reqString (oldPassword, Messages.INVALID_PASSWORD_OLD);
      
       /*-------------------------------
        * Validate password and make sure
        * its not the same as the old one
        *------------------------------*/   
      
        vNewPassword = Validate.reqNewPassword (newPassword1, newPassword2);
        if (vNewPassword == vOldPassword)  throw new Critical(Messages.INVALID_PASSWORD_SAME);

      }

      /*-------------------------------
       * Public password reset request
       *------------------------------*/   

      if (changeType == Constants.PWD_CHANGE_TYPE_PUBLIC)
      {
        /*-------------------------------
         * Validate email
         * 
         * TODO: We are validating a string
         * change this to an email validate
         * when we can get rid of the non
         * email user names
         *------------------------------*/   

        vEmail = Validate.reqString (email, Messages.INVALID_EMAIL); 
        
        /*-------------------------------
         * Generate temporary password
         *------------------------------*/   

        vNewPassword = PasswordMaker.makePassword(Rules.PWD_MIN_LENGTH);
      
      }
   
      /*-------------------------------
       * Create output class
       *------------------------------*/   

      ReturnActionRequest so = new ReturnActionRequest();

      /*----------------------------
       * Setup database call
       *----------------------------*/
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@changeType",    SqlDbType.SmallInt, changeType,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@UserName",      SqlDbType.NVarChar, vEmail,        ParameterDirection.Input, 256));      
      parms.Add(Database.SqlParm("@Token",         SqlDbType.VarChar,  vToken,        ParameterDirection.Input, 100));      
      parms.Add(Database.SqlParm("@OldPassword",   SqlDbType.NVarChar, vOldPassword,  ParameterDirection.Input, 128));      
      parms.Add(Database.SqlParm("@NewPassword",   SqlDbType.NVarChar, vNewPassword,  ParameterDirection.Input, 128));      
      parms.Add(Database.SqlParm("@AppName",       SqlDbType.VarChar,  vAppName,      ParameterDirection.Input, 50));      
      parms.Add(Database.SqlParm("@validateRec",   SqlDbType.Bit,      vValidate,     ParameterDirection.Input));   
    
      parms.Add(Database.SqlParm("@MsgNotAllowed",      SqlDbType.VarChar,  Messages.ACCESS_DENIED,          ParameterDirection.Input,1000));
      parms.Add(Database.SqlParm("@MsgPasswordNoMatch", SqlDbType.VarChar,  Messages.OLD_PASSWORD_NOT_FOUND, ParameterDirection.Input,1000));
      parms.Add(Database.SqlParm("@MsgAccountNotFound", SqlDbType.VarChar,  Messages.ACCESS_DENIED,          ParameterDirection.Input,1000));
      
      parms.Add(Database.SqlParm("@confirmEmail",  SqlDbType.NVarChar, null,  ParameterDirection.Output, 256));
      parms.Add(Database.SqlParm("@recordID",      SqlDbType.BigInt,   null,  ParameterDirection.Output));
 
      /*----------------------------
       * Execute command
       *----------------------------*/
      
      ReturnDB rd = Database.execSproc(connUsers,log,"Web_Change_Password", parms);

      /*----------------------------
       * Extract results from db cmd
       *----------------------------*/
      
      so = (ReturnActionRequest) Database.convertParameters(rd,typeof(ReturnActionRequest));

      /*----------------------------
       * Pass back email and new
       * password value if the
       * change type is public
       * or admin and we are not
       * validating
       *----------------------------*/
      
      if (((changeType == Constants.PWD_CHANGE_TYPE_PUBLIC) || (changeType == Constants.PWD_CHANGE_TYPE_ADMIN)) && (!vValidate))
      {
        if (Util.IsNullOrEmpty(so.confirmEmail)) so.confirmEmail = email;
        string lnk = MBA.HttpApplication.createLink(MBA.Constants.CHANGE_MY_PASSWORD, new NameValue(Constants.PARM_CMD,Constants.CMD_LOGIN), new NameValue(Constants.PARM_UID,vEmail), new NameValue(Constants.PARM_PWD,vNewPassword)); 
        string app = Util.nameCase(Constants.APP_NAME);
        string ttl = Util.createMessageString(Messages.PASSWORD_RESET_TITLE, app);
        string msg = Util.createMessageString(Messages.PASSWORD_RESET_BODY,  app, vNewPassword, lnk);
        string retStatus = "";
        Email.sendMail(so.confirmEmail, ttl, msg, true, out retStatus);          
      }
      
      /*----------------------------
       * Return results
       *----------------------------*/

      return so;

    }
    
    private static void initialAppEntryTasks(ref RequestResponse rd, bool raiseEarlyExit)
    {
         /* If the users password must be changed early exit to change password page */
        
         if (rd.wu.usr.passwordMustBeChanged == true)
         {                
           rd.earlyExitReason = Constants.EARLY_EXIT_CHANGE_PASSWORD;
           rd.userJustLoggedIn = true;
           rd.doNotShowUserToDoNotices = true;
           if (raiseEarlyExit) throw new EarlyExit();
           return;
         }
         
         
         /* Anything else continue with early exit login */

          rd.doNotShowUserToDoNotices = false;
          rd.earlyExitReason = Constants.EARLY_EXIT_LOGIN;
          if (raiseEarlyExit) throw new EarlyExit();
          return;
    }

    public static void handleSessionLoginLogout (  string              appName 
                                                 , bool                raiseEarlyExit
                                                 , SqlConnection       dbConnUser
                                                 , SqlConnection       dbConnApp
                                                 , DetailsLog          log
                                                 , ref RequestResponse rd 
                                                 , ref ReturnWebUser   wu )
    {            
      /* Logout */
            
      if (HttpApplication.clientLogoutPasssed())
      {
        rd.credentialProvided = Constants.CREDENTIAL_LOGOUT;
        wu = Credential.webLogout(dbConnUser,log,HttpApplication.clientToken(),HttpApplication.clientToken());
        rd.loggedIn     = false;
        rd.credentialOK = true;
        rd.wu           = wu;
        rd.earlyExitReason = Constants.EARLY_EXIT_LOGOUT;
        if (raiseEarlyExit) throw new EarlyExit();
        return;
       }
            
       // Login 

       if (HttpApplication.clientLoginPassed(ref rd))
       {
         rd.credentialProvided = Constants.CREDENTIAL_UID_PWD;
         wu = Credential.webLogin(dbConnUser,dbConnApp,log,HttpApplication.clientUid(),HttpApplication.clientPwd(), rd, appName);
         rd.credentialOK = true;
         rd.loggedIn     = true;
         rd.wu           = wu;         
         initialAppEntryTasks(ref rd, raiseEarlyExit);
         return;              
       }
       
       /* Application transfer */
        
       if (HttpApplication.clientAppTransferFlagPassed())
       {         
         rd.credentialProvided = Constants.CREDENTIAL_TOKEN;
         wu = webAppTransfer (dbConnUser, dbConnApp, log, HttpApplication.clientUid(), HttpApplication.clientToken(), rd, appName);         
         rd.credentialOK = true;
         rd.loggedIn     = true;
         rd.wu           = wu;
         initialAppEntryTasks(ref rd, raiseEarlyExit);
         return;                
       }

       return;
   }

  /*#############################################################################
    # 
    #  Internal Helper Functions
    # 
    #############################################################################*/
    
    /***************************************************************************
     * retrievePractitionerData */
    /**
     * Note: We are not able to use the load method in Practitioners in the 
     * Spedmon projec because of project reference issues.  This UDF is also
     * returning additional data that the practiitoner view/load does not return
     * such as pending supervision requests, etc.
     ***************************************************************************/  

    protected static Practitioner retrievePractitionerData  (  SqlConnection connApp
                                                              , DetailsLog  log
                                                              , long        pracID )
    {

        Practitioner so = new Practitioner();
        string sql = @"select top 1 * from dbo.PRAC_REC_VIEW (@pracID)";
        List<SqlParameter> parms = new List<SqlParameter>();      
        parms.Add(Database.SqlParm("@pracID",  SqlDbType.BigInt, pracID, ParameterDirection.Input, 50));       
        ReturnDB rd  = Database.execQuery(connApp, log, sql, false, parms);
        so           = (Practitioner) Database.convertRecord(rd.records,typeof(Practitioner));
        return so;
    }
    
    /***************************************************************************
     * retrieveCybhiConsortiumMembers */
    /**
     * Note: We are performing a non standard direct call of a viewCore UDF
     * The reason for this is the view udf may have additional columns added
     * to it and we only need the basic list of consortium members at this level
     * 
     ***************************************************************************/  
    private static List<ClientConsortiumMember> retrieveCybhiConsortiumMembers (  SqlConnection connApp
                                                                                 , DetailsLog   log
                                                                                 , long         clientid )
    {

       var recs = new List<ClientConsortiumMember>();       
       
       string sql = @"select * from dbo.CYBHI_CONSORTIUM_MEMBERS_VIEW_CORE (null,null,null,@consortiumLeadClientID)";

       var parms = new List<SqlParameter>();      

       parms.Add(Database.SqlParm("@consortiumLeadClientID", SqlDbType.BigInt, clientid, ParameterDirection.Input));
       
       ReturnDB rd  = Database.execQuery(connApp, log, sql, false, parms);
       
       List<Object> slo = Database.convertRecordsToList (ref rd.records, typeof(ClientConsortiumMember));
       foreach (var o in slo) {
            recs.Add((ClientConsortiumMember) o);
       }
       return recs;
    }


    /***************************************************************************
     * retrieveRelatedClientsDataForSelpa */
    /**
     * 
     * Note: We are not able to use the viewList method in SelpaRelatedClients 
     * in the Spedmon project because of project reference issues and we 
     * also want to potentially return additional data in the future.
     ***************************************************************************/  
    private static List<SelpaRelatedClient> retrieveRelatedClientsDataForSelpa (  SqlConnection connApp
                                                                                 , DetailsLog   log
                                                                                 , long         selpaCode )
    {

       var recs = new List<SelpaRelatedClient>();       
       
       string sql = @"select * from dbo.SELPA_RELATED_CLIENTS_VIEW (null,null,null,@selpaCode)";
       var parms = new List<SqlParameter>();      
       parms.Add(Database.SqlParm("@selpaCode",  SqlDbType.Int, selpaCode, ParameterDirection.Input));       
       ReturnDB rd  = Database.execQuery(connApp, log, sql, false, parms);
       List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(SelpaRelatedClient));
        foreach (var o in slo) {
            recs.Add((SelpaRelatedClient) o);
        }
        return recs;
    }

    /***************************************************************************
     * retrieveAssociatedPatientPersonsData */
    /**
     * Note: We are not able to use the viewList method in PatientPersons in the 
     * Spedmon project because of project reference issues and we also want to
     * return additional data.
     * 
     * TODO: This UDF will return additional data (such as auth requests pending, etc)
     ***************************************************************************/  
    private static List<PatientPerson> retrieveAssociatedPatientPersonsData (  SqlConnection connApp
                                                                               , DetailsLog  log
                                                                               , long?       userIDIntAssociation )
    {
       var recs = new List<PatientPerson>();       
       if (!userIDIntAssociation.HasValue) return recs;
       string sql = @"select * from dbo.PATIENT_PERSON_RECS_VIEW (@userIDIntAssociation)";
       var parms = new List<SqlParameter>();      
       parms.Add(Database.SqlParm("@userIDIntAssociation",  SqlDbType.BigInt, userIDIntAssociation.Value, ParameterDirection.Input, 50));       
       ReturnDB rd  = Database.execQuery(connApp, log, sql, false, parms);
        List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(PatientPerson));
        foreach (var o in slo) {
            recs.Add((PatientPerson) o);
        }
        return recs;
    }
    
    /***************************************************************************
     * retrieveAssociatedPatientData */
    /**
     * Note: We are not able to use the viewList method in PatientPersons in the 
     * Spedmon project because of project reference issues and we also want to
     * return additional data.
     * 
     * TODO: This UDF will return additional data (such as auth requests pending, etc)
     ***************************************************************************/  
    private static List<PatientUserAccount> retrieveAssociatedPatientUserAccountData (  SqlConnection connApp
                                                                                      , DetailsLog  log
                                                                                      , long?       userIDIntAssociation )
    {
       var recs = new List<PatientUserAccount>();       
       if (!userIDIntAssociation.HasValue) return recs;
       string sql = @"select * from dbo.PATIENT_USER_ACCOUNTS_RECS_VIEW (@userIDIntAssociation)";
       var parms = new List<SqlParameter>();      
       parms.Add(Database.SqlParm("@userIDIntAssociation",  SqlDbType.BigInt, userIDIntAssociation.Value, ParameterDirection.Input, 50));       
       ReturnDB rd  = Database.execQuery(connApp, log, sql, false, parms);
        List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(PatientUserAccount));
        foreach (var o in slo) {
            recs.Add((PatientUserAccount) o);
        }
        return recs;
    }

    /***************************************************************************
     * retrieveUserData */
    /**
     * 
     * 
     ***************************************************************************/  

    protected static ReturnWebUser retrieveUserData (  SqlConnection connUsers
                                                     , SqlConnection connApp
                                                     , DetailsLog    log
                                                     , string        token
                                                     , int           credentialProvided
                                                     , string        appName
                                                     , RequestResponse rr )
    {
      try
      {
      
        /*-------------------------------
         * For a given token we retrieve
         * user data from the database
         *------------------------------*/ 

        ReturnWebUser so        = new ReturnWebUser();
        so.CredentialProvided   = credentialProvided;                        
        so.usr = Users.load(connUsers,log,appName,token);
        
        /*-------------------------------
         * Populate uInfo object that
         * is passed into methods
         *------------------------------*/ 
                                    
        UserInfo uInfo = new UserInfo();
        UserInfo.retrievePartialUserInfo(ref so.usr, ref uInfo);
        
        /*-------------------------------
         * Fetch user preferences
         *------------------------------*/ 
        
        List<UserPreference> lup = UserPreferences.viewList(connUsers, log, uInfo);
        so.preferences = lup;
        
        /*-------------------------------
         * Based on the users group
         *------------------------------*/
        
         //TODO: Put appname switch logic in here or a delegate to provide app specific processing

        /*-------------------------------
         * User is a client
         *------------------------------*/

        if (so.usr.userGroupID == Constants.USER_GROUP_CLIENT)
        {          
          
          /*-------------------------------
           * User is a practitioner
           *------------------------------*/          
           
          if (so.usr.roleID == Constants.ROLE_LEA_PROVIDER_ID)
          { 
            
            so.pr = retrievePractitionerData (connApp, log, so.usr.pracID);
            
            /*-------------------------------
             * If this practitioner has been
             * deactivated, get out
             *------------------------------*/

            if (so.pr.active == false) throw new MBA.Warning(Messages.ACCOUNT_LOCKED);

          }

          /*-------------------------------
           * User is LEA coordinator
           * or CYBHI coordinator
           *------------------------------*/          
         
          if    ((so.usr.roleID == Constants.ROLE_LEA_COORDINATOR_ID)
             || (so.usr.roleID  == Constants.ROLE_CYBHI_CORDINATOR_ID))
          {
            
            so.cybhiConsortiumIsLead  = so.usr.cybhiConsortiumBillingIsLead;
            so.cybhiConsortiumMembers = retrieveCybhiConsortiumMembers(connApp,log,so.usr.clientID);
          }          
        
        }
        
        else if (so.usr.userGroupID == Constants.USER_GROUP_SBSC)
        {
          /* Add specific processing for Practi-Cal staff here */
        }
        
        else if (so.usr.userGroupID == Constants.USER_GROUP_THIRD_PARTY_PERSON)
        {
          
           /* If this is a parent then get the associated patient person records that we will use to limit access to 
              those clients and patients the user be able to access */ 

           if (so.usr.roleID == Constants.ROLE_PARENT_GUARDIAN_ID)
           {
             so.associatedPatientPersons = retrieveAssociatedPatientPersonsData (connApp, log, so.usr.userIDInt);
           }
           
           /* If this is a patient then get the associated patient user account records that we will use to limit
            * access to those clients and patient the user will be able to access. */
           
           if (so.usr.roleID == Constants.ROLE_PATIENT_ID)
           {
             so.associatedPatientUserAccounts = retrieveAssociatedPatientUserAccountData(connApp, log, so.usr.userIDInt);
           }

           /* If this is a selpa user then get the associated client records that we will use to limit access to these clients */

           if (so.usr.roleID == Constants.ROLE_SELPA_USER_ID)
           {
              so.relatedClients = retrieveRelatedClientsDataForSelpa (connApp, log, so.usr.selpaCode);
           }
          
         /* TODO: Add logic here to help restrict access */
        
        }
        
        else 
        {
          /* Fallback for any user group that is not accounted for */
        }
        
        return so;
      }
      catch(Exception e)
      {
        throw(e);
      }
    }
        /*******************************************************************************************
         * getHMACSignature
         * produces a signed checksum
         *******************************************************************************************/
        public static string getHMACSignature(string privatekey, string message)
        {
            System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
            byte[] keyByte = encoding.GetBytes(privatekey);
            //Console.WriteLine("Key: " + ToReadableByteArray(keyByte));

            System.Security.Cryptography.HMACSHA1 hmacsha1 = new System.Security.Cryptography.HMACSHA1(keyByte);
            byte[] messageBytes = encoding.GetBytes(message);
            //Console.WriteLine("Message: " + ToReadableByteArray(messageBytes));
            byte[] hashmessage = hmacsha1.ComputeHash(messageBytes);
            //Console.WriteLine("Hash: " + ToReadableByteArray(hashmessage));
            return Convert.ToBase64String(hashmessage);

            // https://stackoverflow.com/questions/62285621/c-sharp-hmacsha1-vs-php-hash-hmac
        }

        /*******************************************************************************************
         * generateNewToken
           * Generates a brand new security token
           *******************************************************************************************/

        public static string generateNewToken(string userid)
    {
        return generateNewToken(userid, null);
    }


	protected static string generateNewToken(string userid, string ipaddr)
    {
			// The token must be unique per user, per user session.
      // This function generates a fairly unique token.

      // Convert user id to trimmed lowercase and users ip to a number sans periods
            string tempUid = userid.Trim().ToLower();
            string tempIP = "";
          if(!string.IsNullOrEmpty(ipaddr))
             tempIP = ipaddr.Replace(".", "");                                             
			// Generate random string sans url/query string unfriendly characters
            string tempStr = Util.TokenSafeString(Util.randomString(Util.RandomNumber(1,50)));
      // Generate random number
			Random r = new Random();                                                             
			double rd = r.NextDouble();
			string tempRD = rd.ToString().Replace(".","");
      // Generate random alpha numeric string that contains a time dependent element
            long i = 1;                                                                   
			foreach (byte b in Guid.NewGuid().ToByteArray()){i *= ((int)b + 1);}
      // Put it all together and trim it down to size
			string tempToken = string.Format("{0:x}", i - DateTime.Now.Ticks) + tempIP + tempRD + tempStr;
			if (tempToken.Length > 100) tempToken = tempToken.Substring(0,100);
      // Finally prepend the user id
           
            tempToken =  Util.TokenSafeString(tempUid) + "|" + tempToken;
			return tempToken;
      
      }




    }
}

