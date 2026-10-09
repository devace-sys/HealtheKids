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
    public partial class ScheduleReport : WebUI
    {
        public ScheduleReport()
             : base("reports", WebUI.CreatePageSubTitle("Employee Schedule Report", "Employees schedule report"),
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
                PopulateEmployeeDropDownList();
                GetEmployeeInfo();
            }
        }

        private void PopulateEmployeeDropDownList()
        {
            string _sqlStatement = @"
                select 
	                E.id
	                ,P.lastName + ', ' +  P.firstName as employeeName
                from 
	                TimeKeeper.dbo.Employees E
	                inner join TimeKeeper.dbo.People P
		                ON P.id = E.personID
                order by
                    P.lastName, P.firstName";
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                DataTable _dataTable = new DataTable();
                _sqlDataAdapter.Fill(_dataTable);

                DropDownListEmployees.DataTextField = "employeeName";
                DropDownListEmployees.DataValueField = "id";
                DropDownListEmployees.DataSource = _dataTable;
                DropDownListEmployees.DataBind();
            }
        }

        private void GetEmployeeInfo(int ?employeeInfo=null)
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
                           and O.active = 1";

                if (employeeInfo == null)
                {
                    _sqlStatement += @"
                    where
                        E.id = @Id";
                }
                else
                {
                    _sqlStatement += @"
                    where
                        E.id = @Id";
                }

                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                if (employeeInfo == null)
                {
                    _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", TimeSheetSession.Current.EmployeeId);
                }
                else
                {
                    _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", employeeInfo.Value.ToString());
                }

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

                if (employeeInfo == null)
                {
                    DropDownListEmployees.SelectedValue = _dataRow["id"].ToString();
                }

                PopulateGridForSelectedDate(GetTbSelectedDateTimeText(), string.Empty, _con);
            }
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
                _startDate = DateTime.Parse(tbStartDate.Text);
                _endDate = DateTime.Parse(tbEndDate.Text);
            }

            string _sqlStatement = @"
            select
	            CAST(SA.startDate AS DATE) AS 'startDatePayPeriod'
	            ,CAST(SA.endDate AS DATE) AS 'endDatePayPeriod'
	            ,case
		            when SA.isApproved = 1 then 'true'
		            else 'false'
	             end AS isApproved
	             ,S.dateOfSchedule AS 'scheduleDay'
	             ,SS.starttime
	             ,SS.stopTime
	             ,datediff(minute, SS.startTime, SS.stopTime) AS 'elapsedMinutes'
            from
	            [TimeKeeper].[dbo].[ScheduleApproved] SA
	            inner join [TimeKeeper].[dbo].[Schedule] S
		            ON S.scheduleApprovedId = SA.id
	            inner join [TimeKeeper].[dbo].[ScheduleStartAndStopTime] SS
		            ON SS.scheduleid = S.id
            where
	            SA.employeeID = @EmployeeID
                and SA.startDate >= @StartDate
	            and SA.endDate < @EndDate
            ";

            if (string.IsNullOrEmpty(sortOrder))
            {
                _sqlStatement += @"order by
	                S.dateOfSchedule
	                ,SS.startTime
	                ,SS.stopTime
                ";
            }
            else
            {
                _sqlStatement += AddSortExpression(sortOrder);
            }

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@EmployeeID", DropDownListEmployees.SelectedValue);
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
                case "scheduleDay":
                    if (string.IsNullOrEmpty(hiddenFieldscheduleDaySortOrder.Value) || hiddenFieldscheduleDaySortOrder.Value.Equals("DESC"))
                    {
                        hiddenFieldscheduleDaySortOrder.Value = "ASC";
                    }
                    else
                    {
                        hiddenFieldscheduleDaySortOrder.Value = "DESC";
                    }
                    _orderBy += " S.dateOfSchedule " + hiddenFieldscheduleDaySortOrder.Value;
                    break;
                case "startTime":
                    if (string.IsNullOrEmpty(hiddenFieldstartTimeSortOrder.Value) || hiddenFieldstartTimeSortOrder.Value.Equals("DESC"))
                    {
                        hiddenFieldstartTimeSortOrder.Value = "ASC";
                    }
                    else
                    {
                        hiddenFieldstartTimeSortOrder.Value = "DESC";
                    }
                    _orderBy += " SA.startDate " + hiddenFieldstartTimeSortOrder.Value;
                    break;
                case "stopTime":
                    if (string.IsNullOrEmpty(hiddenFieldstopTimeSortOrder.Value) || hiddenFieldstopTimeSortOrder.Value.Equals("DESC"))
                    {
                        hiddenFieldstopTimeSortOrder.Value = "ASC";
                    }
                    else
                    {
                        hiddenFieldstopTimeSortOrder.Value = "DESC";
                    }
                    _orderBy += " SA.endDate " + hiddenFieldstopTimeSortOrder.Value;
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
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                Label LabelelapsedMinutes = (Label)e.Row.FindControl("LabelelapsedMinutes");
                LabelelapsedMinutes.Text = ((int)(double.Parse(LabelelapsedMinutes.Text) / 60.0)).ToString() + " Hours " +
                    (int.Parse(LabelelapsedMinutes.Text) % 60).ToString() + " Minutes";

                Label LabelscheduleDay = (Label)e.Row.FindControl("LabelscheduleDay");
                LabelscheduleDay.Text = DateTime.Parse(LabelscheduleDay.Text).ToString("MM/dd/yyyy");

                Label LabelstartTime = (Label)e.Row.FindControl("LabelstartTime");
                LabelstartTime.Text = DateTime.Parse(LabelstartTime.Text).ToString("hh:mm tt");

                Label LabelstopTime = (Label)e.Row.FindControl("LabelstopTime");
                LabelstopTime.Text = DateTime.Parse(LabelstopTime.Text).ToString("hh:mm tt");

            }
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
                PopulateGridForSelectedDate(GetTbSelectedDateTimeText(), string.Empty, _con);
            }
        }

        private DateTime GetTbSelectedDateTimeText()
        {
            bool _error = false;
            DateTime _dateTime = ConvertEnteredDate(tbSelectedDate.Text, out _error);
            if (_error)
            {
                tbSelectedDate.Text = _dateTime.ToString("MM/dd/yyyy");
            }

            return _dateTime;
        }
        private DateTime ConvertEnteredDate(string strDate, out bool error)
        {
            error = false;
            DateTime _dateTime;

            try
            {
                _dateTime = DateTime.Parse(strDate);
            }
            catch
            {
                _dateTime = DateTime.Today;
                error = true;
            }

            return _dateTime;
        }
        private void PopulateGridForSelectedDate(string sortOrder)
        {
            try
            {
                using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                {
                    PopulateGridForSelectedDate(GetTbSelectedDateTimeText(), sortOrder, _con);
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
                sb.Append(GridView1.Columns[k].HeaderText.Replace("<strong style='font-weight:bold; text-align: center; vertical-align: middle; padding-left:85px'>", "")
                .Replace("<strong style='font-weight:bold; text-align: center; vertical-align: middle; padding-left:85px'>", "")
                .Replace("<strong style='font-weight:bold; text-align: center; vertical-align: middle; padding-left:125px'>", "")
                .Replace("<strong style='font-weight:bold; text-align: center; vertical-align: middle; padding-left:15px'>", "")
                .Replace("<strong style='font-weight:bold; text-align: center; vertical-align: middle; padding-left:25px'>", "")
                .Replace("</strong>", "")
                .Replace("<br/>", "") + ',');
            }
            //append new line
            sb.Append("\r\n");
            foreach (GridViewRow _gridViewRow in GridView1.Rows)
            {
                sb.Append(((Label)_gridViewRow.FindControl("LabelisApproved")).Text.Replace("<br/>", "   ") + "," +
                    ((Label)_gridViewRow.FindControl("LabelscheduleDay")).Text.Replace("<br/>", "   ") + "," +
                    ((Label)_gridViewRow.FindControl("LabelstartTime")).Text.Replace("<br/>", "   ") + ", " +
                    ((Label)_gridViewRow.FindControl("LabelstopTime")).Text.Replace("<br/>", "   ") + "," +
                    ((Label)_gridViewRow.FindControl("LabelelapsedMinutes")).Text.Replace("<br/>", "   "));
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

        protected void DropDownListEmployees_SelectedIndexChanged(object sender, EventArgs e)
        {
            int? _employeeInfo = int.Parse(DropDownListEmployees.SelectedValue);
            GetEmployeeInfo(_employeeInfo);
        }
    }
}