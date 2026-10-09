using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Data;

// SBC Added For TimeKeeper
namespace MBA.BitteTime
{
     public class ScheduleTemplate
     {
          public ScheduleTemplate()
          {
               //
               // TODO: Add constructor logic here
               //
          }
          public long id { get; set; }
          public string TemplateName { get; set; }

          // going to assume template is built around 7 day work week
          public string SundayInfo
          {
               set;
               get;
          }

          public string MondayInfo
          {
               get;
               set;
          }
          public string TuesdayInfo
          {
               get;
               set;
          }

          public string WednesdayInfo
          {
               get;
               set;
          }

          public string ThursdayInfo
          {
               get;
               set;
          }
          public string FridayInfo
          {
               get;
               set;
          }

          public string SaturdayInfo
          {
               get;
               set;
          }
     }

     public class TimeEntries
     {
          public long id{ get; set; }
          public long orgEmployerID{ get; set; }
          public long peopleID{ get; set; }
          public long taskID{ get; set; }
          public long orgClientID{ get; set; }
          public string note{ get; set; }
          public DateTime startEntry{ get; set; }
          public DateTime endEntry{ get; set; }
          public DateTime dateEntryCreated{ get; set; }
          public DateTime dateEntryUpdated { get; set; }
          
          public static double getNumberHoursForDate(SqlConnection connTimeSheet, DetailsLog log, long employeeId, DateTime dateToProcess)
          {
               // Make sure to get DateTime for start of day (midnight)
               string _dateString = dateToProcess.ToString("MM/dd/yyyy") + " 00:00:00";
               DateTime _startDate = DateTime.Parse(_dateString);
               
               // Get tomorrow's date
               DateTime _endDate = _startDate.AddDays(1);
                              List<SqlParameter> _parms = new List<SqlParameter>();

               _parms.Add(Database.SqlParm("@EmployeeId", SqlDbType.BigInt, employeeId, ParameterDirection.Input));
               _parms.Add(Database.SqlParm("@StartDate", SqlDbType.DateTime, _startDate, ParameterDirection.Input));
               _parms.Add(Database.SqlParm("@EndDate", SqlDbType.DateTime, _endDate, ParameterDirection.Input));

               ReturnDB rd = Database.execQuery(connTimeSheet, log, "TIMESHEET_GetTimeEntryForEmployeeAndDate", true, _parms);
          
               if (!rd.hasRecords)
               {
                    return 0;
               }
               
               TimeEntries _timeEntries = null;
               double _numberHours = 0;
               int _numberMinutes = 0;
               TimeSpan _timeSpan;
               
               foreach(Record _record in rd.records)
               {
                    _timeEntries = new TimeEntries();
                    foreach(Field _field in _record.fields)
                    {
                         switch(_field.name)
                         {
                              case "startEntry":
                                   _timeEntries.startEntry = Convert.ToDateTime(_field.value);
                                   break;
                              case "endEntry":
                                   _timeEntries.endEntry = Convert.ToDateTime(_field.value);
                                   break;
                        }
                    }

                    _timeSpan = _timeEntries.endEntry - _timeEntries.startEntry;
                    _numberMinutes += _timeSpan.Hours*60 + _timeSpan.Minutes;
               }
               
               _numberHours = (_numberMinutes*1.0)/60.0;
               
               return _numberHours;                             
          }

     }

     public class TimeEntryWeek
     {
          public static string _SESSION_DATE_ENTRY = string.Empty;

          private List<TimeEntryDay> _ListDays = new List<TimeEntryDay>();
          public TimeEntryWeek()
          {
               //
               // TODO: Add constructor logic here
               //
          }

          public List<TimeEntryDay> ListOfDays
          {
               get { return _ListDays; }
          }
          public void SetTimeEntry(DateTime startTime, int inNumberOfMinutes)
          {
               int _index = 0;

               if (TimeEntryNotPresent(startTime, out _index))
               {
                    _ListDays[_index].SetNumberOfMinutes(inNumberOfMinutes);
                    return;
               }

               TimeEntryDay _timeEntryDay = new TimeEntryDay();
               _timeEntryDay.DateForDay = startTime;
               _timeEntryDay.SetNumberOfMinutes(inNumberOfMinutes);
               _ListDays.Add(_timeEntryDay);
          }

          public void SetDayOfWeek(DateTime dateTime)
          {
               int _index = 0;

               if (!TimeEntryNotPresent(dateTime, out _index))
               {
                    TimeEntryDay _timeEntryDay = new TimeEntryDay();
                    _timeEntryDay.DateForDay = dateTime;
                    _ListDays.Add(_timeEntryDay);
               }
          }

          private bool TimeEntryNotPresent(DateTime startTime, out int index)
          {
               bool _isPresent = false;
               index = 0;

               foreach (TimeEntryDay _timeEntryDay in _ListDays)
               {
                    if (_timeEntryDay.DateForDay.ToString("MM/dd/yyyy") == startTime.ToString("MM/dd/yyyy"))
                    {
                         _isPresent = true;
                         break;
                    }
                    ++index;
               }
               return _isPresent;
          }
     }

     /// <summary>
     /// Summary description for TimeEntryDay
     /// </summary>
     public class TimeEntryDay
     {
          private int _TotalMinutes;
          private DateTime _DateForDay;
          public TimeEntryDay()
          {
               _TotalMinutes = 0;
          }


          public DateTime DateForDay
          {
               get { return _DateForDay.Date; }
               set { _DateForDay = value.Date; }
          }

          public void SetNumberOfMinutes(int inNumberOfMinutes)
          {
               _TotalMinutes = inNumberOfMinutes;
          }

          public void AddNumberOfMinutes(int inNumberOfMinutes)
          {
               _TotalMinutes += inNumberOfMinutes;
          }

          public int NumberOfHours
          {
               get
               {
                    return (int)(_TotalMinutes / 60.0);
               }
          }

          public int NumberOfMintes
          {
               get
               {
                    return _TotalMinutes % 60;
               }
          }
     }

}
