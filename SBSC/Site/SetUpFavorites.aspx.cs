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
    public partial class SetUpFavorites : WebUI
    {

        public SetUpFavorites()
             : base("timeentry", WebUI.CreatePageSubTitle("Time Entry", "Create, update, or delete time entry"), "", "", Constants.ROLE_SBS_ALL)
        {
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                HiddenFieldEmployeeID.Value = TimeSheetSession.Current.EmployeeId.ToString();
                SetUpPage();
            }
        }

        private void SetUpPage()
        {

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                GetEmployeeName(_con);
                PopulateDropDownListEmployer(_con);
                PopulateAvailableClients(_con);
                PopulateFavoriteClients(_con);
                PopulateAvailableTaskSetUpListBox(_con);
                PopulateFavoritesTaskSetupListBox(_con);
            }
        }

        private void GetEmployeeName(SqlConnection con)
        {
            string _sqlStatement = @"
            select
	            P.firstName
	            ,P.lastName
            from
	            TimeKeeper.dbo.Employees E
	            inner join TimeKeeper.dbo.People P
		            ON P.id = E.personID
            where
	            E.id = @Id";

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", HiddenFieldEmployeeID.Value);
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            if (_dataTable.Rows.Count == 0)
            {
                Response.Redirect("~", true);
                return;
            }

            DataRow _dataRow = _dataTable.Rows[0];
            LabelEmployeeName.Text = _dataRow["firstName"].ToString() + " " + _dataRow["lastName"].ToString();
        }

        private void PopulateAvailableClients(SqlConnection con)
        {
            string @_addSql = @"
                      and o.id not in
                      (
                           select
	                           clientOrganizationID
                           from
	                           TimeKeeper.dbo.Employee_Organization_Favorites
                           where
	                           EmployeeID = @EmployeeId
                      )
                 ";

            ListBoxAvailableClients.DataSource = GetListClients(Convert.ToInt64(DropDownListEmployer.SelectedValue), con, _addSql);
            ListBoxAvailableClients.DataTextField = "name";
            ListBoxAvailableClients.DataValueField = "id";
            ListBoxAvailableClients.DataBind();
        }
        private void PopulateFavoriteClients(SqlConnection con)
        {
            ListBoxFavoritesClientSetUp.DataSource = GetFavoriteClients(con);
            ListBoxFavoritesClientSetUp.DataTextField = "name";
            ListBoxFavoritesClientSetUp.DataValueField = "id";
            ListBoxFavoritesClientSetUp.DataBind();

            InsertAllClientToList(con);
        }

        private void InsertAllClientToList(SqlConnection con)
        {
            string _sqlStatement = @"
                    select
                         id
                         ,name
                    from
                         TimeKeeper.dbo.Organizations
                    where
                         name = 'All Clients'
                         and active = 1";

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            if (_dataTable.Rows.Count != 0)
            {
                DataRow _dataRow = _dataTable.Rows[0];
                ListItem _item = new ListItem();
                _item.Value = _dataRow["id"].ToString();
                _item.Text = _dataRow["name"].ToString();

                ListBoxFavoritesClientSetUp.Items.Insert(0, _item);
            }
        }
        private DataTable GetFavoriteClients(SqlConnection con)
        {
            string _sqlStatement = @"
                         select
                              O.id
                              ,O.name
                         from
                              TimeKeeper.dbo.Employee_Organization_Favorites EOF
                              inner join TimeKeeper.dbo.Organizations O
                                   on O.id = EOF.clientOrganizationID
                                      and O.active = 1
                         where
                              EOF.EmployeeID = @Id
                              AND O.name != 'All Clients'
                         order by
                             O.name";

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", HiddenFieldEmployeeID.Value);

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            return _dataTable;
        }

        private DataTable GetListClients(long organizationID, SqlConnection con, string addSql)
        {
            string _sqlStatement = @"
                         select 
                              O.id,
                              O.name
                         from 
                              TimeKeeper.dbo.Organization_Clients OC	
                              inner join TimeKeeper.dbo.Organizations O
                                   ON O.id = OC.clientOrganizationID
                                     and O.active = 1
                         where 
                              OC.organizationID = @OrganizationID "
                        + " " + addSql + @"
                         order by
                             O.name";


            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@EmployeeId", HiddenFieldEmployeeID.Value);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@OrganizationID", DropDownListEmployer.SelectedValue);
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            return _dataTable;

        }

        private void PopulateDropDownListEmployer(SqlConnection con)
        {
            string _sqlStatement = @"select
                                    o.id,
                                    o.name
                                from
                                    TimeKeeper.dbo.Employees e
                                    inner join TimeKeeper.dbo.Organizations o
                                        on o.id = e.organizationID
                                           and o.active = 1
                                where
                                    e.id = @Id";

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", HiddenFieldEmployeeID.Value);
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            if (_dataTable.Rows.Count == 0)
            {
                Response.Redirect("~", true);
                return;
            }

            DropDownListEmployer.DataSource = _dataTable;
            DropDownListEmployer.DataTextField = "name";
            DropDownListEmployer.DataValueField = "id";
            DropDownListEmployer.DataBind();

            DropDownListEmployer.SelectedIndex = 0;
        }
        private void PopulateFavoriteSetUpPanel()
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                con.Open();

                PopulateFavoritesTaskSetupListBox(con);
                PopulateAvailableTaskSetUpListBox(con);
            }
        }

        private void PopulateFavoritesTaskSetupListBox(SqlConnection con)
        {
            ListBoxSelectedFavoriteTaskSetUp.DataSource = GetListTaskFavorites(con);
            ListBoxSelectedFavoriteTaskSetUp.DataTextField = "name";
            ListBoxSelectedFavoriteTaskSetUp.DataValueField = "id";
            ListBoxSelectedFavoriteTaskSetUp.DataBind();
        }

        private void PopulateAvailableTaskSetUpListBox(SqlConnection con)
        {
            ListBoxAvailableTasks.DataSource = GetListAvalableTask(con);
            ListBoxAvailableTasks.DataTextField = "name";
            ListBoxAvailableTasks.DataValueField = "id";
            ListBoxAvailableTasks.DataBind();

        }
        private DataTable GetListTaskFavorites(SqlConnection con)
        {
            string _sqlStatement = @"
                     select
                          TET.id
                          ,TET.name
                     from
                          TimeKeeper.dbo.TimeEntry_Tasks TET
                          inner join TimeKeeper.dbo.Employee_TimeEntry_Tasks_Favorites ETTF
                               ON ETTF.taskID = TET.id
                          inner join TimeKeeper.dbo.Employees E
                               ON E.id = ETTF.EmployeeID
                     where
                          E.id = @EmployeeID
                          AND TET.active = 1
                     order by
                          TET.name";

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@EmployeeID", HiddenFieldEmployeeID.Value);
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            return _dataTable;

        }

        private DataTable GetListAvalableTask(SqlConnection con)
        {
            string _sqlStatement = @"
                     select
                          TET.id
                          ,TET.name
                     from
                          TimeKeeper.dbo.TimeEntry_Tasks TET
                     where
                          TET.id not in
                          (
                               select
	                               taskID
                               from
	                               TimeKeeper.dbo.Employee_TimeEntry_Tasks_Favorites
                               where
	                               EmployeeID = @EmployeeID
                          )
                          and TET.active = 1
                      order by TET.name";

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@EmployeeID", HiddenFieldEmployeeID.Value);
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            return _dataTable;
        }

        protected void ButtonMoveToFavorites_Click(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                string _sqlInsertStatement = @"
                     insert into TimeKeeper.dbo.Employee_Organization_Favorites
                     (
                         EmployeeID
                         ,clientOrganizationID
                     )
                     values
                     ( 
                         @EmployeeID
                         ,@clientOrganizationID
                     )";

                SqlCommand _sqlInsertCommand = null;
                ListItem _listItem = null;

                foreach (int _index in ListBoxAvailableClients.GetSelectedIndices())
                {
                    _listItem = ListBoxAvailableClients.Items[_index];
                    _sqlInsertCommand = new SqlCommand(_sqlInsertStatement, _con);
                    _sqlInsertCommand.Parameters.AddWithValue("@EmployeeID", HiddenFieldEmployeeID.Value);
                    _sqlInsertCommand.Parameters.Add("@clientOrganizationID", SqlDbType.BigInt).Value = Convert.ToInt64(_listItem.Value);
                    _sqlInsertCommand.CommandType = CommandType.Text;
                    _sqlInsertCommand.ExecuteNonQuery();
                    _sqlInsertCommand.Dispose();
                }
            }

            SetUpPage();
        }
        protected void ButtonMoveToAvailableClients_Click(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                string _sqlDeleteStatement = @"
                     delete from TimeKeeper.dbo.Employee_Organization_Favorites
                     where EmployeeID = @EmployeeID
                           and clientOrganizationID = @clientOrganizationID";

                SqlCommand _sqlDeleteCommand = null;
                ListItem _listItem = null;

                foreach (int _index in ListBoxFavoritesClientSetUp.GetSelectedIndices())
                {
                    _listItem = ListBoxFavoritesClientSetUp.Items[_index];
                    _sqlDeleteCommand = new SqlCommand(_sqlDeleteStatement, _con);
                    _sqlDeleteCommand.Parameters.AddWithValue("@EmployeeID", HiddenFieldEmployeeID.Value);
                    _sqlDeleteCommand.Parameters.Add("@clientOrganizationID", SqlDbType.BigInt).Value = Convert.ToInt64(_listItem.Value);
                    _sqlDeleteCommand.CommandType = CommandType.Text;
                    _sqlDeleteCommand.ExecuteNonQuery();
                    _sqlDeleteCommand.Dispose();
                }
            }

            SetUpPage();
        }

        protected void ButtonMoveToFavoriteTask_Click(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                string _sqlInsertStatement = @"
                     insert into TimeKeeper.dbo.Employee_TimeEntry_Tasks_Favorites
                     (
                         EmployeeID
                         ,taskID
                     )
                     values
                     ( 
                         @EmployeeID
                         ,@taskID
                     )";

                SqlCommand _sqlInsertCommand = null;
                ListItem _listItem = null;

                foreach (int _index in ListBoxAvailableTasks.GetSelectedIndices())
                {
                    _listItem = ListBoxAvailableTasks.Items[_index];
                    _sqlInsertCommand = new SqlCommand(_sqlInsertStatement, _con);
                    _sqlInsertCommand.Parameters.AddWithValue("@EmployeeID", HiddenFieldEmployeeID.Value);
                    _sqlInsertCommand.Parameters.Add("@taskID", SqlDbType.BigInt).Value = Convert.ToInt64(_listItem.Value);
                    _sqlInsertCommand.CommandType = CommandType.Text;
                    _sqlInsertCommand.ExecuteNonQuery();
                    _sqlInsertCommand.Dispose();
                }
            }

            PopulateFavoriteSetUpPanel();
        }
        protected void ButtonMoveToAvailableTask_Click(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                string _sqlDeleteStatement = @"
                     delete from TimeKeeper.dbo.Employee_TimeEntry_Tasks_Favorites
                     where EmployeeID = @EmployeeID
                           and taskID = @taskID";

                SqlCommand _sqlDeleteCommand = null;
                ListItem _listItem = null;

                foreach (int _index in ListBoxSelectedFavoriteTaskSetUp.GetSelectedIndices())
                {
                    _listItem = ListBoxSelectedFavoriteTaskSetUp.Items[_index];
                    _sqlDeleteCommand = new SqlCommand(_sqlDeleteStatement, _con);
                    _sqlDeleteCommand.Parameters.AddWithValue("@EmployeeID", HiddenFieldEmployeeID.Value);
                    _sqlDeleteCommand.Parameters.Add("@taskID", SqlDbType.BigInt).Value = Convert.ToInt64(_listItem.Value);
                    _sqlDeleteCommand.CommandType = CommandType.Text;
                    _sqlDeleteCommand.ExecuteNonQuery();
                    _sqlDeleteCommand.Dispose();
                }
            }

            PopulateFavoriteSetUpPanel();
        }

        protected void RadioButtonListDiplayOptions_SelectedIndexChanged(object sender, EventArgs e)
        {
            switch (RadioButtonListDiplayOptions.SelectedValue)
            {
                case "0":
                    PanelClientFavorites.Visible = true;
                    PanelTaskFavorites.Visible = true;
                    break;
                case "1":
                    PanelClientFavorites.Visible = true;
                    PanelTaskFavorites.Visible = false;
                    break;
                case "2":
                    PanelClientFavorites.Visible = false;
                    PanelTaskFavorites.Visible = true;
                    break;
            }
        }
    }
}