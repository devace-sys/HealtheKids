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
     public partial class TimeEntryTaskManagement : WebUI
     {
          enum TaskStatus
          {
               InActive = 0,
               Active = 1,
               All = 2
          }

          public TimeEntryTaskManagement()
               : base("timeentry", WebUI.CreatePageSubTitle("Task Management", "Manage tasks for Time Keeper System"), "", "", Constants.ROLE_SBS_ALL)
          { 
          }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                {
                    _con.Open();
                    PopulateTaskType(_con);
                    PopulateTaskGridView(string.Empty, _con, string.Empty);
                }
            }
        }

        private void PopulateTaskGridView(string taskType, SqlConnection con, string orderBy)
        {
            TaskStatus _taskStatus = TaskStatus.Active;
            if (RadioButtonInActive.Checked)
            {
                _taskStatus = TaskStatus.InActive;
            }
            else if (RadioButtonAll.Checked)
            {
                _taskStatus = TaskStatus.All;
            }

            PopulateTaskGridView(taskType, con, orderBy, _taskStatus);
        }
        protected void ButtonSearch_Click(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                TaskStatus _taskStatus = RadioButtonInActive.Checked ? TaskStatus.InActive : TaskStatus.All;

                string _taskType = DropDownListTaskType.SelectedValue == "0" ? string.Empty : DropDownListTaskType.SelectedValue;

                if (!string.IsNullOrEmpty(TextBoxSearch.Text.Trim()))
                {
                    PopulateTaskGridView(_taskType, _con, string.Empty, _taskStatus, TextBoxSearch.Text);
                }
            }
        }

        private void PopulateTaskGridView(string taskType, SqlConnection con, string orderBy, TaskStatus status, string taskName = "")
        {
            string _sqlStatement = @"
            SELECT
                TET.[id]
	            ,TET.[taskType]
	            ,TET.[name] AS taskName
                , ISNULL(TET.[defaultMinDuration], 0) AS defaultDuration
                 , ISNULL(TET.[defaultClient], 0) AS defaultClientId
	            ,Ttype.[name] AS taskTypeName
	            ,ISNULL(O.name, '') AS defaultClient
                ,TET.active AS IsActive
				,case 
					WHEN TET.IsProjectManagementRequired = 0 then 'No'
					else 'Yes'
				end AS ProjectManagmentRequired
				,case 
					WHEN TET.IsITHelpDeskRequired = 0 then 'No'
					else 'Yes'
				end AS ITHelpDeskRequired
				,case 
					WHEN TET.IsITPM_ID_Required = 0 then 'No'
					else 'Yes'
				end AS ITPMIDRequired
				,case 
					WHEN TET.IsHD_ROW_ID_Required = 0 then 'No'
					else 'Yes'
				end AS HDRowIDRequired
				,case 
					WHEN TET.IsDescriptionRequired = 0 then 'No'
					else 'Yes'
				end AS DescriptionRequired
				,case 
					WHEN TET.IsFileNameReferenceRequired = 0 then 'No'
					else 'Yes'
				end AS FileNameReferenceRequried
            FROM
                [TimeKeeper].[dbo].[TimeEntry_Tasks] TET
                INNER JOIN[TimeKeeper].[dbo].[TimeEntry_Types] Ttype
                    ON Ttype.id = TET.taskType
                LEFT JOIN[TimeKeeper].[dbo].[Organizations] O
                    ON O.id = TET.defaultClient
                       and O.active = 1";

            if ((!string.IsNullOrEmpty(taskType) && (taskType != "0")) || (status != TaskStatus.All) || (!string.IsNullOrEmpty(taskName)))
            {
                _sqlStatement += @"
            WHERE ";

                string _whereValues = string.Empty;

                if (!string.IsNullOrEmpty(taskType) && (taskType != "0"))
                {
                    _whereValues += "TET.[taskType] = @TaskType";
                }

                if (!string.IsNullOrEmpty(_whereValues) && (status != TaskStatus.All))
                {
                    _whereValues += " AND ";
                }

                if (status == TaskStatus.Active)
                {
                    _whereValues += " TET.active = 1";
                }
                else if (status == TaskStatus.InActive)
                {
                    _whereValues += " TET.active = 0";
                }

                if (!string.IsNullOrEmpty(taskName))
                {
                    if (!string.IsNullOrEmpty(_whereValues))
                    {
                        _whereValues += " AND ";
                    }
                    _whereValues += "TET.[name] like '%' + @TaskName + '%'";
                }

                _sqlStatement += _whereValues;
            }

            if (string.IsNullOrEmpty(orderBy))
            {
                _sqlStatement += @"
            ORDER BY
                TET.[id]";
            }
            else if (orderBy == "TaskType")
            {
                _sqlStatement += @"
            ORDER BY
                TET.[taskType] " + HiddenFieldTaskTypeOrder.Value;

                if (HiddenFieldTaskTypeOrder.Value == "ASC")
                {
                    HiddenFieldTaskTypeOrder.Value = "DESC";
                }
                else
                {
                    HiddenFieldTaskTypeOrder.Value = "ASC";
                }
            }
            else if (orderBy == "TaskName")
            {
                _sqlStatement += @"
            ORDER BY
                TET.[name] " + HiddenFieldTaskNameOrder.Value;

                if (HiddenFieldTaskNameOrder.Value == "ASC")
                {
                    HiddenFieldTaskNameOrder.Value = "DESC";
                }
                else
                {
                    HiddenFieldTaskNameOrder.Value = "ASC";
                }
            }
            else if (orderBy == "DefaultDuration")
            {
                _sqlStatement += @"
            ORDER BY
                TET.[defaultMinDuration] " + HiddenFieldDefaultDurationOrder.Value;

                if (HiddenFieldDefaultDurationOrder.Value == "ASC")
                {
                    HiddenFieldDefaultDurationOrder.Value = "DESC";
                }
                else
                {
                    HiddenFieldDefaultDurationOrder.Value = "ASC";
                }
            }
            else if (orderBy == "DefaultClient")
            {
                _sqlStatement += @"
            ORDER BY
                TET.[defaultClient] " + HiddenFieldDefaultClientOrder.Value;

                if (HiddenFieldDefaultClientOrder.Value == "ASC")
                {
                    HiddenFieldDefaultClientOrder.Value = "DESC";
                }
                else
                {
                    HiddenFieldDefaultClientOrder.Value = "ASC";
                }
            }


            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);

            if (!string.IsNullOrEmpty(taskType) && (taskType != "0"))
            {
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@TaskType", taskType);
            }

            if (!string.IsNullOrEmpty(taskName))
            {
                _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@TaskName", taskName);
            }

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            GridView1.DataSource = _dataTable;
            GridView1.DataBind();
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
                HiddenField HiddenFieldItemTemplateIDEdit = (HiddenField)GridView1.Rows[e.RowIndex].FindControl("HiddenFieldItemTemplateIDEdit");
                _con.Open();
                string _sqlCommand = @"
                update [TimeKeeper].[dbo].[TimeEntry_Tasks]
                set active = 0
                where
                    id = @Id";

                using (SqlCommand _cmd = new SqlCommand(_sqlCommand, _con))
                {
                    _cmd.Parameters.AddWithValue("@Id", HiddenFieldItemTemplateIDEdit.Value);
                    _cmd.ExecuteNonQuery();
                }
                ListItem _item = DropDownListTaskType.SelectedItem;
                PopulateTaskGridView(_item.Value, _con, string.Empty);
            }
        }

        private void ActivateRecord(string templateId)
        {
            string _confirmDelete = Request.Form["confirm_value"];
            if (_confirmDelete != "Yes")
            {
                return;
            }

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                string _sqlCommand = @"
                update [TimeKeeper].[dbo].[TimeEntry_Tasks]
                set active = 1
                where
                    id = @Id";

                using (SqlCommand _cmd = new SqlCommand(_sqlCommand, _con))
                {
                    _cmd.Parameters.AddWithValue("@Id", templateId);
                    _cmd.ExecuteNonQuery();
                }
                ListItem _item = DropDownListTaskType.SelectedItem;
                PopulateTaskGridView(_item.Value, _con, string.Empty);
            }
        }

        protected void GridView1_RowEditing(object sender, GridViewEditEventArgs e)
        {
            HiddenField HiddenFieldItemTemplateIDEdit = (HiddenField)GridView1.Rows[e.NewEditIndex].FindControl("HiddenFieldItemTemplateIDEdit");
            Label LabelTaskTypeId = (Label)GridView1.Rows[e.NewEditIndex].FindControl("LabelTaskTypeId");
            Label LabelTaskName = (Label)GridView1.Rows[e.NewEditIndex].FindControl("LabelTaskName");
            Label LabelDefaultDuration = (Label)GridView1.Rows[e.NewEditIndex].FindControl("LabelDefaultDuration");
            Label LabelDefaultClient = (Label)GridView1.Rows[e.NewEditIndex].FindControl("LabelDefaultClient");
            HiddenField HiddenFieldTaskTypeId = (HiddenField)GridView1.Rows[e.NewEditIndex].FindControl("HiddenFieldTaskTypeId");
            HiddenField HiddenFieldDefaultClientId = (HiddenField)GridView1.Rows[e.NewEditIndex].FindControl("HiddenFieldDefaultClientId");

            string _url = MBA.HttpApplication.createLink("InsertOrUpdateTask.aspx", true);
            _url += "&taskId=" + HiddenFieldItemTemplateIDEdit.Value +
                "&taskType=" + LabelTaskTypeId.Text +
                "&duration=" + LabelDefaultDuration.Text +
                "&client=" + HiddenFieldDefaultClientId.Value;
            Response.Redirect(_url, false);

        }

        protected void GridView1_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
        }

        protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName.Equals("UnDelete"))
            {
                GridViewRow _gvr = (GridViewRow)(((Button)e.CommandSource).NamingContainer);
                int _rowIndex = _gvr.RowIndex;
                HiddenField HiddenFieldItemTemplateIDEdit = (HiddenField)GridView1.Rows[_rowIndex].FindControl("HiddenFieldItemTemplateIDEdit");
                ActivateRecord(HiddenFieldItemTemplateIDEdit.Value);
            }
        }
        protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                HiddenField HiddenFieldActive = (HiddenField)e.Row.FindControl("HiddenFieldActive");
                if (HiddenFieldActive.Value.Equals("true", StringComparison.CurrentCultureIgnoreCase))
                {
                    Button ButtonUnDelete = (Button)e.Row.FindControl("ButtonUnDelete");
                    ButtonUnDelete.Visible = false;
                }
                else
                {
                    Button ButtonDelete = (Button)e.Row.FindControl("ButtonDelete");
                    ButtonDelete.Visible = false;
                }
            }
        }

        protected void GridView1_Sorting(object sender, GridViewSortEventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                PopulateTaskGridView(DropDownListTaskType.SelectedItem.Value, _con, e.SortExpression);
            }
        }

        private void PopulateTaskType(SqlConnection con)
        {
            string _sqlStatement = @"
            SELECT [id]
                ,[name]
            FROM [TimeKeeper].[dbo].[TimeEntry_Types]";

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            DropDownListTaskType.DataSource = _dataTable;

            DropDownListTaskType.DataTextField = "name";
            DropDownListTaskType.DataValueField = "id";
            DropDownListTaskType.DataBind();

            ListItem _listItem = new ListItem();
            _listItem.Text = "No Filter";
            _listItem.Value = "0";

            DropDownListTaskType.Items.Add(_listItem);

            DropDownListTaskType.SelectedValue = "0";
        }
        protected void ButtonTaskType_Click(object sender, EventArgs e)
        {
            string _url = MBA.HttpApplication.createLink("TimeEntryTaskTypeManagement.aspx", true);
            Response.Redirect(_url, false);
        }

        protected void ButtonAddTask_Click(object sender, EventArgs e)
        {
            string _url = MBA.HttpApplication.createLink("InsertOrUpdateTask.aspx", true);
            _url += "&taskId=0&taskType=0&duration=0&client=0";
            Response.Redirect(_url, false);
        }

        protected void DropDownListTaskType_SelectedIndexChanged(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                ListItem _listItem = DropDownListTaskType.SelectedItem;

                PopulateTaskGridView(_listItem.Value, _con, string.Empty);
            }
        }

        protected void RadioButtonActive_CheckedChanged(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                PopulateTaskGridView(DropDownListTaskType.SelectedValue, _con, string.Empty);
            }
        }

        protected void RadioButtonInActive_CheckedChanged(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                PopulateTaskGridView(DropDownListTaskType.SelectedValue, _con, string.Empty);
            }
        }

        protected void RadioButtonAll_CheckedChanged(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                PopulateTaskGridView(DropDownListTaskType.SelectedValue, _con, string.Empty);
            }
        }
    }
}
