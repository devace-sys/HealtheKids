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
    public partial class TimeEntryHolidayAdmin : WebUI
    {
        public TimeEntryHolidayAdmin()
             : base("timeentryholidayadmin", WebUI.CreatePageSubTitle("Holiday Admin", "Create, update, or delete holidays"), "", "", Constants.ROLE_SBS_ALL)
        {
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (rd.wu.usr.timeSheetUserInfo == null)
            {
                rd.wu.usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(rd.wu.usr.userName);
            }

            if (rd.wu.usr.timeSheetUserInfo.roleID != 1)
            {
                string _url = MBA.HttpApplication.createLink("home.aspx", true);
                Response.Redirect(_url, true);
                return;
            }
            datepicker.TodaysDate = DateTime.Today;
            if (!IsPostBack)
            {
                datepicker.SelectedDate = DateTime.Today;
                tbSelectedDate.Text = datepicker.SelectedDate.ToString("MM/dd/yyyy");
                PopulateGrid();
            }
        }

        private void PopulateGrid()
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                con.Open();
                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetHolidays", con);
                _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;

                DataTable _dataTable = new DataTable();
                _sqlDataAdapter.Fill(_dataTable);

                repeaterHolidays.DataSource = _dataTable;
                repeaterHolidays.DataBind();
            }
            Calendar CalendarRepeaterPicker = null;
            foreach (RepeaterItem rptItem in repeaterHolidays.Items)
            {
                CalendarRepeaterPicker = (Calendar)rptItem.FindControl("CalendarRepeaterPicker");
                CalendarRepeaterPicker.TodaysDate = DateTime.Today;
            }
        }
        protected void datepicker_SelectionChanged(object sender, EventArgs e)
        {
            tbSelectedDate.Text = datepicker.SelectedDate.ToString("MM/dd/yyyy");
            datepicker.Visible = false;
            HiddenFieldDateTimeEntry.Value = tbSelectedDate.Text;
        }
        protected void lnkpickdate_Click(object sender, EventArgs e)
        {
            datepicker.Visible = true;
        }

        protected void ButtonCreateNew_Click(object sender, EventArgs e)
        {
            PanelCreateEntry.Visible = true;
            PanelViewModifyDeleteCurrent.Visible = false;
        }

        protected void ButtonCancel_Click(object sender, EventArgs e)
        {
            PanelCreateEntry.Visible = false;
            PanelViewModifyDeleteCurrent.Visible = true;
        }

        protected void ButtonSaveHoliday_Click(object sender, EventArgs e)
        {
            string _confirmUpdate = Request.Form["confirm_update"];
            if (_confirmUpdate != "Yes")
            {
                return;
            }
            using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                con.Open();
                SqlCommand cmd = new SqlCommand("TimeKeeper_TIMESHEET_CreateHolidayEntry", con);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@Name", TextBoxNameOfHoliday.Text);

                if (string.IsNullOrEmpty(TextBoxDescrption.Text.Trim()))
                {
                    cmd.Parameters.AddWithValue("@Description", DBNull.Value);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@Description", TextBoxDescrption.Text);
                }

                cmd.Parameters.AddWithValue("@DateOfHoliday",tbSelectedDate.Text);

                cmd.Parameters.Add("@Id", SqlDbType.BigInt);
                cmd.Parameters["@Id"].Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();
            }
            PopulateGrid();
            Response.Redirect(Request.RawUrl);
        }

        protected void ButtonDelete_Click(object sender, EventArgs e)
        {
            string _confirmUpdate = Request.Form["confirm_update"];
            if (_confirmUpdate != "Yes")
            {
                return;
            }
            using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                //Reference the Repeater Item using Button.
                RepeaterItem item = ((sender as Button).NamingContainer as RepeaterItem);
                HiddenField HiddenFieldId = item.FindControl("HiddenFieldId") as HiddenField;

                con.Open();

                SqlCommand cmd = new SqlCommand("TimeKeeper_TIMESHEET_DeleteHolidays", con);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@ID", HiddenFieldId.Value);

                cmd.ExecuteNonQuery();
            }
            PopulateGrid();
            PanelCreateEntry.Visible = false;
            PanelViewModifyDeleteCurrent.Visible = true;
        }

        protected void CalendarRepeaterPicker_SelectionChanged(object sender, EventArgs e)
        {
            RepeaterItem item = ((sender as Calendar).NamingContainer as RepeaterItem);
            Label LabelDateOfHoliday = item.FindControl("LabelDateOfHoliday") as Label;
            Calendar CalendarRepeaterPicker = item.FindControl("CalendarRepeaterPicker") as Calendar;
            LabelDateOfHoliday.Text = CalendarRepeaterPicker.SelectedDate.ToString("MM/dd/yyyy");
            CalendarRepeaterPicker.Visible = false;
        }

        protected void lnkPickDateRepeater_Click(object sender, EventArgs e)
        {
            RepeaterItem item = ((sender as ImageButton).NamingContainer as RepeaterItem);
            Calendar CalendarRepeaterPicker = item.FindControl("CalendarRepeaterPicker") as Calendar;
            CalendarRepeaterPicker.Visible = true;

        }

        protected void ButtonUpdateGridInfo_Click(object sender, EventArgs e)
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                con.Open();
                Label LabelDateOfHoliday = null;
                HiddenField HiddenFieldDateOfHoliday = null;
                HiddenField HiddenFieldId = null;
                TextBox TextBoxRepeaterHolidayName = null;
                HiddenField HiddenFieldHolidayName = null;
                TextBox TextBoxDescription = null;
                HiddenField HiddenFieldDescription = null;

                foreach (RepeaterItem rptItem in repeaterHolidays.Items)
                {
                    LabelDateOfHoliday = (Label)rptItem.FindControl("LabelDateOfHoliday");
                    HiddenFieldDateOfHoliday = (HiddenField)rptItem.FindControl("HiddenFieldDateOfHoliday");
                    HiddenFieldId = (HiddenField)rptItem.FindControl("HiddenFieldId");
                    TextBoxRepeaterHolidayName = (TextBox)rptItem.FindControl("TextBoxRepeaterHolidayName");
                    HiddenFieldHolidayName = (HiddenField)rptItem.FindControl("HiddenFieldHolidayName");
                    TextBoxDescription = (TextBox)rptItem.FindControl("TextBoxDescription");
                    HiddenFieldDescription = (HiddenField)rptItem.FindControl("HiddenFieldDescription");
                    if ((LabelDateOfHoliday.Text != HiddenFieldDateOfHoliday.Value)
                        || (TextBoxRepeaterHolidayName.Text != HiddenFieldHolidayName.Value)
                        || (TextBoxDescription.Text != HiddenFieldDescription.Value))
                    {
                        UpdateHoliday(con, HiddenFieldId.Value, LabelDateOfHoliday.Text, TextBoxRepeaterHolidayName.Text, TextBoxDescription.Text);
                    }
                }
            }
            PopulateGrid();
            PanelCreateEntry.Visible = false;
            PanelViewModifyDeleteCurrent.Visible = true;
        }

        private void UpdateHoliday(SqlConnection con, string id, string dateOfHoliday, string holidayName, string holidayDescrption)
        {
            SqlCommand cmd = new SqlCommand("TimeKeeper_TIMESHEET_UpdateHoliday", con);
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.AddWithValue("@ID", id);
            cmd.Parameters.AddWithValue("@Name", holidayName);
            cmd.Parameters.AddWithValue("@DateOfHoliday", dateOfHoliday);

            if (string.IsNullOrEmpty(holidayDescrption))
            {
                cmd.Parameters.AddWithValue("@Description", DBNull.Value);
            }
            else
            {
                cmd.Parameters.AddWithValue("@Description", holidayDescrption);
            }

            cmd.ExecuteNonQuery();
        }
    }
}