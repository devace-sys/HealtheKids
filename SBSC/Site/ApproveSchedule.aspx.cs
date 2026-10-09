using MBA;
using MBA.Web;
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
    public partial class ApproveSchedule : WebUI
    {
        public ApproveSchedule()
             : base("timeentry", WebUI.CreatePageSubTitle("Approve Schedule", ""), "", "", Constants.ROLE_SBS_ALL)
        {
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
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

                    Literal1Message.Text = "<h3>Please approve schedule for date " + HiddenFieldStartDate.Value
                        + " to " + HiddenFieldEndDate.Value + "</h3>";
                }
            }
        }

        private bool isDateSelectedValue()
        {
            DateTime _dateSelected = DateTime.MinValue;
            if (Request.QueryString["dateSelected"] == null)
            {
                return false;
            }

            if (!DateTime.TryParse(Request.QueryString["dateSelected"].ToString(), out _dateSelected))
            {
                return false;
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
            int _employeeId = 0;
            if (Request.QueryString["employeeid"] == null)
            {
                return false;
            }
            int.TryParse(Request.QueryString["employeeid"].ToString(), out _employeeId);

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
	                [id] = @id";

            DataTable _dataTable = new DataTable();
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@id", _employeeId);
            _sqlDataAdapter.Fill(_dataTable);

            if (_dataTable.Rows.Count == 0)
            {
                return false;
            }

            HiddenFieldEmployeeId.Value = _employeeId.ToString();

            return true;
        }

        protected void CheckBoxApproveSchedule_CheckedChanged(object sender, EventArgs e)
        {
            DateTime _selectedDate = DateTime.Parse(HiddenFieldSelectedDate.Value);
            int _numberRows = 0;

            if (TimeEntrySchedule.isScheduleApproved(int.Parse(HiddenFieldEmployeeId.Value), _selectedDate, ref _numberRows))
            {
                Response.Redirect(MBA.HttpApplication.createLink(HiddenFieldReferringPage.Value, true));
                return;
            }

            if (_numberRows == 0)
            {
                ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                    "Schedule not generated yet",
                    "alert('Your schedule has not been auto generated yet.');",
                    true);
                Response.Redirect(MBA.HttpApplication.createLink(HiddenFieldReferringPage.Value, true));
                return;
            }

            // Only update record if check box is true
            if (!CheckBoxApproveSchedule.Checked)
            {
                Response.Redirect(MBA.HttpApplication.createLink(HiddenFieldReferringPage.Value, true));
                return;
            }

            DateTime _startDate = _selectedDate.DayOfWeek == DayOfWeek.Sunday ? _selectedDate :
                 _selectedDate.AddDays(-1 * (int)_selectedDate.DayOfWeek);
            DateTime _endDate = _selectedDate.DayOfWeek == DayOfWeek.Saturday ? _selectedDate :
                    _selectedDate.AddDays(6 - (int)_selectedDate.DayOfWeek);

            string _sqlStatement = @"
            UPDATE [TimeKeeper].[dbo].[ScheduleApproved]
               SET [isApproved] = 1
             WHERE 
	            startDate = @StartDate
	            and endDate = @EndDate
                and employeeID = @EmployeeID";

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();

                SqlCommand _sqlcommand = new SqlCommand(_sqlStatement, _con);
                _sqlcommand.Parameters.AddWithValue("@StartDate", _startDate.ToString("MM/dd/yyyy"));
                _sqlcommand.Parameters.AddWithValue("@EndDate", _endDate.ToString("MM/dd/yyyy"));
                _sqlcommand.Parameters.AddWithValue("@EmployeeID", HiddenFieldEmployeeId.Value);

                _sqlcommand.ExecuteScalar();
            }

            Response.Redirect(HiddenFieldReferringPage.Value, false);
        }

    }
}