using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Text.RegularExpressions;

namespace WORKFLOW
{
    public partial class StaffHoursSave : Form
    {
        public StaffHoursSave()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private static StaffHoursSave m_SChildform1;

       /***************************************************************************
        * if not created yet or disposed, Create an instance of the form
        * if just created or created earlier.Return it
        ***************************************************************************/
        public static StaffHoursSave GetChildInstance()
        {
            if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
                m_SChildform1 = new StaffHoursSave();
            return m_SChildform1;
        }
        private string[] recID = new string[7];
        private double shift1start = 0;
        private double shift1end   = 0;
        private double shift2start = 0;
        private double shift2end   = 0;
        private double shift3start = 0;
        private double shift3end   = 0;
        private string[] savetype  = new string[7];
        private DateTime day;
        private int i = 0;
        public string userID;
        public string username;
        public DateTime DateStart;
        public TimeSpan shiftsTotal;
        public void StaffHours()
        {
            if (userID != null)
            {
                userlabel.Text = "Work Timings for " + username;
                workWeekdateTimePicker.Value = DateStart;
            }
        }
        private void StaffHoursSave_Load(object sender, EventArgs e)
        {
            userlabel.Text = "Work Timings for " + username;
            if (SBSCParent.isInputStaff)
            {
                userID = SBSCParent.userID.ToString();
                userlabel.Text = "Work Timings for " + SBSCParent.userName;
            }
            else
                if (userID != null)
                    workWeekdateTimePicker.Value = DateStart;
                else
                {
                    userID = SBSCParent.userID.ToString();
                    userlabel.Text = "Work Timings for " + Environment.UserName;
                }
            workWeekdateTimePicker_ValueChanged(sender, e);
            
        }

        public static DataGridViewRow dgvRow;

        private void LoadStaffHours(DateTime weekStart, string weekday, TextBox s1, TextBox s2, TextBox s3, TextBox note, NumericUpDown total)
        {
       /***************************************************************************
        * Load the controls if time is already filled
        ***************************************************************************/
            DataTable dt = new DataTable();
            FindDayDate(weekday);
            dt = WORKFLOW.Staff.StaffHoursView(SBSCParent.connSpedmon,userID, weekStart.ToShortDateString(), day.ToShortDateString(), "", "", "");
            if (dt.Rows.Count == 0)
            {
                recID[i] = "";
                savetype[i] = "1";                
            }
            else
            {
                savetype[i] = "2";
                savebutton.Text = "Update";
                DataRow dr = dt.Rows[0];
                recID[i] = dr["ID"].ToString();

                if (dr["SHIFT_1"] != DBNull.Value)
                   s1.Text = dr["SHIFT_1"].ToString().Replace(" ", string.Empty);                
                else
                    s1.Text = "";

                if (dr["SHIFT_2"] != DBNull.Value)
                    s2.Text = dr["SHIFT_2"].ToString().Replace(" ", string.Empty);
                else
                    s2.Text = "";

                if (dr["SHIFT_3"] != DBNull.Value)
                    s3.Text = dr["SHIFT_3"].ToString().Replace(" ", string.Empty);
                else
                    s3.Text = "";

                if (dr["DAYHOURS"] != DBNull.Value)
                    total.Value = Convert.ToDecimal(dr["DAYHOURS"]);
                else
                    s3.Text = "";

                if (dr["NOTE"] != DBNull.Value)
                    note.Text = dr["NOTE"].ToString();
                else note.Text = "";               
            }
        }

       /***************************************************************************
        * Method to find if the given value is a valid value for shift times
        ***************************************************************************/
        public bool IsValidTime(string thetime)
        {
            bool isvalid = true;
            try
            {
                Regex checktime1 =
                    new Regex(@"^[0-1][0-9][:|.][0-5][0-9](AM|PM|am|pm)[-][0-1][0-9][:|.][0-5][0-9](AM|PM|am|pm)$");
                Regex checktime3 =
                    new Regex(@"^[0-1][0-9][:|.][0-5][0-9](AM|PM|am|pm)[-][0-9]:[0-5][0-9](AM|PM|am|pm)$");
                Regex checktime4 =
                   new Regex(@"^[0-9]:[0-5][0-9](AM|PM|am|pm)[-][0-1][0-9][:|.][0-5][0-9](AM|PM|am|pm)$");
                Regex checktime2 =
                    new Regex(@"^[0-9]:[0-5][0-9](AM|PM|am|pm)[-][0-9]:[0-5][0-9](AM|PM|am|pm)$");
               

                if (checktime1.IsMatch(thetime) == false)
                    if (checktime2.IsMatch(thetime) == false) 
                        if (checktime3.IsMatch(thetime) == false)
                            if (checktime4.IsMatch(thetime) == false)                                
                            {
                                isvalid = false;
                                MessageBox.Show("Not a valid time, Please enter a valid time!");
                            }
                 if (thetime.Substring(thetime.IndexOf("-") + 1) == "12:00am" )
                 {
                     isvalid = false;
                     MessageBox.Show("Not a valid time, 12:00am is considered next day, please enter 11:59pm instead of 12:00am.");
                 }
            }
            catch (Exception e) { MessageBox.Show(e.Message); }
            
            return isvalid;

        }

       /***************************************************************************
        * Loads staff promised hours for the selected work week
        ***************************************************************************/
        private void workWeekdateTimePicker_ValueChanged(object sender, EventArgs e)
        {
            if (workWeekdateTimePicker.Value.DayOfWeek.ToString() == "Sunday")
            {
                hourspanel.Show();
                RefreshControls();
                LoadStaffHours(workWeekdateTimePicker.Value, "Sunday",    suns1textBox, suns2textBox, suns3textBox, sunnotetextBox,sunnumericUpDown);                
                
                LoadStaffHours(workWeekdateTimePicker.Value, "Monday",    mons1textBox, mons2textBox, mons3textBox, monnotetextBox,monnumericUpDown);                

                LoadStaffHours(workWeekdateTimePicker.Value, "Tuesday",   tues1textBox, tues2textBox, tues3textBox, tuenotetextBox,tuenumericUpDown);
               
                LoadStaffHours(workWeekdateTimePicker.Value, "Wednesday", weds1textBox, weds2textBox, weds3textBox, wednotetextBox,wednumericUpDown);
               
                LoadStaffHours(workWeekdateTimePicker.Value, "Thursday",  thus1textBox, thus2textBox, thus3textBox, thunotetextBox,thunumericUpDown);
                
                LoadStaffHours(workWeekdateTimePicker.Value, "Friday",    fris1textBox, fris2textBox, fris3textBox, frinotetextBox,frinumericUpDown);
             
                LoadStaffHours(workWeekdateTimePicker.Value, "Saturday",  sats1textBox, sats2textBox, sats3textBox, satnotetextBox,satnumericUpDown);              
            }
            else hourspanel.Hide();
        }
      
       /***************************************************************************
        * Set the day value depending on the daycombobox selection
        ***************************************************************************/
        private void FindDayDate(string dayofweek)
        {
            day = workWeekdateTimePicker.Value;
            savebutton.Enabled = true;
            switch (dayofweek)
            {
                case "Sunday":
                    {
                        day = workWeekdateTimePicker.Value;
                        d1label.Text = day.ToShortDateString();
                        i = 0;
                        break;
                    }
                case "Monday":
                    {
                        day = workWeekdateTimePicker.Value.AddDays(1);
                        d2label.Text = day.ToShortDateString();
                        i = 1;
                        break;
                    }
                case "Tuesday":
                    {
                        day = workWeekdateTimePicker.Value.AddDays(2);
                        d3label.Text = day.ToShortDateString();
                        i = 2;
                        break;
                    }
                case "Wednesday":
                    {
                        day = workWeekdateTimePicker.Value.AddDays(3);
                        d4label.Text = day.ToShortDateString();
                        i = 3;
                        break;
                    }
                case "Thursday":
                    {
                        day = workWeekdateTimePicker.Value.AddDays(4);
                        d5label.Text = day.ToShortDateString();
                        i = 4;
                        break;
                    }
                case "Friday":
                    {
                        day = workWeekdateTimePicker.Value.AddDays(5);
                        d6label.Text = day.ToShortDateString();
                        i = 5;
                        break;
                    }
                case "Saturday":
                    {
                        day = workWeekdateTimePicker.Value.AddDays(6);
                        d7label.Text = day.ToShortDateString();
                        i = 6;
                        break;
                    }
            }
        }           

       /***************************************************************************
        * ShiftsOverlap() is used to find if two shifts are overlaping 
        ***************************************************************************/
        private bool ShiftsOverlap(double starttime,double endtime, int shift)
        {
            bool overlaps = false;
            if (starttime != 0)
                switch (shift)
                {
                    case 1:
                        {
                            if (((((starttime >= shift2start) && (starttime <= shift2end))||
                                ((endtime   >= shift2start) && (endtime   <= shift2end)))&& (shift2start != 0)) || 
                                ((((starttime >= shift3start) && (starttime <= shift3end))||
                                ((endtime >= shift3start) && (endtime <= shift3end)))&& (shift3start != 0)))
                                overlaps = true;
                            break;
                        }
                    case 2:
                        {
                            if (((((starttime >= shift1start) && (starttime <= shift1end)) ||
                                ((endtime >= shift1start) && (endtime <= shift1end))) && (shift1start != 0)) ||
                                ((((starttime >= shift3start) && (starttime <= shift3end)) ||
                                ((endtime >= shift3start) && (endtime <= shift3end))) && (shift3start != 0)))
                                overlaps = true;
                            break;
                        }
                    case 3:
                        {
                          if (((((starttime >= shift2start) && (starttime <= shift2end))||
                                ((endtime   >= shift2start) && (endtime   <= shift2end)))&& (shift2start != 0)) || 
                                ((((starttime >= shift1start) && (starttime <= shift1end))||
                                ((endtime >= shift1start) && (endtime <= shift1end)))&& (shift1start != 0)))
                                overlaps = true;
                            break;
                        }
                }
            return overlaps;
        }

    
       
        private string shift;

        private bool CheckValidTime(TextBox s1, TextBox s2, TextBox s3, NumericUpDown total)
        {
            bool valid = false;
            if (s1.Text != "")
            {
                shift = s1.Text;
                s1.Text = shift.Replace(" ", string.Empty);
                if (IsValidTime(s1.Text))
                {
                    //total.Enabled = false;
                    valid = true;
                }
                else {s1.Focus(); valid = false; }
            }
            else
                if (s2.Text == "" && s3.Text == "")
                {
                    total.Value = 0;
                    //total.Enabled = true;
                }
            return valid;
        }

        private void CalculateTime(string weekday, TextBox s1, TextBox s2, TextBox s3, NumericUpDown totaltime)
        {
       /***************************************************************************
        * Calculate the total and update the numeric updown control and total time.
        ***************************************************************************/
            FindDayDate(weekday);
            shiftsTotal = TotalShiftTime(s1.Text, day.ToShortDateString()) +
                          TotalShiftTime(s2.Text, day.ToShortDateString()) +
                          TotalShiftTime(s3.Text, day.ToShortDateString());
            if (shiftsTotal.TotalHours <= 24)
                totaltime.Value = Convert.ToDecimal(shiftsTotal.TotalHours);
            else MessageBox.Show("Total working hours in a day cannot be greater than 24!"); 
        }

       /***************************************************************************
        * Shift Time Validating events
        ***************************************************************************/
        # region

        private void suns1textBox_Leave(object sender, EventArgs e)
        {
            if (CheckValidTime(suns1textBox, suns2textBox, suns3textBox, sunnumericUpDown) || suns1textBox.Text == "")
            {
               CalculateTime("Sunday", suns1textBox, suns2textBox, suns3textBox, sunnumericUpDown);
               FindTotals(sunnumericUpDown);
            }
        }
        
        private void suns2textBox_Leave(object sender, EventArgs e)
        {
            if (CheckValidTime(suns2textBox, suns3textBox, suns1textBox, sunnumericUpDown) || suns2textBox.Text == "") 
            {
                CalculateTime("Sunday", suns1textBox, suns2textBox, suns3textBox, sunnumericUpDown);
                FindTotals(sunnumericUpDown);
            }
        }

        private void suns3textBox_Leave(object sender, EventArgs e)
        {
            if (CheckValidTime(suns3textBox, suns2textBox, suns1textBox, sunnumericUpDown) || suns3textBox.Text == "")
            {
                CalculateTime("Sunday", suns1textBox, suns2textBox, suns3textBox, sunnumericUpDown);
                FindTotals(sunnumericUpDown);
            }
        }

        private void mons1textBox_Leave(object sender, EventArgs e)
        {
            if (CheckValidTime(mons1textBox, mons2textBox, mons3textBox, monnumericUpDown) || mons1textBox.Text == "")
            {
                CalculateTime("Monday", mons1textBox, mons2textBox, mons3textBox, monnumericUpDown);
                FindTotals(monnumericUpDown);
            }
        }

        private void mons2textBox_Leave(object sender, EventArgs e)
        {
            if (CheckValidTime(mons2textBox, mons3textBox, mons1textBox, monnumericUpDown) || mons2textBox.Text == "")
            {
                CalculateTime("Monday", mons1textBox, mons2textBox, mons3textBox, monnumericUpDown);
                FindTotals(monnumericUpDown);
            }
        }

        private void mons3textBox_Leave(object sender, EventArgs e)
        {
            if (CheckValidTime(mons3textBox, mons2textBox, mons1textBox, monnumericUpDown) || mons3textBox.Text == "")
            {
                CalculateTime("Monday", mons1textBox, mons2textBox, mons3textBox, monnumericUpDown);
                FindTotals(monnumericUpDown);
            }
        }

        private void tues1textBox_Leave(object sender, EventArgs e)
        {
            if (CheckValidTime(tues1textBox, tues2textBox, tues3textBox, tuenumericUpDown) || tues1textBox.Text == "")
            {
                CalculateTime("Tuesday", tues1textBox, tues2textBox, tues3textBox, tuenumericUpDown);
                FindTotals(tuenumericUpDown);
            }
        }

        private void tues2textBox_Leave(object sender, EventArgs e)
        {
            if (CheckValidTime(tues2textBox, tues3textBox, tues1textBox, tuenumericUpDown) || tues2textBox.Text == "")
            {
                CalculateTime("Tuesday", tues1textBox, tues2textBox, tues3textBox, tuenumericUpDown);
                FindTotals(tuenumericUpDown);
            }        
        }

        private void tues3textBox_Leave(object sender, EventArgs e)
        {
            if (CheckValidTime(tues3textBox, tues2textBox, tues1textBox, tuenumericUpDown) || tues3textBox.Text == "")
            {
                CalculateTime("Tuesday", tues1textBox, tues2textBox, tues3textBox, tuenumericUpDown);
                FindTotals(tuenumericUpDown);
            }
        }

        private void weds1textBox_Leave(object sender, EventArgs e)
        {
            if (CheckValidTime(weds1textBox, weds2textBox, weds3textBox, wednumericUpDown) || weds1textBox.Text == "")
            {
                CalculateTime("Wednesday", weds1textBox, weds2textBox, weds3textBox, wednumericUpDown);
                FindTotals(wednumericUpDown);
            }
        }

        private void weds2textBox_Leave(object sender, EventArgs e)
        {
            if (CheckValidTime(weds2textBox, weds3textBox, weds1textBox, wednumericUpDown) || weds2textBox.Text == "")
            {
                CalculateTime("Wednesday", weds1textBox, weds2textBox, weds3textBox, wednumericUpDown);
                FindTotals(wednumericUpDown);
            }
        }

        private void weds3textBox_Leave(object sender, EventArgs e)
        {
            if (CheckValidTime(weds3textBox, weds2textBox, weds1textBox, wednumericUpDown) || weds3textBox.Text == "")
            {
                CalculateTime("Wednesday", weds1textBox, weds2textBox, weds3textBox, wednumericUpDown);
                FindTotals(wednumericUpDown);
            }
        }

        private void thus1textBox_Leave(object sender, EventArgs e)
        {
            if (CheckValidTime(thus1textBox, thus2textBox, thus3textBox, thunumericUpDown) || thus1textBox.Text == "")
            {
                CalculateTime("Thursday", thus1textBox, thus2textBox, thus3textBox, thunumericUpDown);
                FindTotals(thunumericUpDown);
            }
        }

        private void thus2textBox_Leave(object sender, EventArgs e)
        {
            if (CheckValidTime(thus2textBox, thus3textBox, thus1textBox, thunumericUpDown) || thus2textBox.Text == "")
            {
                CalculateTime("Thursday", thus1textBox, thus2textBox, thus3textBox, thunumericUpDown);
                FindTotals(thunumericUpDown);
            }
        }

        private void thus3textBox_Leave(object sender, EventArgs e)
        {
            if (CheckValidTime(thus3textBox, thus2textBox, thus1textBox, thunumericUpDown) || thus3textBox.Text == "")
            {
                CalculateTime("Thursday", thus1textBox, thus2textBox, thus3textBox, thunumericUpDown);
                FindTotals(thunumericUpDown);
            }
        }

        private void fris1textBox_Leave(object sender, EventArgs e)
        {
            if (CheckValidTime(fris1textBox, fris2textBox, fris3textBox, frinumericUpDown) || fris1textBox.Text == "")
            {
                CalculateTime("Friday", fris1textBox, fris2textBox, fris3textBox, frinumericUpDown);
                FindTotals(frinumericUpDown);
            }
        }

        private void fris2textBox_Leave(object sender, EventArgs e)
        {
            if (CheckValidTime(fris2textBox, fris3textBox, fris1textBox, frinumericUpDown) || fris2textBox.Text == "")
            {
                CalculateTime("Friday", fris1textBox, fris2textBox, fris3textBox, frinumericUpDown);
                FindTotals(frinumericUpDown);
            }
        }

        private void fris3textBox_Leave(object sender, EventArgs e)
        {
            if (CheckValidTime(fris3textBox, fris2textBox, fris1textBox, frinumericUpDown) || fris3textBox.Text == "")
            {
                CalculateTime("Friday", fris1textBox, fris2textBox, fris3textBox, frinumericUpDown);
                FindTotals(frinumericUpDown);
            }
        }

        private void sats1textBox_Leave(object sender, EventArgs e)
        {
            if (CheckValidTime(sats1textBox, sats2textBox, sats3textBox, satnumericUpDown) || sats1textBox.Text == "")
            {
                CalculateTime("Saturday", sats1textBox, sats2textBox, sats3textBox, satnumericUpDown);
                FindTotals(satnumericUpDown);
            }
        }

        private void sats2textBox_Leave(object sender, EventArgs e)
        {
            if (CheckValidTime(sats2textBox, sats3textBox, sats1textBox, satnumericUpDown) || sats2textBox.Text == "")
            {
                CalculateTime("Saturday", sats1textBox, sats2textBox, sats3textBox, satnumericUpDown);
                FindTotals(satnumericUpDown);
            }
        }

        private void sats3textBox_Leave(object sender, EventArgs e)
        {
            if (CheckValidTime(sats3textBox, sats2textBox, sats1textBox, satnumericUpDown) || sats3textBox.Text == "")
            {
                CalculateTime("Saturday", sats1textBox, sats2textBox, sats3textBox, satnumericUpDown);
                FindTotals(satnumericUpDown);
            }
        }
        #endregion 
       /*****************************************************************************
        * Converts a given time into 24hour format
        *****************************************************************************/
        private double ConvertTo24HourFormat(string time)
        {
            double t1 = 0;
            string t2;

            if (time != "")
            {
                t2 = time.Substring(0, time.Length - 2).Replace(":", ".");

                t1 = Convert.ToDouble(t2);
                if (time.Contains("p") || time.Contains("P"))
                    if (t1 < 12) t1 = t1 + 12;
            }
            return t1;
        }
       /*****************************************************************************
        * saves or updates all the shift timings for the entire work week
        ******************************************************************************/
        private void savebutton_Click(object sender, EventArgs e)
        {
            bool saved = true;
            bool proceed = false;
            saved = SaveRecord(suns1textBox, suns2textBox.Text, suns3textBox.Text, sunnotetextBox.Text, sunnumericUpDown.Value.ToString(), "Sunday", savetype[0], recID[0]);

            if (saved)
            {
                saved = SaveRecord(mons1textBox, mons2textBox.Text, mons3textBox.Text, monnotetextBox.Text, monnumericUpDown.Value.ToString(), "Monday", savetype[1], recID[1]);
                if (saved) proceed = true; else proceed = false;
            }
            else suns1textBox.Focus();
            if(proceed)
                if(saved)
                {
                    saved = SaveRecord(tues1textBox, tues2textBox.Text, tues3textBox.Text, tuenotetextBox.Text, tuenumericUpDown.Value.ToString(), "Tuesday", savetype[2], recID[2]);
                    if (saved) proceed = true; else proceed = false;
                }
                else mons1textBox.Focus();
            if (proceed)
                if(saved)
                {
                    saved = SaveRecord(weds1textBox, weds2textBox.Text, weds3textBox.Text, wednotetextBox.Text, wednumericUpDown.Value.ToString(), "Wednesday", savetype[3], recID[3]);
                    if (saved) proceed = true; else proceed = false;
                }
                else tues1textBox.Focus();
            if (proceed)
                if(saved)
                {
                    saved = SaveRecord(thus1textBox, thus2textBox.Text, thus3textBox.Text, thunotetextBox.Text, thunumericUpDown.Value.ToString(), "Thursday", savetype[4], recID[4]);
                    if (saved) proceed = true; else proceed = false;
                }
                else weds1textBox.Focus();
            if (proceed)
                if(saved)
                {
                    saved = SaveRecord(fris1textBox, fris2textBox.Text, fris3textBox.Text, frinotetextBox.Text, frinumericUpDown.Value.ToString(), "Friday", savetype[5], recID[5]);
                    if (saved) proceed = true; else proceed = false;
                }
                else thus1textBox.Focus();
            if (proceed)
                if(saved)
                {
                    saved = SaveRecord(sats1textBox, sats2textBox.Text, sats3textBox.Text, satnotetextBox.Text, satnumericUpDown.Value.ToString(), "Saturday", savetype[6], recID[6]);
                    if (saved) proceed = true; else proceed = false;
                }
                else fris1textBox.Focus();
            if (proceed)
            {
                workWeekdateTimePicker_ValueChanged(sender, e);
                MessageBox.Show("Update complete!", "Updated");
            }
        }

       /*****************************************************************************
        * saves or updates a record in staff_promised_hours table
        *****************************************************************************/
        private bool SaveRecord(TextBox s1, string shift2, string shift3, string note, string total, string weekday, string saveEdit, string id)
        {
            bool allowSave = true;
            string errorMsg = "";
            string[] shifts = new string[6];
            string shift1 = s1.Text;
            if (shift1 != "")
            {
                shifts[0] = shift1.Substring(0, shift1.IndexOf("-"));
                shifts[1] = shift1.Substring(shift1.IndexOf("-") + 1, (shift1.Length - shift1.IndexOf("-") - 1));
            }
            else { shifts[0] = ""; shifts[1] = "";}

            if (shift2 != "")
            {
                shifts[2] = shift2.Substring(0, shift2.IndexOf("-"));
                shifts[3] = shift2.Substring(shift2.IndexOf("-") + 1, (shift2.Length - shift2.IndexOf("-") - 1));
            }
             else { shifts[2] = ""; shifts[3] = "";}

            if (shift3 != "")
            {
                shifts[4] = shift3.Substring(0, shift3.IndexOf("-"));
                shifts[5] = shift3.Substring(shift3.IndexOf("-") + 1, (shift3.Length - shift3.IndexOf("-") - 1));
            }
            else { shifts[4] = ""; shifts[5] = "";}

            shift1start = ConvertTo24HourFormat(shifts[0]);
            shift1end   = ConvertTo24HourFormat(shifts[1]);

            shift2start = ConvertTo24HourFormat(shifts[2]);
            shift2end   = ConvertTo24HourFormat(shifts[3]);

            shift3start = ConvertTo24HourFormat(shifts[4]);
            shift3end   = ConvertTo24HourFormat(shifts[5]);

            FindDayDate(weekday);

            /***************************************************************************
             * Check if starttime less than end time 
             ***************************************************************************/
            if ((shift1start != 0 && shift1start >= shift1end) || (shift2start != 0 && shift2start >= shift2end) || (shift3start != 0 && shift3start >= shift3end))
            {
                allowSave = false;
                errorMsg = "Shift End time should be greater than shift Start time, Please correct the timings for " + weekday + " and try again!";
            }
            else
                /***************************************************************************
                 * Check if shifts are overlapping
                 ***************************************************************************/
                if (ShiftsOverlap(shift1start, shift1end, 1) || ShiftsOverlap(shift2start, shift2end, 2) || ShiftsOverlap(shift3start, shift3end, 3))
                {
                    allowSave = false;
                    errorMsg = "Shifts should not overlap with other shifts! Please check and correct the timings for " + weekday + "!";
                }
                else
                    /***************************************************************************
                     * Check if the user has entered time
                     ***************************************************************************/
                    if (((shift1end - shift1start) + (shift2end - shift2start) + (shift3end - shift3start)) <= 0 && saveEdit == "1" && total == "0")
                        allowSave = false;
                    else if (!ValidTotal(Convert.ToDecimal(total),shift1,shift2,shift3,day.ToShortDateString()))
                           {
                               allowSave = false;
                               errorMsg = "Total hours entered does not match with the shifts total for " + weekday + "! Please check and correct the timings.";
                           }

            if (allowSave)
            {
                try
                {
                    WORKFLOW.Staff.StaffHoursSave(SBSCParent.connSpedmon, userID, workWeekdateTimePicker.Value.ToShortDateString(), day.ToShortDateString(),
                                                        shifts[0], shifts[1], shifts[2], shifts[3], shifts[4], shifts[5], note,total, null, "0", saveEdit, id);
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.Message);
                }
            }
            else if (errorMsg != "")
            {
                MessageBox.Show(errorMsg);
                s1.Focus();
            }
            if (((shift1end - shift1start) + (shift2end - shift2start) + (shift3end - shift3start)) <= 0 && saveEdit == "1" && total == "0")
                allowSave = true;
            return allowSave;
        }

       /*****************************************************************************
        * Clears the input controls
        *****************************************************************************/
        private void RefreshControls()
        {
            suns1textBox.Text      = "";
            suns2textBox.Text      = "";
            suns3textBox.Text      = "";
            sunnotetextBox.Text    = "";
            mons1textBox.Text      = "";
            mons2textBox.Text      = "";
            mons3textBox.Text      = "";
            monnotetextBox.Text    = "";
            tues1textBox.Text      = "";
            tues2textBox.Text      = "";
            tues3textBox.Text      = "";
            tuenotetextBox.Text    = "";
            weds1textBox.Text      = "";
            weds2textBox.Text      = "";
            weds3textBox.Text      = "";
            wednotetextBox.Text    = "";
            thus1textBox.Text      = "";
            thus2textBox.Text      = "";
            thus3textBox.Text      = "";
            thunotetextBox.Text    = "";
            fris1textBox.Text      = "";
            fris2textBox.Text      = "";
            fris2textBox.Text      = "";
            fris3textBox.Text      = "";
            frinotetextBox.Text    = "";
            sats1textBox.Text      = "";
            sats2textBox.Text      = "";
            sats3textBox.Text      = "";
            satnotetextBox.Text    = "";              
            savebutton.Text        = "Save";
            sunnumericUpDown.Value = 0;
            monnumericUpDown.Value = 0;
            tuenumericUpDown.Value = 0;
            wednumericUpDown.Value = 0;
            thunumericUpDown.Value = 0;
            frinumericUpDown.Value = 0;
            satnumericUpDown.Value = 0;
        }

        private void cancelbutton_Click(object sender, EventArgs e)
        {
            workWeekdateTimePicker_ValueChanged(sender, e);
        }

       /*****************************************************************************
        * Returns the time difference in the shift timings
        *****************************************************************************/
        private TimeSpan TotalShiftTime(string shift,string day)
        {
            string starttime;
            string endtime;
            DateTime startdate;
            DateTime enddate;
            TimeSpan t = TimeSpan.Zero;
            if (shift != "" && shift != null)
            {
                starttime = shift.Substring(0, shift.IndexOf("-"));
                starttime = starttime.Substring(0, starttime.Length - 2) + ":00 " + starttime.Substring(starttime.Length - 2);

                endtime = shift.Substring(shift.IndexOf("-") + 1);
                endtime = endtime.Substring(0, endtime.Length - 2) + ":00 " + endtime.Substring(endtime.Length - 2);

                startdate = Convert.ToDateTime(day + " " + starttime);                
                enddate = Convert.ToDateTime(day + " " + endtime);
                if (enddate > startdate)
                    t = enddate - startdate;
                else 
                  MessageBox.Show("Start time in a shift can not be greater than or equal to end time");

            }
            return t;
        }
        /*****************************************************************************
         * Check if the Total hours entered equal to the total time between the shifts
         *****************************************************************************/
        private bool ValidTotal(decimal total, string s1, string s2,string  s3,string day)
        {            
            shiftsTotal = TimeSpan.Zero;
            if (s1 != "")
                shiftsTotal += TotalShiftTime(s1, day);
            if (s2 != "")
                shiftsTotal += TotalShiftTime(s2, day);
            if (s3 != "")
                shiftsTotal += TotalShiftTime(s3, day);

            double totalTime = shiftsTotal.TotalMinutes / 60;
            if (total != 0 && (s1 != "" || s2 != "" || s3 != "") && (total != Convert.ToDecimal(totalTime)))
                return false;            
            else                           
                return true;            
        }

        private void CalculateTotalWeekHours()
        {
            decimal total;
            total = sunnumericUpDown.Value + monnumericUpDown.Value + tuenumericUpDown.Value + wednumericUpDown.Value +
                    thunumericUpDown.Value + frinumericUpDown.Value + satnumericUpDown.Value;
            totaltextBox.Text = total.ToString();
        }


        private void FindTotals(NumericUpDown totalday)
        {
            if (totalday.Value > 8)
                MessageBox.Show("Are you sure you want to work more than 8 hours?");
            CalculateTotalWeekHours(); 
        }

        private void sunnumericUpDown_Leave(object sender, EventArgs e)
        {
            FindTotals(sunnumericUpDown);
        }

        private void monnumericUpDown_Leave(object sender, EventArgs e)
        {
            FindTotals(monnumericUpDown);
        }

        private void tuenumericUpDown_Leave(object sender, EventArgs e)
        {
            FindTotals(tuenumericUpDown);
        }

        private void wednumericUpDown_Leave(object sender, EventArgs e)
        {
            FindTotals(wednumericUpDown);
        }

        private void thunumericUpDown_Leave(object sender, EventArgs e)
        {
            FindTotals(thunumericUpDown);
        }

        private void frinumericUpDown_Leave(object sender, EventArgs e)
        {
            FindTotals(frinumericUpDown);
        }

        private void satnumericUpDown_Leave(object sender, EventArgs e)
        {
            FindTotals(satnumericUpDown);
        }        
                
    }
}
