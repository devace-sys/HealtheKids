using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;

namespace Spedmon
{
     public partial class TimeEntryExceptions : WebUI
     {
          public TimeEntryExceptions()
               : base("timeentry", WebUI.CreatePageSubTitle("Time Entry Exceptions", "Create or Edit exceptions of the Time Keeper system"), "", "", Constants.ROLE_SBS_ALL)
          { 
          }

          protected void Page_Load(object sender, EventArgs e)
          {
               if (!IsPostBack)
               {
                    PopulateGridView();
               }
          }

          private void PopulateGridView(SqlConnection con)
          {
               string _sqlStatement = @"
                select 
	                TEE.id
	                ,TEE.name
	                ,TEE.description
	                ,case
		                when TEE.type = 0 THEN 'Warning'
		                else 'Error' 
	                 end AS 'type'
	                 ,case
		                when TEE.system = 0 then 'Schedule'
		                else 'Time Entry'
	                  end AS 'system'
	                 ,case
		                when TEE.doesFLSAapply = 0 then 'No'
		                else 'Yes'
	                  end as doesFLSAapply
	                 ,case
		                when TEE.granularity = 0 then 'None Specified'
		                when TEE.granularity = 1 then 'Weekly'
		                when TEE.granularity = 2 then 'Daily'
		                else 'Record Instance' -- 3
	                  end as granularity
	                 ,TEE.minutes
	                 ,TEE.hours
	                 ,TEE.days
	                 ,TEE.message
	                 ,TEE.timeEntryTaskId
	                 ,ISNULL(TET.name, '') as TaskName
                from
	                TimeKeeper.dbo.TimeEntryExceptions TEE
	                left join TimeKeeper.dbo.TimeEntry_Tasks TET
		                ON TET.id = TEE.timeEntryTaskId";

               SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
               DataTable _dataTable = new DataTable();
               _sqlDataAdapter.Fill(_dataTable);

               GridView1.DataSource = _dataTable;
               GridView1.DataBind();

          }

          private void PopulateGridView()
          {
               using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
               {
                    PopulateGridView(_con);
               }
          }

          protected void PopulateExclusions(string id, string name, SqlConnection con)
          {
               LabelExceptionName.Text = "Exclusions for the exception '" + name + "'";
               string _sqlStatement = @"
            select
	            P.firstName
	            ,P.lastName
	            ,case 
		            when TEEE.action = 0 then 'no action'
		            when TEEE.action = 1 then 'email supervisor'
		            when TEEE.action = 2 then 'email next level supervisor'
	             end as [action]
            from
	            TimeKeeper.dbo.People P
	            inner join TimeKeeper.dbo.Employees E
		            on E.personID = P.id
	            inner join TimeKeeper.dbo.TimeEntryExceptionsExclusions TEEE
		            on TEEE.employeeId = E.id
	            inner join TimeKeeper.dbo.TimeEntryExceptions TEE
		            on TEE.id = TEEE.timeEntryExceptionId
            where
	            TEE.id = @Id";

               SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", id);
               DataTable _dataTable = new DataTable();
               _sqlDataAdapter.Fill(_dataTable);

               GridView2.DataSource = _dataTable;
               GridView2.DataBind();


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

               HiddenField HiddenFieldTimeEntryId = (HiddenField)GridView1.Rows[e.RowIndex].FindControl("HiddenFieldTimeEntryId");

               using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
               {
                    string _sqlStatement = @"
                delete from TimeKeeper.dbo.TimeEntryExceptions
                where id = @Id";

                    _con.Open();

                    SqlCommand _sqlcommand = new SqlCommand(_sqlStatement, _con);
                    _sqlcommand.Parameters.AddWithValue("@Id", HiddenFieldTimeEntryId.Value);
                    _sqlcommand.ExecuteScalar();

                    PopulateGridView(_con);
               }
          }
          protected void GridView1_RowEditing(object sender, GridViewEditEventArgs e)
          {
               HiddenField HiddenFieldTimeEntryId = (HiddenField)GridView1.Rows[e.NewEditIndex].FindControl("HiddenFieldTimeEntryId");
               string _url = MBA.HttpApplication.createLink("AddEditTimeEntryException.aspx", true) + "&id=" + HiddenFieldTimeEntryId.Value;
               Response.Redirect(_url);

          }
          protected void GridView1_RowUpdating(object sender, GridViewUpdateEventArgs e)
          {
          }
          protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
          {
               if (e.CommandName.Equals("Exclusions"))
               {
                    using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                    {
                         GridViewRow _gvr = (GridViewRow)(((Button)e.CommandSource).NamingContainer);
                         HiddenField HiddenFieldTimeEntryId = (HiddenField)_gvr.FindControl("HiddenFieldTimeEntryId");
                         Label LabelNameOfException = (Label)_gvr.FindControl("LabelNameOfException");

                         PopulateExclusions(HiddenFieldTimeEntryId.Value, LabelNameOfException.Text, _con);
                    }
               }
          }
          protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
          {
          }
          protected void GridView1_Sorting(object sender, GridViewSortEventArgs e)
          {

          }

          protected void GridView2_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
          {

          }
          protected void GridView2_RowDeleting(object sender, GridViewDeleteEventArgs e)
          {

          }
          protected void GridView2_RowEditing(object sender, GridViewEditEventArgs e)
          {
          }
          protected void GridView2_RowUpdating(object sender, GridViewUpdateEventArgs e)
          {
          }
          protected void GridView2_RowCommand(object sender, GridViewCommandEventArgs e)
          {
          }
          protected void GridView2_RowDataBound(object sender, GridViewRowEventArgs e)
          {
          }
          protected void GridView2_Sorting(object sender, GridViewSortEventArgs e)
          {

          }

          protected void ButtonAdd_Click(object sender, EventArgs e)
          {
               string _url = MBA.HttpApplication.createLink("AddEditTimeEntryException.aspx", true) + "&id=0";
               Response.Redirect(_url);
          }
     }
}
