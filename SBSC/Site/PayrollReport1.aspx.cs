using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

/*
using NPOI.SS;            
using NPOI.SS.UserModel;
using NPOI.SS.Util;

using NPOI.HSSF;            
using NPOI.HSSF.UserModel;
using NPOI.HSSF.Util;

using NPOI.XSSF;
using NPOI.XSSF.UserModel;
using NPOI.XSSF.Util;

using NPOI.HPSF;           

using MBA.Reporting;
using MBA.IdentifyData;
*/
namespace Spedmon
{
    public partial class PayrollReport1 : WebUI
    {

        public abstract class PayrollPeriodTotalsRecord
        {
            public long EmployeeId; // { get; set; }
            public string Last_Name; // { get; set; }
            public string First_Name; // { get; set; }

            public string Company; // { get; set; }

            public System.Decimal TotalMinutes; // { get; set; }
            public System.Decimal PayRegular_Hours; // { get; set; }
            public System.Decimal Total_Hours_To_Pay; // { get; set; }
            public System.Decimal Paid_break; // { get; set; }
            public System.Decimal UnPaid_TimeOff; // { get; set; }
            public System.Decimal PaySick_Hours; // { get; set; }
            public System.Decimal PayVacation; // { get; set; }
            public System.Decimal PayHoliday_Hours; // { get; set; }
            public System.Decimal PayOver_Time; // { get; set; }
            public System.Decimal UnpaidOvertimeHours; // { get; set; }
            public System.Decimal MissingHours; // { get; set; }
            public System.Decimal PayDouble_Time; // { get; set; }
                                           //public List<TasksInformationDay> Tasks { get; set; }

            
            public DateTime Period_Start; // { get; set; }
            public DateTime Period_End; // { get; set; }

            public bool IsCompanySubTotal;

            public System.Decimal Dollar_Adjustments;
            public string Dollar_Adjustments_Notes;

            //public string Verified_On;
            //public int Verification_Counts;
            //public bool IsDelinquentDTKUser;

        }

        public class PayrollPeriodDetailedTotalsRecord : PayrollPeriodTotalsRecord
        {

            public DateTime Date; // { get; set; }
            public string Task;
            public string Client;
            public System.Decimal Hours_reported;
            public string Notes;
            public DateTime startTime;
            public DateTime endTime;

        }

        public class InvoiceReportRecord
        {

            public DateTime First_check; // { get; set; }
            public DateTime Date_Collected; // { get; set; }
            public long INVOICE_NUMBER;
            public string NEW_CLIENT_MARKER;
            public string Client;
            public System.Decimal SpEdCare_Share;

        }

        /*public class PayrollPeriodTotalsRecordWDynCols : PayrollPeriodTotalsRecord
        {
            public int c3, c2, c1;
            public static string 
        }*/

        //private List<PayrollPeriodTotalsRecord> _ListOfTotals;

        private List<PayrollPeriodDetailedTotalsRecord> _ListOfTotals2;
        private List<PayrollPeriodDetailedTotalsRecord> _ListOfTotals3;

        private List<InvoiceReportRecord> _ListOfTotals4;

        private MBA.ReturnDB r_db_1;
        private MBA.ReturnDataTable r_dt_1;

        private MBA.ReturnDB r_db_2;
        private MBA.ReturnDB r_db_3;

        private MBA.ReturnDB r_db_4;

        public class PayrollReportEntities : MBA.Entities
        {

            public static MBA.ReturnSaveRecord saveAdjReason(MBA.DetailsLog log, MBA.UserInfo uInfo, string dropdown_eid,
               string start_date,
               string d_amount,
               string adj_reason
            )
            {
                List<SqlParameter> parms = new List<SqlParameter>();
                Object v_eid = MBA.Validate.reqInteger(dropdown_eid, "invalid ID", false);
                Object v_startdate = MBA.Validate.reqDate(start_date, "invalid start");

                if (d_amount == "")
                  d_amount = "0";

                Object v_amount = MBA.Validate.reqUsdAmount(d_amount, "invalid amount");

                parms.Add(MBA.Database.SqlParm("@startdate", SqlDbType.Date, v_startdate, ParameterDirection.Input));
                parms.Add(MBA.Database.SqlParm("@amount", SqlDbType.Decimal, v_amount, ParameterDirection.Input));
                parms.Add(MBA.Database.SqlParm("@notes_reason", SqlDbType.VarChar, adj_reason, ParameterDirection.Input,8000));

                using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                {
                    if (_con.State == ConnectionState.Closed) //https://stackoverflow.com/a/6943970
                        _con.Open();
                    return recordOp(_con, log, uInfo, "","0", dropdown_eid, "[dbo].[TimeKeeper_PayrollAdj_SAVE]", ref parms);
                }
                
            }

            internal static void GetPayrollTotalsReportInfo(MBA.DetailsLog log, MBA.UserInfo uInfo, string company,
                                       string dropdown_eid, string start_date, string end_date, ref MBA.ReturnDB r_db_1, ref MBA.ReturnDataTable r_dt_1)
            {
                //_ListOfTasks.Clear();

                //r_dt_1 = null;

                using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                {


                    string _sqlStatement = @"[dbo].[TimeKeeper_EMPLOYEE_PAYROLL_SUBTOTALS_AND_ADJUSTMENTS]( @startDate, @endDate )";

                    if (dropdown_eid != "0")
                    {
                        _sqlStatement += @"
                    where
                        EmployeeId = @Id";
                        if (!(MBA.Util.IsNullOrEmpty(company)) && company != "All Companies")
                            _sqlStatement += @"
                    AND
                        Company = @company";
                    }
                    else {
                        if (!(MBA.Util.IsNullOrEmpty(company)) && company != "All Companies")
                            _sqlStatement += @"
                    WHERE
                        Company = @company";
                    }


                    _sqlStatement +=
                        @"
                    ORDER BY
                         Company,
                         Last_Name,
                         First_Name,
                         EmployeeId
                ";

                    List<SqlParameter> parms = new List<SqlParameter>();

                    Object v_eid = MBA.Validate.optInteger(dropdown_eid, "invalid ID", true);
                    Object v_startdate = MBA.Validate.optDate(start_date, "invalid start");
                    Object v_enddate = MBA.Validate.optDate(end_date, "invalid start");

                    Object v_company = MBA.Validate.optString(company, "invalid company");

                    parms.Add(MBA.Database.SqlParm("@Id", SqlDbType.BigInt, v_eid, ParameterDirection.Input, 100));
                    parms.Add(MBA.Database.SqlParm("@startDate", SqlDbType.Date, v_startdate, ParameterDirection.Input, 100));
                    parms.Add(MBA.Database.SqlParm("@endDate", SqlDbType.Date, v_enddate, ParameterDirection.Input, 100));

                    parms.Add(MBA.Database.SqlParm("@company", SqlDbType.VarChar, v_company, ParameterDirection.Input, 100));

                    MBA.defineCols dc = delegate (ref MBA.SQLStatement ss, ref string pageroworder, ref List<SqlParameter> ppp)
                    {
                        pageroworder = "Company";
                    };


                    _con.Open();

                    r_db_1 = MBA.Entities.view(_con, log, uInfo, MBA.Entities.REC_VIEW_ALL, false, "", "", "", _sqlStatement, ref parms, null, dc);

                    r_dt_1 = MBA.Database.convertReturnDBToReturnDataTable(ref r_db_1);

                    //r_db_1.records =  rdt1.aaData;

                    /*
                    object[] arr = MBA.Database.convertRecords(
                        r_db_1.records,
                        typeof(PayrollPeriodTotalsRecord)
                    );
                   
                    foreach (object a in arr)
                    {
                        _ListOfTasks.Add((PayrollPeriodTotalsRecord)a);
                    }
                    */

                }
            }

            internal static void GetPayrollDetailsReportInfo(MBA.DetailsLog log, MBA.UserInfo uInfo, string company,
                                       string dropdown_eid, string start_date, string end_date, ref List<PayrollPeriodDetailedTotalsRecord> _ListOfTotals3, ref MBA.ReturnDB r_db_3)
            {
                //_ListOfTasks.Clear();

                using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                {


                    string _sqlStatement = @"[dbo].[TimeKeeper_EMPLOYEE_DETAIL_PORTED]( " + (dropdown_eid != "0" ? "@Id" : "null" ) + " , @startDate, @endDate )";

                    _sqlStatement += @"ORDER BY Last_Name, First_Name, Date ASC";

                    List<SqlParameter> parms = new List<SqlParameter>();

                    Object v_eid = MBA.Validate.optInteger(dropdown_eid, "invalid ID", true);
                    Object v_startdate = MBA.Validate.optDate(start_date, "invalid start");
                    Object v_enddate = MBA.Validate.optDate(end_date, "invalid start");

                    Object v_company = MBA.Validate.optString(company, "invalid company");

                    parms.Add(MBA.Database.SqlParm("@Id", SqlDbType.BigInt, v_eid, ParameterDirection.Input, 100));
                    parms.Add(MBA.Database.SqlParm("@startDate", SqlDbType.Date, v_startdate, ParameterDirection.Input, 100));
                    parms.Add(MBA.Database.SqlParm("@endDate", SqlDbType.Date, v_enddate, ParameterDirection.Input, 100));

                    parms.Add(MBA.Database.SqlParm("@company", SqlDbType.VarChar, v_company, ParameterDirection.Input, 100));

                    MBA.defineCols dc = delegate (ref MBA.SQLStatement ss, ref string pageroworder, ref List<SqlParameter> ppp)
                    {
                        pageroworder = "Last_Name, First_Name, Date ASC";
                    };

                    /* if (_dataTable.Rows.Count == 0)
                    {
                        labelReportContent.Text = "No data for that employee";
                        return;
                    }*/

                    _con.Open();
                    r_db_3 = MBA.Entities.view(_con, log, uInfo, MBA.Entities.REC_VIEW_ALL, false, "", "", "", _sqlStatement, ref parms, null, dc);
                    //r_db_3 = MBA.Entities.loadAllRecords(_con, log, uInfo, MBA.Entities.REC_VIEW_ALL, false, "1", "", "", _sqlStatement, ref parms, null, dc);
                    //r_db_3 = MBA.Entities.view(_con, log, uInfo, MBA.Entities.REC_VIEW_OBJECTS, true, "1", "", "", _sqlStatement, ref parms, null, dc);

                    object[] arr = MBA.Database.convertRecords(
                        r_db_3.records,
                        typeof(PayrollPeriodDetailedTotalsRecord)
                    );

                    foreach (object a in arr)
                    {
                        _ListOfTotals3.Add((PayrollPeriodDetailedTotalsRecord)a);
                    }

                }
            }


            internal static void GetPayrollDailyReportInfo(MBA.DetailsLog log, MBA.UserInfo uInfo, string company,
                                       string dropdown_eid, string start_date, string end_date, ref List<PayrollPeriodDetailedTotalsRecord> _ListOfTotals2, ref MBA.ReturnDB r_db_2)
            {
                //_ListOfTasks.Clear();

                using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                {


                    string _sqlStatement = @"[dbo].[TimeKeeper_EMPLOYEE_PAYROLL_BY_DAY]( " + (dropdown_eid != "0" ? "@Id" : "null" ) + " , @startDate, @endDate )";

                    List<SqlParameter> parms = new List<SqlParameter>();

                    if (!(MBA.Util.IsNullOrEmpty(company)) && company != "All Companies")
                        _sqlStatement += @"
                    WHERE
                        Company = @company";

                    _sqlStatement += @"ORDER BY Company, Last_Name, First_Name, Date ASC"; 

                    Object v_eid = MBA.Validate.optInteger(dropdown_eid, "invalid ID", true);
                    Object v_startdate = MBA.Validate.optDate(start_date, "invalid start");
                    Object v_enddate = MBA.Validate.optDate(end_date, "invalid start");

                    Object v_company = MBA.Validate.optString(company, "invalid company");

                    parms.Add(MBA.Database.SqlParm("@Id", SqlDbType.BigInt, v_eid, ParameterDirection.Input, 100));
                    parms.Add(MBA.Database.SqlParm("@startDate", SqlDbType.Date, v_startdate, ParameterDirection.Input, 100));
                    parms.Add(MBA.Database.SqlParm("@endDate", SqlDbType.Date, v_enddate, ParameterDirection.Input, 100));

                    parms.Add(MBA.Database.SqlParm("@company", SqlDbType.VarChar, v_company, ParameterDirection.Input, 100));

                    MBA.defineCols dc = delegate (ref MBA.SQLStatement ss, ref string pageroworder, ref List<SqlParameter> ppp)
                    {
                        pageroworder = "Company, Last_Name, First_Name, Date ASC";
                    };

                    /* if (_dataTable.Rows.Count == 0)
                    {
                        labelReportContent.Text = "No data for that employee";
                        return;
                    }*/

                    _con.Open();
                    r_db_2 = MBA.Entities.view(_con, log, uInfo, MBA.Entities.REC_VIEW_ALL, false, "", "", "", _sqlStatement, ref parms, null, dc);

                    object[] arr = MBA.Database.convertRecords(
                        r_db_2.records,
                        typeof(PayrollPeriodDetailedTotalsRecord)
                    );

                    foreach (object a in arr)
                    {
                        ((PayrollPeriodDetailedTotalsRecord)a).PayRegular_Hours -= ((PayrollPeriodDetailedTotalsRecord)a).Paid_break;
                        _ListOfTotals2.Add((PayrollPeriodDetailedTotalsRecord)a);

                    }

                }

            }

            internal static void GetInvoicesReportInfo(MBA.DetailsLog log, MBA.UserInfo uInfo, ref List<InvoiceReportRecord> _ListOfTotals4, ref MBA.ReturnDB r_db_4)
            {
                //_ListOfTasks.Clear();

                using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                {


                    string _sqlStatement = @"[dbo].[InvoicesLastMonth]()";

                    List<SqlParameter> parms = new List<SqlParameter>();

                    

                    MBA.defineCols dc = delegate (ref MBA.SQLStatement ss, ref string pageroworder, ref List<SqlParameter> ppp)
                    {
                        pageroworder = "Client";
                    };

                    /* if (_dataTable.Rows.Count == 0)
                    {
                        labelReportContent.Text = "No data for that employee";
                        return;
                    }*/

                    _con.Open();
                    r_db_4 = MBA.Entities.view(_con, log, uInfo, MBA.Entities.REC_VIEW_ALL, false, "", "", "", _sqlStatement, ref parms, null, dc);

                    object[] arr = MBA.Database.convertRecords(
                        r_db_4.records,
                        typeof(InvoiceReportRecord)
                    );

                    foreach (object a in arr)
                    {
                        _ListOfTotals4.Add((InvoiceReportRecord)a);

                    }

                }

            }

        }

        public PayrollReport1()
             : base("reports", WebUI.CreatePageSubTitle("Payroll Report", "Get payroll report"),
                  "PayrollReport1.aspx.css", "PayrollReport1.aspx.js", Constants.ROLE_SBS_ALL)
        {
            //_ListOfTotals = new List<PayrollPeriodTotalsRecord>();

            _ListOfTotals2 = new List<PayrollPeriodDetailedTotalsRecord>();
            _ListOfTotals3 = new List<PayrollPeriodDetailedTotalsRecord>();

            _ListOfTotals4 = new List<InvoiceReportRecord>();
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            //SummaryTab.Attributes.Add("class", "nav-link");
            //ByDateTab.Attributes.Add("class", "nav-link");
            //ByTaskTab.Attributes.Add("class", "nav-link");
            //InvoicesTab.Attributes.Add("class", "nav-link");

            DollarsAdjustmentWarning.Attributes.Add("style", "display:none;");

            if (!IsPostBack)
            {
                DateTime _currentDate = DateTime.Now;
                DateTime _startDate;// = DateTime.MinValue;
                DateTime _endDate;// = DateTime.MinValue;

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
                PayrollReportEntities.GetPayrollTotalsReportInfo(log, uInfo, DropDownListCompanies.SelectedItem.Value,
                                       DropDownListEmployees.SelectedItem.Value, tbStartDate.Text, tbEndDate.Text, ref r_db_1, ref r_dt_1 );
                BuildSummarizedPayrollReport();
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



        private void BuildSummarizedPayrollReport()
        {
            SummaryTab.Attributes.Add("class", "nav-link active");
            ByDateTab.Attributes.Add("class", "nav-link");
            ByTaskTab.Attributes.Add("class", "nav-link");
            InvoicesTab.Attributes.Add("class", "nav-link");

            labelReportContent.Text = @"
            <table>
                <thead><tr class='tr-thead tr-thead-summary'>
                    <th rowspan='2' style='padding: 0 1.25em'><strong style='font-weight: bold'>Company</strong></th>
                    <th rowspan='2' style='padding: 0 1.25em'><strong style='font-weight: bold'>Last Name</strong></th>
                    <th rowspan='2' style='padding: 0 1.25em'><strong style='font-weight: bold'>First Name</strong></th>
                    <th rowspan='2' style='padding: 0 1.25em;text-align:center'><strong style='font-weight: bold'>Regular<br/>Hours</strong></th>
                    <th rowspan='2' style='padding: 0 1.25em;text-align:center'><strong style='font-weight: bold'>Sick<br/>Hours</strong></th>
                    <th rowspan='2' style='padding: 0 1.25em;text-align:center'><strong style='font-weight: bold'>Vacation<br/>Hours</strong></th>
                    <th rowspan='2' style='padding: 0 1.25em;text-align:center'><strong style='font-weight: bold'>Holiday<br/>Hours</strong></th>
                    <th rowspan='2' style='padding: 0 1.25em;text-align:center'><strong style='font-weight: bold'>Overtime Hours</strong></th>
                    <th rowspan='2' style='padding: 0 1.25em;text-align:center'><strong style='font-weight: bold'>Double Overtime</strong></th>
                    <th rowspan='2' style='padding: 0 1.25em; border-left: 1px black solid; border-right: 1px black solid'><strong style='font-weight: bold'>Total Hours<br/>To Pay</strong></th>

                    <th rowspan='2' style='padding: 0 1.25em;text-align:center'><strong style='font-weight: bold'>Dollar Amount Adjustment</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th rowspan='2' style='padding: 0 1.25em;text-align:center'><strong style='font-weight: bold'>Notes</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th rowspan='2' style='width:30px;'></th>
                    <th rowspan='2'></th>

                    <th style='padding: 0 1.25em;text-align:center' colspan='3'><strong style='font-weight: bold'>Verified</strong></th>

                </tr>
                <tr style='background-color:#9FC6CB;font-weight:bold; height: 4em'>

                  <th><div style='border:none;padding:0px 8px;'>" + ((Object[])(r_dt_1.aaData[0]))[23] + @"</div></th>
                  <th><div style='border:none;padding:0px 8px;'>" + ((Object[])(r_dt_1.aaData[0]))[25] + @"</div></th>
                  <th><div style='border:none;padding:0px 8px;'>" + ((Object[])(r_dt_1.aaData[0]))[27] + @"</div></th>

                </tr></thead>";

            bool flip_odd=true;
            foreach(Object[] _reportRow in r_dt_1.aaData)
            {
                var Last_Name = _reportRow[2]; var First_Name = _reportRow[3]; var EmployeeId = _reportRow[4]; var Company = _reportRow[5];
                var PayRegular_Hours = (System.Decimal)_reportRow[15]; var PaySick_Hours = (System.Decimal) _reportRow[16]; var PayVacation = (System.Decimal)_reportRow[17]; var PayHoliday_Hours = (System.Decimal)_reportRow[18];
                var PayOver_Time = (System.Decimal)_reportRow[19]; var PayDouble_Time = (System.Decimal)_reportRow[20]; var Total_Hours_To_Pay = (System.Decimal)_reportRow[21]; var IsCompanySubTotal = (bool) _reportRow[29];
                var Dollar_Adjustments = (System.Decimal) _reportRow[30]; var Dollar_Adjustments_Notes = (string) _reportRow[31];
                var verif_3 = (int)_reportRow[24]; var verif_2 = (int)_reportRow[26]; var verif_1 = (int)_reportRow[28];

                if ( Dollar_Adjustments != 0)
                {
                    DollarsAdjustmentWarning.Attributes.Remove("style");
                    DollarsAdjustmentWarning.Attributes.Add("style", "display:block;line-height:22px;font-size:21px;");
                }
                labelReportContent.Text += @"
                <tr class='" + (IsCompanySubTotal ? "tr-companytotal" : (flip_odd ? @"tr-odd" : @"tr-even")  ) + @" payroll-summarydetail-content' style='background-color:" + (IsCompanySubTotal ? "#9FC6CB" :  (flip_odd ? @"#f7f9f9" : @"white") )  + @";" +
                  ( IsCompanySubTotal ? "border-bottom:3px double black; border-top: 3px double black;" : "border-bottom: 2px ridge black;") +
                @"'>
                    <td " +
                  ( IsCompanySubTotal ? "style='font-weight:bold;font-size:12pt;line-height:13px;padding:8px 0'" : "") +
                @">" +  Company + @"</td>
                    <td><span class='btn-link' onclick=""SelectEmployee(" +  EmployeeId + @")"">" +  Last_Name + @"</span></td>
                    <td>" +  First_Name + @"</td>
                    <td style='text-align: right;padding: 0 1.25em;  border-left: 1px black solid; border-right: 1px black solid;" +
                  ( IsCompanySubTotal ? "font-weight:bold;" : "") +
                @"'>" + ( PayRegular_Hours != 0 ? $"{  PayRegular_Hours:n2}" : "" )+ @"</td>
                    <td style='text-align: right;padding: 0 1.25em;" +
                  ( IsCompanySubTotal ? "font-weight:bold;" : "border-right: 1px black solid;") +
                @"'>" + ( PaySick_Hours != 0 ? $"{  PaySick_Hours:n2}" : "") + @"</td> 
                    <td style='text-align: right;padding: 0 1.25em;" +
                  ( IsCompanySubTotal ? "font-weight:bold;" : "border-right: 1px black solid;") +
                @"'>" + ( PayVacation != 0 ? $"{  PayVacation:n2}" : "") +  @"</td> 
                    <td style='text-align: right;padding: 0 1.25em;" +
                  ( IsCompanySubTotal ? "font-weight:bold;" : "border-right: 1px black solid;") +
                @"'>" + ( PayHoliday_Hours != 0 ? $"{  PayHoliday_Hours:n2}" : "") + @"</td> 
                    <td style='text-align: right;padding: 0 1.25em;" +
                  ( IsCompanySubTotal ? "font-weight:bold;" : "border-right: 1px black solid;") +
                @"'>" + ( PayOver_Time != 0 ? $"{  PayOver_Time:n2}" : "") + @"</td> 
                    <td style='text-align: right; padding-right: 1em;" +
                  ( IsCompanySubTotal ? "font-weight:bold;" : "border-right: 1px black solid;") +
                @"'>" + ( PayDouble_Time != 0 ? $"{  PayDouble_Time:n2}" : "") + @"</td> 
                    <td style='text-align: right; border-left: 1px black solid; border-right: 1px black solid;" +
                  ( IsCompanySubTotal ? "font-weight:bold;" : "") +
                @"'>" + $"{ Total_Hours_To_Pay:n2}" + @"</td>

                " +

                (  IsCompanySubTotal ? "<td></td><td></td><td></td>" : 

                    @"<td style='text-align: right; padding-right: 1em;" +
                @"' " + ( Dollar_Adjustments != 0 ? @" class='alert-warning text-dark'" : "") +
                    @"><input type=""text""
                    id=""orange-dollarval-" +  EmployeeId.ToString() + @"""
                    onchange=""requiresSave(" +  EmployeeId.ToString() + @")"" value=""" + ( Dollar_Adjustments != 0 ? $"{  Dollar_Adjustments:n2}" : "") + @""" /></td>

                <td style='text-align: right; padding-right: 1em;'" +
                    @" class='notes-val-td payroll-summary-notes-val-td" + ( Dollar_Adjustments != 0 || !MBA.Util.IsNullOrEmpty( Dollar_Adjustments_Notes) ? @" alert-warning text-dark" : "") +
                    @"' ><textarea rows=""1"" onchange=""requiresSave(" +  EmployeeId.ToString() + @")""
                    id=""orange-text-" +  EmployeeId.ToString() + @""">" +  Dollar_Adjustments_Notes + @"</textarea></td>


                    <td " + ( Dollar_Adjustments != 0 ? @" class='alert-warning text-dark'" : "") +
                    @" style='width:30px;' id=""bg-btn-rowsave-" +  EmployeeId.ToString() + @""" ><button type=""button"" class=""btn btn-warning rowsave"" id=""btn-rowsave-" +  EmployeeId.ToString() + @""" onclick=""adjustmentSave(" +  EmployeeId.ToString() + @")"" ><i class='fa fa-save' style='font-size:14px'/></button></td>

                    <td style='border-left: 1px black solid;'>
                       <span onclick='clickToggleExpand(this)' class='toggle-click ui-spedmon-gradient-rounded-but-md'><i class='fas fa-angle-down'></i></span>
                    </td>

                    <td style='text-align: center'>" + (verif_3 == 1 ? @"<i class=""fa fa-check""></i>" : "") + @"</td>

                    <td style='text-align: center'>" + (verif_2 == 1 ? @"<i class=""fa fa-check""></i>" : "") + @"</td>

                    <td style='text-align: center'>" + (verif_1 == 1 ? @"<i class=""fa fa-check""></i>" : "") + @"</td>

                    </tr>"

                );
                flip_odd = !flip_odd;
            }

            labelReportContent.Text += @"
            </table>";
        }

        private void BuildPayrollDailyReport()
        {
            SummaryTab.Attributes.Add("class", "nav-link");
            ByDateTab.Attributes.Add("class", "nav-link active");
            ByTaskTab.Attributes.Add("class", "nav-link");
            InvoicesTab.Attributes.Add("class", "nav-link");

            labelReportContent.Text = @"
            <table>
                <thead><tr class='tr-thead'>
                    <th style='padding: 0 1.25em'><strong style='font-weight: bold'>Company</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th style='padding: 0 1.25em'><strong style='font-weight: bold'>Date</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th style='padding: 0 1.25em'><strong style='font-weight: bold'>Last Name</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th style='padding: 0 1.25em'><strong style='font-weight: bold'>First Name</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th style='padding: 0 1.25em; width:3.5em;text-align:center'><strong style='font-weight: bold'>Regular<br/>Hours</strong></th>
                    <th style='padding: 0 1.25em; width:3.5em;text-align:center'><strong style='font-weight: bold'>Regular<br/>Paid Break</strong></th>
                    <th style='padding: 0 1.25em; width:3.5em;text-align:center'><strong style='font-weight: bold'>Regular<br/>Unpaid Break</strong></th>
                    <th style='padding: 0 1.25em; width:3.5em;text-align:center'><strong style='font-weight: bold'>Sick<br/>Hours</strong></th>
                    <th style='padding: 0 1.25em; width:3.5em;text-align:center'><strong style='font-weight: bold'>Vacation<br/>Hours</strong></th>
                    <th style='padding: 0 1.25em; width:3.5em;text-align:center'><strong style='font-weight: bold'>Holiday<br/>Hours</strong></th>
                    <th style='padding: 0 1.25em; width:3.5em;text-align:center'><strong style='font-weight: bold'>Overtime Hours</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th style='padding: 0 1.25em; width:3.5em;text-align:center'><strong style='font-weight: bold'>Double Overtime</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th style='padding: 0 1.25em; width:3.5em; border-left: 1px black solid; border-right: 1px black solid'><strong style='font-weight: bold'>Total Hours&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<br/>To Pay</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                </tr></thead>";

            bool flip_odd = true; PayrollPeriodDetailedTotalsRecord prev = null;
            foreach (PayrollPeriodDetailedTotalsRecord _reportRow in _ListOfTotals2)
            {

                labelReportContent.Text += @"
                <tr style='background-color:" + (flip_odd ? @"#f7f9f9" : @"white") + @";border-bottom: 2px ridge black;" + (prev != null && prev.Company != _reportRow.Company ? "border-top: 4px solid black;" : "") + @"'>
                    <td>" + _reportRow.Company + @"</td>
                    <td><span class='btn-link' onclick=""SelectDaterange('" + _reportRow.Date.ToString("MM/dd/yyyy") + @"')"">" + _reportRow.Date.ToString("MM/dd/yyyy") + @"</span></td>
                    <td>" + _reportRow.Last_Name + @"</td>
                    <td style='border-right: 1px black solid'>" + _reportRow.First_Name + @"</td>
                    <td style='text-align: right;padding: 0 1.25em; border-right: 1px black solid'>" + (_reportRow.PayRegular_Hours != 0 ? $"{_reportRow.PayRegular_Hours:n2}" : "" ) + @"</td>
                    <td style='text-align: right;padding: 0 1.25em; border-right: 1px black solid'>" + (_reportRow.Paid_break != 0 ? $"{_reportRow.Paid_break:n2}" : "") + @"</td>
                    <td style='text-align: right;padding: 0 1.25em; border-right: 1px black solid'>" + (_reportRow.UnPaid_TimeOff != 0 ? $"{_reportRow.UnPaid_TimeOff:n2}" : "") + @"</td>
                    <td style='text-align: right;padding: 0 1.25em; border-right: 1px black solid'>" + (_reportRow.PaySick_Hours != 0 ? $"{_reportRow.PaySick_Hours:n2}" : "") + @"</td> 
                    <td style='text-align: right;padding: 0 1.25em; border-right: 1px black solid'>" + (_reportRow.PayVacation != 0 ? $"{_reportRow.PayVacation:n2}" : "") + @"</td> 
                    <td style='text-align: right;padding: 0 1.25em; border-right: 1px black solid'>" + (_reportRow.PayHoliday_Hours != 0 ? $"{_reportRow.PayHoliday_Hours:n2}" : "") + @"</td> 
                    <td style='text-align: right;padding: 0 1.25em; border-right: 1px black solid'>" + (_reportRow.PayOver_Time != 0 ? $"{_reportRow.PayOver_Time:n2}" : "") + @"</td> 
                    <td style='text-align: right; padding-right: 1em'>" + (_reportRow.PayDouble_Time != 0 ? $"{_reportRow.PayDouble_Time:n2}" : "") + @"</td>
                    " + "<td style='text-align: right; border-left: 1px black solid; border-right: 1px black solid'>" + $"{_reportRow.Total_Hours_To_Pay:n2}" + @"</td>
                     

                </tr>";
                flip_odd = !flip_odd;
                prev = _reportRow;
            }

            labelReportContent.Text += @"
            </table>";
        }

        private void BuildPayrollDetailedReport()
        {
            SummaryTab.Attributes.Add("class", "nav-link");
            ByDateTab.Attributes.Add("class", "nav-link");
            ByTaskTab.Attributes.Add("class", "nav-link active");
            InvoicesTab.Attributes.Add("class", "nav-link");

            labelReportContent.Text = @"
            <table>
                <thead><tr class='tr-thead'>
                    <th style='padding: 0 1.25em; text-align:center; '><strong style='font-weight: bold'>Date</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th style='padding: 0 1.25em; text-align:center; width:6.5em'><strong style='font-weight: bold'>Last Name</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th style='padding: 0 1.25em; text-align:center; width:6.5em'><strong style='font-weight: bold'>First Name</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>

                    <th style='padding: 0 1.25em; width:3.5em'><strong style='font-weight: bold'>Hours Reported</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>

                    <th style='padding: 0 1.25em;text-align:center; width:20em'><strong style='font-weight: bold'>Task</strong></th>
                    <th style='padding: 0 1.25em;text-align:center; width:3.5em'><strong style='font-weight: bold'>Start Time</strong></th>
                    <th style='padding: 0 1.25em;text-align:center; width:3.5em; border-right: 1px black solid'><strong style='font-weight: bold'>End Time</strong></th>
                    <th style='padding: 0 1.25em;text-align:center; border-left: 1px black solid; border-right: 1px black solid'><strong style='font-weight: bold'>Notes</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th></th>
                </tr></thead>";

            bool flip_odd = true;
            foreach (PayrollPeriodDetailedTotalsRecord _reportRow in _ListOfTotals3)
            {

                labelReportContent.Text += @"
                <tr style='background-color:" + (flip_odd ? @"#f7f9f9" : @"white") + @";border-bottom: 2px ridge black;'>
                    <td>" + _reportRow.Date.ToString("MM/dd/yyyy") + @"</td>
                    <td>" + _reportRow.Last_Name + @"</td>
                    <td style='border-right: 1px black solid'>" + _reportRow.First_Name + @"</td>

                    <td style='text-align: right;padding: 0 1.25em; border-right: 1px black solid'>" + $"{_reportRow.Hours_reported:n2}" + @"</td>

                    <td class='task-namestr-td recorded-tasks-task-namestr-td' style='text-align: right;padding: 0 1.25em'>" + _reportRow.Task + @"</td>
                    <td style='text-align: right;padding: 0 1.25em; border-left: 1px black solid; border-right: 1px black solid'>" + _reportRow.startTime.ToString("hh:mm tt") + @"</td>
                    <td style='text-align: right;padding: 0 1.25em; border-right: 1px black solid'>" + _reportRow.endTime.ToString("hh:mm tt") + @"</td>

                    " + "<td class='notes-val-td recorded-tasks-notes-val-td' style='text-align: right'>" + (  _reportRow.Notes ) + @"</td>

                    <td style='border-left: 1px black solid;'>
                       <span onclick='clickToggleExpand(this)' class='toggle-click ui-spedmon-gradient-rounded-but-md'><i class='fas fa-angle-down'></i></span>
                    </td>
                     

                </tr>";
                flip_odd = !flip_odd;
            }

            labelReportContent.Text += @"
            </table>";
        }

        private void BuildInvoicesReport()
        {
            SummaryTab.Attributes.Add("class", "nav-link");
            ByDateTab.Attributes.Add("class", "nav-link");
            ByTaskTab.Attributes.Add("class", "nav-link");
            InvoicesTab.Attributes.Add("class", "nav-link active");

            labelReportContent.Text = @"
            <table>
                <thead><tr class='tr-thead'>
                    <th style='padding: 0 1.25em'><strong style='font-weight: bold'>Client</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th style='padding: 0 1.25em'><strong style='font-weight: bold'>Invoice Number</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th style='padding: 0 1.25em'><strong style='font-weight: bold'>Date Collected</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th style='padding: 0 1.25em'><strong style='font-weight: bold'>SpEdCare Share</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th style='padding: 0 1.25em'><strong style='font-weight: bold'>First_check</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th style='padding: 0 1.25em'><strong style='font-weight: bold'>New Client ?</strong>&nbsp;&nbsp;&nbsp;&nbsp;</th>
                </tr></thead>";

            bool flip_odd = true;
            foreach (InvoiceReportRecord _reportRow in _ListOfTotals4)
            {

                labelReportContent.Text += @"
                <tr style='background-color:" + (flip_odd ? @"#f7f9f9" : @"white") + @";border-bottom: 2px ridge black;'>
                    <td>" + _reportRow.Client + @"</td>
                    <td>" + _reportRow.INVOICE_NUMBER + @"</td>
                    <td><span class='btn-link'>" + _reportRow.Date_Collected.ToString("MM/dd/yyyy") + @"</span></td>
                    <td style='text-align: right;padding: 0 1.25em'>" + $"{_reportRow.SpEdCare_Share:n2}" + @"</td>
                    <td><span class='btn-link'>" + _reportRow.First_check.ToString("MM/dd/yyyy") + @"</span></td>
                    <td>" + _reportRow.NEW_CLIENT_MARKER + @"</td>

                </tr>";
                flip_odd = !flip_odd;
            }

            labelReportContent.Text += @"
            </table>";
        }

        protected void ButtonUpdateDateRange_Click(object sender, EventArgs e)
        {
            PayrollReportEntities.GetPayrollTotalsReportInfo(log, uInfo, DropDownListCompanies.SelectedItem.Value,
                                       DropDownListEmployees.SelectedItem.Value, tbStartDate.Text, tbEndDate.Text, ref r_db_1, ref r_dt_1);
            BuildSummarizedPayrollReport();
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


        
        class PayroleRptFileGen : MBA.WebReportDocument
        {
            //public MBA.ReturnDataTable rptData2;
            public PayroleRptFileGen(MBA.ReturnDataTable rptData, /* MBA.ReturnDataTable rptData2, */ int rptForm) : base(rptData, rptForm) {
                //this.rptData2 = rptData2;
            }
           
        }


        protected void ButtonExport_Click(object sender, EventArgs e)
        {
         
            PayrollReportEntities.GetPayrollTotalsReportInfo(log, uInfo, DropDownListCompanies.SelectedItem.Value,
                                       DropDownListEmployees.SelectedItem.Value, tbStartDate.Text, tbEndDate.Text, ref r_db_1, ref r_dt_1);
            
            //MBA.ReturnDataTable r_dt_1 = MBA.Database.convertReturnDBToReturnDataTable(ref r_db_1);
            r_dt_1.tableName = "Payroll";
            r_dt_1.tableFooter = MBA.Messages.DATA_VIEW_NO_FOOTER;

            
            r_dt_1.useTemplates = true;
            r_dt_1.excelTemplate = new MBA.ExcelFileTempateInfo();

            r_dt_1.excelTemplate.templateFileName = @"PayrollSummary.xls";

            //r_dt_1.excelTemplate.postPopulationProcessing = true;
            r_dt_1.excelTemplate.forceFormulaRecalculate = true;
            r_dt_1.excelTemplate.collapseRowGroups = false;
            r_dt_1.excelTemplate.collapseColGroups = false;
            r_dt_1.excelTemplate.limitToPhysicalCells = false;
            r_dt_1.excelTemplate.sheetNum = 0;

            r_dt_1.excelTemplate.setDataCellRegion(2 
                                              , 199  
                                              , @"A"   
                                              , @"AE"); 


            PayroleRptFileGen fg = new PayroleRptFileGen(r_dt_1, MBA.Constants.REPT_FORMAT_XLS);

            fg.ProcessRequest(HttpContext.Current);


        }

        protected void DropDownListEmployees_SelectedIndexChanged(object sender, EventArgs e)  
        {

        }

        protected void DropDownListCompanies_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        protected void SummaryTab_Click(object sender, EventArgs e)
        {
            PayrollReportEntities.GetPayrollTotalsReportInfo(log, uInfo, DropDownListCompanies.SelectedItem.Value,
                                   DropDownListEmployees.SelectedItem.Value, tbStartDate.Text, tbEndDate.Text, ref r_db_1, ref r_dt_1);
            BuildSummarizedPayrollReport();
        }

        protected void ByDateTab_Click(object sender, EventArgs e)
        {
            PayrollReportEntities.GetPayrollDailyReportInfo(log, uInfo, DropDownListCompanies.SelectedItem.Value,
                                       DropDownListEmployees.SelectedItem.Value, tbStartDate.Text, tbEndDate.Text, ref _ListOfTotals2, ref r_db_2); ;
            BuildPayrollDailyReport();
        }

        protected void ByTaskTab_Click(object sender, EventArgs e)
        {
            PayrollReportEntities.GetPayrollDetailsReportInfo(log, uInfo, DropDownListCompanies.SelectedItem.Value,
                                       DropDownListEmployees.SelectedItem.Value, tbStartDate.Text, tbEndDate.Text, ref _ListOfTotals3, ref r_db_3); ;
            BuildPayrollDetailedReport();
        }

        protected void InvoicesTab_Click(object sender, EventArgs e)
        {
            PayrollReportEntities.GetInvoicesReportInfo(log, uInfo, ref _ListOfTotals4, ref r_db_4); ;
            BuildInvoicesReport();
        }

    }
}