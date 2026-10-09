using MBA.BitteTime;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Spedmon
{
    public partial class ManagerTimeEntryAndScheduleReport : WebUI
    {
        public List<TimeEntryScheduleReport> TimeAndScheduleEntries = null;
        public ManagerTimeEntryAndScheduleReport()
             : base("reports", WebUI.CreatePageSubTitle("Manager Time and Schedule Report", "View employees time and schedule report"),
                  "", "", Constants.ROLE_SBS_ALL)
        {
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                DateTime _currentDate = DateTime.Now;
                if (_currentDate.DayOfWeek != DayOfWeek.Sunday)
                {
                    _currentDate = _currentDate.AddDays((int)(_currentDate.DayOfWeek) * -1);
                }
                tbSelectedDate.Text = _currentDate.ToString("MM/dd/yyyy");
                PopulateEmployees();
            }
        }

        private void PopulateEmployees()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                string _sqlStatement = @"
            select
	            E.id
	            ,P.firstName + ' ' + P.lastName as EmployeeName
            from
	            TimeKeeper.dbo.People P
	            inner join TimeKeeper.dbo.Employees E
		            on E.personID = P.id
            Order By P.firstName, P.lastName";

                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                DataTable _dataTable = new DataTable();
                _sqlDataAdapter.Fill(_dataTable);

                DropDownListEmployees.DataValueField = "id";
                DropDownListEmployees.DataTextField = "EmployeeName";
                DropDownListEmployees.DataSource = _dataTable;
                DropDownListEmployees.DataBind();

                ListBoxEmployees.DataValueField = "id";
                ListBoxEmployees.DataTextField = "EmployeeName";
                ListBoxEmployees.DataSource = _dataTable;
                ListBoxEmployees.DataBind();
            }
        }


        private void PopulateGridForSelectedDate(string sortOrder, string whereClause, SqlConnection con)
        {
            DateTime _dateValue = DateTime.Parse(tbSelectedDate.Text);

            GetTimeEntriesDetails(_dateValue, sortOrder, whereClause, con);

            GridView1.DataSource = TimeAndScheduleEntries;
            GridView1.DataBind();
        }
        private void PopulateGridView(string sortOrder, string whereClause)
        {
            DateTime _dateValue = DateTime.Parse(tbSelectedDate.Text);

            GetTimeEntriesDetails(_dateValue, sortOrder, whereClause);

            GridView1.DataSource = TimeAndScheduleEntries;
            GridView1.DataBind();
        }

        private void GetTimeEntriesDetails(DateTime dateValue, string sortOrder, string whereClause, SqlConnection con)
        {
            string _startDate = string.Empty;
            string _endDate = string.Empty;

            if (RadioButtonListDateSelection.SelectedValue == "0")
            {
                _startDate = dateValue.DayOfWeek == DayOfWeek.Sunday ? dateValue.ToString("MM/dd/yyyy") :
                    dateValue.AddDays(-1 * (int)dateValue.DayOfWeek).ToString("MM/dd/yyyy");
                _endDate = dateValue.DayOfWeek == DayOfWeek.Saturday ? dateValue.ToString("MM/dd/yyyy") :
                    dateValue.AddDays(6 - (int)dateValue.DayOfWeek).ToString("MM/dd/yyyy");
            }
            else
            {
                _startDate = tbStartDate.Text;
                _endDate = tbEndDate.Text;
            }

            string _sqlStatement = @"
                SELECT 
	                E.id
	                ,E.personID
	                ,P.firstName
	                ,P.lastName
	                ,S.id AS scheduleId
	                ,S.dateOfSchedule
                from
	                TimeKeeper.dbo.People P
	                INNER JOIN TimeKeeper.dbo.Employees E 
		                ON E.personID = P.id
	                INNER JOIN TimeKeeper.dbo.Schedule S
		                ON S.employeeID = E.id
                where 
	                cast(S.dateOfSchedule AS date) >= @StartDate
	                and cast(S.dateOfSchedule AS date) < @EndDate ";

            if (!string.IsNullOrEmpty(whereClause))
            {
                _sqlStatement += whereClause;
            }

            if (string.IsNullOrEmpty(sortOrder))
            {
                _sqlStatement += @" order by
                                       S.dateOfSchedule";

            }
            else
            {
                _sqlStatement += AddSortExpression(sortOrder);
            }

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@StartDate", _startDate);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@EndDate", _endDate);
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            TimeEntryScheduleReport _timeEntry = null;
            TimeAndScheduleEntries = new List<TimeEntryScheduleReport>();

            foreach (DataRow _dataRow in _dataTable.Rows)
            {
                _timeEntry = new TimeEntryScheduleReport();
                _timeEntry.id = long.Parse(_dataRow["id"].ToString());
                _timeEntry.personID = long.Parse(_dataRow["personID"].ToString());
                _timeEntry.firstName = _dataRow["firstName"].ToString();
                _timeEntry.lastName = _dataRow["lastName"].ToString();
                _timeEntry.scheduleId = long.Parse(_dataRow["scheduleId"].ToString());
                _timeEntry.dateOfSchedule.Add(DateTime.Parse(_dataRow["dateOfSchedule"].ToString()));

                TimeAndScheduleEntries.Add(_timeEntry);
            }

            GetScheduleDetails(con);
            GetTimeEntryDetails(con);
        }

        private void GetTimeEntriesDetails(DateTime dateValue, string sortOrder, string whereClause)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                GetTimeEntriesDetails(dateValue, sortOrder, whereClause, _con);
            }
        }

        private void GetTimeEntryDetails(SqlConnection con)
        {
            string _sqlStatement = string.Empty;

            SqlDataAdapter _sqlDataAdapter = null;
            DataTable _dataTable = null;

            foreach (TimeEntryScheduleReport _timeEntrySchedule in TimeAndScheduleEntries)
            {
                _sqlStatement = @"
                select
	                TE.id as TimeEntryId
	                ,TED.dateForTimeEntry
	                ,TE.numberMinutes
	                ,TET.name AS TaskName
	                ,TETypes.name AS TaskType
                    ,TE.note
                from
	                TimeKeeper.dbo.Employees E 
	                INNER JOIN TimeKeeper.dbo.TimeEntry_Day TED
		                ON TED.employeeID = E.ID
	                INNER JOIN TimeKeeper.dbo.TimeEntries TE
		                ON TE.timeEntryDayID = TED.id
	                INNER JOIN TimeKeeper.dbo.TimeEntry_Tasks TET
		                ON TET.id = TE.timeEntrytaskID
	                INNER JOIN TimeKeeper.dbo.TimeEntry_Types TETypes
		                ON TETypes.id = TET.taskType
                where
	                TED.dateForTimeEntry = @DateForTimeEntry
	                AND E.id = @Id";

                _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@DateForTimeEntry", _timeEntrySchedule.dateOfSchedule[0].ToString("MM/dd/yyyy"));
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", _timeEntrySchedule.id);
                _dataTable = new DataTable();
                _sqlDataAdapter.Fill(_dataTable);

                PopulateTimeEntryDetails(_timeEntrySchedule, _dataTable);
            }
        }

        private string AddSortExpression(string sortExpression)
        {
            string _orderBy = " order by ";

            switch (sortExpression)
            {
                case "firstName":
                    if (string.IsNullOrEmpty(hiddenFieldFirtNameSortOrder.Value) || hiddenFieldFirtNameSortOrder.Value.Equals("DESC"))
                    {
                        hiddenFieldFirtNameSortOrder.Value = "ASC";
                    }
                    else
                    {
                        hiddenFieldFirtNameSortOrder.Value = "DESC";
                    }
                    _orderBy += " P.firstName " + hiddenFieldFirtNameSortOrder.Value;
                    break;
                case "lastName":
                    if (string.IsNullOrEmpty(hiddenFieldLastNameSortOrder.Value) || hiddenFieldLastNameSortOrder.Value.Equals("DESC"))
                    {
                        hiddenFieldLastNameSortOrder.Value = "ASC";
                    }
                    else
                    {
                        hiddenFieldLastNameSortOrder.Value = "DESC";
                    }
                    _orderBy += " P.lastName " + hiddenFieldLastNameSortOrder.Value;
                    break;
                case "dateOfSchedule":
                    if (string.IsNullOrEmpty(hiddenFieldDateOfSchedule.Value) || hiddenFieldDateOfSchedule.Value.Equals("DESC"))
                    {
                        hiddenFieldDateOfSchedule.Value = "ASC";
                    }
                    else
                    {
                        hiddenFieldDateOfSchedule.Value = "DESC";
                    }
                    _orderBy += " S.dateOfSchedule " + hiddenFieldDateOfSchedule.Value;
                    break;
                default:
                    _orderBy = string.Empty;
                    break;
            }

            return _orderBy;
        }
        private void PopulateTimeEntryDetails(TimeEntryScheduleReport timeEntrySchedule, DataTable dataTable)
        {
            timeEntrySchedule.timeEntries = new List<TimeEntry>();

            if (dataTable.Rows.Count == 0)
            {
                return;
            }

            TimeEntry _timeEntry = null;

            foreach (DataRow dataRow in dataTable.Rows)
            {
                _timeEntry = new TimeEntry();
                _timeEntry.numberMinutes = long.Parse(dataRow["numberMinutes"].ToString());
                _timeEntry.TaskName = dataRow["TaskName"].ToString();
                _timeEntry.TaskType = dataRow["TaskType"].ToString();
                _timeEntry.Note = dataRow["note"].ToString();

                timeEntrySchedule.timeEntries.Add(_timeEntry);
            }
        }
        private void GetScheduleDetails(SqlConnection con)
        {
            string _sqlStatement = string.Empty;

            SqlDataAdapter _sqlDataAdapter = null;
            DataTable _dataTable = null;

            foreach (TimeEntryScheduleReport _timeEntrySchedule in TimeAndScheduleEntries)
            {
                _sqlStatement = @"
                    SELECT 
	                    SST.id
	                    ,S.dateOfSchedule
	                    ,SST.starttime
	                    ,SST.stoptime
                    from
	                    TimeKeeper.dbo.Schedule S
	                    INNER JOIN TimeKeeper.dbo.ScheduleStartAndStopTime SST
		                    ON SST.scheduleid = S.id
                    where
	                    S.id = @Id";

                _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", _timeEntrySchedule.scheduleId);
                _dataTable = new DataTable();
                _sqlDataAdapter.Fill(_dataTable);

                PopulateScheduleDetails(_timeEntrySchedule, _dataTable);
            }
        }

        private void PopulateScheduleDetails(TimeEntryScheduleReport timeEntrySchedule, DataTable dataTable)
        {
            timeEntrySchedule.startStopTimes = new List<ScheduleStopStart>();

            if (dataTable.Rows.Count == 0)
            {
                return;
            }

            ScheduleStopStart _scheduleStopStart = null;

            foreach (DataRow dataRow in dataTable.Rows)
            {
                _scheduleStopStart = new ScheduleStopStart();
                _scheduleStopStart.Start = DateTime.Parse(dataRow["starttime"].ToString());
                _scheduleStopStart.Stop = DateTime.Parse(dataRow["stoptime"].ToString());

                timeEntrySchedule.startStopTimes.Add(_scheduleStopStart);
            }
        }
        protected void GridView1_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {

        }
        protected void GridView1_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {

        }
        protected void GridView1_RowEditing(object sender, GridViewEditEventArgs e)
        {
        }
        protected void GridView1_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
        }
        protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
        {
        }
        protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
        {
        }

        protected void GridView1_Sorting(object sender, GridViewSortEventArgs e)
        {
            string _whereClause = string.Empty;
            switch (RadioButtonListEmployeeSelect.SelectedValue)
            {
                case "0":
                    _whereClause = " AND E.id = " + DropDownListEmployees.SelectedValue; ;
                    break;
                case "1":
                    _whereClause = GetWhereClauseForEmployees();
                    break;
            }

            PopulateGridForSelectedDate(e.SortExpression, _whereClause);
        }

        private string GetWhereClauseForEmployees()
        {
            string _whereClause = string.Empty;

            foreach (int _index in ListBoxEmployees.GetSelectedIndices())
            {
                if (string.IsNullOrEmpty(_whereClause))
                {
                    _whereClause = " AND E.id in (" + ListBoxEmployees.Items[_index].Value;
                }
                else
                {
                    _whereClause += "," + ListBoxEmployees.Items[_index].Value;
                }
            }

            if (!string.IsNullOrEmpty(_whereClause))
            {
                _whereClause += ")";
            }

            return _whereClause;
        }

        protected void lnkpickdate_Click(object sender, ImageClickEventArgs e)
        {
            datepicker.Visible = true;
        }

        protected void ButtonUpdate_Click(object sender, EventArgs e)
        {
            switch (RadioButtonListEmployeeSelect.SelectedValue)
            {
                case "0":
                    GetDropDownListEmployee();
                    break;
                case "1":
                    GetSelectedEmployeesReport();
                    break;
            }

        }
        private void PopulateGridForSelectedDate(string sortOrder, string whereClause)
        {
            try
            {
                PopulateGridView(sortOrder, whereClause);
            }
            catch (Exception _exception)
            {
                // If Invalid date, alert user
                ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        "Problem with employee record",
                        "alert('There invalid date entered. Try again.');",
                        true);

            }
        }
        private void PopulateGrid()
        {
            List<TimeEntryScheduleReport> _groupingData = new List<TimeEntryScheduleReport>();
            TimeEntryScheduleReport _groupingDataRecord = null;
            long _prevEmployeeID = 0;
            bool _firstTime = true;

            foreach (TimeEntryScheduleReport _record in TimeAndScheduleEntries)
            {
                if (_firstTime)
                {
                    _prevEmployeeID = _record.id;
                    _groupingDataRecord = new TimeEntryScheduleReport(_record);
                    _groupingDataRecord.groupData = true;
                    _firstTime = false;
                    continue;
                }
                if (_record.id != _prevEmployeeID)
                {
                    _groupingData.Add(_groupingDataRecord);
                    _groupingDataRecord = new TimeEntryScheduleReport(_record);
                    _groupingDataRecord.groupData = true;
                    _prevEmployeeID = _record.id;
                    continue;
                }

                foreach (DateTime _dateTime in _record.dateOfSchedule)
                {
                    _groupingDataRecord.dateOfSchedule.Add(_dateTime);
                }

                foreach (ScheduleStopStart _startStop in _record.startStopTimes)
                {
                    _groupingDataRecord.startStopTimes.Add(_startStop);
                }

                foreach (TimeEntry _timeEntry in _record.timeEntries)
                {
                    _groupingDataRecord.timeEntries.Add(_timeEntry);
                }
            }
            _groupingData.Add(_groupingDataRecord);


            GridView1.DataSource = _groupingData;
            GridView1.DataBind();
        }
        protected void datepicker_SelectionChanged(object sender, EventArgs e)
        {
            tbSelectedDate.Text = datepicker.SelectedDate.ToString("MM/dd/yyyy");
            datepicker.Visible = false;
        }

        protected void RadioButtonListGroupingOptions_SelectedIndexChanged(object sender, EventArgs e)
        {
            GridView1.Columns[2].SortExpression = "dateOfSchedule";
            string _whereClause = string.Empty;
            switch (RadioButtonListEmployeeSelect.SelectedValue)
            {
                case "0":
                    _whereClause = " AND E.id = " + DropDownListEmployees.SelectedValue; ;
                    break;
                case "1":
                    _whereClause = GetWhereClauseForEmployees();
                    break;
            }
            PopulateGridForSelectedDate(string.Empty, _whereClause);
        }

        protected void DropDownListEmployees_SelectedIndexChanged(object sender, EventArgs e)
        {
            GetDropDownListEmployee();
        }

        private void GetDropDownListEmployee()
        {
            string _whereClause = " AND E.id = " + DropDownListEmployees.SelectedValue;
            PopulateGridForSelectedDate(string.Empty, _whereClause);
        }

        protected void RadioButtonListEmployeeSelect_SelectedIndexChanged(object sender, EventArgs e)
        {
            DetermineWhatEmployeeSelectedVisible();
        }

        private void DetermineWhatEmployeeSelectedVisible()
        {
            switch (RadioButtonListEmployeeSelect.SelectedValue)
            {
                case "0":
                    DropDownListEmployees.Visible = true;
                    ListBoxEmployees.Visible = false;
                    ButtonSearch.Visible = false;
                    break;
                case "1":
                    DropDownListEmployees.Visible = false;
                    ListBoxEmployees.Visible = true;
                    ButtonSearch.Visible = true;
                    break;
            }
        }

        protected void ButtonSearch_Click(object sender, EventArgs e)
        {
            GetSelectedEmployeesReport();
        }

        private void GetSelectedEmployeesReport()
        {
            string _whereClause = GetWhereClauseForEmployees();

            PopulateGridForSelectedDate(string.Empty, _whereClause);
        }
        protected void OnPageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            GridView1.PageIndex = e.NewPageIndex;
            switch (RadioButtonListEmployeeSelect.SelectedValue)
            {
                case "0":
                    GetDropDownListEmployee();
                    break;
                case "1":
                    GetSelectedEmployeesReport();
                    break;
            }
        }

        protected void ButtonExport_Click(object sender, EventArgs e)
        {
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition",
             "attachment;filename=GridViewExport.csv");
            Response.Charset = "";
            Response.ContentType = "application/text";

            GridView1.AllowPaging = false;
            switch (RadioButtonListEmployeeSelect.SelectedValue)
            {
                case "0":
                    GetDropDownListEmployee();
                    break;
                case "1":
                    GetSelectedEmployeesReport();
                    break;
            }

            StringBuilder sb = new StringBuilder();
            for (int k = 0; k < GridView1.Columns.Count; k++)
            {
                //add separator
                sb.Append(GridView1.Columns[k].HeaderText.Replace("<strong style='font-weight:bold'>", "").Replace("</strong>", "").Replace("<br/>", "") + ',');
            }
            //append new line
            sb.Append("\r\n");
            foreach (GridViewRow _gridViewRow in GridView1.Rows)
            {
                sb.Append(((Label)_gridViewRow.FindControl("LabelFirstName")).Text.Replace("<br/>", "   ") + "," +
                    ((Label)_gridViewRow.FindControl("LabelLastName")).Text.Replace("<br/>", "   ") + ", " +
                    ((Label)_gridViewRow.FindControl("LabelDateOfScheduleDisplay")).Text.Replace("<br/>", "   ") + "," +
                    ((Label)_gridViewRow.FindControl("LabelScheduleTime")).Text.Replace("<br/>", "   ") + "," +
                    ((Label)_gridViewRow.FindControl("LabelTotalScheduledTime")).Text.Replace("<br/>", "   ") + "," +
                    ((Label)_gridViewRow.FindControl("LabelTimeWorked")).Text.Replace("<br/>", "   ") + "," +
                    ((Label)_gridViewRow.FindControl("LabelRecordedTimeEntryTasks")).Text.Replace("<br/>", "   ") + "," +
                    ((Label)_gridViewRow.FindControl("LabelNotes")).Text.Replace("<br/>", "   "));
                sb.Append("\r\n");
            }
            Response.Output.Write(sb.ToString());
            Response.Flush();
            Response.End();

            GridView1.AllowPaging = true;
        }

        //protected void ButtonExport_Click(object sender, EventArgs e)
        //{
        //    Response.Clear();
        //    Response.Buffer = true;
        //    /*
        //    Response.AddHeader("content-disposition", "attachment;filename=GridViewExport.xls");
        //    Response.Charset = "";
        //    Response.ContentType = "application/vnd.ms-excel";
        //    */
        //    Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
        //    Response.AddHeader("content-disposition", String.Format(@"attachment;filename=GridViewExport.xls"));

        //    using (StringWriter sw = new StringWriter())
        //    {
        //        string _whereClause = " AND E.id = " + TimeSheetSession.Current.EmployeeId.ToString();
        //        HtmlTextWriter _htmlTextWriter = new HtmlTextWriter(sw);

        //        //To Export all pages
        //        GridView1.AllowPaging = false;
        //        PopulateGridForSelectedDate(string.Empty, _whereClause);

        //        GridView1.HeaderRow.BackColor = Color.White;
        //        foreach (TableCell _cell in GridView1.HeaderRow.Cells)
        //        {
        //            _cell.BackColor = GridView1.HeaderStyle.BackColor;
        //        }
        //        foreach (GridViewRow _row in GridView1.Rows)
        //        {
        //            _row.BackColor = Color.White;
        //            foreach (TableCell _cell in _row.Cells)
        //            {
        //                if (_row.RowIndex % 2 == 0)
        //                {
        //                    _cell.BackColor = GridView1.AlternatingRowStyle.BackColor;
        //                }
        //                else
        //                {
        //                    _cell.BackColor = GridView1.RowStyle.BackColor;
        //                }
        //                _cell.CssClass = "textmode";
        //            }
        //        }

        //        GridView1.RenderControl(_htmlTextWriter);

        //        //style to format numbers to string
        //        string _style = @"<style> .textmode { } </style>";
        //        Response.Write(_style);
        //        Response.Output.Write(sw.ToString());
        //        Response.Flush();
        //        Response.End();
        //    }
        //}
        public override void VerifyRenderingInServerForm(Control control)
        {
            /* Confirms that an HtmlForm control is rendered for the specified ASP.NET
               server control at run time. */
        }

        protected void RadioButtonListDateSelection_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (RadioButtonListDateSelection.SelectedValue == "0")
            {
                PanelDateRange.Visible = false;
                PanelPayPeriod.Visible = true;
            }
            else
            {
                PanelDateRange.Visible = true;
                PanelPayPeriod.Visible = false;
            }
        }

        protected void lknPicStartDate_Click(object sender, ImageClickEventArgs e)
        {
            CalendarStart.Visible = true;
        }

        protected void lnkPicEndDate_Click(object sender, ImageClickEventArgs e)
        {
            CalendarEnd.Visible = true;
        }
        protected void CalendarStart_SelectionChanged(object sender, EventArgs e)
        {
            tbStartDate.Text = CalendarStart.SelectedDate.ToString("MM/dd/yyyy");
            CalendarStart.Visible = false;
        }

        protected void CalendarEnd_SelectionChanged(object sender, EventArgs e)
        {
            tbEndDate.Text = CalendarEnd.SelectedDate.ToString("MM/dd/yyyy");
            CalendarEnd.Visible = false;
        }
    }
}