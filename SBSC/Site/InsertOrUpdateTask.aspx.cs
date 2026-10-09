using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MBA.Web;

namespace Spedmon
{
     public partial class InsertOrUpdateTask : WebUI
     {
          public InsertOrUpdateTask()
               : base("insertorupdatetask", WebUI.CreatePageSubTitle("Task Management", "Create, update, or delete task management"), "", "", Constants.ROLE_SBS_ALL)
          { 
          }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (TimeSheetSession.Current.RoleId != 1 && TimeSheetSession.Current.RoleId != 3)
            {
                string _url = MBA.HttpApplication.createLink("~", true);
                Response.Redirect(_url);
                return;
            }

            try
            {
                if (!IsPostBack)
                {
                    HiddenFieldTaskID.Value = Request.QueryString["taskId"].ToString();
                    HiddenFieldTaskType.Value = Request.QueryString["taskType"].ToLower();
                    HiddenFieldDuration.Value = Request.QueryString["duration"].ToLower();
                    HiddenFieldClient.Value = Request.QueryString["client"].ToLower();

                    using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                    {
                        _con.Open();
                        PopulateClientDropDownList(_con);
                        PopulateTaskType(_con);

                        if (HiddenFieldTaskID.Value != "0")
                        {
                            GetTaskInformation(_con);
                        }
                    }
                }
            }
            catch
            {
                string _url = MBA.HttpApplication.createLink("~", true);
                Response.Redirect(_url);
            }
        }

        private void GetTaskInformation(SqlConnection con)
        {
            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter("TimeKeeper_TIMESHEET_GetTaskInformation", con);
            _sqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
            _sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@Id", HiddenFieldTaskID.Value);

            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            if (_dataTable.Rows.Count <= 0)
            {
                return;
            }

            DataRow _dataRow = _dataTable.Rows[0];

            TextBoxTaskName.Text = _dataRow["name"].ToString();

            TextBoxTaskDescription.Text = _dataRow["Task_description"].ToString();

            TextBoxTaskTtfnCode.Text = _dataRow["TTFN_code"].ToString();

            TextBoxDuration.Text =  _dataRow.IsNull("defaultMinDuration") ? string.Empty : _dataRow["defaultMinDuration"].ToString();

            if (bool.Parse(_dataRow["IsProjectManagementRequired"].ToString()))
            {
                RadioButtonListProjectManagementOrHelpDesk.SelectedValue = "0";
            }
            else if (bool.Parse(_dataRow["IsITHelpDeskRequired"].ToString()))
            {
                RadioButtonListProjectManagementOrHelpDesk.SelectedValue = "1";
            }
            else
            {
                RadioButtonListProjectManagementOrHelpDesk.SelectedValue = "2";
            }

            if (bool.Parse(_dataRow["IsITPM_ID_Required"].ToString()))
            {
                RadioButtonListITPMorHDRow.SelectedValue = "0";
            }
            else if (bool.Parse(_dataRow["IsHD_ROW_ID_Required"].ToString()))
            {
                RadioButtonListITPMorHDRow.SelectedValue = "1";
            }
            else
            {
                RadioButtonListITPMorHDRow.SelectedValue = "2";
            }

            CheckBoxFileNameReference.Checked = bool.Parse(_dataRow["IsFileNameReferenceRequired"].ToString());
            CheckBoxTaskScheduleInFuture.Checked = bool.Parse(_dataRow["CanBeScheduledInTheFuture"].ToString());
            CheckBoxMultipleClients.Checked = bool.Parse(_dataRow["CanHaveMultipleClients"].ToString());
            CheckBoxSpecifyStartStopTime.Checked = bool.Parse(_dataRow["SpecifyStartStopTime"].ToString());
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
            _listItem.Text = "Select Task Type";
            _listItem.Value = "0";

            DropDownListTaskType.Items.Add(_listItem);

            DropDownListTaskType.SelectedValue = HiddenFieldTaskType.Value;
        }

        private void PopulateClientDropDownList(SqlConnection con)
        {
            string _sqlStatement = @"
            SELECT [id]
                    ,[name]
            FROM [TimeKeeper].[dbo].[Organizations]
            WHERE active = 1";

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            DropDownListClient.DataTextField = "name";
            DropDownListClient.DataValueField = "id";
            DropDownListClient.DataSource = _dataTable;
            DropDownListClient.DataBind();

            ListItem _item = new ListItem();

            _item.Text = "Select Associated Organization If Applicable";
            _item.Value = "0";

            DropDownListClient.Items.Add(_item);
            DropDownListClient.SelectedValue = HiddenFieldClient.Value;
        }

        protected void ButtonSave_Click(object sender, EventArgs e)
        {
            if (DropDownListTaskType.SelectedValue == "0")
            {
                LabelErrMsg.Text = @"<strong style = 'font-weight: bold'> 
                                <br/><br/>Need to specify task type</strong >";
                return;
            }
            else
            {
                LabelErrMsg.Text = string.Empty;
            }

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();

                if (HiddenFieldTaskID.Value == "0")
                {
                    InsertTask(_con);
                }
                else
                {
                    UpdateTask(_con);
                }
            }

            string _url = MBA.HttpApplication.createLink("TimeEntryTaskManagement.aspx", true);
            Response.Redirect(_url, false);
        }

        private void UpdateTask(SqlConnection con)
        {
            SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_TASK_Update", con);
            _sqlCommand.CommandType = CommandType.StoredProcedure;
            _sqlCommand.Parameters.AddWithValue("@id", HiddenFieldTaskID.Value);
            _sqlCommand.Parameters.AddWithValue("@taskType", DropDownListTaskType.SelectedItem.Value);
            _sqlCommand.Parameters.AddWithValue("@name", (string.IsNullOrEmpty(TextBoxTaskName.Text) ? string.Empty : TextBoxTaskName.Text));

            _sqlCommand.Parameters.AddWithValue("@description", (string.IsNullOrEmpty(TextBoxTaskDescription.Text) ? string.Empty : TextBoxTaskDescription.Text));
            _sqlCommand.Parameters.AddWithValue("@ttfn_code", (string.IsNullOrEmpty(TextBoxTaskTtfnCode.Text) ? string.Empty : TextBoxTaskTtfnCode.Text));

            if (string.IsNullOrEmpty(TextBoxDuration.Text))
                _sqlCommand.Parameters.AddWithValue("@defaultMinDuration", DBNull.Value);
            else
                _sqlCommand.Parameters.AddWithValue("@defaultMinDuration", TextBoxDuration.Text);

            if (DropDownListClient.SelectedValue == "0")
                _sqlCommand.Parameters.AddWithValue("@defaultClient", DBNull.Value);
            else
                _sqlCommand.Parameters.AddWithValue("@defaultClient", DropDownListClient.SelectedValue);

            _sqlCommand.Parameters.AddWithValue("@active", true);

            switch (RadioButtonListProjectManagementOrHelpDesk.SelectedValue)
            {
                case "0":
                    _sqlCommand.Parameters.AddWithValue("@IsProjectManagementRequired", true);
                    _sqlCommand.Parameters.AddWithValue("@IsITHelpDeskRequired", false);
                    break;
                case "1":
                    _sqlCommand.Parameters.AddWithValue("@IsProjectManagementRequired", false);
                    _sqlCommand.Parameters.AddWithValue("@IsITHelpDeskRequired", true);
                    break;
                case "2":
                    _sqlCommand.Parameters.AddWithValue("@IsProjectManagementRequired", false);
                    _sqlCommand.Parameters.AddWithValue("@IsITHelpDeskRequired", false);
                    break;
            }

            switch (RadioButtonListITPMorHDRow.SelectedValue)
            {
                case "0":
                    _sqlCommand.Parameters.AddWithValue("@IsITPM_ID_Required", true);
                    _sqlCommand.Parameters.AddWithValue("@IsHD_ROW_ID_Required", false);
                    break;
                case "1":
                    _sqlCommand.Parameters.AddWithValue("@IsITPM_ID_Required", false);
                    _sqlCommand.Parameters.AddWithValue("@IsHD_ROW_ID_Required", true);
                    break;
                case "2":
                    _sqlCommand.Parameters.AddWithValue("@IsITPM_ID_Required", false);
                    _sqlCommand.Parameters.AddWithValue("@IsHD_ROW_ID_Required", false);
                    break;
            }
            // SBC TODO: When we went live description no longer wanted
            // remove field in table in 1.5 and refractor code
            _sqlCommand.Parameters.AddWithValue("@IsDescriptionRequired", false);
            _sqlCommand.Parameters.AddWithValue("@IsFileNameReferenceRequired", (CheckBoxFileNameReference.Checked ? true : false));
            _sqlCommand.Parameters.AddWithValue("@CanBeScheduledInTheFuture", (CheckBoxTaskScheduleInFuture.Checked ? true : false));
            _sqlCommand.Parameters.AddWithValue("@CanHaveMultipleClients", (CheckBoxMultipleClients.Checked ? true : false));
            _sqlCommand.Parameters.AddWithValue("@SpecifyStartStopTime", (CheckBoxSpecifyStartStopTime.Checked ? true : false));

            _sqlCommand.ExecuteNonQuery();
        }
        private void InsertTask(SqlConnection con)
        {
            SqlCommand _sqlCommand = new SqlCommand("TimeKeeper_TASK_CreateNew", con);
            _sqlCommand.CommandType = CommandType.StoredProcedure;
            _sqlCommand.Parameters.AddWithValue("@taskType", DropDownListTaskType.SelectedItem.Value);
            _sqlCommand.Parameters.AddWithValue("@name", (string.IsNullOrEmpty(TextBoxTaskName.Text) ? string.Empty : TextBoxTaskName.Text));

            _sqlCommand.Parameters.AddWithValue("@description", (string.IsNullOrEmpty(TextBoxTaskDescription.Text) ? string.Empty : TextBoxTaskDescription.Text));

            _sqlCommand.Parameters.AddWithValue("@ttfn_code", (string.IsNullOrEmpty(TextBoxTaskTtfnCode.Text) ? string.Empty : TextBoxTaskTtfnCode.Text));

            if (string.IsNullOrEmpty(TextBoxDuration.Text))
                _sqlCommand.Parameters.AddWithValue("@defaultMinDuration", DBNull.Value);
            else
                _sqlCommand.Parameters.AddWithValue("@defaultMinDuration", TextBoxDuration.Text);

            if (DropDownListClient.SelectedValue == "0")
                _sqlCommand.Parameters.AddWithValue("@defaultClient",  DBNull.Value);
            else
                _sqlCommand.Parameters.AddWithValue("@defaultClient", DropDownListClient.SelectedValue);

            _sqlCommand.Parameters.AddWithValue("@active", true);

            switch (RadioButtonListProjectManagementOrHelpDesk.SelectedValue)
            {
                case "0":
                    _sqlCommand.Parameters.AddWithValue("@IsProjectManagementRequired", true);
                    _sqlCommand.Parameters.AddWithValue("@IsITHelpDeskRequired", false);
                    break;
                case "1":
                    _sqlCommand.Parameters.AddWithValue("@IsProjectManagementRequired", false);
                    _sqlCommand.Parameters.AddWithValue("@IsITHelpDeskRequired", true);
                    break;
                case "2":
                    _sqlCommand.Parameters.AddWithValue("@IsProjectManagementRequired", false);
                    _sqlCommand.Parameters.AddWithValue("@IsITHelpDeskRequired", false);
                    break;
            }

            switch (RadioButtonListITPMorHDRow.SelectedValue)
            {
                case "0":
                    _sqlCommand.Parameters.AddWithValue("@IsITPM_ID_Required", true);
                    _sqlCommand.Parameters.AddWithValue("@IsHD_ROW_ID_Required", false);
                    break;
                case "1":
                    _sqlCommand.Parameters.AddWithValue("@IsITPM_ID_Required", false);
                    _sqlCommand.Parameters.AddWithValue("@IsHD_ROW_ID_Required", true);
                    break;
                case "2":
                    _sqlCommand.Parameters.AddWithValue("@IsITPM_ID_Required", false);
                    _sqlCommand.Parameters.AddWithValue("@IsHD_ROW_ID_Required", false);
                    break;
            }
            // SBC TODO: When we went live description no longer wanted
            // remove field in table in 1.5 and refractor code
            _sqlCommand.Parameters.AddWithValue("@IsDescriptionRequired", false);
            _sqlCommand.Parameters.AddWithValue("@IsFileNameReferenceRequired", (CheckBoxFileNameReference.Checked ? true : false));
            _sqlCommand.Parameters.AddWithValue("@CanBeScheduledInTheFuture", (CheckBoxTaskScheduleInFuture.Checked ? true : false));
            _sqlCommand.Parameters.AddWithValue("@CanHaveMultipleClients", (CheckBoxMultipleClients.Checked ? true : false));
            _sqlCommand.Parameters.AddWithValue("@SpecifyStartStopTime", (CheckBoxSpecifyStartStopTime.Checked ? true : false));

            _sqlCommand.Parameters.Add("@Id", SqlDbType.BigInt);
            _sqlCommand.Parameters["@Id"].Direction = ParameterDirection.Output;

            _sqlCommand.ExecuteNonQuery();
        }

        protected void ButtonCancel_Click(object sender, EventArgs e)
        {
            string _url = MBA.HttpApplication.createLink("TimeEntryTaskManagement.aspx", true);
            Response.Redirect(_url, false);
        }
    }
}
