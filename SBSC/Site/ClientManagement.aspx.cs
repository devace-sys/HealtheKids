using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using MBA.BitteTime;
using System.Text;

namespace Spedmon
{
    public partial class ClientManagement : WebUI
    {
        public ClientManagement()
            : base("timeentry", WebUI.CreatePageSubTitle("Client Management", "Create or Edit clients of Time Keeper"), "", "", Constants.ROLE_SBS_ALL)
        {
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                try
                {
                    using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                    {
                        PopulateHeader(_con);
                        PopulateGridInfo(_con, string.Empty, string.Empty);
                    }
                }
                catch (Exception _exception)
                {
                    string _url = MBA.HttpApplication.createLink("OranizationManagement.aspx", true);
                    Response.Redirect(_url, true);
                }
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
                @Id
                ,@SpedmonClient
            )";

            SqlCommand _sqlcommand = new SqlCommand(_sqlStatement, con);
            _sqlcommand.Parameters.AddWithValue("@Id", id);
            _sqlcommand.Parameters.AddWithValue("@SpedmonClient", spedmonClient.Id.ToString());

            _sqlcommand.ExecuteScalar();
        }

        private void UpdateReferenceRecord(string id, SpedmonClient spedmonClient, SqlConnection con)
        {
            string _sqlStatement = @"
            update 
                TimeKeeper.dbo.OrganizationSpedmonClientReference
            set
                OrganizationId = @OrganizationId
                ,SpedmonClientId = @SpedmonId
            where
                OrganizationId = @WhereOrganizationId";

            SqlCommand _sqlcommand = new SqlCommand(_sqlStatement, con);
            _sqlcommand.Parameters.AddWithValue("@OrganizationId", id);
            _sqlcommand.Parameters.AddWithValue("@SpedmonId", spedmonClient.Id.ToString());
            _sqlcommand.Parameters.AddWithValue("@WhereOrganizationId", id);
            _sqlcommand.ExecuteScalar();
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

            PopulateGridInfo(con, string.Empty, string.Empty);

            return long.Parse(_id.ToString());
        }

        private bool ClientPresentInTimeKeeper(SpedmonClient spedmonClient, SqlConnection con)
        {
            string _sqlStatement = @"
            select
	            [id]
            from
                TimeKeeper.dbo.Organizations
            where
                name = @ClientName
                and active = 1";

            DataTable _dataTable = new DataTable();
            SqlDataAdapter _sqlAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlAdapter.SelectCommand.Parameters.AddWithValue("@ClientName", spedmonClient.ClientName);
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
	            OrganizationId = " + id;

            DataTable _dataTable = new DataTable();
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
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

        private void PopulateGridInfo(SqlConnection con, string sortExpression, string whereClause)
        {
            if (int.Parse(HiddenFieldOrganizationId.Value) <= 0)
            {
                string _url = MBA.HttpApplication.createLink("OranizationManagement.aspx", true);
                Response.Redirect(_url, true);
                return;
            }
            DataTable _dataTable = GetOrganizationClients(con, sortExpression, whereClause);

            GridView1.DataSource = _dataTable;
            GridView1.DataBind();

        }

        private void PopulateHeader(SqlConnection con)
        {
            HiddenFieldOrganizationId.Value = Request.QueryString["id"].ToString();

            string _sqlStatement = @"
            select	
	            id
	            ,[name] 
            from 
	            TimeKeeper.dbo.Organizations
            where
                id = @Id";

            DataTable _dataTable = new DataTable();
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", HiddenFieldOrganizationId.Value);
            _sqlDataAdapter.Fill(_dataTable);

            DataRow _dataRow = _dataTable.Rows[0];

            LabelOrganization.Text = "<h3>Clients for " + _dataRow["name"].ToString() + "</h3>";

        }

        private DataTable GetOrganizationClients(SqlConnection con, string sortExpression, string whereClause)
        {
            string _sqlStatement = @"
            SELECT 
	            OC.[organizationID]
                ,OC.[clientOrganizationID]
	            ,O.[name] as organization
	            ,C.[name] as client
            FROM 
	            [TimeKeeper].[dbo].[Organization_Clients] OC
	            INNER JOIN TimeKeeper.dbo.Organizations O
		            ON O.id = OC.organizationID
	            INNER JOIN TimeKeeper.dbo.Organizations C
		            ON C.id = OC.clientOrganizationID
            WHERE 
                OC.[organizationID] = @OrganizationID
                AND O.active = 1
                AND C.active = 1";

            // HiddenFieldOrganizationId.Value + @"

            if (!string.IsNullOrEmpty(whereClause))
            {
                _sqlStatement += " AND C.[name] like @NameLike";
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

            _sqlStatement += " order by C.[name] " + HiddenFieldSortOrder.Value;

            DataTable _dataTable = new DataTable();
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@OrganizationID", HiddenFieldOrganizationId.Value);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@NameLike", "%" + whereClause + "%");


            _sqlDataAdapter.Fill(_dataTable);

            return _dataTable;
        }

        protected void ButtonAdd_Click(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                if (NumberOfClientsLeft(_con) == 0)
                {
                    ClientScriptManager cs = Page.ClientScript;
                    StringBuilder cstext1 = new StringBuilder();
                    String csname1 = "No More Clients";
                    Type cstype = this.GetType();

                    cstext1.Append("<script type=text/javascript> alert('All clients have been assigned') </");
                    cstext1.Append("script>");
                    cs.RegisterStartupScript(cstype, csname1, cstext1.ToString());
                    return;
                }

                DataTable _dataTable = GetOrganizationClients(_con, string.Empty, string.Empty);

                _dataTable.Rows.InsertAt(_dataTable.NewRow(), 0);

                GridView1.EditIndex = 0;
                GridView1.DataSource = _dataTable;
                GridView1.DataBind();

                GridViewRow _gridRow = GridView1.Rows[0];

                HiddenField ClientOrganizationEditId = (HiddenField)_gridRow.FindControl("ClientOrganizationEditId");
                ClientOrganizationEditId.Value = "0";

                Button _buttonUpdate = (Button)_gridRow.FindControl("ButtonUpdate");

                _buttonUpdate.Visible = false;
                ButtonAdd.Visible = false;

                DropDownList DropDownListOrganizations = (DropDownList)_gridRow.FindControl("DropDownListOrganizations");
                PopulateDropDownList(_con, DropDownListOrganizations);
            }

        }

        private int NumberOfClientsLeft(SqlConnection con)
        {
            string _sqlStatement = @"
            select
	            count(*) as NumberClients
            from
	            TimeKeeper.dbo.Organizations
            where
	            id != @Id
	            and [name] != 'All Clients' 
                and active = 1
                and id not in
                (
                    SELECT 
                        [clientOrganizationID] as NumberClients
                    FROM 
	                    [TimeKeeper].[dbo].[Organization_Clients] 
                    WHERE 
                        [organizationID] = @OrganizationId
                )
                and canBeAClient = 1";

            DataTable _dataTable = new DataTable();
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", HiddenFieldOrganizationId.Value);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@OrganizationId", HiddenFieldOrganizationId.Value);

            _sqlDataAdapter.Fill(_dataTable);

            return int.Parse(_dataTable.Rows[0]["NumberClients"].ToString());
        }

        private void PopulateDropDownList(SqlConnection con, DropDownList DropDownListOrganizations)
        {
            string _sqlStatement = @"
            select
	            id
                ,name
            from
	            TimeKeeper.dbo.Organizations
            where
	            id != @Id
	            and [name] != 'All Clients' 
                and active = 1
                and id not in
                (
                    SELECT 
                        [clientOrganizationID]
                    FROM 
	                    [TimeKeeper].[dbo].[Organization_Clients] 
                    WHERE 
                        [organizationID] = @OrganizationId
                )
                and canBeAClient = 1
            order by [name]";

            DataTable _dataTable = new DataTable();
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", HiddenFieldOrganizationId.Value);
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@OrganizationId", HiddenFieldOrganizationId.Value);
            _sqlDataAdapter.Fill(_dataTable);

            DropDownListOrganizations.DataTextField = "name";
            DropDownListOrganizations.DataValueField = "id";
            DropDownListOrganizations.DataSource = _dataTable;
            DropDownListOrganizations.DataBind();
        }

        protected void GridView1_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            ButtonAdd.Visible = true;
            GridView1.EditIndex = -1;
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                PopulateGridInfo(_con, string.Empty, string.Empty);
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

            HiddenField ClientOrganizationId = (HiddenField)GridView1.Rows[e.RowIndex].FindControl("ClientOrganizationId");

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                string _sqlStatement = @"
                delete from [TimeKeeper].[dbo].[Organization_Clients] 
                where organizationID = @OrganizationID
                    and clientOrganizationID = @ClientOrganizationID";

                _con.Open();

                SqlCommand _sqlcommand = new SqlCommand(_sqlStatement, _con);
                _sqlcommand.Parameters.AddWithValue("@OrganizationID", HiddenFieldOrganizationId.Value);
                _sqlcommand.Parameters.AddWithValue("@ClientOrganizationID", ClientOrganizationId.Value);
                _sqlcommand.ExecuteScalar();

                GridView1.EditIndex = -1;
                ButtonAdd.Visible = true;
                PopulateGridInfo(_con, string.Empty, string.Empty);
            }

        }
        protected void GridView1_RowEditing(object sender, GridViewEditEventArgs e)
        {
            /*
            HiddenField HiddenFieldExclusionId = (HiddenField)GridView1.Rows[e.NewEditIndex].FindControl("HiddenFieldExclusionId");
            ButtonAdd.Visible = false;
            HiddenFieldEditRowIndex.Value = e.NewEditIndex.ToString();
            GridView1.EditIndex = e.NewEditIndex;

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                PopulateExclusions(_con);
            }
            */
        }
        protected void GridView1_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
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
                DropDownList DropDownListOrganizations = (DropDownList)_gvr.FindControl("DropDownListOrganizations");

                InsertClientOrganization(DropDownListOrganizations);
            }
        }
        protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
        {
        }
        protected void GridView1_Sorting(object sender, GridViewSortEventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                PopulateGridInfo(_con, e.SortExpression, string.Empty);
            }
        }

        private void InsertClientOrganization(DropDownList DropDownListOrganizations)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                string _sqlStatement = @"
                insert into [TimeKeeper].[dbo].[Organization_Clients] 
                (
	                [organizationID]
                    ,[clientOrganizationID]
                )
                values
                (
	                @OrganizationID
                    ,@ClientOrganizationID
                );";

                _con.Open();

                SqlCommand _sqlcommand = new SqlCommand(_sqlStatement, _con);
                _sqlcommand.Parameters.AddWithValue("@OrganizationID", HiddenFieldOrganizationId.Value);
                _sqlcommand.Parameters.AddWithValue("@ClientOrganizationID", DropDownListOrganizations.SelectedValue);

                object _id = _sqlcommand.ExecuteScalar();

                ButtonAdd.Visible = true;
                GridView1.EditIndex = -1;

                PopulateGridInfo(_con, string.Empty, string.Empty);
            }
        }



        protected void ButtonBack_Click(object sender, EventArgs e)
        {
            string _url = MBA.HttpApplication.createLink("OranizationManagement.aspx", true);
            Response.Redirect(_url, true);
        }

        protected void ButtonSearch_Click(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                PopulateGridInfo(_con, string.Empty, TextBoxSearch.Text);
            }
        }

        protected void ButtonRemoveSearch_Click(object sender, EventArgs e)
        {
            TextBoxSearch.Text = string.Empty;
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                PopulateGridInfo(_con, string.Empty, TextBoxSearch.Text);
            }
        }
    }
}
