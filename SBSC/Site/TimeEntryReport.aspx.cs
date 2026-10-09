using MBA.BitteTime;
using MBA.Web;
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
    public partial class TimeEntryReport : WebUI
    {
        public TimeEntryReport()
             : base("reports", WebUI.CreatePageSubTitle("Employees Time Entry Report", "Employees time entry report"),
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
                GetEmployeeInfo();
            }
        }

        private void GetEmployeeInfo()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                string _sqlStatement = @"
                select
	                E.id
	                ,P.firstName
	                ,P.lastName
	                ,O.name as 'OrganizationName'
                from
	                [TimeKeeper].[dbo].[Employees] E
	                inner join [TimeKeeper].[dbo].[People] P
		                on P.id = E.personID
	                inner join [TimeKeeper].[dbo].Organizations O
		                on O.id = E.organizationID
                           and O.active = 1
                where
	                E.id = @Id";

                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", TimeSheetSession.Current.EmployeeId.ToString());
                DataTable _dataTable = new DataTable();
                _sqlDataAdapter.Fill(_dataTable);

                if (_dataTable.Rows.Count == 0)
                {
                    string _url = MBA.HttpApplication.createLink("www.spedcare.com", true);
                    Response.Redirect(_url, false);
                    return;
                }

                DataRow _dataRow = _dataTable.Rows[0];

                LabelEmployees.Text = _dataRow["firstName"].ToString() + " " + _dataRow["lastName"].ToString() + "<br/>" +
                    _dataRow["OrganizationName"].ToString();

                PopulateGridForSelectedDate(GetTbSelecteDateText(), string.Empty, _con);
            }
        }
        private DateTime GetTbSelecteDateText()
        {
            bool _error = false;
            DateTime _dateTime = ConvertDateTime(tbSelectedDate.Text, out _error);
            if (_error)
            {
                tbSelectedDate.Text = _dateTime.ToString("MM/dd/yyyy");
            }

            return _dateTime;
        }
        private DateTime GetTbStartDateText()
        {
            bool _error = false;
            DateTime _dateTime = ConvertDateTime(tbStartDate.Text, out _error);
            if (_error)
            {
                tbStartDate.Text = _dateTime.ToString("MM/dd/yyyy");
            }

            return _dateTime;
        }
        private DateTime GetTbEndDateText()
        {
            bool _error = false;
            DateTime _dateTime = ConvertDateTime(tbEndDate.Text, out _error);
            if (_error)
            {
                tbEndDate.Text = GetTbStartDateText().AddDays(7).ToString("MM/dd/yyyy");
            }

            return _dateTime;
        }
        private DateTime ConvertDateTime(string inDateStr, out bool error)
        {
            error = false;
            DateTime _dateTime = DateTime.MaxValue;

            try
            {
                _dateTime = DateTime.Parse(inDateStr);
            }
            catch
            {
                _dateTime = DateTime.Today;
                error = true;
            }

            return _dateTime;
        }
        private void PopulateGridForSelectedDate(DateTime dateValue, string sortOrder, SqlConnection con)
        {
            DateTime _startDate = DateTime.MinValue;
            DateTime _endDate = DateTime.MinValue;

            if (RadioButtonListDateSelection.SelectedValue == "0")
            {
                _startDate = dateValue.DayOfWeek == DayOfWeek.Sunday ? dateValue : dateValue.AddDays(-1 * (int)dateValue.DayOfWeek);
                _endDate = dateValue.DayOfWeek == DayOfWeek.Saturday ? dateValue : dateValue.AddDays(6 - (int)dateValue.DayOfWeek);
            }
            else
            {
                _startDate = GetTbStartDateText();
                _endDate = GetTbEndDateText();
            }

            string _sqlStatement = @"
            select
	            TE.timeOfTask
	            ,P.firstName
	            ,P.lastName
	            ,TE.numberMinutes
	            ,TET.name AS 'TaskName'
	            ,TEType.name AS 'TaskType'
	            ,ISNULL(TE.note, '') AS 'note'
	            ,CASE
		            WHEN TE.IsProjectManagement = 1 THEN 'true'
		            ELSE 'false'
	             END AS 'IsProjectManagement'
	             ,CASE
		            WHEN TE.IsHelpDesk = 1 THEN 'true'
		            ELSE 'false'
	            END AS 'IsHelpDesk'
	            ,ISNULL(TE.ITPM_ID, '') AS 'ITPM_ID'
	            ,ISNULL(TE.HD_ROW_ID, '') AS 'HD_ROW_ID'
	            ,ISNULL(TE.Description, '') AS 'Description'
	            ,ISNULL(TE.FileNameReference, '') AS 'FileNameReference'
            from
	            [TimeKeeper].[dbo].[TimeEntries] TE
	            inner join [TimeKeeper].[dbo].[TimeEntry_Day] TED
		            on TED.id = TE.timeEntryDayID
	            inner join [TimeKeeper].[dbo].[Employees] E
		            on E.id = TED.employeeID
	            inner join [TimeKeeper].[dbo].[People] P
		            on P.id = E.personID
	            inner join [TimeKeeper].[dbo].[TimeEntry_Tasks] TET
		            on TET.id = TE.timeEntrytaskID
	            inner join [TimeKeeper].[dbo].[TimeEntry_Types] TEType
		            on TEType.id = TET.taskType
            where
	            E.id = @Id
                and TE.dateEntryCreated >= @StartDate
	            and TE.dateEntryCreated < @EndDate
            ";

            if (string.IsNullOrEmpty(sortOrder))
            {
                _sqlStatement += @" order by
                                       TE.timeOfTask";
            }
            else
            {
                _sqlStatement += AddSortExpression(sortOrder);
            }

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", TimeSheetSession.Current.EmployeeId);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@StartDate", _startDate.ToString("MM/dd/yyyy"));
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@EndDate", _endDate.ToString("MM/dd/yyyy"));
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            GridView1.DataSource = _dataTable;
            GridView1.DataBind();
        }

        private string AddSortExpression(string sortExpression)
        {
            string _orderBy = " order by ";

            switch (sortExpression)
            {
                case "timeOfTask":
                    if (string.IsNullOrEmpty(hiddenFieldTimeOfTaskSortOrder.Value) || hiddenFieldTimeOfTaskSortOrder.Value.Equals("DESC"))
                    {
                        hiddenFieldTimeOfTaskSortOrder.Value = "ASC";
                    }
                    else
                    {
                        hiddenFieldTimeOfTaskSortOrder.Value = "DESC";
                    }
                    _orderBy += " TE.timeOfTask " + hiddenFieldTimeOfTaskSortOrder.Value;
                    break;
                case "numberMinutes":
                    if (string.IsNullOrEmpty(hiddenFieldNumberMinutesSortOrder.Value) || hiddenFieldNumberMinutesSortOrder.Value.Equals("DESC"))
                    {
                        hiddenFieldNumberMinutesSortOrder.Value = "ASC";
                    }
                    else
                    {
                        hiddenFieldNumberMinutesSortOrder.Value = "DESC";
                    }
                    _orderBy += " TE.numberMinutes " + hiddenFieldNumberMinutesSortOrder.Value;
                    break;
                case "TaskName":
                    if (string.IsNullOrEmpty(hiddenFieldTaskNameSortOrder.Value) || hiddenFieldTaskNameSortOrder.Value.Equals("DESC"))
                    {
                        hiddenFieldTaskNameSortOrder.Value = "ASC";
                    }
                    else
                    {
                        hiddenFieldTaskNameSortOrder.Value = "DESC";
                    }
                    _orderBy += " TET.name " + hiddenFieldTaskNameSortOrder.Value;
                    break;
                case "TaskType":
                    if (string.IsNullOrEmpty(hiddenFieldTaskTypeSortOrder.Value) || hiddenFieldTaskTypeSortOrder.Value.Equals("DESC"))
                    {
                        hiddenFieldTaskTypeSortOrder.Value = "ASC";
                    }
                    else
                    {
                        hiddenFieldTaskTypeSortOrder.Value = "DESC";
                    }
                    _orderBy += " TEType.name " + hiddenFieldTaskTypeSortOrder.Value;
                    break;
                case "note":
                    if (string.IsNullOrEmpty(hiddenFieldNoteSortOrder.Value) || hiddenFieldNoteSortOrder.Value.Equals("DESC"))
                    {
                        hiddenFieldNoteSortOrder.Value = "ASC";
                    }
                    else
                    {
                        hiddenFieldNoteSortOrder.Value = "DESC";
                    }
                    _orderBy += " TE.note " + hiddenFieldNoteSortOrder.Value;
                    break;
                case "IsProjectManagement":
                    if (string.IsNullOrEmpty(hiddenFieldIsProjectManagementSortOrder.Value) || hiddenFieldIsProjectManagementSortOrder.Value.Equals("DESC"))
                    {
                        hiddenFieldIsProjectManagementSortOrder.Value = "ASC";
                    }
                    else
                    {
                        hiddenFieldIsProjectManagementSortOrder.Value = "DESC";
                    }
                    _orderBy += " IsProjectManagement " + hiddenFieldIsProjectManagementSortOrder.Value;
                    break;
                case "IsHelpDesk":
                    if (string.IsNullOrEmpty(hiddenFieldIsHelpDeskSortOrder.Value) || hiddenFieldIsHelpDeskSortOrder.Value.Equals("DESC"))
                    {
                        hiddenFieldIsHelpDeskSortOrder.Value = "ASC";
                    }
                    else
                    {
                        hiddenFieldIsHelpDeskSortOrder.Value = "DESC";
                    }
                    _orderBy += " IsHelpDesk " + hiddenFieldIsHelpDeskSortOrder.Value;
                    break;
                case "ITPM_ID":
                    if (string.IsNullOrEmpty(hiddenFieldITPM_IDSortOrder.Value) || hiddenFieldITPM_IDSortOrder.Value.Equals("DESC"))
                    {
                        hiddenFieldITPM_IDSortOrder.Value = "ASC";
                    }
                    else
                    {
                        hiddenFieldITPM_IDSortOrder.Value = "DESC";
                    }
                    _orderBy += " ITPM_ID " + hiddenFieldITPM_IDSortOrder.Value;
                    break;
                case "HD_ROW_ID":
                    if (string.IsNullOrEmpty(hiddenFieldHD_ROW_IDOrder.Value) || hiddenFieldHD_ROW_IDOrder.Value.Equals("DESC"))
                    {
                        hiddenFieldHD_ROW_IDOrder.Value = "ASC";
                    }
                    else
                    {
                        hiddenFieldHD_ROW_IDOrder.Value = "DESC";
                    }
                    _orderBy += " HD_ROW_ID " + hiddenFieldHD_ROW_IDOrder.Value;
                    break;
                case "Description":
                    if (string.IsNullOrEmpty(hiddenFieldDescriptionOrder.Value) || hiddenFieldDescriptionOrder.Value.Equals("DESC"))
                    {
                        hiddenFieldDescriptionOrder.Value = "ASC";
                    }
                    else
                    {
                        hiddenFieldDescriptionOrder.Value = "DESC";
                    }
                    _orderBy += " Description " + hiddenFieldDescriptionOrder.Value;
                    break;
                case "FileNameReference":
                    if (string.IsNullOrEmpty(hiddenFieldFileNameReferenceOrder.Value) || hiddenFieldFileNameReferenceOrder.Value.Equals("DESC"))
                    {
                        hiddenFieldFileNameReferenceOrder.Value = "ASC";
                    }
                    else
                    {
                        hiddenFieldFileNameReferenceOrder.Value = "DESC";
                    }
                    _orderBy += " FileNameReference " + hiddenFieldFileNameReferenceOrder.Value;
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
            PopulateGridForSelectedDate(e.SortExpression);
        }

        protected void lnkpickdate_Click(object sender, ImageClickEventArgs e)
        {
            datepicker.Visible = true;
        }

        protected void ButtonUpdate_Click(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                PopulateGridForSelectedDate(GetTbSelecteDateText(), string.Empty, _con);
            }
        }
        private void PopulateGridForSelectedDate(string sortOrder)
        {
            try
            {
                using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                {
                    PopulateGridForSelectedDate(GetTbSelecteDateText(), sortOrder, _con);
                }
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
        protected void datepicker_SelectionChanged(object sender, EventArgs e)
        {
            tbSelectedDate.Text = datepicker.SelectedDate.ToString("MM/dd/yyyy");
            datepicker.Visible = false;
        }
        protected void OnPageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            GridView1.PageIndex = e.NewPageIndex;
            PopulateGridForSelectedDate(string.Empty);
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
            PopulateGridForSelectedDate(string.Empty);

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
                sb.Append(((Label)_gridViewRow.FindControl("LabeltimeOfTask")).Text.Replace("<br/>", "   ") + "," +
                    ((Label)_gridViewRow.FindControl("LabelnumberMinutes")).Text.Replace("<br/>", "   ") + ", " +
                    ((Label)_gridViewRow.FindControl("LabelTaskName")).Text.Replace("<br/>", "   ") + "," +
                    ((Label)_gridViewRow.FindControl("LabelTaskType")).Text.Replace("<br/>", "   ") + "," +
                    ((Label)_gridViewRow.FindControl("LabelNote")).Text.Replace("<br/>", "   ") + "," +
                    ((Label)_gridViewRow.FindControl("LabelIsProjectManagement")).Text.Replace("<br/>", "   ") + "," +
                    ((Label)_gridViewRow.FindControl("LabelIsHelpDesk")).Text.Replace("<br/>", "   ") + "," +
                    ((Label)_gridViewRow.FindControl("LabelITPM_ID")).Text.Replace("<br/>", "   ") + "," +
                ((Label)_gridViewRow.FindControl("LabelHD_ROW_ID")).Text.Replace("<br/>", "   ") + "," +
                ((Label)_gridViewRow.FindControl("LabelDescription")).Text.Replace("<br/>", "   ") + "," +
                ((Label)_gridViewRow.FindControl("LabelFileNameReference")).Text.Replace("<br/>", "   "));
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

        protected void ButtonPrintREport_Click(object sender, EventArgs e)
        {
            string _page = "PrintTimeEntryReport.aspx";
            string _parameter = string.Empty;

            if (RadioButtonListDateSelection.SelectedIndex == 1)
            {
                _parameter = string.Format("startdate={0}&enddate={1}",
                    tbStartDate.Text, tbEndDate.Text);
            }
            else
            {
                DateTime _dateOfWeek = GetTbSelecteDateText();
                DateTime _startDate = DateTime.MinValue;
                DateTime _endDate = DateTime.MinValue;

                if (_dateOfWeek.DayOfWeek == 0)
                {
                    _startDate = _dateOfWeek;
                }
                else
                {
                    _startDate = _dateOfWeek.AddDays(-1 * (int)_dateOfWeek.DayOfWeek);
                }

                if ((int)_dateOfWeek.DayOfWeek == 6)
                {
                    _endDate = _dateOfWeek;
                }
                else
                {
                    int _numDays = 6 - (int)_dateOfWeek.DayOfWeek;
                    _endDate = _dateOfWeek.AddDays(_numDays);
                }

                _parameter = string.Format("startdate={0}&enddate={1}",
                    _startDate.ToString("MM/dd/yyyy"), _endDate.ToString("MM/dd/yyyy"));
            }

            string _url = MBA.HttpApplication.createLink(_page, true) + "&" + _parameter;
            Response.Redirect(_url, false);
        }
    }
}