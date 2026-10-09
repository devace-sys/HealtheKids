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
     public partial class TimeEntryTaskTypeManagement : WebUI
     {
          public TimeEntryTaskTypeManagement()
               : base("timeentry", WebUI.CreatePageSubTitle("Task Type Management", "Manage tasks types for Time Keeper System"), "", "", Constants.ROLE_SBS_ALL)
          { 
          }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                {
                    _con.Open();
                    PopulateGrid(_con);
                }
            }
        }

        protected void ButtonAddTask_Click(object sender, EventArgs e)
        {
        }

        protected void ButtonBack_Click(object sender, EventArgs e)
        {
            string _url = MBA.HttpApplication.createLink("TimeEntryTaskManagement.aspx", true);
            Response.Redirect(_url, false);
        }
        protected void gridView_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            ButtonAddTask.Enabled = false;
            HiddenFieldEditRowIndex.Value = "-1";
            gridView.EditIndex = -1;
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                PopulateGrid(_con);
            }
        }
        protected void GridView1_Sorting(object sender, GridViewSortEventArgs e)
        {
            switch (e.SortExpression)
            {
                case "Name":
                    using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                    {
                        _con.Open();
                        if (HiddenFieldSortDirection.Value == "ASC")
                        {
                            HiddenFieldSortDirection.Value = "DESC";
                        }
                        else
                        {
                            HiddenFieldSortDirection.Value = "ASC";
                        }

                        PopulateGrid(_con);
                    }
                    break;
            }
        }

        protected void gridView_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            string confirmValue = Request.Form["confirm_value"];
            if (confirmValue != "Yes")
            {
                return;
            }

            ButtonAddTask.Enabled = false;
            int _selectedRow = e.RowIndex;
            string _id = "0";
            HiddenField lblnameTaskTypeId = (HiddenField)gridView.Rows[_selectedRow].FindControl("lblnameTaskTypeId");

            if (lblnameTaskTypeId != null)
            {
                _id = lblnameTaskTypeId.Value;
            }
            else
            {
                HiddenField HiddenFieldIDEdit = (HiddenField)gridView.Rows[_selectedRow].FindControl("HiddenFieldIDEdit");
                if (HiddenFieldIDEdit != null)
                {
                    _id = HiddenFieldIDEdit.Value;
                }
            }

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                string _sqlStatement = "update [TimeKeeper].[dbo].[TimeEntry_Types] set active = 0 where id = @Id";
                SqlCommand cmd = new SqlCommand(_sqlStatement, _con);
                cmd.Parameters.AddWithValue("@Id", _id);

                cmd.ExecuteNonQuery();
                PopulateGrid(_con);
            }
            gridView.EditIndex = -1;
            ButtonAddTask.Enabled = true;
        }

        protected void ActivateRecord(string id)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                string _sqlStatement = "update [TimeKeeper].[dbo].[TimeEntry_Types] set active = 1 where id = @Id";
                SqlCommand cmd = new SqlCommand(_sqlStatement, _con);
                cmd.Parameters.AddWithValue("@Id", id);

                cmd.ExecuteNonQuery();
                PopulateGrid(_con);
            }
        }
        protected void gridView_RowEditing(object sender, GridViewEditEventArgs e)
        {
            ButtonAddTask.Enabled = false;
            HiddenFieldEditRowIndex.Value = e.NewEditIndex.ToString();
            gridView.EditIndex = e.NewEditIndex;

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                PopulateGrid(_con);
                Button ButtonAddEdit = (Button)gridView.Rows[gridView.EditIndex].FindControl("ButtonAddEdit");
                ButtonAddEdit.Visible = false;
                Button ButtonUpdate = (Button)gridView.Rows[gridView.EditIndex].FindControl("ButtonUpdate");
            }
        }
        protected void gridView_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            HiddenField HiddenFieldIDEdit = (HiddenField)gridView.Rows[e.RowIndex].FindControl("HiddenFieldIDEdit");
            TextBox TextBoxEditTaskName = (TextBox)gridView.Rows[e.RowIndex].FindControl("TextBoxEditTaskName");
            CheckBox CheckBoxScheduled = (CheckBox)gridView.Rows[e.RowIndex].FindControl("CheckBoxScheduled");
            CheckBox CheckBoxPaidWork = (CheckBox)gridView.Rows[e.RowIndex].FindControl("CheckBoxPaidWork");
            CheckBox CheckBoxPaidNotToWork = (CheckBox)gridView.Rows[e.RowIndex].FindControl("CheckBoxPaidNotToWork");
            CheckBox CheckBoxBreaks = (CheckBox)gridView.Rows[e.RowIndex].FindControl("CheckBoxBreaks");
            CheckBox CheckBoxVacation = (CheckBox)gridView.Rows[e.RowIndex].FindControl("CheckBoxVacation");
            CheckBox CheckBoxSick = (CheckBox)gridView.Rows[e.RowIndex].FindControl("CheckBoxSick");

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                string _sqlCommand = @"
                update [TimeKeeper].[dbo].[TimeEntry_Types]
                    set name = @Name
                        ,scheduled = @Scheduled
                        ,paidWork = @PaidWork
                        ,paidNotWork = @PaidNotWork
                        ,breaks = @Breaks
                        ,vacation = @Vacation
                        ,sick = @Sick
                where
                    id = @Id";


                using (SqlCommand _cmd = new SqlCommand(_sqlCommand, _con))
                {
                    _cmd.Parameters.AddWithValue("@Name", TextBoxEditTaskName.Text);
                    _cmd.Parameters.AddWithValue("@Scheduled", CheckBoxScheduled.Checked);
                    _cmd.Parameters.AddWithValue("@PaidWork", CheckBoxPaidWork.Checked);
                    _cmd.Parameters.AddWithValue("@PaidNotWork", CheckBoxPaidNotToWork.Checked);
                    _cmd.Parameters.AddWithValue("@Breaks", CheckBoxBreaks.Checked);
                    _cmd.Parameters.AddWithValue("@Vacation", CheckBoxVacation.Checked);
                    _cmd.Parameters.AddWithValue("@Sick", CheckBoxSick.Checked);
                    _cmd.Parameters.AddWithValue("@Id", HiddenFieldIDEdit.Value);
                    _cmd.ExecuteNonQuery();
                }
                gridView.EditIndex = -1;
                PopulateGrid(_con);
            }

            ButtonAddTask.Enabled = true;
        }
        protected void gridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                DataRow dr = ((DataRowView)e.Row.DataItem).Row;

                if (string.IsNullOrEmpty(dr["id"].ToString()))
                {
                    return;
                }
                HiddenField HiddenFieldIDEdit = (HiddenField)e.Row.FindControl("HiddenFieldIDEdit");
                TextBox TextBoxEditTaskName = (TextBox)e.Row.FindControl("TextBoxEditTaskName");
                CheckBox CheckBoxScheduled = (CheckBox)e.Row.FindControl("CheckBoxScheduled");
                CheckBox CheckBoxPaidWork = (CheckBox)e.Row.FindControl("CheckBoxPaidWork");
                CheckBox CheckBoxPaidNotToWork = (CheckBox)e.Row.FindControl("CheckBoxPaidNotToWork");
                CheckBox CheckBoxBreaks = (CheckBox)e.Row.FindControl("CheckBoxBreaks");
                CheckBox CheckBoxVacation = (CheckBox)e.Row.FindControl("CheckBoxVacation");
                HiddenField lblnameTaskTypeId = (HiddenField)e.Row.FindControl("lblnameTaskTypeId");
                CheckBox CheckBoxSick = (CheckBox)e.Row.FindControl("CheckBoxSick");
                Label lblTaskName = (Label)e.Row.FindControl("lblTaskName");
                Label lblScheduled = (Label)e.Row.FindControl("lblScheduled");
                Label lblPaidWork = (Label)e.Row.FindControl("lblPaidWork");
                Label lblPaidNotToWork = (Label)e.Row.FindControl("lblPaidNotToWork");
                Label lblBreaks = (Label)e.Row.FindControl("lblBreaks");
                Label lblVacation = (Label)e.Row.FindControl("lblVacation");
                Label lblSick = (Label)e.Row.FindControl("lblSick");

                HiddenField HiddenFieldIsActive = (HiddenField)e.Row.FindControl("HiddenFieldIsActive");
                Button ButtonDelete = (Button)e.Row.FindControl("ButtonDelete");
                Button ButtonUnDelete = (Button)e.Row.FindControl("ButtonUnDelete");

                if (HiddenFieldIsActive != null)
                {
                    HiddenFieldIsActive.Value = dr["active"].ToString();

                    if (HiddenFieldIsActive.Value.Equals("true", StringComparison.CurrentCultureIgnoreCase))
                    {
                        if (ButtonUnDelete != null)
                            ButtonUnDelete.Visible = false;
                    }
                    else
                    {
                        if (ButtonDelete != null)
                        {
                            ButtonDelete.Visible = false;
                        }
                    }

                }

                if (HiddenFieldIDEdit != null)
                {
                    HiddenFieldIDEdit.Value = dr["id"].ToString();
                }

                if (lblnameTaskTypeId != null)
                {
                    lblnameTaskTypeId.Value = dr["id"].ToString();
                }

                if (TextBoxEditTaskName != null)
                {
                    TextBoxEditTaskName.Text = dr["name"].ToString();
                }

                if (lblTaskName != null)
                {
                    lblTaskName.Text = dr["name"].ToString();
                }


                if (bool.Parse(dr["scheduled"].ToString()))
                {
                    if (CheckBoxScheduled != null)
                    {
                        CheckBoxScheduled.Checked = true;
                    }
                    if (lblScheduled != null)
                    {
                        lblScheduled.Text = "True";
                    }
                }
                else
                {
                    if (CheckBoxScheduled != null)
                    {
                        CheckBoxScheduled.Checked = false;
                    }
                    if (lblScheduled != null)
                    {
                        lblScheduled.Text = "False";
                    }
                }

                if (bool.Parse(dr["paidWork"].ToString()))
                {
                    if (CheckBoxPaidWork != null)
                    {
                        CheckBoxPaidWork.Checked = true;
                    }
                    if (lblPaidWork != null)
                    {
                        lblPaidWork.Text = "True";
                    }
                }
                else
                {
                    if (CheckBoxPaidWork != null)
                    {
                        CheckBoxPaidWork.Checked = false;
                    }
                    if (lblPaidWork != null)
                    {
                        lblPaidWork.Text = "False";
                    }
                }

                if (bool.Parse(dr["paidNotWork"].ToString()))
                {
                    if (CheckBoxPaidNotToWork != null)
                    {
                        CheckBoxPaidNotToWork.Checked = true;
                    }
                    if (lblPaidNotToWork != null)
                    {
                        lblPaidNotToWork.Text = "True";
                    }
                }
                else
                {
                    if (CheckBoxPaidNotToWork != null)
                    {
                        CheckBoxPaidNotToWork.Checked = false;
                    }
                    if (lblPaidNotToWork != null)
                    {
                        lblPaidNotToWork.Text = "False";
                    }
                }

                if (bool.Parse(dr["breaks"].ToString()))
                {
                    if (CheckBoxBreaks != null)
                    {
                        CheckBoxBreaks.Checked = true;
                    }
                    if (lblBreaks != null)
                    {
                        lblBreaks.Text = "True";
                    }
                }
                else
                {
                    if (CheckBoxBreaks != null)
                    {
                        CheckBoxBreaks.Checked = false;
                    }
                    if (lblBreaks != null)
                    {
                        lblBreaks.Text = "False";
                    }
                }

                if (bool.Parse(dr["vacation"].ToString()))
                {
                    if (CheckBoxVacation != null)
                    {
                        CheckBoxVacation.Checked = true;
                    }
                    if (lblVacation != null)
                    {
                        lblVacation.Text = "True";
                    }
                }
                else
                {
                    if (CheckBoxVacation != null)
                    {
                        CheckBoxVacation.Checked = false;
                    }
                    if (lblVacation != null)
                    {
                        lblVacation.Text = "False";
                    }
                }

                if (bool.Parse(dr["sick"].ToString()))
                {
                    if (CheckBoxSick != null)
                    {
                        CheckBoxSick.Checked = true;
                    }
                    if (lblSick != null)
                    {
                        lblSick.Text = "True";
                    }
                }
                else
                {
                    if (CheckBoxSick != null)
                    {
                        CheckBoxSick.Checked = false;
                    }
                    if (lblSick != null)
                    {
                        lblSick.Text = "False";
                    }
                }
            }
        }

        protected void gridView_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName.Equals("AddNew"))
            {
                AddNewTask();
            }
            if (e.CommandName.Equals("UnDelete"))
            {
                GridViewRow _gvr = (GridViewRow)(((Button)e.CommandSource).NamingContainer);
                int _rowIndex = _gvr.RowIndex;
                string _id = "0";
                HiddenField lblnameTaskTypeId = (HiddenField)gridView.Rows[_rowIndex].FindControl("lblnameTaskTypeId");

                if (lblnameTaskTypeId != null)
                {
                    _id = lblnameTaskTypeId.Value;
                }
                else
                {
                    HiddenField HiddenFieldIDEdit = (HiddenField)gridView.Rows[_rowIndex].FindControl("HiddenFieldIDEdit");
                    if (HiddenFieldIDEdit != null)
                    {
                        _id = HiddenFieldIDEdit.Value;
                    }
                }

                ActivateRecord(_id);
            }
        }

        private void AddNewTask()
        {
            TextBox TextBoxEditTaskName = (TextBox)gridView.Rows[0].FindControl("TextBoxEditTaskName");
            CheckBox CheckBoxScheduled = (CheckBox)gridView.Rows[0].FindControl("CheckBoxScheduled");
            CheckBox CheckBoxPaidWork = (CheckBox)gridView.Rows[0].FindControl("CheckBoxPaidWork");
            CheckBox CheckBoxPaidNotToWork = (CheckBox)gridView.Rows[0].FindControl("CheckBoxPaidNotToWork");
            CheckBox CheckBoxBreaks = (CheckBox)gridView.Rows[0].FindControl("CheckBoxBreaks");
            CheckBox CheckBoxVacation = (CheckBox)gridView.Rows[0].FindControl("CheckBoxVacation");
            CheckBox CheckBoxSick = (CheckBox)gridView.Rows[0].FindControl("CheckBoxSick");

            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();

                string _sqlStatement = @"
                INSERT INTO [TimeKeeper].[dbo].[TimeEntry_Types]
                    (
                        [name]
                        ,[scheduled]
                        ,[paidWork]
                        ,[paidNotWork]
                        ,[breaks]
                        ,[vacation]
                        ,[sick]
                    )
                    VALUES
                    (
                        @Name
                        ,@Scheduled
                        ,@PaidWork
                        ,@PaidNotWork
                        ,@Breaks
                        ,@Vacation
                        ,@Sick
                    )";

                using (SqlCommand cmd = new SqlCommand(_sqlStatement, _con))
                {
                    cmd.Parameters.AddWithValue("@Name", TextBoxEditTaskName.Text);
                    cmd.Parameters.AddWithValue("@Scheduled", CheckBoxScheduled.Checked);
                    cmd.Parameters.AddWithValue("@PaidWork", CheckBoxPaidWork.Checked);
                    cmd.Parameters.AddWithValue("@PaidNotWork", CheckBoxPaidNotToWork.Checked);
                    cmd.Parameters.AddWithValue("@Breaks", CheckBoxBreaks.Checked);
                    cmd.Parameters.AddWithValue("@Vacation", CheckBoxVacation.Checked);
                    cmd.Parameters.AddWithValue("@Sick", CheckBoxSick.Checked);
                    cmd.ExecuteNonQuery();
                }
                gridView.EditIndex = -1;
                PopulateGrid(_con);
                ButtonAddTask.Enabled = true;
            }
        }

        protected void ButtonAddTask_Click1(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                DataSet _dataSet = GetGridViewDataSet(_con);
                _dataSet.Tables[0].Rows.InsertAt(_dataSet.Tables[0].NewRow(), 0);
                gridView.EditIndex = 0;
                gridView.DataSource = _dataSet;
                gridView.DataBind();

                GridViewRow _gridRow = gridView.Rows[0];

                HiddenField HiddenFieldIDEdit = (HiddenField)_gridRow.FindControl("HiddenFieldIDEdit");
                HiddenFieldIDEdit.Value = "0";
                Button ButtonAddEdit = (Button)_gridRow.FindControl("ButtonAddEdit");
                ButtonAddEdit.Visible = true;
                Button ButtonUpdate = (Button)_gridRow.FindControl("ButtonUpdate");
                ButtonUpdate.Visible = false;

                ButtonAddTask.Enabled = false;

            }
        }

        private DataSet GetGridViewDataSet(SqlConnection con)
        {
            string _sqlStatement = @"
        SELECT
            *            
        FROM
                [TimeKeeper].[dbo].[TimeEntry_Types]
        ORDER BY
                [name]";

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            DataSet _dataSet = new DataSet();
            _sqlDataAdapter.Fill(_dataSet);

            return _dataSet;
        }

        private void PopulateGrid(SqlConnection con)
        {
            string _sqlStatement = @"
        SELECT
            *            
        FROM
                [TimeKeeper].[dbo].[TimeEntry_Types]";

            if (RadioButtonActive.Checked)
            {
                _sqlStatement += @" WHERE active = 1 ";
            }
            else if (RadioButtonInActive.Checked)
            {
                _sqlStatement += @" WHERE active = 0 ";
            }

            _sqlStatement += @"
        ORDER BY
                [name] " + HiddenFieldSortDirection.Value;

            SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, con);
            DataTable _dataTable = new DataTable();
            _sqlDataAdapter.Fill(_dataTable);

            gridView.DataSource = _dataTable;
            gridView.DataBind();
        }


        protected void RadioButtonActive_CheckedChanged(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                PopulateGrid(_con);
            }
        }

        protected void RadioButtonInActive_CheckedChanged(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                PopulateGrid(_con);
            }
        }

        protected void RadioButtonAll_CheckedChanged(object sender, EventArgs e)
        {
            using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
            {
                _con.Open();
                PopulateGrid(_con);
            }
        }
    }
}
