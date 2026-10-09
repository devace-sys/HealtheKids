using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

// SBC Added for TimeKeeper
namespace MBA.BitteTime
{
     public class ScheduleStopStart
     {
          public DateTime Start { get; set; }
          public DateTime Stop { get; set; }
     }

     public class TimeEntry
     {
          public long numberMinutes { get; set; }
          public string TaskName { get; set; }
          public string TaskType { get; set; }
          public string Note { get; set; }
     }

     /// <summary>
     /// Summary description for TimeEntryScheduleReport
     /// </summary>
     public class TimeEntryScheduleReport
     {
          public TimeEntryScheduleReport()
          {
               dateOfSchedule = new List<DateTime>();
               startStopTimes = new List<ScheduleStopStart>();
               timeEntries = new List<TimeEntry>();
          }

          public TimeEntryScheduleReport(TimeEntryScheduleReport report)
          {
               _groupData = report.groupData;
               id = report.id;
               personID = report.personID;
               firstName = report.firstName;
               lastName = report.lastName;
               scheduleId = report.scheduleId;
               dateOfSchedule = new List<DateTime>();

               foreach (DateTime _dateTime in report.dateOfSchedule)
               {
                    dateOfSchedule.Add(_dateTime);
               }

               startStopTimes = new List<ScheduleStopStart>();
               foreach (ScheduleStopStart _startStop in report.startStopTimes)
               {
                    startStopTimes.Add(_startStop);
               }

               timeEntries = new List<TimeEntry>();
               foreach (TimeEntry _timeEntry in report.timeEntries)
               {
                    timeEntries.Add(_timeEntry);
               }
          }

          bool _groupData = false;
          public bool groupData
          {
               get { return _groupData; }
               set { _groupData = value; }
          }
          public long id { get; set; }
          public long personID { get; set; }
          public string firstName { get; set; }
          public string lastName { get; set; }
          public long scheduleId { get; set; }

          public string dateOfScheduleDisplay
          {
               get
               {
                    string _dateOfScheduleDisplay = string.Empty;

                    foreach (DateTime _dateTime in dateOfSchedule)
                    {
                         if (!string.IsNullOrEmpty(_dateOfScheduleDisplay))
                         {
                              _dateOfScheduleDisplay += "<br/>";
                         }
                         _dateOfScheduleDisplay += _dateTime.ToString("MM/dd/yyyy");
                    }

                    return _dateOfScheduleDisplay;
               }
          }

          public List<DateTime> dateOfSchedule { get; set; }
          public List<ScheduleStopStart> startStopTimes { get; set; }
          public List<TimeEntry> timeEntries { get; set; }

          public long totalNumberMinutes
          {
               get
               {
                    long _totalMinutes = 0;

                    foreach (TimeEntry _timeEntry in timeEntries)
                    {
                         _totalMinutes += _timeEntry.numberMinutes;
                    }

                    return _totalMinutes;
               }
          }

          public string recordedTimeEntryTasks
          {
               get
               {
                    string _recordedTimeEntry = string.Empty;

                    foreach (TimeEntry _timeEntry in timeEntries)
                    {
                         if (!string.IsNullOrEmpty(_recordedTimeEntry))
                         {
                              _recordedTimeEntry += "<br/>";
                         }
                         _recordedTimeEntry += _timeEntry.TaskName;
                         _recordedTimeEntry += ((int)(_timeEntry.numberMinutes / 60.0)) == 0 ? string.Empty : " " + ((int)(_timeEntry.numberMinutes / 60.0)).ToString() + " hours";
                         _recordedTimeEntry += _timeEntry.numberMinutes % 60 == 0 ? string.Empty : " " + (_timeEntry.numberMinutes % 60).ToString() + " minutes";
                    }

                    return _recordedTimeEntry;
               }
          }
          public string Notes
          {
               get
               {
                    string _notes = string.Empty;

                    foreach (TimeEntry timeEntry in timeEntries)
                    {
                         if (string.IsNullOrEmpty(timeEntry.Note))
                         {
                              continue;
                         }

                         if (string.IsNullOrEmpty(_notes))
                         {
                              _notes = timeEntry.Note;
                         }
                         else
                         {
                              _notes += "<br/>" + timeEntry.Note;
                         }
                    }

                    return _notes;
               }
          }
          public string HoursWorked
          {
               get
               {
                    int _hours = (int)((totalNumberMinutes) / 60.0);

                    return _hours.ToString() + " Hours";
               }
          }

          public string MinutesWorked
          {
               get
               {
                    long _minutes = totalNumberMinutes % 60;

                    return _minutes == 0 ? string.Empty : _minutes.ToString() + " Minutes";
               }
          }

          public string TimeWorked
          {
               get
               {
                    return HoursWorked + " " + MinutesWorked;
               }
          }

          public string TotalScheduledTime
          {
               get
               {
                    string _scheduledTime = string.Empty;
                    TimeSpan _timeSpan;
                    double _totalMinutes = 0;

                    foreach (ScheduleStopStart _scheduleStopStart in startStopTimes)
                    {
                         _timeSpan = _scheduleStopStart.Stop.Subtract(_scheduleStopStart.Start);
                         _totalMinutes += _timeSpan.TotalMinutes;
                    }

                    int _hours = (int)(_totalMinutes / 60);
                    int _minutes = ((int)_totalMinutes) % 60;

                    _scheduledTime = (_hours == 0 ? string.Empty : _hours.ToString() + " hours ")
                        + (_minutes == 0 ? string.Empty : _minutes.ToString() + " minutes");

                    return _scheduledTime;
               }
          }
          public string ScheduleTime
          {
               get
               {
                    string _schedule = string.Empty;

                    foreach (ScheduleStopStart _scheduleStopStart in startStopTimes)
                    {
                         if (_groupData)
                         {
                              if (string.IsNullOrEmpty(_schedule))
                              {
                                   _schedule = _scheduleStopStart.Start.ToString("MM/dd/yyyy hh:mm tt") + " to " +
                                       _scheduleStopStart.Stop.ToString("MM/dd/yyyy hh:mm tt");
                              }
                              else
                              {
                                   _schedule += "<br/>" + _scheduleStopStart.Start.ToString("MM/dd/yyyy hh:mm tt") + " to " +
                                       _scheduleStopStart.Stop.ToString("MM/dd/yyyy hh:mm tt");
                              }
                         }
                         else
                         {
                              if (string.IsNullOrEmpty(_schedule))
                              {
                                   _schedule = _scheduleStopStart.Start.ToString("hh:mm tt") + " to " +
                                       _scheduleStopStart.Stop.ToString("hh:mm tt");
                              }
                              else
                              {
                                   _schedule += "<br/>" + _scheduleStopStart.Start.ToString("hh:mm tt") + " to " +
                                       _scheduleStopStart.Stop.ToString("hh:mm tt");
                              }
                         }
                    }
                    return _schedule;
               }
          }
     }
}
