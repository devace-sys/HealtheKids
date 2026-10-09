using MBA.Security;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;

namespace MBA
{
  
  
  /***************************************************************************
   * UserAccount */
  /**
   **************************************************************************/
    
  public class UserAccount
  {
    public string userName;
    public string firstName;
    public string lastName;
    public string email;
    public string phone;
    public string pwd;
    public string districtOrClientName;
    public string helpOrQuestionsContactInfo;
    public string msgTemplateTitle;
    public string msgTemplateBody;
  }
  
  /***************************************************************************
   * NewUserAccount */
  /**
   **************************************************************************/
  
  public class NewUserAccount:UserAccount
  {
  }
  
  /***************************************************************************
   * NewUserAccounts */
  /**
   **************************************************************************/
  
  public class NewUserAccounts
  {
    public List<NewUserAccount> accounts;
  }

  /***************************************************************************
   * UserAssignedRole */
  /**
   **************************************************************************/

  public class UserAssignedRole 
  {
     public long   roleID;
	   public string roleUID;
     public int    roleRank;
		 public string roleName;
     public string roleNameLowered;
     public string roleShortName;
     public long   userGroupID;
		 public string userGroupName;
		 public int    userGroupRank;
		 public string appName;
  }
 
  /***************************************************************************
   * UserAssignedRoles */
  /**
   **************************************************************************/

  public class UserAssignedRoles
  {    
    public List<UserAssignedRole> roles;

    public static bool userHasPermittedRole (string[] permittedRoles, string userRoleName)
    {
      foreach (var permittedRole in permittedRoles) {
       if ( String.Compare (userRoleName,permittedRole,true) == 0) return true;           
      }
      return false;
    }

    public static bool userHasPermittedRole (ref string[] permittedRoles, ref UserAssignedRoles userAssignedRoles)
    {  
       foreach (var userAssignedRole in userAssignedRoles.roles) {
         foreach (var permittedRole in permittedRoles) {
           if ( String.Compare (userAssignedRole.roleName,permittedRole,true) == 0) return true;           
         }       
       }
       return false;
    }
    public static void userHasPermittedRole (ref string[] permittedRoles, ref UserAssignedRoles userAssignedRoles, string warningMessage)
    {  
       if (!userHasPermittedRole(ref permittedRoles, ref userAssignedRoles)) throw new Warning(warningMessage);
    }
  
  }

  /***************************************************************************
   * User */
  /**
   **************************************************************************/

  public class User:Person
  {

    public Guid    uid;
    public string  userName;
    //public string  userPassword;
    public string  appName;
    public string  roleName;
    public int     userGroupID;
    public int     userRank;
    public bool    pcalStaff;
	  public bool    implicitDataAccess;
	  public string  startingPage;
    public bool    sendUserEmailNotifications;        
    public long    pracID;
    public string  pracName;    
    public string  token;
    public long?   clientRepUserId;
    public string  clientRepFirstName;
    public string  clientRepLastName;
    public string  clientRepEmail;
    public string  clientRepPhone;
    public bool    passwordMustBeChanged;
    public int     passwordAgeInDays;
    public int     passwordExpiresIn;              // Calculated by method
    public int     numUnreadManPages;
        

    public string  allAssignedRolesDataJSON;
    public UserAssignedRoles allAssignedRolesData;  // Populated by method
    public bool    teleCommTeleHealthAccessGranted;
    public bool    teleCommTeleIEPAccessGranted;
    public bool    initialPasswordChangeCompleted;
    public DateTime sessionTokenExpires;

    public bool cybhiConsortiumBilling          = false;
	public long cybhiConsortiumLeadClientID     = 0;
    public bool cybhiConsortiumBillingIsLead    = false;

    [ScriptIgnore]
    public BitteTimePeople timeSheetUserInfo; // SBC added for TimeKeeper 
  }

  /***************************************************************************
   * Users */
  /**
   * System users.
   ***************************************************************************/

  public class Users:Entities
  {
    
    public const string URL_ASMX                    = "users.asmx";

    /***************************************************************************
     * changeMyPassword */
    /**
     * Allows a user to change their own password.
     * 
     * @param  oldpwd         Required, users old password
     * @param  newpwd1        Required, 1st entry of users new password
     * @param  newpwd2        Required, 2nd entry of users new password
     * @param  validaterec    Required, True=Yes, False=No
     * @return                ReturnActionRequest
     ***************************************************************************/                
    public static ReturnActionRequest changeMyPassword (SqlConnection connUsers, DetailsLog log, 
                                                      string appName, 
                                                      string token,
                                                      string oldPassword,
                                                      string newPassword1,
                                                      string newPassword2,
                                                      string validateRec)
    {
      return Credential.webChangePassword(connUsers, log, appName, Constants.PWD_CHANGE_TYPE_USER, null, token, oldPassword, newPassword1, newPassword2, validateRec);
    }

    /***************************************************************************
     * delete */
    /**
     * "Deletes" a user record
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   

    protected static ReturnSaveRecord delete (SqlConnection connUsers, DetailsLog log, UserInfo uInfo, 
                                              Object clientID, string appName,
                                              string editDelReason, string validateRec, string recID)
    {           
          
      
      /*----------------------------
       * Collect all of the parameters
       * that are specific to this
       * delete method.
       *----------------------------*/

      List<SqlParameter> parms  = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@clientID", SqlDbType.Int,      clientID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@appName",  SqlDbType.VarChar,  appName,  ParameterDirection.Input,50));  
      
      /*----------------------------
      * Call base method 
      *----------------------------*/

      return Entities.delete(connUsers,log,uInfo, editDelReason,validateRec,recID,"WEB_USER_Delete",ref parms);
    }


   /***************************************************************************
    * emailNewAccountsToNewUsers */
   /**
    * 
    * {0} District/Client name
    * {1} New user first Name
    * {2} New user last Name
    * {3} Username
    * {4} Password
    * {5} Login link
    * {6} Contact person
    * {7} Confidential Message
    ****************************************************************************/ 

   public static void emailNewAccountsToNewUsers (string jsonData)
   {
     NewUserAccounts accts = (NewUserAccounts) JSON.fromJSONString(jsonData,typeof(NewUserAccounts));
     emailNewAccountsToNewUsers(accts.accounts);
   }
     
   public static void emailNewAccountsToNewUsers (List<NewUserAccount> accounts)
   {
        foreach (NewUserAccount acct in accounts)
        {
            string lnk = MBA.HttpApplication.createLink(MBA.Constants.CHANGE_MY_PASSWORD, new NameValue(Constants.PARM_CMD,Constants.CMD_LOGIN), new NameValue(Constants.PARM_UID,acct.userName), new NameValue(Constants.PARM_PWD,acct.pwd)); 
            string app = Util.nameCase(Constants.APP_NAME);
            string ttl = acct.msgTemplateTitle;            
            string msg = String.Format(  acct.msgTemplateBody
                                       , acct.districtOrClientName
                                       , acct.firstName
                                       , acct.lastName
                                       , acct.userName
                                       , acct.pwd
                                       , lnk
                                       , acct.helpOrQuestionsContactInfo                              
                                       , Messages.CONFIDENTIAL_EMAIL );
            string retStatus = "";
            Email.sendMail(acct.email, ttl , msg, true, out retStatus);
        }          

   }
   
   /***************************************************************************
    * load */
   /**
    * Outputs data for a single user
    * 
    * @return                 User
    ***************************************************************************/ 
    
    public static User load (   SqlConnection connUsers
                                 , DetailsLog    log
                                 , UserInfo      uInfo
                                 , string        appName
                                 , string        recID)
    { 
      Type ut = typeof(User);
      return (User) Entities.load (connUsers, log, uInfo, recID, ut,
      delegate 
      {    
        return Users.view (connUsers,log,uInfo,appName,Entities.REC_VIEW_LOAD,false,recID,null,null,null,null,null,null,null,null,null,null);
      });      
    } 
        
    /***************************************************************************
     * load */
    /**
     * Outputs data for a single user
     * 
     * @return                 User
     ***************************************************************************/ 

    public static User load (   SqlConnection connUsers
                              , DetailsLog    log
                              , string        appName
                              , string        token )
    { 
     
      User wu = new User();
      UserInfo uInfo = new UserInfo();
      string vToken  = Validate.reqString(token,Messages.INVALID_TOKEN);          
      Type ut = typeof(User);            
      wu = (User) Entities.load (connUsers, log, uInfo, ut,
      delegate 
      {    
        return Users.view (connUsers,log,uInfo,appName,Entities.REC_VIEW_RAW,false,null,null,null,null,null,null,null,vToken,null,null,null);
      }); 
      
      /*-------------------------------
       * Calculate password expiration
       * and save it.
       *------------------------------*/ 
       
      int pwdExpireIn = Rules.MAX_PASSWORD_VALID_DAYS - wu.passwordAgeInDays; 
      if (pwdExpireIn < 0) pwdExpireIn = 0;
      wu.passwordExpiresIn = pwdExpireIn;
      
      /*-------------------------------
       * Deserialize assigned roles
       * into a list
       *------------------------------*/ 
      
       wu.allAssignedRolesData = (UserAssignedRoles) JSON.fromJSONString (  wu.allAssignedRolesDataJSON
                                                                          , typeof(UserAssignedRoles)
                                                                          , JsonLibrary.NEWTONSOFT );

      return wu;
    } 

   
    /***************************************************************************
     * forgotPassword */
    /**
     * Allows a user to request a new pasword from a public page.
     * 
     * @param  email          Users email or user name
     * @param  validaterec    Required, True=Yes, False=No
     * @return                ReturnActionRequest
     ***************************************************************************/  
              
    public static ReturnActionRequest forgotPassword (  SqlConnection connUsers
                                                      , DetailsLog log
                                                      , string appName
                                                      , string email
                                                      , string validateRec)
    {
      
      ReturnActionRequest so = new ReturnActionRequest();
      so = (ReturnActionRequest) Credential.webChangePassword(connUsers, log, appName, Constants.PWD_CHANGE_TYPE_PUBLIC, email, null, null, null, null, validateRec);      
      return so;
    }
        
    /***************************************************************************
     * save */
    /**
     * Creates a new or edits an existing user account
     * 
     * @param  username       User name
     * @param  password1      Password entered
     * @param  password2      Password entered again
     * @param  roleID         Users role
     * @param  lname          Users last name
     * @param  fname          Users first name
     * @param  email          Users email
     * @param  phone          Users phone number
     * @param  clientID       Users client record id
     * @param  personID       Entitiy ID of person to attach to this account
     * @return                ReturnSaveRecord
     ***************************************************************************/               
    
    protected static ReturnSaveRecordWithJSONData save (  SqlConnection connUsers
                                                        , DetailsLog log
                                                        , UserInfo uInfo
                                                        , string appName
                                                        , string username 
                                                        , string roleID
                                                        , string lname 
                                                        , string fname 
                                                        , string email
                                                        , string phone
                                                        , Object clientID 
                                                        , Object selpaCode
                                                        , Object personID
                                                        , string receiveEmailNotifications
                                                        , string saveType
                                                        , string validateRec                               
                                                        , string editDelReason
                                                        , string recID )
      {           
    
        /*----------------------------
         * Validate parameters specific
         * to this entity.save
         * and populate their
         * coresponding database
         * parameters
         *----------------------------*/
      
        List<SqlParameter> parms      = new List<SqlParameter>();  
   
        string  saveSproc    = "USERS_SAVE";

        string  vAppName                   = Validate.reqString      (appName,   Messages.NO_APP_NAME);
        string  vUserName                  = Validate.reqString      (username,  Messages.INVALID_USER_NAME);      
        int     vRoleID                    = Validate.reqInteger     (roleID,    Messages.INVALID_ROLE_ID);
        string  vLname                     = Validate.reqString      (lname,     Messages.INVALID_LNAME);
        string  vFname                     = Validate.reqString      (fname,     Messages.INVALID_FNAME);
        string  vEmail                     = Validate.reqEmail       (email,     Messages.INVALID_EMAIL);
        Object  vPhone                     = Validate.optPhoneNumber (phone,     Messages.INVALID_PHONE_NUMBER);
        bool    vReceiveEmailNotifications = Validate.reqFlag        (receiveEmailNotifications, @"Invalid value for receive email notifications");
        
        // Note: Validate flag and save type are needed to determine if we generate a password and email the user
        
        bool  vValidateRec = Validate.reqFlag    (validateRec,  Messages.INVALID_VALIDATE_FLAG);
        int   vSaveType    = Validate.reqInteger (saveType,     Messages.INVALID_SAVE_TYPE);
             
        parms.Add(Database.SqlParm("@appName",                    SqlDbType.VarChar,   vAppName,                   ParameterDirection.Input, 50));
        parms.Add(Database.SqlParm("@clientID",                   SqlDbType.Int,       clientID,                   ParameterDirection.Input));
        parms.Add(Database.SqlParm("@selpaCode",                  SqlDbType.Int,       selpaCode,                  ParameterDirection.Input));
        parms.Add(Database.SqlParm("@personID",                   SqlDbType.Int,       personID,                   ParameterDirection.Input));
        parms.Add(Database.SqlParm("@roleID",                     SqlDbType.Int,       vRoleID,                    ParameterDirection.Input));
        parms.Add(Database.SqlParm("@username",                   SqlDbType.NVarChar,  vUserName,                  ParameterDirection.Input, 256)); 
        parms.Add(Database.SqlParm("@pwdMinLen",                  SqlDbType.Int,       Rules.PWD_MIN_LENGTH,       ParameterDirection.Input));
        parms.Add(Database.SqlParm("@firstname",                  SqlDbType.NVarChar,  vFname,                     ParameterDirection.Input, 128));
        parms.Add(Database.SqlParm("@lastname",                   SqlDbType.NVarChar,  vLname,                     ParameterDirection.Input, 128));
        parms.Add(Database.SqlParm("@email",                      SqlDbType.NVarChar,  vEmail,                     ParameterDirection.Input, 256)); 
        parms.Add(Database.SqlParm("@phone",                      SqlDbType.NVarChar,  vPhone,                     ParameterDirection.Input, 256)); 
        parms.Add(Database.SqlParm("@receiveEmailNotifications",  SqlDbType.Bit,       vReceiveEmailNotifications, ParameterDirection.Input)); 
        
        /*----------------------------
         * Call base method which 
         * handles the rest and return
         * results
         *----------------------------*/  
         
        ReturnSaveRecordWithJSONData so = Entities.saveAndReturnJSONData (connUsers, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, Messages.DUP_USER, ref parms, delegate(){});
    
        /*----------------------------
         * Email the new user their
         * account if this is a new
         * record and we are actually 
         * saving
         *----------------------------*/  
               
        if ((!vValidateRec) && (vSaveType == Constants.SAVE_TYPE_NEW))
          emailNewAccountsToNewUsers (so.jsonData);          

        return so;

    }

    /***************************************************************************
     * view */
    /**
     * View users
     * 
     * @param  appName    Application name (from web.config or app.config)
     * @param  clientID   Client record id (if any)
     * @param  userName   Username
     * @param  email      User's email
     * @param  token      Security token (if any)
     * @return            ReturnDB
     ***************************************************************************/   

    protected static ReturnDB view(SqlConnection connUsers, DetailsLog log, UserInfo uInfo, string appName, int recViewType,
                                 bool   pagedOrTop,
                                 string idx,
                                 string canEdit,
                                 string active,
                                 Object clientID,
                                 string roleID,
                                 string userName,
                                 string email,
                                 string token,
                                 string lname, 
                                 string fname,
                                 defineCols dc)
    {
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      List<SqlParameter> parms     = new List<SqlParameter>();   
      string             viewUDF   = "[users].[dbo].USERS_VIEW(@userID, @userGroup, @userRank, @recID, @clientID, @roleID, @appName, @userName, @email, @token, @lname, @fname, @active, @canEdit)";
      
      Object             vAppName  = Validate.optString (appName,  Messages.NO_APP_NAME);
      Object             vUserName = Validate.optString (userName, Messages.INVALID_USER_NAME);
      Object             vEmail    = Validate.optEmail  (email,    Messages.INVALID_EMAIL);
      Object             vToken    = Validate.optString (token,    Messages.INVALID_TOKEN);
      Object             vRoleID   = Validate.optInteger(roleID,   Messages.INVALID_ROLE_ID);
      Object             vLname    = Validate.optString (lname);
      Object             vFname    = Validate.optString (fname);
               
      parms.Add(Database.SqlParm("@appName",  SqlDbType.VarChar,  vAppName,  ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt,   clientID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@roleID",   SqlDbType.BigInt,   vRoleID,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@username", SqlDbType.NVarChar, vUserName, ParameterDirection.Input, 256));
      parms.Add(Database.SqlParm("@email",    SqlDbType.NVarChar, vEmail,    ParameterDirection.Input, 256));
      parms.Add(Database.SqlParm("@token",    SqlDbType.VarChar,  vToken,    ParameterDirection.Input, 100));
      parms.Add(Database.SqlParm("@lname",    SqlDbType.VarChar,  vLname,    ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@fname",    SqlDbType.VarChar,  vFname,    ParameterDirection.Input, 50));
      
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connUsers, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
    }

   /***************************************************************************
    * viewTbl */
   /**
    * View users record data table
    * 
    * @param  appName     Application name (from web.config or app.config) 
    * @param  clientID    Client ID record (if any)
    * @return             ReturnDataTable
    ***************************************************************************/   
    
    protected static ReturnDataTable viewTbl (SqlConnection connUsers, DetailsLog log, UserInfo uInfo, bool paged, string pageNumber, string appName, Object clientID,string roleID, string lname, string fname, string canEdit, string active) 
    {
      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref  List<SqlParameter> parms)
      {
        ss.addDisplayColumn ("id as [id]");
        ss.addDisplayColumn ("dbo.RPT_BIT_TO_YN(active) as [Is\nActive]");
        ss.addDisplayColumn ("lastName   as [Last Name]");
        ss.addDisplayColumn ("firstName  as [First Name]");
        ss.addDisplayColumn ("userName   as [User Name]");
        ss.addDisplayColumn ("roleName   as [Role]");
        ss.addDisplayColumn ("clientName as [Client Name]");
        pageroworder = "[User Name]";
      };
      
      return Entities.viewTbl(connUsers, log, uInfo, paged, pageNumber,
        delegate{return Users.view (connUsers,log,uInfo, appName, Entities.REC_VIEW_TBL, paged, pageNumber, canEdit, active, clientID,roleID, null, null, null, lname, fname ,dc);}
        , @"Users - View"
        , Messages.CONFIDENTIAL
        );
    }

    /**************************************************************************
     * viewSel */
    /**
     * 
     ***************************************************************************/   

    public static ReturnSel viewSel (   SqlConnection connUsers
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , string        appName
                                      , bool          top
                                      , string        topSize
                                      , object        clientID
                                      , string        term )
    {
          
      /*----------------------------
       * Parse search term
       *----------------------------*/

     string vTerm    = Validate.optString (term);
     string lname    = "";
     string fname    = "";
     string other    = "";     
     
     Parse.searchTermToLastFirstOther(vTerm, out lname, out fname, out other); 
         
     /*----------------------------
      * Define our context column
      *----------------------------*/

     defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){              
       ss.addDisplayColumn("isnull(pracDispGroupName,roleName) as [context1]");
     };

     /*----------------------------
      * Call base method which
      * handles the rest and return
      * results
      *----------------------------*/

     return Entities.viewSel(  connUsers
                             , log
                             , uInfo
                             , top
                             , topSize
                             , delegate{ return Users.view (  connUsers
                                                            , log
                                                            , uInfo
                                                            , appName
                                                            , Entities.REC_VIEW_SEL
                                                            , top
                                                            , topSize
                                                            , ""
                                                            , "Y"
                                                            , clientID
                                                            , ""
                                                            , ""
                                                            , ""
                                                            , ""
                                                            , lname
                                                            , fname
                                                            , dc);});

    }

    /**************************************************************************
     * viewUserMessageContactsSel */
    /**
     * 
     * For client users we want to return what users.ViewSel normally returns
     * and the clients current client rep
     *
     * For PCAl users we want to return all available contacts
     ***************************************************************************/   
    public static ReturnSel viewUserMessageContactsSel (   SqlConnection connUsers
                                                          , DetailsLog    log
                                                          , UserInfo      uInfo
                                                          , string        appName
                                                          , bool          top
                                                          , string        topSize
                                                          , object        clientID
                                                          , string        term
                                                          , long?         primaryRepUserID
                                                          , long?         backupRepUserID)
    {
          
      /*----------------------------
       * Parse search term
       *----------------------------*/

      string vTerm    = Validate.optString (term);
      string lname    = "";
      string fname    = "";
      string other    = "";
      string contextColDefStr = "isnull(pracDispGroupName, roleName) as [context1]";

      Parse.searchTermToLastFirstOther(vTerm, out lname, out fname, out other); 
     
      /* If this is a practi-cal user then show all possible users in the system */

      if (uInfo.pcalStaff) {
         clientID = null;
         contextColDefStr = "trim(isnull(pracDispGroupName,roleName) + ' ' + isnull(clientName,'')) as [context1]";
      }

     /*----------------------------
      * Define our context column
      *----------------------------*/

     defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){              
       ss.addDisplayColumn(contextColDefStr);
     };

     /*----------------------------
      * Call base method which
      * handles the rest and return
      * results
      *----------------------------*/

     var so = Entities.viewSel(  connUsers
                               , log
                               , uInfo
                               , top
                               , topSize
                               , delegate{ return Users.view (  connUsers
                                                              , log
                                                              , uInfo
                                                              , appName
                                                              , Entities.REC_VIEW_SEL
                                                              , top
                                                              , topSize
                                                              , ""
                                                              , "Y"
                                                              , clientID
                                                              , ""
                                                              , ""
                                                              , ""
                                                              , ""
                                                              , lname
                                                              , fname
                                                              , dc);});

      /* If this is a non practi-cal user then show just users associated with the users client
       * and add the clients assigned reps to the contact list */

      if ((!uInfo.pcalStaff) && (uInfo.userClientID != 0)) 
      {

        var newSelRecsList = new List<SelRec>();
        
        if (primaryRepUserID.HasValue) {
           var repObj = load(connUsers, log, uInfo, appName, primaryRepUserID.Value.ToString());
           var repSelRec = new SelRec();
           repSelRec.id = repObj.id;
           repSelRec.label = repObj.name;
           repSelRec.value = repObj.id.ToString();
           repSelRec.context1 = @"Practi-Cal Representative";
           newSelRecsList.Add(repSelRec);
        }

        if (backupRepUserID.HasValue && backupRepUserID != primaryRepUserID) {
            var repObj = load(connUsers, log, uInfo, appName, backupRepUserID.Value.ToString());
            var repSelRec = new SelRec();
            repSelRec.id = repObj.id;
            repSelRec.label = repObj.name;
            repSelRec.value = repObj.id.ToString();
            repSelRec.context1 = @"Practi-Cal Representative";
            newSelRecsList.Add(repSelRec);
        }

        newSelRecsList.AddRange(so.SelRecs);
        so.SelRecs = newSelRecsList.ToArray();
      }
      return so;

     }

    }
}
