using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;


namespace Workflow_v2
{
    static class WorkflowPermissions
    {
        

        [Flags]
        public enum PermissionTypes
        {
            NO_PERMISSIONS = 0,
            DATA_MGMT_TAB = 2,
            SQL_RPT_TAB = 4,
            USER_PERM_TAB = 8
        }

        static public ulong getDBUserPermissionFlags(string userDBconnStr, int userid)
        {
            ulong databaseAppSumFlags = 0;
            using (SqlConnection conn = new SqlConnection(userDBconnStr))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("Select dbo.WORKFLOW_APPLICATION_PERMISSIONS_VIEW_USER_FLAGSUM(@userID)"))
                {
                    cmd.Connection = conn;
                    cmd.CommandType = CommandType.Text;

                    /* Todo: This param block is iffy. Is there a good way to pass in a nullable type? */
                    if (userid != 0)
                        cmd.Parameters.Add(Database.SqlParm("@userID", SqlDbType.BigInt, userid, ParameterDirection.Input));
                    else
                        cmd.Parameters.Add(Database.SqlParm("@userID", SqlDbType.BigInt, DBNull.Value, ParameterDirection.Input));

                    databaseAppSumFlags = (ulong)cmd.ExecuteScalar();
                }
            }
            return databaseAppSumFlags;
        }

        static public bool enumPermUserValidate(ulong userPermissionSet, PermissionTypes permToCheck)
        {
            Array a = Enum.GetValues(typeof(PermissionTypes));


            if (0==1) // from Visual Studio: "Warning: Unreachable code detected"

            return true;
            else
                return false;

        }

        static public void permissionsDBValidate(string userDBconnStr)
        {
            //Connect to users DB and retrieve a list of all workflow permissions & compare against enums

            //SUM of enum flags vs sum of flags in sql would work
            //reference http://stackoverflow.com/questions/3463045/best-way-to-get-all-bits-of-an-enum-flag

            Int64 sfFlagSum = ((Enum.GetValues(typeof(PermissionTypes)).Cast<int>()).Sum());

            ulong internalAppSumFlags = (ulong)sfFlagSum;

            ulong databaseAppSumFlags = getDBUserPermissionFlags(userDBconnStr, 0);

            if (databaseAppSumFlags != internalAppSumFlags)
            {
                throw new InvalidOperationException("The set of permissions known to the application differ from the set retrieved from the database. (a" + internalAppSumFlags.ToString() + ", d" + databaseAppSumFlags.ToString());
            }
        }


    }

    public class WorkflowUser
    {

        public string userName { get; private set; }
        public int NUM_UserID { get; private set; }
        public string GUID_UserID { get; private set; }
        public string GUID_RoleID { get; private set; }
        public string fullName { get; private set; }

        public string localIPAdd { get; private set; }

        public ulong permissionFlags { get; private set; }

        public UserInfo curAppUser { get; private set; }

        private DataTable dirtyPermissionsStore;

        public WorkflowUser(string userDBConnStr, string ApplicationName)
        {
            userName = Environment.UserName;
            localIPAdd = null;



            loadDBUserInfo(userDBConnStr, ApplicationName);

            /* TODO load workflow perm flags from DB for this user */

            //permissionFlags = (ulong)WorkflowPermissions.getDBUserPermissionFlags(userDBConnStr, this.NUM_UserID);

        }

        private void loadDBUserInfo(string userDBConnStr, string ApplicationName)
        {
            DataTable dt = new DataTable(); 

            /* Accessible users for this are SBSC employees with the appropriate windows username */
            /* TODO: Turn this into a SQL function like WORKFLOW_USER_VIEW(username) */

            using (SqlConnection userDBconn = new SqlConnection(userDBConnStr))
            {
                userDBconn.Open();

                using (SqlCommand com = new SqlCommand())
                {
                    com.Connection = userDBconn;
                    com.CommandText =
                      " select id as NUM_userid, uid as GUID_userID, roleUID as GUID_roleID, firstname+' '+lastname as userFullName "
                    + " from dbo.USERS_DATA_CORE(dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null)  "
                    + " where userGroupID = dbo.CONST_USER_GROUP_SBS() and SUBSTRING(UserName,0,CHARINDEX('@',UserName)) = @userName"
                    ;
                    com.CommandType = CommandType.Text;
                    com.Parameters.Add(Database.SqlParm("@userName", SqlDbType.VarChar, Environment.UserName, ParameterDirection.Input, 7000));

                    dt = WinFormsCommon.tableFromSqlExecQuery(com);
                }

                if (dt.Rows.Count == 1)
                {
                    DataRow dr = dt.Rows[0];
                    NUM_UserID = Convert.ToInt32(dr["NUM_userid"]);
                    GUID_UserID = dr["GUID_userID"].ToString();
                    GUID_RoleID = dr["GUID_roleID"].ToString();
                    fullName = dr["userFullName"].ToString();

                }
                else
                {
                    throw new ArgumentException("Could not validate user/connection for authentication.");
                }

                /* Get Spedmon UserInfo object for later passthrough */
                DetailsLog L = new MBA.DetailsLog();
                UserInfo usIf = new UserInfo();
                UserInfo.retrieveUserInfo(userDBconn, L, ApplicationName, userName, "", ref usIf);
                this.curAppUser = usIf;
            }
        }

        public bool userIs22Plus()
        { 
          try
          { 
            MBA.Validate.reqOption(curAppUser.userRoleLower, Constants.ROLE_SBS_MGMT,Messages.ACCESS_DENIED);    
          }
          catch
          {
            return false;
          }
          return true;
        }

        public bool PermissionsLoaded()
        { return false; }

    }
}
