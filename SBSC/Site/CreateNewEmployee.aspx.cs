using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;
using System.Globalization;


namespace Spedmon
{
     public partial class CreateNewEmployee : WebUI
     {
          public CreateNewEmployee()
               : base("timeentry", WebUI.CreatePageSubTitle("User Management", "Create or Edit users of the Time Keeper System"), "", "", Constants.ROLE_SBS_ALL)
          { 
          }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                HiddenFieldEmployeeID.Value = Request.QueryString["employee_id"];
                HiddenFieldPersonID.Value = Request.QueryString["person_id"];

                if (HiddenFieldEmployeeID.Value == "0")
                {
                    PanelViewUserInfo.Visible = false;
                    PanelAddUser.Visible = true;
                    ButtonUpdate.Visible = false;
                    ButtonAdd.Visible = true;
                    PanelEndDate.Visible = false;
                    DropDownListEmployeeStatus.SelectedIndex = 0;
                    DropDownListEmployeeStatus.Enabled = false;
                }
                else
                {
                    PanelViewUserInfo.Visible = true;
                    PanelAddUser.Visible = false;
                    ButtonUpdate.Visible = true;
                    ButtonAdd.Visible = false;
                    PanelEndDate.Visible = true;
                    DropDownListEmployeeStatus.Enabled = true;
                }

                using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                {
                    if (HiddenFieldEmployeeID.Value == "0")
                    {
                        PopulateDropDownListUsers(_con);
                    }

                    PopulateRoleDropDown(_con);
                    PopulateOrganizationDropdown(_con);
                    if (HiddenFieldEmployeeID.Value != "0" && HiddenFieldPersonID.Value != "0")
                    {
                        PopulateFormWithExistingEmployee(_con);
                    }
                }
            }
        }

        private DataTable GetEmployeeInfo(SqlConnection con)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHET_GetEmployeeInfoDetail", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", HiddenFieldEmployeeID.Value);

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            return _dataTable;
        }

        private void PopulateFormWithExistingEmployee(SqlConnection con)
        {
            DataTable _dataTable = GetEmployeeInfo(con);

            if (_dataTable.Rows.Count != 1)
            {
                ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        "Problem with employee record",
                        "alert('There is a problem with this record.  Please contact Tech Support and let them know which record you have an issue with.');",
                        true);
                string _url = MBA.HttpApplication.createLink("ManageEmployees.aspx", true);
                Response.Redirect(_url);
                return;
            }
            DataRow _row = _dataTable.Rows[0];

            TextBoxFirstName.Text = _row["firstName"].ToString();
            TextBoxLastName.Text = _row["lastName"].ToString();
            TextBoxSpedMonUserName.Text = _row["spedMonUserName"].ToString();

            DropDownListRole.SelectedValue = _row["roleID"].ToString();
            DropDownListEmployeeStatus.SelectedValue = _row["employeeStatus"].ToString();
            DropDownListOrganization.SelectedValue = _row["OrganizationID"].ToString();

            PopulateDropDownListPositions(con);

            DropDownListPosition.SelectedValue = _row["PositionID"].ToString();
            CheckBoxPartTime.Checked = bool.Parse(_row["partTime"].ToString());
            CheckBoxExempt.Checked = bool.Parse(_row["isExempt"].ToString());
            CheckBoxSalaried.Checked = bool.Parse(_row["isSalaried"].ToString());
            CheckBoxPaidForHolidays.Checked = bool.Parse(_row["PaidForHolidays"].ToString());

            CheckboxNoPayroll.Checked = bool.Parse(_row["noPayroll"].ToString());

            TextBoxSelectedStartDate.Text = DateTime.Parse(_row["startDate"].ToString()).ToString("MM/dd/yyyy");

            string _endDate = _row["endDate"].ToString();
            if (!_endDate.Equals("1/1/1900 12:00:00 AM"))
            {
                TextBoxSelectedEndDate.Text = DateTime.Parse(_endDate).ToString("MM/dd/yyyy");
            }

            TextBoxEMail.Text = _row.IsNull("EmailAddress") ? string.Empty : _row["EmailAddress"].ToString();
            TextBoxAddress.Text = _row.IsNull("Address") ? string.Empty : _row["Address"].ToString();
            TextBoxCity.Text = _row.IsNull("City") ? string.Empty : _row["City"].ToString();
            dropDownListState.SelectedValue = _row.IsNull("State") ? string.Empty : _row["State"].ToString();
            TextBoxZipCode.Text = _row.IsNull("ZipCode") ? string.Empty : _row["ZipCode"].ToString();
            TextBoxPhoneNumber.Text = _row.IsNull("PhoneNumber") ? string.Empty : _row["PhoneNumber"].ToString();
        }
        private void PopulateOrganizationDropdown(SqlConnection con)
        {
            string _sqlStatement = @"
            select
	            id
	            ,name
            from
	            TimeKeeper.dbo.Organizations
            where
                active = 1";

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            DropDownListOrganization.DataSource = _dataTable;
            DropDownListOrganization.DataValueField = "id";
            DropDownListOrganization.DataTextField = "name";
            DropDownListOrganization.DataBind();

            ListItem _listItem = new ListItem();
            _listItem.Text = "--- Select Organization ---";
            _listItem.Value = "0";

            DropDownListOrganization.Items.Insert(0, _listItem);
            DropDownListOrganization.SelectedIndex = 0;

            ListItem _listItemPos = new ListItem();
            _listItemPos.Text = "--- Need to Select Organization ---";
            _listItemPos.Value = "0";
            DropDownListPosition.Items.Insert(0, _listItemPos);
        }
        private void PopulateRoleDropDown(SqlConnection con)
        {
            string _sqlStatement = @"
            select
	            roleID
	            ,roleName
            from
	            TimeKeeper.dbo.TimeSystemRole";

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            DropDownListRole.DataSource = _dataTable;
            DropDownListRole.DataTextField = "roleName";
            DropDownListRole.DataValueField = "roleID";
            DropDownListRole.DataBind();

            ListItem _listItem = new ListItem();
            _listItem.Text = "--- Select Role ---";
            _listItem.Value = "0";

            DropDownListRole.Items.Insert(0, _listItem);
            DropDownListRole.SelectedIndex = 0;
        }
        protected void lnkpickstartdate_Click(object sender, EventArgs e)
        {
            datepicker_start.Visible = true;
        }

        protected void datepickerstart_SelectionChanged(object sender, EventArgs e)
        {
            TextBoxSelectedStartDate.Text = datepicker_start.SelectedDate.ToString("MM/dd/yyyy");
            datepicker_start.Visible = false;
        }

        protected void lnkpickdateend_Click(object sender, EventArgs e)
        {
            datepicker_end.Visible = true;
        }

        protected void datepickerend_SelectionChanged(object sender, EventArgs e)
        {
            TextBoxSelectedEndDate.Text = datepicker_end.SelectedDate.ToString("MM/dd/yyyy");
            datepicker_end.Visible = false;
        }

        protected void ButtonBack_Click(object sender, EventArgs e)
        {
            string _url = MBA.HttpApplication.createLink("ManageEmployees.aspx", true);
            Response.Redirect(_url);
        }

        protected void DropDownListOrganization_SelectedIndexChanged(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                PopulateDropDownListPositions(_con);
            }
        }

        private DataSet GetSpedmonUsersInfo(SqlConnection con)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_SelectSpedmonUsers", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            DataSet _dataSet = new DataSet();
            _sqlDataAdapter.Fill(_dataSet);

            return _dataSet;
        }

        private void PopulateDropDownListUsers(SqlConnection con)
        {
            DataSet _dataSet = GetSpedmonUsersInfo(con);

            DropDownListUsers.DataTextField = "UserInfo";
            DropDownListUsers.DataValueField = "uid";

            DropDownListUsers.DataSource = _dataSet.Tables[0];
            DropDownListUsers.DataBind();

            ListItem _listItem = new ListItem();

            if (DropDownListUsers.Items.Count == 0)
            {
                _listItem.Text = "There are no employees to add";
            }
            else
            {
                _listItem.Text = "Please Select Employee";
            }

            _listItem.Value = "0";

            DropDownListUsers.Items.Add(_listItem);
            DropDownListUsers.SelectedValue = "0";
        }

        private void PopulateDropDownListPositions(SqlConnection con)
        {
            string _sqlStatement = @"
                select
	                id
	                ,title
                from
	                TimeKeeper.dbo.Positions";
                //where
	               // organizationID = @OrganizationID";

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            //_sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@OrganizationID", DropDownListOrganization.SelectedValue);
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            DropDownListPosition.DataSource = _dataTable;
            DropDownListPosition.DataValueField = "id";
            DropDownListPosition.DataTextField = "title";
            DropDownListPosition.DataBind();

            ListItem _listItem = new ListItem();
            _listItem.Text = "--- Select Position ---";
            _listItem.Value = "0";

            DropDownListPosition.Items.Insert(0, _listItem);
            DropDownListPosition.SelectedIndex = 0;

        }

        protected void ButtonAdd_Click(object sender, EventArgs e)
        {

            LabelAddUserError.Text = string.Empty;
            LabelErrorAddRole.Text = string.Empty;
            LabelAddErrorOrganization.Text = string.Empty;
            LabelAddErrorPosition.Text = string.Empty;
            LiteralMessage.Text = string.Empty;

            if (DropDownListUsers.SelectedValue == "0")
            {
                LabelAddUserError.Text = "<br/>You must select an employee<br/>";
                return;
            }

            if (DropDownListRole.SelectedValue == "0")
            {
                LabelErrorAddRole.Text = "<br/>You must select a role<br/>";
                return;
            }

            if (DropDownListOrganization.SelectedValue =="0")
            {
                LabelAddErrorOrganization.Text = "<br/>You must select an organization<br/>";
                return;
            }

            if (DropDownListPosition.SelectedValue == "0")
            {
                LabelAddErrorPosition.Text = "<br/>You must select a position<br/>";
                return;
            }

            if (string.IsNullOrEmpty(TextBoxSelectedStartDate.Text))
            {
                LiteralMessage.Text = "<br/>You must indicate a start date<br/>";
                return;
            }

            string _confirmDelete = Request.Form["confirm_value"];
            if (_confirmDelete != "Yes")
            {
                return;
            }
            string _word = string.Empty;
            InsertPerson();
            _word = "created";

            ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                    "Employee " + _word,
                    "alert('Employee has been " + _word + "');",
                    true);
        }

        protected void ButtonUpdate_Click(object sender, EventArgs e)
        {
            string _confirmDelete = Request.Form["confirm_value"];
            if (_confirmDelete != "Yes")
            {
                return;
            }

            string _problems = string.Empty;
            if (!CanUpdateOrCreateEmployee(out _problems))
            {
                ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                        "Missing Information",
                        "alert('" + _problems + "');",
                        true);
                return;
            }
            string _word = string.Empty;
            UpdatePerson();
            _word = "updated";

            ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                    "Employee " + _word,
                    "alert('Employee has been " + _word + "');",
                    true);
        }

        private bool CanUpdateOrCreateEmployee(out string problems)
        {
            problems = string.Empty;
            bool _canCreate = true;

            if (DropDownListRole.SelectedValue == "0")
            {
                problems += "Role must be selected !\\n";
                _canCreate = false;
            }

            if (DropDownListOrganization.SelectedValue == "0")
            {
                problems += "Organiztion must be selected !\\n";
                _canCreate = false;
            }

            if (DropDownListPosition.SelectedValue == "0")
            {
                problems += "Position must be selected !\\n";
                _canCreate = false;
            }

            DateTime _dateTimeStartTest = DateTime.MinValue;
            DateTime _dateTimeEndTest = DateTime.MaxValue;

            bool _validStartDate = DateTime.TryParse(
                TextBoxSelectedStartDate.Text,
                out _dateTimeStartTest);

            if (!_validStartDate)
            {
                problems += "Start date is not valid !\\n";
                _canCreate = false;
            }

            if (DropDownListEmployeeStatus.SelectedValue == "1")
            {
                _validStartDate = DateTime.TryParse(
                    TextBoxSelectedEndDate.Text,
                    out _dateTimeEndTest);

                if (!_validStartDate)
                {
                    problems += "End date is not valid !\\n";
                    _canCreate = false;
                }

            }

            // Check End date is equal to or after end date
            if (_dateTimeEndTest < _dateTimeStartTest)
            {
                _canCreate = false;
                problems += "End date must be equal to or after start date";
            }

            return _canCreate;
        }

        private void UpdatePerson()
        {
            string _sqlStatement = @"
            UPDATE [TimeKeeper].[dbo].[People]
               SET [roleID] = @roleID
                  ,[lastName] = @lastName
                  ,[firstName] = @firstName
                  ,[spedMonUserName] = @spedMonUserName
             WHERE 
                 id = @Id";

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();

                SqlCommand _sqlcommand = new SqlCommand(_sqlStatement, _con);
                _sqlcommand.Parameters.AddWithValue("@roleID", DropDownListRole.SelectedValue);
                _sqlcommand.Parameters.AddWithValue("@lastName", TextBoxLastName.Text);
                _sqlcommand.Parameters.AddWithValue("@firstName", TextBoxFirstName.Text);
                _sqlcommand.Parameters.AddWithValue("@spedMonUserName", TextBoxSpedMonUserName.Text);
                _sqlcommand.Parameters.AddWithValue("@Id", HiddenFieldPersonID.Value);

                _sqlcommand.ExecuteScalar();

                UpdateEmployee(_con);
            }
        }

        private void UpdateEmployee(SqlConnection con)
        {
            SqlCommand _sqlcommand = new SqlCommand("TimeKeeper_TIMESHEET_UpdateEmployee", con);
            _sqlcommand.CommandType = CommandType.StoredProcedure;

            _sqlcommand.Parameters.AddWithValue("@Id", HiddenFieldEmployeeID.Value);

            _sqlcommand.Parameters.AddWithValue("@personID", HiddenFieldPersonID.Value);
            _sqlcommand.Parameters.AddWithValue("@positionID", DropDownListPosition.SelectedValue);
            _sqlcommand.Parameters.AddWithValue("@organizationID", DropDownListOrganization.SelectedValue);
            _sqlcommand.Parameters.AddWithValue("@partTime", CheckBoxPartTime.Checked);
            _sqlcommand.Parameters.AddWithValue("@startDate", TextBoxSelectedStartDate.Text);

            if (string.IsNullOrEmpty(TextBoxSelectedEndDate.Text))
            {
                _sqlcommand.Parameters.AddWithValue("@endDate", DBNull.Value);
            }
            else
            {
                _sqlcommand.Parameters.AddWithValue("@endDate", TextBoxSelectedEndDate.Text);
            }

            _sqlcommand.Parameters.AddWithValue("@usePositionTasks", true);
            _sqlcommand.Parameters.AddWithValue("@autoPopulateSchedule", false);
            _sqlcommand.Parameters.AddWithValue("@applyFLSARules", true);
            _sqlcommand.Parameters.AddWithValue("@isExempt", CheckBoxExempt.Checked);
            _sqlcommand.Parameters.AddWithValue("@isSalaried", CheckBoxSalaried.Checked);
            _sqlcommand.Parameters.AddWithValue("@notifyScheduleChange", true);
            _sqlcommand.Parameters.AddWithValue("@specifyStartTime", true);
            _sqlcommand.Parameters.AddWithValue("@specifyEndTime", true);
            _sqlcommand.Parameters.AddWithValue("@noPayroll", CheckboxNoPayroll.Checked);
            _sqlcommand.Parameters.AddWithValue("@employeeStatus", DropDownListEmployeeStatus.SelectedValue);
            _sqlcommand.Parameters.AddWithValue("@PaidForHolidays", CheckBoxPaidForHolidays.Checked);
            _sqlcommand.Parameters.AddWithValue("@EmailAddress", TextBoxEMail.Text);
            _sqlcommand.Parameters.AddWithValue("@Address", TextBoxAddress.Text);
            _sqlcommand.Parameters.AddWithValue("@City", TextBoxCity.Text);
            _sqlcommand.Parameters.AddWithValue("@State", dropDownListState.SelectedValue);
            _sqlcommand.Parameters.AddWithValue("@ZipCode", TextBoxZipCode.Text);
            _sqlcommand.Parameters.AddWithValue("@PhoneNumber", TextBoxPhoneNumber.Text);

            _sqlcommand.ExecuteNonQuery();

        }
        private void InsertPerson()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();

                DataSet _dataSet = GetSpedmonUsersInfo(_con);

                if (_dataSet.Tables.Count == 0)
                {
                    return;
                }

                DataRow[] _rows = _dataSet.Tables[0].Select("uid = '" + DropDownListUsers.SelectedValue + "'");

                string _sqlStatement = @"
                    INSERT INTO [TimeKeeper].[dbo].[People]
                    (
                        [roleID]
                        ,[lastName]
                        ,[firstName]
                        ,[spedMonUserName]
                    )
                    VALUES
                    (
                        @roleID
                        ,@lastName
                        ,@firstName
                        ,@spedMonUserName
                    );
                    SELECT SCOPE_IDENTITY();";

                SqlCommand _sqlcommand = new SqlCommand(_sqlStatement, _con);
                _sqlcommand.Parameters.AddWithValue("@roleID", DropDownListRole.SelectedValue);
                _sqlcommand.Parameters.AddWithValue("@lastName", _rows[0]["lastName"].ToString());
                _sqlcommand.Parameters.AddWithValue("@firstName", _rows[0]["firstName"].ToString());
                _sqlcommand.Parameters.AddWithValue("@spedMonUserName", _rows[0]["userName"].ToString());

                object _id = _sqlcommand.ExecuteScalar();

                HiddenFieldPersonID.Value = _id.ToString();
                InsertEmployee(_con);
                PopulateDropDownListUsers(_con);
                PanelAddUser.Visible = false;
                PanelViewUserInfo.Visible = true;
                PopulateFormWithExistingEmployee(_con);
                ButtonAdd.Visible = false;
                ButtonUpdate.Visible = true;
            }
        }

        private void InsertEmployee(SqlConnection con)
        {
            SqlCommand _sqlcommand = new SqlCommand("TimeKeeper_TIMESHEET_CreateEmployee", con);
            _sqlcommand.CommandType = CommandType.StoredProcedure;
            _sqlcommand.Parameters.AddWithValue("@personID", HiddenFieldPersonID.Value);
            _sqlcommand.Parameters.AddWithValue("@positionID", DropDownListPosition.SelectedValue);
            _sqlcommand.Parameters.AddWithValue("@organizationID", DropDownListOrganization.SelectedValue);
            _sqlcommand.Parameters.AddWithValue("@partTime", CheckBoxPartTime.Checked);
            _sqlcommand.Parameters.AddWithValue("@startDate", TextBoxSelectedStartDate.Text);
            _sqlcommand.Parameters.AddWithValue("@usePositionTasks", true);
            _sqlcommand.Parameters.AddWithValue("@autoPopulateSchedule", false);
            _sqlcommand.Parameters.AddWithValue("@applyFLSARules", true);
            _sqlcommand.Parameters.AddWithValue("@isExempt", CheckBoxExempt.Checked);
            _sqlcommand.Parameters.AddWithValue("@isSalaried", CheckBoxSalaried.Checked);
            _sqlcommand.Parameters.AddWithValue("@notifyScheduleChange", true);
            _sqlcommand.Parameters.AddWithValue("@specifyStartTime", true);
            _sqlcommand.Parameters.AddWithValue("@specifyEndTime", true);
            _sqlcommand.Parameters.AddWithValue("@noPayroll", CheckboxNoPayroll.Checked);
            _sqlcommand.Parameters.AddWithValue("@employeeStatus", DropDownListEmployeeStatus.SelectedValue);
            _sqlcommand.Parameters.AddWithValue("@PaidForHolidays", CheckBoxPaidForHolidays.Checked);
            _sqlcommand.Parameters.AddWithValue("@EmailAddress", TextBoxEMail.Text);
            _sqlcommand.Parameters.AddWithValue("@Address", TextBoxAddress.Text);
            _sqlcommand.Parameters.AddWithValue("@City", TextBoxCity.Text);
            _sqlcommand.Parameters.AddWithValue("@State", dropDownListState.SelectedValue);
            _sqlcommand.Parameters.AddWithValue("@ZipCode", TextBoxZipCode.Text);
            _sqlcommand.Parameters.AddWithValue("@PhoneNumber", TextBoxPhoneNumber.Text);
            _sqlcommand.Parameters.Add("@Id", SqlDbType.BigInt);
            _sqlcommand.Parameters["@Id"].Direction = ParameterDirection.Output;

            _sqlcommand.ExecuteNonQuery();

            HiddenFieldEmployeeID.Value = _sqlcommand.Parameters["@Id"].Value.ToString();
            ButtonUpdate.Visible = true;
            ButtonAdd.Visible = false;
            PanelEndDate.Visible = true;
            DropDownListEmployeeStatus.Enabled = true;
        }
    }
}
