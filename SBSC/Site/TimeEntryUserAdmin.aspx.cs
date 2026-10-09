using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;
using MBA.Web;
using MBA.BitteTime;
using MBA;
using System.Globalization;

namespace Spedmon
{
     public partial class TimeEntryUserAdmin : WebUI
     {

          public TimeEntryUserAdmin()
               : base("timeentry", WebUI.CreatePageSubTitle("User Management", "Manage users of the Time Keeper System"), "", "", Constants.ROLE_SBS_ALL)
          { 
          }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (TimeSheetSession.Current.RoleId != 1)
            {
                Response.Redirect("~");
                return;
            }

            if (!IsPostBack)
            {
                using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                {
                    _con.Open();
                    PopulateEmployeeDropDown(_con);
                    PopulateOrganizationDropDown(_con);
                }
            }
        }

        private void PopulateOrganizationDropDown(SqlConnection con)
        {
            string _sqlStatement = @"
            select
	            *
            from
	            TimeKeeper.dbo.Organizations
            where
                active = 1";

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);
            DropDownListOrganization.DataSource = _dataTable;
            DropDownListOrganization.DataTextField = "name";
            DropDownListOrganization.DataValueField = "id";
            DropDownListOrganization.DataBind();

            ListItem _listItem = new ListItem();

            if (DropDownListOrganization.Items.Count == 0)
            {
                _listItem.Text = "There are no Organizations";
            }
            else
            {
                _listItem.Text = "Please Select Organization";
            }
            _listItem.Value = "0";

            DropDownListOrganization.Items.Add(_listItem);
            DropDownListOrganization.SelectedValue = "0";
        }

        private void PopulateEmployeeDropDown(SqlConnection con)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetEmployeeInfo", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            DataSet _dataSet = new DataSet();
            _sqlDataAdapter.Fill(_dataSet);

            DropDownListEmployeeName.DataTextField = "name";
            DropDownListEmployeeName.DataValueField = "id";

            DropDownListEmployeeName.DataSource = _dataSet.Tables[0];
            DropDownListEmployeeName.DataBind();

            ListItem _listItem = new ListItem();

            if (DropDownListEmployeeName.Items.Count == 0)
            {
                _listItem.Text = "There are no employees present";
            }
            else
            {
                _listItem.Text = "Please Select Employee";
            }

            _listItem.Value = "0";

            DropDownListEmployeeName.Items.Add(_listItem);
            DropDownListEmployeeName.SelectedValue = "0";
        }

        protected void DropDownListEmployeeName_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (DropDownListEmployeeName.SelectedValue == "0")
            {
                PanelRecordDetails.Visible = false;
                return;
            }

            PanelRecordDetails.Visible = true;
            PopulateRecordDetail();
        }

        private void PopulateRecordDetail()
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();

                string _sqlStatement = @"        
                select
	                *
                from
	                TimeKeeper.dbo.Employees
                where
	                id = @Id";

                SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", DropDownListEmployeeName.SelectedValue);
                DataTable _dataTable = new DataTable();
                _sqlDataAdapter.Fill(_dataTable);

                if (_dataTable.Rows.Count == 0)
                {
                    PanelRecordDetails.Visible = false;
                    return;
                }

                DataRow _dataRow = _dataTable.Rows[0];

                string _organizationId = _dataRow["organizationID"].ToString();
                DropDownListOrganization.SelectedValue = _organizationId;

                string _positionId = _dataRow["positionID"].ToString();
                PopulatePosition(_con, _positionId, _organizationId);

                CheckBoxStartTime.Checked = bool.Parse(_dataRow["specifyStartTime"].ToString());
                CheckBoxEndTime.Checked = bool.Parse(_dataRow["specifyEndTime"].ToString());

                DropDownListEmployeeStatus.SelectedValue = _dataRow["employeeStatus"].ToString();
            }
        }

        private void PopulatePosition(SqlConnection con, string positionId, string organizationId)
        {
            string _sqlStatement = @"
                select
	                *
                from
	                TimeKeeper.dbo.Positions    
                where
                    organizationID = @OrganizationID";

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@OrganizationID", organizationId);
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            DropDownListPosition.DataTextField = "title";
            DropDownListPosition.DataValueField = "id";

            DropDownListPosition.DataSource = _dataTable;
            DropDownListPosition.DataBind();

            ListItem _item = new ListItem();

            if (DropDownListPosition.Items.Count == 0)
            {
                _item.Text = "There are not positions listed for this organization";
            }
            else
            {
                _item.Text = "Please Select Position";
            }

            _item.Value = "0";

            DropDownListPosition.Items.Add(_item);

            if (string.IsNullOrEmpty(positionId))
            {
                DropDownListPosition.SelectedValue = "0";
            }
            else
            {
                DropDownListPosition.SelectedValue = positionId;
            }
        }

        protected void DropDownListOrganization_SelectedIndexChanged(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                PopulatePosition(_con, string.Empty, DropDownListOrganization.SelectedValue);
            }
        }

        protected void ButtonSave_Click(object sender, EventArgs e)
        {
            string confirmValue = Request.Form["confirm_value"];
            if (confirmValue != "Yes")
            {
                PanelRecordDetails.Visible = true;
                PopulateRecordDetail();
                return;
            }

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();

                string _sqlStatement = @"
                update
	                TimeKeeper.dbo.Employees
                set
	                positionID = @PositionID
                    ,organizationID = @OrganiztionID
                    ,specifyStartTime = @SpecifyStartTime
                    ,specifyEndTime = @SpecifyEndTime
                    ,employeeStatus = @EmployeeStatus
                 where
	                id = @Id";

                using (SqlCommand cmd = new SqlCommand(_sqlStatement, _con))
                {
                    cmd.Parameters.AddWithValue("@PositionID", DropDownListPosition.SelectedValue);
                    cmd.Parameters.AddWithValue("@OrganiztionID", DropDownListOrganization.SelectedValue);
                    cmd.Parameters.AddWithValue("@SpecifyStartTime", CheckBoxStartTime.Checked);
                    cmd.Parameters.AddWithValue("@SpecifyEndTime", CheckBoxEndTime.Checked);
                    cmd.Parameters.AddWithValue("@EmployeeStatus", DropDownListEmployeeStatus.SelectedValue);
                    cmd.Parameters.AddWithValue("@Id", DropDownListEmployeeName.SelectedValue);
                    cmd.ExecuteNonQuery();
                }
            }
        }


        protected void ButtonManageEmployee_Click(object sender, EventArgs e)
        {
            string _url = MBA.HttpApplication.createLink("ManageEmployees.aspx", true);
        }

        protected void ButtonModify_Click(object sender, EventArgs e)
        {

        }
    }
}
