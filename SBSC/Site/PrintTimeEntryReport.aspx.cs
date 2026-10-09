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
    public partial class PrintTimeEntryReport : WebUI
    {
        public PrintTimeEntryReport()
             : base("reports", WebUI.CreatePageSubTitle("Print Employees Time Entry Report", ""),
                  "", "", Constants.ROLE_SBS_ALL)
        {
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateGridForSelectedDate();
            }
        }

        private void PopulateGridForSelectedDate()
        {
            labelReportContent.Text = string.Empty;

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                DateTime _startDate = DateTime.Parse(Request.QueryString["startdate"].ToString());
                DateTime _endDate = DateTime.Parse(Request.QueryString["enddate"].ToString());

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
                order by
                    TE.timeOfTask";

                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", TimeSheetSession.Current.EmployeeId);
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@StartDate", _startDate.ToString("MM/dd/yyyy"));
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@EndDate", _endDate.ToString("MM/dd/yyyy"));
                DataTable _dataTable = new DataTable();
                _sqlDataAdapter.Fill(_dataTable);

                if (_dataTable.Rows.Count == 0)
                {
                    labelReportContent.Text = "No data for time period";
                    return;
                }
                labelReportContent.Text = @"
                    <table>
                        <tr>
                            <th>Time of Task</th>
                            <th>Number of Minutes</th>
                            <th>Task Name</th>
                            <th>Task Type</th>
                            <th>Note</th>
                            <th>Is Project Management</th>
                            <th>Is Help Desk</th>
                            <th>ITPM ID</th>
                            <th>HD ROW ID</th>
                            <th>Description</th>
                            <th>File Name Reference</th> 
                        </tr>
                    ";

                foreach(DataRow _dataRow in _dataTable.Rows)
                {
                    labelReportContent.Text += @"
                        <tr>
                            <td>" + _dataRow["timeOfTask"].ToString() + @"</td>
                            <td>" + _dataRow["numberMinutes"].ToString() + @"</td>
                            <td>" + _dataRow["TaskName"].ToString() + @"</td>
                            <td>" + _dataRow["TaskType"].ToString() + @"</td>
                            <td>" + _dataRow["note"].ToString() + @"</td>
                            <td>" + (_dataRow["IsProjectManagement"].ToString() == "1" ? "true" : "false") + @"</td>
                            <td>" + (_dataRow["IsHelpDesk"].ToString() == "1" ? "true" : "false") + @"</td>
                            <td>" + (_dataRow["ITPM_ID"].ToString() == "1" ? "true" : "false") + @"</td>
                            <td>" + (_dataRow["HD_ROW_ID"].ToString() == "1" ? "true" : "false") + @"</td>
                            <td>" + (_dataRow["Description"].ToString() == "1" ? "true" : "false") + @"</td>
                            <td>" + (_dataRow["FileNameReference"].ToString() == "1" ? "true" : "false") + @"</td>
                        </tr>";
                }

                labelReportContent.Text +=
                   "</table>";

            }
        }

        protected void ButtonCancel_Click(object sender, EventArgs e)
        {
            string _url = MBA.HttpApplication.createLink("TimeEntryReport.aspx", true);
            Response.Redirect(_url, false);
        }
    }
}