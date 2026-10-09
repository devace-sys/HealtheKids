using MBA.BitteTime;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace Spedmon
{
     public partial class TimeEntryScheduleAdminTemplate : WebUI
     {
          public TimeEntryScheduleAdminTemplate()
               : base("timeentry", WebUI.CreatePageSubTitle("Schedule Admin", "Create, update, or delete schedule templates"),
                "", "", Constants.ROLE_SBS_ALL)
          { 
          }

          protected void Page_Load(object sender, EventArgs e)
          {
            string _url = MBA.HttpApplication.createLink("TimeEntryScheduleAdmin.aspx", true);
            Response.Redirect(_url, false);
            return;

            /* Disable access to this page for now
             * 
            if (rd.wu.usr.timeSheetUserInfo == null)
            {
                rd.wu.usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(rd.wu.usr.userName);
            }
            if (rd.wu.usr.timeSheetUserInfo.roleID != 1 && rd.wu.usr.timeSheetUserInfo.roleID != 3)
            {
                string _url = MBA.HttpApplication.createLink("TimeEntryScheduleAdmin.aspx", true);
                Response.Redirect(_url, false);
                return;
            }
            if (!IsPostBack)
            {
                 GetExistingTemplates();
            }
            */
          }

          private void GetExistingTemplates()
          {
               string _sqlStatement = @"
            select
	            APST.id AS TemplateId
	            ,APST.name AS TemplateName
	            ,APST.description AS TemplateDescription
	            ,ISNULL(APSD.id, -1) AS AutoScheduleDaysId
	            ,ISNULL(DOW.id, -1) AS DayOfWeekId
	            ,ISNULL(DOW.day, '') AS DayOfWeek
	            ,ISNULL(APSST.id, -1) AS StartStopTimeId
	            ,ISNULL(APSST.starttime, '') AS StartTime
	            ,ISNULL(APSST.stoptime, '') AS EndTime
            from
	            TimeKeeper.dbo.AutoPopulateScheduleTemplate APST
	            left join TimeKeeper.dbo.AutoPopulateScheduleDays APSD
		            ON APSD.scheduleid = APST.id
	            left join TimeKeeper.dbo.DaysOfTheWeek DOW
		            ON DOW.id = APSD.dayId
	            left join timeKeeper.dbo.AutoPopulateScheduleStartAndStopTime APSST
		            ON APSST.autoPopulateScheduleDaysId = APSD.id
            order by
	            APST.id,
				APSD.id,
				DOW.id";

               using (SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]))
               {
                    _con.Open();

                    SqlDataAdapter _sqlDataAdapter = new SqlDataAdapter(_sqlStatement, _con);
                    DataTable _dataTable = new DataTable();
                    _sqlDataAdapter.Fill(_dataTable);

                    ProcessRecords(_dataTable);
               }
          }

          private void ProcessRecords(DataTable dataTable)
          {
               List<ScheduleTemplate> _listScheduleTemplates = new List<ScheduleTemplate>();
               ScheduleTemplate _scheduleTemplate = null;
               int _dayOfWeek = 0;
               TimeSpan _timeSpan;
               int _idCurrent = 0;
               int[] _arrayMinutes = null;

               _arrayMinutes = new int[7];
               foreach (DataRow _dataRow in dataTable.Rows)
               {
                    // Get totals for template before processing new one
                    if (_idCurrent == 0)
                    {
                         _idCurrent = int.Parse(_dataRow["TemplateId"].ToString());

                         _scheduleTemplate = new ScheduleTemplate();
                         _scheduleTemplate.id = long.Parse(_dataRow["TemplateId"].ToString());
                         _scheduleTemplate.TemplateName = _dataRow["TemplateName"].ToString();

                         _scheduleTemplate.SundayInfo = string.Empty;
                         _scheduleTemplate.MondayInfo = string.Empty;
                         _scheduleTemplate.TuesdayInfo = string.Empty;
                         _scheduleTemplate.WednesdayInfo = string.Empty;
                         _scheduleTemplate.ThursdayInfo = string.Empty;
                         _scheduleTemplate.FridayInfo = string.Empty;
                         _scheduleTemplate.SaturdayInfo = string.Empty;
                    }
                    else if (_idCurrent != int.Parse(_dataRow["TemplateId"].ToString()))
                    {
                         _idCurrent = int.Parse(_dataRow["TemplateId"].ToString());

                         DisplayTimeSpanScheduled(_scheduleTemplate, _arrayMinutes);
                         _arrayMinutes = new int[7];

                         _listScheduleTemplates.Add(_scheduleTemplate);
                         _scheduleTemplate = new ScheduleTemplate();
                         _scheduleTemplate.id = long.Parse(_dataRow["TemplateId"].ToString());
                         _scheduleTemplate.TemplateName = _dataRow["TemplateName"].ToString();
                         _scheduleTemplate.SundayInfo = string.Empty;
                         _scheduleTemplate.MondayInfo = string.Empty;
                         _scheduleTemplate.TuesdayInfo = string.Empty;
                         _scheduleTemplate.WednesdayInfo = string.Empty;
                         _scheduleTemplate.ThursdayInfo = string.Empty;
                         _scheduleTemplate.FridayInfo = string.Empty;
                         _scheduleTemplate.SaturdayInfo = string.Empty;
                    }

                    if ((_dataRow["AutoScheduleDaysId"].ToString() == "-1") || (_dataRow["DayOfWeekId"].ToString() == "-1"))
                    {
                         continue;
                    }

                    if (_dataRow["StartStopTimeId"].ToString() == "-1")
                    {
                         continue;
                    }

                    _dayOfWeek = int.Parse(_dataRow["DayOfWeekId"].ToString());
                    _timeSpan = DateTime.Parse(_dataRow["EndTime"].ToString()) - DateTime.Parse(_dataRow["StartTime"].ToString());

                    _arrayMinutes[_dayOfWeek] += (int)_timeSpan.TotalMinutes;
                    switch (_dayOfWeek)
                    {
                         case 0:
                              if (string.IsNullOrEmpty(_scheduleTemplate.SundayInfo) || (_scheduleTemplate.SundayInfo == string.Empty))
                              {
                                   _scheduleTemplate.SundayInfo = DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                       + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                       + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                              }
                              else
                              {
                                   _scheduleTemplate.SundayInfo += "<br/>" + DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                       + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                       + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                              }
                              break;
                         case 1:
                              if (string.IsNullOrEmpty(_scheduleTemplate.MondayInfo) || (_scheduleTemplate.MondayInfo == string.Empty))
                              {
                                   _scheduleTemplate.MondayInfo = DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                       + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                       + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                              }
                              else
                              {
                                   _scheduleTemplate.MondayInfo += "<br/>" + DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                       + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                       + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                              }
                              break;
                         case 2:
                              if (string.IsNullOrEmpty(_scheduleTemplate.TuesdayInfo) || (_scheduleTemplate.TuesdayInfo == string.Empty))
                              {
                                   _scheduleTemplate.TuesdayInfo = DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                       + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                       + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                              }
                              else
                              {
                                   _scheduleTemplate.TuesdayInfo += "<br/>" + DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                       + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                       + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                              }
                              break;
                         case 3:
                              if (string.IsNullOrEmpty(_scheduleTemplate.WednesdayInfo) || (_scheduleTemplate.WednesdayInfo == string.Empty))
                              {
                                   _scheduleTemplate.WednesdayInfo = DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                       + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                       + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                              }
                              else
                              {
                                   _scheduleTemplate.WednesdayInfo += "<br/>" + DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                       + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                       + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                              }
                              break;
                         case 4:
                              if (string.IsNullOrEmpty(_scheduleTemplate.ThursdayInfo) || (_scheduleTemplate.ThursdayInfo == string.Empty))
                              {
                                   _scheduleTemplate.ThursdayInfo = DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                       + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                       + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                              }
                              else
                              {
                                   _scheduleTemplate.ThursdayInfo += "<br/>" + DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                       + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                       + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                              }
                              break;
                         case 5:
                              if (string.IsNullOrEmpty(_scheduleTemplate.FridayInfo) || (_scheduleTemplate.FridayInfo == string.Empty))
                              {
                                   _scheduleTemplate.FridayInfo = DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                       + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                       + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                              }
                              else
                              {
                                   _scheduleTemplate.FridayInfo += "<br/>" + DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                       + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                       + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                              }
                              break;
                         case 6:
                              if (string.IsNullOrEmpty(_scheduleTemplate.SaturdayInfo) || (_scheduleTemplate.SaturdayInfo == string.Empty))
                              {
                                   _scheduleTemplate.SaturdayInfo = DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                       + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                       + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                              }
                              else
                              {
                                   _scheduleTemplate.SaturdayInfo += "<br/>" + DateTime.Parse(_dataRow["StartTime"].ToString()).ToString("hh:mm tt")
                                       + "&nbsp;&nbsp;&nbsp;&nbsp;"
                                       + DateTime.Parse(_dataRow["EndTime"].ToString()).ToString("hh:mm tt");
                              }
                              break;
                    }
               }

               if (_scheduleTemplate != null)
               {
                    DisplayTimeSpanScheduled(_scheduleTemplate, _arrayMinutes);
                    _listScheduleTemplates.Add(_scheduleTemplate);
               }

               GridView1.DataSource = _listScheduleTemplates;
               GridView1.DataBind();
          }

          private void DisplayTimeSpanScheduled(ScheduleTemplate scheduleTemplate, int[] arrayMinutes)
          {
               int _hours = 0;
               int _minutes = 0;

               for (int _counter = 0; _counter < 7; _counter++)
               {
                    if ((arrayMinutes[_counter] == 0) || (scheduleTemplate == null))
                    {
                         continue;
                    }

                    _hours = (int)((double)arrayMinutes[_counter] / 60.0);
                    _minutes = arrayMinutes[_counter] % 60;

                    switch (_counter)
                    {
                         case 0:
                              scheduleTemplate.SundayInfo += "<br/>" + _hours.ToString() + " Hours";
                              if (_minutes > 0)
                              {
                                   scheduleTemplate.SundayInfo += "&nbsp;&nbsp;&nbsp;&nbsp;" + _minutes.ToString() + " Minutes";
                              }
                              break;
                         case 1:
                              scheduleTemplate.MondayInfo += "<br/>" + _hours.ToString() + " Hours";
                              if (_minutes > 0)
                              {
                                   scheduleTemplate.MondayInfo += "&nbsp;&nbsp;&nbsp;&nbsp;" + _minutes.ToString() + " Minutes";
                              }
                              break;
                         case 2:
                              scheduleTemplate.TuesdayInfo += "<br/>" + _hours.ToString() + " Hours";
                              if (_minutes > 0)
                              {
                                   scheduleTemplate.TuesdayInfo += "&nbsp;&nbsp;&nbsp;&nbsp;" + _minutes.ToString() + " Minutes";
                              }
                              break;
                         case 3:
                              scheduleTemplate.WednesdayInfo += "<br/>" + _hours.ToString() + " Hours";
                              if (_minutes > 0)
                              {
                                   scheduleTemplate.WednesdayInfo += "&nbsp;&nbsp;&nbsp;&nbsp;" + _minutes.ToString() + " Minutes";
                              }
                              break;
                         case 4:
                              scheduleTemplate.ThursdayInfo += "<br/>" + _hours.ToString() + " Hours";
                              if (_minutes > 0)
                              {
                                   scheduleTemplate.ThursdayInfo += "&nbsp;&nbsp;&nbsp;&nbsp;" + _minutes.ToString() + " Minutes";
                              }
                              break;
                         case 5:
                              scheduleTemplate.FridayInfo += "<br/>" + _hours.ToString() + " Hours";
                              if (_minutes > 0)
                              {
                                   scheduleTemplate.TuesdayInfo += "&nbsp;&nbsp;&nbsp;&nbsp;" + _minutes.ToString() + " Minutes";
                              }
                              break;
                         case 6:
                              scheduleTemplate.SaturdayInfo += "<br/>" + _hours.ToString() + " Hours";
                              if (_minutes > 0)
                              {
                                   scheduleTemplate.WednesdayInfo += "&nbsp;&nbsp;&nbsp;&nbsp;" + _minutes.ToString() + " Minutes";
                              }
                              break;
                    }
                    arrayMinutes[_counter] = 0;
               }
          }
          protected void ButtonAddTask_Click1(object sender, EventArgs e)
          {
               string _url = MBA.HttpApplication.createLink("InsertEditScheduleTemplate.aspx", true) + "&scheduleTemplateId=0";
               Response.Redirect(_url, false);
          }

          protected void ButtonBack_Click(object sender, EventArgs e)
          {
               string _url = MBA.HttpApplication.createLink("TimeEntryScheduleAdmin.aspx", true);
               Response.Redirect(_url, false);
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
                        update [TimeKeeper].[dbo].[Employees]
                        set autoPopulateSdheduleTemplateId = null
                        where
                            autoPopulateSdheduleTemplateId = @Id";
                    using (SqlCommand _cmd = new SqlCommand(_sqlCommand, _con))
                    {
                        _cmd.Parameters.AddWithValue("@Id", HiddenFieldItemTemplateIDEdit.Value);
                        _cmd.ExecuteNonQuery();
                        _cmd.CommandText = @"
                            delete [TimeKeeper].[dbo].[AutoPopulateScheduleTemplate]
                            where
                                id = @Id";
                        _cmd.Parameters.Clear();
                        _cmd.Parameters.AddWithValue("@Id", HiddenFieldItemTemplateIDEdit.Value);
                        _cmd.ExecuteNonQuery();
                    }
                    GetExistingTemplates();
               }

          }

          protected void GridView1_RowEditing(object sender, GridViewEditEventArgs e)
          {
               HiddenField HiddenFieldItemTemplateIDEdit = (HiddenField)GridView1.Rows[e.NewEditIndex].FindControl("HiddenFieldItemTemplateIDEdit");

               string _url = MBA.HttpApplication.createLink("InsertEditScheduleTemplate.aspx", true) + "&scheduleTemplateId=" +
                   HiddenFieldItemTemplateIDEdit.Value;
               Response.Redirect(_url, false);

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
          }

          protected void GridView1_Sorting(object sender, GridViewSortEventArgs e)
          {
          }
     }
}
