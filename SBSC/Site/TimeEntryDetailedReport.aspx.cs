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
    public partial class TimeEntryDetailedReport : WebUI
    {
        class TaskInformationRecord
        {
            public TaskInformationRecord()
            {
//                Tasks = new List<TasksInformationDay>();
            }
            public int Employee_ID { get; set; }
            public string Last_Name { get; set; }
            public string First_Name { get; set; }

            public string Client { get; set; }

            public string Date { get; set; }

            public string Task { get; set; }

            public string Emp_Type { get; set; }

            public string HoursReported { get; set; }
            public string RegularHours { get; set; }

            public string HolidayHours { get; set; }

            public string PaidBreak { get; set; }
            public string SickHours { get; set; }
            public string VacationHours { get; set; }
            
            //public List<TasksInformationDay> Tasks { get; set; }
            public string startTime { get; set; }

            public string notes { get; set; }

            public string UnpaidTimeOff { get; set; }

        }

        private List<TaskInformationRecord> _ListOfRecords;

        public TimeEntryDetailedReport()
             : base("reports", WebUI.CreatePageSubTitle("Detailed Report", "Get detailed report"),
                  "", "", Constants.ROLE_SBS_ALL)
        {
            _ListOfRecords = new List<TaskInformationRecord>();
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                DateTime _currentDate = DateTime.Now;
                DateTime _startDate = DateTime.MinValue;
                DateTime _endDate = DateTime.MinValue;

                if (_currentDate.DayOfWeek == 0)
                {
                    _startDate = _currentDate;
                }
                else
                {
                    _startDate = _currentDate.AddDays(-1 * (int)_currentDate.DayOfWeek);
                }

                if ((int)_currentDate.DayOfWeek == 6)
                {
                    _endDate = _currentDate;
                }
                else
                {
                    _endDate = _currentDate.AddDays(6 - (int)_currentDate.DayOfWeek);
                }

                tbStartDate.Text = _startDate.ToString("MM/dd/yyyy");
                tbEndDate.Text = _endDate.ToString("MM/dd/yyyy");
                PopulateEmployeeDropDownList();
                GetReportInfo();
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

                ListItem _item = new ListItem();
                _item.Text = "All Employees";
                _item.Value = "0";
                DropDownListEmployees.Items.Insert(0, _item);
                DropDownListEmployees.SelectedIndex = 0;
            }
        }

        private void GetReportInfo()
        {
            _ListOfRecords.Clear();
            labelReportContent.Text = string.Empty;
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {


                string _sqlStatement;
            
                if (DropDownListEmployees.SelectedItem.Value != "0")
                {
                    _sqlStatement = @"select * FROM [dbo].[TimeKeeper_EMPLOYEE_DETAIL_PORTED]( @Empid, @startDate, @endDate )";
                }
                else
                {
                    _sqlStatement = @"select * FROM [dbo].[TimeKeeper_EMPLOYEE_DETAIL_PORTED]( null, @startDate, @endDate )";
                }
                
                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Empid", DropDownListEmployees.SelectedItem.Value);

                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@startDate", tbStartDate.Text);

                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@endDate", tbEndDate.Text);

                DataTable _dataTable = new DataTable();
                _sqlDataAdapter.Fill(_dataTable);

                if (_dataTable.Rows.Count == 0)
                {
                    labelReportContent.Text = "No data for that employee";
                    return;
                }

                //int _employeeId = 0;
                TaskInformationRecord _taskInformationRecord = null;

                foreach (DataRow _dataRow in _dataTable.Rows)
                //foreach (MBA.Record _rec in rdb.records)
                {
                    /*
                    _employeeId = int.Parse(_dataRow["EmployeeId"].ToString());
                    if (_ListOfRecords.Any(item => item.EmployeeId == _employeeId))
                    {
                        _taskInformationRecord = _ListOfRecords.Single(item => item.EmployeeId == _employeeId);
                    }
                    else
                    { */
                        _taskInformationRecord = new TaskInformationRecord();
                        _taskInformationRecord.Employee_ID = int.Parse(_dataRow["Employee_ID"].ToString());
                        _taskInformationRecord.First_Name = _dataRow["First_Name"].ToString();
                        _taskInformationRecord.Last_Name = _dataRow["Last_Name"].ToString();
                        _taskInformationRecord.Client = _dataRow["Client"].ToString();

                        _taskInformationRecord.Date  = Convert.ToDateTime(_dataRow["Date"].ToString()).ToString("MM/dd/yyyy");
                        _taskInformationRecord.Task = _dataRow["Task"].ToString();
                        _taskInformationRecord.Emp_Type = _dataRow["Emp_Type"].ToString();

                        _taskInformationRecord.RegularHours  = _dataRow["Regular_Hours"].ToString();
                        _taskInformationRecord.HoursReported  = _dataRow["Hours_Reported"].ToString();
                        _taskInformationRecord.PaidBreak     = _dataRow["Paid_break"].ToString();
                        _taskInformationRecord.SickHours     = _dataRow["Sick_Hours"].ToString();
                        _taskInformationRecord.VacationHours = _dataRow["Paid_Vaca"].ToString();
                        _taskInformationRecord.HolidayHours  = _dataRow["Holiday_Hours"].ToString();
                        //_taskInformationRecord.UnpaidOvertimeHours = _dataRow["Unpaid_Work_Hours"].ToString();
                        //_taskInformationRecord.MissingHours = _dataRow["Missing_Time"].ToString();
                        
                        //_taskInformationRecord.TotalMinutes  = _dataRow["Work_Hours_Reported"].ToString();
                        _taskInformationRecord.UnpaidTimeOff = _dataRow["UnPaid_TimeOff"].ToString();

                        _taskInformationRecord.startTime = Convert.ToDateTime(_dataRow["startTime"].ToString()).ToString("HH:mm");
                    //_taskInformationRecord.endTime = _dataRow["endTime"].ToString();

                    _taskInformationRecord.notes = _dataRow["Notes"].ToString();


                    _ListOfRecords.Add(_taskInformationRecord);
                }

                BuildReport();
            }
        }

        private void BuildReport()
        {
            labelReportContent.Text = @"
            <table>
                <tr style='background-color:#9FC6CB;font-weight:bold; height: 40px;border-bottom: 2px ridge black;'>
                    <th style='padding: 0 1.25em'><strong style='font-weight: bold'>Client</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th style='padding: 0 1.25em'><strong style='font-weight: bold'>Date</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th style='padding: 0 1.25em'><strong style='font-weight: bold'>Task</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th style='padding: 0 1.25em'><strong style='font-weight: bold'>Employee Type</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th style='padding: 0 1.25em'><strong style='font-weight: bold'>Last Name</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th style='padding: 0 1.25em'><strong style='font-weight: bold'>First Name</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>

                    <th style='padding: 0 1.25em;text-align:right'><strong style='font-weight: bold'>Reported<br/>Hours</strong></th>
                    <th style='padding: 0 1.25em;text-align:right'><strong style='font-weight: bold'>Regular<br/>Hours</strong></th>
                    <th style='padding: 0 1.25em;text-align:right'><strong style='font-weight: bold'>Paid Break</strong></th>
                    <th style='padding: 0 1.25em;text-align:right'><strong style='font-weight: bold'>Sick Hours</strong></th>
                    <th style='padding: 0 1.25em;text-align:right'><strong style='font-weight: bold'>Vacation Hours</strong></th>
                    <th style='padding: 0 1.25em;text-align:right'><strong style='font-weight: bold'>Holiday Hours</strong></th>
                    <th style='padding: 0 1.25em;text-align:right'><strong style='font-weight: bold'>Unpaid<br/>Time Off</strong></th>

                    <th style='padding: 0 1.25em;text-align:right'><strong style='font-weight: bold'>Start Time</strong></th>

                    <th style='padding: 0 1.25em;text-align:right'><strong style='font-weight: bold'>Notes</strong></th>
                </tr>";

            bool flip_odd=true;
            foreach(TaskInformationRecord _taskInformation in _ListOfRecords)
            {

                labelReportContent.Text += @"
                <tr style='background-color:" + (flip_odd ? @"#E3EAEB" : @"white")  + @";border-bottom: 2px ridge black;'>
                    <td>" + _taskInformation.Client + @"</td>
                    <td>" + _taskInformation.Date + @"</td>
                    <td>" + _taskInformation.Task + @"</td>
                    <td>" + _taskInformation.Emp_Type + @"</td>
                    <td>" + _taskInformation.Last_Name + @"</td>
                    <td>" + _taskInformation.First_Name + @"</td>

                    <td style='text-align: right;padding: 0 1.25em'>" + _taskInformation.HoursReported + @"</td>
                    <td style='text-align: right;padding: 0 1.25em'>" + _taskInformation.RegularHours + @"</td> 
                    <td style='text-align: right;padding: 0 1.25em'>" + _taskInformation.PaidBreak + @"</td> 
                    <td style='text-align: right;padding: 0 1.25em'>" + _taskInformation.SickHours + @"</td>
                    <td style='text-align: right;padding: 0 1.25em'>" + _taskInformation.VacationHours + @"</td>
                    <td style='text-align: right;padding: 0 1.25em'>" + _taskInformation.HolidayHours + @"</td>
                    <td style='text-align: right;padding: 0 1.25em'>" + _taskInformation.UnpaidTimeOff + @"</td>

                    <td style='text-align: right;padding: 0 1.25em'>" + _taskInformation.startTime + @"</td>

                    " + "<td style='text-align: right;padding: 0 1.25em'>" + _taskInformation.notes + @"</td>
                </tr>";
                flip_odd = !flip_odd;
            }

            labelReportContent.Text += @"
            </table>";
        }

        protected void ButtonUpdateDateRange_Click(object sender, EventArgs e)
        {
            GetReportInfo();
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
        protected void lnkPicEndDate_Click(object sender, ImageClickEventArgs e)
        {
            CalendarEnd.Visible = true;
        }

        protected void lknPicStartDate_Click(object sender, ImageClickEventArgs e)
        {
            CalendarStart.Visible = true;
        }

        protected void ButtonExport_Click(object sender, EventArgs e)
        {
            GetReportInfo();

            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition",
             "attachment;filename=PayrollExport.csv");
            Response.Charset = "";
            Response.ContentType = "application/text";

            string _exportCSV = string.Empty;

            _exportCSV = "Last Name,First Name,Client,Date,Task,Employee_Type,HoursReported,RegularHours,PaidBreak,SickHours,VacationHours,HolidayHours,UnpaidTimeoff,StartTime,Notes\r\n";
            
            foreach (TaskInformationRecord _taskInformation in _ListOfRecords)
            {
                _exportCSV +=
                    _taskInformation.Last_Name + "," +
                    _taskInformation.First_Name + "," +


                    _taskInformation.Client + "," +
                    _taskInformation.Date + "," +
                    _taskInformation.Task + "," +
                    _taskInformation.Emp_Type + "," +

                    _taskInformation.HoursReported + "," +
                    _taskInformation.RegularHours + "," +
                    _taskInformation.PaidBreak + "," +
                    _taskInformation.SickHours + "," +
                    _taskInformation.VacationHours + "," +
                    _taskInformation.HolidayHours + "," +
                    _taskInformation.UnpaidTimeOff + "," +

                    _taskInformation.startTime + "," +

                    _taskInformation.notes +  "\r\n";
            }

            Response.Output.Write(_exportCSV);
            Response.Flush();
            Response.End();

        }

        protected void DropDownListEmployees_SelectedIndexChanged(object sender, EventArgs e)
        {
             GetReportInfo();
        }
    }
}