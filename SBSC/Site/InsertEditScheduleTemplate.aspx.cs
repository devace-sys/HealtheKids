using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Spedmon
{
     public partial class InsertEditScheduleTemplate : WebUI
     {
        class ClientInfo
        {
             public long id { get; set; }
             public string name { get; set; }
        }
        class AutoTaskStartStopTime
        {
            public string id { get; set; }
            public string startTime { get; set; }
            public string stopTime { get; set; }
        }

        public InsertEditScheduleTemplate()
               : base("timeentry", WebUI.CreatePageSubTitle("Auto Populate Schedule", "Create or modify schedule templates"),
                    "", "", Constants.ROLE_SBS_ALL)
          { 
          }
        protected void Page_Load(object sender, EventArgs e)
        {
                if (rd.wu.usr.timeSheetUserInfo == null)
                {
                    rd.wu.usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(rd.wu.usr.userName);
                }
                // If employeeid querystring is passed in make sure it matches it matches end user employeeid
                if (Request.QueryString["employeeid"] != null)
                {
                    // only allow if the employeeid of end user matches the querystring value
                    long _employeeid = 0;
                    long.TryParse(Request.QueryString["employeeid"].ToString(), out _employeeid);
                    // If person is not an admin,  only allow them to modify template for themselves
                    if (rd.wu.usr.timeSheetUserInfo.roleID != 1 && rd.wu.usr.timeSheetUserInfo.roleID != 3)
                    {
                        if (rd.wu.usr.timeSheetUserInfo.employeeid != _employeeid)
                        {
                            string _url = MBA.HttpApplication.createLink("TimeEntryScheduleAdmin.aspx", true);
                            Response.Redirect(_url, false);
                            return;
                        }
                    }
                    HiddenFieldEmployeeID.Value = _employeeid.ToString();
                    HiddenFieldAutoPopulateTaskTemplateName.Value = rd.wu.usr.timeSheetUserInfo.lastName + ", " + rd.wu.usr.timeSheetUserInfo.firstName + "(" + _employeeid.ToString() + ")";
                }
                else
                {
                    string _url = MBA.HttpApplication.createLink("TimeEntryScheduleAdmin.aspx", true);
                    Response.Redirect(_url, false);
                    return;
                }

                if (!IsPostBack)
                {
                    HiddenFieldTemplateID.Value = Request.QueryString["scheduleTemplateId"];
                    HiddenFieldStopStartTaskId.Value = Request.QueryString["taskid"];
                    HiddenFieldTaskStartStop.Value = Request.QueryString["startstop"];
                    HiddenFieldTaskStartStopDay.Value = Request.QueryString["day"];

                    if (HiddenFieldTemplateID.Value == "0")
                    {
                        PanelWeekDetails.Visible = false;
                        ButtonAdd.Visible = true;
                        ButtonUpdate.Visible = false;
                    }
                    else
                    {
                        PanelWeekDetails.Visible = true;
                        ButtonAdd.Visible = false;
                        ButtonUpdate.Visible = true;
                        GetScheduleDaysInfo();
                    }
                }
          }

          private void GetScheduleDaysInfo()
          {
               LiteralSundayDetail.Text = "No time recorded<br/>for this day";
               LiteralMondayDetail.Text = "No time recorded<br/>for this day";
               LiteralTuesdayDetail.Text = "No time recorded<br/>for this day";
               LiteralWednesdayDetail.Text = "No time recorded<br/>for this day";
               LiteralThursdayDetail.Text = "No time recorded<br/>for this day";
               LiteralFridayDetail.Text = "No time recorded<br/>for this day";
               LiteralSaturdayDetail.Text = "No time recorded<br/>for this day";
               
               HiddenFieldSundayID.Value = "0";
               HiddenFieldMondayID.Value = "0";
               HiddenFieldTuesdayID.Value = "0";
               HiddenFieldWednesdayID.Value = "0";
               HiddenFieldThursdayID.Value = "0";
               HiddenFieldFridayID.Value = "0";
               HiddenFieldSaturdayID.Value = "0";

               using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
               {
                    _con.Open();

                    SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetAutoScheduleInfo", _con);
                    _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
                    _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", HiddenFieldTemplateID.Value);

                    DataTable _dataTable = new DataTable();
                    _sqlDataAdapter.Fill(_dataTable);

                    if (_dataTable.Rows.Count > 0)
                    {
                        DataRow _dataRow = _dataTable.Rows[0];
                        ProcessRecords(_dataTable);

                        long _autoPopulateTaskTemplateId = long.Parse(_dataRow["AutoPopulateTaskTemplateId"].ToString());
                        HiddenFieldAutoPopulateTaskTemplateId.Value = _dataRow["AutoPopulateTaskTemplateId"].ToString();

                        if (!string.IsNullOrEmpty(HiddenFieldEmployeeID.Value))
                        {
                            PopulateTaskRepeater(_con, _autoPopulateTaskTemplateId);
                        }
                    }
               }
          }

        private void PopulateTaskRepeater(SqlConnection con, long autoPopulateTaskTemplateId)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHET_GetEmployeeTaskFavorites", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;

            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", HiddenFieldEmployeeID.Value);

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            if (_dataTable.Rows.Count == 0)
            {
                LabelWarningMessage.Visible = true;
                return;
            }

            repeaterTaskTemplateControl.DataSource = _dataTable;
            repeaterTaskTemplateControl.DataBind();

            // Set repeater with existing template values if it exist
            if (autoPopulateTaskTemplateId == -1)
            {
                SetUpClientListBox(con);
            }
            else
            { 
                SetUpRepeaterWithUserChoices(con, autoPopulateTaskTemplateId);
            }
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
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@EmployeeID", HiddenFieldEmployeeID.Value);
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
        private void SetUpClientListBox(SqlConnection con)
        {
            List<ClientInfo> listClients = GetFavoriteClientList(con);
            ListBox listBoxClients = null;
            HiddenField HiddenFieldTaskId = null;
            HiddenField HiddenFieldCanHaveMultipleClients = null;
            Panel panelHoursMinutesSunday = null;
            Panel panelStartStopSunday = null;
            Panel panelHoursMinutesMonday = null;
            Panel panelStartStopMonday = null;
            Panel panelHoursMinutesTuesday = null;
            Panel panelStartStopTuesday = null;
            Panel panelHoursMinutesWednesday = null;
            Panel panelStartStopWednesday = null;
            Panel panelHoursMinutesThursday = null;
            Panel panelStartStopThursday = null;
            Panel panelHoursMinutesFriday = null;
            Panel panelStartStopFriday = null;
            Panel panelHoursMinutesSaturday = null;
            Panel panelStartStopSaturday = null;
            HiddenField HiddenFieldSpecifyStartStopTime = null;

            CheckBox checkBoxAllClients = null;

            bool specifyStartStopTime = false;

            foreach (RepeaterItem rptItem in repeaterTaskTemplateControl.Items)
            {
                checkBoxAllClients = (CheckBox)rptItem.FindControl("checkBoxAllClients");
                HiddenFieldSpecifyStartStopTime = (HiddenField)rptItem.FindControl("HiddenFieldSpecifyStartStopTime");
                specifyStartStopTime = bool.Parse(HiddenFieldSpecifyStartStopTime.Value);

                listBoxClients = (ListBox)rptItem.FindControl("listBoxClients");
                HiddenFieldTaskId = (HiddenField)rptItem.FindControl("HiddenFieldTaskId");
                HiddenFieldCanHaveMultipleClients = (HiddenField)rptItem.FindControl("HiddenFieldCanHaveMultipleClients");

                panelHoursMinutesSunday = (Panel)rptItem.FindControl("panelHoursMinutesSunday");
                panelStartStopSunday = (Panel)rptItem.FindControl("panelStartStopSunday");
                panelHoursMinutesSunday.Visible = !specifyStartStopTime;
                panelStartStopSunday.Visible = specifyStartStopTime;

                panelHoursMinutesMonday = (Panel)rptItem.FindControl("panelHoursMinutesMonday");
                panelStartStopMonday = (Panel)rptItem.FindControl("panelStartStopMonday");
                panelHoursMinutesMonday.Visible = !specifyStartStopTime;
                panelStartStopMonday.Visible = specifyStartStopTime;

                panelHoursMinutesTuesday = (Panel)rptItem.FindControl("panelHoursMinutesTuesday");
                panelStartStopTuesday = (Panel)rptItem.FindControl("panelStartStopTuesday");
                panelHoursMinutesTuesday.Visible = !specifyStartStopTime;
                panelStartStopTuesday.Visible = specifyStartStopTime;

                panelHoursMinutesWednesday = (Panel)rptItem.FindControl("panelHoursMinutesWednesday");
                panelStartStopWednesday = (Panel)rptItem.FindControl("panelStartStopWednesday");
                panelHoursMinutesWednesday.Visible = !specifyStartStopTime;
                panelStartStopWednesday.Visible = specifyStartStopTime;

                panelHoursMinutesThursday = (Panel)rptItem.FindControl("panelHoursMinutesThursday");
                panelStartStopThursday = (Panel)rptItem.FindControl("panelStartStopThursday");
                panelHoursMinutesThursday.Visible = !specifyStartStopTime;
                panelStartStopThursday.Visible = specifyStartStopTime;

                panelHoursMinutesFriday = (Panel)rptItem.FindControl("panelHoursMinutesFriday");
                panelStartStopFriday = (Panel)rptItem.FindControl("panelStartStopFriday");
                panelHoursMinutesFriday.Visible = !specifyStartStopTime;
                panelStartStopFriday.Visible = specifyStartStopTime;

                panelHoursMinutesSaturday = (Panel)rptItem.FindControl("panelHoursMinutesSaturday");
                panelStartStopSaturday = (Panel)rptItem.FindControl("panelStartStopSaturday");
                panelHoursMinutesSaturday.Visible = !specifyStartStopTime;
                panelStartStopSaturday.Visible = specifyStartStopTime;

                listBoxClients.Items.Clear();
                listBoxClients.DataValueField = "id";
                listBoxClients.DataTextField = "name";
                listBoxClients.DataSource = listClients;
                listBoxClients.DataBind();

                if (bool.Parse(HiddenFieldCanHaveMultipleClients.Value))
                {
                    checkBoxAllClients.Visible = true;
                    listBoxClients.SelectionMode = ListSelectionMode.Multiple;
                }
                else
                {
                    checkBoxAllClients.Visible = false;
                    listBoxClients.SelectionMode = ListSelectionMode.Single;

                    ListItem _item = new ListItem();
                    _item.Value = "0";
                    _item.Text = "All Clients";
                    listBoxClients.Items.Insert(0, _item);
                    listBoxClients.SelectedValue = "0";
                }
            }
        }
        private void SetUpRepeaterWithUserChoices(SqlConnection con, long autoPopulateTaskTemplateId)
        {
            List<ClientInfo> listClients = GetFavoriteClientList(con);
            HiddenField HiddenFieldTaskId = null;
            HiddenField HiddenFieldCanHaveMultipleClients = null;
            Label labelTaskName = null;
            ListBox listBoxClients = null;

            string _errMsg = string.Empty;
            LabelProblem.Text = string.Empty;
            Panel panelHoursMinutesSunday = null;
            Panel panelStartStopSunday = null;
            Panel panelHoursMinutesMonday = null;
            Panel panelStartStopMonday = null;
            Panel panelHoursMinutesTuesday = null;
            Panel panelStartStopTuesday = null;
            Panel panelHoursMinutesWednesday = null;
            Panel panelStartStopWednesday = null;
            Panel panelHoursMinutesThursday = null;
            Panel panelStartStopThursday = null;
            Panel panelHoursMinutesFriday = null;
            Panel panelStartStopFriday = null;
            Panel panelHoursMinutesSaturday = null;
            Panel panelStartStopSaturday = null;
            HiddenField HiddenFieldSpecifyStartStopTime = null;
            HiddenField HiddenFieldAutoPopulateTaskDetailsId = null;
            CheckBox checkBoxAllClients = null;

            bool specifyStartStopTime = false;

            foreach (RepeaterItem rptItem in repeaterTaskTemplateControl.Items)
            {
                checkBoxAllClients = (CheckBox)rptItem.FindControl("checkBoxAllClients");
                HiddenFieldSpecifyStartStopTime = (HiddenField)rptItem.FindControl("HiddenFieldSpecifyStartStopTime");
                specifyStartStopTime = bool.Parse(HiddenFieldSpecifyStartStopTime.Value);

                HiddenFieldTaskId = (HiddenField)rptItem.FindControl("HiddenFieldTaskId");
                HiddenFieldCanHaveMultipleClients = (HiddenField)rptItem.FindControl("HiddenFieldCanHaveMultipleClients");
                listBoxClients = (ListBox)rptItem.FindControl("listBoxClients");

                HiddenFieldAutoPopulateTaskDetailsId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateTaskDetailsId");

                panelHoursMinutesSunday = (Panel)rptItem.FindControl("panelHoursMinutesSunday");
                panelStartStopSunday = (Panel)rptItem.FindControl("panelStartStopSunday");
                panelHoursMinutesSunday.Visible = !specifyStartStopTime;
                panelStartStopSunday.Visible = specifyStartStopTime;

                panelHoursMinutesMonday = (Panel)rptItem.FindControl("panelHoursMinutesMonday");
                panelStartStopMonday = (Panel)rptItem.FindControl("panelStartStopMonday");
                panelHoursMinutesMonday.Visible = !specifyStartStopTime;
                panelStartStopMonday.Visible = specifyStartStopTime;

                panelHoursMinutesTuesday = (Panel)rptItem.FindControl("panelHoursMinutesTuesday");
                panelStartStopTuesday = (Panel)rptItem.FindControl("panelStartStopTuesday");
                panelHoursMinutesTuesday.Visible = !specifyStartStopTime;
                panelStartStopTuesday.Visible = specifyStartStopTime;

                panelHoursMinutesWednesday = (Panel)rptItem.FindControl("panelHoursMinutesWednesday");
                panelStartStopWednesday = (Panel)rptItem.FindControl("panelStartStopWednesday");
                panelHoursMinutesWednesday.Visible = !specifyStartStopTime;
                panelStartStopWednesday.Visible = specifyStartStopTime;

                panelHoursMinutesThursday = (Panel)rptItem.FindControl("panelHoursMinutesThursday");
                panelStartStopThursday = (Panel)rptItem.FindControl("panelStartStopThursday");
                panelHoursMinutesThursday.Visible = !specifyStartStopTime;
                panelStartStopThursday.Visible = specifyStartStopTime;

                panelHoursMinutesFriday = (Panel)rptItem.FindControl("panelHoursMinutesFriday");
                panelStartStopFriday = (Panel)rptItem.FindControl("panelStartStopFriday");
                panelHoursMinutesFriday.Visible = !specifyStartStopTime;
                panelStartStopFriday.Visible = specifyStartStopTime;

                panelHoursMinutesSaturday = (Panel)rptItem.FindControl("panelHoursMinutesSaturday");
                panelStartStopSaturday = (Panel)rptItem.FindControl("panelStartStopSaturday");
                panelHoursMinutesSaturday.Visible = !specifyStartStopTime;
                panelStartStopSaturday.Visible = specifyStartStopTime;

                listBoxClients.Items.Clear();
                listBoxClients.DataValueField = "id";
                listBoxClients.DataTextField = "name";
                listBoxClients.DataSource = listClients;
                listBoxClients.DataBind();

                labelTaskName = (Label)rptItem.FindControl("labelTaskName");

                if (GetAutoTaskDetailsForTask(con, HiddenFieldAutoPopulateTaskDetailsId, autoPopulateTaskTemplateId, HiddenFieldTaskId.Value, listBoxClients, checkBoxAllClients, bool.Parse(HiddenFieldCanHaveMultipleClients.Value)) > 0)
                {
                    if (specifyStartStopTime)
                    {
                        GetUserSelectedStopStartTimes(con, HiddenFieldAutoPopulateTaskDetailsId, rptItem);
                    }
                    else
                    {
                        GetUserSelectedTaskHoursAndMinutes(con, HiddenFieldAutoPopulateTaskDetailsId, rptItem);
                    }
                }
            }
        }



        private void PopulateStartStopTask(RepeaterItem rptItem)
        {
            ListBox listBoxStartStopSunday = null;
            ListBox listBoxStartStopMonday = null;
            ListBox listBoxStartStopTuesday = null;
            ListBox listBoxStartStopWednesday = null;
            ListBox listBoxStartStopThursday = null;
            ListBox listBoxStartStopFriday = null;
            ListBox listBoxStartStopSaturday = null;

            switch (HiddenFieldTaskStartStopDay.Value)
            {
                case "sunday":
                    listBoxStartStopSunday = (ListBox)rptItem.FindControl("listBoxStartStopSunday");
                    PopulateStartStopListBox(listBoxStartStopSunday);
                    break;
                case "monday":
                    listBoxStartStopMonday = (ListBox)rptItem.FindControl("listBoxStartStopMonday");
                    PopulateStartStopListBox(listBoxStartStopMonday);
                    break;
                case "tuesday":
                    listBoxStartStopTuesday = (ListBox)rptItem.FindControl("listBoxStartStopTuesday");
                    PopulateStartStopListBox(listBoxStartStopTuesday);
                    break;
                case "wednesday":
                    listBoxStartStopWednesday = (ListBox)rptItem.FindControl("listBoxStartStopWednesday");
                    PopulateStartStopListBox(listBoxStartStopWednesday);
                    break;
                case "thursday":
                    listBoxStartStopThursday = (ListBox)rptItem.FindControl("listBoxStartStopThursday");
                    PopulateStartStopListBox(listBoxStartStopThursday);
                    break;
                case "friday":
                    listBoxStartStopFriday = (ListBox)rptItem.FindControl("listBoxStartStopFriday");
                    PopulateStartStopListBox(listBoxStartStopFriday);
                    break;
                case "saturday":
                    listBoxStartStopSaturday = (ListBox)rptItem.FindControl("listBoxStartStopSaturday");
                    PopulateStartStopListBox(listBoxStartStopSaturday);
                    break;
            }
        }
        private void PopulateStartStopListBox(ListBox listBox)
        {
            listBox.Items.Clear();
            string [] _records = HiddenFieldTaskStartStop.Value.Split('|');
            int _length = _records.Length;
            string[] _times;
            ListItem _listItem = null;

            for(int _counter=0; _counter < _length; _counter++)
            {
                _times = _records[_counter].Split('-');
                if (_times.Length != 3)
                {
                    continue;
                }
                _listItem = new ListItem();
                _listItem.Value = _times[0];
                _listItem.Text = _times[1] + " to " + _times[2];
                listBox.Items.Add(_listItem);
            }

        }
        private void PopulateDayDetails(SqlConnection con,DataRow dataRow, RepeaterItem rptItem, int dayId, HiddenField HiddenFieldAutoPopulateTaskDaysId,
            TextBox textBoxHours,
            TextBox textBoxMinutes)
        {
            int _numberOfMinutes = int.Parse(dataRow["numberOfMinutes"].ToString());

            textBoxHours.Text = (_numberOfMinutes / 60).ToString();
            textBoxMinutes.Text = (_numberOfMinutes % 60).ToString();

        }
        private void RemoveFromDBUnreferencedId(SqlConnection con, HiddenField HiddenFieldAutoPopulateTaskDetailsId, ListBox listBoxStartStop, short dayId)
        {
            DataTable _dataTable = GetAutoPopulateTaskDaysStartStopTimeByDay(con, HiddenFieldAutoPopulateTaskDetailsId, dayId);

            if (_dataTable.Rows.Count == 0)
            {
                return;
            }

            int _autoPouplateTaskDaysStartStopTimeId = 0;
            bool _found = false;
            int _listItemValue = 0;
            foreach(DataRow _dataRow in _dataTable.Rows)
            {
                _autoPouplateTaskDaysStartStopTimeId = int.Parse(_dataRow["id"].ToString());
                _found = false;
                foreach(ListItem item in listBoxStartStop.Items)
                {
                    int.TryParse(item.Value, out _listItemValue);

                    if (_autoPouplateTaskDaysStartStopTimeId == _listItemValue)
                    {
                        _found = true;
                        break;
                    }
                }
                if (!_found)
                {
                    SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_AUTO_DeleteAutoPopulateTaskDaysStartStopTime", con);
                    _sqlCommand.CommandType = CommandType.StoredProcedure;

                    _sqlCommand.Parameters.AddWithValue("@Id", _autoPouplateTaskDaysStartStopTimeId);

                    _sqlCommand.ExecuteNonQuery();
                }
            }
        }
        private void GetUserSelectedStopStartTimes(SqlConnection con,
                                    HiddenField HiddenFieldAutoPopulateTaskDetailsId,
                                    RepeaterItem rptItem)
        {
            DataTable _dataTable = GetAutoPopulateTaskDaysStartStopTime(con, HiddenFieldAutoPopulateTaskDetailsId);

            if (_dataTable.Rows.Count == 0)
            {
                return;
            }

            HiddenField HiddenFieldAutoPopulateSundayTaskDaysId = null;
            HiddenField HiddenFieldAutoPopulateMondayTaskDaysId = null;
            HiddenField HiddenFieldAutoPopulateTuesdayTaskDaysId = null;
            HiddenField HiddenFieldAutoPopulateWednesdayTaskDaysId = null;
            HiddenField HiddenFieldAutoPopulateThursdayTaskDaysId = null;
            HiddenField HiddenFieldAutoPopulateFridayTaskDaysId = null;
            HiddenField HiddenFieldAutoPopulateSaturdayTaskDaysId = null;

            ListBox listBoxStartStopSunday = null;
            ListBox listBoxStartStopMonday = null;
            ListBox listBoxStartStopTuesday = null;
            ListBox listBoxStartStopWednesday = null;
            ListBox listBoxStartStopThursday = null;
            ListBox listBoxStartStopFriday = null;
            ListBox listBoxStartStopSaturday = null;

            int _dayid = 0;
            foreach(DataRow _dataRow in _dataTable.Rows)
            {
                _dayid = int.Parse(_dataRow["dayid"].ToString());
                switch(_dayid)
                {
                    case 0:
                        if (HiddenFieldAutoPopulateSundayTaskDaysId == null)
                        {
                            HiddenFieldAutoPopulateSundayTaskDaysId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateSundayTaskDaysId");
                            HiddenFieldAutoPopulateSundayTaskDaysId.Value = _dataRow["autoPopulateTaskDaysId"].ToString();
                        }
                        if (listBoxStartStopSunday == null)
                        {
                            listBoxStartStopSunday = (ListBox)rptItem.FindControl("listBoxStartStopSunday");
                            listBoxStartStopSunday.Items.Clear();
                        }

                        PopulateStartStopListBox(rptItem, listBoxStartStopSunday, _dataRow, _dayid);
                        break;
                    case 1:
                        if (HiddenFieldAutoPopulateMondayTaskDaysId == null)
                        {
                            HiddenFieldAutoPopulateMondayTaskDaysId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateMondayTaskDaysId");
                            HiddenFieldAutoPopulateMondayTaskDaysId.Value = _dataRow["autoPopulateTaskDaysId"].ToString();
                        }
                        if (listBoxStartStopMonday == null)
                        {
                            listBoxStartStopMonday = (ListBox)rptItem.FindControl("listBoxStartStopMonday");
                            listBoxStartStopMonday.Items.Clear();
                        }

                        PopulateStartStopListBox(rptItem, listBoxStartStopMonday, _dataRow, _dayid);
                        break;
                    case 2:
                        if (HiddenFieldAutoPopulateTuesdayTaskDaysId == null)
                        {
                            HiddenFieldAutoPopulateTuesdayTaskDaysId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateTuesdayTaskDaysId");
                            HiddenFieldAutoPopulateTuesdayTaskDaysId.Value = _dataRow["autoPopulateTaskDaysId"].ToString();

                        }
                        if (listBoxStartStopTuesday == null)
                        {
                            listBoxStartStopTuesday = (ListBox)rptItem.FindControl("listBoxStartStopTuesday");
                            listBoxStartStopTuesday.Items.Clear();
                        }

                        PopulateStartStopListBox(rptItem, listBoxStartStopTuesday, _dataRow, _dayid);
                        break;
                    case 3:
                        if (HiddenFieldAutoPopulateWednesdayTaskDaysId == null)
                        {
                            HiddenFieldAutoPopulateWednesdayTaskDaysId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateWednesdayTaskDaysId");
                            HiddenFieldAutoPopulateWednesdayTaskDaysId.Value = _dataRow["autoPopulateTaskDaysId"].ToString();

                        }
                        if (listBoxStartStopWednesday == null)
                        {
                            listBoxStartStopWednesday = (ListBox)rptItem.FindControl("listBoxStartStopWednesday");
                            listBoxStartStopWednesday.Items.Clear();
                        }

                        PopulateStartStopListBox(rptItem, listBoxStartStopWednesday, _dataRow, _dayid);
                        break;
                    case 4:
                        if (HiddenFieldAutoPopulateThursdayTaskDaysId == null)
                        {
                            HiddenFieldAutoPopulateThursdayTaskDaysId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateThursdayTaskDaysId");
                            HiddenFieldAutoPopulateThursdayTaskDaysId.Value = _dataRow["autoPopulateTaskDaysId"].ToString();
                        }
                        if (listBoxStartStopThursday == null)
                        {
                            listBoxStartStopThursday = (ListBox)rptItem.FindControl("listBoxStartStopThursday");
                            listBoxStartStopThursday.Items.Clear();
                        }

                        PopulateStartStopListBox(rptItem, listBoxStartStopThursday, _dataRow, _dayid);
                        break;
                    case 5:
                        if (HiddenFieldAutoPopulateFridayTaskDaysId == null)
                        {
                            HiddenFieldAutoPopulateFridayTaskDaysId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateFridayTaskDaysId");
                            HiddenFieldAutoPopulateFridayTaskDaysId.Value = _dataRow["autoPopulateTaskDaysId"].ToString();
                        }
                        if (listBoxStartStopFriday == null)
                        {
                            listBoxStartStopFriday = (ListBox)rptItem.FindControl("listBoxStartStopFriday");
                            listBoxStartStopFriday.Items.Clear();
                        }


                        PopulateStartStopListBox(rptItem, listBoxStartStopFriday, _dataRow, _dayid);
                        break;
                    case 6:
                        if (HiddenFieldAutoPopulateSaturdayTaskDaysId == null)
                        {
                            HiddenFieldAutoPopulateSaturdayTaskDaysId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateSaturdayTaskDaysId");
                            HiddenFieldAutoPopulateSaturdayTaskDaysId.Value = _dataRow["autoPopulateTaskDaysId"].ToString();
                        }
                        if (listBoxStartStopSaturday == null)
                        {
                            listBoxStartStopSaturday = (ListBox)rptItem.FindControl("listBoxStartStopSaturday");
                            listBoxStartStopSaturday.Items.Clear();
                        }


                        PopulateStartStopListBox(rptItem, listBoxStartStopSaturday, _dataRow, _dayid);
                        break;
                }
            }
        }
        private void PopulateStartStopListBox(RepeaterItem rptItem, ListBox listBoxStartStop, DataRow dataRow, int dayId)
        {
            ListItem _item = null;
            _item = new ListItem();
            _item.Value = dataRow["id"].ToString();
            _item.Text = dataRow["starttime"].ToString() + " to " + dataRow["stoptime"].ToString();
            listBoxStartStop.Items.Add(_item);
        }
        private void GetUserSelectedTaskHoursAndMinutes(SqlConnection con, 
                                            HiddenField HiddenFieldAutoPopulateTaskDetailsId,
                                            RepeaterItem rptItem)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetAutoPopulateTaskDays", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;

            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@autoPopulateTaskDetailsId", HiddenFieldAutoPopulateTaskDetailsId.Value);

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            if (_dataTable.Rows.Count == 0)
            {
                return;
            }

            TextBox textBoxHoursSunday = null;
            TextBox textBoxHoursMonday = null;
            TextBox textBoxHoursTuesday = null;
            TextBox textBoxHoursWednesday = null;
            TextBox textBoxHoursThursday = null;
            TextBox textBoxHoursFriday = null;
            TextBox textBoxHoursSaturday = null;
            TextBox textBoxMinutesSunday = null;
            TextBox textBoxMinutesMonday = null;
            TextBox textBoxMinutesTuesday = null;
            TextBox textBoxMinutesWednesday = null;
            TextBox textBoxMinutesThursday = null;
            TextBox textBoxMinutesFriday = null;
            TextBox textBoxMinutesSaturday = null;

            HiddenField HiddenFieldAutoPopulateSundayTaskDaysId = null;
            HiddenField HiddenFieldAutoPopulateMondayTaskDaysId = null;
            HiddenField HiddenFieldAutoPopulateTuesdayTaskDaysId = null;
            HiddenField HiddenFieldAutoPopulateWednesdayTaskDaysId = null;
            HiddenField HiddenFieldAutoPopulateThursdayTaskDaysId = null;
            HiddenField HiddenFieldAutoPopulateFridayTaskDaysId = null;
            HiddenField HiddenFieldAutoPopulateSaturdayTaskDaysId = null;

            int _dayId = 0;

            foreach(DataRow _dataRow in _dataTable.Rows)
            {
                _dayId = int.Parse(_dataRow["dayid"].ToString());
                switch (_dayId)
                {
                    case 0:
                        HiddenFieldAutoPopulateSundayTaskDaysId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateSundayTaskDaysId");
                        HiddenFieldAutoPopulateSundayTaskDaysId.Value = _dataRow["id"].ToString();
                        textBoxHoursSunday = (TextBox)rptItem.FindControl("textBoxHoursSunday");
                        textBoxMinutesSunday = (TextBox)rptItem.FindControl("textBoxMinutesSunday");
                        PopulateDayDetails(con, _dataRow, rptItem, _dayId, HiddenFieldAutoPopulateSundayTaskDaysId, 
                            textBoxHoursSunday, textBoxMinutesSunday);
                        break;
                    case 1:
                        HiddenFieldAutoPopulateMondayTaskDaysId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateMondayTaskDaysId");
                        HiddenFieldAutoPopulateMondayTaskDaysId.Value = _dataRow["id"].ToString();
                        textBoxHoursMonday = (TextBox)rptItem.FindControl("textBoxHoursMonday");
                        textBoxMinutesMonday = (TextBox)rptItem.FindControl("textBoxMinutesMonday");
                        PopulateDayDetails(con, _dataRow, rptItem, _dayId, HiddenFieldAutoPopulateMondayTaskDaysId, 
                            textBoxHoursMonday, textBoxMinutesMonday);
                        break;
                    case 2:
                        HiddenFieldAutoPopulateTuesdayTaskDaysId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateTuesdayTaskDaysId");
                        HiddenFieldAutoPopulateTuesdayTaskDaysId.Value = _dataRow["id"].ToString();
                        textBoxHoursTuesday = (TextBox)rptItem.FindControl("textBoxHoursTuesday");
                        textBoxMinutesTuesday = (TextBox)rptItem.FindControl("textBoxMinutesTuesday");
                        PopulateDayDetails(con, _dataRow, rptItem, _dayId, HiddenFieldAutoPopulateTuesdayTaskDaysId,
                            textBoxHoursTuesday, textBoxMinutesTuesday);
                        break;
                    case 3:
                        HiddenFieldAutoPopulateWednesdayTaskDaysId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateWednesdayTaskDaysId");
                        HiddenFieldAutoPopulateWednesdayTaskDaysId.Value = _dataRow["id"].ToString();
                        textBoxHoursWednesday = (TextBox)rptItem.FindControl("textBoxHoursWednesday");
                        textBoxMinutesWednesday = (TextBox)rptItem.FindControl("textBoxMinutesWednesday");
                        PopulateDayDetails(con, _dataRow, rptItem, _dayId, HiddenFieldAutoPopulateWednesdayTaskDaysId,
                            textBoxHoursWednesday, textBoxMinutesWednesday);
                        break;
                    case 4:
                        HiddenFieldAutoPopulateThursdayTaskDaysId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateThursdayTaskDaysId");
                        HiddenFieldAutoPopulateThursdayTaskDaysId.Value = _dataRow["id"].ToString();
                        textBoxHoursThursday = (TextBox)rptItem.FindControl("textBoxHoursThursday");
                        textBoxMinutesThursday = (TextBox)rptItem.FindControl("textBoxMinutesThursday");
                        PopulateDayDetails(con, _dataRow, rptItem, _dayId, HiddenFieldAutoPopulateThursdayTaskDaysId,
                            textBoxHoursThursday, textBoxMinutesThursday);
                        break;
                    case 5:
                        HiddenFieldAutoPopulateFridayTaskDaysId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateFridayTaskDaysId");
                        HiddenFieldAutoPopulateFridayTaskDaysId.Value = _dataRow["id"].ToString();
                        textBoxHoursFriday = (TextBox)rptItem.FindControl("textBoxHoursFriday");
                        textBoxMinutesFriday = (TextBox)rptItem.FindControl("textBoxMinutesFriday");
                        PopulateDayDetails(con, _dataRow, rptItem, _dayId, HiddenFieldAutoPopulateFridayTaskDaysId,
                            textBoxHoursFriday, textBoxMinutesFriday);
                        break;
                    case 6:
                        HiddenFieldAutoPopulateSaturdayTaskDaysId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateSaturdayTaskDaysId");
                        HiddenFieldAutoPopulateSaturdayTaskDaysId.Value = _dataRow["id"].ToString();
                        textBoxHoursSaturday = (TextBox)rptItem.FindControl("textBoxHoursSaturday");
                        textBoxMinutesSaturday = (TextBox)rptItem.FindControl("textBoxMinutesSaturday");
                        PopulateDayDetails(con, _dataRow, rptItem, _dayId, HiddenFieldAutoPopulateSaturdayTaskDaysId,
                            textBoxHoursSaturday, textBoxMinutesSaturday);
                        break;
                }
            }
        }
        private long GetAutoTaskDetailsForTask(SqlConnection con, HiddenField HiddenFieldAutoPopulateTaskDetailsId, long autoPopulateTaskTemplateId, 
            string timeentrytaskid, ListBox listBoxClients, CheckBox checkBoxAllClients, bool canHaveMultipleClients)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetAutoPopulateTaskDetails", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;

            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@autoPopulateTaskTemplateId", autoPopulateTaskTemplateId);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@timeEntryTaskId", timeentrytaskid);

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            ListItem _item = new ListItem();
            _item.Value = "0";
            _item.Text = "All Clients";

            if (canHaveMultipleClients)
            {
                checkBoxAllClients.Visible = true;
                listBoxClients.SelectionMode = ListSelectionMode.Multiple;
            }
            else
            {
                checkBoxAllClients.Visible = false;
                listBoxClients.SelectionMode = ListSelectionMode.Single;
                listBoxClients.Items.Insert(0, _item);
                listBoxClients.SelectedValue = "0";
            }

            if (_dataTable.Rows.Count == 0)
            {
                // No record in AutoPopulateTaskDetails
                HiddenFieldAutoPopulateTaskDetailsId.Value = "0";
                return 0;
            }

            // If Single client
            if (_dataTable.Rows.Count == 1)
            {
                SetListBoxForSingleValue(_dataTable, listBoxClients);
                HiddenFieldAutoPopulateTaskDetailsId.Value = _dataTable.Rows[0]["id"].ToString();
                return long.Parse(HiddenFieldAutoPopulateTaskDetailsId.Value);
            }

            ListItem _listItem = null;
            bool _first = true;

            foreach(DataRow _dataRow in _dataTable.Rows)
            {
                if (_first)
                {
                    _first = false;
                    HiddenFieldAutoPopulateTaskDetailsId.Value = _dataRow["id"].ToString();
                }
                if ((_listItem = listBoxClients.Items.FindByValue(_dataRow["clientId"].ToString())) != null)
                {
                    _listItem.Selected = true;
                }
            }
            return long.Parse(HiddenFieldAutoPopulateTaskDetailsId.Value);
        }

        private void SetListBoxForSingleValue(DataTable dataTable, ListBox listBoxClients)
        {
            DataRow _dataRow = dataTable.Rows[0];

            if (_dataRow["clientId"].ToString() != "-1")
            {
                listBoxClients.SelectedValue = _dataRow["clientId"].ToString();
            }
            else if (listBoxClients.SelectionMode == ListSelectionMode.Single)
            {
                listBoxClients.SelectedValue = "0";
            }
        }

        private void ProcessRecords(DataTable dataTable)
        {
            TextBoxTemplateName.Text = string.Empty;

            if (dataTable.Rows.Count == 0)
            {
                ButtonAdd.Visible = true;
                ButtonUpdate.Visible = false;
            }
            else
            {
                ButtonAdd.Visible = false;
                ButtonUpdate.Visible = true;
            }

            Dictionary<int, int> _dictWeekHours = new Dictionary<int, int>();

            for (int _counter = 0; _counter < 7; _counter++)
            {
              _dictWeekHours.Add(_counter, 0);
            }

            int _index = 0;
            TimeSpan _timeSpan = new TimeSpan();
            string _info = string.Empty;

            foreach (DataRow _dataRow in dataTable.Rows)
            {
                 if (string.IsNullOrEmpty(TextBoxTemplateName.Text))
                 {
                      TextBoxTemplateName.Text = _dataRow["TemplateName"].ToString();
                      HiddenFieldTemplateName.Value = TextBoxTemplateName.Text.Trim();
                 }

                 if ((_dataRow["AutoScheduleDaysId"].ToString() != "-1") && (_dataRow["StartStopTimeId"].ToString() != "-1"))
                 {
                      PanelWeekDetails.Visible = true;
                      ButtonAdd.Visible = false;
                      ButtonUpdate.Visible = true;

                      // Capture number of minutes recorded for the day
                      _timeSpan = DateTime.Parse(_dataRow["EndTime"].ToString()) - DateTime.Parse(_dataRow["StartTime"].ToString());
                      switch ((_index = int.Parse(_dataRow["DayOfWeekId"].ToString())))
                      {
                           case 0:
                                HiddenFieldSundayID.Value = _dataRow["AutoScheduleDaysId"].ToString();
                                if (LiteralSundayDetail.Text == "No time recorded<br/>for this day")
                                {
                                     LiteralSundayDetail.Text = DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt");
                                }
                                else
                                {
                                     LiteralSundayDetail.Text += "<br/>" + DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt");
                                }
                                LiteralSundayDetail.Text += "&nbsp;&nbsp;&nbsp;&nbsp;" + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                                break;
                           case 1:
                                HiddenFieldMondayID.Value = _dataRow["AutoScheduleDaysId"].ToString();
                                if (LiteralMondayDetail.Text == "No time recorded<br/>for this day")
                                {
                                     LiteralMondayDetail.Text = DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt");
                                }
                                else
                                {
                                     LiteralMondayDetail.Text += "<br/>" + DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt");
                                }
                                LiteralMondayDetail.Text += "&nbsp;&nbsp;&nbsp;&nbsp;" + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                                break;
                           case 2:
                                HiddenFieldTuesdayID.Value = _dataRow["AutoScheduleDaysId"].ToString();
                                if (LiteralTuesdayDetail.Text == "No time recorded<br/>for this day")
                                {
                                     LiteralTuesdayDetail.Text = DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt");
                                }
                                else
                                {
                                     LiteralTuesdayDetail.Text += "<br/>" + DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt");
                                }
                                LiteralTuesdayDetail.Text += "&nbsp;&nbsp;&nbsp;&nbsp;" + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                                break;
                           case 3:
                                HiddenFieldWednesdayID.Value = _dataRow["AutoScheduleDaysId"].ToString();
                                if (LiteralWednesdayDetail.Text == "No time recorded<br/>for this day")
                                {
                                     LiteralWednesdayDetail.Text = DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt");
                                }
                                else
                                {
                                     LiteralWednesdayDetail.Text += "<br/>" + DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt");
                                }
                                LiteralWednesdayDetail.Text += "&nbsp;&nbsp;&nbsp;&nbsp;" + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                                break;
                           case 4:
                                HiddenFieldThursdayID.Value = _dataRow["AutoScheduleDaysId"].ToString();
                                if (LiteralThursdayDetail.Text == "No time recorded<br/>for this day")
                                {
                                     LiteralThursdayDetail.Text = DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt");
                                }
                                else
                                {
                                     LiteralThursdayDetail.Text += "<br/>" + DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt");
                                }
                                LiteralThursdayDetail.Text += "&nbsp;&nbsp;&nbsp;&nbsp;" + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                                break;
                           case 5:
                                HiddenFieldFridayID.Value = _dataRow["AutoScheduleDaysId"].ToString();
                                if (LiteralFridayDetail.Text == "No time recorded<br/>for this day")
                                {
                                     LiteralFridayDetail.Text = DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt");
                                }
                                else
                                {
                                     LiteralFridayDetail.Text += "<br/>" + DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt");
                                }
                                LiteralFridayDetail.Text += "&nbsp;&nbsp;&nbsp;&nbsp;" + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                                break;
                           case 6:
                                HiddenFieldSaturdayID.Value = _dataRow["AutoScheduleDaysId"].ToString();
                                if (LiteralSaturdayDetail.Text == "No time recorded<br/>for this day")
                                {
                                     LiteralSaturdayDetail.Text = DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt");
                                }
                                else
                                {
                                     LiteralSaturdayDetail.Text += "<br/>" + DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt");
                                }
                                LiteralSaturdayDetail.Text += "&nbsp;&nbsp;&nbsp;&nbsp;" + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                                break;
                           default:
                                string _url = MBA.HttpApplication.createLink("InsertEditScheduleTemplateDay.aspx", true);
                                _url += "&employeeid=" + HiddenFieldEmployeeID.Value;

                                Response.Redirect(_url);
                                return;
                      }
                      _dictWeekHours[_index] += (int)_timeSpan.TotalMinutes;

                 }
            }

            int _minutes = 0;

            for (int _counter = 0; _counter < 7; _counter++)
            {
                 if (_dictWeekHours[_counter] > 0)
                 {
                      _info = "<br/>" + ((int)((double)_dictWeekHours[_counter] / 60.0)).ToString() + " Hours";

                      if ((_minutes = (int)_dictWeekHours[_counter] % 60) != 0)
                      {
                           _info += "&nbsp;&nbsp;&nbsp;&nbsp;" + _minutes.ToString() + " Minutes";
                      }
                      switch (_counter)
                      {
                           case 0:
                                LiteralSundayDetail.Text += _info;
                                break;
                           case 1:
                                LiteralMondayDetail.Text += _info;
                                break;
                           case 2:
                                LiteralTuesdayDetail.Text += _info;
                                break;
                           case 3:
                                LiteralWednesdayDetail.Text += _info;
                                break;
                           case 4:
                                LiteralThursdayDetail.Text += _info;
                                break;
                           case 5:
                                LiteralFridayDetail.Text += _info;
                                break;
                           case 6:
                                LiteralSaturdayDetail.Text += _info;
                                break;
                      }
                 }
            }

          }
          protected void ButtonSave_Click(object sender, EventArgs e)
          {
               SaveNewTemplate();
          }

          private void SaveNewTemplate()
          {
               using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
               {
                    _con.Open();

                    if (IsNamePresent(_con))
                    {
                        // Assuming no exception at this point,we should get the following alert box
                        ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                                "Schedule name is duplicate",
                                "alert('Name of template already exist. Must change the name to save!');",
                                true);

                        return;
                    }

                    string _sqlStatement = @"
                        INSERT INTO TimeKeeper.dbo.AutoPopulateScheduleTemplate
                        (
	                        [name]
	                        ,[description]
                        )
                        VALUES
                        (
	                        @Name
	                        ,@Description
                        );
                        SELECT SCOPE_IDENTITY();";


                    SqlCommand _sqlcommand = new SqlCommand(_sqlStatement, _con);
                    _sqlcommand.Parameters.AddWithValue("@Name", TextBoxTemplateName.Text);
                    // SBC Todo:  Refractor code.  They don't want description
                    _sqlcommand.Parameters.AddWithValue("@Description", "Not used");
                    
                    object _id = _sqlcommand.ExecuteScalar();

                    HiddenFieldTemplateID.Value = _id.ToString();

                    PanelWeekDetails.Visible = true;

                    ButtonUpdate.Visible = true;
                    ButtonAdd.Visible = false;
                
                    PanelWeekDetails.Visible = true;
                    HiddenFieldTemplateName.Value = TextBoxTemplateName.Text.Trim();

                    if (Request.QueryString["employeeid"] != null)
                    {
                        UpdateEmployeeWithTemplate(_id.ToString(), _con);
                    }
                    string _url = MBA.HttpApplication.createLink("InsertEditScheduleTemplate.aspx", true) +
                        "&scheduleTemplateId=" +
                            HiddenFieldTemplateID.Value + "&employeeid=" + HiddenFieldEmployeeID.Value;

                    //gotoNewURL(_url);
                    // At this point there should be no task template information
                    PanelWeekDetails.Visible = true;
                    ButtonAdd.Visible = false;
                    ButtonUpdate.Visible = true;
                    PopulateTaskRepeater(_con, 0);

            }
        }

          private void UpdateEmployeeWithTemplate(string id, SqlConnection con)
          {
               SqlCommand cmd = new SqlCommand("TimeKeeper_TIMESHEET_UpdateEmployeeTemplateId", con);
               cmd.CommandType = CommandType.StoredProcedure;
               cmd.Parameters.AddWithValue("@Id", Request.QueryString["employeeid"].ToString());
               cmd.Parameters.AddWithValue("@autoPopluateScheduleTemplateId", id);

               cmd.ExecuteNonQuery();
          }

           private bool IsNamePresent(SqlConnection con)
          {
                string _sqlStatement = @"
                    select
                        count(*) as count
                    from
                        [TimeKeeper].[dbo].[AutoPopulateScheduleTemplate]
                    where
                        name = @Name";

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Name", TextBoxTemplateName.Text);
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            DataRow _dataRow = _dataTable.Rows[0];

            return int.Parse(_dataRow["count"].ToString()) == 0 ? false : true;
          }

          protected void ButtonSunday_Click(object sender, EventArgs e)
          {
             string _url = MBA.HttpApplication.createLink("InsertEditScheduleTemplateDay.aspx", true) +
                 "&scheduleTemplateId=" +
                     HiddenFieldTemplateID.Value + "&templateDayId=" + HiddenFieldSundayID.Value + "&dayId=0";
             _url += "&employeeid=" + HiddenFieldEmployeeID.Value;
             
             //gotoNewURL(_url);
             Response.Redirect(_url, false);
          }

          protected void ButtonMonday_Click(object sender, EventArgs e)
          {
            string _url = MBA.HttpApplication.createLink("InsertEditScheduleTemplateDay.aspx", true) +
                "&scheduleTemplateId=" + HiddenFieldTemplateID.Value + "&templateDayId=" + HiddenFieldMondayID.Value + "&dayId=1";
            _url += "&employeeid=" + HiddenFieldEmployeeID.Value;
            //gotoNewURL(_url);
            Response.Redirect(_url, false);
          }

          protected void ButtonTuesday_Click(object sender, EventArgs e)
          {
            string _url = MBA.HttpApplication.createLink("InsertEditScheduleTemplateDay.aspx", true) +
                "&scheduleTemplateId=" +
                    HiddenFieldTemplateID.Value + "&templateDayId=" + HiddenFieldTuesdayID.Value + "&dayId=2";
            _url += "&employeeid=" + HiddenFieldEmployeeID.Value;

            //gotoNewURL(_url);
            Response.Redirect(_url, false);
          }

          protected void ButtonWednesday_Click(object sender, EventArgs e)
          {
            string _url = MBA.HttpApplication.createLink("InsertEditScheduleTemplateDay.aspx", true) +
                "&scheduleTemplateId=" +
                    HiddenFieldTemplateID.Value + "&templateDayId=" + HiddenFieldWednesdayID.Value + "&dayId=3";
            _url += "&employeeid=" + HiddenFieldEmployeeID.Value;

            //gotoNewURL(_url);
            Response.Redirect(_url, false);

          }

          protected void ButtonThursday_Click(object sender, EventArgs e)
          {
            string _url = MBA.HttpApplication.createLink("InsertEditScheduleTemplateDay.aspx", true) +
                "&scheduleTemplateId=" +
                    HiddenFieldTemplateID.Value + "&templateDayId=" + HiddenFieldThursdayID.Value + "&dayId=4";
            _url += "&employeeid=" + HiddenFieldEmployeeID.Value;

            //gotoNewURL(_url); 
            Response.Redirect(_url, false);
          }

          protected void ButtonFriday_Click(object sender, EventArgs e)
          {
            string _url = MBA.HttpApplication.createLink("InsertEditScheduleTemplateDay.aspx", true) +
                "&scheduleTemplateId=" +
                    HiddenFieldTemplateID.Value + "&templateDayId=" + HiddenFieldFridayID.Value + "&dayId=5";
            _url += "&employeeid=" + HiddenFieldEmployeeID.Value;

            //gotoNewURL(_url);
            Response.Redirect(_url, false);
          }

          protected void ButtonSaturday_Click(object sender, EventArgs e)
          {
            string _url = MBA.HttpApplication.createLink("InsertEditScheduleTemplateDay.aspx", true) +
                "&scheduleTemplateId=" +
                    HiddenFieldTemplateID.Value + "&templateDayId=" + HiddenFieldSaturdayID.Value + "&dayId=6";
            _url += "&employeeid=" + HiddenFieldEmployeeID.Value;

            //gotoNewURL(_url);
            Response.Redirect(_url, false);
          }

          protected void ButtonUpdate_Click(object sender, EventArgs e)
          {
               string _confirmUpdate = Request.Form["confirm_update"];
               if (_confirmUpdate != "Yes")
               {
                    return;
               }

               // should never happen but just in case
               if (HiddenFieldTemplateID.Value == "0")
               {
                    ButtonAdd.Visible = true;
                    ButtonUpdate.Visible = false;
                    PanelWeekDetails.Visible = false;
                    return;
               }

               using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
               {
                    _con.Open();

                    if ((HiddenFieldTemplateName.Value.ToLower() != TextBoxTemplateName.Text.Trim().ToLower()) && IsNamePresent(_con))
                    {
                        // Assuming no exception at this point,we should get the following alert box
                        ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                                "Schedule name is duplicate",
                                "alert('Name of template already exist. Must change the name to save!');",
                                true);

                        return;
                    }
                    string _sqlStatement = @"
                        UPDATE TimeKeeper.dbo.AutoPopulateScheduleTemplate
	                        SET [name] = @Name
	                        ,[description] = @Description
	                    WHERE
                            id = @Id";

                    using (SqlCommand cmd = new SqlCommand(_sqlStatement, _con))
                    {
                         cmd.Parameters.AddWithValue("@Name", TextBoxTemplateName.Text);
                         cmd.Parameters.AddWithValue("@Description", "Not Used");
                         cmd.Parameters.AddWithValue("@Id", HiddenFieldTemplateID.Value);
                         cmd.ExecuteNonQuery();

                         HiddenFieldTemplateName.Value = TextBoxTemplateName.Text.Trim();
                    }
               }

               // Assuming no exception at this point,we should get the following alert box
               ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                       "Update Applied",
                       "alert('Update for schedule has been applied!');",
                       true);

          }

          protected void ButtonBack_Click(object sender, EventArgs e)
          {
              if (!string.IsNullOrEmpty(HiddenFieldEmployeeID.Value))
              {
                  RedirectToPreviousAdminScreen();
              }
              else
              {
                  RedirectToAutoSchedulePage();
              }
          }
          
          private void RedirectToAutoSchedulePage()
          {
               string _url = MBA.HttpApplication.createLink("TimeEntryScheduleAdmin.aspx", true);
               Response.Redirect(_url, false);
          }

        private void RedirectToPreviousAdminScreen()
          {
              string _url = MBA.HttpApplication.createLink("TimeEntryScheduleAdminTemplate.aspx", true);
          
              if (Session["TimeEntryScheduleAdminUrl"] != null)
              {
                  _url = Session["TimeEntryScheduleAdminUrl"].ToString();
                  Session.Remove("TimeEntryScheduleAdminUrl");
              }
              //gotoNewURL(_url);
              Response.Redirect(_url, false);
          
          }


        private DataTable GetScheduleForDay(string day, SqlConnection con)
        {
            string _sqlStatement = @"
                    select
	                    DOTW.day
	                    ,DOTW.id as DayId
	                    ,APSSAST.autoPopulateScheduleDaysId
	                    ,APSSAST.starttime
	                    ,APSSAST.stoptime
                    from
	                    TimeKeeper.dbo.AutoPopulateScheduleDays APSD
	                    inner join TimeKeeper.dbo.DaysOfTheWeek DOTW
		                    ON DOTW.id = APSD.dayId
	                    inner join TimeKeeper.dbo.AutoPopulateScheduleStartAndStopTime APSSAST
		                    ON APSSAST.autoPopulateScheduleDaysId = APSD.id
                    where
	                    APSD.scheduleid = @ScheduleId
                        AND DOTW.day = @Day";
            SqlDataAdapter _sqlDataAdpater = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdpater.SelectCommand.Parameters.AddWithValue("@ScheduleId", HiddenFieldTemplateID.Value);
            _sqlDataAdpater.SelectCommand.Parameters.AddWithValue("@Day", day);

            DataTable _dataTable = new DataTable();
            _sqlDataAdpater.Fill(_dataTable);

            return _dataTable;
        }
        protected void ButtonCopyFromMonday_Click(object sender, EventArgs e)
        {
            string _day = "Monday";

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                DataTable _dataTable = GetScheduleForDay(_day, _con);

                if (_dataTable.Rows.Count == 0)
                {
                    string _message = "There are no entries for Monday";
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        "No entries for that day",
                        "alert('" + _message + "');",
                        true);
                    return;
                }

                bool _daySelected = false;
                if (CheckBoxMondayToSunday.Checked)
                {
                    CopyDaySchedule("Sunday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxMondayToTuesday.Checked)
                {
                    CopyDaySchedule("Tuesday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxMondayToWednesday.Checked)
                {
                    CopyDaySchedule("Wednesday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxMondayToThursday.Checked)
                {
                    CopyDaySchedule("Thursday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxMondayToFriday.Checked)
                {
                    CopyDaySchedule("Friday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxMondayToSaturday.Checked)
                {
                    CopyDaySchedule("Saturday", _dataTable, _con);
                    _daySelected = true;
                }

                if (!_daySelected)
                {
                    string _message = "No day was selected to copy too";
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        "You did not specify day to copy too",
                        "alert('" + _message + "');",
                        true);
                    return;
                }
                GetScheduleDaysInfo();
            }
        }

        private void CopyDaySchedule(string day, DataTable dataTable, SqlConnection con)
        {
            // Check if schedule exist for that day
            string _sqlStatement = @"
                select
	                APSD.id
                from
	                TimeKeeper.dbo.AutoPopulateScheduleDays APSD
	                inner join TimeKeeper.dbo.DaysOfTheWeek DOTW
		                ON DOTW.id = APSD.dayId
                where
	                APSD.scheduleid = @ScheduleId
	                and DOTW.day = @Day";

            int _autoPoplateScheduleId = 0;
            int _dayId = 0;

            using (SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con))
            {
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@ScheduleId", HiddenFieldTemplateID.Value);
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Day", day);
                DataTable _dataTable = new DataTable();
                _sqlDataAdapter.Fill(_dataTable);

                // If it doesn't Insert schedule for that day
                if (_dataTable.Rows.Count == 0)
                {
                    _dayId = GetDayId(day, con);
                    _autoPoplateScheduleId = InsertScheduleForDay(_dayId, con);
                }
                else
                {
                    _autoPoplateScheduleId = int.Parse(_dataTable.Rows[0]["id"].ToString());
                }
            }

            if (IsSchedulePresentForDay(_autoPoplateScheduleId, con))
            {
                string _message = string.Format("Schedule for the day {0} is present\\nCannot copy over existing schedule", day);
                ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                    "Schedule for that day is present",
                    "alert('" + _message + "');",
                    true);
                return;
            }

            InsertScheduleForDay(_autoPoplateScheduleId, dataTable, con);
        }

        private void InsertScheduleForDay(int autoPoplateScheduleId, DataTable dataTable, SqlConnection con)
        {
            string _insertStatement = @"
                insert into TimeKeeper.dbo.AutoPopulateScheduleStartAndStopTime
                (
	                autoPopulateScheduleDaysId
	                ,starttime
	                ,stoptime
                )";
            string _insertStatement2 = string.Empty;

            foreach (DataRow _dataRow in dataTable.Rows)
            {
                _insertStatement2 = @"
                    values
                    (
	                    @AutoPopulateScheduleId
	                    ,@StartTime
	                    ,@StopTime
                    )";
                using (SqlCommand _sqlCommand = new SqlCommand(_insertStatement + _insertStatement2, con))
                {
                    _sqlCommand.Parameters.AddWithValue("@AutoPopulateScheduleId", autoPoplateScheduleId);
                    _sqlCommand.Parameters.AddWithValue("@StartTime", _dataRow["starttime"].ToString());
                    _sqlCommand.Parameters.AddWithValue("@StopTime", _dataRow["stoptime"].ToString());
                    _sqlCommand.ExecuteNonQuery();
                }
            }
        }
        private bool IsSchedulePresentForDay(int autoPoplateScheduleId, SqlConnection con)
        {
            string _sqlStatement = @"
                select 
                    count(*) as numberRecs
                from
                    TimeKeeper.dbo.AutoPopulateScheduleStartAndStopTime
                where
                    autoPopulateScheduleDaysId = @AutoPopulateScheduleDaysId";

            int _numberRecs = 0;

            using (SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con))
            {
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@AutoPopulateScheduleDaysId", autoPoplateScheduleId);
                DataTable _dataTable = new DataTable();
                _sqlDataAdapter.Fill(_dataTable);

                _numberRecs = int.Parse(_dataTable.Rows[0]["numberRecs"].ToString());
            }

            return _numberRecs == 0 ? false : true;
        }

        private int GetDayId(string day, SqlConnection con)
        {
            string _sqlStatement = @"
                        select
	                        id
                        from
	                        TimeKeeper.dbo.DaysOfTheWeek
                        where
	                        day = @Day";

            int _dayId = 0;
            using (SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con))
            {
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Day", day);
                DataTable _dataTable = new DataTable();
                _sqlDataAdapter.Fill(_dataTable);
                _dayId = int.Parse(_dataTable.Rows[0]["id"].ToString());
            }

            return _dayId;
        }

        private int InsertScheduleForDay(int dayId, SqlConnection con)
        {
            string _insertStatement = @"
                INSERT INTO TimeKeeper.dbo.AutoPopulateScheduleDays
                (
	                dayid,
	                scheduleid
                )
                values
                (
	                @dayid,
	                @scheduleid
                );
                SELECT SCOPE_IDENTITY();
            ";

            int _id = 0;

            using (SqlCommand _sqlCommand = new SqlCommand(_insertStatement, con))
            {
                _sqlCommand.Parameters.AddWithValue("@dayid", dayId);
                _sqlCommand.Parameters.AddWithValue("@scheduleid", HiddenFieldTemplateID.Value);

                _id = Convert.ToInt32(_sqlCommand.ExecuteScalar());
            }

            return _id;
        }
        protected void ButtonCopyFromTuesday_Click(object sender, EventArgs e)
        {
            string _day = "Tuesday";

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                DataTable _dataTable = GetScheduleForDay(_day, _con);

                if (_dataTable.Rows.Count == 0)
                {
                    string _message = "There are no entries for " + _day;
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        "No entries for that day",
                        "alert('" + _message + "');",
                        true);
                    return;
                }

                bool _daySelected = false;

                if (CheckBoxTuesdayToSunday.Checked)
                {
                    CopyDaySchedule("Sunday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxTuesdayToMonday.Checked)
                {
                    CopyDaySchedule("Monday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxTuesdayToWednesday.Checked)
                {
                    CopyDaySchedule("Wednesday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxTuesdayToThursday.Checked)
                {
                    CopyDaySchedule("Thursday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxTuesdayToFriday.Checked)
                {
                    CopyDaySchedule("Friday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxTuesdayToSaturday.Checked)
                {
                    CopyDaySchedule("Saturday", _dataTable, _con);
                    _daySelected = true;
                }

                if (!_daySelected)
                {
                    string _message = "No day was selected to copy too";
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        "You did not specify day to copy too",
                        "alert('" + _message + "');",
                        true);
                    return;
                }
                GetScheduleDaysInfo();
            }
        }

        protected void ButtonCopyFromWednesday_Click(object sender, EventArgs e)
        {
            string _day = "Wednesday";

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                DataTable _dataTable = GetScheduleForDay(_day, _con);

                if (_dataTable.Rows.Count == 0)
                {
                    string _message = "There are no entries for " + _day;
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        "No entries for that day",
                        "alert('" + _message + "');",
                        true);
                    return;
                }

                bool _daySelected = false;

                if (CheckBoxWednesdayToSunday.Checked)
                {
                    CopyDaySchedule("Sunday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxWednesdayToMonday.Checked)
                {
                    CopyDaySchedule("Monday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxWednesdayToTuesday.Checked)
                {
                    CopyDaySchedule("Tuesday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxWednesdayToThursday.Checked)
                {
                    CopyDaySchedule("Thursday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxWednesdayToFriday.Checked)
                {
                    CopyDaySchedule("Friday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxWednesdayToSaturday.Checked)
                {
                    CopyDaySchedule("Saturday", _dataTable, _con);
                    _daySelected = true;
                }

                if (!_daySelected)
                {
                    string _message = "No day was selected to copy too";
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        "You did not specify day to copy too",
                        "alert('" + _message + "');",
                        true);
                    return;
                }
                GetScheduleDaysInfo();
            }
        }

        protected void ButtonCopyFromThursday_Click(object sender, EventArgs e)
        {
            string _day = "Thursday";

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                DataTable _dataTable = GetScheduleForDay(_day, _con);

                if (_dataTable.Rows.Count == 0)
                {
                    string _message = "There are no entries for " + _day;
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        "No entries for that day",
                        "alert('" + _message + "');",
                        true);
                    return;
                }

                bool _daySelected = false;

                if (CheckBoxThursdayToSunday.Checked)
                {
                    CopyDaySchedule("Sunday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxThursdayToMonday.Checked)
                {
                    CopyDaySchedule("Monday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxThursdayToTuesday.Checked)
                {
                    CopyDaySchedule("Tuesday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxThursdayToWednesday.Checked)
                {
                    CopyDaySchedule("Wednesday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxThursdayToFriday.Checked)
                {
                    CopyDaySchedule("Friday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxThursdayToSaturday.Checked)
                {
                    CopyDaySchedule("Saturday", _dataTable, _con);
                    _daySelected = true;
                }

                if (!_daySelected)
                {
                    string _message = "No day was selected to copy too";
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        "You did not specify day to copy too",
                        "alert('" + _message + "');",
                        true);
                    return;
                }
                GetScheduleDaysInfo();
            }
        }

        protected void ButtonCopyFromFriday_Click(object sender, EventArgs e)
        {
            string _day = "Friday";

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                DataTable _dataTable = GetScheduleForDay(_day, _con);

                if (_dataTable.Rows.Count == 0)
                {
                    string _message = "There are no entries for " + _day;
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        "No entries for that day",
                        "alert('" + _message + "');",
                        true);
                    return;
                }

                bool _daySelected = false;

                if (CheckBoxFridayToSunday.Checked)
                {
                    CopyDaySchedule("Sunday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxFridayToMonday.Checked)
                {
                    CopyDaySchedule("Monday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxFridayToTuesday.Checked)
                {
                    CopyDaySchedule("Tuesday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxFridayToWednesday.Checked)
                {
                    CopyDaySchedule("Wednesday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxFridayToThursday.Checked)
                {
                    CopyDaySchedule("Thursday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxFridayToSaturday.Checked)
                {
                    CopyDaySchedule("Saturday", _dataTable, _con);
                    _daySelected = true;
                }

                if (!_daySelected)
                {
                    string _message = "No day was selected to copy too";
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        "You did not specify day to copy too",
                        "alert('" + _message + "');",
                        true);
                    return;
                }
                GetScheduleDaysInfo();
            }
        }

        protected void ButtonCopyFromSunday_Click(object sender, EventArgs e)
        {
            string _day = "Sunday";

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                DataTable _dataTable = GetScheduleForDay(_day, _con);

                if (_dataTable.Rows.Count == 0)
                {
                    string _message = "There are no entries for " + _day;
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        "No entries for that day",
                        "alert('" + _message + "');",
                        true);
                    return;
                }

                bool _daySelected = false;

                if (CheckBoxSundayToMonday.Checked)
                {
                    CopyDaySchedule("Monday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxSundayToTuesday.Checked)
                {
                    CopyDaySchedule("Tuesday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxSundayToWednesday.Checked)
                {
                    CopyDaySchedule("Wednesday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxSundayToThursday.Checked)
                {
                    CopyDaySchedule("Thursday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxSundayToFriday.Checked)
                {
                    CopyDaySchedule("Friday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxSundayToSaturday.Checked)
                {
                    CopyDaySchedule("Saturday", _dataTable, _con);
                    _daySelected = true;
                }

                if (!_daySelected)
                {
                    string _message = "No day was selected to copy too";
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        "You did not specify day to copy too",
                        "alert('" + _message + "');",
                        true);
                    return;
                }
                GetScheduleDaysInfo();
            }
        }

        protected void ButtonCopyFromSaturday_Click(object sender, EventArgs e)
        {
            string _day = "Saturday";

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                DataTable _dataTable = GetScheduleForDay(_day, _con);

                if (_dataTable.Rows.Count == 0)
                {
                    string _message = "There are no entries for " + _day;
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        "No entries for that day",
                        "alert('" + _message + "');",
                        true);
                    return;
                }

                bool _daySelected = false;

                if (CheckBoxSaturdayToSunday.Checked)
                {
                    CopyDaySchedule("Sunday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxSaturdayToMonday.Checked)
                {
                    CopyDaySchedule("Monday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxSaturdayToTuesday.Checked)
                {
                    CopyDaySchedule("Tuesday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxSaturdayToWednesday.Checked)
                {
                    CopyDaySchedule("Wednesday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxSaturdayToThursday.Checked)
                {
                    CopyDaySchedule("Thursday", _dataTable, _con);
                    _daySelected = true;
                }

                if (CheckBoxSaturdayToFriday.Checked)
                {
                    CopyDaySchedule("Friday", _dataTable, _con);
                    _daySelected = true;
                }

                if (!_daySelected)
                {
                    string _message = "No day was selected to copy too";
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        "You did not specify day to copy too",
                        "alert('" + _message + "');",
                        true);
                    return;
                }
                GetScheduleDaysInfo();
            }

        }

        private void DeleteDay(string day)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();

                int _dayId = GetDayId(day, _con);
                string _deleteStatement = @"
                    delete 
                    from 
                        TimeKeeper.dbo.AutoPopulateScheduleDays
                    where 
                        dayId = @DayId
                        and scheduleid = @ScheduleId";

                using (SqlCommand _sqlCommand = new SqlCommand(_deleteStatement, _con))
                {
                    _sqlCommand.Parameters.AddWithValue("@DayId", _dayId.ToString());
                    _sqlCommand.Parameters.AddWithValue("@ScheduleId", HiddenFieldTemplateID.Value);
                    _sqlCommand.ExecuteNonQuery();
                }
            }
            GetScheduleDaysInfo();
        }
        protected void ButtonDeleteSunday_Click(object sender, EventArgs e)
        {
            string _confirmUpdate = Request.Form["confirm_update"];
            if (_confirmUpdate != "Yes")
            {
                return;
            }

            DeleteDay("Sunday");
        }

        protected void ButtonDeleteMonday_Click(object sender, EventArgs e)
        {
            string _confirmUpdate = Request.Form["confirm_update"];
            if (_confirmUpdate != "Yes")
            {
                return;
            }

            DeleteDay("Monday");
        }

        protected void ButtonDeleteTuesday_Click(object sender, EventArgs e)
        {
            string _confirmUpdate = Request.Form["confirm_update"];
            if (_confirmUpdate != "Yes")
            {
                return;
            }

            DeleteDay("Tuesday");
        }

        protected void ButtonDeleteWednesday_Click(object sender, EventArgs e)
        {
            string _confirmUpdate = Request.Form["confirm_update"];
            if (_confirmUpdate != "Yes")
            {
                return;
            }

            DeleteDay("Wednesday");
        }

        protected void ButtonDeleteThursday_Click(object sender, EventArgs e)
        {
            string _confirmUpdate = Request.Form["confirm_update"];
            if (_confirmUpdate != "Yes")
            {
                return;
            }

            DeleteDay("Thursday");
        }

        protected void ButtonDeleteFriday_Click(object sender, EventArgs e)
        {
            string _confirmUpdate = Request.Form["confirm_update"];
            if (_confirmUpdate != "Yes")
            {
                return;
            }

            DeleteDay("Friday");
        }

        protected void ButtonDeleteSaturday_Click(object sender, EventArgs e)
        {
            string _confirmUpdate = Request.Form["confirm_update"];
            if (_confirmUpdate != "Yes")
            {
                return;
            }

            DeleteDay("Saturday");
        }

        private void InsertTaskTemplate(SqlConnection con)
        {
            SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_TIMESHEET_InsertAutoPopulateTaskTemplate", con);
            _sqlCommand.CommandType = CommandType.StoredProcedure;
            _sqlCommand.Parameters.AddWithValue("@Name", HiddenFieldAutoPopulateTaskTemplateName.Value);
            _sqlCommand.Parameters.AddWithValue("@Description", "Not used");
            _sqlCommand.Parameters.Add("@Id", SqlDbType.BigInt);
            _sqlCommand.Parameters["@Id"].Direction = ParameterDirection.Output;

            _sqlCommand.ExecuteNonQuery();

            HiddenFieldAutoPopulateTaskTemplateId.Value = _sqlCommand.Parameters["@Id"].Value.ToString();
        }

        private void UpdateAutoPopulateTaskTemplate(SqlConnection con)
        {
            SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_TIMESHEET_UpdateScheduleTemplate", con);
            _sqlCommand.CommandType = CommandType.StoredProcedure;
            _sqlCommand.Parameters.AddWithValue("@Id", HiddenFieldTemplateID.Value);
            _sqlCommand.Parameters.AddWithValue("@autoPopulateTaskTemplateId", HiddenFieldAutoPopulateTaskTemplateId.Value);
            _sqlCommand.Parameters.AddWithValue("@employeeId", HiddenFieldEmployeeID.Value);

            _sqlCommand.ExecuteNonQuery();

        }
        protected void ButtonSaveTaskInfo_Click(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            { 
                _con.Open();
                if (HiddenFieldAutoPopulateTaskTemplateId.Value == "-1" || 
                    string.IsNullOrEmpty(HiddenFieldAutoPopulateTaskTemplateId.Value))
                {
                    InsertTaskTemplate(_con);
                    UpdateAutoPopulateTaskTemplate(_con);
                }

                HiddenField HiddenFieldTaskId = null;
                HiddenField HiddenFieldAutoPopulateTaskDetailsId = null;
                Label labelTaskName = null;
                ListBox listBoxClients = null;

                LabelProblem.Text = string.Empty;

                Panel panelHoursMinutesSunday = null;

                foreach (RepeaterItem rptItem in repeaterTaskTemplateControl.Items)
                {
                    HiddenFieldTaskId = (HiddenField)rptItem.FindControl("HiddenFieldTaskId");
                    HiddenFieldAutoPopulateTaskDetailsId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateTaskDetailsId");
                    labelTaskName = (Label)rptItem.FindControl("labelTaskName");
                    listBoxClients = (ListBox)rptItem.FindControl("listBoxClients");

                    panelHoursMinutesSunday = (Panel)rptItem.FindControl("panelHoursMinutesSunday");

                    if (panelHoursMinutesSunday.Visible)
                    {
                        InsertUpdateTaskHoursMinutes(listBoxClients, labelTaskName, HiddenFieldAutoPopulateTaskDetailsId, HiddenFieldTaskId, rptItem, _con);
                    }
                    else
                    {
                        InsertUpdateTaskStartStop(listBoxClients, HiddenFieldTaskId, HiddenFieldAutoPopulateTaskDetailsId, rptItem, _con);
                    }
                }
                PopulateTaskRepeater(_con, long.Parse(HiddenFieldAutoPopulateTaskTemplateId.Value));
            }
        }

        private void InsertUpdateTaskStartStop(ListBox listBoxClients,
            HiddenField HiddenFieldTaskId,
            HiddenField HiddenFieldAutoPopulateTaskDetailsId,
            RepeaterItem rptItem,
            SqlConnection con)
        {
            long _id = 0;
            List<long> _listAutoPupolateTaskDetailsId = null;

            if (!AutoPopulateTaskDetailsRecordExist(con, HiddenFieldAutoPopulateTaskTemplateId.Value, HiddenFieldTaskId.Value, out _id))
            {
                if (listBoxClients.SelectionMode == ListSelectionMode.Single)
                {
                    InsertAutoPopulateTaskDetails(con, HiddenFieldAutoPopulateTaskDetailsId, HiddenFieldAutoPopulateTaskTemplateId.Value, HiddenFieldTaskId.Value, listBoxClients.SelectedValue);
                }
                else
                {
                    _listAutoPupolateTaskDetailsId = InsertMultipleAutoPopulateTaskDetails(con, HiddenFieldAutoPopulateTaskDetailsId, HiddenFieldAutoPopulateTaskTemplateId.Value, HiddenFieldTaskId.Value, listBoxClients);
                }
            }
            else
            {
                HiddenFieldAutoPopulateTaskDetailsId.Value = _id.ToString();
            }

            ListBox listBoxStartStopSunday = (ListBox)rptItem.FindControl("listBoxStartStopSunday");
            ListBox listBoxStartStopMonday = (ListBox)rptItem.FindControl("listBoxStartStopMonday");
            ListBox listBoxStartStopTuesday = (ListBox)rptItem.FindControl("listBoxStartStopTuesday");
            ListBox listBoxStartStopWednesday = (ListBox)rptItem.FindControl("listBoxStartStopWednesday");
            ListBox listBoxStartStopThursday = (ListBox)rptItem.FindControl("listBoxStartStopThursday");
            ListBox listBoxStartStopFriday = (ListBox)rptItem.FindControl("listBoxStartStopFriday");
            ListBox listBoxStartStopSaturday = (ListBox)rptItem.FindControl("listBoxStartStopSaturday");

            HiddenField HiddenFieldAutoPopulateSundayTaskDaysId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateSundayTaskDaysId");
            HiddenField HiddenFieldAutoPopulateMondayTaskDaysId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateMondayTaskDaysId");
            HiddenField HiddenFieldAutoPopulateTuesdayTaskDaysId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateTuesdayTaskDaysId");
            HiddenField HiddenFieldAutoPopulateWednesdayTaskDaysId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateWednesdayTaskDaysId");
            HiddenField HiddenFieldAutoPopulateThursdayTaskDaysId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateThursdayTaskDaysId");
            HiddenField HiddenFieldAutoPopulateFridayTaskDaysId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateFridayTaskDaysId");
            HiddenField HiddenFieldAutoPopulateSaturdayTaskDaysId = (HiddenField)rptItem.FindControl("HiddenFieldAutoPopulateSaturdayTaskDaysId");

            if (listBoxStartStopSunday.Items.Count > 0)
            {
                if (_listAutoPupolateTaskDetailsId == null)
                    SaveListBoxStopStartTime(con, HiddenFieldTaskId, HiddenFieldAutoPopulateTaskDetailsId, DayOfWeek.Sunday, HiddenFieldAutoPopulateSundayTaskDaysId, listBoxStartStopSunday);
                else
                    SaveListBoxStopStartTime(con, HiddenFieldTaskId, _listAutoPupolateTaskDetailsId, DayOfWeek.Sunday, HiddenFieldAutoPopulateSundayTaskDaysId, listBoxStartStopSunday);
            }
            RemoveFromDBUnreferencedId(con, HiddenFieldAutoPopulateTaskDetailsId, listBoxStartStopSunday, 0);

            if (listBoxStartStopMonday.Items.Count > 0)
            {
                if (_listAutoPupolateTaskDetailsId == null)
                    SaveListBoxStopStartTime(con, HiddenFieldTaskId, HiddenFieldAutoPopulateTaskDetailsId, DayOfWeek.Monday, HiddenFieldAutoPopulateMondayTaskDaysId, listBoxStartStopMonday);
                else
                    SaveListBoxStopStartTime(con, HiddenFieldTaskId, _listAutoPupolateTaskDetailsId, DayOfWeek.Monday, HiddenFieldAutoPopulateMondayTaskDaysId, listBoxStartStopMonday);
            }
            RemoveFromDBUnreferencedId(con, HiddenFieldAutoPopulateTaskDetailsId, listBoxStartStopMonday, 1);

            if (listBoxStartStopTuesday.Items.Count > 0)
            {
                if (_listAutoPupolateTaskDetailsId == null)
                    SaveListBoxStopStartTime(con, HiddenFieldTaskId, HiddenFieldAutoPopulateTaskDetailsId, DayOfWeek.Tuesday, HiddenFieldAutoPopulateTuesdayTaskDaysId, listBoxStartStopTuesday);
                else
                    SaveListBoxStopStartTime(con, HiddenFieldTaskId, _listAutoPupolateTaskDetailsId, DayOfWeek.Tuesday, HiddenFieldAutoPopulateTuesdayTaskDaysId, listBoxStartStopTuesday);
            }
            RemoveFromDBUnreferencedId(con, HiddenFieldAutoPopulateTaskDetailsId, listBoxStartStopTuesday, 2);

            if (listBoxStartStopWednesday.Items.Count > 0)
            {
                if (_listAutoPupolateTaskDetailsId == null)
                    SaveListBoxStopStartTime(con, HiddenFieldTaskId, HiddenFieldAutoPopulateTaskDetailsId, DayOfWeek.Wednesday, HiddenFieldAutoPopulateWednesdayTaskDaysId, listBoxStartStopWednesday);
                else
                    SaveListBoxStopStartTime(con, HiddenFieldTaskId, _listAutoPupolateTaskDetailsId, DayOfWeek.Wednesday, HiddenFieldAutoPopulateWednesdayTaskDaysId, listBoxStartStopWednesday);
            }
            RemoveFromDBUnreferencedId(con, HiddenFieldAutoPopulateTaskDetailsId, listBoxStartStopWednesday, 3);

            if (listBoxStartStopThursday.Items.Count > 0)
            {
                if (_listAutoPupolateTaskDetailsId == null)
                    SaveListBoxStopStartTime(con, HiddenFieldTaskId, HiddenFieldAutoPopulateTaskDetailsId, DayOfWeek.Thursday, HiddenFieldAutoPopulateThursdayTaskDaysId, listBoxStartStopThursday);
                else
                    SaveListBoxStopStartTime(con, HiddenFieldTaskId, _listAutoPupolateTaskDetailsId, DayOfWeek.Thursday, HiddenFieldAutoPopulateThursdayTaskDaysId, listBoxStartStopThursday);
            }
            RemoveFromDBUnreferencedId(con, HiddenFieldAutoPopulateTaskDetailsId, listBoxStartStopThursday, 4);

            if (listBoxStartStopFriday.Items.Count > 0)
            {
                if (_listAutoPupolateTaskDetailsId == null)
                    SaveListBoxStopStartTime(con, HiddenFieldTaskId, HiddenFieldAutoPopulateTaskDetailsId, DayOfWeek.Friday, HiddenFieldAutoPopulateFridayTaskDaysId, listBoxStartStopFriday);
                else
                    SaveListBoxStopStartTime(con, HiddenFieldTaskId, _listAutoPupolateTaskDetailsId, DayOfWeek.Friday, HiddenFieldAutoPopulateFridayTaskDaysId, listBoxStartStopFriday);
            }
            RemoveFromDBUnreferencedId(con, HiddenFieldAutoPopulateTaskDetailsId, listBoxStartStopFriday, 5);

            if (listBoxStartStopSaturday.Items.Count > 0)
            {
                if (_listAutoPupolateTaskDetailsId == null)
                    SaveListBoxStopStartTime(con, HiddenFieldTaskId, HiddenFieldAutoPopulateTaskDetailsId, DayOfWeek.Saturday, HiddenFieldAutoPopulateSaturdayTaskDaysId, listBoxStartStopSaturday);
                else
                    SaveListBoxStopStartTime(con, HiddenFieldTaskId, _listAutoPupolateTaskDetailsId, DayOfWeek.Saturday, HiddenFieldAutoPopulateSaturdayTaskDaysId, listBoxStartStopSaturday);
            }
            RemoveFromDBUnreferencedId(con, HiddenFieldAutoPopulateTaskDetailsId, listBoxStartStopSaturday, 6);
        }

        private DataTable GetAutoPopulateTaskDaysStartStopTimeByDay(SqlConnection con, HiddenField HiddenFieldAutoPopulateTaskDetailsId, short dayId)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_AUTO_GetAutoPopulateTaskDaysStartStopTimeByDay", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;

            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@autoPopulateTaskDetailsId", HiddenFieldAutoPopulateTaskDetailsId.Value);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@dayId", dayId);

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            return _dataTable;
        }

        private DataTable GetAutoPopulateTaskDaysStartStopTime(SqlConnection con, HiddenField HiddenFieldAutoPopulateTaskDetailsId)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_AUTO_GetAutoPopulateTaskDaysStartStopTime", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;

            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@autoPopulateTaskDetailsId", HiddenFieldAutoPopulateTaskDetailsId.Value);

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            return _dataTable;
        }

        private void SaveListBoxStopStartTime(SqlConnection con, HiddenField HiddenFieldTaskId, List<long> listAutoPupolateTaskDetailsId, DayOfWeek day, HiddenField HiddenFieldAutoPopulateTaskDaysId, ListBox listBoxStartStopTime)
        {
            if (listAutoPupolateTaskDetailsId.Count == 0)
            {
                return;
            }

            bool _firstRecord = true;
            if (HiddenFieldAutoPopulateTaskDaysId.Value == "0" || string.IsNullOrEmpty(HiddenFieldAutoPopulateTaskDaysId.Value))
            {
                foreach (long _autoPopulateTaskDetailsId in listAutoPupolateTaskDetailsId)
                {
                    // Just store the first record
                    if (_firstRecord)
                        HiddenFieldAutoPopulateTaskDaysId.Value = InsertOrUpdateAutoPopulateTaskDays(con, (int)day, _autoPopulateTaskDetailsId, 0, 0).ToString();
                    else
                        InsertOrUpdateAutoPopulateTaskDays(con, (int)day, _autoPopulateTaskDetailsId, 0, 0).ToString();
                    _firstRecord = false;
                }
            }
            foreach (ListItem item in listBoxStartStopTime.Items)
            {
                InsertOrUpdateAutoPopulateScheduleStartAndStopTime(con, item, HiddenFieldAutoPopulateTaskDaysId);
            }
        }
        private void SaveListBoxStopStartTime(SqlConnection con, HiddenField HiddenFieldTaskId, HiddenField HiddenFieldAutoPopulateTaskDetailsId, DayOfWeek day, HiddenField HiddenFieldAutoPopulateTaskDaysId, ListBox listBoxStartStopTime)
        {
            if (HiddenFieldAutoPopulateTaskDaysId.Value == "0" || string.IsNullOrEmpty(HiddenFieldAutoPopulateTaskDaysId.Value))
            {
                HiddenFieldAutoPopulateTaskDaysId.Value = InsertOrUpdateAutoPopulateTaskDays(con, (int)day, long.Parse(HiddenFieldAutoPopulateTaskDetailsId.Value), 0, 0).ToString();
            }
            foreach(ListItem item in listBoxStartStopTime.Items)
            {
                InsertOrUpdateAutoPopulateScheduleStartAndStopTime(con, item, HiddenFieldAutoPopulateTaskDaysId);
            }
        }

        private long InsertOrUpdateAutoPopulateScheduleStartAndStopTime(SqlConnection con, ListItem item, HiddenField HiddenFieldAutoPopulateTaskDaysId)
        {
            string[] times = item.Text.Replace(" to ", "|").Split('|');

            // Sanity check
            if (times.Length != 2)
            {
                return 0;
            }

            SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_AUTO_InsertAutoPopulateTaskDaysStartStopTime", con);
            _sqlCommand.CommandType = CommandType.StoredProcedure;

            long _recordId = 0;
            long.TryParse(item.Value, out _recordId);

            _sqlCommand.Parameters.AddWithValue("@recordId", _recordId);
            _sqlCommand.Parameters.AddWithValue("@autoPopulateTaskDaysId", HiddenFieldAutoPopulateTaskDaysId.Value);
            _sqlCommand.Parameters.AddWithValue("@starttime", times[0]);
            _sqlCommand.Parameters.AddWithValue("@stoptime", times[1]);
            _sqlCommand.Parameters.Add("@Id", SqlDbType.BigInt);
            _sqlCommand.Parameters["@Id"].Direction = ParameterDirection.Output;

            _sqlCommand.ExecuteNonQuery();

            item.Value = _sqlCommand.Parameters["@Id"].Value.ToString();

            return long.Parse(item.Value);
        }

        private void InsertUpdateTaskHoursMinutes(ListBox listBoxClients, 
            Label labelTaskName, 
            HiddenField HiddenFieldAutoPopulateTaskDetailsId,
            HiddenField HiddenFieldTaskId,
            RepeaterItem rptItem,
            SqlConnection con)
        {
            string _errMsg = string.Empty;
            string _errMsg2 = string.Empty;

            TextBox textBoxHoursSunday = textBoxHoursSunday = (TextBox)rptItem.FindControl("textBoxHoursSunday");
            textBoxHoursSunday.Text = string.IsNullOrEmpty(textBoxHoursSunday.Text) ? "0" : textBoxHoursSunday.Text; 

            TextBox textBoxHoursMonday = textBoxHoursMonday = (TextBox)rptItem.FindControl("textBoxHoursMonday");
            textBoxHoursMonday.Text = string.IsNullOrEmpty(textBoxHoursMonday.Text) ? "0" : textBoxHoursMonday.Text;

            TextBox textBoxHoursTuesday = textBoxHoursTuesday = (TextBox)rptItem.FindControl("textBoxHoursTuesday");
            textBoxHoursTuesday.Text = string.IsNullOrEmpty(textBoxHoursTuesday.Text) ? "0" : textBoxHoursTuesday.Text; 

            TextBox textBoxHoursWednesday = textBoxHoursWednesday = (TextBox)rptItem.FindControl("textBoxHoursWednesday");
            textBoxHoursWednesday.Text = string.IsNullOrEmpty(textBoxHoursWednesday.Text) ? "0" : textBoxHoursWednesday.Text;

            TextBox textBoxHoursThursday = textBoxHoursThursday = (TextBox)rptItem.FindControl("textBoxHoursThursday");
            textBoxHoursThursday.Text = string.IsNullOrEmpty(textBoxHoursThursday.Text) ? "0" : textBoxHoursThursday.Text;

            TextBox textBoxHoursFriday = textBoxHoursFriday = (TextBox)rptItem.FindControl("textBoxHoursFriday");
            textBoxHoursFriday.Text = string.IsNullOrEmpty(textBoxHoursFriday.Text) ? "0" : textBoxHoursFriday.Text;

            TextBox textBoxHoursSaturday = textBoxHoursSaturday = (TextBox)rptItem.FindControl("textBoxHoursSaturday");
            textBoxHoursSaturday.Text = string.IsNullOrEmpty(textBoxHoursSaturday.Text) ? "0" : textBoxHoursSaturday.Text;

            TextBox textBoxMinutesSunday = textBoxMinutesSunday = (TextBox)rptItem.FindControl("textBoxMinutesSunday");
            textBoxMinutesSunday.Text = string.IsNullOrEmpty(textBoxMinutesSunday.Text) ? "0" : textBoxMinutesSunday.Text;

            TextBox textBoxMinutesMonday = textBoxMinutesMonday = (TextBox)rptItem.FindControl("textBoxMinutesMonday");
            textBoxMinutesMonday.Text = string.IsNullOrEmpty(textBoxMinutesMonday.Text) ? "0" : textBoxMinutesMonday.Text;

            TextBox textBoxMinutesTuesday = textBoxMinutesTuesday = (TextBox)rptItem.FindControl("textBoxMinutesTuesday");
            textBoxMinutesTuesday.Text = string.IsNullOrEmpty(textBoxMinutesTuesday.Text) ? "0" : textBoxMinutesTuesday.Text;

            TextBox textBoxMinutesWednesday = textBoxMinutesWednesday = (TextBox)rptItem.FindControl("textBoxMinutesWednesday");
            textBoxMinutesWednesday.Text = string.IsNullOrEmpty(textBoxMinutesWednesday.Text) ? "0" : textBoxMinutesWednesday.Text;

            TextBox textBoxMinutesThursday = textBoxMinutesThursday = (TextBox)rptItem.FindControl("textBoxMinutesThursday");
            textBoxMinutesThursday.Text = string.IsNullOrEmpty(textBoxMinutesThursday.Text) ? "0" : textBoxMinutesThursday.Text;

            TextBox textBoxMinutesFriday = textBoxMinutesFriday = (TextBox)rptItem.FindControl("textBoxMinutesFriday");
            textBoxMinutesFriday.Text = string.IsNullOrEmpty(textBoxMinutesFriday.Text) ? "0" : textBoxMinutesFriday.Text;

            TextBox textBoxMinutesSaturday = textBoxMinutesSaturday = (TextBox)rptItem.FindControl("textBoxMinutesSaturday");
            textBoxMinutesSaturday.Text = string.IsNullOrEmpty(textBoxMinutesSaturday.Text) ? "0" : textBoxMinutesSaturday.Text;

            int hoursSunday = 0;
            int minutesSunday = 0;
            int hoursMonday = 0;
            int minutesMonday = 0;
            int hoursTuesday = 0;
            int minutesTuesday = 0;
            int hoursWednesday = 0;
            int minutesWednesday = 0;
            int hoursThursday = 0;
            int minutesThursday = 0;
            int hoursFriday = 0;
            int minutesFriday = 0;
            int hoursSaturday = 0;
            int minutesSaturday = 0;

            long _id = 0;

            if (!string.IsNullOrEmpty(_errMsg2 = ValidateTimeEntry(textBoxHoursSunday, textBoxMinutesSunday, "Sunday", labelTaskName, out hoursSunday, out minutesSunday)))
            {
                _errMsg += _errMsg2;
            }
            if (!string.IsNullOrEmpty(_errMsg2 = ValidateTimeEntry(textBoxHoursMonday, textBoxMinutesMonday, "Monday", labelTaskName, out hoursMonday, out minutesMonday)))
            {
                _errMsg += _errMsg2;
            }
            if (!string.IsNullOrEmpty(_errMsg2 = ValidateTimeEntry(textBoxHoursTuesday, textBoxMinutesTuesday, "Tuesday", labelTaskName, out hoursTuesday, out minutesTuesday)))
            {
                _errMsg += _errMsg2;
            }
            if (!string.IsNullOrEmpty(_errMsg2 = ValidateTimeEntry(textBoxHoursWednesday, textBoxMinutesWednesday, "Wednesday", labelTaskName, out hoursWednesday, out minutesWednesday)))
            {
                _errMsg += _errMsg2;
            }
            if (!string.IsNullOrEmpty(_errMsg2 = ValidateTimeEntry(textBoxHoursThursday, textBoxMinutesThursday, "Thurday", labelTaskName, out hoursThursday, out minutesThursday)))
            {
                _errMsg += _errMsg2;
            }
            if (!string.IsNullOrEmpty(_errMsg2 = ValidateTimeEntry(textBoxHoursFriday, textBoxMinutesFriday, "Friday", labelTaskName, out hoursFriday, out minutesFriday)))
            {
                _errMsg += _errMsg2;
            }
            if (!string.IsNullOrEmpty(_errMsg2 = ValidateTimeEntry(textBoxHoursSaturday, textBoxMinutesSaturday, "Saturday", labelTaskName, out hoursSaturday, out minutesSaturday)))
            {
                _errMsg += _errMsg2;
            }
            // If multipile,  make sure at least one itme is selected
            if (listBoxClients.SelectionMode == ListSelectionMode.Multiple && listBoxClients.GetSelectedIndices().Length != 0 &&
                hoursSunday != 0 && minutesSunday != 0 && hoursMonday != 0 && minutesMonday != 0 &&
                                hoursTuesday != 0 && minutesTuesday != 0 && hoursWednesday != 0 && minutesWednesday != 0 &&
                                hoursThursday != 0 && minutesThursday != 0 &&
                                hoursFriday != 0 && minutesFriday != 0 && hoursSaturday != 0 && minutesSaturday != 0)
            {
                _errMsg += "<br/>" + labelTaskName.Text + " - For multiple clients you must select at least one client";
            }

            // ONly do the DB task if there was no error at this point and some hours or minutes have been specified for one of the days
            if (string.IsNullOrEmpty(_errMsg))
            {
                // Check if record exist in DB
                if (AutoPopulateTaskDetailsRecordExist(con, HiddenFieldAutoPopulateTaskTemplateId.Value, HiddenFieldTaskId.Value, out _id))
                {
                    if (listBoxClients.SelectionMode == ListSelectionMode.Single)
                    {
                        // Set listBoxClients to 0 if all day values are 0
                        if (hoursSunday == 0 && minutesSunday == 0 && hoursMonday == 0 && minutesMonday == 0 &&
                                hoursTuesday == 0 && minutesTuesday == 0 && hoursWednesday == 0 && minutesWednesday == 0 &&
                                hoursThursday == 0 && minutesThursday == 0 &&
                                hoursFriday == 0 && minutesFriday == 0 && hoursSaturday == 0 && minutesSaturday == 0)
                        {
                            listBoxClients.SelectedValue = "0";
                        }
                        UpdateTaskDetailRecord(con, _id, long.Parse(listBoxClients.SelectedValue));
                        UpdateTaskRecordDay(con, _id, hoursSunday, minutesSunday, hoursMonday, minutesMonday
                                , hoursTuesday, minutesTuesday, hoursWednesday, minutesWednesday, hoursThursday, minutesThursday,
                                hoursFriday, minutesFriday, hoursSaturday, minutesSaturday, true);
                    }
                    else
                    {
                        // Set listBoxClients to 0 if all day values are 0
                        if (hoursSunday == 0 && minutesSunday == 0 && hoursMonday == 0 && minutesMonday == 0 &&
                                hoursTuesday == 0 && minutesTuesday == 0 && hoursWednesday == 0 && minutesWednesday == 0 &&
                                hoursThursday == 0 && minutesThursday == 0 &&
                                hoursFriday == 0 && minutesFriday == 0 && hoursSaturday == 0 && minutesSaturday == 0)
                        {
                            listBoxClients.ClearSelection();
                        }
                        RemoveAndReAddMultipleClientTaskDetailRecord(con, HiddenFieldAutoPopulateTaskDetailsId, ref _id, HiddenFieldAutoPopulateTaskTemplateId.Value, HiddenFieldTaskId.Value,
                            listBoxClients, hoursSunday, minutesSunday, hoursMonday, minutesMonday
                                , hoursTuesday, minutesTuesday, hoursWednesday, minutesWednesday, hoursThursday, minutesThursday,
                                hoursFriday, minutesFriday, hoursSaturday, minutesSaturday);
                    }
                }
                // if record does not exist hours needs to be specified
                else
                {
                    if (listBoxClients.SelectionMode == ListSelectionMode.Single)
                    {
                        InsertTaskDetailRecordSingleClient(con, HiddenFieldAutoPopulateTaskDetailsId, HiddenFieldAutoPopulateTaskTemplateId.Value, listBoxClients
                            , HiddenFieldTaskId.Value, hoursSunday, minutesSunday, hoursMonday, minutesMonday
                            , hoursTuesday, minutesTuesday, hoursWednesday, minutesWednesday, hoursThursday, minutesThursday,
                            hoursFriday, minutesFriday, hoursSaturday, minutesSaturday);
                    }
                    else
                    {
                        InsertTaskDetailRecordMultipleClient(con, HiddenFieldAutoPopulateTaskDetailsId, HiddenFieldAutoPopulateTaskTemplateId.Value, listBoxClients
                            , HiddenFieldTaskId.Value, hoursSunday, minutesSunday, hoursMonday, minutesMonday
                            , hoursTuesday, minutesTuesday, hoursWednesday, minutesWednesday, hoursThursday, minutesThursday,
                            hoursFriday, minutesFriday, hoursSaturday, minutesSaturday);
                    }
                }
            }
            else
            {
                LabelProblem.Text += _errMsg;
                _errMsg = string.Empty;
            }

        }
        private string ValidateTimeEntry(TextBox textBoxHours, TextBox textBoxMinutes, string day, Label labelTaskName, out int hours, out int minutes)
        {
            string _errMsg = string.Empty;
            hours = 0;
            minutes = 0;

            try
            {
                // If spaces or emptyentered set to 0 for hours and minutes
                if (string.IsNullOrEmpty(textBoxHours.Text.Trim()))
                {
                    textBoxHours.Text = "0";
                }
                if (string.IsNullOrEmpty(textBoxMinutes.Text.Trim()))
                {
                    textBoxMinutes.Text = "0";
                }

                hours = int.Parse(textBoxHours.Text);
                minutes = int.Parse(textBoxMinutes.Text);

                // Verify valid time values
                if (hours < 0 || hours > 23)
                {
                    _errMsg += "<br/>" + labelTaskName.Text + " " + day + " - hours must be a value between 0 to 23";
                    textBoxHours.Text = "0";
                }
                if (minutes < 0 || minutes > 59)
                {
                    _errMsg += "<br/>" + labelTaskName.Text + " " + day + " - minutes must be a value between 0 to 59";
                    textBoxMinutes.Text = "0";
                }
            }
            catch(Exception error)
            {
                _errMsg += "<br/>" + labelTaskName.Text + " " + day + " - " + error.Message;
                textBoxHours.Text = "0";
                textBoxMinutes.Text = "0";
            }

            return _errMsg;
        }

        private long InsertTaskDetailRecordSingleClient(SqlConnection con, HiddenField HiddenFieldAutoPopulateTaskDetailsId, string autoPopulateTaskTemplateId, ListBox listBoxClients,
            string timeentrytaskid, int hoursSunday, int minutesSunday, int hoursMonday, int minutesMonday,
            int hoursTuesday, int minutesTuesday, int hoursWednesday, int minutesWednesday, int hoursThursday, int minutesThursday,
            int hoursFriday, int minutesFriday, int hoursSaturday, int minutesSaturday)
        {
            long _autoPopulateTaskDetailsId = InsertAutoPopulateTaskDetails(con, HiddenFieldAutoPopulateTaskDetailsId, autoPopulateTaskTemplateId, timeentrytaskid, listBoxClients.SelectedValue);

            UpdateTaskRecordDay(con, _autoPopulateTaskDetailsId, hoursSunday, minutesSunday, hoursMonday, minutesMonday,
                hoursTuesday, minutesTuesday, hoursWednesday, minutesWednesday, hoursThursday, minutesThursday,
                hoursFriday, minutesFriday, hoursSaturday, minutesSaturday, false);

            return _autoPopulateTaskDetailsId;
        }

        private List<long> InsertTaskDetailRecordMultipleClient(SqlConnection con, HiddenField HiddenFieldAutoPopulateTaskDetailsId, string autoPopulateTaskTemplateId, ListBox listBoxClients,
            string timeentrytaskid, int hoursSunday, int minutesSunday, int hoursMonday, int minutesMonday,
            int hoursTuesday, int minutesTuesday, int hoursWednesday, int minutesWednesday, int hoursThursday, int minutesThursday,
            int hoursFriday, int minutesFriday, int hoursSaturday, int minutesSaturday)
        {
            List<long> _listAutoPupolateTaskDetailsId = InsertMultipleAutoPopulateTaskDetails(con, HiddenFieldAutoPopulateTaskDetailsId, autoPopulateTaskTemplateId, timeentrytaskid, listBoxClients);
            bool _firstTime = true;

            foreach (long _autoPopulateTaskDetailsId in _listAutoPupolateTaskDetailsId)
            {
                UpdateTaskRecordDay(con, _autoPopulateTaskDetailsId, hoursSunday, minutesSunday, hoursMonday, minutesMonday,
                    hoursTuesday, minutesTuesday, hoursWednesday, minutesWednesday, hoursThursday, minutesThursday,
                    hoursFriday, minutesFriday, hoursSaturday, minutesSaturday, false, true, _firstTime);
                if (_firstTime)
                    _firstTime = false;
            }

            return _listAutoPupolateTaskDetailsId;
        }
        private List<long> InsertMultipleAutoPopulateTaskDetails(SqlConnection con, HiddenField HiddenFieldAutoPopulateTaskDetailsId, string autoPopulateTaskTemplateId, string timeentrytaskid, ListBox listBoxClients)
        {
            ListItem _item = null;
            List<long> _autoPopualteTaskDetailsList = new List<long>();

            foreach(int _index in listBoxClients.GetSelectedIndices())
            {
                _item = listBoxClients.Items[_index];

                _autoPopualteTaskDetailsList.Add(InsertAutoPopulateTaskDetails(con, HiddenFieldAutoPopulateTaskDetailsId, autoPopulateTaskTemplateId, timeentrytaskid, _item.Value));
            }

            return _autoPopualteTaskDetailsList;
        }
        private long InsertAutoPopulateTaskDetails(SqlConnection con, HiddenField HiddenFieldAutoPopulateTaskDetailsId, string autoPopulateTaskTemplateId, string timeentrytaskid, string clientId)
        {
            SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_TIMESHEET_InsertAutoPopulateTaskDetails", con);
            _sqlCommand.CommandType = CommandType.StoredProcedure;
            _sqlCommand.Parameters.AddWithValue("@autoPopulateTaskTemplateId", autoPopulateTaskTemplateId);
            _sqlCommand.Parameters.AddWithValue("@timeentrytaskid", timeentrytaskid);

            if (clientId == "0")
            {
                SqlParameter _parameter = new SqlParameter("@clientid", SqlDbType.BigInt);
                _parameter.Value = DBNull.Value;
                _sqlCommand.Parameters.Add(_parameter);
            }
            else
            {
                _sqlCommand.Parameters.AddWithValue("@clientid", clientId);
            }

            _sqlCommand.Parameters.Add("@Id", SqlDbType.BigInt);
            _sqlCommand.Parameters["@Id"].Direction = ParameterDirection.Output;

            _sqlCommand.ExecuteNonQuery();

            long _id = long.Parse(_sqlCommand.Parameters["@Id"].Value.ToString());

            if (!string.IsNullOrEmpty(HiddenFieldAutoPopulateTaskDetailsId.Value))
            {
                HiddenFieldAutoPopulateTaskDetailsId.Value = _id.ToString();
            }

            return _id;
        }

        private void RemoveAndReAddMultipleClientTaskDetailRecord(SqlConnection con, HiddenField HiddenFieldAutoPopulateTaskDetailsId, ref long autoPopulateTaskDetailsId, string autoPopulateTaskTemplateId, 
            string timeEntryTaskId, ListBox listBoxClients, int hoursSunday, int minutesSunday, int hoursMonday, int minutesMonday,
            int hoursTuesday, int minutesTuesday, int hoursWednesday, int minutesWednesday, int hoursThursday, int minutesThursday,
            int hoursFriday, int minutesFriday, int hoursSaturday, int minutesSaturday)
        {
            // Delete existing records and reinsert detail records
            DeleteTaskDetailRecordForMultipleClients(con, autoPopulateTaskTemplateId, timeEntryTaskId);
            InsertTaskDetailRecordMultipleClient(con, HiddenFieldAutoPopulateTaskDetailsId, HiddenFieldAutoPopulateTaskTemplateId.Value, listBoxClients, timeEntryTaskId, hoursSunday, minutesSunday, hoursMonday, minutesMonday
                    , hoursTuesday, minutesTuesday, hoursWednesday, minutesWednesday, hoursThursday, minutesThursday,
                    hoursFriday, minutesFriday, hoursSaturday, minutesSaturday);
        }
        private void UpdateTaskDetailRecord(SqlConnection con, long autoPopulateTaskDetailsId, long clientId)
        {
            SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_TIMESHEET_UpdateAutoPopulateTaskDetails", con);
            _sqlCommand.CommandType = CommandType.StoredProcedure;
            _sqlCommand.Parameters.AddWithValue("@Id", autoPopulateTaskDetailsId);

            if (clientId == 0)
            {
                SqlParameter _parameter = new SqlParameter("@clientid", SqlDbType.BigInt);
                _parameter.Value = DBNull.Value;
                _sqlCommand.Parameters.Add(_parameter);
            }
            else
            {
                _sqlCommand.Parameters.AddWithValue("@clientid", clientId);
            }

            _sqlCommand.ExecuteNonQuery();

        }
        private void ProcessTaskDaysSelection(SqlConnection con, int hours, int minutes, int daysId, long autoPopulateTaskDetailsId, bool checkToDeleteTaskDays,
            bool isMultipleClient, bool isFirstClient = false)
        {
            if (hours > 0 || minutes > 0)
            {
                // For Multiple Clients 
                if (isMultipleClient && !isFirstClient)
                {
                    hours = 0;
                    minutes = 0;
                }
     
                InsertOrUpdateAutoPopulateTaskDays(con, daysId, autoPopulateTaskDetailsId, hours, minutes);
            }
            else if (checkToDeleteTaskDays)
            {
                DeleteTaskDaysIfNeeded(con, daysId, autoPopulateTaskDetailsId);
            }
        }
        private void UpdateTaskRecordDay(SqlConnection con, long autoPopulateTaskDetailsId, int hoursSunday, int minutesSunday, int hoursMonday, int minutesMonday,
            int hoursTuesday, int minutesTuesday, int hoursWednesday, int minutesWednesday, int hoursThursday, int minutesThursday,
            int hoursFriday, int minutesFriday, int hoursSaturday, int minutesSaturday, bool checkToDeleteTaskDays,
            bool isMultipleClient = false, bool firstTimeForMultiple = true)
        {
            for(int _daysId = 0; _daysId < 7; ++_daysId)
            {
                switch(_daysId)
                {
                    case 0:
                        if (!isMultipleClient)
                        {
                            ProcessTaskDaysSelection(con, hoursSunday, minutesSunday, _daysId, autoPopulateTaskDetailsId, checkToDeleteTaskDays, isMultipleClient);
                        }
                        else 
                        {
                            // If you get here you should be multiple client 
                            ProcessTaskDaysSelection(con, hoursSunday, minutesSunday, _daysId, autoPopulateTaskDetailsId, checkToDeleteTaskDays, isMultipleClient, firstTimeForMultiple);
                        }
                        break;
                    case 1:
                        if (!isMultipleClient)
                        {
                            ProcessTaskDaysSelection(con, hoursMonday, minutesMonday, _daysId, autoPopulateTaskDetailsId, checkToDeleteTaskDays, isMultipleClient);
                        }
                        else 
                        {
                            // If you get here you should be multiple client 
                            ProcessTaskDaysSelection(con, hoursMonday, minutesMonday, _daysId, autoPopulateTaskDetailsId, checkToDeleteTaskDays, isMultipleClient, firstTimeForMultiple);
                        }
                        break;
                    case 2:
                        if (!isMultipleClient)
                        {
                            ProcessTaskDaysSelection(con, hoursTuesday, minutesTuesday, _daysId, autoPopulateTaskDetailsId, checkToDeleteTaskDays, isMultipleClient);
                        }
                        else 
                        {
                            // If you get here you should be multiple client 
                            ProcessTaskDaysSelection(con, hoursTuesday, minutesTuesday, _daysId, autoPopulateTaskDetailsId, checkToDeleteTaskDays, isMultipleClient, firstTimeForMultiple);
                        }
                        break;
                    case 3:
                        if (!isMultipleClient)
                        {
                            ProcessTaskDaysSelection(con, hoursWednesday, minutesWednesday, _daysId, autoPopulateTaskDetailsId, checkToDeleteTaskDays, isMultipleClient);
                        }
                        else 
                        {
                            // If you get here you should be multiple client 
                            ProcessTaskDaysSelection(con, hoursWednesday, minutesWednesday, _daysId, autoPopulateTaskDetailsId, checkToDeleteTaskDays, isMultipleClient, firstTimeForMultiple);
                        }
                        break;
                    case 4:
                        if (!isMultipleClient)
                        {
                            ProcessTaskDaysSelection(con, hoursThursday, minutesThursday, _daysId, autoPopulateTaskDetailsId, checkToDeleteTaskDays, isMultipleClient);
                        }
                        else 
                        {
                            // If you get here you should be multiple client 
                            ProcessTaskDaysSelection(con, hoursThursday, minutesThursday, _daysId, autoPopulateTaskDetailsId, checkToDeleteTaskDays, isMultipleClient, firstTimeForMultiple);
                        }
                        break;
                    case 5:
                        if (!isMultipleClient)
                        {
                            ProcessTaskDaysSelection(con, hoursFriday, minutesFriday, _daysId, autoPopulateTaskDetailsId, checkToDeleteTaskDays, isMultipleClient);
                        }
                        else 
                        {
                            // If you get here you should be multiple client 
                            ProcessTaskDaysSelection(con, hoursFriday, minutesFriday, _daysId, autoPopulateTaskDetailsId, checkToDeleteTaskDays, isMultipleClient, firstTimeForMultiple);
                        }
                        break;
                    case 6:
                        if (!isMultipleClient)
                        {
                            ProcessTaskDaysSelection(con, hoursSaturday, minutesSaturday, _daysId, autoPopulateTaskDetailsId, checkToDeleteTaskDays, isMultipleClient);
                        }
                        else 
                        {
                            // If you get here you should be multiple client 
                            ProcessTaskDaysSelection(con, hoursSaturday, minutesSaturday, _daysId, autoPopulateTaskDetailsId, checkToDeleteTaskDays, isMultipleClient, firstTimeForMultiple);
                        }
                        break;
                }
            }
        }

        private long InsertOrUpdateAutoPopulateTaskDays(SqlConnection con, int daysId, long autoPopulateTaskDetailsId, int hours, int minutes)
        {
            int _numberOfMinutes = hours * 60 + minutes;

            SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_TIMESHEET_InsertAutoPopulateTaskDays", con);
            _sqlCommand.CommandType = CommandType.StoredProcedure;
            _sqlCommand.Parameters.AddWithValue("@dayid", daysId);
            _sqlCommand.Parameters.AddWithValue("@autoPopulateTaskDetailsId", autoPopulateTaskDetailsId);
            _sqlCommand.Parameters.AddWithValue("@numberOfMinutes", _numberOfMinutes);
            _sqlCommand.Parameters.Add("@Id", SqlDbType.BigInt);
            _sqlCommand.Parameters["@Id"].Direction = ParameterDirection.Output;

            _sqlCommand.ExecuteNonQuery();

            return long.Parse(_sqlCommand.Parameters["@Id"].Value.ToString());
        }
        private void DeleteTaskDaysIfNeeded(SqlConnection con, int daysId, long autoPopulateTaskDetailsId)
        {
            SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_TIMESHEET_DeleteAutoPopulateTaskDays", con);
            _sqlCommand.CommandType = CommandType.StoredProcedure;
            _sqlCommand.Parameters.AddWithValue("@dayid", daysId);
            _sqlCommand.Parameters.AddWithValue("@autoPopulateTaskDetailsId", autoPopulateTaskDetailsId);

            _sqlCommand.ExecuteNonQuery();

        }
        private void DeleteTaskDetailRecordForMultipleClients(SqlConnection con, string autoPopulateTaskTemplateId, string timeentrytaskid)
        {
            SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_TIMESHEET_DeleteAutoPopulateTaskDetails", con);
            _sqlCommand.CommandType = CommandType.StoredProcedure;
            _sqlCommand.Parameters.AddWithValue("@autoPopulateTaskTemplateId", autoPopulateTaskTemplateId);
            _sqlCommand.Parameters.AddWithValue("@timeentrytaskid", timeentrytaskid);

            _sqlCommand.ExecuteNonQuery();
        }
        private bool AutoPopulateTaskDetailsRecordExist(SqlConnection con, string autoPopulateTaskTemplateId, string timeEntryTaskId, out long id)
        {
            id = 0;
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetAutoPopulateTaskDetails", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;

            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@autoPopulateTaskTemplateId", autoPopulateTaskTemplateId);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@timeEntryTaskId", timeEntryTaskId);

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            if (_dataTable.Rows.Count > 0)
            {
                DataRow _dataRow = _dataTable.Rows[0];
                id = long.Parse(_dataRow["id"].ToString());

                return true;
            }
            return false;
        }
        private void SetAutoStopStartModalDialog(ListBox listBox, HiddenField HiddenFieldTaskId, string day)
        {
            string _startStopTimes = string.Empty;

            foreach (ListItem _item in listBox.Items)
            {
                _startStopTimes += (string.IsNullOrEmpty(_startStopTimes) ? string.Empty : "|")
                    + _item.Value;
                _startStopTimes += "-" + _item.Text.Replace(" to ", "-");
            }
            HiddenFieldStopStartTaskId.Value = HiddenFieldTaskId.Value;
            HiddenFieldTaskStartStop.Value = _startStopTimes;
            HiddenFieldTaskStartStopDay.Value = day;
        }
        protected void ButtonStartStopSunday_Click(object sender, EventArgs e)
        {
            labelMessage.Text = string.Empty;
            divModal.Visible = true;
            RepeaterItem item = ((sender as Button).NamingContainer as RepeaterItem);
            ListBox listBoxStartStopSunday = (ListBox)item.FindControl("listBoxStartStopSunday");
            HiddenField HiddenFieldTaskId = (HiddenField)item.FindControl("HiddenFieldTaskId");
            string _startStopTimes = string.Empty;

            if (listBoxStartStopSunday.Items.Count == 0)
            {
                btnClose.Text = "Add Start and Stop Times";
            }
            else
            {
                btnClose.Text = "Add, Modify, or Delete Start Stop Times";
            }

            SetAutoStopStartModalDialog(listBoxStartStopSunday, HiddenFieldTaskId, "sunday");
            LoadStartStop();
        }
        protected void ButtonStartStopMonday_Click(object sender, EventArgs e)
        {
            labelMessage.Text = string.Empty;
            divModal.Visible = true;
            RepeaterItem item = ((sender as Button).NamingContainer as RepeaterItem);
            ListBox listBoxStartStopMonday = (ListBox)item.FindControl("listBoxStartStopMonday");
            HiddenField HiddenFieldTaskId = (HiddenField)item.FindControl("HiddenFieldTaskId");

            if (listBoxStartStopMonday.Items.Count == 0)
            {
                btnClose.Text = "Add Start and Stop Times";
            }
            else
            {
                btnClose.Text = "Add, Modify, or Delete Start Stop Times";
            }

            SetAutoStopStartModalDialog(listBoxStartStopMonday, HiddenFieldTaskId, "monday");
            LoadStartStop();
        }

        protected void ButtonStartStopTuesday_Click(object sender, EventArgs e)
        {
            labelMessage.Text = string.Empty;
            divModal.Visible = true;
            RepeaterItem item = ((sender as Button).NamingContainer as RepeaterItem);
            ListBox listBoxStartStopTuesday = (ListBox)item.FindControl("listBoxStartStopTuesday");
            HiddenField HiddenFieldTaskId = (HiddenField)item.FindControl("HiddenFieldTaskId");

            if (listBoxStartStopTuesday.Items.Count == 0)
            {
                btnClose.Text = "Add Start and Stop Times";
            }
            else
            {
                btnClose.Text = "Add, Modify, or Delete Start Stop Times";
            }

            SetAutoStopStartModalDialog(listBoxStartStopTuesday, HiddenFieldTaskId, "tuesday");
            LoadStartStop();
        }

        protected void ButtonStartStopWednesday_Click(object sender, EventArgs e)
        {
            labelMessage.Text = string.Empty;
            divModal.Visible = true;
            RepeaterItem item = ((sender as Button).NamingContainer as RepeaterItem);
            ListBox listBoxStartStopWednesday = (ListBox)item.FindControl("listBoxStartStopWednesday");
            HiddenField HiddenFieldTaskId = (HiddenField)item.FindControl("HiddenFieldTaskId");

            if (listBoxStartStopWednesday.Items.Count == 0)
            {
                btnClose.Text = "Add Start and Stop Times";
            }
            else
            {
                btnClose.Text = "Add, Modify, or Delete Start Stop Times";
            }

            SetAutoStopStartModalDialog(listBoxStartStopWednesday, HiddenFieldTaskId, "wednesday");
            LoadStartStop();
        }

        protected void ButtonStartStopThursday_Click(object sender, EventArgs e)
        {
            labelMessage.Text = string.Empty;
            divModal.Visible = true;
            RepeaterItem item = ((sender as Button).NamingContainer as RepeaterItem);
            ListBox listBoxStartStopThursday = (ListBox)item.FindControl("listBoxStartStopThursday");
            HiddenField HiddenFieldTaskId = (HiddenField)item.FindControl("HiddenFieldTaskId");

            if (listBoxStartStopThursday.Items.Count == 0)
            {
                btnClose.Text = "Add Start and Stop Times";
            }
            else
            {
                btnClose.Text = "Add, Modify, or Delete Start Stop Times";
            }

            SetAutoStopStartModalDialog(listBoxStartStopThursday, HiddenFieldTaskId, "thursday");
            LoadStartStop();
        }

        protected void ButtonStartStopFriday_Click(object sender, EventArgs e)
        {
            labelMessage.Text = string.Empty;
            divModal.Visible = true;
            RepeaterItem item = ((sender as Button).NamingContainer as RepeaterItem);
            ListBox listBoxStartStopFriday = (ListBox)item.FindControl("listBoxStartStopFriday");
            HiddenField HiddenFieldTaskId = (HiddenField)item.FindControl("HiddenFieldTaskId");

            if (listBoxStartStopFriday.Items.Count == 0)
            {
                btnClose.Text = "Add Start and Stop Times";
            }
            else
            {
                btnClose.Text = "Add, Modify, or Delete Start Stop Times";
            }

            SetAutoStopStartModalDialog(listBoxStartStopFriday, HiddenFieldTaskId, "friday");
            LoadStartStop();
        }

        protected void ButtonStartStopSaturday_Click(object sender, EventArgs e)
        {
            labelMessage.Text = string.Empty;
            divModal.Visible = true;
            RepeaterItem item = ((sender as Button).NamingContainer as RepeaterItem);
            ListBox listBoxStartStopSaturday = (ListBox)item.FindControl("listBoxStartStopSaturday");
            HiddenField HiddenFieldTaskId = (HiddenField)item.FindControl("HiddenFieldTaskId");

            if (listBoxStartStopSaturday.Items.Count == 0)
            {
                btnClose.Text = "Add Start and Stop Times";
            }
            else
            {
                btnClose.Text = "Add, Modify, or Delete Start Stop Times";
            }

            SetAutoStopStartModalDialog(listBoxStartStopSaturday, HiddenFieldTaskId, "saturday");
            LoadStartStop();
        }
        protected void CloseModal(object sender, EventArgs e)
        {
            TextBox labelBoxStartTime;
            TextBox labelBoxStopTime;
            HiddenField HiddenFieldDialogStopStartTimeId;
            string _startStopTimes = string.Empty;

            foreach (RepeaterItem rptItem in repeaterTaskStartStopTemplateControl.Items)
            {
                HiddenFieldDialogStopStartTimeId = (HiddenField)rptItem.FindControl("HiddenFieldDialogStopStartTimeId");
                labelBoxStartTime = (TextBox)rptItem.FindControl("labelBoxStartTime");
                labelBoxStopTime = (TextBox)rptItem.FindControl("labelBoxStopTime");

                if (labelBoxStartTime == null ||
                    labelBoxStopTime == null ||
                    string.IsNullOrEmpty(labelBoxStartTime.Text) ||
                    string.IsNullOrEmpty(labelBoxStopTime.Text))
                {
                    continue;
                }
                _startStopTimes += (string.IsNullOrEmpty(_startStopTimes) ? string.Empty : "|") +
                    (string.IsNullOrEmpty(HiddenFieldDialogStopStartTimeId.Value) ? labelBoxStartTime.Text + labelBoxStopTime.Text : HiddenFieldDialogStopStartTimeId.Value) + 
                    "-" + labelBoxStartTime.Text + "-" + labelBoxStopTime.Text;
            }
            HiddenFieldTaskStartStop.Value = _startStopTimes;
            PopulateListBoxStopStartTime();
            divModal.Visible = false;
        }
        private void PopulateListBoxStopStartTime()
        {
            bool startStopTimePresent = string.IsNullOrEmpty(HiddenFieldStopStartTaskId.Value) ?
                false : true;

            if (!startStopTimePresent)
            {
                return;
            }
            HiddenField HiddenFieldTaskId = null;

            foreach (RepeaterItem rptItem in repeaterTaskTemplateControl.Items)
            {
                HiddenFieldTaskId = (HiddenField)rptItem.FindControl("HiddenFieldTaskId");
                if (HiddenFieldTaskId.Value == HiddenFieldStopStartTaskId.Value)
                {
                    PopulateStartStopTask(rptItem);
                    break;
                }
            }
        }
        private void LoadStartStop()
        {
            string[] _stopStartTimes = HiddenFieldTaskStartStop.Value.Split('|');
            int _length = _stopStartTimes.Length;
            int _lengthRecord = 0;
            string _record;
            string[] _recordField;
            List<AutoTaskStartStopTime> _listStartStop = new List<AutoTaskStartStopTime>();
            AutoTaskStartStopTime _autoStartStop = null;

            for (int _counter = 0; _counter < _length; _counter++)
            {
                _record = _stopStartTimes[_counter];
                if (string.IsNullOrEmpty(_record.Trim()))
                {
                    continue;
                }
                _recordField = _record.Split('-');
                _lengthRecord = _recordField.Length;
                _autoStartStop = new AutoTaskStartStopTime();
                _autoStartStop.id = _recordField[0];
                _autoStartStop.startTime = _recordField[1];
                _autoStartStop.stopTime = _recordField[2];
                _listStartStop.Add(_autoStartStop);
            }
            repeaterTaskStartStopTemplateControl.DataSource = _listStartStop;
            repeaterTaskStartStopTemplateControl.DataBind();
        }
        protected void ButtonAdd_Click(object sender, EventArgs e)
        {
            List<AutoTaskStartStopTime> _listStartStopTime = new List<AutoTaskStartStopTime>();
            TextBox labelBoxStartTime;
            TextBox labelBoxStopTime;
            AutoTaskStartStopTime _autoStartStopTime = null;

            foreach (RepeaterItem _item in repeaterTaskStartStopTemplateControl.Items)
            {
                labelBoxStartTime = ((TextBox)_item.FindControl("labelBoxStartTime"));
                labelBoxStopTime = ((TextBox)_item.FindControl("labelBoxStopTime"));

                if ((labelBoxStartTime == null) || (labelBoxStopTime == null))
                {
                    continue;
                }
                _autoStartStopTime = new AutoTaskStartStopTime();
                _autoStartStopTime.id = labelBoxStartTime.Text + "|" + labelBoxStopTime.Text;
                _autoStartStopTime.startTime = labelBoxStartTime.Text;
                _autoStartStopTime.stopTime = labelBoxStopTime.Text;
                _listStartStopTime.Add(_autoStartStopTime);
            }
            _listStartStopTime.Add(new AutoTaskStartStopTime());

            repeaterTaskStartStopTemplateControl.DataSource = _listStartStopTime;
            repeaterTaskStartStopTemplateControl.DataBind();
        }
        protected void ButtonDelete_Click(object sender, EventArgs e)
        {
            RepeaterItem _item = ((sender as Button).NamingContainer as RepeaterItem);
            TextBox labelBoxStartTime = (TextBox)_item.FindControl("labelBoxStartTime");
            TextBox labelBoxStopTime = (TextBox)_item.FindControl("labelBoxStopTime");

            List<AutoTaskStartStopTime> _listAutoTaskStartStopTime = new List<AutoTaskStartStopTime>();
            TextBox labelBoxStartTimeInGrid = null;
            TextBox labelBoxStopTimeInGrid = null;

            foreach (RepeaterItem rptItem in repeaterTaskStartStopTemplateControl.Items)
            {
                labelBoxStartTimeInGrid = (TextBox)rptItem.FindControl("labelBoxStartTime");
                labelBoxStopTimeInGrid = (TextBox)rptItem.FindControl("labelBoxStopTime");

                if ((labelBoxStartTimeInGrid.Text == labelBoxStartTime.Text) &&
                    (labelBoxStopTimeInGrid.Text == labelBoxStopTime.Text))
                {
                    continue;
                }
                _listAutoTaskStartStopTime.Add(new AutoTaskStartStopTime()
                {
                    startTime = labelBoxStartTimeInGrid.Text,
                    stopTime = labelBoxStopTimeInGrid.Text
                });
            }

            repeaterTaskStartStopTemplateControl.DataSource = _listAutoTaskStartStopTime;
            repeaterTaskStartStopTemplateControl.DataBind();
        }
        protected void ImageButtonStartTime_Click(object sender, ImageClickEventArgs e)
        {
            RepeaterItem _item = ((sender as ImageButton).NamingContainer as RepeaterItem);
            Panel PanelPickStartTime = (Panel)_item.FindControl("PanelPickStartTime");
            PanelPickStartTime.Visible = !PanelPickStartTime.Visible;
            Panel PanelPickStopTime = (Panel)_item.FindControl("PanelPickStopTime");
            PanelPickStopTime.Visible = false;
        }

        protected void ImageButtonStopTime_Click(object sender, ImageClickEventArgs e)
        {
            RepeaterItem _item = ((sender as ImageButton).NamingContainer as RepeaterItem);
            Panel PanelPickStopTime = (Panel)_item.FindControl("PanelPickStopTime");
            PanelPickStopTime.Visible = !PanelPickStopTime.Visible;
            Panel PanelPickStartTime = (Panel)_item.FindControl("PanelPickStartTime");
            PanelPickStartTime.Visible = false;
        }

        protected void ButtonSelectStopTime_Click(object sender, EventArgs e)
        {
            RepeaterItem _item = ((sender as Button).NamingContainer as RepeaterItem);
            DropDownList DropDownListBoxHoursStop = (DropDownList)_item.FindControl("DropDownListBoxHoursStop");
            DropDownList DropDownListMinutesStop = (DropDownList)_item.FindControl("DropDownListMinutesStop");
            DropDownList DropDownListAMPMStop = (DropDownList)_item.FindControl("DropDownListAMPMStop");
            TextBox labelBoxStartTime = (TextBox)_item.FindControl("labelBoxStartTime");
            TextBox labelBoxStopTime = (TextBox)_item.FindControl("labelBoxStopTime");

            string stopTime = DropDownListBoxHoursStop.SelectedValue + ":" + DropDownListMinutesStop.SelectedValue + " "
                + DropDownListAMPMStop.SelectedValue;

            if (!EntryIsDuplicate(labelBoxStartTime.Text, stopTime))
            {
                labelBoxStopTime.Text = stopTime;
            }

            Panel PanelPickStopTime = (Panel)_item.FindControl("PanelPickStopTime");
            PanelPickStopTime.Visible = false;
        }
        protected void ButtonSelectStartTime_Click(object sender, EventArgs e)
        {
            RepeaterItem _item = ((sender as Button).NamingContainer as RepeaterItem);
            DropDownList DropDownListBoxHoursStart = (DropDownList)_item.FindControl("DropDownListBoxHoursStart");
            DropDownList DropDownListMinutesStart = (DropDownList)_item.FindControl("DropDownListMinutesStart");
            DropDownList DropDownListAMPMStart = (DropDownList)_item.FindControl("DropDownListAMPMStart");
            TextBox labelBoxStartTime = (TextBox)_item.FindControl("labelBoxStartTime");
            TextBox labelBoxStopTime = (TextBox)_item.FindControl("labelBoxStopTime");

            string startTime = DropDownListBoxHoursStart.SelectedValue + ":" + DropDownListMinutesStart.SelectedValue + " "
                + DropDownListAMPMStart.SelectedValue;

            if (!EntryIsDuplicate(startTime, labelBoxStopTime.Text))
            {
                labelBoxStartTime.Text = startTime;
            }

            Panel PanelPickStartTime = (Panel)_item.FindControl("PanelPickStartTime");
            PanelPickStartTime.Visible = false;
        }
        protected void ButtonBackToTaskTemplate_Click(object sender, EventArgs e)
        {
            TextBox labelBoxStartTime;
            TextBox labelBoxStopTime;
            string _startStopTimes = string.Empty;

            foreach (RepeaterItem rptItem in repeaterTaskStartStopTemplateControl.Items)
            {
                labelBoxStartTime = (TextBox)rptItem.FindControl("labelBoxStartTime");
                labelBoxStopTime = (TextBox)rptItem.FindControl("labelBoxStopTime");

                if (labelBoxStartTime == null ||
                    labelBoxStopTime == null ||
                    string.IsNullOrEmpty(labelBoxStartTime.Text) ||
                    string.IsNullOrEmpty(labelBoxStopTime.Text))
                {
                    continue;
                }
                _startStopTimes += (string.IsNullOrEmpty(_startStopTimes) ? string.Empty : "|")
                    + labelBoxStartTime.Text + "-" + labelBoxStopTime.Text;
            }
            string _url = MBA.HttpApplication.createLink("InsertEditScheduleTemplate.aspx", true)
                + "&startstop=" + _startStopTimes + "&taskid=" + HiddenFieldStopStartTaskId.Value +
                "&day=" + HiddenFieldTaskStartStopDay.Value + "&employeeid=" + HiddenFieldEmployeeID.Value
                + "&scheduleTemplateId=" + HiddenFieldTemplateID.Value;

            Response.Redirect(_url);
        }

        protected bool EntryIsDuplicate(string startTime, string stopTime)
        {
            labelMessage.Text = string.Empty;
            if (string.IsNullOrEmpty(startTime) || string.IsNullOrEmpty(stopTime))
            {
                return false;
            }

            foreach (RepeaterItem rptItem in repeaterTaskStartStopTemplateControl.Items)
            {
                TextBox labelBoxStartTime = (TextBox)rptItem.FindControl("labelBoxStartTime");
                TextBox labelBoxStopTime = (TextBox)rptItem.FindControl("labelBoxStopTime");

                if (labelBoxStartTime.Text == startTime && labelBoxStopTime.Text == stopTime)
                {
                    labelMessage.Text = "This is a duplicate entry";
                    return true;
                }
            }

            return false;
        }

        protected void checkBoxAllClients_CheckedChanged(object sender, EventArgs e)
        {

            RepeaterItem item = ((sender as CheckBox).NamingContainer as RepeaterItem);
            ListBox listBoxClients = (ListBox)item.FindControl("listBoxClients");
            CheckBox checkBoxAllClients = (CheckBox)item.FindControl("checkBoxAllClients");
            bool selected = false;

            if (checkBoxAllClients.Checked)
            {
                listBoxClients.Enabled = false;
                selected = true;
            }
            else
            {
                listBoxClients.Enabled = true;
            }

            foreach(ListItem listItem in listBoxClients.Items)
            {
                listItem.Selected = selected;
            }
            Page.SetFocus(checkBoxAllClients);
        }
    }
}
