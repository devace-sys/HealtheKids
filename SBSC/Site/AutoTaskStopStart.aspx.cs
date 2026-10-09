using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Spedmon
{
    public partial class AutoTaskStopStart : WebUI
    {
        class AutoTaskStartStopTime
        {
            public string startTime { get; set; }
            public string stopTime { get; set; }
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string _startStop = Request.QueryString["startstop"];
                LoadStartStop(_startStop);
                labelMessage.Text = string.Empty;

                HiddenFieldTaskId.Value = Request.QueryString["taskid"];
                HiddenFieldDay.Value = Request.QueryString["day"];
                HiddenFieldEmployeeId.Value = Request.QueryString["employeeid"];
                HiddenFieldTemplateID.Value = Request.QueryString["scheduleTemplateId"];
            }
        }
        public AutoTaskStopStart()
             : base("autotaskstopstart", WebUI.CreatePageSubTitle("Auto Stop Start", "Create or Update Task Template Start Stop Times"), "", "", Constants.ROLE_SBS_ALL)
        {
        }

        private void LoadStartStop(string startStop)
        {
            string[] _stopStartTimes = startStop.Split('|');
            int _length = _stopStartTimes.Length;
            int _lengthRecord = 0;
            string _record;
            string[] _recordField;
            List<AutoTaskStartStopTime> _listStartStop = new List<AutoTaskStartStopTime>();
            AutoTaskStartStopTime _autoStartStop = null;

            for (int _counter = 0; _counter < _length; _counter++)
            {
                _record = _stopStartTimes[_counter];
                if (string.IsNullOrEmpty(_record.Trim()))
                {
                    continue;
                }
                _recordField = _record.Split('-');
                _lengthRecord = _recordField.Length;
                _autoStartStop = new AutoTaskStartStopTime();
                _autoStartStop.startTime = _recordField[0];
                _autoStartStop.stopTime = _recordField[1];
                _listStartStop.Add(_autoStartStop);
            }
            repeaterTaskStartStopTemplateControl.DataSource = _listStartStop;
            repeaterTaskStartStopTemplateControl.DataBind();
        }
        protected void ButtonAdd_Click(object sender, EventArgs e)
        {
            List<AutoTaskStartStopTime> _listStartStopTime = new List<AutoTaskStartStopTime>();
            Label labelBoxStartTime;
            Label labelBoxStopTime;
            AutoTaskStartStopTime _autoStartStopTime = null;

            foreach (RepeaterItem _item in repeaterTaskStartStopTemplateControl.Items)
            {
                labelBoxStartTime = ((Label)_item.FindControl("labelBoxStartTime"));
                labelBoxStopTime = ((Label)_item.FindControl("labelBoxStopTime"));

                if ((labelBoxStartTime == null) || (labelBoxStopTime == null))
                {
                    continue;
                }
                _autoStartStopTime = new AutoTaskStartStopTime();
                _autoStartStopTime.startTime = labelBoxStartTime.Text;
                _autoStartStopTime.stopTime = labelBoxStopTime.Text;
                _listStartStopTime.Add(_autoStartStopTime);
            }
            _listStartStopTime.Add(new AutoTaskStartStopTime());

            repeaterTaskStartStopTemplateControl.DataSource = _listStartStopTime;
            repeaterTaskStartStopTemplateControl.DataBind();
        }
        protected void ButtonDelete_Click(object sender, EventArgs e)
        {
            RepeaterItem _item = ((sender as Button).NamingContainer as RepeaterItem);
            Label labelBoxStartTime = (Label)_item.FindControl("labelBoxStartTime");
            Label labelBoxStopTime = (Label)_item.FindControl("labelBoxStopTime");

            if (string.IsNullOrEmpty(labelBoxStartTime.Text.Trim()) || string.IsNullOrEmpty(labelBoxStopTime.Text.Trim()))
            {
                return;
            }

            List<AutoTaskStartStopTime> _listAutoTaskStartStopTime = new List<AutoTaskStartStopTime>();
            Label labelBoxStartTimeInGrid = null;
            Label labelBoxStopTimeInGrid = null;

            foreach (RepeaterItem rptItem in repeaterTaskStartStopTemplateControl.Items)
            {
                labelBoxStartTimeInGrid = (Label)rptItem.FindControl("labelBoxStartTime");
                labelBoxStopTimeInGrid = (Label)rptItem.FindControl("labelBoxStopTime");

                if ((labelBoxStartTimeInGrid.Text == labelBoxStartTime.Text) &&
                    (labelBoxStopTimeInGrid.Text == labelBoxStopTime.Text))
                {
                    continue;
                }
                _listAutoTaskStartStopTime.Add(new AutoTaskStartStopTime()
                {
                    startTime = labelBoxStartTimeInGrid.Text,
                    stopTime = labelBoxStopTimeInGrid.Text
                });
            }

            repeaterTaskStartStopTemplateControl.DataSource = _listAutoTaskStartStopTime;
            repeaterTaskStartStopTemplateControl.DataBind();
        }
        protected void ImageButtonStartTime_Click(object sender, ImageClickEventArgs e)
        {
            RepeaterItem _item = ((sender as ImageButton).NamingContainer as RepeaterItem);
            Panel PanelPickStartTime = (Panel)_item.FindControl("PanelPickStartTime");
            PanelPickStartTime.Visible = !PanelPickStartTime.Visible;
            Panel PanelPickStopTime = (Panel)_item.FindControl("PanelPickStopTime");
            PanelPickStopTime.Visible = false;
        }

        protected void ImageButtonStopTime_Click(object sender, ImageClickEventArgs e)
        {
            RepeaterItem _item = ((sender as ImageButton).NamingContainer as RepeaterItem);
            Panel PanelPickStopTime = (Panel)_item.FindControl("PanelPickStopTime");
            PanelPickStopTime.Visible = !PanelPickStopTime.Visible;
            Panel PanelPickStartTime = (Panel)_item.FindControl("PanelPickStartTime");
            PanelPickStartTime.Visible = false;
        }

        protected void ButtonSelectStopTime_Click(object sender, EventArgs e)
        {
            RepeaterItem _item = ((sender as Button).NamingContainer as RepeaterItem);
            DropDownList DropDownListBoxHoursStop = (DropDownList)_item.FindControl("DropDownListBoxHoursStop");
            DropDownList DropDownListMinutesStop = (DropDownList)_item.FindControl("DropDownListMinutesStop");
            DropDownList DropDownListAMPMStop = (DropDownList)_item.FindControl("DropDownListAMPMStop");
            Label labelBoxStartTime = (Label)_item.FindControl("labelBoxStartTime");
            Label labelBoxStopTime = (Label)_item.FindControl("labelBoxStopTime");

            string stopTime = DropDownListBoxHoursStop.SelectedValue + ":" + DropDownListMinutesStop.SelectedValue + " "
                + DropDownListAMPMStop.SelectedValue;

            if (!EntryIsDuplicate(labelBoxStartTime.Text, stopTime))
            {
                labelBoxStopTime.Text = stopTime;
            }

            Panel PanelPickStopTime = (Panel)_item.FindControl("PanelPickStopTime");
            PanelPickStopTime.Visible = false;
        }
        protected void ButtonSelectStartTime_Click(object sender, EventArgs e)
        {
            RepeaterItem _item = ((sender as Button).NamingContainer as RepeaterItem);
            DropDownList DropDownListBoxHoursStart = (DropDownList)_item.FindControl("DropDownListBoxHoursStart");
            DropDownList DropDownListMinutesStart = (DropDownList)_item.FindControl("DropDownListMinutesStart");
            DropDownList DropDownListAMPMStart = (DropDownList)_item.FindControl("DropDownListAMPMStart");
            Label labelBoxStartTime = (Label)_item.FindControl("labelBoxStartTime");
            Label labelBoxStopTime = (Label)_item.FindControl("labelBoxStopTime");

            string startTime = DropDownListBoxHoursStart.SelectedValue + ":" + DropDownListMinutesStart.SelectedValue + " "
                + DropDownListAMPMStart.SelectedValue;

            if (!EntryIsDuplicate(startTime, labelBoxStopTime.Text))
            {
                labelBoxStartTime.Text = startTime;
            }

            Panel PanelPickStartTime = (Panel)_item.FindControl("PanelPickStartTime");
            PanelPickStartTime.Visible = false;
        }
        protected void ButtonBackToTaskTemplate_Click(object sender, EventArgs e)
        {
            Label labelBoxStartTime;
            Label labelBoxStopTime;
            string _startStopTimes = string.Empty;

            foreach (RepeaterItem rptItem in repeaterTaskStartStopTemplateControl.Items)
            {
                labelBoxStartTime = (Label)rptItem.FindControl("labelBoxStartTime");
                labelBoxStopTime = (Label)rptItem.FindControl("labelBoxStopTime");

                if (labelBoxStartTime == null ||
                    labelBoxStopTime == null ||
                    string.IsNullOrEmpty(labelBoxStartTime.Text) || 
                    string.IsNullOrEmpty(labelBoxStartTime.Text))
                {
                    continue;
                }
                _startStopTimes += (string.IsNullOrEmpty(_startStopTimes) ? string.Empty : "|")
                    + labelBoxStartTime.Text + "-" + labelBoxStopTime.Text;
            }
            string _url = MBA.HttpApplication.createLink("InsertEditScheduleTemplate.aspx", true)
                + "&startstop=" + _startStopTimes + "&taskid=" + HiddenFieldTaskId.Value +
                "&day=" + HiddenFieldDay.Value + "&employeeid=" + HiddenFieldEmployeeId.Value
                + "&scheduleTemplateId=" + HiddenFieldTemplateID.Value;

            Response.Redirect(_url);
        }

        protected bool EntryIsDuplicate(string startTime, string stopTime)
        {
            labelMessage.Text = string.Empty;
            if (string.IsNullOrEmpty(startTime) || string.IsNullOrEmpty(stopTime))
            {
                return false;
            }

            foreach (RepeaterItem rptItem in repeaterTaskStartStopTemplateControl.Items)
            {
                Label labelBoxStartTime = (Label)rptItem.FindControl("labelBoxStartTime");
                Label labelBoxStopTime = (Label)rptItem.FindControl("labelBoxStopTime");

                if (labelBoxStartTime.Text == startTime && labelBoxStopTime.Text == stopTime)
                {
                    labelMessage.Text = "This is a duplicate entry";
                    return true;
                }
            }

            return false;
        }
    }
}