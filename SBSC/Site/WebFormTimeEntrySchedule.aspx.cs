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
using MBA.Web;
using MBA.BitteTime;
using System.Collections.Generic;

namespace Spedmon
{
     public partial class WebFormSchedule :  WebUI
     {
          private TimeEntryWeek _TimeEntryWeek = new TimeEntryWeek();
          public WebFormSchedule()
               : base("schedule", WebUI.CreatePageSubTitle("Schedule", "Create, update, or delete work schedules"), "", "", Constants.ROLE_SBS_ALL)
          { 
          }

        private void SetUpPage()
        {
            SetEmployeeInfo();
            if (!IsDateInQueryString())
            {
                tbSelectedDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
            }
            bool _error = false;
            DateTime _dateTime = GetScheduleDate(tbSelectedDate.Text, out _error);
            if (_error)
            {
                tbSelectedDate.Text = _dateTime.ToString("MM/dd/yyyy");
            }
            GetScheduleInfoForDateAndSetLabels(_dateTime.Date);
            PopulateApprovePanel();
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            datepicker.TodaysDate = DateTime.Today;
            if (!IsPostBack)
            {
                SetUpPage();
            }

            bool _error = false;
            DateTime _dateTime = GetScheduleDate(tbSelectedDate.Text, out _error);
            if (_error)
            {
                tbSelectedDate.Text = _dateTime.ToString("MM/dd/yyyy");
            }

            if (TimeSheetSession.Current.EmployeeId == long.Parse(DropDownListEmployees.SelectedValue))
            {
                labelWarning.Visible = false;
            }
            else
            {
                labelWarning.Visible = true;
            }
        }

        /// <summary>
        /// Method will return back current date if string is invalid
        /// </summary>
        /// <param name="inDateString"></param>
        /// <returns></returns>
        private DateTime GetScheduleDate(string inDateString, out bool error)
        {
            error = false;
            DateTime _dateTime = DateTime.Today;

            try
            {
                _dateTime = DateTime.Parse(inDateString);
            }
            catch
            {
                error = true;
                _dateTime = DateTime.Today;
            }

            return _dateTime;
        }
        private void PopulateApprovePanel()
        {
            if (Request.UrlReferrer == null)
            {
                HiddenFieldReferringPage.Value = "home.aspx";
            }
            else
            {
                HiddenFieldReferringPage.Value = Request.UrlReferrer.ToString();
            }

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                if (!isEmployeeIdValid(_con))
                {
                    string _url = MBA.HttpApplication.createLink(HiddenFieldReferringPage.Value, false);
                    Response.Redirect(_url, true);
                    return;
                }
                if (!isDateSelectedValue())
                {
                    string _url = MBA.HttpApplication.createLink(HiddenFieldReferringPage.Value, false);
                    Response.Redirect(_url, true);
                    return;
                }

            }
        }

        private bool isDateSelectedValue()
        {
            DateTime _dateSelected = DateTime.MinValue;
            if (Request.QueryString["dateSelected"] == null)
            {
                DateTime.TryParse(tbSelectedDate.Text, out _dateSelected);
            }
            else
            {
                if (!DateTime.TryParse(Request.QueryString["dateSelected"].ToString(), out _dateSelected))
                {
                    return false;
                }
            }

            DateTime _startDate = _dateSelected.DayOfWeek == DayOfWeek.Sunday ? _dateSelected : _dateSelected.AddDays(-1 * (int)_dateSelected.DayOfWeek);
            DateTime _endDate = _dateSelected.DayOfWeek == DayOfWeek.Saturday ? _dateSelected : _dateSelected.AddDays(6 - (int)_dateSelected.DayOfWeek);

            HiddenFieldSelectedDate.Value = _dateSelected.ToString("MM/dd/yyyy");
            HiddenFieldStartDate.Value = _startDate.ToString("MM/dd/yyyy");
            HiddenFieldEndDate.Value = _endDate.ToString("MM/dd/yyyy");

            return true;
        }

        private bool isEmployeeIdValid(SqlConnection con)
        {
            long _employeeId = 0;
            if (Request.QueryString["employeeid"] == null)
            {
                _employeeId = TimeSheetSession.Current.EmployeeId;
            }
            else
            {
                long.TryParse(Request.QueryString["employeeid"].ToString(), out _employeeId);
            }

            if (_employeeId == 0)
            {
                return false;
            }

            string _sqlStatement = @"
                select
	                *
                from
	                [TimeKeeper].[dbo].[Employees]
                where
	                [id] = @Id";

            DataTable _dataTable = new DataTable();
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", _employeeId);
            _sqlDataAdapter.Fill(_dataTable);

            if (_dataTable.Rows.Count == 0)
            {
                return false;
            }

            HiddenFieldEmployeeId.Value = _employeeId.ToString();

            return true;
        }

        private void SetEmployeeInfo()
        {
            if (Request.QueryString.ToString().Contains("employeeid") && (TimeSheetSession.Current.RoleId == 1))
            {
                HiddenFieldEmployeeId.Value = Request.QueryString["employeeid"];
            }
            else
            {
                HiddenFieldEmployeeId.Value = TimeSheetSession.Current.EmployeeId.ToString();
            }

            LabelEmployee.Visible = false;
            BindDropDownEmployeeList();
        }

        private void BindDropDownEmployeeList()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetEmployeeInfo", _con);
                _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
                DataSet _dataSet = new DataSet();
                _sqlDataAdapter.Fill(_dataSet);

                DropDownListEmployees.DataTextField = "name";
                DropDownListEmployees.DataValueField = "id";

                DropDownListEmployees.DataSource = _dataSet.Tables[0];
                DropDownListEmployees.DataBind();

                DropDownListEmployees.SelectedValue = HiddenFieldEmployeeId.Value;

                GetEmployeeInfo(_con);

            }
        }

        private void GetEmployeeInfo(SqlConnection con)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetPresonInfo", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            _sqlDataAdapter.SelectCommand.Parameters.Add("@EmployeeId", SqlDbType.BigInt).Value = Convert.ToInt64(HiddenFieldEmployeeId.Value);
            DataSet _dataSet = new DataSet();
            _sqlDataAdapter.Fill(_dataSet);

            if (_dataSet.Tables[0].Rows.Count == 0)
            {
                string _url = MBA.HttpApplication.createLink("home.aspx", true);

                Response.Redirect(_url, false);
                return;
            }

            DataRow _dataRow = _dataSet.Tables[0].Rows[0];
            if (LabelEmployee.Visible == true)
            {
                LabelEmployee.Text = _dataRow["FirstName"].ToString() + " " + _dataRow["LastName"].ToString();
            }
            else
            {
                DropDownListEmployees.SelectedValue = HiddenFieldEmployeeId.Value;
            }
        }

        private void GetScheduleInfoForDateAndSetLabels(DateTime selectedDate)
        {
            // Strip hours and minutes before calling SP
            DateTime _selectedDate = DateTime.Parse(selectedDate.ToString("MM/dd/yyyy"));
            DataTable _dataTable = CallGetScheduleSP(_selectedDate);

            if (_dataTable == null)
            {
                LiteralScheduledTime.Text = "0 Hours";
                HiddenFieldHoursScheduled.Value = "0";
                HiddenFieldMinutesScheduled.Value = "0";
            }
            else
            {
                double _numberOfMinutes = 0;
                TimeSpan _timeSpan;
                foreach (DataRow _dataRow in _dataTable.Rows)
                {
                    _timeSpan = (DateTime.Parse(_dataRow["stoptime"].ToString()) - DateTime.Parse(_dataRow["starttime"].ToString()));
                    _numberOfMinutes += _timeSpan.Hours * 60 + _timeSpan.Minutes;
                }

                HiddenFieldHoursScheduled.Value = ((int)(_numberOfMinutes / 60)).ToString();
                HiddenFieldMinutesScheduled.Value = (_numberOfMinutes % 60).ToString();
                LiteralScheduledTime.Text = HiddenFieldHoursScheduled.Value + " Hours";

                if (HiddenFieldMinutesScheduled.Value != "0")
                {
                    LiteralScheduledTime.Text += " Minutes " + HiddenFieldMinutesScheduled.Value;
                }
            }

            DateTime _firstDayOfTheWeek = GetFirstDayOfTheWeek(_selectedDate);
            DateTime _lastDayOfTheWeek = GetLastDayOfTheWeek(_selectedDate);

            SetListToBuildTableFrom(_firstDayOfTheWeek, (_lastDayOfTheWeek - _firstDayOfTheWeek).Days);
            BuildTable();
        }

        protected void ButtonPreviousWeek_Click(object sender, EventArgs e)
        {
            DateTime _selectedDate = DateTime.Parse(tbSelectedDate.Text);
            _selectedDate = _selectedDate.Date.AddDays(-7);
            tbSelectedDate.Text = _selectedDate.ToString("MM/dd/yyyy");

            GetScheduleInfoForDateAndSetLabels(_selectedDate);
        }

        protected void ButtonNextWeek_Click(object sender, EventArgs e)
        {
            DateTime _selectedDate = DateTime.Parse(tbSelectedDate.Text);
            _selectedDate = _selectedDate.Date.AddDays(+7);
            tbSelectedDate.Text = _selectedDate.ToString("MM/dd/yyyy");

            GetScheduleInfoForDateAndSetLabels(_selectedDate);
        }

        private void BuildTable()
        {
            List<TimeEntryDay> _listDays = _TimeEntryWeek.ListOfDays;
            DataTable _dataTable = null;
            TimeSpan _timeSpan;
            int _numberOfMinutes = 0;
            string _url = string.Empty;

            // Currently assume table will only populate a 7 day week
            foreach (TimeEntryDay _timeEntryDay in _listDays)
            {
                _dataTable = CallGetScheduleSP(_timeEntryDay.DateForDay);

                if (_dataTable == null)
                {
                    _numberOfMinutes = 0;
                }
                else
                {
                    _numberOfMinutes = 0;
                    foreach (DataRow _dataRow in _dataTable.Rows)
                    {
                        _timeSpan = (DateTime.Parse(_dataRow["stoptime"].ToString()) - DateTime.Parse(_dataRow["starttime"].ToString()));
                        _numberOfMinutes += _timeSpan.Hours * 60 + _timeSpan.Minutes;
                    }
                }

                if (TimeSheetSession.Current.EmployeeId == long.Parse(DropDownListEmployees.SelectedValue))
                {
                    _url = MBA.HttpApplication.createLink("WebFormScheduleStopStart.aspx", true) + "&employeeid=" + HiddenFieldEmployeeId.Value + "&scheduledate=" +
                        _timeEntryDay.DateForDay.ToString("MM/dd/yyyy");
                }
                else
                {
                    _url = string.Empty;
                }

                switch (_timeEntryDay.DateForDay.DayOfWeek)
                {
                    case DayOfWeek.Sunday:
                        LiteralSunday.Text = @"
                    <p style='font-size: : medium'>
                        SUNDAY<br />
                        Scheduled : " + ((int)(_numberOfMinutes / 60)).ToString() + " Hours " + (_numberOfMinutes % 60).ToString() + @" Minutes<br/>
                        <a href='" + _url + "'>" + _timeEntryDay.DateForDay.ToString("MM/dd/yyyy") + @"</a>
                    </p>";
                        break;
                    case DayOfWeek.Monday:
                        LiteralMonday.Text = @"
                    <p style='font-size: : medium'>
                        MONDAY<br />
                        Scheduled : " + ((int)(_numberOfMinutes / 60)).ToString() + " Hours " + (_numberOfMinutes % 60).ToString() + @" Minutes<br/>
                        <a href='" + _url + "'>" + _timeEntryDay.DateForDay.ToString("MM/dd/yyyy") + @"</a>
                    </p>";
                        break;
                    case DayOfWeek.Tuesday:
                        LiteralTuesday.Text = @"
                    <p style='font-size: : medium'>
                        TUESDAY<br />
                        Scheduled : " + ((int)(_numberOfMinutes / 60)).ToString() + " Hours " + (_numberOfMinutes % 60).ToString() + @" Minutes<br/>
                        <a href='" + _url + "'>" + _timeEntryDay.DateForDay.ToString("MM/dd/yyyy") + @"</a>
                    </p>";
                        break;
                    case DayOfWeek.Wednesday:
                        LiteralWednesday.Text = @"
                    <p style='font-size: : medium'>
                        WEDNESDAY<br />
                        Scheduled : " + ((int)(_numberOfMinutes / 60)).ToString() + " Hours " + (_numberOfMinutes % 60).ToString() + @" Minutes<br/>
                        <a href='" + _url + "'>" + _timeEntryDay.DateForDay.ToString("MM/dd/yyyy") + @"</a>
                    </p>";
                        break;
                    case DayOfWeek.Thursday:
                        LiteralThursday.Text = @"
                    <p style='font-size: : medium'>
                        THURSDAY<br />
                        Scheduled : " + ((int)(_numberOfMinutes / 60)).ToString() + " Hours " + (_numberOfMinutes % 60).ToString() + @" Minutes<br/>
                        <a href='" + _url + "'>" + _timeEntryDay.DateForDay.ToString("MM/dd/yyyy") + @"</a>
                    </p>";
                        break;
                    case DayOfWeek.Friday:
                        LiteralFriday.Text = @"
                    <p style='font-size: : medium'>
                        FRIDAY<br />
                        Scheduled : " + ((int)(_numberOfMinutes / 60)).ToString() + " Hours " + (_numberOfMinutes % 60).ToString() + @" Minutes<br/>
                        <a href='" + _url + "'>" + _timeEntryDay.DateForDay.ToString("MM/dd/yyyy") + @"</a>
                    </p>";
                        break;
                    case DayOfWeek.Saturday:
                        LiteralSaturday.Text = @"
                    <p style='font-size: : medium'>
                        SATURDAY<br />
                        Scheduled : " + ((int)(_numberOfMinutes / 60)).ToString() + " Hours " + (_numberOfMinutes % 60).ToString() + @" Minutes<br/>
                        <a href='" + _url + "'>" + _timeEntryDay.DateForDay.ToString("MM/dd/yyyy") + @"</a>
                    </p>";
                        break;
                }

            }
        }

        private void SetListToBuildTableFrom(DateTime firstDayOfWeek, int numberOfDays)
        {
            DateTime _dayOfWeek = DateTime.MinValue;
            // Need to add one for loop.  Number of days for the week will be 6 not 7
            int _numberOfDays = numberOfDays + 1;
            for (int _counter = 0; _counter < _numberOfDays; _counter++)
            {
                _dayOfWeek = firstDayOfWeek.Date.AddDays(_counter);
                _TimeEntryWeek.SetDayOfWeek(_dayOfWeek);
            }
        }

        private DateTime GetFirstDayOfTheWeek(DateTime selectedDate)
        {
            if (selectedDate.DayOfWeek == DayOfWeek.Sunday)
            {
                return selectedDate;
            }

            return selectedDate.Date.AddDays(-1 * (int)selectedDate.DayOfWeek);
        }

        private DateTime GetLastDayOfTheWeek(DateTime selectedDate)
        {
            if (selectedDate.DayOfWeek == DayOfWeek.Saturday)
            {
                return selectedDate;
            }

            return selectedDate.Date.AddDays(6 - (int)selectedDate.DayOfWeek);
        }

        private DataTable CallGetScheduleSP(DateTime selectedDate)
        {
            DataTable _dt = new DataTable();

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetSchedule", _con);
                _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
                _sqlDataAdapter.SelectCommand.Parameters.Add("@employeeID", SqlDbType.BigInt).Value = Convert.ToInt64(HiddenFieldEmployeeId.Value);
                _sqlDataAdapter.SelectCommand.Parameters.Add("@startDate", SqlDbType.DateTime).Value = selectedDate.Date;
                _sqlDataAdapter.SelectCommand.Parameters.Add("@endDate", SqlDbType.DateTime).Value = selectedDate.Date.AddDays(1); // Get everything up till midnight of the start of the next week
                _sqlDataAdapter.Fill(_dt);
            }

            if (_dt.Rows.Count == 0)
            {
                return null;
            }

            return _dt;

        }
        private bool IsDateInQueryString()
        {
            bool _isPresent = false;

            try
            {
                // Verify a valid long
                //if (Session[TimeEntryWeek._SESSION_DATE_ENTRY] != null)
                //{
                //    tbSelectedDate.Text = DateTime.Parse(Session[TimeEntryWeek._SESSION_DATE_ENTRY].ToString()).ToString("MM/dd/yyyy");
                //}
                //else
                //{
                //    tbSelectedDate.Text = DateTime.Parse(Request.QueryString["dateforentry"]).ToString("MM/dd/yyyy");
                //}
                tbSelectedDate.Text = DateTime.Parse(Request.QueryString["dateforentry"]).ToString("MM/dd/yyyy");
                _isPresent = true;
            }
            catch
            {
                // Ignore error
            }

            return _isPresent;
        }

        protected void ButtonEdit_Click(object sender, EventArgs e)
        {
            string _url = MBA.HttpApplication.createLink("WebFormScheduleStopStart.aspx", true) +
                       "&employeeid=" + HiddenFieldEmployeeId.Value + "&scheduledate=" +
                        tbSelectedDate.Text;

            Response.Redirect(_url);
        }

        protected void lnkpickdate_Click(object sender, EventArgs e)
        {
            datepicker.Visible = true;
        }

        protected void datepicker_SelectionChanged(object sender, EventArgs e)
        {
            tbSelectedDate.Text = datepicker.SelectedDate.ToString("MM/dd/yyyy");
            datepicker.Visible = false;
            bool _error = false;
            DateTime _dateTime = GetScheduleDate(tbSelectedDate.Text, out _error);
            if (_error)
            {
                tbSelectedDate.Text = _dateTime.ToString("MM/dd/yyyy");
            }
            // If an error is detected reset value in tbSelectedDate
            GetScheduleInfoForDateAndSetLabels(_dateTime);

        }


        protected void DropDownListEmployees_SelectedIndexChanged(object sender, EventArgs e)
        {
            HiddenFieldEmployeeId.Value = DropDownListEmployees.SelectedValue;
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                GetEmployeeInfo(_con);
            }
            GetScheduleInfoForDateAndSetLabels(DateTime.Parse(tbSelectedDate.Text).Date);
        }
    }
}
