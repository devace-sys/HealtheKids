using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;
using MBA.BitteTime;

namespace Spedmon
{
    public partial class ClientOranizationManagement : WebUI
    {
        public ClientOranizationManagement()
             : base("timeentry", WebUI.CreatePageSubTitle("Client Management", "Create or Edit clients of Time Keeper"), "", "", Constants.ROLE_SBS_ALL)
        {
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                {
                    PopulateOrganizationGrid(_con, string.Empty, string.Empty);
                }
            }
        }

        private void PopulateOrganizationGrid(SqlConnection con, string sortExpression, string whereClause)
        {
            DataTable _dataTable = GetOrganizations(con, sortExpression, whereClause);

            GridView1.DataSource = _dataTable;
            GridView1.DataBind();
        }

        private DataTable GetOrganizations(SqlConnection con, string sortExpression, string whereClause)
        {
            string _sqlStatement = @"
            select	DISTINCT
	            O.id
	            ,O.[name]
                ,O.[active]
            from 
	            TimeKeeper.dbo.Organizations O
				LEFT JOIN TimeKeeper.dbo.Organization_Clients OC
					ON OC.organizationID = O.id 
            where 
                O.[name] != 'All Clients'
                and O.active = 1
				and O.canBeAClient = 1"
                ;

            if (!string.IsNullOrEmpty(whereClause))
            {
                _sqlStatement += " AND [name] like @Name";
            }

            if (!string.IsNullOrEmpty(sortExpression))
            {
                if (HiddenFieldSortOrder.Value.Equals("ASC"))
                {
                    HiddenFieldSortOrder.Value = "DESC";
                }
                else
                {
                    HiddenFieldSortOrder.Value = "ASC";
                }
            }

            _sqlStatement += " order by [name] " + HiddenFieldSortOrder.Value;

            DataTable _dataTable = new DataTable();
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Name", "%" + whereClause + "%");
            _sqlDataAdapter.Fill(_dataTable);

            return _dataTable;
        }
        protected void GridView1_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            ButtonAdd.Visible = true;
            GridView1.EditIndex = -1;
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                PopulateOrganizationGrid(_con, string.Empty, string.Empty);
            }
        }

        private void MakeOrganization(string organizationId)
        {
            ButtonAdd.Visible = false;

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                string _sqlStatement = @"
                update TimeKeeper.dbo.Organizations
                set active = 1
                where id = @Id";

                _con.Open();

                SqlCommand _sqlcommand = new SqlCommand(_sqlStatement, _con);
                _sqlcommand.Parameters.AddWithValue("@Id", organizationId);
                _sqlcommand.ExecuteScalar();

                GridView1.EditIndex = -1;
                ButtonAdd.Visible = true;
                PopulateOrganizationGrid(_con, string.Empty, string.Empty);
            }
        }
        protected void GridView1_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            string _confirmDelete = Request.Form["confirm_value"];
            if (_confirmDelete != "Yes")
            {
                return;
            }

            ButtonAdd.Visible = false;

            HiddenField OrganizationId = (HiddenField)GridView1.Rows[e.RowIndex].FindControl("OrganizationId");

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                string _sqlStatement = @"
                update TimeKeeper.dbo.Organizations
                set active = 0
                where id = @Id";

                _con.Open();

                SqlCommand _sqlcommand = new SqlCommand(_sqlStatement, _con);
                _sqlcommand.Parameters.AddWithValue("@Id", OrganizationId.Value);
                _sqlcommand.ExecuteScalar();

                GridView1.EditIndex = -1;
                ButtonAdd.Visible = true;
                PopulateOrganizationGrid(_con, string.Empty, string.Empty);
            }

        }
        protected void GridView1_RowEditing(object sender, GridViewEditEventArgs e)
        {
            ButtonAdd.Visible = false;
            GridView1.EditIndex = e.NewEditIndex;

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                PopulateOrganizationGrid(_con, string.Empty, string.Empty);
            }

            Button ButtonInsert = (Button)GridView1.Rows[e.NewEditIndex].FindControl("ButtonInsert");
            ButtonInsert.Visible = false;

        }
        protected void GridView1_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            string _confirmDelete = Request.Form["confirm_value"];
            if (_confirmDelete != "Yes")
            {
                return;
            }

            HiddenField OrganizationEditId = (HiddenField)GridView1.Rows[e.RowIndex].FindControl("OrganizationEditId");
            TextBox TextBoxOrganization = (TextBox)GridView1.Rows[e.RowIndex].FindControl("TextBoxOrganization");

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                string _sqlStatement = @"
                update TimeKeeper.dbo.Organizations
                set name = @Name
                where id = @Id";

                _con.Open();

                SqlCommand _sqlcommand = new SqlCommand(_sqlStatement, _con);
                _sqlcommand.Parameters.AddWithValue("@Name", TextBoxOrganization.Text);
                _sqlcommand.Parameters.AddWithValue("@Id", OrganizationEditId.Value);
                _sqlcommand.ExecuteScalar();

                GridView1.EditIndex = -1;
                ButtonAdd.Visible = true;
                PopulateOrganizationGrid(_con, string.Empty, string.Empty);
            }
        }
        protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName.Equals("Add"))
            {
                string _confirmDelete = Request.Form["confirm_value"];
                if (_confirmDelete != "Yes")
                {
                    return;
                }

                GridViewRow _gvr = (GridViewRow)(((Button)e.CommandSource).NamingContainer);
                TextBox TextBoxOrganization = (TextBox)_gvr.FindControl("TextBoxOrganization");

                InsertOrganization(TextBoxOrganization.Text);
            }
            else if (e.CommandName.Equals("Active"))
            {
                string _confirmDelete = Request.Form["confirm_value"];
                if (_confirmDelete != "Yes")
                {
                    return;
                }

                GridViewRow _gvr = (GridViewRow)(((Button)e.CommandSource).NamingContainer);
                HiddenField OrganizationId = (HiddenField)_gvr.FindControl("OrganizationId");
                MakeOrganization(OrganizationId.Value);
            }
        }

        private long InsertOrganization(string name)
        {
            long _orgId = 0;

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _orgId = InsertClient(name, _con);
            }

            return _orgId;
        }

        private long InsertClient(string name, SqlConnection con)
        {
            string _sqlStatement = @"
                insert into TimeKeeper.dbo.Organizations
                (
	                [name]
                    ,[canBeAClient]
                )
                values
                (
	                @Name
                    ,1
                );
                select SCOPE_IDENTITY();";

            if (con.State != ConnectionState.Open)
            {
                con.Open();
            }

            SqlCommand _sqlcommand = new SqlCommand(_sqlStatement, con);
            _sqlcommand.Parameters.AddWithValue("@Name", name);

            object _id = _sqlcommand.ExecuteScalar();

            ButtonAdd.Visible = true;
            GridView1.EditIndex = -1;

            PopulateOrganizationGrid(con, string.Empty, string.Empty);

            return long.Parse(_id.ToString());
        }
        protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            try
            {
                if (e.Row.RowType == DataControlRowType.DataRow)
                {
                    DataRow _dataRow = ((DataRowView)e.Row.DataItem).Row;

                    Button ButtonACtivate = (Button)e.Row.FindControl("ButtonACtivate");
                    Button ButtonDelete = (Button)e.Row.FindControl("ButtonDelete");

                    if (bool.Parse(_dataRow["active"].ToString()))
                    {
                        ButtonACtivate.Visible = false;
                        ButtonDelete.Visible = true;
                    }
                    else
                    {
                        ButtonACtivate.Visible = true;
                        ButtonDelete.Visible = false;
                    }
                }
            }
            catch
            {

            }
        }

        protected void GridView1_Sorting(object sender, GridViewSortEventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                PopulateOrganizationGrid(_con, e.SortExpression, string.Empty);
            }
        }
        protected void ButtonAdd_Click(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                DataTable _dataTable = GetOrganizations(_con, string.Empty, string.Empty);

                _dataTable.Rows.InsertAt(_dataTable.NewRow(), 0);

                GridView1.EditIndex = 0;
                GridView1.DataSource = _dataTable;
                GridView1.DataBind();

                GridViewRow _gridRow = GridView1.Rows[0];

                HiddenField OrganizationEditId = (HiddenField)_gridRow.FindControl("OrganizationEditId");
                OrganizationEditId.Value = "0";

                Button _buttonUpdate = (Button)_gridRow.FindControl("ButtonUpdate");

                _buttonUpdate.Visible = false;
                ButtonAdd.Visible = false;
            }

        }

        protected void ButtonSearch_Click(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                PopulateOrganizationGrid(_con, string.Empty, TextBoxSearch.Text);
            }
        }

        protected void ButtonRemoveSearch_Click(object sender, EventArgs e)
        {
            TextBoxSearch.Text = string.Empty;
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                PopulateOrganizationGrid(_con, string.Empty, TextBoxSearch.Text);
            }
        }

        protected void ButtonSpedmonSync_Click(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                List<SpedmonClient> _spedmonClients = GetSpedmonClients(_con);

                long _orgId = 0;

                foreach (SpedmonClient _spedmonClient in _spedmonClients)
                {
                    if (!ClientPresentInTimeKeeper(_spedmonClient, _con))
                    {
                        _orgId = InsertClient(_spedmonClient.ClientName, _con);
                        InsertReferenceRecord(_orgId.ToString(), _spedmonClient, _con);
                    }
                }
                ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(),
                    "Spedmon Client has been synced",
                    "alert('Spedmon Sync completed.');",
                    true);
            }
        }
        private void InsertReferenceRecord(string id, SpedmonClient spedmonClient, SqlConnection con)
        {
            string _sqlStatement = @"
            insert into TimeKeeper.dbo.OrganizationSpedmonClientReference
            (
                OrganizationId
                ,SpedmonClientId
            )
            values
            (
                @OrganizationId
                ,@SpedmonClientId
            )";

            SqlCommand _sqlcommand = new SqlCommand(_sqlStatement, con);
            _sqlcommand.Parameters.AddWithValue("@OrganizationId", id);
            _sqlcommand.Parameters.AddWithValue("@SpedmonClientId", spedmonClient.Id.ToString());
            _sqlcommand.ExecuteScalar();
        }

        private bool ClientPresentInTimeKeeper(SpedmonClient spedmonClient, SqlConnection con)
        {
            string _sqlStatement = @"
            select
	            [id]
            from
                TimeKeeper.dbo.Organizations
            where
                name = @Name
                and active = 1";

            DataTable _dataTable = new DataTable();
            SqlDataAdapter _sqlAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlAdapter.SelectCommand.Parameters.AddWithValue("@Name", spedmonClient.ClientName);
            _sqlAdapter.Fill(_dataTable);

            if (_dataTable.Rows.Count == 0)
            {
                return false;
            }

            UpdateReferenceIfNeeded(_dataTable.Rows[0]["id"].ToString(), spedmonClient, con);

            return true;
        }

        private void UpdateReferenceIfNeeded(string id, SpedmonClient spedmonClient, SqlConnection con)
        {
            string _sqlStatement = @"
            select
                OrganizationId
                ,SpedmonClientId
            from
	            TimeKeeper.dbo.OrganizationSpedmonClientReference
            where
	            OrganizationId = @Id";

            DataTable _dataTable = new DataTable();
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", id);
            _sqlDataAdapter.Fill(_dataTable);

            if (_dataTable.Rows.Count == 0)
            {
                InsertReferenceRecord(id, spedmonClient, con);
                return;
            }

            if (long.Parse(_dataTable.Rows[0]["SpedmonClientId"].ToString()) != spedmonClient.Id)
            {
                UpdateReferenceRecord(id, spedmonClient, con);
            }
        }
        private void UpdateReferenceRecord(string id, SpedmonClient spedmonClient, SqlConnection con)
        {
            string _sqlStatement = @"
            update 
                TimeKeeper.dbo.OrganizationSpedmonClientReference
            set
                OrganizationId = @OrganizationId
                ,SpedmonClientId = @SpedmonClientId
            where
                OrganizationId = @Id";

            SqlCommand _sqlcommand = new SqlCommand(_sqlStatement, con);
            _sqlcommand.Parameters.AddWithValue("@OrganizationId", id);
            _sqlcommand.Parameters.AddWithValue("@SpedmonClientId", spedmonClient.Id.ToString());
            _sqlcommand.Parameters.AddWithValue("@Id", id);
            _sqlcommand.ExecuteScalar();
        }

        private List<SpedmonClient> GetSpedmonClients(SqlConnection con)
        {
            List<SpedmonClient> _spedmonClients = new List<SpedmonClient>();
            string _sqlStatement = @"
            select
	            CLIENT_ID
	            ,CLIENT_NAME
            from
	            SPEDMON.dbo.CLIENTS_Client
            ";

            DataTable _dataTable = new DataTable();
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.Fill(_dataTable);

            SpedmonClient _spedmonClient = null;
            foreach (DataRow _dataRow in _dataTable.Rows)
            {
                _spedmonClient = new SpedmonClient();
                _spedmonClient.Id = long.Parse(_dataRow["CLIENT_ID"].ToString());
                _spedmonClient.ClientName = _dataRow["CLIENT_NAME"].ToString();

                _spedmonClients.Add(_spedmonClient);
            }

            return _spedmonClients;
        }

    }
}