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
    public partial class TimeVerificationAdmin : WebUI
    {
        public TimeVerificationAdmin()
               : base("timeverificationadmin", 
                     WebUI.CreatePageSubTitle("Time Verification Admin", "Create, update, or delete time verifications"), "screen.css", "", Constants.ROLE_SBS_ALL)
        {
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                DateTime _dateToRun = DateTime.Today;
                if (_dateToRun.DayOfWeek != DayOfWeek.Sunday)
                {
                    _dateToRun = _dateToRun.AddDays(-1 * (int)_dateToRun.DayOfWeek);
                }
                labelVerificationDate.Text = _dateToRun.ToString("MM/dd/yyyy");

                CalendarCalendarVerification.TodaysDate = DateTime.Today;
                labelSelectedStartDate.Text = "No Start Date Selected";
                labelSelectedEndDate.Text = "No Start End Selected";
                datepickerStartDate.SelectedDate = DateTime.Today;
                datepickerEndDate.SelectedDate = DateTime.Today;
                PopulateDropDownListEmployees();
                PopulateGrid();
            }

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
            SqlTransaction _objTrans = null;
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                try
                {
                    _con.Open();
                    _objTrans = _con.BeginTransaction();
                    labelVerificationDate.Text = CalendarCalendarVerification.SelectedDate.ToString("MM/dd/yyyy");
                    CalendarCalendarVerification.Visible = false;
                    AddPayrollVerificationIfNecessary(_con, _objTrans);
                    _objTrans.Commit();
                }
                catch
                {
                    _objTrans.Rollback();
                }
            }
            PopulateGrid();
        }
        private List<long> GetListOfEmployees(SqlConnection con, SqlTransaction objTrans)
        {
            List<long> _listOfEmployees = new List<long>();

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetEmployeeList", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            _sqlDataAdapter.SelectCommand.Transaction = objTrans;

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            foreach (DataRow _dataRow in _dataTable.Rows)
            {
                _listOfEmployees.Add(long.Parse(_dataRow["EmployeeId"].ToString()));
            }

            return _listOfEmployees;
        }
        private void AddPayrollVerificationIfNecessary(SqlConnection con, SqlTransaction objTrans)
        {
            // Get list of 
            List<long> _listEmployeeIds = GetListOfEmployees(con, objTrans);
            DateTime _firstDayOfTheWeek = DateTime.Parse(labelVerificationDate.Text);
            DateTime _lastDayOfTheWeek = _firstDayOfTheWeek.AddDays(7);

            // Find last day of employee schedule for the week
            foreach (long _employeeId in _listEmployeeIds)
            {
                InsertVerificationIfNeeded(con, objTrans, _employeeId, _firstDayOfTheWeek, _lastDayOfTheWeek);
            }
        }
        private DateTime GetLastDayOfSchedule(SqlConnection con, SqlTransaction objTrans, long employeeId, DateTime startDate, DateTime endDate)
        {
            DateTime _lastDayOfSchedule = DateTime.MinValue;

            //SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("SELECT * FROM TimeKeeper_TIMESHEET_GetSchedulesForEmployeesByDateRangeUDF(@startDate, @endDate, @employeeId)", con);
            //_sqlDataAdapter.SelectCommand.CommandType = CommandType.Text;
            
            // NOTE: this has been tested and seems to be working as a UDF call; perhaps could be tested further.  Reverting.
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetSchedulesForEmployeesByDateRange", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            _sqlDataAdapter.SelectCommand.Transaction = objTrans;

            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@startDate", startDate);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@endDate", endDate);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@employeeId", employeeId);

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            // Get last record 
            int _rowCount = _dataTable.Rows.Count;

            if (_rowCount > 0)
            {
                DataRow _dataRow = _dataTable.Rows[_rowCount - 1];
                _lastDayOfSchedule = (DateTime.Parse(_dataRow["dateOfSchedule"].ToString())).Date;
            }

            return _lastDayOfSchedule;
        }
        private void InsertVerificationIfNeeded(SqlConnection con, SqlTransaction objTrans,
            long employeeId, DateTime startDate, DateTime endDate)
        {
            DateTime _lastDayOfSchedule = GetLastDayOfSchedule(con, objTrans, employeeId, startDate, endDate);
            if (_lastDayOfSchedule == DateTime.MinValue)
            {
                return;
            }
            DateTime _dayBeforeLastScheduleDay = _lastDayOfSchedule.AddDays(-1);

            // Stored procedure will determine if a new record needs to be inserted
            SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_TIMESHEET_InsertEmployeeTimeVerfication", con);
            _sqlCommand.CommandType = CommandType.StoredProcedure;
            _sqlCommand.Transaction = objTrans;

            _sqlCommand.Parameters.AddWithValue("@employeeID", employeeId);
            _sqlCommand.Parameters.AddWithValue("@lastDayOfSchedule", _lastDayOfSchedule.ToString("MM/dd/yyyy"));
            _sqlCommand.Parameters.AddWithValue("@dateOfNotification", _dayBeforeLastScheduleDay.ToString("MM/dd/yyyy"));
            _sqlCommand.Parameters.AddWithValue("@startDateOfTheWeek", startDate);
            _sqlCommand.Parameters.AddWithValue("@stopDateOfTheWeek", endDate.AddDays(1));
            _sqlCommand.Parameters.AddWithValue("@comments", DBNull.Value);
            _sqlCommand.Parameters.Add("@Id", SqlDbType.BigInt);
            _sqlCommand.Parameters["@Id"].Direction = ParameterDirection.Output;

            _sqlCommand.ExecuteNonQuery();
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

                ListItem _listItem = new ListItem();
                _listItem.Value = "0";
                _listItem.Text = "All Employees";

                DropDownListEmployees.Items.Insert(0, _listItem);
                DropDownListEmployees.SelectedValue = "0";
            }
        }

        protected void PopulateGridByDate()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();

                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(
                    "SELECT * FROM" +
                      "[dbo].[TimeKeeper_TIMESHEET_FindEmployeeVerificationsByDateRange]( @startDate, @endDate)",
                    _con);
                _sqlDataAdapter.SelectCommand.CommandType = CommandType.Text; //CommandType.StoredProcedure;

                if (labelSelectedStartDate.Text != "No Start Date Selected")
                {
                    _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@startDate", labelSelectedStartDate.Text);
                }
                else
                {
                    _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@startDate", DBNull.Value);
                }

                if (labelSelectedEndDate.Text != "No Start End Selected")
                {
                    DateTime _endDate = DateTime.Parse(labelSelectedEndDate.Text).AddDays(1);
                    _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@endDate", _endDate.ToString("MM/dd/yyyy"));
                }
                else
                {
                    _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@endDate", DBNull.Value);
                }

                DataTable _dataTable = new DataTable();
                _sqlDataAdapter.Fill(_dataTable);

                //var rd = MBA.Database.execQuery(_con, log, sql, false, parms);

                repeaterVerification.DataSource = _dataTable;
                repeaterVerification.DataBind();
            }

            if (repeaterVerification.Items.Count > 0)
            {
                FixDateInGrid();
            }
        }

        protected void PopulateGridByEmployeeStartEndDate()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();

                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHET_GetEmployeeVerificationByNameDateRange", _con);
                _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@employeeId", DropDownListEmployees.SelectedValue);
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@startDate", labelSelectedStartDate.Text);

                DateTime _endDate = DateTime.Parse(labelSelectedEndDate.Text).AddDays(1);
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@endDate", _endDate.ToString("MM/dd/yyyy"));

                DataTable _dataTable = new DataTable();
                _sqlDataAdapter.Fill(_dataTable);

                repeaterVerification.DataSource = _dataTable;
                repeaterVerification.DataBind();
            }

            if (repeaterVerification.Items.Count > 0)
            {
                FixDateInGrid();
            }
        }

        protected void PopulateGridByEmployee()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();

                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHET_GetEmployeeVerificationByName", _con);
                _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@employeeId", DropDownListEmployees.SelectedValue);
                                                                       
                DataTable _dataTable = new DataTable();
                _sqlDataAdapter.Fill(_dataTable);

                repeaterVerification.DataSource = _dataTable;
                repeaterVerification.DataBind();
            }

            if (repeaterVerification.Items.Count > 0)
            {
                FixDateInGrid();
            }
        }
        protected void PopulateGrid()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();

                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHET_GetEmployeeVerification", _con);
                _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
                DataTable _dataTable = new DataTable();
                _sqlDataAdapter.Fill(_dataTable);

                repeaterVerification.DataSource = _dataTable;
                repeaterVerification.DataBind();
            }

            if (repeaterVerification.Items.Count > 0)
            {
                FixDateInGrid();
            }
        }

        private void FixDateInGrid()
        {
            Label labellastDayOfSchedule, labelDateVerified;

            foreach (RepeaterItem rptItem in repeaterVerification.Items)
            {
                labellastDayOfSchedule = (Label)rptItem.FindControl("labellastDayOfSchedule");
                labelDateVerified = (Label)rptItem.FindControl("labelDateVerified");

                labellastDayOfSchedule.Text = DateTime.Parse(labellastDayOfSchedule.Text).ToString("MM/dd/yyyy");
                if (!string.IsNullOrEmpty(labelDateVerified.Text))
                {
                    labelDateVerified.Text = DateTime.Parse(labelDateVerified.Text).ToString("MM/dd/yyyy");
                }
            }
        }

        protected void ButtonClearDateFilter_Click(object sender, EventArgs e)
        {
            labelSelectedStartDate.Text = "No Start Date Selected";
            labelSelectedEndDate.Text = "No Start End Selected";
        }

        protected void imageButtonStartDate_Click(object sender, ImageClickEventArgs e)
        {
            datepickerStartDate.Visible = true;
        }

        protected void ImageButtonEndDate_Click(object sender, ImageClickEventArgs e)
        {
            datepickerEndDate.Visible = true;
        }

        protected void ButtonVerify_Click(object sender, EventArgs e)
        {
            string _confirmUpdate = Request.Form["confirm_update"];
            if (_confirmUpdate != "Yes")
            {
                return;
            }
            if (rd.wu.usr.timeSheetUserInfo == null)
            {
                rd.wu.usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(rd.wu.usr.userName);
            }

            using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                con.Open();
                //Reference the Repeater Item using Button.
                RepeaterItem item = ((sender as Button).NamingContainer as RepeaterItem);
                SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_TIMESHEET_UpdateEmployeeTimeVerfication", con);
                _sqlCommand.CommandType = CommandType.StoredProcedure;

                HiddenField HiddenFieldId = (HiddenField)item.FindControl("HiddenFieldId");
                _sqlCommand.Parameters.AddWithValue("@Id", HiddenFieldId.Value);

                _sqlCommand.Parameters.AddWithValue("@isVerified", true);

                HiddenField HiddenFieldEmployeeId = (HiddenField)item.FindControl("HiddenFieldEmployeeId");
                _sqlCommand.Parameters.AddWithValue("@employeeID", HiddenFieldEmployeeId.Value);

                Label labellastDayOfSchedule = (Label)item.FindControl("labellastDayOfSchedule");
                _sqlCommand.Parameters.AddWithValue("@lastDayOfSchedule", labellastDayOfSchedule.Text);

                _sqlCommand.Parameters.AddWithValue("@dateVerified", DateTime.Today.ToString("MM/dd/yyyy"));

                TextBox textBoxComments = (TextBox)item.FindControl("textBoxComments");
                _sqlCommand.Parameters.AddWithValue("@comments", textBoxComments.Text);

                _sqlCommand.Parameters.AddWithValue("@WhoVerifiedHours", rd.wu.usr.id);

                _sqlCommand.ExecuteNonQuery();

            }
            SearchVerifications();
        }

        protected void ButtonRemoveVerify_Click(object sender, EventArgs e)
        {
            string _confirmUpdate = Request.Form["confirm_update"];
            if (_confirmUpdate != "Yes")
            {
                return;
            }
            using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                con.Open();
                //Reference the Repeater Item using Button.
                RepeaterItem item = ((sender as Button).NamingContainer as RepeaterItem);
                SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_TIMESHEET_UpdateEmployeeTimeVerfication", con);
                _sqlCommand.CommandType = CommandType.StoredProcedure;

                HiddenField HiddenFieldId = (HiddenField)item.FindControl("HiddenFieldId");
                _sqlCommand.Parameters.AddWithValue("@Id", HiddenFieldId.Value);

                _sqlCommand.Parameters.AddWithValue("@isVerified", false);

                HiddenField HiddenFieldEmployeeId = (HiddenField)item.FindControl("HiddenFieldEmployeeId");
                _sqlCommand.Parameters.AddWithValue("@employeeID", HiddenFieldEmployeeId.Value);

                Label labellastDayOfSchedule = (Label)item.FindControl("labellastDayOfSchedule");
                _sqlCommand.Parameters.AddWithValue("@lastDayOfSchedule", labellastDayOfSchedule.Text);

                _sqlCommand.Parameters.AddWithValue("@dateVerified", DBNull.Value);

                TextBox textBoxComments = (TextBox)item.FindControl("textBoxComments");
                _sqlCommand.Parameters.AddWithValue("@comments", textBoxComments.Text);

                _sqlCommand.Parameters.AddWithValue("@WhoVerifiedHours", rd.wu.usr.id);

                _sqlCommand.ExecuteNonQuery();

            }
            SearchVerifications();
        }

        protected void ButtonUpdate_Click(object sender, EventArgs e)
        {
            SearchVerifications();
        }

        private void SearchVerifications()
        { 
            if ((DropDownListEmployees.SelectedValue == "0")
                && (labelSelectedStartDate.Text == "No Start Date Selected")
                && (labelSelectedEndDate.Text == "No Start End Selected"))
            {
                PopulateGrid();
            }
            else if ((DropDownListEmployees.SelectedValue != "0")
                && (labelSelectedStartDate.Text != "No Start Date Selected")
                && (labelSelectedEndDate.Text != "No Start End Selected"))
            {
                PopulateGridByEmployeeStartEndDate();
            }
            else if ((DropDownListEmployees.SelectedValue != "0")
                && (labelSelectedStartDate.Text == "No Start Date Selected")
                && (labelSelectedEndDate.Text == "No Start End Selected"))
            {
                PopulateGridByEmployee();
            }
            else
            {
                PopulateGridByDate();
            }
        }

        protected void datepickerStartDate_SelectionChanged(object sender, EventArgs e)
        {
            labelSelectedStartDate.Text = datepickerStartDate.SelectedDate.ToString("MM/dd/yyyy");
            datepickerStartDate.Visible = false;
        }

        protected void datepickerEndDate_SelectionChanged(object sender, EventArgs e)
        {
            labelSelectedEndDate.Text = datepickerEndDate.SelectedDate.ToString("MM/dd/yyyy");
            datepickerEndDate.Visible = false;
        }

        protected void imageButtonDateToRunVerification_Click(object sender, ImageClickEventArgs e)
        {
            CalendarCalendarVerification.Visible = true;
        }
    }
}