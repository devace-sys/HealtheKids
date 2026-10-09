using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Data;
using MBA.Reporting;

namespace MBA.Security
{
  
    /***************************************************************************
     * MissingTimeEntryConfirmation */
    /**
     * 
     **************************************************************************/
    public class MissingTimeEntryConfirmation : ListItemWImage
    {
        public string title       { get ; set; } 
        public string description { get ; set; } 
        public string finePrint   { get { return "Please sign in and confirm the time entries for this week are correct."; } }
        public string imgSrc      { get { return null; } }
    }

    /***************************************************************************
     * MissingTimeEntryConfirmations */
    /**
     * 
     **************************************************************************/
    
    public class MissingTimeEntryConfirmations
    {
      public List<MissingTimeEntryConfirmation> listItems;
    }

    /***************************************************************************
     * MissingTimeEntryConfirmationNotice */
    /**
     * 
     **************************************************************************/
    public class missingTimeEntryConfirmationNotice 
    {
        public missingTimeEntryConfirmationNotice ()
        {
        }

        public string firstName;
        public string lastName;
        public string emailWork;
        public string emailPersonal;
        public string confirmationsMissingJSON; /* Note: JSON is not escaped. */ 
        public MissingTimeEntryConfirmations confirmationsMissingObj;
    }

    public class DelinquentDTKUser
    {
        public long id;
        public long employeeID;
        public DateTime lastDayOfSchedule;
        public DateTime firstDayOfSchedule;
        public DateTime dateVerified;
        public string comments;
        public string lastName;
        public string firstName;
        public string email;
        public string email2;
        public int daysOverdue;

        public string warning_out { get {
                return "Verify hours for the pay period between " + firstDayOfSchedule.ToString("MM/dd/yyyy") +
             " to " + lastDayOfSchedule.ToString("MM/dd/yyyy");
            }
        }
    }


    public class BitteTimePeople // : MBA.Entities  /* BitteTimePeople ???? */
    {
        public long id;                     // aside from the question of what Bitte is,
        public long roleID;                 // it appears that this class holds fields for a single entry.
        public string lastName;             // Shouldn't this be BitteTimePerson?
        public string firstName;
        public string roleName;
        public long employeeid;

        public bool isDelinquentDTKUser;

        public static bool isHourVerifyRequired( SqlConnection con, DetailsLog logg, UserInfo uInfo, string e_id, ref string html_checkbox_warning_out, ref string warning_out_hidden, ref string lastDayOfSchedule)
        {
           
            Object[] rd = returnCheckForDelinquentEmployees(con, logg, uInfo, e_id, 0, null);

            if (rd.Length == 0 )
                return false;

            DelinquentDTKUser firstDTKU = (DelinquentDTKUser) rd[0];

            html_checkbox_warning_out = firstDTKU.warning_out +

"<br/><br/><strong style=\"font-weight: bold\">By clicking this box you are certifying that you have reviewed your recorded hours for this time period and they are correct.</strong><br/><br/>";

            // This method is only called from .aspx.cs code-behinds.  If we ever, for some reason, need isHourVerifyRequired() from somewhere
            // that isn't a webpage, then... that's okay too.  we can use the plain-text version of warning_out,
            // in the DelinquentDTKUser.warning_out field.

            warning_out_hidden = firstDTKU.id.ToString();
            lastDayOfSchedule = firstDTKU.lastDayOfSchedule.ToString();
            return true;
        }

        /***************************************************************************
         * getCurrentMissingTimePeriodConfirmationsSummary */
        /**
         * 
         **************************************************************************/    
        public static List<missingTimeEntryConfirmationNotice> getCurrentMissingTimePeriodConfirmationsSummary ( SqlConnection conn
                                                                                                                , DetailsLog   log
                                                                                                                , UserInfo     uInfo
                                                                                                                , bool usePassThruUDF = true)
        {
          if (conn.State == ConnectionState.Closed) conn.Open(); /* https://stackoverflow.com/a/6943970 */
          var notices = new List<missingTimeEntryConfirmationNotice>();
          string sql = @"select * from dbo." + ( usePassThruUDF ? @"TimeKeeper_" : @"") + @"TIMESHEET_GetCurrentMissingTimePeriodConfirmationsSummary()";
          var rd = MBA.Database.execQuery(conn,log,sql);
          
          /* No records?  Get out! */
          if (rd.hasRecords == false) return notices;
          
          /* Generate notice objects */
          
          var noticeObjs = MBA.Database.convertRecords(rd.records, typeof(missingTimeEntryConfirmationNotice));
          foreach (var noticeObj in noticeObjs)
          {
            missingTimeEntryConfirmationNotice notice = (missingTimeEntryConfirmationNotice) noticeObj;
            notice.confirmationsMissingObj = (MissingTimeEntryConfirmations) MBA.JSON.fromJSONString ( notice.confirmationsMissingJSON
                                                                                                      ,typeof(MissingTimeEntryConfirmations));
            notices.Add(notice);
          }
          
          return notices;
        }

        public static Object[] returnCheckForDelinquentEmployees(
            SqlConnection con, DetailsLog log, UserInfo uInfo,
            string employeeID, int minDaysAgo, string maxDaysAgo,
            bool usePassThruUDF=true
        )
        {
            if (con.State == ConnectionState.Closed) //https://stackoverflow.com/a/6943970
                con.Open();

            string sql =
              @"select * from dbo." + ( usePassThruUDF ? "TimeKeeper_" : "") +
              "TIMESHEET_CheckForDelinquentEmployees( @employeeId, @minDaysAgo, @maxDaysAgo )";
            Object vEmployeeID = MBA.Validate.optInteger (employeeID, "invalid employee id");
            Object vMaxDaysAgo = MBA.Validate.optInteger (maxDaysAgo, "invalid");

                
            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(MBA.Database.SqlParm("@employeeId", SqlDbType.BigInt, vEmployeeID, ParameterDirection.Input, 100));
            parms.Add(MBA.Database.SqlParm("@minDaysAgo", SqlDbType.Int, minDaysAgo, ParameterDirection.Input, 100));
            parms.Add(MBA.Database.SqlParm("@maxDaysAgo", SqlDbType.Int, vMaxDaysAgo, ParameterDirection.Input, 100));

            ReturnDB rd= Database.execQuery(con,log,sql,false,parms);
               
            return (Object[]) MBA.Database.convertRecords(rd.records, typeof(DelinquentDTKUser));

        }

        public static BitteTimePeople getTimeEntryPersonDetail(string spedMonUserName)
        {
            DetailsLog _log = new DetailsLog();

            using (SqlConnection _con = new SqlConnection(MBA.Constants.DB_CONN_APP))

            {
                _con.Open();
                return loadUserInfo(_con, _log, spedMonUserName);
            }
        }

        public static BitteTimePeople loadUserInfo(SqlConnection connSpedmon
                                             , DetailsLog log
                                             , string spedMonLogin)
        {
            BitteTimePeople people = new BitteTimePeople();

            try
            {
                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_PEOPLE_GetRecord", connSpedmon);

                //TODO: here we're using the Spedmon DB connection to run a Spedmon SPROC, inside of MBA code.
                //      I know this doesn't follow our established "patterns" as intended, but I don't know if we're going to fix it,
                //      or how.

                    
                _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
                _sqlDataAdapter.SelectCommand.Parameters.Add("@SpedMonUserName", SqlDbType.VarChar).Value = spedMonLogin;

                DataSet _dataSet = new DataSet();
                _sqlDataAdapter.Fill(_dataSet);

                if (_dataSet.Tables[0].Rows.Count == 0)
                {
                    return null;
                }
                DataRow _dataRow = _dataSet.Tables[0].Rows[0];

                people.id = long.Parse(_dataRow["id"].ToString());
                people.roleID = long.Parse(_dataRow["roleID"].ToString());
                people.lastName = _dataRow["lastName"].ToString();
                people.firstName = _dataRow["firstName"].ToString();
                people.roleName = _dataRow["roleName"].ToString();
                people.employeeid = long.Parse(_dataRow["employeeid"].ToString());
                
                people.isDelinquentDTKUser = !(Util.IsNullOrEmpty( _dataRow["isDelinquentDTKUser"].ToString() ) );
            }
            catch (Exception e)
            {
            }

            return people;
        }



    }

}
