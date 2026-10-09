using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace Spedmon
{
     public partial class ManageEmployees : WebUI
     {
          public ManageEmployees()
               : base("timeentry", WebUI.CreatePageSubTitle("User Management", "Manage users of the Time Keeper System"), "", "", Constants.ROLE_SBS_ALL)
          { 
          }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                {
                    _con.Open();
                    PopulateEmployeeGrid(_con, string.Empty);
                }
            }

        }

        protected void ButtonAddEmployee_Click(object sender, EventArgs e)
        {
            string _url = MBA.HttpApplication.createLink("CreateNewEmployee.aspx", true) + "&employee_id=0&person_id=0";
            Response.Redirect(_url);
        }

        protected void GridView1_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
        }

        protected void GridView1_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            string _confirmDelete = Request.Form["confirm_value"];
            if (_confirmDelete != "Yes")
            {
                return;
            }

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                HiddenField HiddenFieldItemPersonID = (HiddenField)GridView1.Rows[e.RowIndex].FindControl("HiddenFieldItemPersonID");
                HiddenField HiddenFieldEmployeeID = (HiddenField)GridView1.Rows[e.RowIndex].FindControl("HiddenFieldEmployeeID");
                _con.Open();
                // Delete favorites if they exist
                DeleteClientFavorites(_con, HiddenFieldEmployeeID.Value);
                DeleteTaskFavorites(_con, HiddenFieldEmployeeID.Value);
                DeletePerson(_con, HiddenFieldItemPersonID.Value);
                PopulateEmployeeGrid(_con, string.Empty);
            }
        }

        private void DeleteTaskFavorites(SqlConnection con, string employeeID)
        {
            string _sqlCommand = @"
                delete [TimeKeeper].[dbo].[Employee_TimeEntry_Tasks_Favorites]
                where
                    EmployeeID = @EmployeeID";

            using (SqlCommand _cmd = new SqlCommand(_sqlCommand, con))
            {
                _cmd.Parameters.AddWithValue("@EmployeeID", employeeID);
                _cmd.ExecuteNonQuery();
            }
        }

        private void DeleteClientFavorites(SqlConnection con, string employeeID)
        {
            string _sqlCommand = @"
                delete [TimeKeeper].[dbo].[Employee_Organization_Favorites]
                where
                    EmployeeID = @EmployeeID";

            using (SqlCommand _cmd = new SqlCommand(_sqlCommand, con))
            {
                _cmd.Parameters.AddWithValue("@EmployeeID", employeeID);
                _cmd.ExecuteNonQuery();
            }
        }

        private void DeletePerson(SqlConnection con, string personID)
        {
            string _sqlCommand = @"
                delete [TimeKeeper].[dbo].[People]
                where
                    id = @Id";

            using (SqlCommand _cmd = new SqlCommand(_sqlCommand, con))
            {
                _cmd.Parameters.AddWithValue("@Id", personID);
                _cmd.ExecuteNonQuery();
            }
        }

        private void PopulateEmployeeGrid(SqlConnection con, string sortExpression)
        {
            string _sqlStatement = @"
            select
	            P.id as PersonID
	            ,P.firstName
	            ,P.lastName
	            ,ISNULL(P.spedMonUserName, '') AS spedMonUserName
	            ,R.roleName 
	            ,R.roleID
	            ,E.id AS EmployeeID
	            ,E.startDate
	            ,ISNULL(E.endDate, '') AS endDate
	            ,E.employeeStatus
	            ,Pos.title
	            ,O.id as OrganizationID
	            ,O.name as Organization
            from
	            TimeKeeper.dbo.People P
	            inner join TimeKeeper.dbo.TimeSystemRole R
		            ON R.roleID = P.roleID
	            inner join TimeKeeper.dbo.Employees E
		            ON E.personID = P.id
	            inner join TimeKeeper.dbo.Positions Pos
		            ON Pos.id = E.positionID
	            inner join TimeKeeper.dbo.Organizations O
		            ON O.id = E.organizationID
                       and O.active = 1 ";

            if (string.IsNullOrEmpty(sortExpression))
            {
                _sqlStatement += @"
                ORDER BY
	                lastName ASC";
            }
            else if (sortExpression == "firstName")
            {
                _sqlStatement += @"
                ORDER BY
                    firstName " + HiddenFieldFirstNameOrder.Value;

                HiddenFieldFirstNameOrder.Value = HiddenFieldFirstNameOrder.Value == "ASC" ? "DESC" : "ASC";
            }
            else if (sortExpression == "lastName")
            {
                _sqlStatement += @"
                ORDER BY
                    lastName " + HiddenFieldLastNameOrder.Value;

                HiddenFieldLastNameOrder.Value = HiddenFieldLastNameOrder.Value == "ASC" ? "DESC" : "ASC";
            }
            else if (sortExpression == "spedMonUserName")
            {
                _sqlStatement += @"
                ORDER BY
                    spedMonUserName " + HiddenFieldSpedMonUserNameOrder.Value;

                HiddenFieldSpedMonUserNameOrder.Value = HiddenFieldSpedMonUserNameOrder.Value == "ASC" ? "DESC" : "ASC";
            }
            else if (sortExpression == "roleName")
            {
                _sqlStatement += @"
                ORDER BY
                    roleName " + HiddenFieldRoleOrder.Value;

                HiddenFieldRoleOrder.Value = HiddenFieldRoleOrder.Value == "ASC" ? "DESC" : "ASC";
            }
            else if (sortExpression == "startDate")
            {
                _sqlStatement += @"
                ORDER BY
                    startDate " + HiddenFieldStartDateOrder.Value;

                HiddenFieldStartDateOrder.Value = HiddenFieldStartDateOrder.Value == "ASC" ? "DESC" : "ASC";
            }
            else if (sortExpression == "endDate")
            {
                _sqlStatement += @"
                ORDER BY
                    endDate " + HiddenFieldEndDateOrder.Value;

                HiddenFieldEndDateOrder.Value = HiddenFieldEndDateOrder.Value == "ASC" ? "DESC" : "ASC";
            }
            else if (sortExpression == "employeeStatus")
            {
                _sqlStatement += @"
                ORDER BY
                    employeeStatus " + HiddenFieldEmployeeStatusOrder.Value;

                HiddenFieldEmployeeStatusOrder.Value = HiddenFieldEmployeeStatusOrder.Value == "ASC" ? "DESC" : "ASC";
            }
            else if (sortExpression == "title")
            {
                _sqlStatement += @"
                ORDER BY
                    title " + HiddenFieldTitleOrder.Value;

                HiddenFieldTitleOrder.Value = HiddenFieldTitleOrder.Value == "ASC" ? "DESC" : "ASC";
            }
            else if (sortExpression == "Organization")
            {
                _sqlStatement += @"
                ORDER BY
                    Organization " + HiddenFieldOrganizationOrder.Value;

                HiddenFieldOrganizationOrder.Value = HiddenFieldOrganizationOrder.Value == "ASC" ? "DESC" : "ASC";
            }

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            GridView1.DataSource = _dataTable;
            GridView1.DataBind();

        }
        protected void GridView1_RowEditing(object sender, GridViewEditEventArgs e)
        {
            HiddenField HiddenFieldItemPersonID = (HiddenField)GridView1.Rows[e.NewEditIndex].FindControl("HiddenFieldItemPersonID");
            HiddenField HiddenFieldEmployeeID = (HiddenField)GridView1.Rows[e.NewEditIndex].FindControl("HiddenFieldEmployeeID");

            string _url = MBA.HttpApplication.createLink("CreateNewEmployee.aspx", true) + "&employee_id=" + HiddenFieldEmployeeID.Value
                + "&person_id=" + HiddenFieldItemPersonID.Value;
            Response.Redirect(_url);
        }
        protected void GridView1_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
        }

        protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName.Equals("Edit"))
            {

            }
        }
        protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow)
            {
                return;
            }
            Label LabelStartDate = e.Row.FindControl("LabelStartDate") as Label;

            if (LabelStartDate != null)
            {
                LabelStartDate.Text = DateTime.Parse(LabelStartDate.Text).ToString("MM/dd/yyyy");
            }

            Label LabelEndDate = e.Row.FindControl("LabelEndDate") as Label;

            if (LabelEndDate != null)
            {
                if (LabelEndDate.Text.Contains("1900"))
                {
                    LabelEndDate.Text = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
                }
                else 
                {
                    LabelEndDate.Text = DateTime.Parse(LabelEndDate.Text).ToString("MM/dd/yyyy");
                }
            }

            Label LabelEmployeeStatus = e.Row.FindControl("LabelEmployeeStatus") as Label;

            if (LabelEmployeeStatus != null)
            {
                switch (int.Parse(LabelEmployeeStatus.Text))
                {
                    case 0:
                        LabelEmployeeStatus.Text = "Active";
                        break;
                    case 1:
                        LabelEmployeeStatus.Text = "Terminated";
                        break;
                    case 2:
                        LabelEmployeeStatus.Text = "Leave Of Absence";
                        break;
                }
            }
        }

        protected void GridView1_Sorting(object sender, GridViewSortEventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                PopulateEmployeeGrid(_con, e.SortExpression);
            }
        }

        protected void ButtonSearch_Click(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                if (string.IsNullOrEmpty(TextBoxSearch.Text.Trim()))
                {
                    PopulateEmployeeGrid(_con, string.Empty);
                }
                else
                {
                    SearchForPerson(_con);
                }
            }
        }

        private void SearchForPerson(SqlConnection con)
        {
            string _sqlStatement = @"
            select
	            P.id as PersonID
	            ,P.firstName
	            ,P.lastName
	            ,ISNULL(P.spedMonUserName, '') AS spedMonUserName
	            ,R.roleName 
	            ,R.roleID
	            ,E.id AS EmployeeID
	            ,E.startDate
	            ,ISNULL(E.endDate, '') AS endDate
	            ,E.employeeStatus
	            ,Pos.title
	            ,O.id as OrganizationID
	            ,O.name as Organization
            from
	            TimeKeeper.dbo.People P
	            inner join TimeKeeper.dbo.TimeSystemRole R
		            ON R.roleID = P.roleID
	            inner join TimeKeeper.dbo.Employees E
		            ON E.personID = P.id
	            inner join TimeKeeper.dbo.Positions Pos
		            ON Pos.id = E.positionID
	            inner join TimeKeeper.dbo.Organizations O
		            ON O.id = E.organizationID
                      AND O.active = 1";

            string[] _tokens = TextBoxSearch.Text.Split(' ');

            string _where = " where ";
            int _numberTokens = 0;

            foreach (string _token in _tokens)
            {
                ++_numberTokens;
                if (_where != " where ")
                {
                    _where += " OR ";
                }
                _where += "p.lastName like @LastName" + _numberTokens.ToString() + 
                     " OR p.firstName like @FirstName" + _numberTokens.ToString();
            }
            _sqlStatement += _where;

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);

            for (int _counter = 0; _counter < _numberTokens; _counter++)
            {
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@LastName" + (_counter + 1).ToString(), "%" + _tokens[_counter] + "%");
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@FirstName" + (_counter + 1).ToString(), "%" + _tokens[_counter] + "%");
            }

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            GridView1.DataSource = _dataTable;
            GridView1.DataBind();

        }
    }
}
