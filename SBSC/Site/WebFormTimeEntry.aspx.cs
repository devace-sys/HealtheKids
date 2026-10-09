using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;
using MBA.Web;
using MBA.BitteTime;
using MBA;
using System.Globalization;
using System.Web.UI.HtmlControls;

namespace Spedmon
{
    public partial class WebFormTimeEntry : WebUI
    {
        private string _DateForEntry = string.Empty;
        private TimeEntryWeek _TimeEntryWeek = new TimeEntryWeek();
        public string _URL = string.Empty;

        class ClientInfo
        {
            public long id { get; set; }
            public string name { get; set; }
        }
        class TimeEntryInfo
        {
            public TimeEntryInfo()
            {
                orgClientIDSunday = new List<long>();
                orgClientIDMonday = new List<long>();
                orgClientIDTuesday = new List<long>();
                orgClientIDWednesday = new List<long>();
                orgClientIDThursday = new List<long>();
                orgClientIDFriday = new List<long>();
                orgClientIDSaturday = new List<long>();

                timeEntryIDSunday = 0;
                timeEntryIDMonday = 0;
                timeEntryIDTuesday = 0;
                timeEntryIDWednesday = 0;
                timeEntryIDThursday = 0;
                timeEntryIDFriday = 0;
                timeEntryIDSaturday = 0;

                timeEntryDayIDSunday = 0;
                timeEntryDayIDMonday = 0;
                timeEntryDayIDTuesday = 0;
                timeEntryDayIDWednesday = 0;
                timeEntryDayIDThursday = 0;
                timeEntryDayIDFriday = 0;
                timeEntryDayIDSaturday = 0;

                dateForTimeEntrySunday = string.Empty;
                dateForTimeEntryMonday = string.Empty;
                dateForTimeEntryTuesday = string.Empty;
                dateForTimeEntryWednesday = string.Empty;
                dateForTimeEntryThursday = string.Empty;
                dateForTimeEntryFriday = string.Empty;
                dateForTimeEntrySaturday = string.Empty;

                disableTaskUpdateSunday = false;
                disableTaskUpdateMonday = false;
                disableTaskUpdateTuesday = false;
                disableTaskUpdateWednesday = false;
                disableTaskUpdateThursday = false;
                disableTaskUpdateFriday = false;
                disableTaskUpdateSaturday = false;
            }
            public int recordCount { get; set; }
            public bool disableTaskUpdateSunday { get; set; }
            public bool disableTaskUpdateMonday { get; set; }
            public bool disableTaskUpdateTuesday { get; set; }
            public bool disableTaskUpdateWednesday { get; set; }
            public bool disableTaskUpdateThursday { get; set; }
            public bool disableTaskUpdateFriday { get; set; }
            public bool disableTaskUpdateSaturday { get; set; }
            public long timeEntryDayIDSunday { get; set; }
            public long timeEntryDayIDMonday { get; set; }
            public long timeEntryDayIDTuesday { get; set; }
            public long timeEntryDayIDWednesday { get; set; }
            public long timeEntryDayIDThursday { get; set; }
            public long timeEntryDayIDFriday { get; set; }
            public long timeEntryDayIDSaturday { get; set; }
            public long timeEntryIDSunday { get; set; }
            public long timeEntryIDMonday { get; set; }
            public long timeEntryIDTuesday { get; set; }
            public long timeEntryIDWednesday { get; set; }
            public long timeEntryIDThursday { get; set; }
            public long timeEntryIDFriday { get; set; }
            public long timeEntryIDSaturday { get; set; }
            public long employeeId { get; set; }
            public long timeEntryId { get; set; }
            public string TaskName { get; set; }
            public string HolidayName { get; set; }
            public long timeEntrytaskID { get; set; }
            public long holidayTaskID { get; set; }
            public bool CanHaveMultipleClients { get; set; }
            public List<long> orgClientIDSunday { get; set; }
            public List<long> orgClientIDMonday { get; set; }
            public List<long> orgClientIDTuesday { get; set; }
            public List<long> orgClientIDWednesday { get; set; }
            public List<long> orgClientIDThursday { get; set; }
            public List<long> orgClientIDFriday { get; set; }
            public List<long> orgClientIDSaturday { get; set; }
            public string organizationsSunday { get; set; }
            public string organizationsMonday { get; set; }
            public string organizationsTuesday { get; set; }
            public string organizationsWednesday { get; set; }
            public string organizationsThursday { get; set; }
            public string organizationsFriday { get; set; }
            public string organizationsSaturday { get; set; }
            public string dateForTimeEntrySunday { get; set; }
            public string dateForTimeEntryMonday { get; set; }
            public string dateForTimeEntryTuesday { get; set; }
            public string dateForTimeEntryWednesday { get; set; }
            public string dateForTimeEntryThursday { get; set; }
            public string dateForTimeEntryFriday { get; set; }
            public string dateForTimeEntrySaturday { get; set; }

            public long numberMinutesSunday { get; set; }
            public long numberMinutesMonday { get; set; }
            public long numberMinutesTuesday { get; set; }
            public long numberMinutesWednesday { get; set; }
            public long numberMinutesThursday { get; set; }
            public long numberMinutesFriday { get; set; }
            public long numberMinutesSaturday { get; set; }
            public long numberHoursSunday { get; set; }
            public long numberHoursMonday { get; set; }
            public long numberHoursTuesday { get; set; }
            public long numberHoursWednesday { get; set; }
            public long numberHoursThursday { get; set; }
            public long numberHoursFriday { get; set; }
            public long numberHoursSaturday { get; set; }
        }

        Literal LiteralSunday = null;
        Literal LiteralMonday = null;
        Literal LiteralTuesday = null;
        Literal LiteralWednesday = null;
        Literal LiteralThursday = null;
        Literal LiteralFriday = null;
        Literal LiteralSaturday = null;
        public WebFormTimeEntry()
               : base("timeentry", WebUI.CreatePageSubTitle("Time Entry", "Create, update, or delete time entry"), "screen.css", "", Constants.ROLE_SBS_ALL)
        {
        }

        private void DetermineIfStopAndStartTimeRequried(SqlConnection con, DataTable dataTable, ref bool displayStartTime, ref bool displayStopTime)
        {
            // Sanity check
            if (dataTable.Rows.Count == 0)
            {
                return;
            }

            DataRow _dataRow = dataTable.Rows[0];

            displayStartTime = bool.Parse(_dataRow["specifyStartTime"].ToString());
            displayStopTime = bool.Parse(_dataRow["specifyEndTime"].ToString());
        }

        private DataTable GetEmployeeInfoDetail(SqlConnection con)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHET_GetEmployeeInfoDetail", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", HiddenFieldEmployeeId.Value);

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            return _dataTable;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                // Homelink is null
                InitLinksAndLabels();
                if (!IsPostBack)
                {
                    _URL = MBA.HttpApplication.createLink("PopupCalendar.aspx", true);
                    SetEmployeeIDFromQueryStringIfPresent();

                    EmployeeNameOrPopulateDropDownList();
                    SetPageWithEmployeeInfoAndTask();
                }
            }
            catch (Exception error)
            {
                LabelProblem.Text = error.StackTrace;
            }
        }
        private void CheckIfNeedToVerifyHours(SqlConnection con)
        {

            string warning_out = "", warning_out_hidden = "";

            string _lastDayOfSchedule = string.Empty;
            PanelVerifyHours.Visible = MBA.Security.BitteTimePeople.isHourVerifyRequired(con, log, uInfo, HiddenFieldEmployeeId.Value, ref warning_out, ref warning_out_hidden, ref _lastDayOfSchedule);
            HiddenFieldLastDayOfSchedule.Value = _lastDayOfSchedule;
            LabelVerifyPrompt.Text = warning_out;
            HiddenFieldVerifyId.Value = warning_out_hidden;
        }

        private void SetPageWithEmployeeInfoAndTask()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                bool _displayStartTime = false;
                bool _displayStopTime = false;
                DataTable _dataTable = GetEmployeeInfoDetail(_con);
                DetermineIfStopAndStartTimeRequried(_con, _dataTable, ref _displayStartTime, ref _displayStopTime);
                CheckIfNeedToVerifyHours(_con);

                HiddenFieldDisplayStartTime.Value = _displayStartTime.ToString();
                HiddenFieldDisplayStopTime.Value = _displayStopTime.ToString();
                GetEmployeeInfo();
                PopulateTaskTemplateTimeEntries(_con, DateTime.Today);
            }
            InitializeWeekInfo();
        }
        private void PopulateTaskTemplateTimeEntries(SqlConnection con, DateTime dateToProcess)
        {
            DateTime _firstDayOfTheWeek = DateTime.MinValue;
            DateTime _lastDayOfTheWeek = DateTime.MaxValue;

            GetStartAndEndDayOfTheWeek(ref _firstDayOfTheWeek, ref _lastDayOfTheWeek, dateToProcess);

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetTimeEntriesByDateAndEmployee", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;

            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@StartDate", _firstDayOfTheWeek);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@EndDate", _lastDayOfTheWeek.AddDays(1));
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@EmployeeId", HiddenFieldEmployeeId.Value);

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            List<TimeEntryInfo> _listEmployeeTimeInfo = new List<TimeEntryInfo>();
            TimeEntryInfo _timeEntryInfo = null;
            long _timeEntryTaskID = 0;
            int _index = 0;
            bool _exists = false;
            long _hours = 0;
            long _minutes = 0;
            long _numberMinutes = 0;
            int _count = 0;

            labelWeeklyHourCount.Text = "No Hours have been recorded";

            foreach (DataRow _dataRow in _dataTable.Rows)
            {
                _timeEntryTaskID = long.Parse(_dataRow["timeEntrytaskID"].ToString());
                _numberMinutes = long.Parse(_dataRow["numberMinutes"].ToString());
                _hours = _numberMinutes / 60;
                _minutes = _numberMinutes % 60;

                if ((_index = _listEmployeeTimeInfo.FindIndex(element => element.timeEntrytaskID == _timeEntryTaskID)) >= 0)
                {
                    _exists = true;
                    _timeEntryInfo = _listEmployeeTimeInfo[_index];
                }
                else
                {
                    _exists = false;
                    _timeEntryInfo = new TimeEntryInfo();
                    _timeEntryInfo.employeeId = long.Parse(_dataRow["employeeId"].ToString());
                    _timeEntryInfo.TaskName = _dataRow["TaskName"].ToString();
                    _timeEntryInfo.HolidayName = _dataRow["HolidayName"].ToString();
                    _timeEntryInfo.timeEntrytaskID = _timeEntryTaskID;
                    _timeEntryInfo.holidayTaskID = long.Parse(_dataRow["holidayTaskID"].ToString());
                    _timeEntryInfo.CanHaveMultipleClients = bool.Parse(_dataRow["CanHaveMultipleClients"].ToString());
                    _timeEntryInfo.recordCount = _count++;
                }

                DateTime _dateForTimeEntry;

                switch ((_dateForTimeEntry = DateTime.Parse(_dataRow["dateForTimeEntry"].ToString())).DayOfWeek)
                {
                    case DayOfWeek.Sunday:
                        // if there is already time value from a previous task entry, disable the control so  no update can be done
                        if (_timeEntryInfo.numberHoursSunday > 0 || _timeEntryInfo.numberMinutesSunday > 0)
                        {
                            _timeEntryInfo.disableTaskUpdateSunday = true;
                        }
                        _timeEntryInfo.numberHoursSunday += _hours;
                        _timeEntryInfo.numberMinutesSunday += _minutes;
                        if (_timeEntryInfo.numberMinutesSunday > 59)
                        {
                            _numberMinutes = _timeEntryInfo.numberHoursSunday * 60 + _timeEntryInfo.numberMinutesSunday;
                            _timeEntryInfo.numberHoursSunday = _numberMinutes / 60;
                            _timeEntryInfo.numberMinutesSunday = _numberMinutes % 60;
                        }
                        _timeEntryInfo.orgClientIDSunday.Add(long.Parse(_dataRow["orgClientID"].ToString()));
                        _timeEntryInfo.organizationsSunday = _dataRow["OrganizationName"].ToString();
                        _timeEntryInfo.timeEntryIDSunday = long.Parse(_dataRow["timeEntryID"].ToString());
                        _timeEntryInfo.dateForTimeEntrySunday = _dateForTimeEntry.ToString("MM/dd/yyyy");
                        _timeEntryInfo.timeEntryDayIDSunday = long.Parse(_dataRow["timeEntryDayID"].ToString());
                        break;
                    case DayOfWeek.Monday:
                        // if there is already time value from a previous task entry, disable the control so  no update can be done
                        if (_timeEntryInfo.numberHoursMonday > 0 || _timeEntryInfo.numberMinutesMonday > 0)
                        {
                            _timeEntryInfo.disableTaskUpdateMonday = true;
                        }
                        _timeEntryInfo.numberHoursMonday += _hours;
                        _timeEntryInfo.numberMinutesMonday += _minutes;
                        if (_timeEntryInfo.numberMinutesMonday > 59)
                        {
                            _numberMinutes = _timeEntryInfo.numberHoursMonday * 60 + _timeEntryInfo.numberMinutesMonday;
                            _timeEntryInfo.numberHoursMonday = _numberMinutes / 60;
                            _timeEntryInfo.numberMinutesMonday = _numberMinutes % 60;
                        }
                        _timeEntryInfo.orgClientIDMonday.Add(long.Parse(_dataRow["orgClientID"].ToString()));
                        _timeEntryInfo.organizationsMonday = _dataRow["OrganizationName"].ToString();
                        _timeEntryInfo.timeEntryIDMonday = long.Parse(_dataRow["timeEntryID"].ToString());
                        _timeEntryInfo.dateForTimeEntryMonday = _dateForTimeEntry.ToString("MM/dd/yyyy");
                        _timeEntryInfo.timeEntryDayIDMonday = long.Parse(_dataRow["timeEntryDayID"].ToString());
                        break;
                    case DayOfWeek.Tuesday:
                        // if there is already time value from a previous task entry, disable the control so  no update can be done
                        if (_timeEntryInfo.numberHoursTuesday > 0 || _timeEntryInfo.numberMinutesTuesday > 0)
                        {
                            _timeEntryInfo.disableTaskUpdateTuesday = true;
                        }
                        _timeEntryInfo.numberHoursTuesday += _hours;
                        _timeEntryInfo.numberMinutesTuesday += _minutes;
                        if (_timeEntryInfo.numberMinutesTuesday > 59)
                        {
                            _numberMinutes = _timeEntryInfo.numberHoursTuesday * 60 + _timeEntryInfo.numberMinutesTuesday;
                            _timeEntryInfo.numberHoursTuesday = _numberMinutes / 60;
                            _timeEntryInfo.numberMinutesTuesday = _numberMinutes % 60;
                        }
                        _timeEntryInfo.orgClientIDTuesday.Add(long.Parse(_dataRow["orgClientID"].ToString()));
                        _timeEntryInfo.organizationsTuesday = _dataRow["OrganizationName"].ToString();
                        _timeEntryInfo.timeEntryIDTuesday = long.Parse(_dataRow["timeEntryID"].ToString());
                        _timeEntryInfo.dateForTimeEntryTuesday = _dateForTimeEntry.ToString("MM/dd/yyyy");
                        _timeEntryInfo.timeEntryDayIDTuesday = long.Parse(_dataRow["timeEntryDayID"].ToString());
                        break;
                    case DayOfWeek.Wednesday:
                        // if there is already time value from a previous task entry, disable the control so  no update can be done
                        if (_timeEntryInfo.numberHoursWednesday > 0 || _timeEntryInfo.numberMinutesWednesday > 0)
                        {
                            _timeEntryInfo.disableTaskUpdateWednesday = true;
                        }
                        _timeEntryInfo.numberHoursWednesday += _hours;
                        _timeEntryInfo.numberMinutesWednesday += _minutes;
                        if (_timeEntryInfo.numberMinutesWednesday > 59)
                        {
                            _numberMinutes = _timeEntryInfo.numberHoursWednesday * 60 + _timeEntryInfo.numberMinutesWednesday;
                            _timeEntryInfo.numberHoursWednesday = _numberMinutes / 60;
                            _timeEntryInfo.numberMinutesWednesday = _numberMinutes % 60;
                        }
                        _timeEntryInfo.orgClientIDWednesday.Add(long.Parse(_dataRow["orgClientID"].ToString()));
                        _timeEntryInfo.timeEntryIDWednesday = long.Parse(_dataRow["timeEntryID"].ToString());
                        _timeEntryInfo.dateForTimeEntryWednesday = _dateForTimeEntry.ToString("MM/dd/yyyy");
                        _timeEntryInfo.timeEntryDayIDWednesday = long.Parse(_dataRow["timeEntryDayID"].ToString());
                        break;
                    case DayOfWeek.Thursday:
                        // if there is already time value from a previous task entry, disable the control so  no update can be done
                        if (_timeEntryInfo.numberHoursThursday > 0 || _timeEntryInfo.numberMinutesThursday > 0)
                        {
                            _timeEntryInfo.disableTaskUpdateThursday = true;
                        }
                        _timeEntryInfo.numberHoursThursday += _hours;
                        _timeEntryInfo.numberMinutesThursday += _minutes;
                        if (_timeEntryInfo.numberMinutesThursday > 59)
                        {
                            _numberMinutes = _timeEntryInfo.numberHoursThursday * 60 + _timeEntryInfo.numberMinutesThursday;
                            _timeEntryInfo.numberHoursThursday = _numberMinutes / 60;
                            _timeEntryInfo.numberMinutesThursday = _numberMinutes % 60;
                        }
                        _timeEntryInfo.orgClientIDThursday.Add(long.Parse(_dataRow["orgClientID"].ToString()));
                        _timeEntryInfo.organizationsThursday = _dataRow["OrganizationName"].ToString();
                        _timeEntryInfo.timeEntryIDThursday = long.Parse(_dataRow["timeEntryID"].ToString());
                        _timeEntryInfo.dateForTimeEntryThursday = _dateForTimeEntry.ToString("MM/dd/yyyy");
                        _timeEntryInfo.timeEntryDayIDThursday = long.Parse(_dataRow["timeEntryDayID"].ToString());
                        break;
                    case DayOfWeek.Friday:
                        // if there is already time value from a previous task entry, disable the control so  no update can be done
                        if (_timeEntryInfo.numberHoursFriday > 0 || _timeEntryInfo.numberMinutesFriday > 0)
                        {
                            _timeEntryInfo.disableTaskUpdateFriday = true;
                        }
                        _timeEntryInfo.numberHoursFriday += _hours;
                        _timeEntryInfo.numberMinutesFriday += _minutes;
                        if (_timeEntryInfo.numberMinutesFriday > 59)
                        {
                            _numberMinutes = _timeEntryInfo.numberHoursFriday * 60 + _timeEntryInfo.numberMinutesFriday;
                            _timeEntryInfo.numberHoursFriday = _numberMinutes / 60;
                            _timeEntryInfo.numberMinutesFriday = _numberMinutes % 60;
                        }
                        _timeEntryInfo.orgClientIDFriday.Add(long.Parse(_dataRow["orgClientID"].ToString()));
                        _timeEntryInfo.organizationsFriday = _dataRow["OrganizationName"].ToString();
                        _timeEntryInfo.timeEntryIDFriday = long.Parse(_dataRow["timeEntryID"].ToString());
                        _timeEntryInfo.dateForTimeEntryFriday = _dateForTimeEntry.ToString("MM/dd/yyyy");
                        _timeEntryInfo.timeEntryDayIDFriday = long.Parse(_dataRow["timeEntryDayID"].ToString());
                        break;
                    case DayOfWeek.Saturday:
                        // if there is already time value from a previous task entry, disable the control so  no update can be done
                        if (_timeEntryInfo.numberHoursSaturday > 0 || _timeEntryInfo.numberMinutesSaturday > 0)
                        {
                            _timeEntryInfo.disableTaskUpdateSaturday = true;
                        }
                        _timeEntryInfo.numberHoursSaturday += _hours;
                        _timeEntryInfo.numberMinutesSaturday += _minutes;
                        if (_timeEntryInfo.numberMinutesSaturday > 59)
                        {
                            _numberMinutes = _timeEntryInfo.numberHoursSaturday * 60 + _timeEntryInfo.numberMinutesSaturday;
                            _timeEntryInfo.numberHoursSaturday = _numberMinutes / 60;
                            _timeEntryInfo.numberMinutesSaturday = _numberMinutes % 60;
                        }
                        _timeEntryInfo.orgClientIDSaturday.Add(long.Parse(_dataRow["orgClientID"].ToString()));
                        _timeEntryInfo.organizationsSaturday = _dataRow["OrganizationName"].ToString();
                        _timeEntryInfo.timeEntryIDSaturday = long.Parse(_dataRow["timeEntryID"].ToString());
                        _timeEntryInfo.dateForTimeEntrySaturday = _dateForTimeEntry.ToString("MM/dd/yyyy");
                        _timeEntryInfo.timeEntryDayIDSaturday = long.Parse(_dataRow["timeEntryDayID"].ToString());
                        break;
                }

                if (_exists)
                {
                    _listEmployeeTimeInfo[_index] = _timeEntryInfo;
                }
                else
                {
                    _listEmployeeTimeInfo.Add(_timeEntryInfo);
                }
            }

            repeaterTaskTemplateControl.DataSource = _listEmployeeTimeInfo;
            repeaterTaskTemplateControl.DataBind();

            if (repeaterTaskTemplateControl.Items.Count > 0)
            {
                List<ClientInfo> _listClients = GetFavoriteClientList(con);
                PopulateTaskTemplateTimeEntries(con, _listEmployeeTimeInfo, _listClients);
            }
            GetScheduleInfoForDateAndSetLabels(dateToProcess);

            SetListToBuildTableFrom(_firstDayOfTheWeek, (_lastDayOfTheWeek - _firstDayOfTheWeek).Days);
            FillInRepeater();
        }

        private void SetClientListBox(ListBox listBoxClients, DropDownList dropDownListClients, List<long> listOrgClientID, bool canHaveMultipleClients)
        {
            if (listOrgClientID?.Count > 0)
            {
                if (listOrgClientID.Count > 1 && !canHaveMultipleClients)
                {
                    // This will occur when we have two entries for the same task
                    // on the same day,  but each record has a different Client
                    // Reset the listBoxClients.SelectionMode to  multiple for this situation
                    listBoxClients.Visible = false;
                    dropDownListClients.Visible = true;
                }

                ListItem _item = null;
                foreach (long orgClientId in listOrgClientID)
                {
                    if (listBoxClients.Visible)
                    {
                        _item = listBoxClients.Items.FindByValue(orgClientId.ToString());
                        if (_item != null)
                        {
                            _item.Selected = true;
                        }
                    }
                    else
                    {
                        _item = dropDownListClients.Items.FindByValue(orgClientId.ToString());
                        if (_item != null)
                        {
                            _item.Selected = true;
                        }
                        break;
                    }
                }
            }

        }
        private void PopulateTaskTemplateTimeEntries(SqlConnection con, List<TimeEntryInfo> listEmployeeTimeInfo, List<ClientInfo> listClients)
        {
            HiddenField HiddenFieldCanHaveMultipleClients = null;

            ListBox listBoxClientsSunday = null;
            ListBox listBoxClientsMonday = null;
            ListBox listBoxClientsTuesday = null;
            ListBox listBoxClientsWednesday = null;
            ListBox listBoxClientsThursday = null;
            ListBox listBoxClientsFriday = null;
            ListBox listBoxClientsSaturday = null;

            DropDownList DropDownListClientsSunday = null;
            DropDownList DropDownListClientsMonday = null;
            DropDownList DropDownListClientsTuesday = null;
            DropDownList DropDownListClientsWednesday = null;
            DropDownList DropDownListClientsThursday = null;
            DropDownList DropDownListClientsFriday = null;
            DropDownList DropDownListClientsSaturday = null;

            int _index = 0;
            bool _canHaveMultipleClients = false;
            TimeEntryInfo _timeEntryInfo = null;

            HiddenField HiddenFieldDateForTimeEntrySunday;
            HiddenField HiddenFieldDateForTimeEntryMonday;
            HiddenField HiddenFieldDateForTimeEntryTuesday;
            HiddenField HiddenFieldDateForTimeEntryWednesday;
            HiddenField HiddenFieldDateForTimeEntryThursday;
            HiddenField HiddenFieldDateForTimeEntryFriday;
            HiddenField HiddenFieldDateForTimeEntrySaturday;

            if (string.IsNullOrEmpty(HiddenFieldSelectedDate.Value))
            {
                HiddenFieldSelectedDate.Value = DateTime.Today.ToString("MM/dd/yyyy");
            }
            DateTime _selectedDate = DateTime.Parse(HiddenFieldSelectedDate.Value);
            DateTime _startDate = GetFirstDayOfTheWeek(_selectedDate);
            DateTime _endDate = GetLastDayOfTheWeek(_selectedDate);

            HiddenField HiddenFieldTaskId;
            HiddenField HiddenFieldHolidayId;
            Label labelSundayDisabledMessage;
            Label labelMondayDisabledMessage;
            Label labelTuesdayDisabledMessage;
            Label labelWednesdayDisabledMessage;
            Label labelThursdayDisabledMessage;
            Label labelFridayDisabledMessage;
            Label labelSaturdayDisabledMessage;

            System.Web.UI.WebControls.TextBox textBoxHoursSunday;
            System.Web.UI.WebControls.TextBox textBoxHoursMonday;
            System.Web.UI.WebControls.TextBox textBoxHoursTuesday;
            System.Web.UI.WebControls.TextBox textBoxHoursWednesday;
            System.Web.UI.WebControls.TextBox textBoxHoursThursday;
            System.Web.UI.WebControls.TextBox textBoxHoursFriday;
            System.Web.UI.WebControls.TextBox textBoxHoursSaturday;

            System.Web.UI.WebControls.TextBox textBoxMinutesSunday;
            System.Web.UI.WebControls.TextBox textBoxMinutesMonday;
            System.Web.UI.WebControls.TextBox textBoxMinutesTuesday;
            System.Web.UI.WebControls.TextBox textBoxMinutesWednesday;
            System.Web.UI.WebControls.TextBox textBoxMinutesThursday;
            System.Web.UI.WebControls.TextBox textBoxMinutesFriday;
            System.Web.UI.WebControls.TextBox textBoxMinutesSaturday;

            long _numberOfMinutes = 0;

            foreach (RepeaterItem rptItem in repeaterTaskTemplateControl.Items)
            {
                HiddenFieldDateForTimeEntrySunday = (HiddenField)rptItem.FindControl("HiddenFieldDateForTimeEntrySunday");
                HiddenFieldDateForTimeEntryMonday = (HiddenField)rptItem.FindControl("HiddenFieldDateForTimeEntryMonday");
                HiddenFieldDateForTimeEntryTuesday = (HiddenField)rptItem.FindControl("HiddenFieldDateForTimeEntryTuesday");
                HiddenFieldDateForTimeEntryWednesday = (HiddenField)rptItem.FindControl("HiddenFieldDateForTimeEntryWednesday");
                HiddenFieldDateForTimeEntryThursday = (HiddenField)rptItem.FindControl("HiddenFieldDateForTimeEntryThursday");
                HiddenFieldDateForTimeEntryFriday = (HiddenField)rptItem.FindControl("HiddenFieldDateForTimeEntryFriday");
                HiddenFieldDateForTimeEntrySaturday = (HiddenField)rptItem.FindControl("HiddenFieldDateForTimeEntrySaturday");

                DropDownListClientsSunday = (DropDownList)rptItem.FindControl("DropDownListClientsSunday");
                DropDownListClientsMonday = (DropDownList)rptItem.FindControl("DropDownListClientsMonday");
                DropDownListClientsTuesday = (DropDownList)rptItem.FindControl("DropDownListClientsTuesday");
                DropDownListClientsWednesday = (DropDownList)rptItem.FindControl("DropDownListClientsWednesday");
                DropDownListClientsThursday = (DropDownList)rptItem.FindControl("DropDownListClientsThursday");
                DropDownListClientsFriday = (DropDownList)rptItem.FindControl("DropDownListClientsFriday");
                DropDownListClientsSaturday = (DropDownList)rptItem.FindControl("DropDownListClientsSaturday");

                listBoxClientsSunday = (ListBox)rptItem.FindControl("listBoxClientsSunday");
                listBoxClientsMonday = (ListBox)rptItem.FindControl("listBoxClientsMonday");
                listBoxClientsTuesday = (ListBox)rptItem.FindControl("listBoxClientsTuesday");
                listBoxClientsWednesday = (ListBox)rptItem.FindControl("listBoxClientsWednesday");
                listBoxClientsThursday = (ListBox)rptItem.FindControl("listBoxClientsThursday");
                listBoxClientsFriday = (ListBox)rptItem.FindControl("listBoxClientsFriday");
                listBoxClientsSaturday = (ListBox)rptItem.FindControl("listBoxClientsSaturday");

                labelSundayDisabledMessage = (Label)rptItem.FindControl("labelSundayDisabledMessage");
                labelMondayDisabledMessage = (Label)rptItem.FindControl("labelMondayDisabledMessage");
                labelTuesdayDisabledMessage = (Label)rptItem.FindControl("labelTuesdayDisabledMessage");
                labelWednesdayDisabledMessage = (Label)rptItem.FindControl("labelWednesdayDisabledMessage");
                labelThursdayDisabledMessage = (Label)rptItem.FindControl("labelThursdayDisabledMessage");
                labelFridayDisabledMessage = (Label)rptItem.FindControl("labelFridayDisabledMessage");
                labelSaturdayDisabledMessage = (Label)rptItem.FindControl("labelSaturdayDisabledMessage");

                HiddenFieldTaskId = (HiddenField)rptItem.FindControl("HiddenFieldTaskId");
                HiddenFieldHolidayId = (HiddenField)rptItem.FindControl("HiddenFieldHolidayId");

                textBoxHoursSunday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxHoursSunday");
                textBoxHoursMonday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxHoursMonday");
                textBoxHoursTuesday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxHoursTuesday");
                textBoxHoursWednesday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxHoursWednesday");
                textBoxHoursThursday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxHoursThursday");
                textBoxHoursFriday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxHoursFriday");
                textBoxHoursSaturday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxHoursSaturday");

                textBoxMinutesSunday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxMinutesSunday");
                textBoxMinutesMonday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxMinutesMonday");
                textBoxMinutesTuesday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxMinutesTuesday");
                textBoxMinutesWednesday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxMinutesWednesday");
                textBoxMinutesThursday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxMinutesThursday");
                textBoxMinutesFriday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxMinutesFriday");
                textBoxMinutesSaturday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxMinutesSaturday");

                _numberOfMinutes += GetTotalMinutesForRow(textBoxHoursSunday, textBoxMinutesSunday,
                    textBoxHoursMonday, textBoxMinutesMonday,
                    textBoxHoursTuesday, textBoxMinutesTuesday,
                    textBoxHoursWednesday, textBoxMinutesWednesday,
                    textBoxHoursThursday, textBoxMinutesThursday,
                    textBoxHoursFriday, textBoxMinutesFriday,
                    textBoxHoursSaturday, textBoxMinutesSaturday);
                // If field is empty set to dates for the week
                if (string.IsNullOrEmpty(HiddenFieldDateForTimeEntrySunday.Value))
                {
                    HiddenFieldDateForTimeEntrySunday.Value = _startDate.ToString("MM/dd/yyyy");
                }

                if (string.IsNullOrEmpty(HiddenFieldDateForTimeEntryMonday.Value))
                {
                    HiddenFieldDateForTimeEntryMonday.Value = _startDate.AddDays(1).ToString("MM/dd/yyyy");
                }

                if (string.IsNullOrEmpty(HiddenFieldDateForTimeEntryTuesday.Value))
                {
                    HiddenFieldDateForTimeEntryTuesday.Value = _startDate.AddDays(2).ToString("MM/dd/yyyy");
                }

                if (string.IsNullOrEmpty(HiddenFieldDateForTimeEntryWednesday.Value))
                {
                    HiddenFieldDateForTimeEntryWednesday.Value = _startDate.AddDays(3).ToString("MM/dd/yyyy");
                }

                if (string.IsNullOrEmpty(HiddenFieldDateForTimeEntryThursday.Value))
                {
                    HiddenFieldDateForTimeEntryThursday.Value = _startDate.AddDays(4).ToString("MM/dd/yyyy");
                }

                if (string.IsNullOrEmpty(HiddenFieldDateForTimeEntryFriday.Value))
                {
                    HiddenFieldDateForTimeEntryFriday.Value = _startDate.AddDays(5).ToString("MM/dd/yyyy");
                }

                if (string.IsNullOrEmpty(HiddenFieldDateForTimeEntrySaturday.Value))
                {
                    HiddenFieldDateForTimeEntrySaturday.Value = _startDate.AddDays(6).ToString("MM/dd/yyyy");
                }

                _timeEntryInfo = listEmployeeTimeInfo[_index];
                HiddenFieldCanHaveMultipleClients = (HiddenField)rptItem.FindControl("HiddenFieldCanHaveMultipleClients");

                if ((_canHaveMultipleClients = bool.Parse(HiddenFieldCanHaveMultipleClients.Value)))
                {
                    // Make sure all clients is not present
                    if (listClients.Exists(element => element.id == 0))
                    {
                        listClients.RemoveAt(0);
                    }
                }
                else
                {
                    // Make sure all clients is present
                    if (!listClients.Exists(element => element.id == 0))
                    {
                        ClientInfo _item = new ClientInfo();
                        _item.id = 0;
                        _item.name = "All Clients";
                        listClients.Insert(0, _item);
                    }
                }

                SetClientDropDownListAndListBox(DropDownListClientsSunday, listBoxClientsSunday, labelSundayDisabledMessage, _timeEntryInfo.disableTaskUpdateSunday, listClients, rptItem, _timeEntryInfo.orgClientIDSunday, _timeEntryInfo.CanHaveMultipleClients, textBoxHoursSunday, textBoxMinutesSunday, HiddenFieldHolidayId);
                SetClientDropDownListAndListBox(DropDownListClientsMonday, listBoxClientsMonday, labelMondayDisabledMessage, _timeEntryInfo.disableTaskUpdateMonday, listClients, rptItem, _timeEntryInfo.orgClientIDMonday, _timeEntryInfo.CanHaveMultipleClients, textBoxHoursMonday, textBoxMinutesMonday, HiddenFieldHolidayId);
                SetClientDropDownListAndListBox(DropDownListClientsTuesday, listBoxClientsTuesday, labelTuesdayDisabledMessage, _timeEntryInfo.disableTaskUpdateTuesday, listClients, rptItem, _timeEntryInfo.orgClientIDTuesday, _timeEntryInfo.CanHaveMultipleClients, textBoxHoursTuesday, textBoxMinutesTuesday, HiddenFieldHolidayId);
                SetClientDropDownListAndListBox(DropDownListClientsWednesday, listBoxClientsWednesday, labelWednesdayDisabledMessage, _timeEntryInfo.disableTaskUpdateWednesday, listClients, rptItem, _timeEntryInfo.orgClientIDWednesday, _timeEntryInfo.CanHaveMultipleClients, textBoxHoursWednesday, textBoxMinutesWednesday, HiddenFieldHolidayId);
                SetClientDropDownListAndListBox(DropDownListClientsThursday, listBoxClientsThursday, labelThursdayDisabledMessage, _timeEntryInfo.disableTaskUpdateThursday, listClients, rptItem, _timeEntryInfo.orgClientIDThursday, _timeEntryInfo.CanHaveMultipleClients, textBoxHoursThursday, textBoxMinutesThursday, HiddenFieldHolidayId);
                SetClientDropDownListAndListBox(DropDownListClientsFriday, listBoxClientsFriday, labelFridayDisabledMessage, _timeEntryInfo.disableTaskUpdateFriday, listClients, rptItem, _timeEntryInfo.orgClientIDFriday, _timeEntryInfo.CanHaveMultipleClients, textBoxHoursFriday, textBoxMinutesFriday, HiddenFieldHolidayId);
                SetClientDropDownListAndListBox(DropDownListClientsSaturday, listBoxClientsSaturday, labelSaturdayDisabledMessage, _timeEntryInfo.disableTaskUpdateSaturday, listClients, rptItem, _timeEntryInfo.orgClientIDSaturday, _timeEntryInfo.CanHaveMultipleClients, textBoxHoursSaturday, textBoxMinutesSaturday, HiddenFieldHolidayId);

                ++_index;
            }
            long _hours = _numberOfMinutes / 60;
            long _minutes = _numberOfMinutes % 60;
            double _decimalHours = Math.Round((_numberOfMinutes * 1.0) / 60.0, 2, MidpointRounding.AwayFromZero);

            labelWeeklyHourCount.Text = _numberOfMinutes == 0 ? "No time for the week has been entered" :
                "Entered: " + (_minutes == 0 ? _decimalHours.ToString() + ".00" : _decimalHours.ToString()) + " Hours"
                + "<br/>Hours: " + _hours.ToString() + "<br/>Minutes: " + _minutes.ToString();
        }

        private long GetTotalMinutesForDay(System.Web.UI.WebControls.TextBox textBoxHours, System.Web.UI.WebControls.TextBox textBoxMinutes)
        {
            long _totalMinutes = 0;
            long _minutes = 0;

            if (!string.IsNullOrEmpty(textBoxHours.Text.Trim()))
            {
                long.TryParse(textBoxHours.Text, out _minutes);
                _totalMinutes += _minutes * 60;
            }

            if (!string.IsNullOrEmpty(textBoxMinutes.Text.Trim()))
            {
                long.TryParse(textBoxMinutes.Text, out _minutes);
                _totalMinutes += _minutes;
            }

            return _totalMinutes;
        }
        private long GetTotalMinutesForRow(System.Web.UI.WebControls.TextBox textBoxHoursSunday, System.Web.UI.WebControls.TextBox textBoxMinutesSunday,
                    System.Web.UI.WebControls.TextBox textBoxHoursMonday, System.Web.UI.WebControls.TextBox textBoxMinutesMonday,
                    System.Web.UI.WebControls.TextBox textBoxHoursTuesday, System.Web.UI.WebControls.TextBox textBoxMinutesTuesday,
                    System.Web.UI.WebControls.TextBox textBoxHoursWednesday, System.Web.UI.WebControls.TextBox textBoxMinutesWednesday,
                    System.Web.UI.WebControls.TextBox textBoxHoursThursday, System.Web.UI.WebControls.TextBox textBoxMinutesThursday,
                    System.Web.UI.WebControls.TextBox textBoxHoursFriday, System.Web.UI.WebControls.TextBox textBoxMinutesFriday,
                    System.Web.UI.WebControls.TextBox textBoxHoursSaturday, System.Web.UI.WebControls.TextBox textBoxMinutesSaturday)
        {
            return GetTotalMinutesForDay(textBoxHoursSunday, textBoxMinutesSunday)
                + GetTotalMinutesForDay(textBoxHoursMonday, textBoxMinutesMonday)
                + GetTotalMinutesForDay(textBoxHoursTuesday, textBoxMinutesTuesday)
                + GetTotalMinutesForDay(textBoxHoursWednesday, textBoxMinutesWednesday)
                + GetTotalMinutesForDay(textBoxHoursThursday, textBoxMinutesThursday)
                + GetTotalMinutesForDay(textBoxHoursFriday, textBoxMinutesFriday)
                + GetTotalMinutesForDay(textBoxHoursSaturday, textBoxMinutesSaturday);
        }

        private void SetClientDropDownListAndListBox(DropDownList dropDownListClients, ListBox listBoxClients,
            Label labelDisableMessage, bool disableTaskUpdate, List<ClientInfo> listClients, RepeaterItem rptItem,
            List<long> listClientID, bool canHaveMultipleClients, System.Web.UI.WebControls.TextBox textBoxHours,
            System.Web.UI.WebControls.TextBox textBoxMinutes, HiddenField HiddenFieldHolidayId)
        {
            listBoxClients.DataSource = listClients;
            listBoxClients.DataValueField = "id";
            listBoxClients.DataTextField = "name";
            listBoxClients.DataBind();
            listBoxClients.SelectionMode = ListSelectionMode.Multiple;

            dropDownListClients.DataSource = listClients;
            dropDownListClients.DataValueField = "id";
            dropDownListClients.DataTextField = "name";
            dropDownListClients.DataBind();

            if (canHaveMultipleClients)
            {
                listBoxClients.Visible = true;
                dropDownListClients.Visible = false;
            }
            else
            {
                listBoxClients.Visible = false;
                dropDownListClients.Visible = true;
            }

            if (disableTaskUpdate || bool.Parse(HiddenFieldDisplayStartTime.Value) || bool.Parse(HiddenFieldDisplayStopTime.Value)
                || HiddenFieldHolidayId.Value != "0")
            {
                listBoxClients.Enabled = false;
                dropDownListClients.Enabled = false;
                labelDisableMessage.Visible = true;
                textBoxHours.Enabled = false;
                textBoxMinutes.Enabled = false;
            }
            else
            {
                listBoxClients.Enabled = true;
                dropDownListClients.Enabled = true;
                labelDisableMessage.Visible = false;
                textBoxHours.Enabled = true;
                textBoxMinutes.Enabled = true;
            }

            SetClientListBox(listBoxClients, dropDownListClients, listClientID, canHaveMultipleClients);

        }

        private List<ClientInfo> GetFavoriteClientList(SqlConnection con)
        {
            List<ClientInfo> _listClientInfo = GetClientList(con, "TimeKeeper_TIMESHEET_GetClientFavorites");

            if (_listClientInfo.Count == 0)
            {
                return GetClientList(con, "TimeKeeper_TIMESHEET_GetClient");
            }

            return _listClientInfo;
        }

        private List<ClientInfo> GetClientList(SqlConnection con, string storedProcedureName)
        {
            List<ClientInfo> _listClientInfo = new List<ClientInfo>();

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(storedProcedureName, con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;

            if (storedProcedureName.Contains("Favorites"))
            {
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@EmployeeID", HiddenFieldEmployeeId.Value);
            }

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            if (_dataTable.Rows.Count == 0)
            {
                return _listClientInfo;
            }

            ClientInfo _clientInfo = null;
            foreach (DataRow _dataRow in _dataTable.Rows)
            {
                _clientInfo = new ClientInfo();
                _clientInfo.id = long.Parse(_dataRow["id"].ToString());
                _clientInfo.name = _dataRow["name"].ToString();

                _listClientInfo.Add(_clientInfo);
            }
            return _listClientInfo;
        }
        private void SetEmployeeIDFromQueryStringIfPresent()
        {
            HiddenFieldEmployeeId.Value = string.Empty;

            try
            {
                if (Request.QueryString.ToString().Contains("employeeid"))
                {
                    // Verify a valid long
                    long _employeeID = Convert.ToInt64(Request.QueryString["employeeid"]);
                    HiddenFieldEmployeeId.Value = _employeeID.ToString();
                    DateTime _dateCheck = DateTime.Parse(Request.QueryString["dateforentry"]);
                    _DateForEntry = _dateCheck.ToString("MM/dd/yyyy");
                }
                else
                {
                    if (rd.wu.usr.timeSheetUserInfo == null)
                    {
                        rd.wu.usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(rd.wu.usr.userName);
                    }

                    HiddenFieldEmployeeId.Value = rd.wu.usr.timeSheetUserInfo.employeeid.ToString();
                    _DateForEntry = DateTime.Today.ToString("MM/dd/yyyy");
                }
            }
            catch
            {
                // Ignore error
                _DateForEntry = string.Empty;
                HiddenFieldEmployeeId.Value = string.Empty;
            }
        }

        private void InitializeWeekInfo()
        {
            if (string.IsNullOrEmpty(_DateForEntry))
            {
                DateTime _selectedDate = DateTime.Today;
                HiddenFieldSelectedDate.Value = _selectedDate.ToString("MM/dd/yyyy");
            }
            else
            {
                HiddenFieldSelectedDate.Value = _DateForEntry;
            }

            GetWeekDateRange();
        }

        protected void GetWeekDateRange()
        {
            DateTime _selectedDate = DateTime.Today;

            try
            {
                if (string.IsNullOrEmpty(HiddenFieldSelectedDate.Value))
                {
                    HiddenFieldSelectedDate.Value = _selectedDate.ToString("MM/dd/yyyy");
                }
                else
                {
                    _selectedDate = DateTime.Parse(HiddenFieldSelectedDate.Value);
                }
            }
            catch
            {
                // Ignore exception
                _selectedDate = DateTime.Today;
                HiddenFieldSelectedDate.Value = _selectedDate.ToString("MM/dd/yyyy");
            }
        }

        private void GetStartAndEndDayOfTheWeek(ref DateTime firstDayOfTheWeek, ref DateTime lastDayOfTheWeek, DateTime selectedDate)
        {
            firstDayOfTheWeek = GetFirstDayOfTheWeek(selectedDate);
            lastDayOfTheWeek = GetLastDayOfTheWeek(selectedDate);
        }

        private void FillInRepeater()
        {
            List<TimeEntryDay> _listDays = _TimeEntryWeek.ListOfDays;
            DataTable _dataTable = null;
            TimeSpan _timeSpan;
            int _numberOfMinutes = 0;
            string _url = string.Empty;

            LiteralSunday = (Literal)repeaterTaskTemplateControl.Controls[0].Controls[0].FindControl("LiteralSunday");
            LiteralMonday = (Literal)repeaterTaskTemplateControl.Controls[0].Controls[0].FindControl("LiteralMonday");
            LiteralTuesday = (Literal)repeaterTaskTemplateControl.Controls[0].Controls[0].FindControl("LiteralTuesday");
            LiteralWednesday = (Literal)repeaterTaskTemplateControl.Controls[0].Controls[0].FindControl("LiteralWednesday");
            LiteralThursday = (Literal)repeaterTaskTemplateControl.Controls[0].Controls[0].FindControl("LiteralThursday");
            LiteralFriday = (Literal)repeaterTaskTemplateControl.Controls[0].Controls[0].FindControl("LiteralFriday");
            LiteralSaturday = (Literal)repeaterTaskTemplateControl.Controls[0].Controls[0].FindControl("LiteralSaturday");

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

                if (_numberOfMinutes == 0)
                {
                    _url = MBA.HttpApplication.createLink("WebFormScheduleStopStart.aspx", true) + "&employeeid=" + HiddenFieldEmployeeId.Value + "&scheduledate=" +
                        _timeEntryDay.DateForDay.ToString("MM/dd/yyyy");
                }
                else
                {
                    _url = MBA.HttpApplication.createLink("InsertOrUpdateTimeEntry.aspx", true) + "&employeeid=" + HiddenFieldEmployeeId.Value + "&timentrydate=" + _timeEntryDay.DateForDay.ToString("MM/dd/yyyy");
                }

                switch (_timeEntryDay.DateForDay.DayOfWeek)
                {
                    case DayOfWeek.Sunday:
                        LiteralSunday.Text = @"
                    <p style='font-weight: bold'>
                        SUNDAY<br />
                        Scheduled : " + ((int)(_numberOfMinutes / 60)).ToString() + " Hours " + (_numberOfMinutes % 60).ToString() + @" Minutes<br/>
                        Recorded : " + _timeEntryDay.NumberOfHours.ToString() + " Hours " + _timeEntryDay.NumberOfMintes + @" Minutes<br/>
                        <a style='font-weight: bold; color: blue' href='" + _url + "'>" + _timeEntryDay.DateForDay.ToString("MM/dd/yyyy") + @"</a>
                    </p>";
                        break;
                    case DayOfWeek.Monday:
                        LiteralMonday.Text = @"
                    <p style='font-weight: bold'>
                        MONDAY<br />
                        Scheduled : " + ((int)(_numberOfMinutes / 60)).ToString() + " Hours " + (_numberOfMinutes % 60).ToString() + @" Minutes<br/>
                        Recorded : " + _timeEntryDay.NumberOfHours.ToString() + " Hours " + _timeEntryDay.NumberOfMintes + @" Minutes<br/>
                        <a style='font-weight: bold; color: blue' href='" + _url + "'>" + _timeEntryDay.DateForDay.ToString("MM/dd/yyyy") + @"</a>
                    </p>";
                        break;
                    case DayOfWeek.Tuesday:
                        LiteralTuesday.Text = @"
                    <p style='font-weight: bold'>
                        TUESDAY<br />
                        Scheduled : " + ((int)(_numberOfMinutes / 60)).ToString() + " Hours " + (_numberOfMinutes % 60).ToString() + @" Minutes<br/>
                        Recorded : " + _timeEntryDay.NumberOfHours.ToString() + " Hours " + _timeEntryDay.NumberOfMintes + @" Minutes<br/>
                        <a style='font-weight: bold; color: blue' href='" + _url + "'>" + _timeEntryDay.DateForDay.ToString("MM/dd/yyyy") + @"</a>
                    </p>";
                        break;
                    case DayOfWeek.Wednesday:
                        LiteralWednesday.Text = @"
                    <p style='font-weight: bold'>
                        WEDNESDAY<br />
                        Scheduled : " + ((int)(_numberOfMinutes / 60)).ToString() + " Hours " + (_numberOfMinutes % 60).ToString() + @" Minutes<br/>
                        Recorded : " + _timeEntryDay.NumberOfHours.ToString() + " Hours " + _timeEntryDay.NumberOfMintes + @" Minutes<br/>
                        <a style='font-weight: bold; color: blue' href='" + _url + "'>" + _timeEntryDay.DateForDay.ToString("MM/dd/yyyy") + @"</a>
                    </p>";
                        break;
                    case DayOfWeek.Thursday:
                        LiteralThursday.Text = @"
                    <p style='font-weight: bold'>
                        THURSDAY<br />
                        Scheduled : " + ((int)(_numberOfMinutes / 60)).ToString() + " Hours " + (_numberOfMinutes % 60).ToString() + @" Minutes<br/>
                        Recorded : " + _timeEntryDay.NumberOfHours.ToString() + " Hours " + _timeEntryDay.NumberOfMintes + @" Minutes<br/>
                        <a style='font-weight: bold; color: blue' href='" + _url + "'>" + _timeEntryDay.DateForDay.ToString("MM/dd/yyyy") + @"</a>
                    </p>";
                        break;
                    case DayOfWeek.Friday:
                        LiteralFriday.Text = @"
                    <p style='font-weight: bold'>
                        FRIDAY<br />
                        Scheduled : " + ((int)(_numberOfMinutes / 60)).ToString() + " Hours " + (_numberOfMinutes % 60).ToString() + @" Minutes<br/>
                        Recorded : " + _timeEntryDay.NumberOfHours.ToString() + " Hours " + _timeEntryDay.NumberOfMintes + @" Minutes<br/>
                        <a style='font-weight: bold; color: blue' href='" + _url + "'>" + _timeEntryDay.DateForDay.ToString("MM/dd/yyyy") + @"</a>
                    </p>";
                        break;
                    case DayOfWeek.Saturday:
                        LiteralSaturday.Text = @"
                    <p style='font-weight: bold'>
                        SATURDAY<br />
                        Scheduled : " + ((int)(_numberOfMinutes / 60)).ToString() + " Hours " + (_numberOfMinutes % 60).ToString() + @" Minutes<br/>
                        Recorded : " + _timeEntryDay.NumberOfHours.ToString() + " Hours " + _timeEntryDay.NumberOfMintes + @" Minutes<br/>
                        <a style='font-weight: bold; color: blue' href='" + _url + "'>" + _timeEntryDay.DateForDay.ToString("MM/dd/yyyy") + @"</a>
                    </p>";
                        break;
                }

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
        private void GetTimeEntryHours(DateTime selectedDate)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                // Get tomorrow's date
                DateTime _endDate = selectedDate.Date.AddDays(1);
                List<SqlParameter> _parms = new List<SqlParameter>();

                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetTimeEntriesForEmployeeAndDate", _con);
                _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
                _sqlDataAdapter.SelectCommand.Parameters.Add("@EmployeeId", SqlDbType.BigInt).Value = Convert.ToInt64(HiddenFieldEmployeeId.Value);
                _sqlDataAdapter.SelectCommand.Parameters.Add("@StartDate", SqlDbType.DateTime).Value = selectedDate.Date;

                DataSet _dataSet = new DataSet();
                _sqlDataAdapter.Fill(_dataSet);

                if (_dataSet.Tables[0].Rows.Count == 0)
                {
                    _TimeEntryWeek.SetTimeEntry(selectedDate.Date, 0);
                    return;
                }

                int _numberOfMinutes = 0;
                foreach (DataRow _dataRow in _dataSet.Tables[0].Rows)
                {
                    _numberOfMinutes += (int)_dataRow["numberMinutes"];
                }

                _TimeEntryWeek.SetTimeEntry(selectedDate.Date, _numberOfMinutes);
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
                GetTimeEntryHours(_dayOfWeek);
            }
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

        private void GetScheduleInfoForDateAndSetLabels(DateTime selectedDate)
        {
            // Strip hours and minutes before calling SP
            DateTime _selectedDate = DateTime.Parse(selectedDate.ToString("MM/dd/yyyy"));
            DataTable _dataTable = CallGetScheduleSP(_selectedDate);

            if (_dataTable == null)
            {
                HiddenFieldHoursScheduled.Value = "0";
                HiddenFieldMinutesScheduled.Value = "0";
                return;
            }

            double _numberOfMinutes = 0;
            TimeSpan _timeSpan;
            foreach (DataRow _dataRow in _dataTable.Rows)
            {
                _timeSpan = (DateTime.Parse(_dataRow["stoptime"].ToString()) - DateTime.Parse(_dataRow["starttime"].ToString()));
                _numberOfMinutes += _timeSpan.Hours * 60 + _timeSpan.Minutes;
            }

            HiddenFieldHoursScheduled.Value = ((int)(_numberOfMinutes / 60)).ToString();
            HiddenFieldMinutesScheduled.Value = (_numberOfMinutes % 60).ToString();
        }

        private void PopulateEmployeeDropDownList()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetEmployeeList", _con);
                _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;

                DataTable _dataTable = new DataTable();
                _sqlDataAdapter.Fill(_dataTable);

                DropDownListEmployees.DataSource = _dataTable;
                DropDownListEmployees.DataTextField = "Name";
                DropDownListEmployees.DataValueField = "EmployeeId";
                DropDownListEmployees.DataBind();

                if (DropDownListEmployees.Items.Count > 0)
                {
                    DropDownListEmployees.SelectedValue = HiddenFieldEmployeeId.Value;
                }
                else
                {
                    string _url = MBA.HttpApplication.createLink("home.aspx", true);

                    Response.Redirect(_url, false);
                    return;
                }
            }
        }
        private void EmployeeNameOrPopulateDropDownList()
        {
            if (rd.wu.usr.timeSheetUserInfo == null)
            {
                rd.wu.usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(rd.wu.usr.userName);
            }

            if (rd.wu.usr.timeSheetUserInfo.roleID == 1)
            {
                PanelAdmin.Visible = true;
                PanelRegularEmploeyee.Visible = false;
                PopulateEmployeeDropDownList();
            }
            else
            {
                PanelAdmin.Visible = false;
                PanelRegularEmploeyee.Visible = true;

                GetEmployeeName();
            }
        }
        private void GetEmployeeName()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetPresonInfo", _con);
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
                literalEmployee.Text = _dataRow["FirstName"].ToString() + " " + _dataRow["LastName"].ToString();
            }
        }
        private void GetEmployeeInfo()
        {
            GetWeekDateRange();

            DateTime _selectedDate;

            foreach (TimeEntryDay _day in _TimeEntryWeek.ListOfDays)
            {
                _selectedDate = DateTime.Parse(HiddenFieldSelectedDate.Value);
                if (_day.DateForDay.Date == _selectedDate.Date)
                {
                    HiddenFieldHoursRecorded.Value = (_day.NumberOfHours).ToString();
                    HiddenFieldMinutesRecorded.Value = (_day.NumberOfMintes).ToString();
                    break;
                }
            }

        }

        protected void ButtonPreviousWeek_Click(object sender, EventArgs e)
        {
            DateTime _selectedDate = DateTime.Parse(HiddenFieldSelectedDate.Value);
            _selectedDate = _selectedDate.Date.AddDays(-7);
            HiddenFieldSelectedDate.Value = _selectedDate.ToString("MM/dd/yyyy");

            GetWeekDateRange();
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                PopulateTaskTemplateTimeEntries(_con, _selectedDate);
            }
        }

        protected void ButtonNextWeek_Click(object sender, EventArgs e)
        {
            DateTime _selectedDate = DateTime.Parse(HiddenFieldSelectedDate.Value);
            _selectedDate = _selectedDate.Date.AddDays(+7);
            HiddenFieldSelectedDate.Value = _selectedDate.ToString("MM/dd/yyyy");

            GetWeekDateRange();
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                PopulateTaskTemplateTimeEntries(_con, _selectedDate);
            }
        }

        protected void ButtonSaveTaskInfo_Click(object sender, EventArgs e)
        {
            if (rd.wu.usr.timeSheetUserInfo == null)
            {
                rd.wu.usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(rd.wu.usr.userName);
            }

            if (rd.wu.usr.timeSheetUserInfo.employeeid.ToString() != HiddenFieldEmployeeId.Value)
            {
                ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                    "Cannot modify hours of another employee",
                    "alert('You can only modify your own hours');",
                true);
                SetPageWithEmployeeInfoAndTask();
                return;
            }


            System.Web.UI.WebControls.TextBox textBoxHoursSunday = null;
            System.Web.UI.WebControls.TextBox textBoxMinutesSunday = null;
            HiddenField HiddenFieldTimeEntryIDSunday = null;
            ListBox listBoxClientsSunday = null;
            HiddenField HiddenFieldDateForTimeEntrySunday = null;
            HiddenField HiddenFieldTimeEntryDayIDSunday = null;
            DropDownList DropDownListClientsSunday = null;

            System.Web.UI.WebControls.TextBox textBoxHoursMonday = null;
            System.Web.UI.WebControls.TextBox textBoxMinutesMonday = null;
            HiddenField HiddenFieldTimeEntryIDMonday = null;
            ListBox listBoxClientsMonday = null;
            HiddenField HiddenFieldDateForTimeEntryMonday = null;
            HiddenField HiddenFieldTimeEntryDayIDMonday = null;
            DropDownList DropDownListClientsMonday = null;

            System.Web.UI.WebControls.TextBox textBoxHoursTuesday = null;
            System.Web.UI.WebControls.TextBox textBoxMinutesTuesday = null;
            HiddenField HiddenFieldTimeEntryIDTuesday = null;
            ListBox listBoxClientsTuesday = null;
            HiddenField HiddenFieldDateForTimeEntryTuesday = null;
            HiddenField HiddenFieldTimeEntryDayIDTuesday = null;
            DropDownList DropDownListClientsTuesday = null;

            System.Web.UI.WebControls.TextBox textBoxHoursWednesday = null;
            System.Web.UI.WebControls.TextBox textBoxMinutesWednesday = null;
            HiddenField HiddenFieldTimeEntryIDWednesday = null;
            ListBox listBoxClientsWednesday = null;
            HiddenField HiddenFieldDateForTimeEntryWednesday = null;
            HiddenField HiddenFieldTimeEntryDayIDWednesday = null;
            DropDownList DropDownListClientsWednesday = null;

            System.Web.UI.WebControls.TextBox textBoxHoursThursday = null;
            System.Web.UI.WebControls.TextBox textBoxMinutesThursday = null;
            HiddenField HiddenFieldTimeEntryIDThursday = null;
            ListBox listBoxClientsThursday = null;
            HiddenField HiddenFieldDateForTimeEntryThursday = null;
            HiddenField HiddenFieldTimeEntryDayIDThursday = null;
            DropDownList DropDownListClientsThursday = null;

            System.Web.UI.WebControls.TextBox textBoxHoursFriday = null;
            System.Web.UI.WebControls.TextBox textBoxMinutesFriday = null;
            HiddenField HiddenFieldTimeEntryIDFriday = null;
            ListBox listBoxClientsFriday = null;
            HiddenField HiddenFieldDateForTimeEntryFriday = null;
            HiddenField HiddenFieldTimeEntryDayIDFriday = null;
            DropDownList DropDownListClientsFriday = null;

            System.Web.UI.WebControls.TextBox textBoxHoursSaturday = null;
            System.Web.UI.WebControls.TextBox textBoxMinutesSaturday = null;
            HiddenField HiddenFieldTimeEntryIDSaturday = null;
            ListBox listBoxClientsSaturday = null;
            HiddenField HiddenFieldDateForTimeEntrySaturday = null;
            HiddenField HiddenFieldTimeEntryDayIDSaturday = null;
            DropDownList DropDownListClientsSaturday = null;

            HiddenField HiddenFieldTaskId = null;
            HiddenField HiddenFieldHolidayId = null;
            HiddenField HiddenFieldCanHaveMultipleClients = null;

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                foreach (RepeaterItem rptItem in repeaterTaskTemplateControl.Items)
                {
                    HiddenFieldTaskId = (HiddenField)rptItem.FindControl("HiddenFieldTaskId");
                    HiddenFieldHolidayId = (HiddenField)rptItem.FindControl("HiddenFieldHolidayId");
                    HiddenFieldCanHaveMultipleClients = (HiddenField)rptItem.FindControl("HiddenFieldCanHaveMultipleClients");

                    textBoxHoursSunday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxHoursSunday");
                    textBoxMinutesSunday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxMinutesSunday");
                    HiddenFieldTimeEntryIDSunday = (HiddenField)rptItem.FindControl("HiddenFieldTimeEntryIDSunday");
                    listBoxClientsSunday = (ListBox)rptItem.FindControl("listBoxClientsSunday");
                    HiddenFieldDateForTimeEntrySunday = (HiddenField)rptItem.FindControl("HiddenFieldDateForTimeEntrySunday");
                    HiddenFieldTimeEntryDayIDSunday = (HiddenField)rptItem.FindControl("HiddenFieldTimeEntryDayIDSunday");
                    DropDownListClientsSunday = (DropDownList)rptItem.FindControl("DropDownListClientsSunday");

                    textBoxHoursMonday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxHoursMonday");
                    textBoxMinutesMonday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxMinutesMonday");
                    HiddenFieldTimeEntryIDMonday = (HiddenField)rptItem.FindControl("HiddenFieldTimeEntryIDMonday");
                    listBoxClientsMonday = (ListBox)rptItem.FindControl("listBoxClientsMonday");
                    HiddenFieldDateForTimeEntryMonday = (HiddenField)rptItem.FindControl("HiddenFieldDateForTimeEntryMonday");
                    HiddenFieldTimeEntryDayIDMonday = (HiddenField)rptItem.FindControl("HiddenFieldTimeEntryDayIDMonday");
                    DropDownListClientsMonday = (DropDownList)rptItem.FindControl("DropDownListClientsMonday");

                    textBoxHoursTuesday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxHoursTuesday");
                    textBoxMinutesTuesday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxMinutesTuesday");
                    HiddenFieldTimeEntryIDTuesday = (HiddenField)rptItem.FindControl("HiddenFieldTimeEntryIDTuesday");
                    listBoxClientsTuesday = (ListBox)rptItem.FindControl("listBoxClientsTuesday");
                    HiddenFieldDateForTimeEntryTuesday = (HiddenField)rptItem.FindControl("HiddenFieldDateForTimeEntryTuesday");
                    HiddenFieldTimeEntryDayIDTuesday = (HiddenField)rptItem.FindControl("HiddenFieldTimeEntryDayIDTuesday");
                    DropDownListClientsTuesday = (DropDownList)rptItem.FindControl("DropDownListClientsTuesday");

                    textBoxHoursWednesday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxHoursWednesday");
                    textBoxMinutesWednesday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxMinutesWednesday");
                    HiddenFieldTimeEntryIDWednesday = (HiddenField)rptItem.FindControl("HiddenFieldTimeEntryIDWednesday");
                    listBoxClientsWednesday = (ListBox)rptItem.FindControl("listBoxClientsWednesday");
                    HiddenFieldDateForTimeEntryWednesday = (HiddenField)rptItem.FindControl("HiddenFieldDateForTimeEntryWednesday");
                    HiddenFieldTimeEntryDayIDWednesday = (HiddenField)rptItem.FindControl("HiddenFieldTimeEntryDayIDWednesday");
                    DropDownListClientsWednesday = (DropDownList)rptItem.FindControl("DropDownListClientsWednesday");

                    textBoxHoursThursday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxHoursThursday");
                    textBoxMinutesThursday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxMinutesThursday");
                    HiddenFieldTimeEntryIDThursday = (HiddenField)rptItem.FindControl("HiddenFieldTimeEntryIDThursday");
                    listBoxClientsThursday = (ListBox)rptItem.FindControl("listBoxClientsThursday");
                    HiddenFieldDateForTimeEntryThursday = (HiddenField)rptItem.FindControl("HiddenFieldDateForTimeEntryThursday");
                    HiddenFieldTimeEntryDayIDThursday = (HiddenField)rptItem.FindControl("HiddenFieldTimeEntryDayIDThursday");
                    DropDownListClientsThursday = (DropDownList)rptItem.FindControl("DropDownListClientsThursday");

                    textBoxHoursFriday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxHoursFriday");
                    textBoxMinutesFriday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxMinutesFriday");
                    HiddenFieldTimeEntryIDFriday = (HiddenField)rptItem.FindControl("HiddenFieldTimeEntryIDFriday");
                    listBoxClientsFriday = (ListBox)rptItem.FindControl("listBoxClientsFriday");
                    HiddenFieldDateForTimeEntryFriday = (HiddenField)rptItem.FindControl("HiddenFieldDateForTimeEntryFriday");
                    HiddenFieldTimeEntryDayIDFriday = (HiddenField)rptItem.FindControl("HiddenFieldTimeEntryDayIDFriday");
                    DropDownListClientsFriday = (DropDownList)rptItem.FindControl("DropDownListClientsFriday");

                    textBoxHoursSaturday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxHoursSaturday");
                    textBoxMinutesSaturday = (System.Web.UI.WebControls.TextBox)rptItem.FindControl("textBoxMinutesSaturday");
                    HiddenFieldTimeEntryIDSaturday = (HiddenField)rptItem.FindControl("HiddenFieldTimeEntryIDSaturday");
                    listBoxClientsSaturday = (ListBox)rptItem.FindControl("listBoxClientsSaturday");
                    HiddenFieldDateForTimeEntrySaturday = (HiddenField)rptItem.FindControl("HiddenFieldDateForTimeEntrySaturday");
                    HiddenFieldTimeEntryDayIDSaturday = (HiddenField)rptItem.FindControl("HiddenFieldTimeEntryDayIDSaturday");
                    DropDownListClientsSaturday = (DropDownList)rptItem.FindControl("DropDownListClientsSaturday");

                    if (textBoxHoursSunday.Enabled)
                    {
                        ProcessReportItem(_con, HiddenFieldTaskId, HiddenFieldTimeEntryDayIDSunday, HiddenFieldCanHaveMultipleClients,
                            HiddenFieldDateForTimeEntrySunday,
                            textBoxHoursSunday, textBoxMinutesSunday, HiddenFieldTimeEntryIDSunday, listBoxClientsSunday, DropDownListClientsSunday);
                    }

                    if (textBoxHoursMonday.Enabled)
                    {
                        ProcessReportItem(_con, HiddenFieldTaskId, HiddenFieldTimeEntryDayIDMonday, HiddenFieldCanHaveMultipleClients,
                            HiddenFieldDateForTimeEntryMonday,
                            textBoxHoursMonday, textBoxMinutesMonday, HiddenFieldTimeEntryIDMonday, listBoxClientsMonday, DropDownListClientsMonday);
                    }

                    if (textBoxHoursTuesday.Enabled)
                    {
                        ProcessReportItem(_con, HiddenFieldTaskId, HiddenFieldTimeEntryDayIDTuesday, HiddenFieldCanHaveMultipleClients,
                        HiddenFieldDateForTimeEntryTuesday,
                        textBoxHoursTuesday, textBoxMinutesTuesday, HiddenFieldTimeEntryIDTuesday, listBoxClientsTuesday, DropDownListClientsTuesday);
                    }

                    if (textBoxHoursWednesday.Enabled)
                    {
                        ProcessReportItem(_con, HiddenFieldTaskId, HiddenFieldTimeEntryDayIDWednesday, HiddenFieldCanHaveMultipleClients,
                            HiddenFieldDateForTimeEntryWednesday,
                            textBoxHoursWednesday, textBoxMinutesWednesday, HiddenFieldTimeEntryIDWednesday, listBoxClientsWednesday, DropDownListClientsWednesday);
                    }

                    if (textBoxHoursThursday.Enabled)
                    {
                        ProcessReportItem(_con, HiddenFieldTaskId, HiddenFieldTimeEntryDayIDThursday, HiddenFieldCanHaveMultipleClients,
                            HiddenFieldDateForTimeEntryThursday,
                            textBoxHoursThursday, textBoxMinutesThursday, HiddenFieldTimeEntryIDThursday, listBoxClientsThursday, DropDownListClientsThursday);
                    }

                    if (textBoxHoursFriday.Enabled)
                    {
                        ProcessReportItem(_con, HiddenFieldTaskId, HiddenFieldTimeEntryDayIDFriday, HiddenFieldCanHaveMultipleClients,
                           HiddenFieldDateForTimeEntryFriday,
                           textBoxHoursFriday, textBoxMinutesFriday, HiddenFieldTimeEntryIDFriday, listBoxClientsFriday, DropDownListClientsFriday);
                    }


                    if (textBoxHoursFriday.Enabled)
                    {
                        ProcessReportItem(_con, HiddenFieldTaskId, HiddenFieldTimeEntryDayIDSaturday, HiddenFieldCanHaveMultipleClients,
                           HiddenFieldDateForTimeEntrySaturday,
                           textBoxHoursSaturday, textBoxMinutesSaturday, HiddenFieldTimeEntryIDSaturday, listBoxClientsSaturday, DropDownListClientsSaturday);
                    }
                }
            }

            string _command = "alert('Your changes have been saved');window.location.href = \"" + Request.RawUrl + "\"";
            ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                "Saved",
                _command,
            true);

            //Response.Redirect(Request.RawUrl);
        }

        private void ProcessReportItem(SqlConnection con, HiddenField HiddenFieldTaskId, HiddenField HiddenFieldTimeEntryDayID, HiddenField HiddenFieldCanHaveMultipleClients,
            HiddenField HiddenFieldDateForTimeEntry, System.Web.UI.WebControls.TextBox textBoxHours, System.Web.UI.WebControls.TextBox textBoxMinutes,
            HiddenField HiddenFieldTimeEntryID, ListBox listBox, DropDownList dropDownList)
        {
            long _hours = 0;
            long _minutes = 0;

            long.TryParse(textBoxHours.Text, out _hours);
            long.TryParse(textBoxMinutes.Text, out _minutes);

            // If time values are greater than 0, check if you need to insert or update
            if (_hours > 0 || _minutes > 0)
            {
                if (bool.Parse(HiddenFieldCanHaveMultipleClients.Value))
                {
                    ProcessMultiple(con, HiddenFieldTaskId, HiddenFieldTimeEntryDayID, HiddenFieldCanHaveMultipleClients,
                          HiddenFieldDateForTimeEntry, textBoxHours, textBoxMinutes, HiddenFieldTimeEntryID, listBox);
                }
                else
                {
                    if (HiddenFieldTimeEntryID.Value == "0")
                    {
                        HiddenFieldTimeEntryID.Value = InsertTimeEntry(con, HiddenFieldTaskId, HiddenFieldTimeEntryDayID, HiddenFieldCanHaveMultipleClients,
                          HiddenFieldDateForTimeEntry, textBoxHours.Text, textBoxMinutes.Text, HiddenFieldTimeEntryID, dropDownList.SelectedValue).ToString();
                    }
                    else
                    {
                        UpdateTimeEntry(con, HiddenFieldTimeEntryID, HiddenFieldCanHaveMultipleClients, textBoxHours, textBoxMinutes, dropDownList);
                    }
                }
            }
            else
            {
                if (HiddenFieldTimeEntryID.Value != "0")
                {
                    DeleteTimeEntry(con, HiddenFieldTimeEntryID, HiddenFieldCanHaveMultipleClients,
                        HiddenFieldTimeEntryDayID, HiddenFieldTaskId);
                }
            }
        }

        private void ProcessMultiple(SqlConnection con, HiddenField HiddenFieldTaskId, HiddenField HiddenFieldTimeEntryDayID,
            HiddenField HiddenFieldCanHaveMultipleClients, HiddenField HiddenFieldDateForTimeEntry,
            System.Web.UI.WebControls.TextBox textBoxHours,
            System.Web.UI.WebControls.TextBox textBoxMinutes, HiddenField HiddenFieldTimeEntryID, ListBox listBox)
        {
            DeleteTimeEntry(con, HiddenFieldTimeEntryDayID, HiddenFieldCanHaveMultipleClients, HiddenFieldTimeEntryDayID,
                HiddenFieldTaskId);

            long _hours = 0;
            long _minutes = 0;

            long.TryParse(textBoxHours.Text, out _hours);
            long.TryParse(textBoxMinutes.Text, out _minutes);

            if (_hours == 0 && _minutes == 0)
            {
                return;
            }

            long _numberOfMinutes = _hours * 60 + _minutes;
            int[] _selectedIndexClients = listBox.GetSelectedIndices();
            int _length = _selectedIndexClients.Length;

            for (int _counter = 0; _counter < _length; ++_counter)
            {
                if (_counter == 0)
                {
                    HiddenFieldTimeEntryID.Value = InsertTimeEntry(con, HiddenFieldTaskId, HiddenFieldTimeEntryDayID,
                      HiddenFieldCanHaveMultipleClients, HiddenFieldDateForTimeEntry, textBoxHours.Text, textBoxMinutes.Text,
                      HiddenFieldTimeEntryID, listBox.Items[_counter].Value).ToString();
                }
                else
                {
                    // For multiple,  set to 0 after iniital insert
                    InsertTimeEntry(con, HiddenFieldTaskId, HiddenFieldTimeEntryDayID,
                                          HiddenFieldCanHaveMultipleClients, HiddenFieldDateForTimeEntry, "0", "0",
                                          HiddenFieldTimeEntryID, listBox.Items[_counter].Value);
                }
            }

        }
        private void DeleteTimeEntry(SqlConnection con, HiddenField HiddenFieldTimeEntryID, HiddenField HiddenFieldCanHaveMultipleClients,
            HiddenField HiddenFileTimeEntryDayID, HiddenField HiddenFieldTaskID)
        {
            if (bool.Parse(HiddenFieldCanHaveMultipleClients.Value))
            {
                SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_TIMESHEET_DeleteTimeEntryForMultipleClient", con);
                _sqlCommand.CommandType = CommandType.StoredProcedure;
                _sqlCommand.Parameters.AddWithValue("@TimeEntryDayID", HiddenFileTimeEntryDayID.Value);
                _sqlCommand.Parameters.AddWithValue("@TimeEntrytaskID", HiddenFieldTaskID.Value);

                _sqlCommand.ExecuteNonQuery();
            }
            else
            {
                SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_TIMESHEET_DeleteTimeEntry", con);
                _sqlCommand.CommandType = CommandType.StoredProcedure;
                _sqlCommand.Parameters.AddWithValue("@Id", HiddenFieldTimeEntryID.Value);

                _sqlCommand.ExecuteNonQuery();
            }
        }
        private long InsertTimeEntry(SqlConnection con, HiddenField HiddenFieldTaskId, HiddenField HiddenFieldTimeEntryDayID,
            HiddenField HiddenFieldCanHaveMultipleClients, HiddenField HiddenFieldDateForTimeEntry,
            string hours, string minutes, HiddenField HiddenFieldTimeEntryID, string orgClientID)
        {
            long _hours = 0;
            long _minutes = 0;

            long.TryParse(hours, out _hours);
            long.TryParse(minutes, out _minutes);

            long _numberOfMinutes = _hours * 60 + _minutes;

            if (HiddenFieldTimeEntryDayID.Value == "0")
            {
                HiddenFieldTimeEntryDayID.Value = InsertTimeEntryDay(HiddenFieldDateForTimeEntry).ToString();
            }

            SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_TIMESHEET_CreateTimeEntry", con);
            _sqlCommand.CommandType = CommandType.StoredProcedure;
            _sqlCommand.Parameters.AddWithValue("@timeEntryDayID", HiddenFieldTimeEntryDayID.Value);
            _sqlCommand.Parameters.AddWithValue("@timeOfTask", HiddenFieldDateForTimeEntry.Value);
            _sqlCommand.Parameters.AddWithValue("@numberMinutes", _numberOfMinutes);
            _sqlCommand.Parameters.AddWithValue("@timeEntrytaskID", HiddenFieldTaskId.Value);

            if (orgClientID == "0" || string.IsNullOrEmpty(orgClientID))
            {
                SqlParameter _parameter = new SqlParameter("@orgClientID", SqlDbType.BigInt);
                _parameter.Value = DBNull.Value;
                _sqlCommand.Parameters.Add(_parameter);
            }
            else
            {
                _sqlCommand.Parameters.AddWithValue("@orgClientID", orgClientID);
            }

            _sqlCommand.Parameters.AddWithValue("@note", DBNull.Value);
            _sqlCommand.Parameters.AddWithValue("@dateEntryCreated", DateTime.Now.ToString());
            _sqlCommand.Parameters.AddWithValue("@IsProjectManagement", DBNull.Value);
            _sqlCommand.Parameters.AddWithValue("@IsHelpDesk", DBNull.Value);
            _sqlCommand.Parameters.AddWithValue("@ITPM_ID", DBNull.Value);
            _sqlCommand.Parameters.AddWithValue("@HD_ROW_ID", DBNull.Value);
            _sqlCommand.Parameters.AddWithValue("@Description", DBNull.Value);
            _sqlCommand.Parameters.AddWithValue("@FileNameReference", DBNull.Value);
            _sqlCommand.Parameters.AddWithValue("@FileComments", DBNull.Value);
            _sqlCommand.Parameters.AddWithValue("@FileComplete", false);
            _sqlCommand.Parameters.AddWithValue("@HasMultipleClients", bool.Parse(HiddenFieldCanHaveMultipleClients.Value));
            _sqlCommand.Parameters.AddWithValue("@StartEntryDateTime", DBNull.Value);
            _sqlCommand.Parameters.AddWithValue("@EndEntryDateTime", DBNull.Value);

            _sqlCommand.Parameters.Add("@Id", SqlDbType.BigInt);
            _sqlCommand.Parameters["@Id"].Direction = ParameterDirection.Output;

            _sqlCommand.Parameters.AddWithValue("@e_id", DBNull.Value);

            _sqlCommand.ExecuteNonQuery();

            return long.Parse(_sqlCommand.Parameters["@Id"].Value.ToString());
        }
        private long InsertTimeEntryDay(HiddenField HiddenFieldDateForTimeEntry)
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                con.Open();
                SqlCommand cmd = new SqlCommand("TimeKeeper_TIMESHEET_CreateTimeEntryDay", con);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@EmployeeId", Convert.ToInt64(HiddenFieldEmployeeId.Value));
                cmd.Parameters.AddWithValue("@dateForTimeEntry", DateTime.Parse(HiddenFieldDateForTimeEntry.Value).Date);
                cmd.Parameters.Add("@Id", SqlDbType.BigInt);
                cmd.Parameters["@Id"].Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();
                return long.Parse(cmd.Parameters["@Id"].Value.ToString());
            }
        }

        private void UpdateTimeEntry(SqlConnection con, HiddenField HiddenFieldTimeEntryID, HiddenField HiddenFieldCanHaveMultipleClients,
            System.Web.UI.WebControls.TextBox textBoxHours, System.Web.UI.WebControls.TextBox textBoxMinutes, DropDownList dropDownList)
        {
            long _hours = 0;
            long _minutes = 0;

            long.TryParse(textBoxHours.Text, out _hours);
            long.TryParse(textBoxMinutes.Text, out _minutes);

            long _numberOfMinutes = _hours * 60 + _minutes;

            SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_TIMESHEET_UpdateTimeEntryTaslEmplate", con);
            _sqlCommand.CommandType = CommandType.StoredProcedure;
            _sqlCommand.Parameters.AddWithValue("@Id", HiddenFieldTimeEntryID.Value);
            _sqlCommand.Parameters.AddWithValue("@numberMinutes", _numberOfMinutes);

            if (dropDownList.SelectedValue == "0" || dropDownList.SelectedIndex == -1)
            {
                SqlParameter _parameter = new SqlParameter("@orgClientID", SqlDbType.BigInt);
                _parameter.Value = DBNull.Value;
                _sqlCommand.Parameters.Add(_parameter);
            }
            else
            {
                _sqlCommand.Parameters.AddWithValue("@orgClientID", dropDownList.SelectedValue);
            }

            _sqlCommand.ExecuteNonQuery();
        }
        protected void DropDownListEmployees_SelectedIndexChanged(object sender, EventArgs e)
        {
            LabelAdminEmployee.Visible = false;

            if (rd.wu.usr.timeSheetUserInfo == null)
            {
                rd.wu.usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(rd.wu.usr.userName);
            }

            HiddenFieldEmployeeId.Value = DropDownListEmployees.SelectedValue;
            SetPageWithEmployeeInfoAndTask();

            if (rd.wu.usr.timeSheetUserInfo.employeeid.ToString() != HiddenFieldEmployeeId.Value)
            {
                LabelAdminEmployee.Visible = true;
            }
        }

        protected void CheckBoxVerifyHours_CheckedChanged(object sender, EventArgs e)
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                con.Open();
                SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_TIMESHEET_UpdateEmployeeTimeVerfication", con);
                _sqlCommand.CommandType = CommandType.StoredProcedure;

                _sqlCommand.Parameters.AddWithValue("@Id", HiddenFieldVerifyId.Value);
                _sqlCommand.Parameters.AddWithValue("@isVerified", true);
                _sqlCommand.Parameters.AddWithValue("@employeeID", HiddenFieldEmployeeId.Value);
                _sqlCommand.Parameters.AddWithValue("@lastDayOfSchedule", HiddenFieldLastDayOfSchedule.Value);
                _sqlCommand.Parameters.AddWithValue("@dateVerified", DateTime.Today.ToString("MM/dd/yyyy"));
                _sqlCommand.Parameters.AddWithValue("@comments", HiddenFieldComments.Value);

                _sqlCommand.Parameters.AddWithValue("@WhoVerifiedHours", rd.wu.usr.id);

                _sqlCommand.ExecuteNonQuery();


            }
            this.gotoNewURL(homeLink);
        }
    }
}
