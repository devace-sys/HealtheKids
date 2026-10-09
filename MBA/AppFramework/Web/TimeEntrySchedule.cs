using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Collections.Generic;

// SBC Added for TimeKeeper
namespace MBA.Web
{
    public class TimeEntrySchedule
    {
        public TimeEntrySchedule()
        {
            //
            // TODO: Add constructor logic here
            //
        }

        public static bool isScheduleApproved(int employeeId, DateTime dateOfWeek, ref int rowCount)
        {
            bool _isApproved = false;
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _isApproved = isScheduleApproved(_con, employeeId, dateOfWeek, ref rowCount);
            }

            return _isApproved;
        }

        public static bool isScheduleApproved(SqlConnection con, int employeeId, DateTime dateOfWeek, ref int rowCount)
        {
            DateTime _startDate = dateOfWeek.DayOfWeek == DayOfWeek.Sunday ? dateOfWeek : dateOfWeek.AddDays(-1 * (int)dateOfWeek.DayOfWeek);
            DateTime _endDate = dateOfWeek.DayOfWeek == DayOfWeek.Saturday ? dateOfWeek : dateOfWeek.AddDays(6 - (int)dateOfWeek.DayOfWeek);

            string _sqlStatement = @"
                    select 
                        isApproved
                    FROM 
                        [TimeKeeper].[dbo].[ScheduleApproved] 
                    where 
                        employeeID = @EmployeeID
                        and startDate = @StartDate
                        and endDate = @EndDate";

            DataTable _dataTable = new DataTable();
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@EmployeeID", employeeId);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@StartDate", _startDate.ToString("MM/dd/yyyy"));
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@EndDate", _endDate.ToString("MM/dd/yyyy"));
            _sqlDataAdapter.Fill(_dataTable);

            if ((rowCount = _dataTable.Rows.Count) == 0)
            {
                return false;
            }

            return _dataTable.Rows[0]["isApproved"].ToString().ToLower() == "false" ? false : true;
        }
    }
}
