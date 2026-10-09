using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MBA.BitteTime;

namespace Spedmon
{
    public partial class TimeEntryScheduleAdmin : WebUI
    {
        class Holiday
        {
            public long ID { get; set; }
            public string Name { get; set; }
            public string Description { get; set; }
            public DateTime DateOfHoliday { get; set; }
        }

        public string url = string.Empty;

        public TimeEntryScheduleAdmin()
             : base("timeentry", WebUI.CreatePageSubTitle("Schedule Admin", "Create, update, or delete schedule"), "", "", Constants.ROLE_SBS_ALL)
        {
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (rd.wu.usr.timeSheetUserInfo == null)
            {
                rd.wu.usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(rd.wu.usr.userName);
            }
            if (!IsPostBack)
            {
                tbSelectedDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
                using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                {
                    _con.Open();
                    PopulateEmployeeList(_con);
                    PopulateTemplateList(_con);
                }
            }
            // If not an admin,  hide controls that end user should not have access too
            if ((rd.wu.usr.timeSheetUserInfo.roleID != 1) && (rd.wu.usr.timeSheetUserInfo.roleID != 3))
            {
                PanelRunTaskTemplate.Visible = false;
                ButtonManageSchedules.Visible = false;
                RadioButtonListSetEmployeeType.Visible = false;
                DropDownListEmployee.Enabled = false;
                DropDownListScheduleTemplate.Enabled = false;
                ButtonRunSchedule.Visible = false;
                ButtonApply.Visible = false;

                // hide Add button if template exist
                if (DropDownListScheduleTemplate.SelectedIndex != 0)
                {
                    ButtonAddOrEdit.Visible = false;
                }
                ButtonRunSchedule.Visible = false;
            }
            else
            {
                PanelRunTaskTemplate.Visible = true;
                ButtonRunSchedule.Visible = true;
                ButtonAddOrEdit.Visible = false;
            }
        }

        private void PopulateEmployeeList(SqlConnection con)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetEmployeeList", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            ListBoxEmployees.DataSource = _dataTable;
            ListBoxEmployees.DataTextField = "Name";
            ListBoxEmployees.DataValueField = "EmployeeId";
            ListBoxEmployees.DataBind();

            DropDownListEmployee.DataSource = _dataTable;
            DropDownListEmployee.DataTextField = "Name";
            DropDownListEmployee.DataValueField = "EmployeeId";
            DropDownListEmployee.DataBind();

            ListItem _item = new ListItem();
            _item.Value = "-1";
            _item.Text = "Select Employee";

            ListBoxEmployees.Items.Insert(0, _item);
            DropDownListEmployee.Items.Insert(0, _item);

            ListBoxEmployees.SelectedIndex = 0;
            DropDownListEmployee.SelectedIndex = 0;

            if (RadioButtonListSetEmployeeType.SelectedValue == "0")
            {
                ListBoxEmployees.Visible = true;
                DropDownListEmployee.Visible = false;
            }
            else
            {
                ListBoxEmployees.Visible = false;
                DropDownListEmployee.Visible = true;

                DropDownListEmployee.SelectedValue = rd.wu.usr.timeSheetUserInfo.employeeid.ToString();
            }
        }

        private void PopulateControlForEmployee(DataRow dataRow)
        {
            if (!dataRow.IsNull("autoPopulateSdheduleTemplateId"))
            {
                DropDownListScheduleTemplate.SelectedValue = dataRow["autoPopulateSdheduleTemplateId"].ToString();
            }
        }
        private void PopulateTemplateList(SqlConnection con)
        {
            string _sqlStatement = @"
            select
	            id
	            ,[name]
	            ,[description]
            from
	            TimeKeeper.dbo.AutoPopulateScheduleTemplate
            order by
	            [name]";

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            DropDownListScheduleTemplate.DataSource = _dataTable;
            DropDownListScheduleTemplate.DataTextField = "name";
            DropDownListScheduleTemplate.DataValueField = "id";
            DropDownListScheduleTemplate.DataBind();

            ListItem _item = new ListItem();
            _item.Text = "Select Schedule";
            _item.Value = "-1";

            DropDownListScheduleTemplate.Items.Insert(0, _item); ;

            GetTemplateForEmployees();
        }


        protected void ButtonManageSchedules_Click(object sender, EventArgs e)
        {
            string _url = MBA.HttpApplication.createLink("TimeEntryScheduleAdminTemplate.aspx", true);
            Response.Redirect(_url, false);
        }
        protected void GridView1_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
        }

        protected void GridView1_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
        }

        protected void GridView1_RowEditing(object sender, GridViewEditEventArgs e)
        {

            HiddenField HiddenFieldItemTemplateIDEdit = (HiddenField)GridView1.Rows[e.NewEditIndex].FindControl("HiddenFieldItemTemplateIDEdit");

            string _currentUrl = Request.Url.ToString();
            Session["TimeEntryScheduleAdminUrl"] = _currentUrl;
            string _url = MBA.HttpApplication.createLink("InsertEditScheduleTemplate.aspx", true) + "&scheduleTemplateId=" +
                HiddenFieldItemTemplateIDEdit.Value;

            if (rd.wu.usr.timeSheetUserInfo == null)
            {
                rd.wu.usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(rd.wu.usr.userName);
            }

            if ((rd.wu.usr.timeSheetUserInfo.roleID == 1) || (rd.wu.usr.timeSheetUserInfo.roleID == 3))
            {
                _url += "&employeeid=" + DropDownListEmployee.SelectedValue;
            }
            else
            {
                _url += "&employeeid=" + rd.wu.usr.timeSheetUserInfo.employeeid.ToString();
            }

            Response.Redirect(_url, true);
        }

        protected void GridView1_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
        }

        protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName.Equals("Edit"))
            {

            }
        }
        protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
        {
        }

        protected void GridView1_Sorting(object sender, GridViewSortEventArgs e)
        {
        }

        protected void RadioButtonListSetEmployeeType_SelectedIndexChanged(object sender, EventArgs e)
        {
            switch (RadioButtonListSetEmployeeType.SelectedValue)
            {
                case "0":
                    SetEmployeeSelectionVisibleControls(true);
                    break;
                case "1":
                    SetEmployeeSelectionVisibleControls(false);
                    break;
            }
        }

        private void SetEmployeeSelectionVisibleControls(bool multipleEmployees)
        {
            LiteralEmployeesPrompt.Visible = multipleEmployees;
            LiteralEmployeePrompt.Visible = !multipleEmployees;
            ListBoxEmployees.Visible = multipleEmployees;
            DropDownListEmployee.Visible = !multipleEmployees;
        }

        protected void ListBoxEmployees_SelectedIndexChanged(object sender, EventArgs e)
        {
            int[] _selectedValues = ListBoxEmployees.GetSelectedIndices();
            string _whereClauseValue = string.Empty;
            List<string> _listIds = new List<string>();
            int _numberOfIds = 0;

            for (int _counter = 0; _counter < _selectedValues.Length; _counter++)
            {
                ++_numberOfIds;
                _listIds.Add(ListBoxEmployees.Items[_selectedValues[_counter]].Value);

                if (string.IsNullOrEmpty(_whereClauseValue))
                {
                    _whereClauseValue = "E.id = @Id" + _numberOfIds.ToString();
                }
                else
                {
                    _whereClauseValue += " OR E.id = @Id" + _numberOfIds.ToString();
                }
            }

            GetTemplateForEmployees(_whereClauseValue, _listIds);
        }

        private void GetTemplateForEmployees(string selectedNames, List<string> listId)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();

                SqlDataAdapter _sqlDataAdapter = GetSqlAdapterToRetrieveEmployee(selectedNames, _con);
                if (listId != null && listId.Count > 0)
                {
                    int _index = 0;
                    foreach (string id in listId)
                    {
                        ++_index;
                        _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id" + _index.ToString(), id);
                    }
                }

                DataRow _dataRow = GetDataRowForTemplateID(_sqlDataAdapter);
                if (_dataRow == null)
                {
                    return;
                }
                DropDownListScheduleTemplate.SelectedValue = _dataRow["templateId"].ToString();
                GetTemplateInfo();
            }
        }
        private void GetTemplateForEmployees(string selectedNames, string id = null)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();

                SqlDataAdapter _sqlDataAdapter = GetSqlAdapterToRetrieveEmployee(selectedNames, _con);

                if (!string.IsNullOrEmpty(id))
                {
                    _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", id);
                }

                DataRow _dataRow = GetDataRowForTemplateID(_sqlDataAdapter);
                if (_dataRow == null)
                {
                    return;
                }
                DropDownListScheduleTemplate.SelectedValue = _dataRow["templateId"].ToString();
                GetTemplateInfo();
            }
        }

        private DataRow GetDataRowForTemplateID(SqlDataAdapter sqlDataAdapter)
        {
            DataTable _dataTable = new DataTable();
            sqlDataAdapter.Fill(_dataTable);

            if (_dataTable.Rows.Count != 1)
            {
                DropDownListScheduleTemplate.SelectedValue = "-1";
                GetTemplateInfo();
                return null;
            }

            return _dataTable.Rows[0];
        }

        private SqlDataAdapter GetSqlAdapterToRetrieveEmployee(string selectedNames, SqlConnection con)
        {
            string _sqlStatement = @"
                select
	                DISTINCT APST.id as templateId
                from
	                TimeKeeper.dbo.AutoPopulateScheduleTemplate APST
	                inner join TimeKeeper.dbo.Employees E
		                on E.autoPopulateSdheduleTemplateId = APST.id
                where
                    " + selectedNames;

            return new SqlDataAdapter(_sqlStatement, con);
        }

        protected void DropDownListEmployee_SelectedIndexChanged(object sender, EventArgs e)
        {
            GetTemplateForEmployees();
        }

        private void GetTemplateForEmployees()
        {
            string _whereClause = string.Empty;
            if (DropDownListEmployee.SelectedValue == "-1")
            {
                _whereClause = "E.id = @Id";
                GetTemplateForEmployees(_whereClause, "-1");
                return;
            }

            _whereClause = "E.id=@Id";
            GetTemplateForEmployees(_whereClause, DropDownListEmployee.SelectedValue);

        }

        protected void DropDownListScheduleTemplate_SelectedIndexChanged(object sender, EventArgs e)
        {
            GetTemplateInfo();
        }

        private void GetTemplateInfo()
        {
            string _sqlStatement = @"
            select
	            APST.id AS TemplateId
	            ,APST.name AS TemplateName
	            ,APST.description AS TemplateDescription
	            ,ISNULL(APSD.id, -1) AS AutoScheduleDaysId
	            ,ISNULL(DOW.id, -1) AS DayOfWeekId
	            ,ISNULL(DOW.day, '') AS DayOfWeek
	            ,ISNULL(APSST.id, -1) AS StartStopTimeId
	            ,ISNULL(APSST.starttime, '') AS StartTime
	            ,ISNULL(APSST.stoptime, '') AS EndTime
            from
	            TimeKeeper.dbo.AutoPopulateScheduleTemplate APST
	            left join TimeKeeper.dbo.AutoPopulateScheduleDays APSD
		            ON APSD.scheduleid = APST.id
	            left join TimeKeeper.dbo.DaysOfTheWeek DOW
		            ON DOW.id = APSD.dayId
	            left join timeKeeper.dbo.AutoPopulateScheduleStartAndStopTime APSST
		            ON APSST.autoPopulateScheduleDaysId = APSD.id
            where
                APST.id = @Id
            order by
	            APST.id,
				APSD.id,
				DOW.id";

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();

                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", DropDownListScheduleTemplate.SelectedValue);

                DataTable _dataTable = new DataTable();
                _sqlDataAdapter.Fill(_dataTable);

                ProcessRecord(_dataTable);
            }
        }

        private void ProcessRecord(DataTable dataTable)
        {
            List<ScheduleTemplate> _listScheduleTemplates = new List<ScheduleTemplate>();
            ScheduleTemplate _scheduleTemplate = null;
            int _dayOfWeek = 0;
            TimeSpan _timeSpan;
            int[] _arrayMinutes = new int[7];
            int _idCurrent = 0;
            int _hours = 0;
            int _minutes = 0;

            foreach (DataRow _dataRow in dataTable.Rows)
            {
                // Get totals for template before processing new one
                if (_idCurrent == 0)
                {
                    _idCurrent = int.Parse(_dataRow["TemplateId"].ToString());

                    _scheduleTemplate = new ScheduleTemplate();
                    _scheduleTemplate.id = long.Parse(_dataRow["TemplateId"].ToString());
                    _scheduleTemplate.TemplateName = _dataRow["TemplateName"].ToString();

                    _scheduleTemplate.SundayInfo = string.Empty;
                    _scheduleTemplate.MondayInfo = string.Empty;
                    _scheduleTemplate.TuesdayInfo = string.Empty;
                    _scheduleTemplate.WednesdayInfo = string.Empty;
                    _scheduleTemplate.ThursdayInfo = string.Empty;
                    _scheduleTemplate.FridayInfo = string.Empty;
                    _scheduleTemplate.SaturdayInfo = string.Empty;
                }

                if ((_dataRow["AutoScheduleDaysId"].ToString() == "-1") || (_dataRow["DayOfWeekId"].ToString() == "-1"))
                {
                    continue;
                }

                if (_dataRow["StartStopTimeId"].ToString() == "-1")
                {
                    continue;
                }

                _dayOfWeek = int.Parse(_dataRow["DayOfWeekId"].ToString());
                _timeSpan = DateTime.Parse(_dataRow["EndTime"].ToString()) - DateTime.Parse(_dataRow["StartTime"].ToString());

                _arrayMinutes[_dayOfWeek] += (int)_timeSpan.TotalMinutes;
                switch (_dayOfWeek)
                {
                    case 0:
                        if (string.IsNullOrEmpty(_scheduleTemplate.SundayInfo) || (_scheduleTemplate.SundayInfo == string.Empty))
                        {
                            _scheduleTemplate.SundayInfo = DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                        }
                        else
                        {
                            _scheduleTemplate.SundayInfo += "<br/>" + DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                        }
                        break;
                    case 1:
                        if (string.IsNullOrEmpty(_scheduleTemplate.MondayInfo) || (_scheduleTemplate.MondayInfo == string.Empty))
                        {
                            _scheduleTemplate.MondayInfo = DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                        }
                        else
                        {
                            _scheduleTemplate.MondayInfo += "<br/>" + DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                        }
                        break;
                    case 2:
                        if (string.IsNullOrEmpty(_scheduleTemplate.TuesdayInfo) || (_scheduleTemplate.TuesdayInfo == string.Empty))
                        {
                            _scheduleTemplate.TuesdayInfo = DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                        }
                        else
                        {
                            _scheduleTemplate.TuesdayInfo += "<br/>" + DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                        }
                        break;
                    case 3:
                        if (string.IsNullOrEmpty(_scheduleTemplate.WednesdayInfo) || (_scheduleTemplate.WednesdayInfo == string.Empty))
                        {
                            _scheduleTemplate.WednesdayInfo = DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                        }
                        else
                        {
                            _scheduleTemplate.WednesdayInfo += "<br/>" + DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                        }
                        break;
                    case 4:
                        if (string.IsNullOrEmpty(_scheduleTemplate.ThursdayInfo) || (_scheduleTemplate.ThursdayInfo == string.Empty))
                        {
                            _scheduleTemplate.ThursdayInfo = DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                        }
                        else
                        {
                            _scheduleTemplate.ThursdayInfo += "<br/>" + DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                        }
                        break;
                    case 5:
                        if (string.IsNullOrEmpty(_scheduleTemplate.FridayInfo) || (_scheduleTemplate.FridayInfo == string.Empty))
                        {
                            _scheduleTemplate.FridayInfo = DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                        }
                        else
                        {
                            _scheduleTemplate.FridayInfo += "<br/>" + DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                        }
                        break;
                    case 6:
                        if (string.IsNullOrEmpty(_scheduleTemplate.SaturdayInfo) || (_scheduleTemplate.SaturdayInfo == string.Empty))
                        {
                            _scheduleTemplate.SaturdayInfo = DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                        }
                        else
                        {
                            _scheduleTemplate.SaturdayInfo += "<br/>" + DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                        }
                        break;
                }
            }

            for (int _counter = 0; _counter < 7; _counter++)
            {
                if ((_arrayMinutes[_counter] == 0) || (_scheduleTemplate == null))
                {
                    continue;
                }

                _hours = (int)((double)_arrayMinutes[_counter] / 60.0);
                _minutes = _arrayMinutes[_counter] % 60;

                switch (_counter)
                {
                    case 0:
                        _scheduleTemplate.SundayInfo += "<br/>" + _hours.ToString() + " Hours";
                        if (_minutes > 0)
                        {
                            _scheduleTemplate.SundayInfo += "&nbsp;&nbsp;&nbsp;&nbsp;" + _minutes.ToString() + " Minutes";
                        }
                        break;
                    case 1:
                        _scheduleTemplate.MondayInfo += "<br/>" + _hours.ToString() + " Hours";
                        if (_minutes > 0)
                        {
                            _scheduleTemplate.MondayInfo += "&nbsp;&nbsp;&nbsp;&nbsp;" + _minutes.ToString() + " Minutes";
                        }
                        break;
                    case 2:
                        _scheduleTemplate.TuesdayInfo += "<br/>" + _hours.ToString() + " Hours";
                        if (_minutes > 0)
                        {
                            _scheduleTemplate.TuesdayInfo += "&nbsp;&nbsp;&nbsp;&nbsp;" + _minutes.ToString() + " Minutes";
                        }
                        break;
                    case 3:
                        _scheduleTemplate.WednesdayInfo += "<br/>" + _hours.ToString() + " Hours";
                        if (_minutes > 0)
                        {
                            _scheduleTemplate.WednesdayInfo += "&nbsp;&nbsp;&nbsp;&nbsp;" + _minutes.ToString() + " Minutes";
                        }
                        break;
                    case 4:
                        _scheduleTemplate.ThursdayInfo += "<br/>" + _hours.ToString() + " Hours";
                        if (_minutes > 0)
                        {
                            _scheduleTemplate.ThursdayInfo += "&nbsp;&nbsp;&nbsp;&nbsp;" + _minutes.ToString() + " Minutes";
                        }
                        break;
                    case 5:
                        _scheduleTemplate.FridayInfo += "<br/>" + _hours.ToString() + " Hours";
                        if (_minutes > 0)
                        {
                            _scheduleTemplate.TuesdayInfo += "&nbsp;&nbsp;&nbsp;&nbsp;" + _minutes.ToString() + " Minutes";
                        }
                        break;
                    case 6:
                        _scheduleTemplate.SaturdayInfo += "<br/>" + _hours.ToString() + " Hours";
                        if (_minutes > 0)
                        {
                            _scheduleTemplate.WednesdayInfo += "&nbsp;&nbsp;&nbsp;&nbsp;" + _minutes.ToString() + " Minutes";
                        }
                        break;
                }
                _arrayMinutes[_counter] = 0;
            }

            if (_scheduleTemplate != null)
            {
                _listScheduleTemplates.Add(_scheduleTemplate);
            }

            if (_listScheduleTemplates.Count == 0)
            {
                ButtonAdd.Visible = true;
            }
            else
            {
                ButtonAdd.Visible = false;
            }
            GridView1.DataSource = _listScheduleTemplates;
            GridView1.DataBind();
        }

        protected void ButtonApply_Click(object sender, EventArgs e)
        {
            LabelError.Text = string.Empty;

            string _confirmUpdate = Request.Form["confirm_update"];
            if (_confirmUpdate != "Yes")
            {
                return;
            }

            //if (DropDownListScheduleTemplate.SelectedValue == "-1")
            //{
            //    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
            //            "Select a schedule",
            //            "alert('Must select a schedule from the list!');",
            //            true);
            //    return;
            //}

            int[] _arrySelectedEmployees = null;
            if ((RadioButtonListSetEmployeeType.SelectedValue == "0") &&
                ((_arrySelectedEmployees = ListBoxEmployees.GetSelectedIndices()).Length == 0))
            {
                if (_arrySelectedEmployees.Contains(0))
                {
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                            "Select a one or more employees",
                            "alert('Must select one or more employees from list!');",
                            true);
                    LabelError.Text = "Make sure not to select item 'Select Employee'";
                    return;
                }
            }

            if ((RadioButtonListSetEmployeeType.SelectedValue == "1") && (DropDownListEmployee.SelectedValue == "-1"))
            {
                ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        "Select an employee from the list",
                        "alert('Must select an employees from list!');",
                        true);
                return;
            }

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();

                string _sqlStatement = @"
                update [TimeKeeper].[dbo].Employees
                    set autoPopulateSdheduleTemplateId = " +
                    (DropDownListScheduleTemplate.SelectedValue == "-1" ? "null" : DropDownListScheduleTemplate.SelectedValue) +
                    @"
                    ,autoPopulateSchedule=1
                where ";

                string _whereValue = string.Empty;

                int _numberOfParameters = 0;
                if (RadioButtonListSetEmployeeType.SelectedValue == "0")
                {
                    for (int _counter = 0; _counter < _arrySelectedEmployees.Length; ++_counter)
                    {
                        ++_numberOfParameters;
                        if (_counter == 0)
                        {
                            _whereValue = "id=@Id" + _numberOfParameters.ToString();
                        }
                        else
                        {
                            _whereValue += " or id=@Id" + _numberOfParameters.ToString();
                        }
                    }
                }
                else
                {
                    ++_numberOfParameters;
                    _whereValue = "id=@Id" + _numberOfParameters.ToString();
                }

                _sqlStatement += _whereValue;

                using (SqlCommand cmd = new SqlCommand(_sqlStatement, _con))
                {
                    _numberOfParameters = 0;

                    if (RadioButtonListSetEmployeeType.SelectedValue == "0")
                    {
                        for (int _counter = 0; _counter < _arrySelectedEmployees.Length; ++_counter)
                        {
                            ++_numberOfParameters;
                            cmd.Parameters.AddWithValue("@Id" + _numberOfParameters.ToString(), ListBoxEmployees.Items[_arrySelectedEmployees[_counter]].Value);
                        }
                    }
                    else
                    {
                        ++_numberOfParameters;
                        cmd.Parameters.AddWithValue("@Id" + _numberOfParameters.ToString(), DropDownListEmployee.SelectedValue);
                    }

                    cmd.ExecuteNonQuery();
                }

            }

            // Assuming no exception at this point,we should get the following alert box
            ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                    "Update Applied",
                    "alert('Update for schedule has been applied!');",
                    true);
        }

        protected void ButtonRunSchedule_Click(object sender, EventArgs e)
        {

            string _confirmRun = Request.Form["confirm_run"];
            if (_confirmRun != "Yes")
            {
                return;
            }

            SqlTransaction _objTrans = null;

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                try
                {
                    _con.Open();
                    _objTrans = _con.BeginTransaction();

                    string _sqlStatement = @"
                    select
                        id
                        ,autoPopulateSdheduleTemplateId
                    from
                        TimeKeeper.dbo.Employees
                    where
                        autoPopulateSdheduleTemplateId is not null";

                    SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                    _sqlDataAdapter.SelectCommand.Transaction = _objTrans;
                    DataTable _dataTable = new DataTable();
                    _sqlDataAdapter.Fill(_dataTable);

                    if (_dataTable.Rows.Count == 0)
                    {
                        return;
                    }
                    InsertSchedule(_con, _dataTable, _objTrans);
                    _objTrans.Commit();
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                            "Schedules Run Done",
                            "alert('Schedules have been generated!');",
                            true);
                }
                catch (Exception _exception)
                {
                    _objTrans.Rollback();
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                            "Schedules had errors",
                            "alert('Schedules not generated - " + _exception.Message + "!');",
                            true);
                }
                finally
                {
                    _con.Close();
                }
            }

        }

        private void InsertSchedule(SqlConnection con, DataTable dataTableScheduleTemplate, SqlTransaction sqlTransaction)
        {
            DateTime _currentDate = DateTime.Now;
            DateTime _startOfTheWeekDate = DateTime.MinValue;
            // Get date for sunday of this week
            if (_currentDate.DayOfWeek == DayOfWeek.Sunday)
            {
                _startOfTheWeekDate = _currentDate;
            }
            else
            {
                _startOfTheWeekDate = _currentDate.AddDays(-1 * (int)_currentDate.DayOfWeek);
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
            int _scheduleApproveId = 0;

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

        private void InsertSchedule(SqlConnection con, int employeeId, DateTime startOfTheWeek, DataTable dataTableTemplateDays, SqlTransaction sqlTransaction, int scheduleApproveId)
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
                where scheduleid = @scheduleId";

            using (SqlCommand _sqlcommand = new SqlCommand(_deleteStatement, con))
            {
                _sqlcommand.Parameters.AddWithValue("@scheduleId", scheduleId);
                _sqlcommand.Transaction = sqlTransaction;
                _sqlcommand.ExecuteScalar();
            }
        }

        private int InsertSchedule(SqlConnection con, int employeeId, DateTime dateOfSchedule, SqlTransaction sqlTransaction, int scheduleApproveId)
        {
            SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_SCHEDULE_CreateNew", con);
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

        private int InsertScheduleApproved(SqlConnection con, int employeeId, DateTime dateOfSchedule, SqlTransaction sqlTransaction)
        {
            DateTime _startDate = dateOfSchedule.DayOfWeek == DayOfWeek.Sunday ? dateOfSchedule :
                    dateOfSchedule.AddDays(-1 * (int)dateOfSchedule.DayOfWeek);
            DateTime _endDate = dateOfSchedule.DayOfWeek == DayOfWeek.Saturday ? dateOfSchedule :
                    dateOfSchedule.AddDays(6 - (int)dateOfSchedule.DayOfWeek);

            SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_SCHEDULE_CreateNewScheduleApproved", con);
            _sqlCommand.Transaction = sqlTransaction;
            _sqlCommand.CommandType = CommandType.StoredProcedure;
            _sqlCommand.Parameters.AddWithValue("@EmployeeId", employeeId);
            _sqlCommand.Parameters.AddWithValue("@StartDate", _startDate);
            _sqlCommand.Parameters.AddWithValue("@EndDate", _endDate);
            _sqlCommand.Parameters.Add("@Id", SqlDbType.BigInt);
            _sqlCommand.Parameters["@Id"].Direction = ParameterDirection.Output;

            _sqlCommand.ExecuteNonQuery();

            return int.Parse(_sqlCommand.Parameters["@Id"].Value.ToString());
        }

        private int InsertScheduleStopStartTime(SqlConnection con, int scheduleId, DateTime startTime, DateTime endTime, SqlTransaction sqlTransaction)
        {
            SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_SCHEDULE_STOP_START_CreateNew", con);
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

        protected void ButtonAddOrEdit_Click(object sender, EventArgs e)
        {
            string _url = MBA.HttpApplication.createLink("InsertEditScheduleTemplate.aspx", true);
            _url += "&scheduleTemplateId=0&employeeid=" + rd.wu.usr.timeSheetUserInfo.employeeid.ToString();
            Response.Redirect(_url, true);
        }

        protected void ButtonAdd_Click(object sender, EventArgs e)
        {
            string _url = MBA.HttpApplication.createLink("InsertEditScheduleTemplate.aspx", true) + "&scheduleTemplateId=0";

            if (rd.wu.usr.timeSheetUserInfo == null)
            {
                rd.wu.usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(rd.wu.usr.userName);
            }

            if ((rd.wu.usr.timeSheetUserInfo.roleID == 1) || (rd.wu.usr.timeSheetUserInfo.roleID == 3))
            {
                _url += "&employeeid=" + DropDownListEmployee.SelectedValue;
            }
            else
            {
                _url += "&employeeid=" + rd.wu.usr.timeSheetUserInfo.employeeid.ToString();
            }

            Response.Redirect(_url, true);
        }
        protected void lnkpickdate_Click(object sender, ImageClickEventArgs e)
        {
            datepicker.Visible = true;
        }
        protected void datepicker_SelectionChanged(object sender, EventArgs e)
        {
            tbSelectedDate.Text = datepicker.SelectedDate.ToString("MM/dd/yyyy");
            datepicker.Visible = false;
        }
        private static DataTable GetHolidays(SqlConnection con, SqlTransaction objTransAction)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetHolidays", con);
            _sqlDataAdapter.SelectCommand.Transaction = objTransAction;
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            return _dataTable;
        }
        private Holiday GetHolidaysForDate(SqlConnection con, SqlTransaction objTransAction, DateTime processDate)
        {
            DataTable _dataTable = GetHolidays(con, objTransAction);
            DateTime _holidayDateTime;

            foreach (DataRow _dataRow in _dataTable.Rows)
            {
                _holidayDateTime = DateTime.Parse(_dataRow["DateOfHoliday"].ToString());
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

                if (_holidayDateTime == processDate)
                {
                    Holiday _holidays = new Holiday();
                    _holidays.ID = int.Parse(_dataRow["ID"].ToString());
                    _holidays.Name = _dataRow["Name"].ToString();
                    _holidays.Description = _dataRow.IsNull("Description") ? string.Empty : _dataRow["Description"].ToString();

                    _holidays.DateOfHoliday = _holidayDateTime;
                    return _holidays;
                }
            }

            return null;
        }

        protected void ButtonRunTaskTemplate_Click(object sender, EventArgs e)
        {
            string _confirmRun = Request.Form["confirm_run"];
            if (_confirmRun != "Yes")
            {
                return;
            }

            SqlTransaction _objTrans = null;

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                LiteralMessageError.Text = string.Empty;
                try
                {
                    DateTime _processDate = DateTime.Now;

                    if (!DateTime.TryParse(tbSelectedDate.Text, out _processDate))
                    {
                        LiteralMessageError.Text = "Date entry is not valid";
                        return;
                    }
                    _con.Open();
                    _objTrans = _con.BeginTransaction();


                    Holiday _holiday = GetHolidaysForDate(_con, _objTrans, _processDate);
                    DataTable _dataTable = null;

                    if (_holiday != null && DoesEmployeeGetPaidForHoliday(_con, ref _dataTable, _objTrans))
                    {
                        InsertHolidayIntoTimesheet(_holiday, _con, _objTrans, _processDate, _dataTable);
                    }
                    else
                    {
                        bool _forceDelete = bool.Parse(DropDownListForceDelete.SelectedValue);
                        EnterTaskInfoForTimeEntry(_con, _objTrans, _processDate, _forceDelete);
                    }

                    _objTrans.Commit();
                }
                catch (Exception _exception)
                {
                    _objTrans.Rollback();
                    LiteralMessageError.Text = "Schedules had errors\n" +
                            "Schedules not generated - " + _exception.Message + "!";
                }
                finally
                {
                    _con.Close();
                }

            }
        }

        private bool DoesEmployeeGetPaidForHoliday(SqlConnection con, ref DataTable dataTable, SqlTransaction objTrans)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetEmployeesWhoGetPaidForHolidayByEmployeeID", con);
            _sqlDataAdapter.SelectCommand.Transaction = objTrans;
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@ID", long.Parse(DropDownListEmployee.SelectedValue));

            dataTable = new DataTable();
            _sqlDataAdapter.Fill(dataTable);

            return dataTable.Rows.Count > 0 ? true : false;
        }
        private void InsertHolidayIntoTimesheet(Holiday holiday, SqlConnection con, SqlTransaction objTrans, DateTime processDate, DataTable dataTable)
        {
            long _timeEntryDayId = 0;

            foreach (DataRow _dataRow in dataTable.Rows)
            {
                _timeEntryDayId = CreateTimeEntryDayIfNotPresent(long.Parse(_dataRow["id"].ToString()), con, objTrans, processDate);
                InsertTimeEntries(con, objTrans, _timeEntryDayId, (8 * 60).ToString(), string.Empty, string.Empty,
                    string.Empty, false, holiday.ID.ToString(), processDate);
            }
        }

        private static long InsertTimeEntries(SqlConnection con, SqlTransaction objTransAction, long timeEntryDayID,
            string numberOfMinutes, string timeEntrytaskID, string clientid, string note,
            bool canHaveMultipleClients, string holidayTaskID, DateTime processDate)
        {
            using (SqlCommand cmd = new SqlCommand("TimeKeeper_TIMESHEET_InsertTimeEntries", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Transaction = objTransAction;
                cmd.Parameters.AddWithValue("@timeEntryDayID", timeEntryDayID);
                cmd.Parameters.AddWithValue("@timeOfTask", processDate.ToString("MM/dd/yyyy"));
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
                cmd.Parameters.AddWithValue("@dateEntryUpdated", DateTime.Now.ToString());
                cmd.Parameters.AddWithValue("@HasMultipleClients", canHaveMultipleClients);

                if (string.IsNullOrEmpty(holidayTaskID))
                {
                    cmd.Parameters.AddWithValue("@holidayTaskID", DBNull.Value);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@holidayTaskID", holidayTaskID);
                }

                cmd.Parameters.Add("@Id", SqlDbType.BigInt);
                cmd.Parameters["@Id"].Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();

                return long.Parse(cmd.Parameters["@Id"].Value.ToString());
            }
        }

        private long CreateTimeEntryDayIfNotPresent(long employeeId, SqlConnection con, SqlTransaction objTrans, DateTime processDate)
        {
            SqlCommand cmd = new SqlCommand("TimeKeeper_TIMESHEET_CreateTimeEntryDay", con);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Transaction = objTrans;

            cmd.Parameters.AddWithValue("@EmployeeId", employeeId);
            cmd.Parameters.AddWithValue("@dateForTimeEntry", processDate.ToString("MM/dd/yyyy"));
            cmd.Parameters.Add("@Id", SqlDbType.BigInt);
            cmd.Parameters["@Id"].Direction = ParameterDirection.Output;

            cmd.ExecuteNonQuery();
            return long.Parse(cmd.Parameters["@Id"].Value.ToString());
        }

        private DataTable GetAllEmployeesTaskEmplateInfo(SqlConnection con, SqlTransaction objTransAction, DateTime processDate)
        {

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetAutoTaskInfoForTimeEntryForSpecificDay", con);
            _sqlDataAdapter.SelectCommand.Transaction = objTransAction;
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@DayId", (int)processDate.DayOfWeek);

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            return _dataTable;
        }

        private DataTable GetAllEmployeesTaskEmplateInfoForEmployee(SqlConnection con, SqlTransaction objTransAction, DateTime processDate)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetAutoTaskInfoForTimeEntryForSpecificDayForEmployee", con);
            _sqlDataAdapter.SelectCommand.Transaction = objTransAction;
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@DayId", (int)processDate.DayOfWeek);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@EmployeeId", DropDownListEmployee.SelectedValue);


            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            return _dataTable;
        }


        private void EnterTaskInfoForTimeEntry(SqlConnection con, SqlTransaction objTransAction, DateTime processDate, bool forceDelete)
        {
            DataTable _dataTable = null;
            if (bool.Parse(DropDownListAllEmployees.SelectedValue))
            {
                _dataTable = GetAllEmployeesTaskEmplateInfo(con, objTransAction, processDate);
            }
            else
            {
                _dataTable = GetAllEmployeesTaskEmplateInfoForEmployee(con, objTransAction, processDate);
            }

            List<DataRow> _employeeTasks = new List<DataRow>();
            bool _firstTime = true;

            foreach (DataRow _dataRow in _dataTable.Rows)
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
                    ProcessEmployeeTasks(con, objTransAction, _employeeTasks, processDate, forceDelete);
                    // Clear list for next employee tasks
                    _employeeTasks.Clear();
                }
                _employeeTasks.Add(_dataRow);
            }
            if (_employeeTasks.Count > 0)
            {
                ProcessEmployeeTasks(con, objTransAction, _employeeTasks, processDate, forceDelete);
                _employeeTasks.Clear();
            }
        }
        private void ProcessEmployeeTasks(SqlConnection con,
            SqlTransaction objTransAction, List<DataRow> listEmployeeTasks, DateTime processDate, bool forceDelete)
        {
            // Sanity check
            if (listEmployeeTasks.Count == 0)
            {
                return;
            }

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetAutoSchedulerTimeEntryDay", con);
            _sqlDataAdapter.SelectCommand.Transaction = objTransAction;
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@EmployeeID", listEmployeeTasks[0]["employeeID"].ToString());
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@dateForTimeEntry", processDate.ToString("MM/dd/yyyy"));

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            if (_dataTable.Rows.Count > 0 && !forceDelete)
            {
                return;
            }
            else if (_dataTable.Rows.Count > 0)
            {
                DeleteTimeEntryDay(con, objTransAction, _dataTable);
            }

            long _timeEntryDayID = InsertIntoTimeEntryDay(con, objTransAction, listEmployeeTasks, processDate);

            foreach (DataRow _dataRow in listEmployeeTasks)
            {
                InsertTimeEntries(con, objTransAction, _dataRow, _timeEntryDayID, processDate);
            }
        }

        private List<long> InsertTimeEntriesStopStartTime(SqlConnection con, SqlTransaction objTransAction, long timeEntryDayID,
            string timeEntrytaskID, string clientid, string note,
            bool canHaveMultipleClients, long autoPopulateDaysId, DateTime processDate)
        {
            List<long> _timeEntryIds = new List<long>();
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_AUTO_GetAutoPopulateTaskDaysStartStopTimeByTaskDaysId", con);
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
                _startDateTime = DateTime.Parse(processDate.ToString("MM/dd/yyyy") + " " + _dataRow["starttime"].ToString());
                _stopDateTime = DateTime.Parse(processDate.ToString("MM/dd/yyyy") + " " + _dataRow["stoptime"].ToString());
                _timeSpan = _stopDateTime - _startDateTime;
                _numberOfMinutes = (int)_timeSpan.TotalMinutes;
                _timeEntryIds.Add(InsertTimeEntriesStopStartTime(con, objTransAction, timeEntryDayID, timeEntrytaskID, clientid, note,
                    canHaveMultipleClients, _startDateTime, _stopDateTime, _numberOfMinutes, processDate));
            }

            return _timeEntryIds;
        }

        private long InsertTimeEntriesStopStartTime(SqlConnection con, SqlTransaction objTransAction, long timeEntryDayID,
            string timeEntrytaskID, string clientid, string note,
            bool canHaveMultipleClients, DateTime startDateTime, DateTime stopDateTime, int numberOfMinutes, DateTime processDate)
        {
            using (SqlCommand cmd = new SqlCommand("TimeKeeper_TIMESHEET_CreateTimeEntry", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Transaction = objTransAction;
                cmd.Parameters.AddWithValue("@timeEntryDayID", timeEntryDayID);
                cmd.Parameters.AddWithValue("@timeOfTask", processDate.ToString("MM/dd/yyyy"));
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

                cmd.Parameters.AddWithValue("@e_id", DBNull.Value);

                cmd.Parameters.Add("@Id", SqlDbType.BigInt);
                cmd.Parameters["@Id"].Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();

                return long.Parse(cmd.Parameters["@Id"].Value.ToString());
            }

        }
        private long InsertTimeEntries(SqlConnection con, SqlTransaction objTransAction, long timeEntryDayID,
            DateTime processDate, string numberOfMinutes, string timeEntrytaskID, string clientid, string note,
            bool canHaveMultipleClients, string holidayTaskID, bool specifyStartStopTime, long autoPopulateDaysId)
        {
            if (specifyStartStopTime)
            {
                List<long> _listIds = InsertTimeEntriesStopStartTime(con, objTransAction, timeEntryDayID, timeEntrytaskID, clientid, note,
                    canHaveMultipleClients, autoPopulateDaysId, processDate);

                return _listIds.Count > 0 ? _listIds[0] : 0;
            }
            using (SqlCommand cmd = new SqlCommand("TimeKeeper_TIMESHEET_InsertTimeEntries", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Transaction = objTransAction;
                cmd.Parameters.AddWithValue("@timeEntryDayID", timeEntryDayID);
                cmd.Parameters.AddWithValue("@timeOfTask", processDate.ToString("MM/dd/yyyy"));
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
                cmd.Parameters.AddWithValue("@dateEntryUpdated", DateTime.Now.ToString());
                cmd.Parameters.AddWithValue("@HasMultipleClients", canHaveMultipleClients);

                if (string.IsNullOrEmpty(holidayTaskID))
                {
                    cmd.Parameters.AddWithValue("@holidayTaskID", DBNull.Value);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@holidayTaskID", holidayTaskID);
                }

                cmd.Parameters.Add("@Id", SqlDbType.BigInt);
                cmd.Parameters["@Id"].Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();

                return long.Parse(cmd.Parameters["@Id"].Value.ToString());
            }
        }

        private long InsertTimeEntries(SqlConnection con, SqlTransaction objTransAction, DataRow dataRow, long timeEntryDayID, DateTime processDate)
        {
            string clientid = dataRow.IsNull("clientid") ? string.Empty : dataRow["clientid"].ToString();

            return InsertTimeEntries(con, objTransAction, timeEntryDayID, processDate, dataRow["numberOfMinutes"].ToString(),
                dataRow["timeentrytaskid"].ToString(), clientid, "Task Template Entry",
                bool.Parse(dataRow["CanHaveMultipleClients"].ToString()), string.Empty, bool.Parse(dataRow["SpecifyStartStopTime"].ToString()), long.Parse(dataRow["AautoPopulateDaysId"].ToString()));
        }

        private long InsertIntoTimeEntryDay(SqlConnection con, SqlTransaction objTransAction, List<DataRow> listEmployeeTasks, DateTime processDate)
        {
            long _timeEntryDayID = 0;

            using (SqlCommand cmd = new SqlCommand("TimeKeeper_TIMESHEET_InsertTimeEntryDay", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Transaction = objTransAction;
                cmd.Parameters.AddWithValue("@employeeId", listEmployeeTasks[0]["EmployeeId"].ToString());
                cmd.Parameters.AddWithValue("@dateForTimeEntry", processDate.ToString("MM/dd/yyyy"));
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
            using (SqlCommand cmd = new SqlCommand("TimeKeeper_TIMESHEET_DeleteTimeEntries", con))
            {
                DataRow _dataRow = dataTable.Rows[0];
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Transaction = objTransAction;
                cmd.Parameters.AddWithValue("@timeEntryDayID", _dataRow["id"].ToString());

                cmd.ExecuteNonQuery();
            }
        }

    }
}
