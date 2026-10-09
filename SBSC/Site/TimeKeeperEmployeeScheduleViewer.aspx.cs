using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Spedmon
{
    public partial class TimeKeeperEmployeeScheduleViewer : WebUI
    {
        private class EmployeesScheduleInfo
        {
            public string ScheduleId { get; set; }
            public string ScheduleStartAndStopTimeIds { get; set; }
            public string PersonId { get; set; }
            public string EmployeeId { get; set; }
            public string Name { get; set; }
            public string WeekStart { get; set; }
            public string DateOfDay { get; set; }
            public string Day { get; set; }
            public string ScheduledTimes { get; set; }
            public string DayHours { get; set; }
            public string WeekHours { get; set; }
        }
        public TimeKeeperEmployeeScheduleViewer()
             : base("timeentry", WebUI.CreatePageSubTitle("Employee Schedule Viewer", "View Employee schedule"), "", "", Constants.ROLE_SBS_ALL)
        {
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            datepicker.TodaysDate = DateTime.Today;
            if (!IsPostBack)
            {
                if (rd.wu.usr.timeSheetUserInfo == null)
                {
                    rd.wu.usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(rd.wu.usr.userName);
                }

                HiddenFieldEmployeeID.Value = rd.wu.usr.timeSheetUserInfo.employeeid.ToString();
                DateTime _selectedDate = DateTime.Today;
                // Current date is not sunday calculate to previous Sunday
                if (_selectedDate.DayOfWeek != DayOfWeek.Sunday)
                {
                    _selectedDate = _selectedDate.AddDays(-1 * ((int)_selectedDate.DayOfWeek));
                }
                labelSelectedDate.Text = _selectedDate.ToString("MM/dd/yyyy");
                using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                {
                    PopulateEmployeeDropDownList(_con);
                    EvaluateFiltersAndPopulateRepeater(_con);
                }
            }
        }

        private void PopulateEmployeeDropDownList(SqlConnection con)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetEmployeeList", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            DropDownListEmployees.DataSource = _dataTable;
            DropDownListEmployees.DataTextField = "Name";
            DropDownListEmployees.DataValueField = "EmployeeId";
            DropDownListEmployees.DataBind();

            ListItem _item = new ListItem();
            _item.Value = "-1";
            _item.Text = "All Employee";

            DropDownListEmployees.Items.Insert(0, _item);

            DropDownListEmployees.SelectedValue = "-1";
        }
        private void EvaluateFiltersAndPopulateRepeater(SqlConnection con)
        {
            string _sqlStatement =
            @"select
                S.id as 'ScheduleId'
		        ,SSS.id as 'ScheduleStartAndStopTimeId'
		        ,P.id as 'PersonId'
		        ,E.id as 'EmployeeId'
		        ,P.firstName
		        ,P.lastName
		        ,P.firstName + ' ' + P.lastName as 'Name'
		        ,S.dateOfSchedule
		        ,SSS.starttime
		        ,SSS.stoptime
             from
                [TimeKeeper].[dbo].[Schedule] S
                INNER JOIN[TimeKeeper].[dbo].[ScheduleStartAndStopTime] SSS
                    ON SSS.scheduleid = S.id
                INNER JOIN[TimeKeeper].[dbo].[Employees] E
                    ON E.id = S.employeeID
                INNER JOIN[TimeKeeper].[dbo].[People] P
                    ON P.id = E.personID
            where 
                S.dateOfSchedule >= @startDate AND S.dateOfSchedule < @endDate";

            if (DropDownListEmployees.SelectedValue != "-1")
            {
                _sqlStatement += " AND E.id = @employeeId";
            }
            _sqlStatement += " order by P.firstName, p.lastName, E.id, SSS.starttime ";

            SqlDataAdapter _sqlAdapter = new SqlDataAdapter(_sqlStatement, con);
            DateTime _startDate;
            DateTime _endDate;

            if (DropDownListDayOfWeek.SelectedValue == "-1")
            {
                _startDate = DateTime.Parse(labelSelectedDate.Text);
                _endDate = _startDate.AddDays(7);
            }
            else
            {
                _startDate = DateTime.Parse(labelSelectedDate.Text).AddDays(int.Parse(DropDownListDayOfWeek.SelectedValue));
                _endDate = _startDate.AddDays(1);
            }

            _sqlAdapter.SelectCommand.Parameters.AddWithValue("@startDate", _startDate.ToString("MM/dd/yyyy"));
            _sqlAdapter.SelectCommand.Parameters.AddWithValue("@endDate", _endDate.ToString("MM/dd/yyyy"));

            if (DropDownListEmployees.SelectedValue != "-1")
            {
                _sqlAdapter.SelectCommand.Parameters.AddWithValue("@employeeId", int.Parse(DropDownListEmployees.SelectedValue));
            }

            DataTable _dataTable = new DataTable();
            _sqlAdapter.Fill(_dataTable);

            ProcessDataTable(_dataTable, con);
        }

        private void ProcessDataTable(DataTable dataTable, SqlConnection con)
        {
            List<EmployeesScheduleInfo> _listEmployeeSchedules = new List<EmployeesScheduleInfo>();
            EmployeesScheduleInfo _employeeScheduleInfo = null;
            bool _firstTime = true;
            DateTime _dateOfDay;
            DateTime _startTime;
            DateTime _stopTime;
            TimeSpan _dayTimeSpan;

            foreach(DataRow _dataRow in dataTable.Rows)
            {
                // Copy values from data row into object unless it is not the first time or schedule id don't match 
                if (_firstTime || _dataRow["ScheduleId"].ToString() != _employeeScheduleInfo.ScheduleId)
                {
                    // If not the first time put value in list
                    if (_firstTime)
                    {
                        _firstTime = false;
                    }
                    else
                    {
                        _listEmployeeSchedules.Add(_employeeScheduleInfo);
                    }

                    _employeeScheduleInfo = new EmployeesScheduleInfo();

                    _employeeScheduleInfo.ScheduleId = _dataRow["ScheduleId"].ToString();
                    _employeeScheduleInfo.ScheduleStartAndStopTimeIds = _dataRow["ScheduleStartAndStopTimeId"].ToString();
                    _employeeScheduleInfo.PersonId = _dataRow["PersonId"].ToString();
                    _employeeScheduleInfo.EmployeeId = _dataRow["EmployeeId"].ToString();
                    _employeeScheduleInfo.Name = _dataRow["Name"].ToString();
                    _employeeScheduleInfo.WeekStart = labelSelectedDate.Text;

                    _employeeScheduleInfo.DateOfDay = DateTime.Parse(_dataRow["dateOfSchedule"].ToString()).ToString("MM/dd/yyyy");
                    _dateOfDay = DateTime.Parse(_employeeScheduleInfo.DateOfDay);
                    switch(_dateOfDay.DayOfWeek)
                    {
                        case DayOfWeek.Sunday:
                            _employeeScheduleInfo.Day = "Sunday";
                            break;
                        case DayOfWeek.Monday:
                            _employeeScheduleInfo.Day = "Monday";
                            break;
                        case DayOfWeek.Tuesday:
                            _employeeScheduleInfo.Day = "Tuesday";
                            break;
                        case DayOfWeek.Wednesday:
                            _employeeScheduleInfo.Day = "Wednesday";
                            break;
                        case DayOfWeek.Thursday:
                            _employeeScheduleInfo.Day = "Thursday";
                            break;
                        case DayOfWeek.Friday:
                            _employeeScheduleInfo.Day = "Friday";
                            break;
                        case DayOfWeek.Saturday:
                            _employeeScheduleInfo.Day = "Saturday";
                            break;
                    }

                    _startTime = DateTime.Parse(_dataRow["starttime"].ToString());
                    _stopTime = DateTime.Parse(_dataRow["stoptime"].ToString());
                    _dayTimeSpan = _stopTime - _startTime;
                    _employeeScheduleInfo.ScheduledTimes = _startTime.ToString("hh:mm tt") + " to " + _stopTime.ToString("hh:mm tt");
                    _employeeScheduleInfo.DayHours = _dayTimeSpan.TotalHours.ToString();
                    continue;
                }
                _employeeScheduleInfo.ScheduleStartAndStopTimeIds += "," + _dataRow["ScheduleStartAndStopTimeId"].ToString();
                _startTime = DateTime.Parse(_dataRow["starttime"].ToString());
                _stopTime = DateTime.Parse(_dataRow["stoptime"].ToString());
                _dayTimeSpan = _stopTime - _startTime;
                _employeeScheduleInfo.DayHours = (double.Parse(_employeeScheduleInfo.DayHours.ToString()) + _dayTimeSpan.TotalHours).ToString();
                _employeeScheduleInfo.ScheduledTimes += "<br/>" + _startTime.ToString("hh:mm tt") + " to " + _stopTime.ToString("hh:mm tt");
            }
            if (_employeeScheduleInfo != null)
            {
                _listEmployeeSchedules.Add(_employeeScheduleInfo);
            }

            // Loop thru list again and get totals for the week
            foreach(EmployeesScheduleInfo _employeeSchedule in _listEmployeeSchedules)
            {
                GetWeekTotalsForEmployee(_employeeSchedule, con);
            }

            repeaterEmployeesSchedule.DataSource = _listEmployeeSchedules;
            repeaterEmployeesSchedule.DataBind();
        }

        private void GetWeekTotalsForEmployee(EmployeesScheduleInfo employeesScheduleInfo, SqlConnection con)
        {
            DateTime _startDate = DateTime.Parse(labelSelectedDate.Text);
            DateTime _endDate = _startDate.AddDays(7);

            //SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("SELECT * FROM TimeKeeper_TIMESHEET_GetSchedulesForEmployeesByDateRangeUDF(@startDate, @endDate, @employeeId)", con);
            //_sqlDataAdapter.SelectCommand.CommandType = CommandType.Text;
            
            // NOTE: this has been tested and seems to be working as a UDF call; perhaps could be tested further.  Reverting.
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetSchedulesForEmployeesByDateRange", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@startDate", _startDate);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@endDate", _endDate);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@employeeId", long.Parse(employeesScheduleInfo.EmployeeId));

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            double _totalWeekHours = 0;
            TimeSpan _timeSpan;

            foreach(DataRow _dataRow in _dataTable.Rows)
            {
                _timeSpan = DateTime.Parse(_dataRow["stoptime"].ToString()) - DateTime.Parse(_dataRow["starttime"].ToString());
                _totalWeekHours += _timeSpan.TotalHours;
            }

            employeesScheduleInfo.WeekHours = _totalWeekHours.ToString();
        }

        protected void Calendar_DayRender(object sender, DayRenderEventArgs e)
        {
            if (e.Day.Date.DayOfWeek != DayOfWeek.Sunday)
            {
                e.Cell.ForeColor = System.Drawing.Color.Gray;
                e.Day.IsSelectable = false;
            }
        }
        protected void datepicker_SelectionChanged(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                labelSelectedDate.Text = datepicker.SelectedDate.ToString("MM/dd/yyyy");
                datepicker.Visible = false;
                DropDownListDayOfWeek.SelectedValue = "-1";
                DropDownListEmployees.SelectedValue = "-1";
                EvaluateFiltersAndPopulateRepeater(_con);
            }
        }
        protected void lnkpickdate_Click(object sender, EventArgs e)
        {
            datepicker.Visible = true;
        }

        protected void DropDownListDayOfWeek_SelectedIndexChanged(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                EvaluateFiltersAndPopulateRepeater(_con);
            }
        }

        protected void DropDownListEmployees_SelectedIndexChanged(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                EvaluateFiltersAndPopulateRepeater(_con);
            }
        }
    }
}