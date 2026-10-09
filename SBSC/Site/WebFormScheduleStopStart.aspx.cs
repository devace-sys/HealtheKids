using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;
using MBA.BitteTime;
using MBA.Web;

namespace Spedmon
{
     public partial class WebFormScheduleStopStart : WebUI
     {
          public WebFormScheduleStopStart()
               : base("webformschedulestopstart", WebUI.CreatePageSubTitle("Schedule", "Create or Update Schedule"), "", "", Constants.ROLE_SBS_ALL)
          { 
          }
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                gridView.ShowFooter = false;
                if (!IsPostBack)
                {
                    if (Request.UrlReferrer == null)
                    {
                        HiddenFieldPreviousPage.Value = "WebFormTimeEntrySchedule.aspx";
                    }
                    else
                    {
                        HiddenFieldPreviousPage.Value = System.IO.Path.GetFileName(Request.UrlReferrer.LocalPath);
                    }

                    if (string.IsNullOrEmpty((string)Request.QueryString["scheduledate"])
                       || string.IsNullOrEmpty((string)Request.QueryString["employeeid"]))
                    {
                        Response.Redirect(HiddenFieldPreviousPage.Value, false);
                        return;
                    }

                    CheckForValidDate();
                    // Only allow logged in user the ablity to modify their own schedule
                    // Otherwise e
                    if (TimeSheetSession.Current.EmployeeId == long.Parse(Request.QueryString["employeeid"]))
                    {
                        HiddenFieldEmployeeID.Value = (string)Request.QueryString["employeeid"];
                    }
                    else
                    {
                        string _url = MBA.HttpApplication.createLink("WebFormTimeEntrySchedule.aspx", true);
                        Response.Redirect(_url, true);
                        return;
                    }

                    GetScheduleIDFromDate();
                }
            }
            catch(Exception _error)
            {
                string _url = MBA.HttpApplication.createLink("WebFormTimeEntrySchedule.aspx", true);
                Response.Redirect(_url, true);
            }
        }

        private void CheckForValidDate()
        {
            try
            {
                string _scheduleDate = Request.QueryString["scheduledate"].Replace("%2f", "/");
                LiteralDateOfEntry.Text = DateTime.Parse(_scheduleDate).ToString("MM/dd/yyyy");
            }
            catch
            {
                string _url = MBA.HttpApplication.createLink("WebFormTimeEntry.aspx", true);
                Response.Redirect(_url, false);
            }
        }
        private void GetScheduleIDFromDate()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                SqlDataAdapter _dataAdapter = new SqlDataAdapter("TimeKeeper_SCHEDULE_GetScheduledByDate", _con);
                _dataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
                _dataAdapter.SelectCommand.Parameters.Add("@DateOfSchedule", SqlDbType.DateTime).Value = DateTime.Parse(LiteralDateOfEntry.Text);
                _dataAdapter.SelectCommand.Parameters.Add("@EmployeeId", SqlDbType.BigInt).Value = Convert.ToInt64(HiddenFieldEmployeeID.Value);
                DataSet _dataSet = new DataSet();
                _dataAdapter.Fill(_dataSet);

                if (_dataSet.Tables[0].Rows.Count > 0)
                {
                    HiddenFieldScheduleID.Value = _dataSet.Tables[0].Rows[0]["id"].ToString();
                    PopulateGrid();
                }
                else
                {
                    gridView.DataSource = null;
                    gridView.DataBind();
                    HiddenFieldScheduleID.Value = "0";
                }
            }
        }

        private void PopulateGrid()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                SqlDataAdapter _dataAdapter = new SqlDataAdapter("TimeKeeper_SCHEDULE_GetStartAndStopTimesByScheduledDate", _con);
                _dataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
                _dataAdapter.SelectCommand.Parameters.Add("@ScheduleId", SqlDbType.BigInt).Value = Convert.ToInt64(HiddenFieldScheduleID.Value);
                DataSet _dataSet = new DataSet();
                _dataAdapter.Fill(_dataSet);

                if (_dataSet.Tables[0].Rows.Count > 0)
                {
                    gridView.DataSource = _dataSet;
                    gridView.DataBind();
                }
                else
                {
                    gridView.DataSource = null;
                    gridView.DataBind();
                }
            }
        }
        protected void gridView_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            ButtonAdd.Enabled = true;
            HiddenFieldEditRowIndex.Value = "-1";
            gridView.EditIndex = -1;
            PopulateGrid();
        }
        protected void gridView_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            string _confirmDelete = Request.Form["confirm_value"];
            if (_confirmDelete != "Yes")
            {
                return;
            }

            ButtonAdd.Enabled = false;
            int _selectedRow = e.RowIndex;
            long _id = 0;
            HiddenField lblnameStopStartId = (HiddenField)gridView.Rows[_selectedRow].FindControl("lblnameStopStartId");

            if (lblnameStopStartId != null)
            {
                _id = Convert.ToInt64(lblnameStopStartId.Value);
            }
            else
            {
                HiddenField HiddenFieldIDEdit = (HiddenField)gridView.Rows[_selectedRow].FindControl("HiddenFieldIDEdit");
                if (HiddenFieldIDEdit != null)
                {
                    _id = Convert.ToInt64(HiddenFieldIDEdit.Value);
                }
            }

            using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                con.Open();
                SqlCommand cmd = new SqlCommand("TimeKeeper_SCHEDULEStartAndStop_Delete", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ID", _id);

                cmd.ExecuteNonQuery();
            }
            gridView.EditIndex = -1;
            ButtonAdd.Enabled = true;
            PopulateGrid();

        }
        protected void gridView_RowEditing(object sender, GridViewEditEventArgs e)
        {
            try
            {
                ButtonAdd.Enabled = false;
                HiddenFieldEditRowIndex.Value = e.NewEditIndex.ToString();
                gridView.EditIndex = e.NewEditIndex;
                PopulateGrid();
                Button _button = (Button)gridView.Rows[gridView.EditIndex].FindControl("ButtonAddEdit");
                _button.Visible = false;
            }
            catch
            {
                // Ignore exception
                if (!ButtonAdd.Enabled)
                {
                    ButtonAdd.Enabled = true;
                }
            }
        }
        protected void gridView_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            TextBox TextBoxEditStartTime = (TextBox)gridView.Rows[e.RowIndex].FindControl("TextBoxEditStartTime");
            TextBox TextBoxEditEndTime = (TextBox)gridView.Rows[e.RowIndex].FindControl("TextBoxEditEndTime");
            HiddenField HiddenFieldIDEdit = (HiddenField)gridView.Rows[e.RowIndex].FindControl("HiddenFieldIDEdit");
            long _id = Convert.ToInt64(HiddenFieldIDEdit.Value);
            DateTime _startTime = DateTime.Parse(LiteralDateOfEntry.Text + " " + TextBoxEditStartTime.Text);
            DateTime _endTime = DateTime.Parse(LiteralDateOfEntry.Text + " " + TextBoxEditEndTime.Text);

            if (TimeEntryInThatRangeExist(_startTime, _endTime))
            {
                return;
            }

            using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                con.Open();
                SqlCommand cmd = new SqlCommand("TimeKeeper_SCHEDULEStartAndStop_Update", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ID", _id);
                cmd.Parameters.AddWithValue("@STARTTIME", _startTime);
                cmd.Parameters.AddWithValue("@STOPTIME", _endTime);

                cmd.ExecuteNonQuery();
            }

            gridView.EditIndex = -1;
            ButtonAdd.Enabled = true;
            PopulateGrid();
        }

        protected void gridView_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            DateTime _startTime = DateTime.Parse(LiteralDateOfEntry.Text);
            DateTime _endTime = DateTime.Parse(LiteralDateOfEntry.Text);
            string _txtStartTime = string.Empty;
            string _txtEndTime = string.Empty;
            string _errMsg = string.Empty;

            if (e.CommandName.Equals("AddNew"))
            {
                _txtStartTime = ((TextBox)gridView.Rows[0].FindControl("TextBoxEditStartTime")).Text;
                _txtEndTime = ((TextBox)gridView.Rows[0].FindControl("TextBoxEditEndTime")).Text;

                _startTime = DateTime.Parse(LiteralDateOfEntry.Text + " " + _txtStartTime);
                _endTime = DateTime.Parse(LiteralDateOfEntry.Text + " " + _txtEndTime);


                // Sanity check make sure end time is latter than start time otherwise display error
                if (_startTime >= _endTime)
                {
                    _errMsg = "Start time must be latter than end time.\\nPlease correct time entry\\nand try again.";
                    ScriptManager.RegisterClientScriptBlock(Page, typeof(Page), "ClientScript", "alert('" + _errMsg + "')", true);
                    return;
                }

                if (TimeEntryInThatRangeExist(_startTime, _endTime))
                {
                    _errMsg = "You already have an entry in that time range\\nPlease modify that entry\\nand try again.";
                    ScriptManager.RegisterClientScriptBlock(Page, typeof(Page), "ClientScript", "alert('" + _errMsg + "')", true);
                    return;
                }

                InsertRecord(_startTime, _endTime);
                gridView.EditIndex = -1;
                ButtonAdd.Enabled = true;
                PopulateGrid();
            }
            else if (e.CommandName.Equals("Edit"))
            {
                //
            }
            else if (e.CommandName.Equals("StopTimePickerToggle"))
            {
                StopTimePickerToggle();
            }
            else if (e.CommandName.Equals("SaveStopTime"))
            {
                RowSaveStopTime();
            }
            else if (e.CommandName.Equals("StartTimePickerToggle"))
            {
                StartTimePickerToggle();
            }
            else if (e.CommandName.Equals("SaveStartTime"))
            {
                RowSaveStartTime();
            }
        }

        public void StartTimePickerToggle()
        {
            int _index = Convert.ToInt32(HiddenFieldEditRowIndex.Value);
            Panel _panelPickStartTime = ((Panel)gridView.Rows[_index].FindControl("PanelPickStartTime"));

            if (_panelPickStartTime.Visible)
            {
                _panelPickStartTime.Visible = false;
            }
            else
            {
                _panelPickStartTime.Visible = true;
            }

        }
        public void StopTimePickerToggle()
        {
            int _index = Convert.ToInt32(HiddenFieldEditRowIndex.Value);
            Panel _panelPickStopTime = ((Panel)gridView.Rows[_index].FindControl("PanelPickStopTime"));

            if (_panelPickStopTime.Visible)
            {
                _panelPickStopTime.Visible = false;
            }
            else
            {
                _panelPickStopTime.Visible = true;
            }
        }
        public void RowSaveStartTime()
        {
            int _index = Convert.ToInt32(HiddenFieldEditRowIndex.Value);
            DropDownList _dropDownListBoxHoursStart = ((DropDownList)gridView.Rows[_index].FindControl("DropDownListBoxHoursStart"));
            DropDownList _dropDownListMinutesStart = ((DropDownList)gridView.Rows[_index].FindControl("DropDownListMinutesStart"));
            DropDownList _dropDownListAMPMStart = ((DropDownList)gridView.Rows[_index].FindControl("DropDownListAMPMStart"));
            TextBox _textBoxStartTime = ((TextBox)gridView.Rows[_index].FindControl("TextBoxEditStartTime"));
            Panel panelPickStartTime = ((Panel)gridView.Rows[_index].FindControl("PanelPickStartTime"));


            string _timeValue = _dropDownListBoxHoursStart.SelectedValue + ":" + _dropDownListMinutesStart.SelectedValue + " " + _dropDownListAMPMStart.SelectedValue;
            _textBoxStartTime.Text = _timeValue;
            _dropDownListBoxHoursStart.SelectedValue = "12";
            _dropDownListMinutesStart.SelectedValue = "00";
            _dropDownListAMPMStart.SelectedValue = "AM";
            panelPickStartTime.Visible = false;
            Page.SetFocus(_textBoxStartTime);
        }
        public void RowSaveStopTime()
        {
            int _index = Convert.ToInt32(HiddenFieldEditRowIndex.Value);

            Label _labelStopTimeError = ((Label)gridView.Rows[_index].FindControl("LabelStopTimeError"));
            _labelStopTimeError.Text = string.Empty;

            TextBox _textBoxStartTime = ((TextBox)gridView.Rows[_index].FindControl("TextBoxEditStartTime"));

            if (string.IsNullOrEmpty(_textBoxStartTime.Text))
            {
                _labelStopTimeError.Text = "Must specify a start time<br/>";
                return;
            }

            DropDownList _dropDownListStopHour = ((DropDownList)gridView.Rows[_index].FindControl("DropDownListStopHour"));
            DropDownList _dropDownListStopAMPM = ((DropDownList)gridView.Rows[_index].FindControl("DropDownListStopAMPM"));
            DropDownList _dropDownListStopMinutes = ((DropDownList)gridView.Rows[_index].FindControl("DropDownListStopMinutes"));

            string _timeValue = _dropDownListStopHour.SelectedValue + ":" + _dropDownListStopMinutes.SelectedValue + " " + _dropDownListStopAMPM.SelectedValue;
            DateTime _start = DateTime.Parse("01-01-2000 " + _textBoxStartTime.Text);
            DateTime _end = DateTime.Parse("01-01-2000 " + _timeValue);

            if (_start >= _end)
            {
                _labelStopTimeError.Text = "Stop time must be after start time<br/>";
                return;
            }

            TextBox _textBoxEditEndTime = ((TextBox)gridView.Rows[_index].FindControl("TextBoxEditEndTime"));
            _textBoxEditEndTime.Text = _timeValue;
            _dropDownListStopHour.SelectedValue = "12";
            _dropDownListStopMinutes.SelectedValue = "00";
            _dropDownListStopAMPM.SelectedValue = "AM";

            Panel _panelPickStopTime = ((Panel)gridView.Rows[_index].FindControl("PanelPickStopTime"));
            _panelPickStopTime.Visible = false;
        }

        private void InsertRecord(DateTime startTime, DateTime endTime)
        {
            try
            {
                if (HiddenFieldScheduleID.Value == "0")
                {
                    InsertSchedule();
                }

                using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                {
                    long _scheduleId = Convert.ToInt64(HiddenFieldScheduleID.Value);

                    con.Open();
                    SqlCommand cmd = new SqlCommand("TimeKeeper_SCHEDULE_STOP_START_CreateNew", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@ScheduleId", _scheduleId);
                    cmd.Parameters.AddWithValue("@StartTime", startTime);
                    cmd.Parameters.AddWithValue("@StopTime", endTime);
                    cmd.Parameters.Add("@Id", SqlDbType.BigInt);
                    cmd.Parameters["@Id"].Direction = ParameterDirection.Output;

                    cmd.ExecuteNonQuery();
                }
            }
            catch(Exception _exception)
            {
                LiteralErrors.Text = "<!-- Exception: " + _exception.Message + " - " + _exception.InnerException.Message + "-->";
            }
        }

        private long InsertScheduleApproved(SqlConnection con, long employeeId, DateTime dateOfSchedule)
        {
            DateTime _startDate = dateOfSchedule.DayOfWeek == DayOfWeek.Sunday ? dateOfSchedule :
                    dateOfSchedule.AddDays(-1 * (int)dateOfSchedule.DayOfWeek);
            DateTime _endDate = dateOfSchedule.DayOfWeek == DayOfWeek.Saturday ? dateOfSchedule :
                    dateOfSchedule.AddDays(6 - (int)dateOfSchedule.DayOfWeek);

            SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_SCHEDULE_CreateNewScheduleApproved", con);
            _sqlCommand.CommandType = CommandType.StoredProcedure;
            _sqlCommand.Parameters.AddWithValue("@EmployeeId", employeeId);
            _sqlCommand.Parameters.AddWithValue("@StartDate", _startDate);
            _sqlCommand.Parameters.AddWithValue("@EndDate", _endDate);
            _sqlCommand.Parameters.Add("@Id", SqlDbType.BigInt);
            _sqlCommand.Parameters["@Id"].Direction = ParameterDirection.Output;

            _sqlCommand.ExecuteNonQuery();

            return long.Parse(_sqlCommand.Parameters["@Id"].Value.ToString());
        }

        private void InsertSchedule()
        {
            long _employeeId = Convert.ToInt64(HiddenFieldEmployeeID.Value);
            DateTime _dateOfSchedule = DateTime.Parse(LiteralDateOfEntry.Text);
            long _scheduleApproveId = 0;

            // Might have double clicked
            using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                try
                {
                    con.Open();

                    _scheduleApproveId = InsertScheduleApproved(con, _employeeId, _dateOfSchedule);
                    SqlCommand cmd = new SqlCommand("TimeKeeper_SCHEDULE_CreateNew", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@EmployeeId", _employeeId);
                    cmd.Parameters.AddWithValue("@ScheduleApproveId", _scheduleApproveId);
                    cmd.Parameters.AddWithValue("@DateOfSchedule", _dateOfSchedule);
                    cmd.Parameters.Add("@Id", SqlDbType.BigInt);
                    cmd.Parameters["@Id"].Direction = ParameterDirection.Output;

                    cmd.ExecuteNonQuery();
                    HiddenFieldScheduleID.Value = cmd.Parameters["@Id"].Value.ToString();
                }
                catch (Exception e)
                {
                    LiteralErrors.Text = "<!-- Exception: " + e.Message + " - " + e.InnerException.Message + "-->";
                    // Ignore error
                }
            }
        }

        private bool TimeEntryInThatRangeExist(DateTime newStartTime, DateTime newEndTime)
        {
            if (HiddenFieldScheduleID.Value == "0")
            {
                return false; // Indicates a new record
            }

            Label lblnameStartTime = null;
            Label lblnameEndTime = null;
            DateTime _gridStartTime = DateTime.MinValue;
            DateTime _gridEndTime = DateTime.MaxValue;

            foreach (GridViewRow row in gridView.Rows)
            {
                lblnameStartTime = (Label)row.FindControl("lblnameStartTime");

                if (lblnameStartTime == null)
                {
                    continue;
                }

                lblnameEndTime = (Label)row.FindControl("lblnameEndTime");

                _gridStartTime = DateTime.Parse(LiteralDateOfEntry.Text + " " + lblnameStartTime.Text);
                _gridEndTime = DateTime.Parse(LiteralDateOfEntry.Text + " " + lblnameEndTime.Text);

                // New start time must be before existing start time and new end time is before any existing
                // start time.  there is no overlap in this row
                if ((newStartTime < _gridStartTime) && (newEndTime <= _gridStartTime))
                {
                    continue;
                }

                // New start time is after existing stop time, there is no overlap in this row
                if (newStartTime >= _gridEndTime)
                {
                    continue;
                }

                // If you get to this point there is an overlap
                return true;
            }

            // You get to this point. There is no overlap
            return false;
        }

        protected void gridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                DataRow dr = ((DataRowView)e.Row.DataItem).Row;

                if (string.IsNullOrEmpty(dr["id"].ToString()))
                {
                    return;
                }

                Label lblnameStartTime = (Label)e.Row.FindControl("lblnameStartTime");
                if (lblnameStartTime != null)
                {
                    lblnameStartTime.Text = DateTime.Parse(dr["starttime"].ToString()).ToString("hh:mm tt");
                }
                Label lblnameEndTime = (Label)e.Row.FindControl("lblnameEndTime");
                if (lblnameEndTime != null)
                {
                    lblnameEndTime.Text = DateTime.Parse(dr["stoptime"].ToString()).ToString("hh:mm tt");
                }

                TextBox TextBoxEditStartTime = (TextBox)e.Row.FindControl("TextBoxEditStartTime");
                if (TextBoxEditStartTime != null)
                {
                    TextBoxEditStartTime.Text = DateTime.Parse(dr["starttime"].ToString()).ToString("hh:mm tt");
                }

                TextBox TextBoxEditEndTime = (TextBox)e.Row.FindControl("TextBoxEditEndTime");
                if (TextBoxEditEndTime != null)
                {
                    TextBoxEditEndTime.Text = DateTime.Parse(dr["stoptime"].ToString()).ToString("hh:mm tt");
                }
            }
        }
        protected void ButtonBack_Click(object sender, EventArgs e)
        {
            string _url = MBA.HttpApplication.createLink("WebFormTimeEntrySchedule.aspx", true) +
                "&employeeid=" + HiddenFieldEmployeeID.Value + "&dateforentry=" + LiteralDateOfEntry.Text;
            Response.Redirect(_url, true);
        }

        protected void ButtonAdd_Click(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                SqlDataAdapter da = new SqlDataAdapter("TimeKeeper_SCHEDULE_GetStartAndStopTimes", _con);
                da.SelectCommand.CommandType = CommandType.StoredProcedure;
                da.SelectCommand.Parameters.Add("@Scheduleid", SqlDbType.BigInt).Value = Convert.ToInt64(HiddenFieldScheduleID.Value);
                DataSet _dataSet = new DataSet();
                da.Fill(_dataSet);

                _dataSet.Tables[0].Rows.InsertAt(_dataSet.Tables[0].NewRow(), 0);

                HiddenFieldEditRowIndex.Value = "0";
                gridView.EditIndex = 0;
                gridView.DataSource = _dataSet;
                gridView.DataBind();

                GridViewRow _gridRow = gridView.Rows[0];

                Button _buttonUpdate = (Button)_gridRow.FindControl("ButtonUpdate");

                _buttonUpdate.Visible = false;
                ButtonAdd.Enabled = false;


            }

        }
        protected void GridView1_Sorting(object sender, GridViewSortEventArgs e)
        {
            switch (e.SortExpression)
            {
                case "Start":
                    BindStartTime();
                    break;
                case "End":
                    BindStopTime();
                    break;
            }
        }

        private void BindStopTime()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                if (HiddenFieldStop.Value == "ASC")
                {
                    HiddenFieldStop.Value = "DESC";
                }
                else
                {
                    HiddenFieldStop.Value = "ASC";
                }

                string _sqlStatement =
                  @"SELECT 
		            [id]
		            ,[scheduleid]
		            ,[starttime]
		            ,[stoptime]
	            FROM 
		            [TimeKeeper].[dbo].[ScheduleStartAndStopTime]
	            WHERE
		            [scheduleid] = @ScheduleId
                ORDER BY stoptime " + HiddenFieldStop.Value;

                SqlDataAdapter sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@ScheduleId", HiddenFieldScheduleID.Value);
                DataSet _dataSet = new DataSet();
                sqlDataAdapter.Fill(_dataSet);

                if (_dataSet.Tables[0].Rows.Count <= 0)
                {
                    gridView.DataSource = null;
                    gridView.DataBind();
                    return;
                }

                gridView.DataSource = _dataSet;
                gridView.DataBind();
            }
        }

        private void BindStartTime()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                if (HiddenFieldStart.Value == "ASC")
                {
                    HiddenFieldStart.Value = "DESC";
                }
                else
                {
                    HiddenFieldStart.Value = "ASC";
                }

                string _sqlStatement =
                  @"SELECT 
		            [id]
		            ,[scheduleid]
		            ,[starttime]
		            ,[stoptime]
	            FROM 
		            [TimeKeeper].[dbo].[ScheduleStartAndStopTime]
	            WHERE
		            [scheduleid] = @ScheduleId
                ORDER BY starttime " + HiddenFieldStart.Value;

                SqlDataAdapter sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@ScheduleId", HiddenFieldScheduleID.Value);
                DataSet _dataSet = new DataSet();
                sqlDataAdapter.Fill(_dataSet);

                if (_dataSet.Tables[0].Rows.Count <= 0)
                {
                    gridView.DataSource = null;
                    gridView.DataBind();
                    return;
                }

                gridView.DataSource = _dataSet;
                gridView.DataBind();
            }
        }
    }
}
