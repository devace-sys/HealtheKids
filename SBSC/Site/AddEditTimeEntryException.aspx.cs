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
     public partial class AddEditTimeEntryException : WebUI
     {
          public AddEditTimeEntryException()
               : base("timeentry", WebUI.CreatePageSubTitle("Time Entry Exception Management", "Create or Edit exceptions related to Time Keeper"), "", "", Constants.ROLE_SBS_ALL)
          { 
          }

          protected void Page_Load(object sender, EventArgs e)
          {
               if (!IsPostBack)
               {
                    HiddenFieldExceptionID.Value = long.Parse(Request.QueryString["id"]).ToString();

                    if (HiddenFieldExceptionID.Value == "0")
                    {
                         PanelExclusionList.Visible = false;
                    }
                    SetUpPage();
               }
          }

          private void SetUpPage()
          {
               try
               {
                    using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                    {
                         PopulateTaskDropDownList(_con);
                         if (HiddenFieldExceptionID.Value == "0")
                         {
                              ButtonAddUpdateException.Text = "Add Exception";
                         }
                         else
                         {
                              ButtonAddUpdateException.Text = "Update Exception";
                              PopulateExceptionInfo(_con);
                         }
                    }
               }
               catch
               {
                    string _url = MBA.HttpApplication.createLink("TimeEntryExceptions.aspx", true);
                    Response.Redirect(_url);
               }
          }

          private void PopulateTaskDropDownList(SqlConnection con)
          {
               string _sqlStatement = @"
            select 
	            id
	            ,name
            from
	            TimeKeeper.dbo.TimeEntry_Tasks";

               SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
               DataTable _dataTable = new DataTable();
               _sqlDataAdapter.Fill(_dataTable);

               DropDownListTask.DataTextField = "name";
               DropDownListTask.DataValueField = "id";
               DropDownListTask.DataSource = _dataTable;
               DropDownListTask.DataBind();

               ListItem _item = new ListItem();
               _item.Text = "No Task Selected";
               _item.Value = "-1";
               DropDownListTask.Items.Insert(0, _item);
               DropDownListTask.SelectedIndex = 0;

          }

          private void PopulateExceptionInfo(SqlConnection con)
          {
               string _sqlStatement = @"
            select 
	            TEE.id
	            ,TEE.name
	            ,TEE.description
	            ,TEE.type
	            ,TEE.system
	            ,TEE.doesFLSAapply
	            ,TEE.granularity
	            ,TEE.minutes
	            ,TEE.hours
	            ,TEE.days
	            ,TEE.message
	            ,TEE.timeEntryTaskId
	            ,TET.id as taskId
            from
	            TimeKeeper.dbo.TimeEntryExceptions TEE
	            left join TimeKeeper.dbo.TimeEntry_Tasks TET
		            ON TET.id = TEE.timeEntryTaskId
            where
	            TEE.id = @id";

               SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
               _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@id", HiddenFieldExceptionID.Value);

               DataTable _dataTable = new DataTable();
               _sqlDataAdapter.Fill(_dataTable);

               if (_dataTable.Rows.Count == 1)
               {
                    DataRow _dataRow = _dataTable.Rows[0];

                    TextBoxExceptionName.Text = _dataRow["name"].ToString();
                    TextBoxExceptionDescription.Text = _dataRow["description"].ToString();
                    DropDownListType.SelectedValue = _dataRow["type"].ToString();
                    DropDownListSystem.SelectedValue = _dataRow["system"].ToString();

                    CheckBoxFLSA.Checked = bool.Parse(_dataRow["doesFLSAapply"].ToString());

                    string[] _value = null;
                    DropDownListGranularity.SelectedValue = _dataRow["granularity"].ToString();

                    if (_dataRow.IsNull("minutes"))
                    {
                         DropDownListMinutes.SelectedValue = "-1";
                         DropDownListMinutesOperator.SelectedValue = "-1";
                    }
                    else
                    {
                         _value = _dataRow["minutes"].ToString().Split(' ');
                         DropDownListMinutes.SelectedValue = _value[0].Trim();
                         DropDownListMinutesOperator.SelectedValue = _value[1].Trim();
                    }

                    if (_dataRow.IsNull("hours"))
                    {
                         DropDownListHours.SelectedValue = "-1";
                         DropDownListHoursOperator.SelectedValue = "-1";
                    }
                    else
                    {
                         _value = _dataRow["hours"].ToString().Split(' ');
                         DropDownListHours.SelectedValue = _value[0].Trim();
                         DropDownListHoursOperator.SelectedValue = _value[1].Trim();
                    }

                    if (_dataRow.IsNull("days"))
                    {
                         DropDownListDays.SelectedValue = "-1";
                         DropDownListDaysOperator.SelectedValue = "-1";
                    }
                    else
                    {
                         _value = _dataRow["days"].ToString().Split(' ');
                         DropDownListDays.SelectedValue = _value[0].Trim();
                         DropDownListDaysOperator.SelectedValue = _value[1].Trim();
                    }

                    if (!_dataRow.IsNull("taskId"))
                    {
                         DropDownListTask.SelectedValue = _dataRow["taskId"].ToString();
                    }
               }

               PopulateExclusions(con);
          }

          private void PopulateExclusions(SqlConnection con)
          {
               string _sqlStatement = @"
            select
	            TEEE.id
	            ,P.firstName
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
	            TEE.id = @id";

               SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
              _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@id", HiddenFieldExceptionID.Value);

               DataTable _dataTable = new DataTable();
               _sqlDataAdapter.Fill(_dataTable);

               GridView1.DataSource = _dataTable;
               GridView1.DataBind();

               string _remove = string.Empty;
               List<string> _idsNotToInclude = new List<string>();

               foreach (DataRow _dataRow in _dataTable.Rows)
               {
                    _idsNotToInclude.Add(_dataRow["id"].ToString());
                    if (!string.IsNullOrEmpty(_remove))
                    {
                         _remove += ",";
                    }
                    _remove += "@Id" + _idsNotToInclude.Count.ToString();
               }
               PopulateEmployeeDropDownList(_remove, con, _idsNotToInclude);
          }

          private void PopulateEmployeeDropDownList(string remove, SqlConnection con, List<string> idsNotToInclude)
          {
               string _sqlStatement = @"
            select
	            E.id
	            ,P.firstName + ' ' + P.lastName as EmployeeName
            from
	            TimeKeeper.dbo.People P
	            inner join TimeKeeper.dbo.Employees E
		            on E.personID = P.id";

               if (!string.IsNullOrEmpty(remove))
               {
                    _sqlStatement += @"
                where
	                E.id not in
	                (
		                " + remove + @"
	                )";
               }

               SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
               int _index = 1;
               foreach(string _ids in idsNotToInclude)
               {
                    _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id" + _index.ToString(), _ids);
                    ++_index;
               }

               DataTable _dataTable = new DataTable();
               _sqlDataAdapter.Fill(_dataTable);

               DropDownListEmployee.DataValueField = "id";
               DropDownListEmployee.DataTextField = "EmployeeName";
               DropDownListEmployee.DataSource = _dataTable;
               DropDownListEmployee.DataBind();

               ListItem _item = new ListItem();
               _item.Text = " -- Select an Employee ---";
               _item.Value = "-1";

               DropDownListEmployee.Items.Insert(0, _item);
          }
          protected void ButtonAddUpdateException_Click(object sender, EventArgs e)
          {
               string _confirmDelete = Request.Form["confirm_value"];
               if (_confirmDelete != "Yes")
               {
                    return;
               }

               if (HiddenFieldExceptionID.Value == "0")
               {
                    InsertException();
               }
               else
               {
                    UpdateException();
               }
          }

          private void UpdateException()
          {
               using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
               {
                    string _sqlStatement = @"
                update TimeKeeper.dbo.TimeEntryExceptions
                set
	                [name] = @Name
	                ,[description] = @Description
	                ,[type] = @Type
	                ,[system] = @System
	                ,doesFLSAapply = @DoesFLSAApply
	                ,granularity = @Granularity
	                ,[minutes] = @Minutes
	                ,[hours] = @Hours
	                ,[days] = @Days
	                ,[message] = @Message
	                ,timeEntryTaskId = @TimeEntryTaskID
                where
                   id = @Id";

                    _con.Open();

                    SqlCommand _sqlcommand = new SqlCommand(_sqlStatement, _con);
                    _sqlcommand.Parameters.AddWithValue("@Name", TextBoxExceptionName.Text);
                    _sqlcommand.Parameters.AddWithValue("@Description", TextBoxExceptionDescription.Text);
                    _sqlcommand.Parameters.AddWithValue("@Type", DropDownListType.SelectedValue);
                    _sqlcommand.Parameters.AddWithValue("@System", DropDownListSystem.SelectedValue);
                    _sqlcommand.Parameters.AddWithValue("@DoesFLSAApply", CheckBoxFLSA.Checked);
                    _sqlcommand.Parameters.AddWithValue("@Granularity", DropDownListGranularity.SelectedValue);
                    _sqlcommand.Parameters.AddWithValue("@Minutes", (DropDownListMinutes.SelectedValue == "-1" ? string.Empty : "'" + DropDownListMinutes.SelectedValue + " " + DropDownListMinutesOperator.SelectedItem.Text + "'"));
                    _sqlcommand.Parameters.AddWithValue("@Hours", (DropDownListHours.SelectedValue == " - 1" ? string.Empty : "'" + DropDownListHours.SelectedValue + " " + DropDownListHoursOperator.SelectedItem.Text + "'"));
                    _sqlcommand.Parameters.AddWithValue("@Days", (DropDownListDays.SelectedValue == " - 1" ? string.Empty : "'" + DropDownListDays.SelectedValue + " " + DropDownListDaysOperator.SelectedItem.Text + "'"));
                    _sqlcommand.Parameters.AddWithValue("@Message", TextBoxMessage.Text);
                    _sqlcommand.Parameters.AddWithValue("@TimeEntryTaskID", (DropDownListTask.SelectedValue == "-1" ? string.Empty : DropDownListTask.SelectedValue));
                    _sqlcommand.Parameters.AddWithValue("@Id", HiddenFieldExceptionID.Value);
                    _sqlcommand.ExecuteScalar();

                    PanelExclusionList.Visible = true;

                    PopulateExclusions(_con);
               }
          }

          private void InsertException()
          {
               using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
               {
                    string _sqlStatement = @"
                insert into TimeKeeper.dbo.TimeEntryExceptions
                (
	                [name]
	                ,[description]
	                ,[type]
	                ,[system]
	                ,doesFLSAapply
	                ,granularity
	                ,[minutes]
	                ,[hours]
	                ,[days]
	                ,[message]
	                ,timeEntryTaskId
                )
                values
                (
	                @Name
	                ,@Description
	                ,@Type
	                ,@System
	                ,@DoesFLSAapply
	                ,@Granularity
	                ,@Minutes
	                ,@Hours
	                ,@Days
	                ,@Message
	                ,@TimeEntryTaskId
                );
                select SCOPE_IDENTITY();";

                    _con.Open();

                    SqlCommand _sqlcommand = new SqlCommand(_sqlStatement, _con);
                    _sqlcommand.Parameters.AddWithValue("@Name", TextBoxExceptionName.Text);
                    _sqlcommand.Parameters.AddWithValue("@Description", TextBoxExceptionDescription.Text);
                    _sqlcommand.Parameters.AddWithValue("@Type", DropDownListType.SelectedValue);
                    _sqlcommand.Parameters.AddWithValue("@System", DropDownListSystem.SelectedValue);
                    _sqlcommand.Parameters.AddWithValue("@DoesFLSAapply", CheckBoxFLSA.Checked);
                    _sqlcommand.Parameters.AddWithValue("@Granularity", DropDownListGranularity.SelectedValue);
                    _sqlcommand.Parameters.AddWithValue("@Minutes", (DropDownListMinutes.SelectedValue == " - 1" ? string.Empty : "'" + DropDownListMinutes.SelectedValue + " " + DropDownListMinutesOperator.SelectedItem.Text));
                    _sqlcommand.Parameters.AddWithValue("@Hours", (DropDownListHours.SelectedValue == " - 1" ? string.Empty : "'" + DropDownListHours.SelectedValue + " " + DropDownListHoursOperator.SelectedItem.Text + "'"));
                    _sqlcommand.Parameters.AddWithValue("@Days", (DropDownListDays.SelectedValue == " - 1" ? string.Empty : "'" + DropDownListDays.SelectedValue + " " + DropDownListDaysOperator.SelectedItem.Text + "'"));
                    _sqlcommand.Parameters.AddWithValue("@Message", TextBoxMessage.Text);
                    _sqlcommand.Parameters.AddWithValue("@TimeEntryTaskId", (DropDownListTask.SelectedValue == " - 1" ? string.Empty : DropDownListTask.SelectedValue));
                    
                    object _id = _sqlcommand.ExecuteScalar();

                    HiddenFieldExceptionID.Value = _id.ToString();

                    PanelExclusionList.Visible = true;

                    ButtonAddUpdateException.Text = "Update Exception";

                    PopulateExclusions(_con);
               }
          }

          protected void ButtonBack_Click(object sender, EventArgs e)
          {
               string _url = MBA.HttpApplication.createLink("TimeEntryExceptions.aspx", true);
               Response.Redirect(_url);

          }
          protected void GridView1_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
          {
               ButtonAdd.Visible = true;
               HiddenFieldEditRowIndex.Value = "-1";
               GridView1.EditIndex = -1;
               using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
               {
                    PopulateExclusions(_con);
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

               HiddenField _HiddenFieldExclusionId = (HiddenField)GridView1.Rows[e.RowIndex].FindControl("HiddenFieldExclusionId");

               using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
               {
                    string _sqlStatement = @"
                delete from TimeKeeper.dbo.TimeEntryExceptionsExclusions
                where id = @Id";

                    _con.Open();

                    SqlCommand _sqlcommand = new SqlCommand(_sqlStatement, _con);
                    _sqlcommand.Parameters.AddWithValue("@Id", _HiddenFieldExclusionId.Value);
                    _sqlcommand.ExecuteScalar();

                    GridView1.EditIndex = -1;
                    ButtonAdd.Visible = true;
                    PopulateExclusions(_con);
               }


          }
          protected void GridView1_RowEditing(object sender, GridViewEditEventArgs e)
          {
               HiddenField HiddenFieldExclusionId = (HiddenField)GridView1.Rows[e.NewEditIndex].FindControl("HiddenFieldExclusionId");
               ButtonAdd.Visible = false;
               HiddenFieldEditRowIndex.Value = e.NewEditIndex.ToString();
               GridView1.EditIndex = e.NewEditIndex;

               using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
               {
                    PopulateExclusions(_con);
               }
          }
          protected void GridView1_RowUpdating(object sender, GridViewUpdateEventArgs e)
          {
               string _confirmDelete = Request.Form["confirm_value"];
               if (_confirmDelete != "Yes")
               {
                    return;
               }

               DropDownList _DropDownListAction = (DropDownList)GridView1.Rows[e.RowIndex].FindControl("DropDownListAction");
               HiddenField _HiddenFieldExclusionIdEdit = (HiddenField)GridView1.Rows[e.RowIndex].FindControl("HiddenFieldExclusionIdEdit");

               using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
               {
                    string _sqlStatement = @"
                update TimeKeeper.dbo.TimeEntryExceptionsExclusions
                set action = @Action
                where id = @Id";

                    _con.Open();

                    SqlCommand _sqlcommand = new SqlCommand(_sqlStatement, _con);
                    _sqlcommand.Parameters.AddWithValue("@Action", _DropDownListAction.SelectedValue);
                    _sqlcommand.Parameters.AddWithValue("@Id", _HiddenFieldExclusionIdEdit.Value);
                    _sqlcommand.ExecuteScalar();

                    GridView1.EditIndex = -1;
                    ButtonAdd.Visible = true;
                    PopulateExclusions(_con);
               }


          }
          protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
          {
          }
          protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
          {
          }
          protected void GridView1_Sorting(object sender, GridViewSortEventArgs e)
          {

          }

          protected void ButtonAdd_Click(object sender, EventArgs e)
          {
               if (HiddenFieldExceptionID.Value == "0")
               {
                    PanelExclusionList.Visible = false;
                    return;
               }

               if (DropDownListEmployee.SelectedValue == "-1")
               {
                    return;
               }

               using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
               {
                    string _sqlStatement = @"
                insert into TimeKeeper.dbo.TimeEntryExceptionsExclusions
                (
	                timeEntryExceptionId
	                ,employeeId
	                ,action
                )
                values
                (
	                @TimeEntryExceptionID
	                ,@EmployeeID
	                ,@Action
                );
                select SCOPE_IDENTITY();";

                    _con.Open();

                    SqlCommand _sqlcommand = new SqlCommand(_sqlStatement, _con);
                    _sqlcommand.Parameters.AddWithValue("@TimeEntryExceptionID", HiddenFieldExceptionID.Value);
                    _sqlcommand.Parameters.AddWithValue("@EmployeeID", DropDownListEmployee.SelectedValue);
                    _sqlcommand.Parameters.AddWithValue("@Action", DropDownListAction.SelectedValue);

                object _id = _sqlcommand.ExecuteScalar();

                    PopulateExclusions(_con);
               }
          }
     }
}
