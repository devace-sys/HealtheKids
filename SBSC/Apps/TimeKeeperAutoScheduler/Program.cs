using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MBA;
using MBA.Security;

namespace Spedmon
{
    class Holiday
    {
        public long ID { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public DateTime DateOfHolidayObserved { get; set; }
    }



    class TimeKeeperAutoScheduler : BatchApplication
    {
        private static string[] _Args = null;

        private static int _WeeksToGenerate = 2;
        private static bool _ForceDelete = false;
        private static DateTime _DateToRun = DateTime.Today;
        static void Main(string[] args)
        {
            _Args = args;
            GenericCallBack _mainDel = delegate { main(); };

            enter(ConfigurationManager.AppSettings["appName"],
                  "Time Keeper Auto Scheduler",
                  ConfigurationManager.AppSettings["appVersion"],
                  ref args,
                  ref _mainDel,
                  false);
        }
        /// <summary>
        ///    Valid options are 
        ///        -w[weeks] :  Will run scheduler for the number of seeks specified.
        ///            example -w 2 
        ///                 Runs scheduler for current week and next week(2 weeks)
        ///             default is 2
        ///        -f[Force Delete Previous TimeEntries] : If set to true will allow Task Template to remove existing entries
        ///            example  -f true
        ///                Will cause task templates to delete and the recreate time entries for the day it is running
        ///                against
        ///            default is false
        ///    -   d[Date] : Will run Task template against a specific date
        ///           example -d '12-7-1941'
        ///               Will cause task templates to run against Dec 7 1941
        ///           default is the current date
        /// </summary>
        /// <returns></returns>
        private static bool ProcessArguments(out string errMsg)
        {
            errMsg = string.Empty;
            try
            {
                // Valid options are 
                // -w [weeks] :  Will run scheduler for the number of seeks specified.
                //      example -w 2 
                //          Runs scheduler for current week and next week (2 weeks)
                //      default is 2
                //  -f [Force Delete Previous TimeEntries] : If set to true will allow Task Template to remove existing entries
                //      example  -f true
                //          Will cause task templates to delete and the recreate time entries for the day it is running 
                //          against
                //      default is false
                // -d [Date] : Will run Task template against a specific date
                //     example -d '12-7-1941'
                //         Will cause task templates to run against Dec 7 1941
                //     default is the current date


                foreach(NameValue _nameValue in arguments)
                {
                    switch (_nameValue.name.ToLower())
                    {
                        case "-w":
                            if (!int.TryParse(_nameValue.value.ToString(), out _WeeksToGenerate) || _WeeksToGenerate <= 0)
                            {
                                errMsg += "\nInvalid value for weeks to generate";
                            }
                            break;
                        case "-f":
                            if (!bool.TryParse(_nameValue.value.ToString(), out _ForceDelete))
                            {
                                errMsg += "\nInvalid value for Force Delete";
                            }
                            break;
                        case "-d":
                            if (!DateTime.TryParse(_nameValue.value.ToString(), out _DateToRun))
                            {
                                errMsg += "\nInvalid value for Date To Run";
                            }
                            break;
                    }
                }
            }
            catch (Exception _exception)
            {
                errMsg += "\nException caught trying to parse arguments - " + _exception.Message;
            }

            return string.IsNullOrEmpty(errMsg) ? true : false;
        }
        static void main()
        { 
            DisplayNotice(Return.RET_INFO,"Starting Auto Scheduler");
            string _errMsg = string.Empty;
            if (!ProcessArguments(out _errMsg))
            {
                DisplayNotice(Return.RET_FATAL, "Command line argments are invalid\n" + _errMsg + "!");
                return;
            }

            SqlTransaction _objTrans = null;

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnKeeper"]))
            {
                try
                {
                    _con.Open();

                    SendEmailsToYesterdaysNaughtyList(_con); // we're just running a UDF and not making any INSERTS or UPDATES; we don't need a transaction just yet

                    _objTrans = _con.BeginTransaction();

                    if (System.DateTime.Today.Month == 1 && System.DateTime.Today.Day == 1)
                      UpdateHolidaysForThisYear(_con, _objTrans); 
                    
                    ProcessEmployeeAutoScheduler(_con, _objTrans, _WeeksToGenerate);

                    Holiday _holiday = GetHolidaysForDate(_con, _objTrans);

                    if (_holiday != null)
                    {
                        DisplayNotice(Return.RET_INFO, "Inserting Holidays task for appropriate employees");
                        InsertHolidayIntoTimesheet(_holiday, _con, _objTrans);
                        DisplayNotice(Return.RET_INFO, "Done Inserting Holidays task");
                    }
                    else
                    {

                        DisplayNotice(Return.RET_INFO, "Processing Task Templates");
                        EnterTaskInfoForTimeEntry(_con, _objTrans, _ForceDelete);
                        DisplayNotice(Return.RET_INFO, "Done processing Task Template");
                    }

                    AddPayrollVerificationIfNecessary(_con, _objTrans);
                    _objTrans.Commit();
                }
                catch (Exception _exception)
                {
                    _objTrans.Rollback();
                    DisplayNotice(Return.RET_FATAL, "Schedules had errors\n" +
                            "Schedules not generated - " + _exception.Message + "!");

                }
                finally
                {
                    _con.Close();
                }
            }
        }

        private static void AddPayrollVerificationIfNecessary(SqlConnection con, SqlTransaction objTrans)
        {
            // Get list of 
            List<long> _listEmployeeIds = GetListOfEmployees(con, objTrans);
            DateTime _firstDayOfTheWeek = DateTime.MinValue;
            DateTime _lastDayOfTheWeek = DateTime.MaxValue;

            GetStartAndEndDayOfTheWeek(ref _firstDayOfTheWeek, ref _lastDayOfTheWeek, _DateToRun);
            _lastDayOfTheWeek.AddDays(1);

            // Find last day of employee schedule for the week
            foreach (long _employeeId in _listEmployeeIds)
            {
                InsertVerificationIfNeeded(con, objTrans, _employeeId, _firstDayOfTheWeek, _lastDayOfTheWeek, _DateToRun);
            }
        }
        private static void InsertVerificationIfNeeded(SqlConnection con, SqlTransaction objTrans, 
            long employeeId, DateTime startDate, DateTime endDate, DateTime today)
        {
            DateTime _lastDayOfSchedule = GetLastDayOfSchedule(con, objTrans, employeeId, startDate, endDate);
            if (_lastDayOfSchedule == DateTime.MinValue)
            {
                DisplayNotice(Return.RET_ERROR, "Unable to get last day of schedule for employee " + employeeId.ToString());
                return;
            }
            DateTime _dayBeforeLastScheduleDay = _lastDayOfSchedule.AddDays(-1);

            DisplayNotice(Return.RET_INFO, "Inserting notification for " + employeeId.ToString());
            // Stored procedure will determine if a new record needs to be inserted
            SqlCommand _sqlCommand = new SqlCommand("TIMESHEET_InsertEmployeeTimeVerfication", con);
            _sqlCommand.CommandType = CommandType.StoredProcedure;
            _sqlCommand.Transaction = objTrans;

            _sqlCommand.Parameters.AddWithValue("@employeeID", employeeId);
            _sqlCommand.Parameters.AddWithValue("@lastDayOfSchedule", _lastDayOfSchedule.ToString("MM/dd/yyyy"));

            // note; was recording a dateOfNotification to a past date, even though
            // a notice wasn't sent that day
            _sqlCommand.Parameters.AddWithValue("@dateOfNotification", (_dayBeforeLastScheduleDay < DateTime.Today ? DateTime.Today : _dayBeforeLastScheduleDay).ToString("MM/dd/yyyy"));

            _sqlCommand.Parameters.AddWithValue("@startDateOfTheWeek", startDate);
            _sqlCommand.Parameters.AddWithValue("@stopDateOfTheWeek", endDate.AddDays(1));
            _sqlCommand.Parameters.AddWithValue("@comments", DBNull.Value);

            _sqlCommand.Parameters.Add("@Id", SqlDbType.BigInt);

            _sqlCommand.Parameters["@Id"].Direction = ParameterDirection.Output;

            _sqlCommand.ExecuteNonQuery();
        }
        private static DateTime GetLastDayOfSchedule(SqlConnection con, SqlTransaction objTrans, long employeeId, DateTime startDate, DateTime endDate)
        {
            DateTime _lastDayOfSchedule = DateTime.MinValue;

            //SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("SELECT * FROM TimeKeeper_TIMESHEET_GetSchedulesForEmployeesByDateRangeUDF(@startDate, @endDate, @employeeId)", con);
            //_sqlDataAdapter.SelectCommand.CommandType = CommandType.Text;
            
            // NOTE: this has been tested and seems to be working as a UDF call; perhaps could be tested further.  Reverting.
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TIMESHEET_GetSchedulesForEmployeesByDateRange", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            _sqlDataAdapter.SelectCommand.Transaction = objTrans;

            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@startDate", startDate);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@endDate", endDate);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@employeeId", employeeId);

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            // Get last record 
            int _rowCount = _dataTable.Rows.Count;

            if (_rowCount > 0)
            {
                DataRow _dataRow = _dataTable.Rows[_rowCount - 1];
                _lastDayOfSchedule = (DateTime.Parse(_dataRow["dateOfSchedule"].ToString())).Date;
            }

            return _lastDayOfSchedule;
        }
        private static List<long> GetListOfEmployees(SqlConnection con, SqlTransaction objTrans)
        {
            List<long> _listOfEmployees = new List<long>();

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TIMESHEET_GetEmployeeList", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            _sqlDataAdapter.SelectCommand.Transaction = objTrans;

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            foreach(DataRow _dataRow in _dataTable.Rows)
            {
                _listOfEmployees.Add(long.Parse(_dataRow["EmployeeId"].ToString()));
            }

            return _listOfEmployees;
        }
        private static DateTime GetFirstDayOfTheWeek(DateTime selectedDate)
        {
            if (selectedDate.DayOfWeek == DayOfWeek.Sunday)
            {
                return selectedDate;
            }

            return selectedDate.Date.AddDays(-1 * (int)selectedDate.DayOfWeek);
        }

        private static DateTime GetLastDayOfTheWeek(DateTime selectedDate)
        {
            if (selectedDate.DayOfWeek == DayOfWeek.Saturday)
            {
                return selectedDate;
            }

            return selectedDate.Date.AddDays(6 - (int)selectedDate.DayOfWeek);
        }

        private static void GetStartAndEndDayOfTheWeek(ref DateTime firstDayOfTheWeek, ref DateTime lastDayOfTheWeek, DateTime selectedDate)
        {
            firstDayOfTheWeek = GetFirstDayOfTheWeek(selectedDate);
            lastDayOfTheWeek = GetLastDayOfTheWeek(selectedDate);
        }

        private static void InsertHolidayIntoTimesheet(Holiday holiday, SqlConnection con, SqlTransaction objTrans)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TIMESHEET_GetEmployeesWhoGetPaidForHoliday", con);
            _sqlDataAdapter.SelectCommand.Transaction = objTrans;
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);
            long _timeEntryDayId = 0;
            const string HOLIDAY_TASK_ID = "163";
        
            foreach (DataRow _dataRow in _dataTable.Rows)
            {
                _timeEntryDayId = CreateTimeEntryDayIfNotPresent(long.Parse(_dataRow["id"].ToString()), con, objTrans);
                
                InsertTimeEntries(
                     con
                    , objTrans
                    , _timeEntryDayId
                    , "480" /* Full 8 hours */
                    , HOLIDAY_TASK_ID
                    , string.Empty
                    , "Automatically entered holiday : " + holiday.Name
                    , false
                    , HOLIDAY_TASK_ID
                    , false
                    , _timeEntryDayId                    
                    , long.Parse ( _dataRow["id"].ToString() )                
                );
            }
        }

        private static long CreateTimeEntryDayIfNotPresent(long employeeId, SqlConnection con, SqlTransaction objTrans)
        {
            SqlCommand cmd = new SqlCommand("TIMESHEET_CreateTimeEntryDay", con);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Transaction = objTrans;

            cmd.Parameters.AddWithValue("@EmployeeId", employeeId);
            cmd.Parameters.AddWithValue("@dateForTimeEntry", _DateToRun.ToString("MM/dd/yyyy"));
            cmd.Parameters.Add("@Id", SqlDbType.BigInt);
            cmd.Parameters["@Id"].Direction = ParameterDirection.Output;

            cmd.ExecuteNonQuery();
            return long.Parse(cmd.Parameters["@Id"].Value.ToString());
        }

        private static void UpdateHolidaysForThisYear(SqlConnection con, SqlTransaction objTransAction)
        {

            SqlCommand cmd = new SqlCommand("TIMESHEET_UpdateHolidaysThisYear", con);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Transaction = objTransAction;
            cmd.ExecuteNonQuery();

        }

        private static DataTable GetHolidays(SqlConnection con, SqlTransaction objTransAction)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TIMESHEET_GetHolidays", con);
            _sqlDataAdapter.SelectCommand.Transaction = objTransAction;
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            return _dataTable;
        }
        private static Holiday GetHolidaysForDate(SqlConnection con, SqlTransaction objTransAction)
        {
            DataTable _dataTable = GetHolidays(con, objTransAction);
            DateTime _holidayDateTime;

            foreach(DataRow _dataRow in _dataTable.Rows)
            {
                _holidayDateTime = DateTime.Parse(_dataRow["DateOfHolidayObserved"].ToString());
                // If holiday falls on a Saturday make Friday the holiday
                if (_holidayDateTime.DayOfWeek == DayOfWeek.Saturday)
                {
                    _holidayDateTime = _holidayDateTime.AddDays(-1);
                }
                else if (_holidayDateTime.DayOfWeek == DayOfWeek.Sunday)
                {
                    // If Holiday falls on a Sunday,mark the holiday on the following Monday
                    _holidayDateTime = _holidayDateTime.AddDays(1);
                }

                if (_holidayDateTime == _DateToRun)
                {
                    Holiday _holidays = new Holiday();
                    _holidays.ID = int.Parse(_dataRow["ID"].ToString());
                    _holidays.Name = _dataRow["Name"].ToString();
                    _holidays.Description = _dataRow.IsNull("Description") ? string.Empty : _dataRow["Description"].ToString();

                    _holidays.DateOfHolidayObserved = _holidayDateTime;
                    return _holidays;
                }
            }

            return null;
        }
        private static void EnterTaskInfoForTimeEntry(SqlConnection con, SqlTransaction objTransAction, bool deleteIfExists)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TIMESHEET_GetAutoTaskInfoForTimeEntryForSpecificDay", con);
            _sqlDataAdapter.SelectCommand.Transaction = objTransAction;
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@DayId", (int)_DateToRun.DayOfWeek);

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);
            List<DataRow> _employeeTasks = new List<DataRow>();
            bool _firstTime = true;

            foreach(DataRow _dataRow in _dataTable.Rows)
            {
                if (_firstTime)
                {
                    _firstTime = false;
                    _employeeTasks.Add(_dataRow);
                    continue;
                }
                // Process employee tasks once you find the start of a new set of emploe
                if (_employeeTasks.Count > 0 && 
                    _dataRow["EmployeeId"].ToString() != _employeeTasks[0]["EmployeeId"].ToString())
                {
                    DisplayNotice(Return.RET_INFO, "Processing employee id " + _employeeTasks[0]["EmployeeId"].ToString());
                    ProcessEmployeeTasks(con, objTransAction, _employeeTasks);
                    // Clear list for next employee tasks
                    _employeeTasks.Clear();
                }
                _employeeTasks.Add(_dataRow);
            }
            if (_employeeTasks.Count > 0)
            {
                DisplayNotice(Return.RET_INFO, "Processing employee id " + _employeeTasks[0]["EmployeeId"].ToString());
                ProcessEmployeeTasks(con, objTransAction, _employeeTasks);
                _employeeTasks.Clear();
            }
        }

        private static void ProcessEmployeeTasks(SqlConnection con, 
            SqlTransaction objTransAction, List<DataRow> listEmployeeTasks)
        {
            // Sanity check
            if (listEmployeeTasks.Count == 0)
            {
                return;
            }

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TIMESHEET_GetAutoSchedulerTimeEntryDay", con);
            _sqlDataAdapter.SelectCommand.Transaction = objTransAction;
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@EmployeeID", listEmployeeTasks[0]["employeeID"].ToString());
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@dateForTimeEntry", _DateToRun.ToString("MM/dd/yyyy"));

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            if (_dataTable.Rows.Count > 0 && !_ForceDelete)
            {
                DisplayNotice(Return.RET_INFO, "Time Entry for employee id " + listEmployeeTasks[0]["employeeID"].ToString() + " for the date " + _DateToRun.ToString("MM/dd/yyyy") + " already present skiping");
                return;
            }
            else if (_dataTable.Rows.Count > 0)
            {
                DisplayNotice(Return.RET_INFO, "Time Entry for employee id " + listEmployeeTasks[0]["employeeID"].ToString() + " for the date " + _DateToRun.ToString("MM/dd/yyyy") + 
                    " present, but the force delete option has been specified. Deleting existing entries");
                DeleteTimeEntryDay(con, objTransAction, _dataTable);
            }

            long _timeEntryDayID = InsertIntoTimeEntryDay(con, objTransAction, listEmployeeTasks);

            DisplayNotice(Return.RET_INFO, "Inserting Time Entry for employee id " + listEmployeeTasks[0]["employeeID"].ToString() + " for the date " + _DateToRun.ToString("MM/dd/yyyy"));
            foreach (DataRow _dataRow in listEmployeeTasks)
            {
                InsertTimeEntries(con, objTransAction, _dataRow, _timeEntryDayID);
            }
        }

        private static List<long> InsertTimeEntriesStopStartTime(SqlConnection con, SqlTransaction objTransAction, long timeEntryDayID,
            string timeEntrytaskID, string clientid, string note,
            bool canHaveMultipleClients, long autoPopulateDaysId, long e_id)
        {
            List<long> _timeEntryIds = new List<long>();
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("AUTO_GetAutoPopulateTaskDaysStartStopTimeByTaskDaysId", con);
            _sqlDataAdapter.SelectCommand.Transaction = objTransAction;
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@autoPopulateTaskDaysId", autoPopulateDaysId);
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            DateTime _startDateTime;
            DateTime _stopDateTime;
            TimeSpan _timeSpan;
            int _numberOfMinutes = 0;

            foreach (DataRow _dataRow in _dataTable.Rows)
            {
                _startDateTime = DateTime.Parse(_DateToRun.ToString("MM/dd/yyyy") + " " + _dataRow["starttime"].ToString());
                _stopDateTime = DateTime.Parse(_DateToRun.ToString("MM/dd/yyyy") + " " + _dataRow["stoptime"].ToString());
                _timeSpan = _stopDateTime - _startDateTime;
                _numberOfMinutes = (int)_timeSpan.TotalMinutes;

                _timeEntryIds.Add(InsertTimeEntriesStopStartTime(con, objTransAction, timeEntryDayID, timeEntrytaskID, clientid, note, canHaveMultipleClients, _startDateTime, _stopDateTime, _numberOfMinutes, e_id));

            }

            return _timeEntryIds;
        }

        private static long InsertTimeEntriesStopStartTime(SqlConnection con, SqlTransaction objTransAction, long timeEntryDayID,
            string timeEntrytaskID, string clientid, string note,
            bool canHaveMultipleClients, DateTime startDateTime, DateTime stopDateTime, int numberOfMinutes, long e_id
        )
        { 
            using (SqlCommand cmd = new SqlCommand("TIMESHEET_CreateTimeEntry", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Transaction = objTransAction;
                cmd.Parameters.AddWithValue("@timeEntryDayID", timeEntryDayID);
                cmd.Parameters.AddWithValue("@timeOfTask", _DateToRun.ToString("MM/dd/yyyy"));
                cmd.Parameters.AddWithValue("@numberMinutes", numberOfMinutes);

                if (string.IsNullOrEmpty(timeEntrytaskID))
                {
                    cmd.Parameters.AddWithValue("@timeEntrytaskID", DBNull.Value);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@timeEntrytaskID", timeEntrytaskID);
                }

                if (string.IsNullOrEmpty(clientid))
                {
                    cmd.Parameters.AddWithValue("@orgClientID", DBNull.Value);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@orgClientID", clientid);
                }

                cmd.Parameters.AddWithValue("@note", "Task Template Entry");
                cmd.Parameters.AddWithValue("@dateEntryCreated", DateTime.Now.ToString());
                cmd.Parameters.AddWithValue("@IsProjectManagement", 0);
                cmd.Parameters.AddWithValue("@IsHelpDesk", 0);
                cmd.Parameters.AddWithValue("@ITPM_ID", DBNull.Value);
                cmd.Parameters.AddWithValue("@HD_ROW_ID", DBNull.Value);
                cmd.Parameters.AddWithValue("@Description", DBNull.Value);
                cmd.Parameters.AddWithValue("@FileNameReference", DBNull.Value);
                cmd.Parameters.AddWithValue("@FileComments", DBNull.Value);
                cmd.Parameters.AddWithValue("@FileComplete", 0);
                cmd.Parameters.AddWithValue("@HasMultipleClients", canHaveMultipleClients);
                cmd.Parameters.AddWithValue("@StartEntryDateTime", startDateTime);
                cmd.Parameters.AddWithValue("@EndEntryDateTime", stopDateTime);

                cmd.Parameters.AddWithValue("@e_id", e_id);

                cmd.Parameters.Add("@Id", SqlDbType.BigInt);
                cmd.Parameters["@Id"].Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();

                return long.Parse(cmd.Parameters["@Id"].Value.ToString());
            }

        }
        private static long InsertTimeEntries(SqlConnection con, SqlTransaction objTransAction, long timeEntryDayID,
            string numberOfMinutes, string timeEntrytaskID, string clientid, string note,
            bool canHaveMultipleClients, string holidayTaskID, bool specifyStartStopTime, long autoPopulateDaysId , long e_id
            )
        {
            if (specifyStartStopTime)
            {
                List<long> _listIds = InsertTimeEntriesStopStartTime(con, objTransAction, timeEntryDayID, timeEntrytaskID, clientid, note,
                    canHaveMultipleClients, autoPopulateDaysId , e_id
                    );

                return _listIds.Count > 0 ? _listIds[0] : 0;
            }
            using (SqlCommand cmd = new SqlCommand("TIMESHEET_InsertTimeEntries", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Transaction = objTransAction;
                cmd.Parameters.AddWithValue("@timeEntryDayID", timeEntryDayID);
                cmd.Parameters.AddWithValue("@timeOfTask", _DateToRun.ToString("MM/dd/yyyy"));
                cmd.Parameters.AddWithValue("@numberMinutes", numberOfMinutes);

                long long_value = 0;

                if (string.IsNullOrEmpty(timeEntrytaskID))
                {
                    cmd.Parameters.AddWithValue("@timeEntrytaskID", DBNull.Value);
                }
                else
                {
                    long.TryParse(timeEntrytaskID, out long_value);
                    cmd.Parameters.AddWithValue("@timeEntrytaskID", long_value);
                }

                if (string.IsNullOrEmpty(clientid))
                {
                    cmd.Parameters.AddWithValue("@orgClientID", DBNull.Value);
                }
                else
                {
                    long.TryParse(clientid, out long_value);
                    // Can never have a client id of 0
                    if (long_value == 0)
                        cmd.Parameters.AddWithValue("@orgClientID", DBNull.Value);
                    else
                        cmd.Parameters.AddWithValue("@orgClientID", long_value);
                }

                cmd.Parameters.AddWithValue("@note", "Task Template Entry");
                cmd.Parameters.AddWithValue("@dateEntryUpdated", DateTime.Now.ToString());
                cmd.Parameters.AddWithValue("@HasMultipleClients", canHaveMultipleClients);

                if (string.IsNullOrEmpty(holidayTaskID))
                {
                    cmd.Parameters.AddWithValue("@holidayTaskID", DBNull.Value);
                }
                else
                {
                    long.TryParse(holidayTaskID, out long_value);
                    cmd.Parameters.AddWithValue("@holidayTaskID", long_value);
                }

                cmd.Parameters.Add("@Id", SqlDbType.BigInt);
                cmd.Parameters["@Id"].Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();

                return long.Parse(cmd.Parameters["@Id"].Value.ToString());
            }
        }
        private static long InsertTimeEntries(SqlConnection con, SqlTransaction objTransAction, DataRow dataRow, long timeEntryDayID)
        {
            string clientid = dataRow.IsNull("clientid") ? string.Empty : dataRow["clientid"].ToString();

            return InsertTimeEntries(

                con, objTransAction,
                timeEntryDayID,
                dataRow["numberOfMinutes"].ToString(),
                dataRow["timeentrytaskid"].ToString(),
                clientid,
                "Task Template Entry",
                bool.Parse(dataRow["CanHaveMultipleClients"].ToString()),
                string.Empty,
                bool.Parse(dataRow["SpecifyStartStopTime"].ToString()),
                long.Parse(dataRow["AautoPopulateDaysId"].ToString())
                ,
                long.Parse( dataRow["EmployeeId"].ToString() )

            );
        }
        private static long InsertIntoTimeEntryDay(SqlConnection con, SqlTransaction objTransAction, List<DataRow> listEmployeeTasks)
        {
            long _timeEntryDayID = 0;

            using (SqlCommand cmd = new SqlCommand("TIMESHEET_InsertTimeEntryDay", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Transaction = objTransAction;
                cmd.Parameters.AddWithValue("@employeeId", listEmployeeTasks[0]["EmployeeId"].ToString());
                cmd.Parameters.AddWithValue("@dateForTimeEntry", _DateToRun.ToString("MM/dd/yyyy"));
                cmd.Parameters.Add("@Id", SqlDbType.BigInt);
                cmd.Parameters["@Id"].Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();

                _timeEntryDayID = long.Parse(cmd.Parameters["@Id"].Value.ToString());
            }

            return _timeEntryDayID;
        }
        private static void DeleteTimeEntryDay(SqlConnection con, 
            SqlTransaction objTransAction, DataTable dataTable)
        {
            using (SqlCommand cmd = new SqlCommand("TIMESHEET_DeleteTimeEntries", con))
            {
                DataRow _dataRow = dataTable.Rows[0];
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Transaction = objTransAction;
                cmd.Parameters.AddWithValue("@timeEntryDayID", _dataRow["id"].ToString());

                cmd.ExecuteNonQuery();
            }
        }

        private static void SendEmailsToYesterdaysNaughtyList (SqlConnection con)
        {
            DisplayNotice(Return.RET_INFO, "Checking for missing time period confirmations");
            
            /* If today is a weekend then we skip sending notifications (if any) */

            if ( (DateTime.Today.DayOfWeek == DayOfWeek.Saturday) || (DateTime.Today.DayOfWeek == DayOfWeek.Sunday) )
            {
              DisplayNotice(Return.RET_INFO, "Today is a weekend day so we skip checking for missing time periods");
              return;
            }

            /* Get current missing confirmations, if any */

            DetailsLog logg   = new DetailsLog();
            UserInfo   usInfo = new UserInfo();

            var notices = MBA.Security.BitteTimePeople.getCurrentMissingTimePeriodConfirmationsSummary (con,logg,usInfo,false);
            
            /* No one to notify?  Exit. */

            if (notices.Count == 0) {
              DisplayNotice(Return.RET_INFO, "No missing time period confirmations found");
              return;            
            }
            
            /* We have some notifications to process */

            DisplayNotice(Return.RET_INFO, "There are missing time period confirmations");
            
            string retStatus; 
            bool   result;
            
            foreach (var notice in notices)
            {
              DisplayNotice(Return.RET_INFO, "Sending message to " + notice.firstName);
              
              /* Send notice to work email (everyone should have a work email) */
              
              result = MBA.Email.sendAnnouncementAsHtmlWithHeroImage60pctAndImageList(

                  //0,  // userMsgId; these messages don't have a corresponding dialog widget to open, so the URL param openmsgmodal
                  // will not be applicable

                  false, // promptUserToGotoURL
                  null,
                  null  // TimeKeeper "naughty list" emails will also not have a gotoURL callback, at least for this release

                , Constants.APP_EMAIL_FROM
                , notice.emailWork
                , notice.firstName + ", your DailyTimeKeeper hour entries are overdue for verification and approval"
                , "Please verify hours for the weeks listed below."
                , notice.confirmationsMissingObj.listItems

                , MBA.EmbeddedResources.CommonImages.IMAGE_NAME_PCA_LOGO_W_PENCIL

                , MBA.EmbeddedResources.CommonImages.IMAGE_NAME_LIST_ITEM_DOCTOR_SPEAKING
                , out retStatus
              );
             
              if (result == true)
                  DisplayNotice(Return.RET_SUCCESS, @"Sent message");
              else
                 DisplayNotice(Return.RET_ABORT_OR_CANCEL, @"FAILED!");

              /* If there is no personal email available, skip to next notice. */

              if (Util.IsNullOrEmpty(notice.emailPersonal) || (notice.emailWork == notice.emailPersonal))
                continue;

              /* Otherwise send notification to personal email as well */

              result = MBA.Email.sendAnnouncementAsHtmlWithHeroImage60pctAndImageList(

                  //0,  // userMsgId; these messages don't have a corresponding dialog widget to open, so the URL param openmsgmodal
                  // will not be applicable

                  false, // promptUserToGotoURL
                  null,
                  null  // TimeKeeper "naughty list" emails will also not have a gotoURL callback, at least for this release

                , Constants.APP_EMAIL_FROM
                , notice.emailPersonal
                , notice.firstName + ", your DailyTimeKeeper hour entries are overdue for verification and approval"
                , "Please verify hours for the weeks listed below."
                , notice.confirmationsMissingObj.listItems


                , MBA.EmbeddedResources.CommonImages.IMAGE_NAME_PCA_LOGO_W_PENCIL


                , MBA.EmbeddedResources.CommonImages.IMAGE_NAME_LIST_ITEM_DOCTOR_SPEAKING
                , out retStatus
              );
            
            } 
        }

        private static void ProcessEmployeeAutoScheduler(SqlConnection con, SqlTransaction objTrans, int inWeeksToGenerate)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TIMESHEET_GetEmployeeSchedules", con);
            _sqlDataAdapter.SelectCommand.Transaction = objTrans;
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            if (_dataTable.Rows.Count == 0)
            {
                DisplayNotice(Return.RET_INFO, "No employees to proces");
                return;
            }

            DateTime _dateTime = DateTime.Now;
            DisplayNotice(Return.RET_INFO, "Number of employees to process " + _dataTable.Rows.Count.ToString());

            for (int _counter = 0; _counter < inWeeksToGenerate; _counter++)
            {
                InsertSchedule(con, _dataTable, objTrans, _dateTime.AddDays(7 * _counter));
            }

            DisplayNotice(Return.RET_INFO, "Schedules have been generated!");
        }

        private static void InsertSchedule(SqlConnection con, DataTable dataTableScheduleTemplate, SqlTransaction sqlTransaction,
            DateTime dateTime)
        {
            DateTime _startOfTheWeekDate = DateTime.MinValue;
            // Get date for sunday of this week
            if (dateTime.DayOfWeek == DayOfWeek.Sunday)
            {
                _startOfTheWeekDate = dateTime;
            }
            else
            {
                _startOfTheWeekDate = dateTime.AddDays(-1 * (int)dateTime.DayOfWeek);
            }

            string _sqlStatement = string.Empty;
            string _sqlStatement1 = @"
                    select
	                    DOW.ID as DayOfTheWeek
	                    ,DOW.day as DayValue
	                    ,APST.starttime
	                    ,APST.stoptime
                    from
	                    TimeKeeper.dbo.AutoPopulateScheduleDays APSD
	                    inner join TimeKeeper.dbo.AutoPopulateScheduleStartAndStopTime APST
		                    on APST.autoPopulateScheduleDaysId = APSD.id
	                    inner join TimeKeeper.dbo.DaysOfTheWeek DOW
		                    on DOW.id = APSD.dayId
                    where
	                    APSD.scheduleid = ";

            string _sqlStatement2 = @"
                    order by
	                    DOW.ID";

            int _employeeId = 0;
            DataTable _dataTableTemplateDays = null;
            SqlDataAdapter _sqlDataAdapter = null;
            long _scheduleApproveId = 0;

            foreach (DataRow _dataRowScheduleTemplate in dataTableScheduleTemplate.Rows)
            {
                _employeeId = int.Parse(_dataRowScheduleTemplate["id"].ToString());
                _sqlStatement = _sqlStatement1 + _dataRowScheduleTemplate["autoPopulateSdheduleTemplateId"] + _sqlStatement2;

                _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
                _sqlDataAdapter.SelectCommand.Transaction = sqlTransaction;
                _dataTableTemplateDays = new DataTable();
                _sqlDataAdapter.Fill(_dataTableTemplateDays);

                _scheduleApproveId = InsertScheduleApproved(con, _employeeId, _startOfTheWeekDate, sqlTransaction);

                if (_dataTableTemplateDays.Rows.Count > 0)
                {
                    InsertSchedule(con, _employeeId, _startOfTheWeekDate, _dataTableTemplateDays, sqlTransaction, _scheduleApproveId);
                }
            }
        }

        private static long InsertScheduleApproved(SqlConnection con, int employeeId, DateTime dateOfSchedule, SqlTransaction sqlTransaction)
        {
            DateTime _startDate = dateOfSchedule.DayOfWeek == DayOfWeek.Sunday ? dateOfSchedule :
                    dateOfSchedule.AddDays(-1 * (int)dateOfSchedule.DayOfWeek);
            DateTime _endDate = dateOfSchedule.DayOfWeek == DayOfWeek.Saturday ? dateOfSchedule :
                    dateOfSchedule.AddDays(6 - (int)dateOfSchedule.DayOfWeek);

            SqlCommand _sqlCommand = new SqlCommand("SCHEDULE_CreateNewScheduleApproved", con);
            _sqlCommand.Transaction = sqlTransaction;
            _sqlCommand.CommandType = CommandType.StoredProcedure;
            _sqlCommand.Parameters.AddWithValue("@EmployeeId", employeeId);
            _sqlCommand.Parameters.AddWithValue("@StartDate", _startDate);
            _sqlCommand.Parameters.AddWithValue("@EndDate", _endDate);
            _sqlCommand.Parameters.Add("@Id", SqlDbType.BigInt);
            _sqlCommand.Parameters["@Id"].Direction = ParameterDirection.Output;

            _sqlCommand.ExecuteNonQuery();

            return long.Parse(_sqlCommand.Parameters["@Id"].Value.ToString());
        }

        private static void InsertSchedule(SqlConnection con, int employeeId, DateTime startOfTheWeek,
                    DataTable dataTableTemplateDays, SqlTransaction sqlTransaction, long scheduleApproveId)
        {
            DateTime _dateOfSchedule = DateTime.MinValue;
            int _scheduleId = 0;
            DateTime _startTime = DateTime.MinValue;
            DateTime _stopTime = DateTime.MinValue;
            string _dateString = string.Empty;
            int _previousScheduleId = 0;

            foreach (DataRow _dataRow in dataTableTemplateDays.Rows)
            {
                _dateOfSchedule = startOfTheWeek.AddDays(int.Parse(_dataRow["DayOfTheWeek"].ToString()));
                _scheduleId = InsertSchedule(con, employeeId, _dateOfSchedule, sqlTransaction, scheduleApproveId);

                // Delete previous start stop entries if they exist 
                if ((_previousScheduleId == 0) ||
                    (_previousScheduleId != _scheduleId))
                {
                    _previousScheduleId = _scheduleId;
                    DeletePreviousSchedule(_scheduleId, con, sqlTransaction);
                }

                if (_scheduleId != -1)
                {
                    _dateString = _dateOfSchedule.ToString("MM/dd/yyyy") + " " + DateTime.Parse(_dataRow["starttime"].ToString()).ToString("hh:mm tt");
                    _startTime = DateTime.Parse(_dateString);
                    _dateString = _dateOfSchedule.ToString("MM/dd/yyyy") + " " + DateTime.Parse(_dataRow["stoptime"].ToString()).ToString("hh:mm tt");
                    _stopTime = DateTime.Parse(_dateString);
                    InsertScheduleStopStartTime(con, _scheduleId, _startTime, _stopTime, sqlTransaction);
                }
            }
        }

        private static void DeletePreviousSchedule(int scheduleId, SqlConnection con, SqlTransaction sqlTransaction)
        {
            string _deleteStatement = @"
                delete
                from TimeKeeper.dbo.ScheduleStartAndStopTime
                where scheduleid = " + scheduleId.ToString();

            using (SqlCommand _sqlcommand = new SqlCommand(_deleteStatement, con))
            {
                _sqlcommand.Transaction = sqlTransaction;
                _sqlcommand.ExecuteScalar();
            }
        }

        private static int InsertSchedule(SqlConnection con, int employeeId, DateTime dateOfSchedule,
            SqlTransaction sqlTransaction, long scheduleApproveId)
        {
            SqlCommand _sqlCommand = new SqlCommand("SCHEDULE_CreateNew", con);
            _sqlCommand.Transaction = sqlTransaction;
            _sqlCommand.CommandType = CommandType.StoredProcedure;
            _sqlCommand.Parameters.AddWithValue("@EmployeeId", employeeId);
            _sqlCommand.Parameters.AddWithValue("@ScheduleApproveId", scheduleApproveId);
            _sqlCommand.Parameters.AddWithValue("@DateOfSchedule", dateOfSchedule);
            _sqlCommand.Parameters.Add("@Id", SqlDbType.BigInt);
            _sqlCommand.Parameters["@Id"].Direction = ParameterDirection.Output;

            _sqlCommand.ExecuteNonQuery();

            return int.Parse(_sqlCommand.Parameters["@Id"].Value.ToString());
        }

        private static int InsertScheduleStopStartTime(SqlConnection con, int scheduleId, DateTime startTime, DateTime endTime, SqlTransaction sqlTransaction)
        {
            SqlCommand _sqlCommand = new SqlCommand("SCHEDULE_STOP_START_CreateNew", con);
            _sqlCommand.Transaction = sqlTransaction;
            _sqlCommand.CommandType = CommandType.StoredProcedure;
            _sqlCommand.Parameters.AddWithValue("@ScheduleId", scheduleId);
            _sqlCommand.Parameters.AddWithValue("@StartTime", startTime);
            _sqlCommand.Parameters.AddWithValue("@StopTime", endTime);
            _sqlCommand.Parameters.Add("@Id", SqlDbType.BigInt);
            _sqlCommand.Parameters["@Id"].Direction = ParameterDirection.Output;

            _sqlCommand.ExecuteNonQuery();

            return int.Parse(_sqlCommand.Parameters["@Id"].Value.ToString());
        }
    }
}
