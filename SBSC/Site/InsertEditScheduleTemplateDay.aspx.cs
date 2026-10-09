using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Spedmon
{
     public partial class InsertEditScheduleTemplateDay : WebUI
     {
          public InsertEditScheduleTemplateDay()
               : base("timeentry", WebUI.CreatePageSubTitle("Auto Populate Schedule", "Create or modify day in the template"),
                    "", "", Constants.ROLE_SBS_ALL)
          { 
          }
          protected void Page_Load(object sender, EventArgs e)
          {
               if (!IsPostBack)
               {
                    HiddenFieldScheduleTemplateId.Value = Request.QueryString["scheduleTemplateId"];
                    HiddenFieldScheduleTemplateDayId.Value = Request.QueryString["templateDayId"];
                    HiddenFieldDayId.Value = Request.QueryString["dayId"];
                    HiddenFieldEmployeeID.Value = Request.QueryString["employeeid"];

                    // Invalid to have a 0 schedule template Id
                    if (HiddenFieldScheduleTemplateId.Value == "0")
                    {
                         string _url = MBA.HttpApplication.createLink("InsertEditScheduleTemplate.aspx", true)
                             + "&scheduleTemplateId=" + HiddenFieldScheduleTemplateId.Value + "&employeeid=" + HiddenFieldEmployeeID.Value;
                         //gotoNewURL(_url);
                         Response.Redirect(_url, false);
                         return;
                    }

                    // If template day id is 0,  insert record
                    if (HiddenFieldScheduleTemplateDayId.Value == "0")
                    {
                         InsertAutoScheduleDays();
                    }

                    PopulateGrid();
               }
          }

          private void InsertAutoScheduleDays()
          {
               try
               {
                    int _dayId = int.Parse(HiddenFieldDayId.Value);

                    if (_dayId < 0 || _dayId > 6)
                    {
                         throw new Exception("Invalid day value");
                    }

                    string _sqlStatement = @"
            INSERT INTO TimeKeeper.dbo.AutoPopulateScheduleDays
            (
	            [dayId]
	            ,[scheduleid]
            )
            VALUES
            (
	            @DayId
	            ,@ScheduleId
            );
            SELECT SCOPE_IDENTITY();";

                    using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                    {
                         _con.Open();

                         SqlCommand _sqlcommand = new SqlCommand(_sqlStatement, _con);
                         _sqlcommand.Parameters.AddWithValue("@DayId", HiddenFieldDayId.Value);
                         _sqlcommand.Parameters.AddWithValue("@ScheduleId", HiddenFieldScheduleTemplateId.Value);
                         
                         object _id = _sqlcommand.ExecuteScalar();

                         HiddenFieldScheduleTemplateDayId.Value = _id.ToString();
                    }
               }
               catch
               {
                    string _url = MBA.HttpApplication.createLink("InsertEditScheduleTemplate.aspx", true)
                        + "&scheduleTemplateId=0&employeeid=" + HiddenFieldEmployeeID.Value;
                    //gotoNewURL(_url);
                    Response.Redirect(_url, false);
                    return;
               }
          }

          protected void ButtonBack_Click(object sender, EventArgs e)
          {
               string _url = MBA.HttpApplication.createLink("InsertEditScheduleTemplate.aspx", true)
                   + "&scheduleTemplateId=" + HiddenFieldScheduleTemplateId.Value + "&employeeid=" + HiddenFieldEmployeeID.Value;
               //gotoNewURL(_url);
               Response.Redirect(_url, false);

          }

          protected void gridView_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
          {
               ButtonAdd.Enabled = true;
               HiddenFieldEditRowIndex.Value = "-1";
               gridView.EditIndex = -1;
               PopulateGrid();
          }

          protected void gridView_RowDeleting(object sender, GridViewDeleteEventArgs e)
          {
               ButtonAdd.Enabled = false;
               int _selectedRow = e.RowIndex;
               long _id = 0;
               HiddenField lblnameStopStartId = (HiddenField)gridView.Rows[_selectedRow].FindControl("lblnameStopStartId");

               if (lblnameStopStartId != null)
               {
                    _id = Convert.ToInt64(lblnameStopStartId.Value);
               }
               else
               {
                    HiddenField HiddenFieldIDEdit = (HiddenField)gridView.Rows[_selectedRow].FindControl("HiddenFieldIDEdit");
                    if (HiddenFieldIDEdit != null)
                    {
                         _id = Convert.ToInt64(HiddenFieldIDEdit.Value);
                    }
               }

               using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
               {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("TimeKeeper_SCHEDULETemplateStartAndStop_Delete", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@ID", _id);

                    cmd.ExecuteNonQuery();
               }
               gridView.EditIndex = -1;
               ButtonAdd.Enabled = true;
               PopulateGrid();
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

                    Label lblnameStartTime = (Label)e.Row.FindControl("lblnameStartTime");
                    if (lblnameStartTime != null)
                    {
                         lblnameStartTime.Text = DateTime.Parse(dr["starttime"].ToString()).ToString("hh:mm tt");
                    }
                    Label lblnameEndTime = (Label)e.Row.FindControl("lblnameEndTime");
                    if (lblnameEndTime != null)
                    {
                         lblnameEndTime.Text = DateTime.Parse(dr["stoptime"].ToString()).ToString("hh:mm tt");
                    }

                    TextBox TextBoxEditStartTime = (TextBox)e.Row.FindControl("TextBoxEditStartTime");
                    if (TextBoxEditStartTime != null)
                    {
                         TextBoxEditStartTime.Text = DateTime.Parse(dr["starttime"].ToString()).ToString("hh:mm tt");
                    }

                    TextBox TextBoxEditEndTime = (TextBox)e.Row.FindControl("TextBoxEditEndTime");
                    if (TextBoxEditEndTime != null)
                    {
                         TextBoxEditEndTime.Text = DateTime.Parse(dr["stoptime"].ToString()).ToString("hh:mm tt");
                    }
               }
          }

          protected void gridView_RowEditing(object sender, GridViewEditEventArgs e)
          {
               ButtonAdd.Enabled = false;
               HiddenFieldEditRowIndex.Value = e.NewEditIndex.ToString();
               gridView.EditIndex = e.NewEditIndex;
               PopulateGrid();
               Button _button = (Button)gridView.Rows[gridView.EditIndex].FindControl("ButtonAddEdit");
               _button.Visible = false;
          }

          protected void gridView_RowUpdating(object sender, GridViewUpdateEventArgs e)
          {
               TextBox TextBoxEditStartTime = (TextBox)gridView.Rows[e.RowIndex].FindControl("TextBoxEditStartTime");
               TextBox TextBoxEditEndTime = (TextBox)gridView.Rows[e.RowIndex].FindControl("TextBoxEditEndTime");
               HiddenField HiddenFieldIDEdit = (HiddenField)gridView.Rows[e.RowIndex].FindControl("HiddenFieldIDEdit");
               long _id = Convert.ToInt64(HiddenFieldIDEdit.Value);
               DateTime _startTime = DateTime.Parse(DateTime.MinValue.ToString("MM/dd/yyyy") + " " + TextBoxEditStartTime.Text);
               DateTime _endTime = DateTime.Parse(DateTime.MinValue.ToString("MM/dd/yyyy") + " " + TextBoxEditEndTime.Text);

               if (TimeEntryInThatRangeExist(_startTime, _endTime))
               {
                    return;
               }

               using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
               {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("TimeKeeper_SCHEDULEStartAndStopTemplate_Update", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@ID", _id);
                    cmd.Parameters.AddWithValue("@STARTTIME", new TimeSpan(_startTime.Hour, _startTime.Minute, 0));
                    cmd.Parameters.AddWithValue("@STOPTIME", new TimeSpan(_endTime.Hour, _endTime.Minute, 0));

                    cmd.ExecuteNonQuery();
               }

               gridView.EditIndex = -1;
               ButtonAdd.Enabled = true;
               PopulateGrid();
          }
          protected void gridView_RowCommand(object sender, GridViewCommandEventArgs e)
          {
               string _txtStartTime = string.Empty;
               string _txtEndTime = string.Empty;
               string _errMsg = string.Empty;
               string _DatePortion = DateTime.MinValue.ToString("MM/dd/yyyy");
               DateTime _startTime;
               DateTime _endTime;

               if (e.CommandName.Equals("AddNew"))
               {
                    _txtStartTime = ((TextBox)gridView.Rows[0].FindControl("TextBoxEditStartTime")).Text;
                    _txtEndTime = ((TextBox)gridView.Rows[0].FindControl("TextBoxEditEndTime")).Text;

                    _startTime = DateTime.Parse(_DatePortion + " " + _txtStartTime);
                    _endTime = DateTime.Parse(_DatePortion + " " + _txtEndTime);


                    // Sanity check make sure end time is latter than start time otherwise display error
                    if (_startTime >= _endTime)
                    {
                         _errMsg = "Start time must be latter than end time.\\nPlease correct time entry\\nand try again.";
                         ScriptManager.RegisterClientScriptBlock(Page, typeof(Page), "ClientScript", "alert('" + _errMsg + "')", true);
                         return;
                    }

                    if (TimeEntryInThatRangeExist(_startTime, _endTime))
                    {
                         _errMsg = "You already have an entry in that time range\\nPlease modify that entry\\nand try again.";
                         ScriptManager.RegisterClientScriptBlock(Page, typeof(Page), "ClientScript", "alert('" + _errMsg + "')", true);
                         return;
                    }

                    InsertRecord(_startTime, _endTime);
                    gridView.EditIndex = -1;
                    ButtonAdd.Enabled = true;
                    PopulateGrid();
               }
               else if (e.CommandName.Equals("StartTimePickerToggle"))
               {
                    StartTimePickerToggle();
               }
               else if (e.CommandName.Equals("StopTimePickerToggle"))
               {
                    StopTimePickerToggle();
               }
               else if (e.CommandName.Equals("SaveStartTime"))
               {
                    RowSaveStartTime();
               }
               else if (e.CommandName.Equals("SaveStopTime"))
               {
                    RowSaveStopTime();
               }

          }
          public void RowSaveStopTime()
          {
               int _index = Convert.ToInt32(HiddenFieldEditRowIndex.Value);

               Label _labelStopTimeError = ((Label)gridView.Rows[_index].FindControl("LabelStopTimeError"));
               _labelStopTimeError.Text = string.Empty;

               TextBox _textBoxStartTime = ((TextBox)gridView.Rows[_index].FindControl("TextBoxEditStartTime"));

               if (string.IsNullOrEmpty(_textBoxStartTime.Text))
               {
                    _labelStopTimeError.Text = "Must specify a start time<br/>";
                    return;
               }

               DropDownList _dropDownListStopHour = ((DropDownList)gridView.Rows[_index].FindControl("DropDownListStopHour"));
               DropDownList _dropDownListStopAMPM = ((DropDownList)gridView.Rows[_index].FindControl("DropDownListStopAMPM"));
               DropDownList _dropDownListStopMinutes = ((DropDownList)gridView.Rows[_index].FindControl("DropDownListStopMinutes"));

               string _timeValue = _dropDownListStopHour.SelectedValue + ":" + _dropDownListStopMinutes.SelectedValue + " " + _dropDownListStopAMPM.SelectedValue;
               DateTime _start = DateTime.Parse("01-01-2000 " + _textBoxStartTime.Text);
               DateTime _end = DateTime.Parse("01-01-2000 " + _timeValue);

               if (_start >= _end)
               {
                    _labelStopTimeError.Text = "Stop time must be after start time<br/>";
                    return;
               }

               TextBox _textBoxEditEndTime = ((TextBox)gridView.Rows[_index].FindControl("TextBoxEditEndTime"));
               _textBoxEditEndTime.Text = _timeValue;
               _dropDownListStopHour.SelectedValue = "12";
               _dropDownListStopMinutes.SelectedValue = "00";
               _dropDownListStopAMPM.SelectedValue = "AM";

               Panel _panelPickStopTime = ((Panel)gridView.Rows[_index].FindControl("PanelPickStopTime"));
               _panelPickStopTime.Visible = false;
          }

          public void RowSaveStartTime()
          {
               int _index = Convert.ToInt32(HiddenFieldEditRowIndex.Value);
               DropDownList _dropDownListBoxHoursStart = ((DropDownList)gridView.Rows[_index].FindControl("DropDownListBoxHoursStart"));
               DropDownList _dropDownListMinutesStart = ((DropDownList)gridView.Rows[_index].FindControl("DropDownListMinutesStart"));
               DropDownList _dropDownListAMPMStart = ((DropDownList)gridView.Rows[_index].FindControl("DropDownListAMPMStart"));
               TextBox _textBoxStartTime = ((TextBox)gridView.Rows[_index].FindControl("TextBoxEditStartTime"));
               Panel panelPickStartTime = ((Panel)gridView.Rows[_index].FindControl("PanelPickStartTime"));


               string _timeValue = _dropDownListBoxHoursStart.SelectedValue + ":" + _dropDownListMinutesStart.SelectedValue + " " + _dropDownListAMPMStart.SelectedValue;
               _textBoxStartTime.Text = _timeValue;
               _dropDownListBoxHoursStart.SelectedValue = "12";
               _dropDownListMinutesStart.SelectedValue = "00";
               _dropDownListAMPMStart.SelectedValue = "AM";
               panelPickStartTime.Visible = false;
               Page.SetFocus(_textBoxStartTime);
          }
          public void StartTimePickerToggle()
          {
               int _index = Convert.ToInt32(HiddenFieldEditRowIndex.Value);
               Panel _panelPickStartTime = ((Panel)gridView.Rows[_index].FindControl("PanelPickStartTime"));

               if (_panelPickStartTime.Visible)
               {
                    _panelPickStartTime.Visible = false;
               }
               else
               {
                    _panelPickStartTime.Visible = true;
               }
          }
          public void StopTimePickerToggle()
          {
               int _index = Convert.ToInt32(HiddenFieldEditRowIndex.Value);
               Panel _panelPickStopTime = ((Panel)gridView.Rows[_index].FindControl("PanelPickStopTime"));

               if (_panelPickStopTime.Visible)
               {
                    _panelPickStopTime.Visible = false;
               }
               else
               {
                    _panelPickStopTime.Visible = true;
               }
          }

          private void PopulateGrid()
          {
               using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
               {
                    SqlDataAdapter _dataAdapter = new SqlDataAdapter("TimeKeeper_SCHEDULE_GetTemplateStartAndStopTimesByScheduledDate", _con);
                    _dataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
                    _dataAdapter.SelectCommand.Parameters.Add("@ScheduleDayId", SqlDbType.BigInt).Value = Convert.ToInt64(HiddenFieldScheduleTemplateDayId.Value);
                    DataSet _dataSet = new DataSet();
                    _dataAdapter.Fill(_dataSet);

                    if (_dataSet.Tables[0].Rows.Count > 0)
                    {
                         gridView.DataSource = _dataSet;
                         gridView.DataBind();
                    }
                    else
                    {
                         gridView.DataSource = null;
                         gridView.DataBind();
                    }
               }
          }

          private void InsertRecord(DateTime startTime, DateTime endTime)
          {
               try
               {
                    if (HiddenFieldScheduleTemplateDayId.Value == "0")
                    {
                         throw new Exception("Missing parent record");
                    }

                    using (SqlConnection con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
                    {
                         long _scheduleId = Convert.ToInt64(HiddenFieldScheduleTemplateDayId.Value);

                         con.Open();
                         SqlCommand cmd = new SqlCommand("TimeKeeper_SCHEDULE_TEMPLATE_STOP_START_CreateNew", con);
                         cmd.CommandType = CommandType.StoredProcedure;
                         cmd.Parameters.AddWithValue("@ScheduleDayId", _scheduleId);
                         cmd.Parameters.AddWithValue("@StartTime", new TimeSpan(startTime.Hour, startTime.Minute, 0));
                         cmd.Parameters.AddWithValue("@StopTime", new TimeSpan(endTime.Hour, endTime.Minute, 0));
                         cmd.Parameters.Add("@Id", SqlDbType.BigInt);
                         cmd.Parameters["@Id"].Direction = ParameterDirection.Output;

                         cmd.ExecuteNonQuery();
                    }
               }
               catch (Exception _exception)
               {
                    string _error = _exception.Message;
                    string _url = MBA.HttpApplication.createLink("InsertEditScheduleTemplate.aspx", true)
                        + "&scheduleTemplateId=" + HiddenFieldScheduleTemplateId.Value + "&employeeid=" + HiddenFieldEmployeeID.Value;
                    //gotoNewURL(_url);
                    Response.Redirect(_url, false);
               }
          }

          private bool TimeEntryInThatRangeExist(DateTime newStartTime, DateTime newEndTime)
          {
               if (HiddenFieldScheduleTemplateId.Value == "0")
               {
                    return false; // Indicates a new record
               }

               Label lblnameStartTime = null;
               Label lblnameEndTime = null;
               DateTime _gridStartTime = DateTime.MinValue;
               DateTime _gridEndTime = DateTime.MaxValue;

               foreach (GridViewRow row in gridView.Rows)
               {
                    lblnameStartTime = (Label)row.FindControl("lblnameStartTime");

                    if (lblnameStartTime == null)
                    {
                         continue;
                    }

                    lblnameEndTime = (Label)row.FindControl("lblnameEndTime");

                    _gridStartTime = DateTime.Parse(DateTime.MinValue.ToString("MM/dd/yyyy") + " " + lblnameStartTime.Text);
                    _gridEndTime = DateTime.Parse(DateTime.MinValue.ToString("MM/dd/yyyy") + " " + lblnameEndTime.Text);

                    // New start time must be before existing start time and new end time is before any existing
                    // start time.  there is no overlap in this row
                    if ((newStartTime < _gridStartTime) && (newEndTime <= _gridStartTime))
                    {
                         continue;
                    }

                    // New start time is after existing stop time, there is no overlap in this row
                    if (newStartTime >= _gridEndTime)
                    {
                         continue;
                    }

                    // If you get to this point there is an overlap
                    return true;
               }

               // You get to this point. There is no overlap
               return false;
          }

          protected void ButtonAdd_Click(object sender, EventArgs e)
          {
               using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
               {
                    SqlDataAdapter da = new SqlDataAdapter("TimeKeeper_SCHEDULE_GetStartAndStopTimesForScheduleTemplate", _con);
                    da.SelectCommand.CommandType = CommandType.StoredProcedure;
                    da.SelectCommand.Parameters.Add("@TemplateScheduleDayid", SqlDbType.BigInt).Value = Convert.ToInt64(HiddenFieldScheduleTemplateDayId.Value);
                    DataSet _dataSet = new DataSet();
                    da.Fill(_dataSet);

                    _dataSet.Tables[0].Rows.InsertAt(_dataSet.Tables[0].NewRow(), 0);

                    HiddenFieldEditRowIndex.Value = "0";
                    gridView.EditIndex = 0;
                    gridView.DataSource = _dataSet;
                    gridView.DataBind();

                    GridViewRow _gridRow = gridView.Rows[0];

                    Button _buttonUpdate = (Button)_gridRow.FindControl("ButtonUpdate");

                    _buttonUpdate.Visible = false;
                    ButtonAdd.Enabled = false;

               }
          }

          protected void GridView1_Sorting(object sender, GridViewSortEventArgs e)
          {
               switch (e.SortExpression)
               {
                    case "Start":
                        ButtonAdd.Enabled = true;
                        HiddenFieldEditRowIndex.Value = "-1";
                        gridView.EditIndex = -1;
                        BindStartTime();
                         break;
                    case "End":
                        ButtonAdd.Enabled = true;
                        HiddenFieldEditRowIndex.Value = "-1";
                        gridView.EditIndex = -1;
                        BindStopTime();
                         break;
               }
          }

          private void BindStopTime()
          {
               using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
               {
                    if (HiddenFieldStop.Value == "ASC")
                    {
                         HiddenFieldStop.Value = "DESC";
                    }
                    else
                    {
                         HiddenFieldStop.Value = "ASC";
                    }

                    string _sqlStatement =
                      @"SELECT 
		                    [id]
		                    ,[autoPopulateScheduleDaysId]
		                    ,[starttime]
		                    ,[stoptime]
	                    FROM 
		                    [TimeKeeper].[dbo].[AutoPopulateScheduleStartAndStopTime]
	                    WHERE
		                    [autoPopulateScheduleDaysId] = @AutoPopulateScheduleDaysId
                        ORDER BY stoptime " + HiddenFieldStop.Value;

                    SqlDataAdapter sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                    sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@AutoPopulateScheduleDaysId", HiddenFieldScheduleTemplateDayId.Value);

                    DataSet _dataSet = new DataSet();
                    sqlDataAdapter.Fill(_dataSet);

                    if (_dataSet.Tables[0].Rows.Count <= 0)
                    {
                         gridView.DataSource = null;
                         gridView.DataBind();
                         return;
                    }

                    gridView.DataSource = _dataSet;
                    gridView.DataBind();
               }
          }

          private void BindStartTime()
          {
               using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
               {
                    if (HiddenFieldStart.Value == "ASC")
                    {
                         HiddenFieldStart.Value = "DESC";
                    }
                    else
                    {
                         HiddenFieldStart.Value = "ASC";
                    }

                    string _sqlStatement =
                      @"SELECT 
		                    [id]
		                    ,[autoPopulateScheduleDaysId]
		                    ,[starttime]
		                    ,[stoptime]
	                    FROM 
		                    [TimeKeeper].[dbo].[AutoPopulateScheduleStartAndStopTime]
	                    WHERE
		                    [autoPopulateScheduleDaysId] = @AutoPopulateScheduleDaysId" + HiddenFieldScheduleTemplateDayId.Value + @"
                        ORDER BY starttime " + HiddenFieldStart.Value;

                    SqlDataAdapter sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                    sqlDataAdapter.SelectCommand.Parameters.AddWithValue("@AutoPopulateScheduleDaysId", HiddenFieldScheduleTemplateDayId.Value);
                    DataSet _dataSet = new DataSet();
                    sqlDataAdapter.Fill(_dataSet);

                    if (_dataSet.Tables[0].Rows.Count <= 0)
                    {
                         gridView.DataSource = null;
                         gridView.DataBind();
                         return;
                    }

                    gridView.DataSource = _dataSet;
                    gridView.DataBind();
               }
          }
     }
}
