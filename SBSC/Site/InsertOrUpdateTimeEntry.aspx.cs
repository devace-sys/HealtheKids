using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;
using MBA;
using MBA.BitteTime;
using System.Data;
using MBA.Web;


namespace Spedmon
{
     public partial class InsertOrUpdateTimeEntry : WebUI
     {
          public string Url = string.Empty;
          public string Message = string.Empty;
          public InsertOrUpdateTimeEntry()
               : base("insertorupdatetimeentry", WebUI.CreatePageSubTitle("Time Entry", "Create, update, or delete time entry"), "", "", Constants.ROLE_SBS_ALL)
          {
          }

        protected void Page_Load(object sender, EventArgs e)
        {
            MaintainScrollPositionOnPostBack = true;
            datepicker.TodaysDate = DateTime.Today;

            // Homelink is null
            InitLinksAndLabels();

            if (!IsPostBack)
            {
                if (rd.wu.usr.timeSheetUserInfo == null)
                {
                    rd.wu.usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(rd.wu.usr.userName);
                }
                if (string.IsNullOrEmpty(Request.QueryString["employeeid"])
                    || string.IsNullOrEmpty(Request.QueryString["timentrydate"]))
                {
                    PanelDateEntry.Visible = true;
                    HiddenFieldEmployeeID.Value = rd.wu.usr.timeSheetUserInfo.employeeid.ToString();
                    LabelEmployeeName.Text = "Daily Time Entry for " + rd.wu.usr.timeSheetUserInfo.firstName + " " + rd.wu.usr.timeSheetUserInfo.lastName;

                    if (Request.QueryString["datetoprocess"] == null)
                    {
                        tbSelectedDate.Text = DateTime.Today.ToString("MM/dd/yyyy");
                    }
                    else
                    {
                        tbSelectedDate.Text = Request.QueryString["datetoprocess"];
                    }

                    if (rd.wu.usr.timeSheetUserInfo.roleID == 1)
                    {
                        PanelEmployeeOnly.Visible = false;
                        PanelAdminEmployees.Visible = true;
                        PopulateDropDownListEmployees();
                    }
                    else
                    {
                        PanelEmployeeOnly.Visible = true;
                        PanelAdminEmployees.Visible = false;
                        GetEmployeeName();
                    }
                    HiddenFieldDateTimeEntry.Value = tbSelectedDate.Text;
                    GetIDForTimeEntry();
                }
                else
                {
                    PanelDateEntry.Visible = false;
                    PanelInsert.Visible = true;
                    LabelProblem.Text = string.Empty;
                    GetQueryStringValue();
                }
                if (Request.UrlReferrer == null || (Request.UrlReferrer.ToString().Contains("InsertOrUpdateTimeEntry.aspx")))
                {
                    HiddenFieldPreviousPage.Value = "WebFormTimeEntry.aspx";
                }
                else
                {
                    HiddenFieldPreviousPage.Value = System.IO.Path.GetFileName(Request.UrlReferrer.LocalPath);
                }
                InitializePage();
                if (HiddenFieldTimeEntryID.Value != "0" && !string.IsNullOrEmpty(HiddenFieldTimeEntryID.Value))
                {
                    SetControlsForExistingRecord();
                }
                PopulateGrid();
                DisplayScheduleAndEnteredTimeTotals();
            }
            else
            {
                if (bool.Parse(HiddenFieldDisplayStartTime.Value) && bool.Parse(HiddenFieldDisplayStopTime.Value))
                {
                    var ctrlName = Request.Params[Page.postEventSourceID];
                    var args = Request.Params[Page.postEventArgumentID];

                    HandleCustomPostbackEvent(ctrlName, args);
                }
            }
        }
        private void CheckIfNeedToVerifyHours(SqlConnection con)
        {

            string warning_out = "", warning_out_hidden = "";

            string _lastDayOfSchedule = string.Empty;
            PanelVerifyHours.Visible = MBA.Security.BitteTimePeople.isHourVerifyRequired(con, log, uInfo, HiddenFieldEmployeeID.Value, ref warning_out, ref warning_out_hidden, ref _lastDayOfSchedule);
            HiddenFieldLastDayOfSchedule.Value = _lastDayOfSchedule;

            LabelVerifyPrompt.Text = warning_out;
            HiddenFieldVerifyId.Value = warning_out_hidden;
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
                _sqlCommand.Parameters.AddWithValue("@employeeID", HiddenFieldEmployeeID.Value);
                _sqlCommand.Parameters.AddWithValue("@lastDayOfSchedule", HiddenFieldLastDayOfSchedule.Value);
                _sqlCommand.Parameters.AddWithValue("@dateVerified", DateTime.Today.ToString("MM/dd/yyyy"));
                _sqlCommand.Parameters.AddWithValue("@comments", HiddenFieldComments.Value);
                _sqlCommand.Parameters.AddWithValue("@WhoVerifiedHours", rd.wu.usr.id);

                _sqlCommand.ExecuteNonQuery();


            }
            this.gotoNewURL(homeLink);
        }

        private void PopulateDropDownListEmployees()
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
                    DropDownListEmployees.SelectedValue = HiddenFieldEmployeeID.Value;
                }
            }
        }
        private void HandleCustomPostbackEvent(string ctrlName, string args)
        {
            //Since this will get called for every postback, we only
            // want to handle a specific combination of control
            // and argument.
            if (ctrlName == TextBoxStopTime.UniqueID && args == "OnBlur")
            {
                DateTime _end = DateTime.Parse("01-01-2000 " + TextBoxStopTime.Text);
                DateTime _start = DateTime.Parse("01-01-2000 " + TextBoxStartTime.Text);
                TimeSpan _timeSpan = _end.Subtract(_start);

                LiteralHours.Text = _timeSpan.Hours.ToString();
                LiteralMinutes.Text = _timeSpan.Minutes.ToString();

                TextBoxHours.Text = LiteralHours.Text;
                TextBoxMinutes.Text = LiteralMinutes.Text;
            }
        }
        private void PopulateGrid()
        {
            HiddenFieldTotalTime.Value = "0";
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                CheckIfNeedToVerifyHours(_con);

                SqlDataAdapter _sqlAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetTimeEntry", _con);
                _sqlAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
                _sqlAdapter.SelectCommand.Parameters.Add("@Id", SqlDbType.BigInt).Value = Convert.ToInt64(HiddenFieldTimeEntryDayID.Value);
                DataSet _dataSet = new DataSet();
                _sqlAdapter.Fill(_dataSet);

                HiddenFieldTotalTime.Value = "0";
                LabelEnterBreakInfo.Visible = false;
                if (_dataSet.Tables[0].Rows.Count <= 0)
                {
                    GridView1.DataSource = null;
                    GridView1.DataBind();
                    return;
                }

                GridView1.DataSource = _dataSet;
                GridView1.DataBind();

                if (double.Parse(HiddenFieldTotalTime.Value) / 60.0 > 3)
                {
                    CheckForBreak(_dataSet);
                }

                if (bool.Parse(HiddenFieldDisplayStartTime.Value))
                {
                    ((TemplateField)GridView1.Columns[1]).HeaderText = "<br/>Date and Time of Task<br/><br/>";
                }
                else
                {
                    ((TemplateField)GridView1.Columns[1]).HeaderText = "<br/>Date of Task<br/><br/>";
                }
            }
        }

        private void CheckForBreak(DataSet dataSet)
        {
            bool _foundBreak = false;
            foreach(DataRow _dataRow in dataSet.Tables[0].Rows)
            {
                if (_dataRow["task"].ToString().Contains("Paid Break"))
                {
                    _foundBreak = true;
                    break;
                }
            }

            if (_foundBreak)
            {
                LabelEnterBreakInfo.Visible = false;
            }
            else
            {
                LabelEnterBreakInfo.Visible = true;
            }
        }
        private void SetTaskInFavoriteListBox(string taskID, SqlConnection con)
        {
            if (ListBoxFavoriteTaskTimeEntry.Items.FindByValue(taskID) == null)
            {
                string _sqlInsertStatement = @"
                     insert into TimeKeeper.dbo.Employee_TimeEntry_Tasks_Favorites
                     (
                         EmployeeID
                         ,taskID
                     )
                     values
                     (
                         @EmployeeID
                         ,@TaskID
                     )";

                SqlCommand _sqlInsertCommand = new SqlCommand(_sqlInsertStatement, con);
                _sqlInsertCommand.Parameters.AddWithValue("@EmployeeID", HiddenFieldEmployeeID.Value);
                _sqlInsertCommand.Parameters.AddWithValue("@TaskID", taskID);
                _sqlInsertCommand.CommandType = CommandType.Text;
                _sqlInsertCommand.ExecuteNonQuery();

                PopulateTimeEntryTaskFavorites(con);
            }
            ListBoxFavoriteTaskTimeEntry.SelectedValue = taskID;
        }
        private void PopulateTimeEntryTaskFavorites(SqlConnection con)
        {
            ListBoxFavoriteTaskTimeEntry.DataSource = GetListTaskFavorites(con);
            ListBoxFavoriteTaskTimeEntry.DataTextField = "name";
            ListBoxFavoriteTaskTimeEntry.DataValueField = "id";
            ListBoxFavoriteTaskTimeEntry.DataBind();

            if (ListBoxFavoriteTaskTimeEntry.Items.Count > 0)
            {
                ListBoxFavoriteTaskTimeEntry.SelectedIndex = 0;
            }
        }


        private void SetClientInFavoriteListBox(string orgClientID, SqlConnection con)
        {
            // If client is not null and not found in courrent list rebuild list found
            if (string.IsNullOrEmpty(orgClientID))
            {
                ListBoxFavoriteClientTimeEntry.SelectedValue = "0";
                return;
            }

            if (ListBoxFavoriteClientTimeEntry.Items.FindByValue(orgClientID) == null)
            {
                string _sqlInsertStatement = @"
                     insert into TimeKeeper.dbo.Employee_Organization_Favorites
                     (
                         EmployeeID
                         ,clientOrganizationID
                     )
                     values
                     (
                         @EmployeeID
                         ,@OrganizationClientID
                     )";

                SqlCommand _sqlInsertCommand = new SqlCommand(_sqlInsertStatement, con);
                _sqlInsertCommand.Parameters.AddWithValue("@EmployeeID", HiddenFieldEmployeeID.Value);
                _sqlInsertCommand.Parameters.AddWithValue("@OrganizationClientID", orgClientID);
                _sqlInsertCommand.CommandType = CommandType.Text;
                _sqlInsertCommand.ExecuteNonQuery();

                PopulateListBoxFavoriteClient(con);
            }
            ListBoxFavoriteClientTimeEntry.SelectedValue = orgClientID;
        }
        private void SetControlsForExistingRecord()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();

                SqlDataAdapter _sqlAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetTimeEntryById", _con);
                _sqlAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
                _sqlAdapter.SelectCommand.Parameters.Add("@Id", SqlDbType.BigInt).Value = Convert.ToInt64(HiddenFieldTimeEntryID.Value);
                DataTable _dt = new DataTable();
                _sqlAdapter.Fill(_dt);

                if (_dt.Rows.Count <= 0)
                {
                    return;
                }

                DataRow _dataRow = _dt.Rows[0];

                HiddenFieldHasMultipleClients.Value = _dataRow["HasMultipleClients"].ToString();

                // If an error occurs ignore it
                try
                {
                    DropDownListEmployer.SelectedValue = _dataRow["employer_id"].ToString();
                }
                catch
                {

                }

                // Possible Favorites change
                try
                {
                    if (_dataRow.IsNull("orgClientID"))
                        ListBoxFavoriteClientTimeEntry.SelectedValue = "0";
                    else
                        ListBoxFavoriteClientTimeEntry.SelectedValue = _dataRow["orgClientID"].ToString();
                }
                catch
                {
                    if (RadioButtonListTaskType.SelectedIndex == 2)
                    {
                        ListBoxFavoriteClientTimeEntry.ClearSelection();
                    }
                    else if (ListBoxFavoriteTaskTimeEntry.Items.Count > 0)
                    {
                        ListBoxFavoriteTaskTimeEntry.SelectedIndex = 0;
                    }
                }

                SetClientInFavoriteListBox(_dataRow["orgClientID"].ToString(), _con);

                SetTaskInFavoriteListBox(_dataRow["timeEntrytaskID"].ToString(), _con);

                DateTime _timeOfTask = DateTime.Parse(_dataRow["timeOfTask"].ToString());

                TextBoxStartTime.Text = _timeOfTask.ToString("HH:mm");

                int _numberOfMinutes = (int)_dataRow["numberMinutes"];
                int _numberHours = _numberOfMinutes / 60;
                int _numberMintues = _numberOfMinutes % 60;

                TextBoxHours.Text = _numberHours.ToString();
                TextBoxMinutes.Text = _numberMintues.ToString();

                string _note = string.Empty;

                if (!string.IsNullOrEmpty(_dataRow["note"].ToString()))
                {
                    _note = _dataRow["note"].ToString().Replace("&amp;", "&").Replace("&lt;", "<").Replace("&gt;", ">").Replace("&quot;", "\"").Replace("&apos;", "'");
                }
                TextBoxNotes.Text = _note;

                // SBC TODO: Version 1.5 rename column to smart sheet and remove IsHelp and IsProject management fields
                // along with ITPM_ID.  Rename HD_ROW_ID to SmartSheetID
                TextBoxSmartSheetID.Text = _dataRow["HD_ROW_ID"].ToString();
                TextBoxReferenceDocumentFileName.Text = _dataRow["FileNameReference"].ToString();
                if (_dataRow.IsNull("FileComments"))
                {
                    TextBoxFile.Text = string.Empty;
                    CheckboxComplete.Checked = false;
                }
                else
                {
                    TextBoxFile.Text = _dataRow["FileComments"].ToString();
                    CheckboxComplete.Checked = bool.Parse(_dataRow["FileComplete"].ToString());
                }


                DateTime _startTime = DateTime.Parse(_dataRow["timeOfTask"].ToString());
                TextBoxStartTime.Text = _startTime.ToString("hh:mm tt");
                TextBoxStopTime.Text = _startTime.AddMinutes(_numberOfMinutes).ToString("hh:mm tt");
            }
        }
        private void GetQueryStringValue()
        {
            try
            {
                if (rd.wu.usr.timeSheetUserInfo == null)
                {
                    rd.wu.usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(rd.wu.usr.userName);
                }

                // Only allow employee id in query string if person is admin
                if (rd.wu.usr.timeSheetUserInfo.roleID == 1)
                {
                    long _employeeId = Convert.ToInt64(Request.QueryString["employeeid"]);
                    HiddenFieldEmployeeID.Value = _employeeId.ToString();
                }
                else
                {
                    HiddenFieldEmployeeID.Value = rd.wu.usr.timeSheetUserInfo.employeeid.ToString();
                }

                if (rd.wu.usr.timeSheetUserInfo.roleID == 1)
                {
                    PanelEmployeeOnly.Visible = false;
                    PanelAdminEmployees.Visible = true;
                    PopulateDropDownListEmployees();
                }
                else
                {
                    PanelEmployeeOnly.Visible = true;
                    PanelAdminEmployees.Visible = false;
                    GetEmployeeName();
                }

                HiddenFieldDateTimeEntry.Value = DateTime.Parse(Request.QueryString["timentrydate"]).ToString("MM/dd/yyyy");

                GetIDForTimeEntry();
            }
            catch
            {
                Response.Redirect(MBA.HttpApplication.createLink(HiddenFieldPreviousPage.Value, true), false);
            }
        }

        private void GetEmployeeName()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();

                string _sqlStatement = @"
                 select
                      P.lastName
                      ,P.firstName
                 from
                      TimeKeeper.dbo.People P
                      INNER JOIN TimeKeeper.dbo.Employees E
                           ON E.personID = P.id
                 where
                      E.id = @Id";
                SqlDataAdapter _sqlAdapter = new SqlDataAdapter(_sqlStatement, _con);
                _sqlAdapter.SelectCommand.Parameters.AddWithValue("@Id", HiddenFieldEmployeeID.Value);

                DataTable _dataTable = new DataTable();
                _sqlAdapter.Fill(_dataTable);

                if (_dataTable.Rows.Count == 0)
                {
                    return;
                }

                DataRow _dataRow = _dataTable.Rows[0];

                LiteralEmployeeName.Text = _dataRow["firstName"].ToString() + " " + _dataRow["lastName"].ToString();
            }
        }
        private void GetIDForTimeEntry()
        {
            using (SqlConnection _connection = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _connection.Open();
                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetTimeEntryDayForEmployeeAndDate", _connection);
                _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
                _sqlDataAdapter.SelectCommand.Parameters.Add("@EmployeeId", SqlDbType.BigInt).Value = Convert.ToInt64(HiddenFieldEmployeeID.Value);
                _sqlDataAdapter.SelectCommand.Parameters.Add("@StartDate", SqlDbType.DateTime).Value = DateTime.Parse(HiddenFieldDateTimeEntry.Value).Date;

                DataSet _dataSet = new DataSet();
                _sqlDataAdapter.Fill(_dataSet);

                if (_dataSet.Tables[0].Rows.Count == 0)
                {
                    HiddenFieldTimeEntryDayID.Value = "0";
                    return;
                }

                DataRow _dataRow = _dataSet.Tables[0].Rows[0];
                HiddenFieldTimeEntryDayID.Value = _dataRow["id"].ToString();
            }
        }

        private void InitializePage()
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                con.Open();

                PopulateDropDownListEmployer(con);
                PopulateListBoxFavoriteClient(con);
                PopluateListBoxFavoriteTask(con);

                bool _displayStartTime = false;
                bool _displayStopTime = false;
                DetermineIfStopAndStartTimeRequried(con, ref _displayStartTime, ref _displayStopTime);

                LiteralDateOfEntry.Text = HiddenFieldDateTimeEntry.Value;

                DisplayScheduleAndEnteredTimeTotals();
            }
        }

        private void SetTimeEntryControls(bool displayStarTime, bool displayStopTime)
        {
            if (displayStarTime && displayStopTime)
            {
                TextBoxHours.Visible = false;
                TextBoxMinutes.Visible = false;
                LiteralHours.Visible = true;
                LiteralMinutes.Visible = true;

                var onBlurScript = Page.ClientScript.GetPostBackEventReference(TextBoxStopTime, "OnBlur");
                TextBoxStopTime.Attributes.Add("onblur", onBlurScript);
            }
            else
            {
                TextBoxHours.Visible = true;
                TextBoxMinutes.Visible = true;
                LiteralHours.Visible = false;
                LiteralMinutes.Visible = false;
            }


            if (displayStarTime)
            {
                LiteralStartTime.Visible = true;
                PanelStartTime.Visible = true;
            }
            else
            {
                LiteralStartTime.Visible = false;
                PanelStartTime.Visible = false;
            }

            if (displayStopTime)
            {
                LiteralStopTime.Visible = true;
                PanelStopTime.Visible = true;
            }
            else
            {
                LiteralStopTime.Visible = false;
                PanelStopTime.Visible = false;
            }

        }

        private void DetermineIfStopAndStartTimeRequried(SqlConnection con, ref bool displayStartTime, ref bool displayStopTime)
        {
            string _taskId = ListBoxFavoriteTaskTimeEntry.SelectedValue;

            if (string.IsNullOrEmpty(_taskId))
            {
                return;
            }

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetTaskInformation", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", _taskId);

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            if (_dataTable.Rows.Count <= 0)
            {
                return;
            }

            DataRow _dataRow = _dataTable.Rows[0];

            if (bool.Parse(_dataRow["SpecifyStartStopTime"].ToString()))
            {
                displayStartTime = true;
                displayStopTime = true;
                HiddenFieldDisplayStartTime.Value = "true";
                HiddenFieldDisplayStopTime.Value = "true";

            }
            else
            {
                displayStartTime = false;
                displayStopTime = false;
                HiddenFieldDisplayStartTime.Value = "false";
                HiddenFieldDisplayStopTime.Value = "false";
            }
            SetTimeEntryControls(displayStartTime, displayStopTime);
        }

        private void PopluateListBoxFavoriteTask(SqlConnection con)
        {
            ListBoxFavoriteTaskTimeEntry.DataSource = GetListTaskFavorites(con);
            ListBoxFavoriteTaskTimeEntry.DataTextField = "name";
            ListBoxFavoriteTaskTimeEntry.DataValueField = "id";
            ListBoxFavoriteTaskTimeEntry.DataBind();

            if (RadioButtonListTaskType.SelectedIndex == 2)
            {
                ListBoxFavoriteClientTimeEntry.ClearSelection();
            }
            else if (ListBoxFavoriteClientTimeEntry.Items.Count > 0)
            {
                ListBoxFavoriteClientTimeEntry.SelectedIndex = 0;
            }
        }
        private void PopulateListBoxFavoriteClient(SqlConnection con)
        {
            ListBoxFavoriteClientTimeEntry.DataSource = GetFavoriteClients(con);
            ListBoxFavoriteClientTimeEntry.DataTextField = "name";
            ListBoxFavoriteClientTimeEntry.DataValueField = "id";
            ListBoxFavoriteClientTimeEntry.DataBind();

            ListItem _listItem = new ListItem();
            _listItem.Value = "0";
            _listItem.Text = "All Clients";
            ListBoxFavoriteClientTimeEntry.Items.Insert(0, _listItem);

            if (RadioButtonListTaskType.SelectedIndex == 2)
            {
                ListBoxFavoriteClientTimeEntry.ClearSelection();
            }
            else if (ListBoxFavoriteClientTimeEntry.Items.Count > 0)
            {
                ListBoxFavoriteClientTimeEntry.SelectedIndex = 0;
            }
        }
        private DataTable GetFavoriteClients(SqlConnection con)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetClientFavorites", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@EmployeeID", HiddenFieldEmployeeID.Value);

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);


            if (_dataTable.Rows.Count == 0)
            {
                SqlDataAdapter _sqlDataAdapter2 = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetClient", con);
                _sqlDataAdapter2.SelectCommand.CommandType = CommandType.StoredProcedure;

                DataTable _dataTable2 = new DataTable();
                _sqlDataAdapter2.Fill(_dataTable);

                return _dataTable2;
            }

            return _dataTable;
        }

        private void PopulateDropDownListEmployer(SqlConnection con)
        {
            string _sqlStatement = @"select
                                                  o.id,
                                                  o.name
                                             from
                                                  TimeKeeper.dbo.Employees e
                                                  inner join TimeKeeper.dbo.Organizations o
                                                       on o.id = e.organizationID
                                             where
                                                  e.id = @Id
                                                  and o.active = 1";

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", HiddenFieldEmployeeID.Value);
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);
            DropDownListEmployer.DataSource = _dataTable;
            DropDownListEmployer.DataTextField = "name";
            DropDownListEmployer.DataValueField = "id";
            DropDownListEmployer.DataBind();

            if (DropDownListEmployer.Items.Count > 0)
            {
                DropDownListEmployer.SelectedIndex = 0;
            }

        }

        private DataTable GetListTaskFavorites(SqlConnection con)
        {
            string _sqlStatement = @"
                     select
                          TET.id
                          ,TET.name
                     from
                          TimeKeeper.dbo.TimeEntry_Tasks TET";
            string _sqlStatementJoin = @"
                          inner join TimeKeeper.dbo.Employee_TimeEntry_Tasks_Favorites ETTF
                               ON ETTF.taskID = TET.id
                          inner join TimeKeeper.dbo.Employees E
                               ON E.id = ETTF.EmployeeID";
            string _sqlStatementWhere = @"
                     where
                          E.id = @EmployeeID
                          AND TET.active = 1";

            if (DateTime.Today < DateTime.Parse(HiddenFieldDateTimeEntry.Value))
            {
                _sqlStatementWhere += " AND TET.CanBeScheduledInTheFuture = 1";
            }

            // Filter records based on ability to select single or multiple clients if specified in DropDownList
            if (RadioButtonListTaskType.SelectedValue == "1")
            {
                _sqlStatementWhere += " AND TET.CanHaveMultipleClients = 0";
            }
            else if (RadioButtonListTaskType.SelectedValue == "2")
            {
                _sqlStatementWhere += " AND TET.CanHaveMultipleClients = 1";
            }

            string _orderByClause = @"
                     order by
                          TET.name";

            string _sqlToExecute = _sqlStatement + _sqlStatementJoin + _sqlStatementWhere + _orderByClause;

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlToExecute, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@EmployeeID", HiddenFieldEmployeeID.Value);

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            if (_dataTable.Rows.Count == 0)
            {
                _sqlStatementWhere = string.Empty;

                if (RadioButtonListTaskType.SelectedValue == "1")
                {
                    _sqlStatementWhere += " WHERE TET.CanHaveMultipleClients = 0 ";
                }
                else if (RadioButtonListTaskType.SelectedValue == "2")
                {
                    _sqlStatementWhere += " WHERE TET.CanHaveMultipleClients = 1";
                }

                _sqlToExecute = _sqlStatement + _sqlStatementWhere + _orderByClause;
                SqlDataAdapter _sqlDataAdapter2 = new SqlDataAdapter(_sqlToExecute, con);
                DataTable _dataTable2 = new DataTable();
                _sqlDataAdapter2.Fill(_dataTable2);

                return _dataTable2;
            }

            return _dataTable;

        }

        protected void Back(object sender, EventArgs e)
        {
            PanelRecord.Visible = false;
            PanelInsert.Visible = true;
            DisplayScheduleAndEnteredTimeTotals();
        }

        protected void Save(object sender, EventArgs e)
        {
            if (rd.wu.usr.timeSheetUserInfo == null)
            {
                rd.wu.usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(rd.wu.usr.userName);
            }

            if (rd.wu.usr.timeSheetUserInfo.employeeid.ToString() != HiddenFieldEmployeeID.Value)
            {
                ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                    "Cannot modify hours of another employee",
                    "alert('You can only modify hours for your own time sheet');",
                true);
                return;
            }

            Page.Validate("TimeEntries");

            LabelProblem.Text = string.Empty;

            if (string.IsNullOrEmpty(TextBoxHours.Text.Trim()))
            {
                TextBoxHours.Text = "0";
            }

            if (string.IsNullOrEmpty(TextBoxMinutes.Text.Trim()))
            {
                TextBoxMinutes.Text = "0";
            }

            if (FifteenMinuteBreakRuleBroken())
            {
                return;
            }

            bool _displayStartTime = bool.Parse(HiddenFieldDisplayStartTime.Value);
            bool _displayStopTime = bool.Parse(HiddenFieldDisplayStopTime.Value);

            if (string.IsNullOrEmpty(TextBoxStartTime.Text) && _displayStartTime)
            {
                LabelProblem.Text = "Must specify a start time";
                return;
            }

            if (_displayStartTime && _displayStopTime)
            {
                DateTime _start = DateTime.Parse("01-01-2000 " + TextBoxStartTime.Text);
                DateTime _end = DateTime.Parse("01-01-2000 " + TextBoxStopTime.Text);

                if (_start >= _end)
                {
                    LabelProblem.Text = "Stop time must be after start time";
                    return;
                }
            }

            if (!RequiredTaskFieldsPresent())
            {
                return;
            }

            if (HiddenFieldTimeEntryDayID.Value == "0")
            {
                InsertTimeEntryDay();
            }

            if (HiddenFieldTimeEntryID.Value == "0")
            {
                InsertTimeEntry();
            }
            else
            {
                UpdateTimeEntry();
            }

            CheckTimeEntryValues();

            PopulateGrid();
            PanelRecord.Visible = false;
            PanelInsert.Visible = true;
            //DisplayScheduleAndEnteredTimeTotals();
            string _url = Request.RawUrl;

            int _index = 0;
            if ((_index=_url.IndexOf("&datetoprocess")) > 0)
            {
                _url = _url.Substring(0, _index);
            }
            _url += "&datetoprocess=" + HiddenFieldDateTimeEntry.Value;
            Response.Redirect(_url);
        }

        private bool RequiredTaskFieldsPresent()
        {
            int _selection = 0;
            int.TryParse(ListBoxFavoriteTaskTimeEntry.SelectedValue, out _selection);

            if (_selection <= 0)
            {
                ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        "Problem with time keeper task",
                        "alert('You did not select a task.');",
                        true);
                return false;
            }
            int.TryParse(ListBoxFavoriteClientTimeEntry.SelectedValue, out _selection);

            if (_selection <= 0)
            {
                ListBoxFavoriteClientTimeEntry.SelectedValue = "0";
            }

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                string _sqlStatement = @"
                select
	                id
	                ,ISNULL(IsProjectManagementRequired, 0) AS IsProjectManagementRequired
	                ,ISNULL(IsITHelpDeskRequired, 0) AS IsITHelpDeskRequired
	                ,ISNULL(IsITPM_ID_Required, 0) AS IsITPM_ID_Required
	                ,ISNULL(IsHD_ROW_ID_Required, 0) AS IsHD_ROW_ID_Required
	                ,ISNULL(IsDescriptionRequired, 0) AS IsDescriptionRequired
	                ,ISNULL(IsFileNameReferenceRequired, 0) AS IsFileNameReferenceRequired
                    ,ISNULL(defaultMinDuration, '') AS defaultMinDuration
                from
	                TimeKeeper.dbo.TimeEntry_Tasks
                where
	                id = @Id";

                DataTable _dataTable = new DataTable();
                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", ListBoxFavoriteTaskTimeEntry.SelectedValue);
                _sqlDataAdapter.Fill(_dataTable);

                if (_dataTable.Rows.Count == 0)
                {
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                            "Problem with time keeper task",
                            "alert('Unable to retrieve task record for verification.');",
                            true);
                    return false;
                }

                DataRow _dataRow = _dataTable.Rows[0];
                // SBC TODO: Version 1.5 rename column to smart sheet and remove IsHelp and IsProject management fields
                // along with ITPM_ID.  Rename HD_ROW_ID to SmartSheetID
                bool _isFileNameReferenceRequired = _dataRow["IsFileNameReferenceRequired"].ToString() == "True" ? true : false;

                if (_isFileNameReferenceRequired && string.IsNullOrEmpty(TextBoxReferenceDocumentFileName.Text))
                {
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                            "Problem with time keeper task",
                            "alert('Document reference file name is required.');",
                            true);
                    return false;
                }

                string _defaultMinDuration = _dataRow["defaultMinDuration"].ToString();

                if (!string.IsNullOrEmpty(_defaultMinDuration))
                {
                    int _hours = int.Parse(TextBoxHours.Text);
                    int _minutes = int.Parse(TextBoxMinutes.Text);
                    int _defaultMin = 0;

                    if ((_defaultMin = int.Parse(_defaultMinDuration)) > _hours * 60 + _minutes)
                    {
                        ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                                "Problem with time keeper task",
                                "alert('You must specify at least " + _defaultMin.ToString() + " minutes for this task');",
                                true);
                        return false;
                    }
                }
            }

            return true;
        }
        private bool CheckTimeEntryValues()
        {
            bool _errorPresent = false;

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                /* A little difficult trying to parse values going go with hard coded rules for now
                string _sqlStatement = @"
                    SELECT [id]
                          ,[name]
                          ,[description]
                          ,[type]
                          ,[system]
                          ,[doesFLSAapply]
                          ,[granularity]
                          ,[minutes]
                          ,[hours]
                          ,[days]
                          ,[message]
                          ,[timeEntryTaskId]
                    FROM [TimeKeeper].[dbo].[TimeEntryExceptions]
                    WHERE [system] = 1";

                DataTable _dataTable = new DataTable();
                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                _sqlDataAdapter.Fill(_dataTable);

                foreach(DataRow _row in _dataTable.Rows)
                {
                    int _granularity = int.Parse(_row["granularity"].ToString());
                    switch(_granularity)
                    {
                        // Specified
                        case 0:
                            _errorPresent = EvaluateSpecifiedException(_row, _con);
                            break;
                        // Weekly
                        case 1:
                            _errorPresent = EvaluateWeeklyEntries(_row, _con);
                            break;
                        // Daily
                        case 2:
                            _errorPresent = EvaluateDailyEntries(_row, _con);
                            break;
                        // RecordInstance
                        case 3:
                            EavluateRecord(_row);
                            break;
                    }
                }
                */
                EvaluateWeeklyEntries(_con);
                EvaluateDailyEntries(_con);

            }

            return _errorPresent;
        }

        private void EvaluateWeeklyEntries(SqlConnection con)
        {
            int _numberDays = 0;
            int _numberMinutesInTheWeek = GetMinutesInTheWeek(con, ref _numberDays);

            // Make sure hours doesn't exceed 40
            if ((_numberMinutesInTheWeek > 2786) || (_numberDays > 6))
            {
                ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                    "WARNING",
                    "alert('Your time entries have resulted in overtime.  Please review as overtime must be preapproved.');",
                    true);
            }
        }
        private bool EvaluateWeeklyEntries(DataRow row, SqlConnection con)
        {
            bool _isErrorPresent = false;
            int _valueOfException = 0;
            string _record = string.Empty;
            int _index = 0;
            string _booleanOperator = string.Empty;
            int _numberDays = 0;
            int _numberMinutesInTheWeek = GetMinutesInTheWeek(con, ref _numberDays);
            bool _isErrorException = row["type"].ToString() == "0" ? false : true;
            string _message = row["message"].ToString();

            if (!row.IsNull("minutes"))
            {
                _record = row["minutes"].ToString();
                if ((_index = GetIndexOfOperator(_record)) == -1)
                {
                    return _isErrorException;
                }
                _valueOfException = int.Parse(_record.Substring(0, _index));
                _booleanOperator = _record.Substring(_index, _record.Length - _index);
                _isErrorPresent = isThereAProblem(_isErrorException, _booleanOperator, _valueOfException, _numberMinutesInTheWeek, _message);
            }

            if (!row.IsNull("hours"))
            {
                _record = row["hours"].ToString();
                if ((_index = GetIndexOfOperator(_record)) == -1)
                {
                    return _isErrorException;
                }
                _valueOfException = int.Parse(_record.Substring(0, _index));
                _booleanOperator = _record.Substring(_index, _record.Length - _index);
                _isErrorPresent = isThereAProblem(_isErrorException, _booleanOperator, _valueOfException, _numberMinutesInTheWeek, _message);
            }

            if (!row.IsNull("days"))
            {
                _record = row["hours"].ToString();
                if ((_index = GetIndexOfOperator(_record)) == -1)
                {
                    return _isErrorException;
                }
                _valueOfException = int.Parse(_record.Substring(0, _index));
                _booleanOperator = _record.Substring(_index, _record.Length - _index);
                _isErrorPresent = isThereAProblem(_isErrorException, _booleanOperator, _valueOfException, _numberMinutesInTheWeek, _message);
            }

            return _isErrorPresent;
        }

        private int GetIndexOfOperator(string record)
        {
            int _index = 0;

            if ((_index = record.IndexOf("=")) != -1)
                return _index;
            if ((_index = record.IndexOf("!=")) != -1)
                return _index;
            if ((_index = record.IndexOf(">")) != -1)
                return _index;
            if ((_index = record.IndexOf(">=")) != -1)
                return _index;
            if ((_index = record.IndexOf("<")) != -1)
                return _index;
            if ((_index = record.IndexOf("<=")) != -1)
                return _index;

            return -1;
        }

        private bool isThereAProblem(bool isErrorException, string booleanOperator, int valueOfException, int numberMinutesInTheWeek, string message)
        {
            bool _isErrorPresent = false;

            if (booleanOperator.Equals("="))
            {
                if (valueOfException == numberMinutesInTheWeek)
                {
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        isErrorException ? "ERROR" : "WARNING",
                        "alert('" + message + "');",
                        true);
                }
                _isErrorPresent = isErrorException ? true : false;
            }

            if (booleanOperator.Equals("!="))
            {
                if (valueOfException != numberMinutesInTheWeek)
                {
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        isErrorException ? "ERROR" : "WARNING",
                        "alert('" + message + "');",
                        true);
                }
                _isErrorPresent = isErrorException ? true : false;
            }

            if (booleanOperator.Equals(">"))
            {
                if (valueOfException > numberMinutesInTheWeek)
                {
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        isErrorException ? "ERROR" : "WARNING",
                        "alert('" + message + "');",
                        true);
                }
                _isErrorPresent = isErrorException ? true : false;
            }

            if (booleanOperator.Equals(">="))
            {
                if (valueOfException >= numberMinutesInTheWeek)
                {
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        isErrorException ? "ERROR" : "WARNING",
                        "alert('" + message + "');",
                        true);
                }
                _isErrorPresent = isErrorException ? true : false;
            }

            if (booleanOperator.Equals("<"))
            {
                if (valueOfException < numberMinutesInTheWeek)
                {
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        isErrorException ? "ERROR" : "WARNING",
                        "alert('" + message + "');",
                        true);
                }
                _isErrorPresent = isErrorException ? true : false;
            }

            if (booleanOperator.Equals("<="))
            {
                if (valueOfException < numberMinutesInTheWeek)
                {
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        isErrorException ? "ERROR" : "WARNING",
                        "alert('" + message + "');",
                        true);
                }
                _isErrorPresent = isErrorException ? true : false;
            }

            return _isErrorPresent;
        }

        private bool FifteenMinuteBreakRuleBroken()
        {
            bool _fifteenMinuteBreach = false;

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                string _sqlStatement = @"
                SELECT
	                [id]
                FROM
	                [TimeKeeper].[dbo].[TimeEntry_Tasks]
                WHERE
	                [name] = 'Time Off - 15 Minute Paid Break'            ";

                DataTable _dataTable = new DataTable();
                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                _sqlDataAdapter.Fill(_dataTable);

                if (_dataTable.Rows.Count == 0)
                {
                    return false;
                }

                DataRow _dataRow = _dataTable.Rows[0];
                if (ListBoxFavoriteTaskTimeEntry.SelectedValue.Equals(_dataRow["id"].ToString()))
                {
                    if ((int.Parse(TextBoxHours.Text) * 60 + int.Parse(TextBoxMinutes.Text)) != 15)
                    {
                        ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                            "WARNING",
                            "alert('A 15 minute break needs to be 15 minutes');",
                            true);
                        return true;
                    }
                }
                return false;
            }

            return _fifteenMinuteBreach;
        }

        private void EvaluateDailyEntries(SqlConnection con)
        {
            DateTime _todayDate = DateTime.Parse(HiddenFieldDateTimeEntry.Value);
            DateTime _startOfWeek = (_todayDate.DayOfWeek == DayOfWeek.Sunday) ? _todayDate : _todayDate.AddDays(-1 * (int)_todayDate.DayOfWeek);
            DateTime _endOfWeek = (_todayDate.DayOfWeek == DayOfWeek.Saturday) ? _todayDate : _todayDate.AddDays(6 - (int)_todayDate.DayOfWeek);

            string _sqlStatement = @"
            SELECT
                  TD.[dateForTimeEntry]
	              ,sum(TE.numberMinutes) as numberMinutes
            FROM
	            [TimeKeeper].[dbo].[TimeEntry_Day] TD
	            inner join [TimeKeeper].[dbo].[TimeEntries] TE
		            on TE.timeEntryDayID = TD.id
				inner join [TimeKeeper].[dbo].[TimeEntry_Tasks] TET
					on TET.id = TE.timeEntrytaskID
              WHERE
	            TD.[employeeID] = @EmployeeID
                AND TD.dateForTimeEntry = @DateForTimeEntry
                AND TET.name not like '%unpaid%'
			GROUP BY
				TD.[dateForTimeEntry]";

            DataTable _dataTable = new DataTable();
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@EmployeeID", HiddenFieldEmployeeID.Value);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@DateForTimeEntry", HiddenFieldDateTimeEntry.Value);
            _sqlDataAdapter.Fill(_dataTable);

            int _totalMintues = 0;
            foreach (DataRow _row in _dataTable.Rows)
            {
                _totalMintues += int.Parse(_row["numberMinutes"].ToString());
            }

            if (_totalMintues > 480)
            {
                ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                    "WARNING",
                    "alert('Your time entries have resulted in overtime.  Please review as overtime must be preapproved.');",
                    true);
            }
        }

        private int GetMinutesInTheWeek(SqlConnection con, ref int numberDays)
        {
            DateTime _todayDate = DateTime.Parse(HiddenFieldDateTimeEntry.Value);
            DateTime _startOfWeek = (_todayDate.DayOfWeek == DayOfWeek.Sunday) ? _todayDate : _todayDate.AddDays(-1 * (int)_todayDate.DayOfWeek);
            DateTime _endOfWeek = (_todayDate.DayOfWeek == DayOfWeek.Saturday) ? _todayDate : _todayDate.AddDays(6 - (int)_todayDate.DayOfWeek);

            string _sqlStatement = @"
            SELECT
                  TD.[dateForTimeEntry]
	              ,sum(TE.numberMinutes) as numberMinutes
            FROM
	            [TimeKeeper].[dbo].[TimeEntry_Day] TD
	            inner join [TimeKeeper].[dbo].[TimeEntries] TE
		            on TE.timeEntryDayID = TD.id
				inner join [TimeKeeper].[dbo].[TimeEntry_Tasks] TET
					on TET.id = TE.timeEntrytaskID
              WHERE
	            TD.[employeeID] = @EmployeeID
                AND TD.dateForTimeEntry >= @StartOfWeek
	            AND TD.dateForTimeEntry <= @EndOfWeek
				AND TET.name not like '%unpaid%'
			GROUP BY
				TD.[dateForTimeEntry]";

            DataTable _dataTable = new DataTable();
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@EmployeeID", HiddenFieldEmployeeID.Value);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@StartOfWeek", _startOfWeek.ToString("MM/dd/yyyy"));
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@EndOfWeek", _endOfWeek.ToString("MM/dd/yyyy"));
            _sqlDataAdapter.Fill(_dataTable);

            int _totalMintues = 0;
            foreach (DataRow _row in _dataTable.Rows)
            {
                _totalMintues += int.Parse(_row["numberMinutes"].ToString());
            }

            numberDays = _dataTable.Rows.Count;

            return _totalMintues;
        }

        private void EavluateRecord(DataRow row)
        {

        }
        private bool EvaluateDailyEntries(DataRow row, SqlConnection con)
        {
            return false;
        }
        private bool EvaluateSpecifiedException(DataRow row, SqlConnection con)
        {
            // Not sure what to do right now about this
            return false;
        }
        private void InsertTimeEntryDay()
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                con.Open();
                SqlCommand cmd = new SqlCommand("TimeKeeper_TIMESHEET_CreateTimeEntryDay", con);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@EmployeeId", Convert.ToInt64(HiddenFieldEmployeeID.Value));
                cmd.Parameters.AddWithValue("@dateForTimeEntry", DateTime.Parse(HiddenFieldDateTimeEntry.Value).Date);
                cmd.Parameters.Add("@Id", SqlDbType.BigInt);
                cmd.Parameters["@Id"].Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();
                HiddenFieldTimeEntryDayID.Value = cmd.Parameters["@Id"].Value.ToString();
            }
        }

        private void DeleteTimeEntry()
        {
            if (rd.wu.usr.timeSheetUserInfo == null)
            {
                rd.wu.usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(rd.wu.usr.userName);
            }

            if (rd.wu.usr.timeSheetUserInfo.employeeid.ToString() != HiddenFieldEmployeeID.Value)
            {
                ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                    "Cannot modify hours of another employee",
                    "alert('You can only modify hours for your own time sheet');",
                true);
                return;
            }

            string _confirmDelete = Request.Form["confirm_value"];
            if (_confirmDelete != "Yes")
            {
                return;
            }

            using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                con.Open();
                SqlCommand cmd = new SqlCommand("TimeKeeper_TIMESHEET_DeleteTimeEntry", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Id", Convert.ToInt64(HiddenFieldTimeEntryID.Value));

                cmd.ExecuteNonQuery();
            }
            //DisplayScheduleAndEnteredTimeTotals();
            Response.Redirect(Request.RawUrl);
        }
        private void InsertTimeEntry()
        {
            if (ListBoxFavoriteClientTimeEntry.GetSelectedIndices().Count() > 1)
            {
                HiddenFieldHasMultipleClients.Value = "True";
                InsertMultipleEntries();
            }
            else
            {
                HiddenFieldHasMultipleClients.Value = "False";
                InsertSingleTimeEntry(Convert.ToInt64(ListBoxFavoriteClientTimeEntry.SelectedValue), false);
            }
        }

        private void InsertMultipleEntries()
        {
            int [] _selectedIndices = ListBoxFavoriteClientTimeEntry.GetSelectedIndices();
            string _orgClientID = string.Empty;
            bool _calcMinutes = true;

            for (int _counter = 0; _counter < _selectedIndices.Length; ++_counter)
            {
                // Do not insert all clients for multiple select
                if  (!(_orgClientID = ListBoxFavoriteClientTimeEntry.Items[_selectedIndices[_counter]].Value).Equals(HiddenFieldAllClientID.Value))
                {
                    // Only calculate minutes for first entry
                    InsertSingleTimeEntry(long.Parse(_orgClientID), true, _calcMinutes);
                    _calcMinutes = false;
                }
            }
        }

        private void InsertSingleTimeEntry(long orgClientID, bool multipleClients, bool calcMinutes = true)
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                con.Open();
                SqlCommand cmd = new SqlCommand("TimeKeeper_TIMESHEET_CreateTimeEntry", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@timeEntryDayID", Convert.ToInt64(HiddenFieldTimeEntryDayID.Value));

                // SBC TODO: Version 1.5 rename column to smart sheet and remove IsHelp and IsProject management fields
                // along with ITPM_ID.  Rename HD_ROW_ID to SmartSheetID
                bool _isProjectManagement = false, _isHelpDesk = false;

                bool _displayStartTime = bool.Parse(HiddenFieldDisplayStartTime.Value);

                if (_displayStartTime)
                {
                    cmd.Parameters.AddWithValue("@timeOfTask", DateTime.Parse(HiddenFieldDateTimeEntry.Value + " " + TextBoxStartTime.Text));
                }
                else
                {
                    cmd.Parameters.AddWithValue("@timeOfTask", DateTime.Parse(HiddenFieldDateTimeEntry.Value));
                }

                int _numberOfMinutes = 0;
                int _hours = 0;
                int _minutes = 0;

                // If multiple client select numberOfMinutes will be 0
                if (calcMinutes)
                {
                    if (TextBoxHours.Visible && TextBoxMinutes.Visible)
                    {
                        _numberOfMinutes = Convert.ToInt32(TextBoxHours.Text) * 60 + Convert.ToInt32(TextBoxMinutes.Text);
                    }
                    else if (!string.IsNullOrEmpty(LiteralHours.Text) && !string.IsNullOrEmpty(LiteralMinutes.Text))
                    {
                        int.TryParse(LiteralHours.Text, out _hours);
                        int.TryParse(LiteralMinutes.Text, out _minutes);
                        _numberOfMinutes = _hours * 60 + _minutes;
                    }
                    else
                    {
                        DateTime _startTime = DateTime.Parse("1-1-2000 " + TextBoxStartTime.Text);
                        DateTime _endTime = DateTime.Parse("1-1-2000 " + TextBoxStopTime.Text);
                        TimeSpan _timeSpan = _endTime - _startTime;
                        _numberOfMinutes = _timeSpan.Hours * 60 + _timeSpan.Minutes;
                    }
                }

                long _timeEntryTaskID = _timeEntryTaskID = Convert.ToInt64(ListBoxFavoriteTaskTimeEntry.SelectedValue);

                cmd.Parameters.AddWithValue("@numberMinutes", _numberOfMinutes);
                cmd.Parameters.AddWithValue("@timeEntrytaskID", _timeEntryTaskID);

                if (orgClientID == 0)
                {
                    cmd.Parameters.AddWithValue("@orgClientID", DBNull.Value);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@orgClientID", orgClientID);
                }

                if (string.IsNullOrEmpty(TextBoxNotes.Text))
                {
                    cmd.Parameters.AddWithValue("@note", DBNull.Value);
                }
                else
                {
                    // This is done client side string _note = TextBoxNotes.Text.Replace("&","&amp;").Replace("<", "&lt;").Replace(">", "&gt;").Replace("\"", "&quot;").Replace("'", "&apos;");
                    cmd.Parameters.AddWithValue("@note", TextBoxNotes.Text);
                }
                cmd.Parameters.AddWithValue("@dateEntryCreated", DateTime.Now);
                cmd.Parameters.AddWithValue("@IsProjectManagement", _isProjectManagement);
                cmd.Parameters.AddWithValue("@IsHelpDesk", _isHelpDesk);

                // SBC TODO: Release to live they no longer wanted this value  insert null for now
                // Do clean up in 1.5
                cmd.Parameters.AddWithValue("@ITPM_ID", DBNull.Value);

                // SBC TODO: HD_ROW_ID represents the smartsheet ID for now refactor code in 1.5 to avoid confustion
                if (string.IsNullOrEmpty(TextBoxSmartSheetID.Text))
                {
                    cmd.Parameters.AddWithValue("@HD_ROW_ID", DBNull.Value);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@HD_ROW_ID", TextBoxSmartSheetID.Text);
                }

                // SBC - TODO: When we went live description was no longer desired.
                // Remove column and refractor code in 1.5
                cmd.Parameters.AddWithValue("@Description", DBNull.Value);

                if (string.IsNullOrEmpty(TextBoxReferenceDocumentFileName.Text))
                {
                    cmd.Parameters.AddWithValue("@FileNameReference", DBNull.Value);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@FileNameReference", TextBoxReferenceDocumentFileName.Text);
                }

                if (string.IsNullOrEmpty(TextBoxFile.Text))
                {
                    cmd.Parameters.AddWithValue("@FileComments", DBNull.Value);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@FileComments", TextBoxFile.Text);
                }

                if (CheckboxComplete.Checked)
                {
                    cmd.Parameters.AddWithValue("@FileComplete", true);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@FileComplete", false);
                }

                cmd.Parameters.AddWithValue("@HasMultipleClients", multipleClients);

                if (bool.Parse(HiddenFieldDisplayStartTime.Value))
                {
                    cmd.Parameters.AddWithValue("@StartEntryDateTime",
                        HiddenFieldDateTimeEntry.Value + " " +TextBoxStartTime.Text);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@StartEntryDateTime", DBNull.Value);
                }

                if (bool.Parse(HiddenFieldDisplayStopTime.Value))
                {
                    cmd.Parameters.AddWithValue("@EndEntryDateTime",
                        HiddenFieldDateTimeEntry.Value + " " + TextBoxStopTime.Text);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@EndEntryDateTime", DBNull.Value);
                }

                cmd.Parameters.AddWithValue("@e_id", DBNull.Value);

                cmd.Parameters.Add("@Id", SqlDbType.BigInt);
                cmd.Parameters["@Id"].Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();
            }

        }

        private void UpdateTimeEntry()
        {
            if (ListBoxFavoriteClientTimeEntry.GetSelectedIndices().Count() > 1)
            {
                HiddenFieldHasMultipleClients.Value = "True";
                DeleteEntriesForTask();
                InsertMultipleEntries();
            }
            else
            {
                // For multiple entries just do an update
                //if (bool.Parse(HiddenFieldHasMultipleClients.Value))
                //{
                //    DeleteEntriesForTask();
                //    InsertSingleTimeEntry(Convert.ToInt64(ListBoxFavoriteClientTimeEntry.SelectedValue), false);
                //}
                //else
                //{
                //    UpdateSingleTimeEntry(Convert.ToInt64(ListBoxFavoriteClientTimeEntry.SelectedValue));
                //}
                UpdateSingleTimeEntry(Convert.ToInt64(ListBoxFavoriteClientTimeEntry.SelectedValue));
                HiddenFieldHasMultipleClients.Value = "False";
            }
        }

        private void DeleteEntriesForTask()
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                con.Open();

                SqlCommand cmd = new SqlCommand("TimeKeeper_TIMESHEET_DeleteTimeEntryForMultipleClient", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@timeEntryDayID", Convert.ToInt64(HiddenFieldTimeEntryDayID.Value));
                cmd.Parameters.AddWithValue("@timeEntrytaskID", Convert.ToInt64(ListBoxFavoriteTaskTimeEntry.SelectedValue));

                cmd.ExecuteNonQuery();
            }
        }
        private void UpdateSingleTimeEntry(long orgClientID)
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                con.Open();
                SqlCommand cmd = new SqlCommand("TimeKeeper_TIMESHEET_UpdateTimeEntry", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Id", Convert.ToInt64(HiddenFieldTimeEntryID.Value));
                cmd.Parameters.AddWithValue("@timeEntryDayID", Convert.ToInt64(HiddenFieldTimeEntryDayID.Value));

                bool _displayStartTime = false;
                bool _displayEndTime = false;

                DetermineIfStopAndStartTimeRequried(con, ref _displayStartTime, ref _displayEndTime);

                if (_displayStartTime)
                {
                    cmd.Parameters.AddWithValue("@timeOfTask", DateTime.Parse(HiddenFieldDateTimeEntry.Value + " " + TextBoxStartTime.Text));
                }
                else
                {
                    cmd.Parameters.AddWithValue("@timeOfTask", DateTime.Parse(HiddenFieldDateTimeEntry.Value));
                }

                int _numberOfMinutes = 0;
                int _hours = 0;
                int _minutes = 0;

                if (TextBoxHours.Visible && TextBoxMinutes.Visible)
                {
                    _numberOfMinutes = Convert.ToInt32(TextBoxHours.Text) * 60 + Convert.ToInt32(TextBoxMinutes.Text);
                }
                else if (!string.IsNullOrEmpty(LiteralHours.Text) && !string.IsNullOrEmpty(LiteralMinutes.Text))
                {
                    int.TryParse(LiteralHours.Text, out _hours);
                    int.TryParse(LiteralMinutes.Text, out _minutes);
                    _numberOfMinutes = _hours * 60 + _minutes;
                }
                else
                {
                    DateTime _startTime = DateTime.Parse("1-1-2000 " + TextBoxStartTime.Text);
                    DateTime _endTime = DateTime.Parse("1-1-2000 " + TextBoxStopTime.Text);
                    TimeSpan _timeSpan = _endTime - _startTime;
                    _numberOfMinutes = _timeSpan.Hours * 60 + _timeSpan.Minutes;
                }

                cmd.Parameters.AddWithValue("@numberMinutes", _numberOfMinutes);
                cmd.Parameters.AddWithValue("@timeEntrytaskID", Convert.ToInt64(ListBoxFavoriteTaskTimeEntry.SelectedValue));

                if (orgClientID == 0)
                {
                    cmd.Parameters.AddWithValue("@orgClientID", DBNull.Value);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@orgClientID", orgClientID);
                }

                if (string.IsNullOrEmpty(TextBoxNotes.Text))
                {
                    cmd.Parameters.AddWithValue("@note", DBNull.Value);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@note", TextBoxNotes.Text);
                }

                cmd.Parameters.AddWithValue("@dateEntryUpdated", DateTime.Now);

                // SBC TODO: When we went live,  decidied they did not want this feature
                // Booleans to false to keep from breaking page
                bool _isProjectManagement = false, _isHelpDesk = false;

                cmd.Parameters.AddWithValue("@IsProjectManagement", _isProjectManagement);

                cmd.Parameters.AddWithValue("@IsHelpDesk", _isHelpDesk);

                // SBC TODO: Release to live, IT Project management ID not wanted insert null for now
                // in 1.5 delete and refractor database to clean up
                cmd.Parameters.AddWithValue("@ITPM_ID", DBNull.Value);

                // SBC TODO: This value will represent the smartsheet id for now
                // in 1.5 refractor code and rename
                if (string.IsNullOrEmpty(TextBoxSmartSheetID.Text))
                {
                    cmd.Parameters.AddWithValue("@HD_ROW_ID", DBNull.Value);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@HD_ROW_ID", TextBoxSmartSheetID.Text);
                }

                // SBC TODO: When we went live no longer want description
                // insert null for now and refactor for 1.5
                cmd.Parameters.AddWithValue("@Description", DBNull.Value);

                if (string.IsNullOrEmpty(TextBoxReferenceDocumentFileName.Text))
                {
                    cmd.Parameters.AddWithValue("@FileNameReference", DBNull.Value);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@FileNameReference", TextBoxReferenceDocumentFileName.Text);
                }

                if (string.IsNullOrEmpty(TextBoxFile.Text))
                {
                    cmd.Parameters.AddWithValue("@FileComments", DBNull.Value);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@FileComments", TextBoxFile.Text);
                }

                if (CheckboxComplete.Checked)
                {
                    cmd.Parameters.AddWithValue("@FileComplete", true);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@FileComplete", false);
                }

                cmd.Parameters.AddWithValue("@HasMultipleClients", false);

                if (bool.Parse(HiddenFieldDisplayStartTime.Value))
                {
                    cmd.Parameters.AddWithValue("@StartEntryDateTime", HiddenFieldDateTimeEntry.Value + " " + TextBoxStartTime.Text);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@StartEntryDateTime", DBNull.Value);
                }

                if (bool.Parse(HiddenFieldDisplayStartTime.Value))
                {
                    cmd.Parameters.AddWithValue("@EndEntryDateTime", HiddenFieldDateTimeEntry.Value + " " + TextBoxStopTime.Text);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@EndEntryDateTime", DBNull.Value);
                }

                cmd.Parameters.AddWithValue("@e_id", DBNull.Value);

                cmd.ExecuteNonQuery();
            }
        }

        protected void GridView1_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
        }

        protected void GridView1_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            HiddenField HiddenFieldItemTemplateIDEdit = (HiddenField)GridView1.Rows[e.RowIndex].FindControl("HiddenFieldItemTemplateIDEdit");
            HiddenFieldTimeEntryID.Value = HiddenFieldItemTemplateIDEdit.Value;

            DeleteTimeEntry();

            PopulateGrid();
            PanelRecord.Visible = false;
            PanelInsert.Visible = true;
        }

        protected void GridView1_RowEditing(object sender, GridViewEditEventArgs e)
        {
            HiddenField HiddenFieldItemTemplateIDEdit = (HiddenField)GridView1.Rows[e.NewEditIndex].FindControl("HiddenFieldItemTemplateIDEdit");
            HiddenFieldTimeEntryID.Value = HiddenFieldItemTemplateIDEdit.Value;

            // For force client list box to single
            ListBoxFavoriteClientTimeEntry.SelectionMode = ListSelectionMode.Single;

            PanelInsert.Visible = false;
            PanelRecord.Visible = true;

            InitializePage();
            SetControlsForExistingRecord();
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
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                DataRow _dataRow = ((DataRowView)e.Row.DataItem).Row;

                if (string.IsNullOrEmpty(_dataRow["id"].ToString()))
                {
                    return;
                }

                Literal LiteralHours = (Literal)e.Row.FindControl("LiteralHours");
                Literal LiteralMinutes = (Literal)e.Row.FindControl("LiteralMinutes");
                HiddenField HiddenFieldHolidayID = (HiddenField)e.Row.FindControl("HiddenFieldHolidayID");

                // Do not count if holiday
                // int _numberOfMinutes = HiddenFieldHolidayID.Value == "0" ? (int)_dataRow["numberMinutes"] : 0;

                int _numberOfMinutes = (int)_dataRow["numberMinutes"];

                // Do not include Time Off in running totals
                if (!_dataRow["task"].ToString().ToLower().Contains("time off"))
                {
                    HiddenFieldTotalTime.Value = (int.Parse(HiddenFieldTotalTime.Value) + _numberOfMinutes).ToString();
                }

                LiteralHours.Text = (_numberOfMinutes / 60).ToString() + " Hours";
                LiteralMinutes.Text = (_numberOfMinutes % 60).ToString() + " Minutes";

                Label LabelTimeOfTask = (Label)e.Row.FindControl("LabelTimeOfTask");

                if (_dataRow.IsNull("StartEntryDateTime"))
                {
                    LabelTimeOfTask.Text = "Not Recorded";
                }
                else
                {
                    LabelTimeOfTask.Text = DateTime.Parse(_dataRow["StartEntryDateTime"].ToString()).ToString("hh:mm tt");
                }

                Label LabelTimeTaskEnded = (Label)e.Row.FindControl("LabelTimeTaskEnded");

                if (_dataRow.IsNull("EndEntryDateTime"))
                {
                    LabelTimeTaskEnded.Text = "Not Recorded";
                }
                else
                {
                    LabelTimeTaskEnded.Text = DateTime.Parse(_dataRow["EndEntryDateTime"].ToString()).ToString("hh:mm tt");
                }

                // Do Not allow edits of Holiday
                if (HiddenFieldHolidayID.Value != "0")
                {
                    HiddenFieldIsHoliday.Value = "true";
                    //System.Web.UI.WebControls.Button ButtonDelete = (System.Web.UI.WebControls.Button)e.Row.FindControl("ButtonDelete");
                    //System.Web.UI.WebControls.Button ButtonEdit = (System.Web.UI.WebControls.Button)e.Row.FindControl("ButtonEdit");
                    //ButtonDelete.Visible = false;
                    //ButtonEdit.Visible = false;
                }
                else if (HiddenFieldIsHoliday.Value != "true")
                {
                    HiddenFieldIsHoliday.Value = "false";
                }

            }
        }
        protected void ButtonInsert_Click(object sender, EventArgs e)
        {
            if (rd.wu.usr.timeSheetUserInfo == null)
            {
                rd.wu.usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(rd.wu.usr.userName);
            }

            if (rd.wu.usr.timeSheetUserInfo.employeeid.ToString() != HiddenFieldEmployeeID.Value)
            {
                    ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        "Cannot modify hours of another employee",
                        "alert('You can only modify hours for your own time sheet');",
                    true);
                return;
            }
            // Make sure person creating new record is represented in this page
            PanelRecord.Visible = true;
            PanelInsert.Visible = false;
            HiddenFieldTimeEntryID.Value = "0"; // INdicates we are creating a new record

            TextBoxStartTime.Text = string.Empty;
            TextBoxStopTime.Text = string.Empty;
            TextBoxHours.Text = "0";
            TextBoxMinutes.Text = "0";
            TextBoxNotes.Text = string.Empty;
            TextBoxFile.Text = string.Empty;
            CheckboxComplete.Checked = false;
        }

        protected void ButtonBack_Click(object sender, EventArgs e)
        {
            string _url = MBA.HttpApplication.createLink(HiddenFieldPreviousPage.Value, true) + "&employeeid=" + HiddenFieldEmployeeID.Value +
                "&dateforentry=" + HiddenFieldDateTimeEntry.Value;
            Response.Redirect(_url, true);
            return;
        }

        protected void GridView1_Sorting(object sender, GridViewSortEventArgs e)
        {
            switch (e.SortExpression)
            {
                case "timeOfTask":
                    BindTimeOfTask();
                    break;
                case "TimeSpent":
                    BindTimeSpent();
                    break;
                case "Task":
                    BindTask();
                    break;
                case "Client":
                    BindClient();
                    break;
                case "Note":
                    BindNote();
                    break;
            }
        }

        private void BindNote()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                if (HiddenFieldNote.Value == "ASC")
                {
                    HiddenFieldNote.Value = "DESC";
                }
                else
                {
                    HiddenFieldNote.Value = "ASC";
                }

                string _sqlStatement =
                  @"SELECT
                    TE.id
                    ,TE.timeEntryDayID
                    ,TE.numberMinutes
                    ,TE.timeOfTask
                    ,TES.name AS 'task'
                    ,TES.id AS 'task_id'
                    ,O.name AS 'client'
                    ,O.id AS 'client_id'
                    ,CASE
	                    WHEN TE.IsProjectManagement = 1 THEN 'true'
	                    ELSE 'false'
	                END AS 'isPM'
	                ,CASE
	                    WHEN TE.IsHelpDesk = 1 THEN 'true'
	                    ELSE 'false'
	                END AS 'isHelpDesk'
	                ,ISNULL(TE.ITPM_ID, '') AS 'ITPM_ID'
	                ,ISNULL(TE.HD_ROW_ID, '') AS 'HD_ROW_ID'
	                ,ISNULL(TE.Description, '') AS 'Description'
	                ,ISNULL(TE.FileNameReference, '') AS 'FileNameReference'
	                ,ISNULL(TE.note, '') AS 'note'
                FROM
                    [TimeKeeper].[dbo].[TimeEntries] TE
                    INNER JOIN [TimeKeeper].[dbo].[TimeEntry_Tasks] TES
	                    ON TES.id = TE.timeEntrytaskID
                    INNER JOIN [TimeKeeper].[dbo].[Organizations] O
	                    ON O.id = TE.orgClientID
                WHERE
                    TE.timeEntryDayID = @TimeEntryDayID
                    and O.active = 1
                ORDER BY note " + HiddenFieldNote.Value;

                SqlDataAdapter sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@TimeEntryDayID", HiddenFieldTimeEntryDayID.Value);
                DataSet _dataSet = new DataSet();
                sqlDataAdapter.Fill(_dataSet);

                HiddenFieldTotalTime.Value = "0";
                LabelEnterBreakInfo.Visible = false;
                if (_dataSet.Tables[0].Rows.Count <= 0)
                {
                    GridView1.DataSource = null;
                    GridView1.DataBind();
                    return;
                }

                GridView1.DataSource = _dataSet;
                GridView1.DataBind();

                if (double.Parse(HiddenFieldTotalTime.Value) / 60.0 > 3)
                {
                    CheckForBreak(_dataSet);
                }
            }
        }

        private void BindClient()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                if (HiddenFieldClient.Value == "ASC")
                {
                    HiddenFieldClient.Value = "DESC";
                }
                else
                {
                    HiddenFieldClient.Value = "ASC";
                }

                string _sqlStatement =
                  @"SELECT
                    TE.id
                    ,TE.timeEntryDayID
                    ,TE.numberMinutes
                    ,TE.timeOfTask
                    ,TES.name AS 'task'
                    ,TES.id AS 'task_id'
                    ,O.name AS 'client'
                    ,O.id AS 'client_id'
                    ,CASE
	                    WHEN TE.IsProjectManagement = 1 THEN 'true'
	                    ELSE 'false'
	                END AS 'isPM'
	                ,CASE
	                    WHEN TE.IsHelpDesk = 1 THEN 'true'
	                    ELSE 'false'
	                END AS 'isHelpDesk'
	                ,ISNULL(TE.ITPM_ID, '') AS 'ITPM_ID'
	                ,ISNULL(TE.HD_ROW_ID, '') AS 'HD_ROW_ID'
	                ,ISNULL(TE.Description, '') AS 'Description'
	                ,ISNULL(TE.FileNameReference, '') AS 'FileNameReference'
	                ,ISNULL(TE.note, '') AS 'note'
                      FROM
                           [TimeKeeper].[dbo].[TimeEntries] TE
                           INNER JOIN [TimeKeeper].[dbo].[TimeEntry_Tasks] TES
	                           ON TES.id = TE.timeEntrytaskID
                           INNER JOIN [TimeKeeper].[dbo].[Organizations] O
	                           ON O.id = TE.orgClientID
                      WHERE
                           TE.timeEntryDayID = @TimeEntryDayID
                           AND O.active = 1
                     ORDER BY client " + HiddenFieldClient.Value;

                SqlDataAdapter sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@TimeEntryDayID", HiddenFieldTimeEntryDayID.Value);
                DataSet _dataSet = new DataSet();
                sqlDataAdapter.Fill(_dataSet);

                HiddenFieldTotalTime.Value = "0";
                LabelEnterBreakInfo.Visible = false;
                if (_dataSet.Tables[0].Rows.Count <= 0)
                {
                    GridView1.DataSource = null;
                    GridView1.DataBind();
                    return;
                }

                GridView1.DataSource = _dataSet;
                GridView1.DataBind();

                if (double.Parse(HiddenFieldTotalTime.Value) / 60.0 > 3)
                {
                    CheckForBreak(_dataSet);
                }
            }
        }

        private void BindTask()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                if (HiddenFieldTask.Value == "ASC")
                {
                    HiddenFieldTask.Value = "DESC";
                }
                else
                {
                    HiddenFieldTask.Value = "ASC";
                }

                string _sqlStatement =
                  @"SELECT
                    TE.id
                    ,TE.timeEntryDayID
                    ,TE.numberMinutes
                    ,TE.timeOfTask
                    ,TES.name AS 'task'
                    ,TES.id AS 'task_id'
                    ,O.name AS 'client'
                    ,O.id AS 'client_id'
                    ,CASE
	                    WHEN TE.IsProjectManagement = 1 THEN 'true'
	                    ELSE 'false'
	                END AS 'isPM'
	                ,CASE
	                    WHEN TE.IsHelpDesk = 1 THEN 'true'
	                    ELSE 'false'
	                END AS 'isHelpDesk'
	                ,ISNULL(TE.ITPM_ID, '') AS 'ITPM_ID'
	                ,ISNULL(TE.HD_ROW_ID, '') AS 'HD_ROW_ID'
	                ,ISNULL(TE.Description, '') AS 'Description'
	                ,ISNULL(TE.FileNameReference, '') AS 'FileNameReference'
	                ,ISNULL(TE.note, '') AS 'note'
                      FROM
                           [TimeKeeper].[dbo].[TimeEntries] TE
                           INNER JOIN [TimeKeeper].[dbo].[TimeEntry_Tasks] TES
	                           ON TES.id = TE.timeEntrytaskID
                           INNER JOIN [TimeKeeper].[dbo].[Organizations] O
	                           ON O.id = TE.orgClientID
                      WHERE
                           TE.timeEntryDayID = @TimeEntryDayID
                           and O.active = 1
                     ORDER BY task " + HiddenFieldTask.Value;

                SqlDataAdapter sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@TimeEntryDayID", HiddenFieldTimeEntryDayID.Value);
                DataSet _dataSet = new DataSet();
                sqlDataAdapter.Fill(_dataSet);

                HiddenFieldTotalTime.Value = "0";
                LabelEnterBreakInfo.Visible = false;
                if (_dataSet.Tables[0].Rows.Count <= 0)
                {
                    GridView1.DataSource = null;
                    GridView1.DataBind();
                    return;
                }

                GridView1.DataSource = _dataSet;
                GridView1.DataBind();

                if (double.Parse(HiddenFieldTotalTime.Value) / 60.0 > 3)
                {
                    CheckForBreak(_dataSet);
                }
            }
        }

        private void BindTimeSpent()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                if (HiddenFieldTimeSpent.Value == "ASC")
                {
                    HiddenFieldTimeSpent.Value = "DESC";
                }
                else
                {
                    HiddenFieldTimeSpent.Value = "ASC";
                }

                string _sqlStatement =
                  @"SELECT
                    TE.id
                    ,TE.timeEntryDayID
                    ,TE.numberMinutes
                    ,TE.timeOfTask
                    ,TES.name AS 'task'
                    ,TES.id AS 'task_id'
                    ,O.name AS 'client'
                    ,O.id AS 'client_id'
                    ,CASE
	                    WHEN TE.IsProjectManagement = 1 THEN 'true'
	                    ELSE 'false'
	                END AS 'isPM'
	                ,CASE
	                    WHEN TE.IsHelpDesk = 1 THEN 'true'
	                    ELSE 'false'
	                END AS 'isHelpDesk'
	                ,ISNULL(TE.ITPM_ID, '') AS 'ITPM_ID'
	                ,ISNULL(TE.HD_ROW_ID, '') AS 'HD_ROW_ID'
	                ,ISNULL(TE.Description, '') AS 'Description'
	                ,ISNULL(TE.FileNameReference, '') AS 'FileNameReference'
	                ,ISNULL(TE.note, '') AS 'note'
                      FROM
                           [TimeKeeper].[dbo].[TimeEntries] TE
                           INNER JOIN [TimeKeeper].[dbo].[TimeEntry_Tasks] TES
	                           ON TES.id = TE.timeEntrytaskID
                           INNER JOIN [TimeKeeper].[dbo].[Organizations] O
	                           ON O.id = TE.orgClientID
                      WHERE
                           TE.timeEntryDayID = @TimeEntryDayID
                           and O.active = 1
                     ORDER BY numberMinutes " + HiddenFieldTimeSpent.Value;

                SqlDataAdapter sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@TimeEntryDayID", HiddenFieldTimeEntryDayID.Value);
                DataSet _dataSet = new DataSet();
                sqlDataAdapter.Fill(_dataSet);

                HiddenFieldTotalTime.Value = "0";
                LabelEnterBreakInfo.Visible = false;
                if (_dataSet.Tables[0].Rows.Count <= 0)
                {
                    GridView1.DataSource = null;
                    GridView1.DataBind();
                    return;
                }

                GridView1.DataSource = _dataSet;
                GridView1.DataBind();

                if (double.Parse(HiddenFieldTotalTime.Value) / 60.0 > 3)
                {
                    CheckForBreak(_dataSet);
                }
            }
        }
        private void BindTimeOfTask()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                if (HiddenFieldtimeOfTaskOrder.Value == "ASC")
                {
                    HiddenFieldtimeOfTaskOrder.Value = "DESC";
                }
                else
                {
                    HiddenFieldtimeOfTaskOrder.Value = "ASC";
                }

                string _sqlStatement =
                    @"SELECT
                    TE.id
                    ,TE.timeEntryDayID
                    ,TE.numberMinutes
                    ,TE.timeOfTask
                    ,TES.name AS 'task'
                    ,TES.id AS 'task_id'
                    ,O.name AS 'client'
                    ,O.id AS 'client_id'
                    ,CASE
	                    WHEN TE.IsProjectManagement = 1 THEN 'true'
	                    ELSE 'false'
	                END AS 'isPM'
	                ,CASE
	                    WHEN TE.IsHelpDesk = 1 THEN 'true'
	                    ELSE 'false'
	                END AS 'isHelpDesk'
	                ,ISNULL(TE.ITPM_ID, '') AS 'ITPM_ID'
	                ,ISNULL(TE.HD_ROW_ID, '') AS 'HD_ROW_ID'
	                ,ISNULL(TE.Description, '') AS 'Description'
	                ,ISNULL(TE.FileNameReference, '') AS 'FileNameReference'
	                ,ISNULL(TE.note, '') AS 'note'
                  FROM
                       [TimeKeeper].[dbo].[TimeEntries] TE
                       INNER JOIN [TimeKeeper].[dbo].[TimeEntry_Tasks] TES
	                       ON TES.id = TE.timeEntrytaskID
                       INNER JOIN [TimeKeeper].[dbo].[Organizations] O
	                       ON O.id = TE.orgClientID
                  WHERE
                       TE.timeEntryDayID = @TimeEntryDayID
                       and O.active = 1
                 ORDER BY timeOfTask " + HiddenFieldtimeOfTaskOrder.Value;

                SqlDataAdapter sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@TimeEntryDayID", HiddenFieldTimeEntryDayID.Value);
                DataSet _dataSet = new DataSet();
                sqlDataAdapter.Fill(_dataSet);

                HiddenFieldTotalTime.Value = "0";
                LabelEnterBreakInfo.Visible = false;
                if (_dataSet.Tables[0].Rows.Count <= 0)
                {
                    GridView1.DataSource = null;
                    GridView1.DataBind();
                    return;
                }

                GridView1.DataSource = _dataSet;
                GridView1.DataBind();

                if (double.Parse(HiddenFieldTotalTime.Value) / 60.0 > 3)
                {
                    CheckForBreak(_dataSet);
                }
            }
        }


        protected void RadioButtonListClientChoices_SelectedIndexChanged(object sender, EventArgs e)
        {
            InitializePage();
        }

        private DataTable GetTimeEntryExceptions(SqlConnection con)
        {
            string _sqlStatement = @"
            SELECT [id]
                  ,[name]
                  ,[description]
                  ,[type]
                  ,[system]
                  ,[doesFLSAapply]
                  ,[granularity]
                  ,[minutes]
                  ,[hours]
                  ,[days]
                  ,[message]
                  ,[timeEntryTaskId]
            FROM
	            [TimeKeeper].[dbo].[TimeEntryExceptions]
            WHERE
	            [system] = 1";

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            return _dataTable;
        }


        protected void ImageButtonStartTimeInfo_Click(object sender, ImageClickEventArgs e)
        {
            if (PanelPickStartTime.Visible)
            {
                PanelPickStartTime.Visible = false;
            }
            else
            {
                PanelPickStartTime.Visible = true;
            }
        }

        protected void ImageButtonStopTimeInfo_Click(object sender, ImageClickEventArgs e)
        {
            if (PanelPickStopTime.Visible)
            {
                PanelPickStopTime.Visible = false;
            }
            else
            {
                PanelPickStopTime.Visible = true;
            }
        }
        protected void ButtonSelectStartTime_Click(object sender, EventArgs e)
        {
            string _timeValue = ListBoxHoursStart.SelectedValue + ":" + DropDownListMinutesStart.SelectedValue + " " + DropDownListAMPMStart.SelectedValue;
            TextBoxStartTime.Text = _timeValue;
            ListBoxHoursStart.SelectedValue = "12";
            DropDownListMinutesStart.SelectedValue = "00";
            DropDownListAMPMStart.SelectedValue = "AM";
            PanelPickStartTime.Visible = false;
            //Page.SetFocus(TextBoxStartTime);
        }
        protected void ButtonSelectStopTime_Click(object sender, EventArgs e)
        {
            LabelStopTimeError.Text = string.Empty;

            if (string.IsNullOrEmpty(TextBoxStartTime.Text))
            {
                LabelStopTimeError.Text = "Must specify a start time<br/>";
                return;
            }

            string _timeValue = DropDownListStopHour.SelectedValue + ":" + DropDownListStopMinutes.SelectedValue + " " + DropDownListStopAMPM.SelectedValue;
            DateTime _start = DateTime.Parse("01-01-2000 " + TextBoxStartTime.Text);
            DateTime _end = DateTime.Parse("01-01-2000 " + _timeValue);

            if (_start >= _end)
            {
                LabelStopTimeError.Text = "Stop time must be after start time<br/>";
                return;
            }

            TextBoxStopTime.Text = _timeValue;
            DropDownListStopHour.SelectedValue = "12";
            DropDownListStopMinutes.SelectedValue = "00";
            DropDownListStopAMPM.SelectedValue = "AM";
            PanelPickStopTime.Visible = false;
            //Page.SetFocus(TextBoxStopTime);

            TimeSpan _timeSpan = _end.Subtract(_start);
            LiteralHours.Text = _timeSpan.Hours.ToString();
            LiteralMinutes.Text = _timeSpan.Minutes.ToString();
        }

        private void DisplayScheduleAndEnteredTimeTotals()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                // Get Schedule
                DataTable _dataTable = GetScheduleForDay(_con);
                LiteralDateOfEntry.Visible = false;
                LiteralDateOfEntryLabel.Visible = false;

                if (_dataTable == null)
                {
                    LiteralDateOfEntry.Visible = true;
                    LiteralDateOfEntryLabel.Visible = true;
                    Message = "There is no schedule information for the date " + HiddenFieldDateTimeEntry.Value
                        + ".\\nYou will need to enter schedule information for that date before entering any tasks.";

                    Url = MBA.HttpApplication.createLink("WebFormTimeEntrySchedule.aspx", true);
                    Url += "&dateforentry=" + HiddenFieldDateTimeEntry.Value;
                    var script = "<script>alert('" + Message + "');window.location.href = '" + Url + "';</script>";
                    Page.ClientScript.RegisterStartupScript(this.GetType(), "WantToSave", script);
                    return;
                }

                double _numberOfMinutes = 0;
                TimeSpan _timeSpan;
                foreach (DataRow _dataRow in _dataTable.Rows)
                {
                    _timeSpan = (DateTime.Parse(_dataRow["stoptime"].ToString()) - DateTime.Parse(_dataRow["starttime"].ToString()));
                    _numberOfMinutes += _timeSpan.Hours * 60 + _timeSpan.Minutes;
                }
                labelScheduleForDay.Text = ((int)(_numberOfMinutes / 60)).ToString() + " Hours " +
                                                (_numberOfMinutes % 60).ToString() + " Minutes";

                // Get Time Entered
                _dataTable = GetTimeEnteredByEmployee(_con);

                if (_dataTable == null)
                {
                    labelHoursEntered.Text = "0 Hours 0 Minutes";
                    return;
                }

                _numberOfMinutes = 0;
                foreach (DataRow _dataRow in _dataTable.Rows)
                {
                    _numberOfMinutes += (int)_dataRow["numberMinutes"];
                }
                labelHoursEntered.Text = ((int)(_numberOfMinutes / 60)).ToString() + " Hours " +
                                                (_numberOfMinutes % 60).ToString() + " Minutes";
            }
        }

        private DataTable GetTimeEnteredByEmployee(SqlConnection con)
        {
            DateTime _selecteDate = DateTime.Parse(HiddenFieldDateTimeEntry.Value);
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetTimeEntriesForEmployeeAndDate", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            _sqlDataAdapter.SelectCommand.Parameters.Add("@EmployeeId", SqlDbType.BigInt).Value = HiddenFieldEmployeeID.Value;
            _sqlDataAdapter.SelectCommand.Parameters.Add("@StartDate", SqlDbType.DateTime).Value = _selecteDate.Date;

            DataSet _dataSet = new DataSet();
            _sqlDataAdapter.Fill(_dataSet);

            if (_dataSet.Tables[0].Rows.Count == 0)
            {
                return null;
            }

            return _dataSet.Tables[0];
        }
        private DataTable GetScheduleForDay(SqlConnection con)
        {
            DateTime _selecteDate = DateTime.Parse(HiddenFieldDateTimeEntry.Value);
            DataTable _dt = new DataTable();

                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetSchedule", con);
                _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
                _sqlDataAdapter.SelectCommand.Parameters.Add("@employeeID", SqlDbType.BigInt).Value = HiddenFieldEmployeeID.Value;
                _sqlDataAdapter.SelectCommand.Parameters.Add("@startDate", SqlDbType.DateTime).Value = _selecteDate.Date;
                _sqlDataAdapter.SelectCommand.Parameters.Add("@endDate", SqlDbType.DateTime).Value = _selecteDate.Date.AddDays(1); // Get everything up till midnight of the start of the next week
                _sqlDataAdapter.Fill(_dt);

            if (_dt.Rows.Count == 0)
            {
                return null;
            }

            return _dt;

        }
        protected void RadioButtonListTaskType_SelectedIndexChanged(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                PopulateTimeEntryTaskFavorites(_con);

                if (RadioButtonListTaskType.SelectedIndex == 2)
                {
                    ListBoxFavoriteClientTimeEntry.ClearSelection();
                }
                else if (ListBoxFavoriteClientTimeEntry.Items.Count > 0)
                {
                    ListBoxFavoriteClientTimeEntry.SelectedIndex = 0;
                }

                ListBoxFavoriteTaskTimeEntry.ClearSelection();
            }
        }
        protected void ListBoxFavoriteTaskTimeEntry_SelectedIndexChanged(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                bool _displayStartTime = false;
                bool _displayStopTime = false;

                _con.Open();
                SetClientListBoxSelectionMOde(_con);
                DetermineIfStopAndStartTimeRequried(_con, ref _displayStartTime, ref _displayStopTime);
            }
        }

        private void SetClientListBoxSelectionMOde(SqlConnection con)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetTaskInformation", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", ListBoxFavoriteTaskTimeEntry.SelectedValue);

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            if (_dataTable.Rows.Count <= 0)
            {
                return;
            }
            DataRow _dataRow = _dataTable.Rows[0];

            if (RadioButtonListTaskType.SelectedIndex == 2)
            {
                ListBoxFavoriteClientTimeEntry.ClearSelection();
            }
            else if (ListBoxFavoriteClientTimeEntry.Items.Count > 0)
            {
                ListBoxFavoriteClientTimeEntry.SelectedIndex = 0;
            }

            ListBoxFavoriteClientTimeEntry.SelectionMode = bool.Parse(_dataRow["CanHaveMultipleClients"].ToString()) ? ListSelectionMode.Multiple : ListSelectionMode.Single;
        }
        protected void lnkpickdate_Click(object sender, EventArgs e)
        {
            datepicker.Visible = true;
        }
        protected void datepicker_SelectionChanged(object sender, EventArgs e)
        {
            tbSelectedDate.Text = datepicker.SelectedDate.ToString("MM/dd/yyyy");
            datepicker.Visible = false;
            UpdateTimeEntries();
        }

        private void UpdateTimeEntries()
        {
            HiddenFieldDateTimeEntry.Value = tbSelectedDate.Text;
            GetIDForTimeEntry();
            InitializePage();
            if (HiddenFieldTimeEntryID.Value != "0" && !string.IsNullOrEmpty(HiddenFieldTimeEntryID.Value))
            {
                SetControlsForExistingRecord();
            }
            PopulateGrid();
            DisplayScheduleAndEnteredTimeTotals();
        }

        protected void DropDownListEmployees_SelectedIndexChanged(object sender, EventArgs e)
        {
            LabelAdminEmployee.Visible = false;

            if (rd.wu.usr.timeSheetUserInfo == null)
            {
                rd.wu.usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(rd.wu.usr.userName);
            }

            HiddenFieldEmployeeID.Value = DropDownListEmployees.SelectedValue;
            UpdateTimeEntries();

            if (rd.wu.usr.timeSheetUserInfo.employeeid.ToString() != HiddenFieldEmployeeID.Value)
            {
                LabelAdminEmployee.Visible = true;
            }
        }
    }
}
