using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;

namespace MBA
{
  
  /* Basic info about who the user belongs to */

  public class UserInfo
  {
    public  long    userid;
    public  string  useridStr;  
    public  int     userGroup; 
    public  int     userRank;
    public  long    userClientID;    
    public  string  userClientIDStr;
    public  long    userSelpaCode = 0;          
    public  string  userSelpaCodeStr = "";
    public  long    userPracID;
    public  string  userPracIDStr;
    public  long    userPracPlanWriterGroupID;
    public  string  userPracPlanWriterGroupIDStr;
    public  long    userPracOrpServiceClassNameID;
    public  string  userPracOrpServiceClassNameIDStr;
    public  long    userPracStdSvcClassNameID;
    public  string  userPracStdSvcClassNameIDStr;
    public  bool    userPracIsAParaProfessional;

    public  bool    userPracIsPracSomeoneWhoCanManageDirectSupervisionTracking;
    public  bool    userPracPracIsLimitedToTheirReportingGroupForManagingDirectSupervisionTracking;
    
    public long     userPracDispGroupID;
    public string   userPracDispGroupIDStr;
    public string   userPracDispGroupName;

    public long     userPracReptGroupID;
    public string   userPracReptGroupIDStr;
    public string   userPracReptGroupName;

    public  string  userIP;
    public  string  userRole;
    public  string  userRoleLower;
    public  long    userRoleID;

    public  bool    pcalStaff;
	public  bool    implicitDataAccess;
	public  string  startingPage;
    public  bool    teleCommTeleHealthAccessGranted;
    public  bool    teleCommTeleIEPAccessGranted;

    public  List<PatientPerson>         associatedPatientPersons;
    public  List<PatientUserAccount>    associatedPatientUserAccounts;
    public  List<SelpaRelatedClient>    associatedClients;

    public  bool cybhiConsortiumIsLead = false;
    public  List<ClientConsortiumMember> cybhiConsortiumMembers;

        
    /***************************************************************************
     * createBatchUserInfo */
    /**
     * Populates the user info object with data that is appropriate for
     * privelleged batch tasks.
     ***************************************************************************/         
    
    public static Return createBatchUserInfo (string batchuserip, ref UserInfo uInfo)
    {      
      Return so = new Return();
              
      uInfo.userClientID           = 0;
      uInfo.userClientIDStr        = "";
      uInfo.userGroup                    = Constants.USER_GROUP_SBSC;
      uInfo.userRole                     = Util.nameCase(Constants.ROLE_ADMIN);
      uInfo.userRoleID                   = Constants.ROLE_ADMIN_ID;
      uInfo.userRoleLower                = Constants.ROLE_ADMIN;
      uInfo.userRank                     = Constants.RANK_ADMIN;
      uInfo.userPracID                   = 0;
      uInfo.userPracIDStr                = "";
      uInfo.userid                       = Constants.USER_ID_SYSTEM;  
      uInfo.useridStr                    = Constants.USER_ID_SYSTEM.ToString();
      uInfo.userIP                       = batchuserip;

      uInfo.pcalStaff                        = true;
	  uInfo.implicitDataAccess             = true;
	  uInfo.startingPage                   = @"";
      uInfo.teleCommTeleHealthAccessGranted  = true;
      uInfo.teleCommTeleIEPAccessGranted     = true;
      return so;
      
    }
    
    /***************************************************************************
     * retrieveUserInfo */
    /**
     * Attempts to populate the user info object with a given userID (long)     
     ***************************************************************************/         
    
    public static Return retrieveUserInfo (  SqlConnection connUsers
                                           , DetailsLog    log                                          
                                           , string appname
                                           , long userID
                                           , ref UserInfo uInfo )
    {
      

      string valAppName  = Validate.reqString (appname, Messages.INVALID_APP_NAME); 
                    
 
      List <SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@appName",   SqlDbType.VarChar,  valAppName,                 ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@userID",    SqlDbType.BigInt,   userID,                    ParameterDirection.Input));
      
      string sql = @"select top 1
                    id              as userid,                    
                    userGroupID       as userGroup,
                    roleName        as userRole,
                    roleNameLowered  as userRoleLower,
                    userRank          as userRank,
                    roleID          as userRoleID,
                    clientID  as userClientID,
                    pracID as userPracID,
                    teleCommTeleHealthAccessGranted 
                    from dbo.USERS_DATA_CORE(@appName,null,null,null,@userID)";
                               
      /*-------------------------------
       * Execute query
       *------------------------------*/             

      ReturnDB rd = Database.execQuery(connUsers, log, sql, false, parms);
      
      /*-------------------------------
       * If the user was not found
       * get out
       *------------------------------*/             

      if (!rd.hasRecords)
      {        
        throw new Critical(Messages.INVALID_USER_ID);
      }
      
      /*-------------------------------
       * Otherwise convert our result
       * set into a UserInfo instance
       * populating what we can from
       * the result set.
       *------------------------------*/ 
      
      uInfo = (UserInfo) Database.convertRecord(rd.records, typeof(UserInfo));
      
      /*-------------------------------
       * And then populate the rest
       *------------------------------*/ 
       
      uInfo.userClientIDStr      = uInfo.userClientID.ToString();
      uInfo.userPracIDStr        = uInfo.userPracID.ToString();
      uInfo.userIP               = "";
      uInfo.useridStr            = uInfo.userid.ToString();              

      return rd;
      
    }
                                           

    /***************************************************************************
     * retrieveUserInfo */
    /**
     * Attempts to populate the user info object with account data from the MBA
     * (users) database.  The search is based on the network users name.
     ***************************************************************************/         
    
    public static Return retrieveUserInfo (SqlConnection connUsers, 
                                           DetailsLog    log, 
                                           string appname, 
                                           string ntuser, 
                                           string ntuserip,
                                           ref UserInfo uInfo)
    {
      
      /*-------------------------------
       * Make sure app name and user
       * were passed in
       *------------------------------*/             

      string valAppName  = Validate.reqString (appname, Messages.INVALID_APP_NAME); 
      string valNTUser   = Validate.reqString (ntuser,  Messages.INVALID_NT_USER);
            
      /*-------------------------------
       * Create our db parameters and
       * pass in app name, 
       * network username, and
       * user group (constant for now)
       *------------------------------*/             
 
      List <SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@appname",   SqlDbType.VarChar,  valAppName,                 ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@ntuser",    SqlDbType.VarChar,  valNTUser,                  ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@usergroup", SqlDbType.Int,      Constants.USER_GROUP_SBSC,  ParameterDirection.Input));
      
      /*-------------------------------
       * Setup query to 
       * locate the MBA login in the
       * users database that matches
       * the network username
       *------------------------------*/             

      string sql = @"select 
                    id              as userid,                    
                    userGroupID       as userGroup,
                    roleName        as userRole,
                    roleNameLowered  as userRoleLower,
                    userRank          as userRank,
                    roleID          as userRoleID,
                    teleCommTeleHealthAccessGranted 
                    from dbo.USERS_DATA_CORE(@appname,null,null,null,null) 
                    where ((userGroupID = @usergroup)
                    and (substring(UserName, 0, charindex ('@',UserName)) = @ntuser))";
            
      /*-------------------------------
       * Execute query
       *------------------------------*/             

      ReturnDB rd = Database.execQuery(connUsers, log, sql, false, parms);
      
      /*-------------------------------
       * If the user was not found
       * get out
       *------------------------------*/             

      if (!rd.hasRecords)
      {
        string msg = Util.createMessageString(Messages.NT_USER_NOT_FOUND, ntuser);
        throw new Critical(msg);
      }
      
      /*-------------------------------
       * Otherwise convert our result
       * set into a UserInfo instance
       * populating what we can from
       * the result set.
       *------------------------------*/ 
      
      uInfo = (UserInfo) Database.convertRecord(rd.records, typeof(UserInfo));
      
      /*-------------------------------
       * And then populate the rest
       *------------------------------*/ 
      
      uInfo.userClientID         = 0;
      uInfo.userClientIDStr      = "";
      uInfo.userPracID           = 0;      
      uInfo.userPracIDStr        = "";
      uInfo.userIP               = ntuserip;      
      uInfo.useridStr            = uInfo.userid.ToString();
      return rd;
      
    }
         
    public static void retrieveUserInfo(RequestResponse rd, ref UserInfo uInfo)
    {
      uInfo.userid            = rd.wu.usr.id;
      uInfo.useridStr         = rd.wu.usr.id.ToString();
      uInfo.userGroup         = rd.wu.usr.userGroupID;
      uInfo.userRank          = rd.wu.usr.userRank;
      uInfo.userClientID      = rd.wu.usr.clientID;
      uInfo.userClientIDStr   = rd.wu.usr.clientID.ToString();
      uInfo.userSelpaCode     = rd.wu.usr.selpaCode;
      uInfo.userSelpaCodeStr  = rd.wu.usr.selpaCode.ToString();
      uInfo.userRole          = rd.wu.usr.roleName;
      uInfo.userRoleLower     = rd.wu.usr.roleName.ToLower();
      uInfo.userIP            = rd.userIP;
      uInfo.userRoleID        = rd.wu.usr.roleID;
      
      uInfo.pcalStaff                       = rd.wu.usr.pcalStaff;
	  uInfo.implicitDataAccess              = rd.wu.usr.implicitDataAccess;
	  uInfo.startingPage                    = rd.wu.usr.startingPage;
      uInfo.teleCommTeleHealthAccessGranted = rd.wu.usr.teleCommTeleHealthAccessGranted;
      uInfo.teleCommTeleIEPAccessGranted    = rd.wu.usr.teleCommTeleIEPAccessGranted;
     
      if (uInfo.userGroup == Constants.USER_GROUP_CLIENT)
      {
       
        /*-------------------------------
         * User is a practitioner
         *------------------------------*/          

        if (uInfo.userRoleID == Constants.ROLE_LEA_PROVIDER_ID)
        { 
          uInfo.userPracID                        = rd.wu.pr.id;
          uInfo.userPracIDStr                     = rd.wu.pr.id.ToString();        
          uInfo.userPracPlanWriterGroupID         = rd.wu.pr.planWriterGroupID;
          uInfo.userPracPlanWriterGroupIDStr      = rd.wu.pr.planWriterGroupID.ToString();
          uInfo.userPracOrpServiceClassNameID     = rd.wu.pr.orpGroupServiceClassNameID;
          uInfo.userPracOrpServiceClassNameIDStr  = rd.wu.pr.orpGroupServiceClassNameID.ToString();    
          uInfo.userPracStdSvcClassNameID         = rd.wu.pr.stdSvcClassNameID;
          uInfo.userPracStdSvcClassNameIDStr      = rd.wu.pr.stdSvcClassNameID.ToString();
          uInfo.userPracIsAParaProfessional       = rd.wu.pr.isAParaProfessional;
          
          uInfo.userPracIsPracSomeoneWhoCanManageDirectSupervisionTracking                     = rd.wu.pr.isPracSomeoneWhoCanManageDirectSupervisionTracking;
          uInfo.userPracPracIsLimitedToTheirReportingGroupForManagingDirectSupervisionTracking = rd.wu.pr.pracIsLimitedToTheirReportingGroupForManagingDirectSupervisionTracking;

          uInfo.userPracDispGroupID    = rd.wu.pr.groupID;
          uInfo.userPracDispGroupIDStr = rd.wu.pr.groupID.ToString();
          uInfo.userPracDispGroupName  = rd.wu.pr.groupName;

          uInfo.userPracReptGroupID    = rd.wu.pr.groupIDRept;
          uInfo.userPracReptGroupIDStr = rd.wu.pr.groupIDRept.ToString();
          uInfo.userPracReptGroupName  = rd.wu.pr.groupNameRept;

        }

        /*-------------------------------
         * User is LEA or CYBHI 
         * coordinator
         *------------------------------*/          

        if (
             (uInfo.userRoleID == Constants.ROLE_LEA_COORDINATOR_ID)
          || (uInfo.userRoleID == Constants.ROLE_CYBHI_CORDINATOR_ID)
        )
        {
            uInfo.cybhiConsortiumIsLead    = rd.wu.cybhiConsortiumIsLead;
            uInfo.cybhiConsortiumMembers   = rd.wu.cybhiConsortiumMembers;
        }                
        
      }
      else if (uInfo.userGroup == Constants.USER_GROUP_THIRD_PARTY_PERSON)
      {
        if (uInfo.userRoleID == Constants.ROLE_PARENT_GUARDIAN_ID)
        {
          uInfo.associatedPatientPersons = rd.wu.associatedPatientPersons;
        }

        if (uInfo.userRoleID == Constants.ROLE_PATIENT_ID) 
        { 
          uInfo.associatedPatientUserAccounts = rd.wu.associatedPatientUserAccounts;
        }

        if (uInfo.userRoleID == Constants.ROLE_SELPA_USER_ID)
        {
          uInfo.associatedClients = rd.wu.relatedClients;
        }
      }
    }

    /***************************************************************************
     * retrievePartialUserInfo */
    /**
     * Populates a portion of the UserInfo object from the WebUser object
     ***************************************************************************/         
              
    public static void retrievePartialUserInfo (ref User wu, ref UserInfo uInfo)
    {
      uInfo.userid                          = wu.id;
      uInfo.useridStr                       = wu.id.ToString();
      uInfo.userGroup                       = wu.userGroupID;
      uInfo.userRank                        = wu.userRank;
      uInfo.userClientID                    = wu.clientID;
      uInfo.userClientIDStr                 = wu.clientID.ToString();
  
      /* uInfo.userClientName  = wu.clientName;
    
      uInfo.userClientRepFirstName = wu.clientRepFirstName;
      uInfo.userClientRepLastName  = wu.clientRepLastName;
      uInfo.userClientRepPhone     = wu.clientRepPhone;
      uInfo.userClientRepEmail     = wu.clientRepEmail;
    */

      uInfo.userRole        = wu.roleName;
      uInfo.userRoleLower   = wu.roleName.ToLower();    
      uInfo.userRoleID      = wu.roleID;
      
      uInfo.pcalStaff                       = wu.pcalStaff;
	  uInfo.implicitDataAccess              = wu.implicitDataAccess;
	  uInfo.startingPage                    = wu.startingPage;
      uInfo.teleCommTeleHealthAccessGranted = wu.teleCommTeleHealthAccessGranted;
      uInfo.teleCommTeleIEPAccessGranted    = wu.teleCommTeleIEPAccessGranted;
    
    }

  }
}
